package com.inmobiliaria.dao;

import com.inmobiliaria.config.ConexionDB;
import com.inmobiliaria.modelo.Propiedad;

import java.sql.*;
import java.util.ArrayList;
import java.util.List;

public class PropiedadDAO {

    /* -------------------------------------------------
       1) LISTAR con filtros dinámicos
       ------------------------------------------------- */
    public List<Propiedad> listar(String ciudad, String tipo, Double precioMax,
                                  List<Integer> idCaracteristicas, String estado) throws SQLException {

        StringBuilder sql = new StringBuilder(
            "SELECT p.*, c.nombre AS ciudad, t.nombre AS tipo, i.razon_social " +
            "FROM propiedad p " +
            "INNER JOIN ciudad c ON p.id_ciudad = c.id_ciudad " +
            "INNER JOIN tipo_propiedad t ON p.id_tipo = t.id_tipo " +
            "INNER JOIN inmobiliaria i ON p.id_inmobiliaria = i.id_inmobiliaria " +
            "WHERE 1=1 ");

        List<Object> params = new ArrayList<>();

        if (ciudad != null && !ciudad.isEmpty()) {
            sql.append("AND c.nombre = ? ");
            params.add(ciudad);
        }
        if (tipo != null && !tipo.isEmpty()) {
            sql.append("AND t.nombre = ? ");
            params.add(tipo);
        }
        if (precioMax != null) {
            sql.append("AND p.precio <= ? ");
            params.add(precioMax);
        }
        if (estado != null && !estado.isEmpty()) {
            sql.append("AND p.estado = ? ");
            params.add(estado);
        }
        if (idCaracteristicas != null && !idCaracteristicas.isEmpty()) {
            sql.append("AND p.id_propiedad IN (")
               .append("SELECT pc.id_propiedad FROM propiedad_caracteristica pc ")
               .append("WHERE pc.id_caracteristica IN (")
               .append("?,".repeat(idCaracteristicas.size()))
               .deleteCharAt(sql.length() - 1) // quita última coma
               .append(") GROUP BY pc.id_propiedad ")
               .append("HAVING COUNT(DISTINCT pc.id_caracteristica) = ?) ");
            params.addAll(idCaracteristicas);
            params.add(idCaracteristicas.size());
        }

        sql.append("ORDER BY p.fecha_publicacion DESC");

        List<Propiedad> lista = new ArrayList<>();
        try (Connection cn = ConexionDB.getConnection();
             PreparedStatement ps = cn.prepareStatement(sql.toString())) {

            for (int i = 0; i < params.size(); i++) {
                ps.setObject(i + 1, params.get(i));
            }
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) lista.add(mapear(rs));
            }
        }
        // cargar imágenes y características de cada propiedad
        for (Propiedad p : lista) {
            p.setImagenes(listarImagenes(p.getIdPropiedad()));
            p.setCaracteristicas(listarCaracteristicas(p.getIdPropiedad()));
        }
        return lista;
    }

    /* -------------------------------------------------
       2) BUSCAR POR ID (con relaciones cargadas)
       ------------------------------------------------- */
    public Propiedad buscarPorId(int id) throws SQLException {
        String sql = "SELECT p.*, c.nombre AS ciudad, t.nombre AS tipo, i.razon_social " +
                     "FROM propiedad p " +
                     "INNER JOIN ciudad c ON p.id_ciudad = c.id_ciudad " +
                     "INNER JOIN tipo_propiedad t ON p.id_tipo = t.id_tipo " +
                     "INNER JOIN inmobiliaria i ON p.id_inmobiliaria = i.id_inmobiliaria " +
                     "WHERE p.id_propiedad = ?";
        try (Connection cn = ConexionDB.getConnection();
             PreparedStatement ps = cn.prepareStatement(sql)) {
            ps.setInt(1, id);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    Propiedad p = mapear(rs);
                    p.setImagenes(listarImagenes(id));
                    p.setCaracteristicas(listarCaracteristicas(id));
                    return p;
                }
            }
        }
        return null;
    }

    /* -------------------------------------------------
       3) INSERTAR con transacción (propiedad + imágenes + características)
       ------------------------------------------------- */
    public int insertar(Propiedad p, List<String> urlsImagenes,
                        List<Integer> idsCaracteristicas) throws SQLException {

        Connection cn = null;
        try {
            cn = ConexionDB.getConnection();
            cn.setAutoCommit(false);

            String sql = "INSERT INTO propiedad " +
                "(matricula_inmobiliaria, titulo, descripcion, precio, area_m2, " +
                " habitaciones, banos, direccion, estado, id_tipo, id_ciudad, id_inmobiliaria) " +
                "VALUES (?,?,?,?,?,?,?,?,?,?,?,?)";

            int idGenerado;
            try (PreparedStatement ps = cn.prepareStatement(sql, Statement.RETURN_GENERATED_KEYS)) {
                ps.setString(1, p.getMatriculaInmobiliaria());
                ps.setString(2, p.getTitulo());
                ps.setString(3, p.getDescripcion());
                ps.setBigDecimal(4, p.getPrecio());
                ps.setBigDecimal(5, p.getAreaM2());
                ps.setInt(6, p.getHabitaciones());
                ps.setInt(7, p.getBanos());
                ps.setString(8, p.getDireccion());
                ps.setString(9, p.getEstado() == null ? "DISPONIBLE" : p.getEstado());
                ps.setInt(10, p.getIdTipo());
                ps.setInt(11, p.getIdCiudad());
                ps.setInt(12, p.getIdInmobiliaria());
                ps.executeUpdate();

                try (ResultSet rs = ps.getGeneratedKeys()) {
                    rs.next();
                    idGenerado = rs.getInt(1);
                }
            }

            // Imágenes (1:N)
            if (urlsImagenes != null && !urlsImagenes.isEmpty()) {
                String sqlImg = "INSERT INTO imagen_propiedad (id_propiedad, url, orden) VALUES (?,?,?)";
                try (PreparedStatement ps = cn.prepareStatement(sqlImg)) {
                    int orden = 1;
                    for (String url : urlsImagenes) {
                        ps.setInt(1, idGenerado);
                        ps.setString(2, url);
                        ps.setInt(3, orden++);
                        ps.addBatch();
                    }
                    ps.executeBatch();
                }
            }

            // Características (N:M)
            if (idsCaracteristicas != null && !idsCaracteristicas.isEmpty()) {
                String sqlCar = "INSERT INTO propiedad_caracteristica (id_propiedad, id_caracteristica) VALUES (?,?)";
                try (PreparedStatement ps = cn.prepareStatement(sqlCar)) {
                    for (Integer idCar : idsCaracteristicas) {
                        ps.setInt(1, idGenerado);
                        ps.setInt(2, idCar);
                        ps.addBatch();
                    }
                    ps.executeBatch();
                }
            }

            cn.commit();
            return idGenerado;

        } catch (SQLException e) {
            if (cn != null) cn.rollback();
            throw e;
        } finally {
            if (cn != null) {
                cn.setAutoCommit(true);
                cn.close();
            }
        }
    }

    /* -------------------------------------------------
       4) ACTUALIZAR
       ------------------------------------------------- */
    public void actualizar(Propiedad p, List<String> urlsImagenes,
                           List<Integer> idsCaracteristicas) throws SQLException {
        Connection cn = null;
        try {
            cn = ConexionDB.getConnection();
            cn.setAutoCommit(false);

            String sql = "UPDATE propiedad SET titulo=?, descripcion=?, precio=?, area_m2=?, " +
                         "habitaciones=?, banos=?, direccion=?, estado=?, id_tipo=?, id_ciudad=? " +
                         "WHERE id_propiedad=?";
            try (PreparedStatement ps = cn.prepareStatement(sql)) {
                ps.setString(1, p.getTitulo());
                ps.setString(2, p.getDescripcion());
                ps.setBigDecimal(3, p.getPrecio());
                ps.setBigDecimal(4, p.getAreaM2());
                ps.setInt(5, p.getHabitaciones());
                ps.setInt(6, p.getBanos());
                ps.setString(7, p.getDireccion());
                ps.setString(8, p.getEstado());
                ps.setInt(9, p.getIdTipo());
                ps.setInt(10, p.getIdCiudad());
                ps.setInt(11, p.getIdPropiedad());
                ps.executeUpdate();
            }

            // Imágenes: borrar y volver a insertar (enfoque simple)
            if (urlsImagenes != null) {
                try (PreparedStatement ps = cn.prepareStatement(
                        "DELETE FROM imagen_propiedad WHERE id_propiedad=?")) {
                    ps.setInt(1, p.getIdPropiedad());
                    ps.executeUpdate();
                }
                String sqlImg = "INSERT INTO imagen_propiedad (id_propiedad, url, orden) VALUES (?,?,?)";
                try (PreparedStatement ps = cn.prepareStatement(sqlImg)) {
                    int orden = 1;
                    for (String url : urlsImagenes) {
                        ps.setInt(1, p.getIdPropiedad());
                        ps.setString(2, url);
                        ps.setInt(3, orden++);
                        ps.addBatch();
                    }
                    ps.executeBatch();
                }
            }

            // Características: mismo enfoque
            if (idsCaracteristicas != null) {
                try (PreparedStatement ps = cn.prepareStatement(
                        "DELETE FROM propiedad_caracteristica WHERE id_propiedad=?")) {
                    ps.setInt(1, p.getIdPropiedad());
                    ps.executeUpdate();
                }
                String sqlCar = "INSERT INTO propiedad_caracteristica (id_propiedad, id_caracteristica) VALUES (?,?)";
                try (PreparedStatement ps = cn.prepareStatement(sqlCar)) {
                    for (Integer idCar : idsCaracteristicas) {
                        ps.setInt(1, p.getIdPropiedad());
                        ps.setInt(2, idCar);
                        ps.addBatch();
                    }
                    ps.executeBatch();
                }
            }

            cn.commit();
        } catch (SQLException e) {
            if (cn != null) cn.rollback();
            throw e;
        } finally {
            if (cn != null) { cn.setAutoCommit(true); cn.close(); }
        }
    }

    /* -------------------------------------------------
       5) BAJA LÓGICA
       ------------------------------------------------- */
    public void darDeBaja(int idPropiedad) throws SQLException {
        String sql = "UPDATE propiedad SET estado='INACTIVA' WHERE id_propiedad=?";
        try (Connection cn = ConexionDB.getConnection();
             PreparedStatement ps = cn.prepareStatement(sql)) {
            ps.setInt(1, idPropiedad);
            ps.executeUpdate();
        }
    }

    /* -------------------------------------------------
       Helpers privados
       ------------------------------------------------- */
    private Propiedad mapear(ResultSet rs) throws SQLException {
        Propiedad p = new Propiedad();
        p.setIdPropiedad(rs.getInt("id_propiedad"));
        p.setMatriculaInmobiliaria(rs.getString("matricula_inmobiliaria"));
        p.setTitulo(rs.getString("titulo"));
        p.setDescripcion(rs.getString("descripcion"));
        p.setPrecio(rs.getBigDecimal("precio"));
        p.setAreaM2(rs.getBigDecimal("area_m2"));
        p.setHabitaciones(rs.getInt("habitaciones"));
        p.setBanos(rs.getInt("banos"));
        p.setDireccion(rs.getString("direccion"));
        p.setEstado(rs.getString("estado"));
        p.setIdTipo(rs.getInt("id_tipo"));
        p.setIdCiudad(rs.getInt("id_ciudad"));
        p.setIdInmobiliaria(rs.getInt("id_inmobiliaria"));
        try { p.setNombreCiudad(rs.getString("ciudad")); } catch (SQLException ignored) {}
        try { p.setNombreTipo(rs.getString("tipo")); } catch (SQLException ignored) {}
        try { p.setRazonSocialInmobiliaria(rs.getString("razon_social")); } catch (SQLException ignored) {}
        return p;
    }

    private List<String> listarImagenes(int idPropiedad) throws SQLException {
        List<String> lista = new ArrayList<>();
        String sql = "SELECT url FROM imagen_propiedad WHERE id_propiedad=? ORDER BY orden";
        try (Connection cn = ConexionDB.getConnection();
             PreparedStatement ps = cn.prepareStatement(sql)) {
            ps.setInt(1, idPropiedad);
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) lista.add(rs.getString("url"));
            }
        }
        return lista;
    }

    private List<String> listarCaracteristicas(int idPropiedad) throws SQLException {
        List<String> lista = new ArrayList<>();
        String sql = "SELECT c.nombre FROM caracteristica c " +
                     "INNER JOIN propiedad_caracteristica pc ON c.id_caracteristica = pc.id_caracteristica " +
                     "WHERE pc.id_propiedad=?";
        try (Connection cn = ConexionDB.getConnection();
             PreparedStatement ps = cn.prepareStatement(sql)) {
            ps.setInt(1, idPropiedad);
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) lista.add(rs.getString("nombre"));
            }
        }
        return lista;
    }

    /* -------------------------------------------------
       6) Consulta del reporte (GROUP BY + HAVING)
       ------------------------------------------------- */
    public List<String[]> reportePorCiudad() throws SQLException {
        List<String[]> lista = new ArrayList<>();
        String sql = "SELECT c.nombre AS ciudad, COUNT(p.id_propiedad) AS total " +
                     "FROM ciudad c LEFT JOIN propiedad p ON c.id_ciudad = p.id_ciudad " +
                     "GROUP BY c.id_ciudad, c.nombre " +
                     "HAVING COUNT(p.id_propiedad) >= 1 " +
                     "ORDER BY total DESC";
        try (Connection cn = ConexionDB.getConnection();
             PreparedStatement ps = cn.prepareStatement(sql);
             ResultSet rs = ps.executeQuery()) {
            while (rs.next()) {
                lista.add(new String[]{ rs.getString("ciudad"), String.valueOf(rs.getInt("total")) });
            }
        }
        return lista;
    }
}
