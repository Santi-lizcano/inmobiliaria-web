package com.inmobiliaria.dao;

import com.inmobiliaria.config.ConexionDB;
import com.inmobiliaria.modelo.Cita;

import java.sql.*;
import java.time.LocalDateTime;
import java.util.ArrayList;
import java.util.List;

public class CitaDAO {

    /* ============================================================
       1) INSERTAR cita (el UNIQUE (id_propiedad, fecha_hora) se propaga)
       ============================================================ */
    public int insertar(Cita c) throws SQLException {
        String sql = "INSERT INTO cita (id_propiedad, id_usuario, fecha_hora, estado, observaciones) " +
                     "VALUES (?, ?, ?, ?, ?)";
        try (Connection cn = ConexionDB.getConnection();
             PreparedStatement ps = cn.prepareStatement(sql, Statement.RETURN_GENERATED_KEYS)) {
            ps.setInt(1, c.getIdPropiedad());
            ps.setInt(2, c.getIdUsuario());
            ps.setTimestamp(3, Timestamp.valueOf(c.getFechaHora()));
            ps.setString(4, c.getEstado() == null ? "PENDIENTE" : c.getEstado());
            ps.setString(5, c.getObservaciones());
            ps.executeUpdate();

            try (ResultSet rs = ps.getGeneratedKeys()) {
                if (rs.next()) return rs.getInt(1);
            }
        }
        return -1;
    }

    /* ============================================================
       2) VERIFICAR si ya existe una cita en ese horario
       ============================================================ */
    public boolean existeEnHorario(int idPropiedad, LocalDateTime fechaHora) throws SQLException {
        String sql = "SELECT 1 FROM cita WHERE id_propiedad = ? AND fecha_hora = ? " +
                     "AND estado NOT IN ('CANCELADA') LIMIT 1";
        try (Connection cn = ConexionDB.getConnection();
             PreparedStatement ps = cn.prepareStatement(sql)) {
            ps.setInt(1, idPropiedad);
            ps.setTimestamp(2, Timestamp.valueOf(fechaHora));
            try (ResultSet rs = ps.executeQuery()) {
                return rs.next();
            }
        }
    }

    /* ============================================================
       3) LISTAR citas de un cliente
       ============================================================ */
    public List<Cita> listarPorUsuario(int idUsuario) throws SQLException {
        String sql =
            "SELECT c.*, p.titulo AS titulo_propiedad " +
            "FROM cita c " +
            "INNER JOIN propiedad p ON c.id_propiedad = p.id_propiedad " +
            "WHERE c.id_usuario = ? " +
            "ORDER BY c.fecha_hora DESC";
        return ejecutarListado(sql, idUsuario);
    }

    /* ============================================================
       4) LISTAR citas de las propiedades de una inmobiliaria
       ============================================================ */
    public List<Cita> listarPorInmobiliaria(int idInmobiliaria) throws SQLException {
        String sql =
            "SELECT c.*, p.titulo AS titulo_propiedad, " +
            "       CONCAT(pe.nombres,' ',pe.apellidos) AS nombre_cliente, " +
            "       u.correo AS correo_cliente, pe.telefono AS telefono_cliente " +
            "FROM cita c " +
            "INNER JOIN propiedad p ON c.id_propiedad = p.id_propiedad " +
            "INNER JOIN usuario u ON c.id_usuario = u.id_usuario " +
            "LEFT JOIN perfil pe ON pe.id_usuario = u.id_usuario " +
            "WHERE p.id_inmobiliaria = ? " +
            "ORDER BY c.fecha_hora DESC";
        return ejecutarListado(sql, idInmobiliaria);
    }

    /* ============================================================
       5) LISTAR TODAS (admin)
       ============================================================ */
    public List<Cita> listarTodas() throws SQLException {
        String sql =
            "SELECT c.*, p.titulo AS titulo_propiedad, " +
            "       CONCAT(pe.nombres,' ',pe.apellidos) AS nombre_cliente, " +
            "       u.correo AS correo_cliente, pe.telefono AS telefono_cliente " +
            "FROM cita c " +
            "INNER JOIN propiedad p ON c.id_propiedad = p.id_propiedad " +
            "INNER JOIN usuario u ON c.id_usuario = u.id_usuario " +
            "LEFT JOIN perfil pe ON pe.id_usuario = u.id_usuario " +
            "ORDER BY c.fecha_hora DESC";
        return ejecutarListado(sql, null);
    }

    /* ============================================================
       6) BUSCAR por ID
       ============================================================ */
    public Cita buscarPorId(int idCita) throws SQLException {
        String sql =
            "SELECT c.*, p.titulo AS titulo_propiedad, " +
            "       CONCAT(pe.nombres,' ',pe.apellidos) AS nombre_cliente, " +
            "       u.correo AS correo_cliente, pe.telefono AS telefono_cliente " +
            "FROM cita c " +
            "INNER JOIN propiedad p ON c.id_propiedad = p.id_propiedad " +
            "INNER JOIN usuario u ON c.id_usuario = u.id_usuario " +
            "LEFT JOIN perfil pe ON pe.id_usuario = u.id_usuario " +
            "WHERE c.id_cita = ?";
        try (Connection cn = ConexionDB.getConnection();
             PreparedStatement ps = cn.prepareStatement(sql)) {
            ps.setInt(1, idCita);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) return mapear(rs);
            }
        }
        return null;
    }

    /* ============================================================
       7) CAMBIAR ESTADO (CONFIRMADA / CANCELADA / REALIZADA)
       ============================================================ */
    public void cambiarEstado(int idCita, String nuevoEstado) throws SQLException {
        String sql = "UPDATE cita SET estado = ? WHERE id_cita = ?";
        try (Connection cn = ConexionDB.getConnection();
             PreparedStatement ps = cn.prepareStatement(sql)) {
            ps.setString(1, nuevoEstado);
            ps.setInt(2, idCita);
            ps.executeUpdate();
        }
    }

    /* ============================================================
       8) ELIMINAR (borrado físico, solo admin)
       ============================================================ */
    public void eliminar(int idCita) throws SQLException {
        String sql = "DELETE FROM cita WHERE id_cita = ?";
        try (Connection cn = ConexionDB.getConnection();
             PreparedStatement ps = cn.prepareStatement(sql)) {
            ps.setInt(1, idCita);
            ps.executeUpdate();
        }
    }

    /* ============================================================
       HELPERS
       ============================================================ */
    private List<Cita> ejecutarListado(String sql, Integer param) throws SQLException {
        List<Cita> lista = new ArrayList<>();
        try (Connection cn = ConexionDB.getConnection();
             PreparedStatement ps = cn.prepareStatement(sql)) {
            if (param != null) ps.setInt(1, param);
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) lista.add(mapear(rs));
            }
        }
        return lista;
    }

    private Cita mapear(ResultSet rs) throws SQLException {
        Cita c = new Cita();
        c.setIdCita(rs.getInt("id_cita"));
        c.setIdPropiedad(rs.getInt("id_propiedad"));
        c.setIdUsuario(rs.getInt("id_usuario"));
        Timestamp ts = rs.getTimestamp("fecha_hora");
        if (ts != null) c.setFechaHora(ts.toLocalDateTime());
        c.setEstado(rs.getString("estado"));
        c.setObservaciones(rs.getString("observaciones"));

        // Campos joined (pueden venir null según la consulta)
        try { c.setTituloPropiedad(rs.getString("titulo_propiedad")); } catch (SQLException ignored) {}
        try { c.setNombreCliente(rs.getString("nombre_cliente")); } catch (SQLException ignored) {}
        try { c.setCorreoCliente(rs.getString("correo_cliente")); } catch (SQLException ignored) {}
        try { c.setTelefonoCliente(rs.getString("telefono_cliente")); } catch (SQLException ignored) {}
        return c;
    }
}
