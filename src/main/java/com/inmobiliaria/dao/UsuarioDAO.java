package com.inmobiliaria.dao;

import com.inmobiliaria.config.ConexionDB;
import com.inmobiliaria.modelo.Usuario;

import java.sql.*;
import java.util.ArrayList;
import java.util.List;

public class UsuarioDAO {

    /* ============================================================
       1) REGISTRO: inserta usuario + perfil + rol CLIENTE
          Todo en una sola transacción.
       ============================================================ */
    public int insertarConPerfil(Usuario u) throws SQLException {
        Connection cn = null;
        try {
            cn = ConexionDB.getConnection();
            cn.setAutoCommit(false);

            // --- 1. Insertar usuario ---
            String sqlUsuario =
                "INSERT INTO usuario (correo, password_hash, estado, intentos_fallidos) " +
                "VALUES (?, ?, 'ACTIVO', 0)";

            int idUsuario;
            try (PreparedStatement ps = cn.prepareStatement(sqlUsuario,
                    Statement.RETURN_GENERATED_KEYS)) {
                ps.setString(1, u.getCorreo());
                ps.setString(2, u.getPasswordHash());   // ya viene hasheado con BCrypt
                ps.executeUpdate();

                try (ResultSet rs = ps.getGeneratedKeys()) {
                    if (!rs.next()) throw new SQLException("No se generó ID de usuario.");
                    idUsuario = rs.getInt(1);
                }
            }

            // --- 2. Insertar perfil (relación 1:1, id_usuario UNIQUE) ---
            String sqlPerfil =
                "INSERT INTO perfil (id_usuario, nombres, apellidos, documento, " +
                "                    telefono, direccion) " +
                "VALUES (?, ?, ?, ?, ?, ?)";
            try (PreparedStatement ps = cn.prepareStatement(sqlPerfil)) {
                ps.setInt(1, idUsuario);
                ps.setString(2, u.getNombres());
                ps.setString(3, u.getApellidos());
                ps.setString(4, u.getDocumento());
                ps.setString(5, u.getTelefono());
                ps.setString(6, u.getDireccion());
                ps.executeUpdate();
            }

            // --- 3. Asignar rol CLIENTE por defecto (N:M) ---
            String sqlRol =
                "INSERT INTO usuario_rol (id_usuario, id_rol) " +
                "SELECT ?, id_rol FROM rol WHERE nombre = 'CLIENTE'";
            try (PreparedStatement ps = cn.prepareStatement(sqlRol)) {
                ps.setInt(1, idUsuario);
                ps.executeUpdate();
            }

            // --- 4. Auditoría ---
            registrarAuditoriaInterno(cn, idUsuario, "REGISTRO",
                    "Usuario registrado con correo " + u.getCorreo(), null);

            cn.commit();
            return idUsuario;

        } catch (SQLException e) {
            if (cn != null) cn.rollback();
            throw e;   // El Servlet capturará SQLIntegrityConstraintViolationException
        } finally {
            if (cn != null) {
                cn.setAutoCommit(true);
                cn.close();
            }
        }
    }

    /* ============================================================
       2) BUSCAR POR CORREO (para login)
       ============================================================ */
    public Usuario buscarPorCorreo(String correo) throws SQLException {
        String sql =
            "SELECT u.id_usuario, u.correo, u.password_hash, u.estado, " +
            "       u.intentos_fallidos, u.fecha_registro, " +
            "       p.nombres, p.apellidos, p.documento, p.telefono, p.direccion, p.foto " +
            "FROM usuario u " +
            "LEFT JOIN perfil p ON u.id_usuario = p.id_usuario " +
            "WHERE u.correo = ?";

        try (Connection cn = ConexionDB.getConnection();
             PreparedStatement ps = cn.prepareStatement(sql)) {
            ps.setString(1, correo);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) return mapear(rs);
            }
        }
        return null;
    }

    /* ============================================================
       3) BUSCAR POR ID
       ============================================================ */
    public Usuario buscarPorId(int idUsuario) throws SQLException {
        String sql =
            "SELECT u.id_usuario, u.correo, u.password_hash, u.estado, " +
            "       u.intentos_fallidos, u.fecha_registro, " +
            "       p.nombres, p.apellidos, p.documento, p.telefono, p.direccion, p.foto " +
            "FROM usuario u " +
            "LEFT JOIN perfil p ON u.id_usuario = p.id_usuario " +
            "WHERE u.id_usuario = ?";

        try (Connection cn = ConexionDB.getConnection();
             PreparedStatement ps = cn.prepareStatement(sql)) {
            ps.setInt(1, idUsuario);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) return mapear(rs);
            }
        }
        return null;
    }

    /* ============================================================
       4) OBTENER ROLES DEL USUARIO (para la sesión)
       ============================================================ */
    public List<String> obtenerRoles(int idUsuario) throws SQLException {
        List<String> roles = new ArrayList<>();
        String sql =
            "SELECT r.nombre FROM rol r " +
            "INNER JOIN usuario_rol ur ON r.id_rol = ur.id_rol " +
            "WHERE ur.id_usuario = ?";

        try (Connection cn = ConexionDB.getConnection();
             PreparedStatement ps = cn.prepareStatement(sql)) {
            ps.setInt(1, idUsuario);
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) roles.add(rs.getString("nombre"));
            }
        }
        return roles;
    }

    /* ============================================================
       5) ASIGNAR ROL (evita duplicados en usuario_rol)
       ============================================================ */
    public boolean asignarRol(int idUsuario, int idRol) throws SQLException {
        String sql = "INSERT IGNORE INTO usuario_rol (id_usuario, id_rol) VALUES (?, ?)";
        try (Connection cn = ConexionDB.getConnection();
             PreparedStatement ps = cn.prepareStatement(sql)) {
            ps.setInt(1, idUsuario);
            ps.setInt(2, idRol);
            return ps.executeUpdate() > 0;
        }
    }

    /* ============================================================
       6) REVOCAR ROL
       ============================================================ */
    public boolean revocarRol(int idUsuario, int idRol) throws SQLException {
        String sql = "DELETE FROM usuario_rol WHERE id_usuario = ? AND id_rol = ?";
        try (Connection cn = ConexionDB.getConnection();
             PreparedStatement ps = cn.prepareStatement(sql)) {
            ps.setInt(1, idUsuario);
            ps.setInt(2, idRol);
            return ps.executeUpdate() > 0;
        }
    }

    /* ============================================================
       7) ACTUALIZAR PERFIL
       ============================================================ */
    public void actualizarPerfil(Usuario u) throws SQLException {
        String sql =
            "UPDATE perfil SET nombres=?, apellidos=?, documento=?, " +
            "telefono=?, direccion=?, foto=? WHERE id_usuario=?";
        try (Connection cn = ConexionDB.getConnection();
             PreparedStatement ps = cn.prepareStatement(sql)) {
            ps.setString(1, u.getNombres());
            ps.setString(2, u.getApellidos());
            ps.setString(3, u.getDocumento());
            ps.setString(4, u.getTelefono());
            ps.setString(5, u.getDireccion());
            ps.setString(6, u.getFoto());
            ps.setInt(7, u.getIdUsuario());
            ps.executeUpdate();
        }
    }

    /* ============================================================
       8) CAMBIAR ESTADO (ACTIVO / INACTIVO / BLOQUEADO)
       ============================================================ */
    public void cambiarEstado(int idUsuario, String nuevoEstado) throws SQLException {
        String sql = "UPDATE usuario SET estado = ? WHERE id_usuario = ?";
        try (Connection cn = ConexionDB.getConnection();
             PreparedStatement ps = cn.prepareStatement(sql)) {
            ps.setString(1, nuevoEstado);
            ps.setInt(2, idUsuario);
            ps.executeUpdate();
        }
    }

    /* ============================================================
       9) INTENTOS FALLIDOS (bloqueo tras 5)
       ============================================================ */
    public void incrementarIntentos(int idUsuario) throws SQLException {
        Connection cn = null;
        try {
            cn = ConexionDB.getConnection();
            cn.setAutoCommit(false);

            String sqlUpd =
                "UPDATE usuario SET intentos_fallidos = intentos_fallidos + 1 " +
                "WHERE id_usuario = ?";
            try (PreparedStatement ps = cn.prepareStatement(sqlUpd)) {
                ps.setInt(1, idUsuario);
                ps.executeUpdate();
            }

            // Si llegó a 5, se bloquea
            String sqlCheck = "SELECT intentos_fallidos FROM usuario WHERE id_usuario = ?";
            int intentos = 0;
            try (PreparedStatement ps = cn.prepareStatement(sqlCheck)) {
                ps.setInt(1, idUsuario);
                try (ResultSet rs = ps.executeQuery()) {
                    if (rs.next()) intentos = rs.getInt(1);
                }
            }

            if (intentos >= 5) {
                try (PreparedStatement ps = cn.prepareStatement(
                        "UPDATE usuario SET estado='BLOQUEADO' WHERE id_usuario = ?")) {
                    ps.setInt(1, idUsuario);
                    ps.executeUpdate();
                }
                registrarAuditoriaInterno(cn, idUsuario, "BLOQUEO",
                        "Cuenta bloqueada por 5 intentos fallidos", null);
            }

            cn.commit();
        } catch (SQLException e) {
            if (cn != null) cn.rollback();
            throw e;
        } finally {
            if (cn != null) { cn.setAutoCommit(true); cn.close(); }
        }
    }

    /* ============================================================
       10) RESET DE INTENTOS (tras login exitoso)
       ============================================================ */
    public void resetearIntentos(int idUsuario) throws SQLException {
        String sql = "UPDATE usuario SET intentos_fallidos = 0 WHERE id_usuario = ?";
        try (Connection cn = ConexionDB.getConnection();
             PreparedStatement ps = cn.prepareStatement(sql)) {
            ps.setInt(1, idUsuario);
            ps.executeUpdate();
        }
    }

    /* ============================================================
       11) CAMBIAR CONTRASEÑA (recibe nuevo hash ya listo)
       ============================================================ */
    public void cambiarPassword(int idUsuario, String nuevoHash) throws SQLException {
        String sql = "UPDATE usuario SET password_hash = ? WHERE id_usuario = ?";
        try (Connection cn = ConexionDB.getConnection();
             PreparedStatement ps = cn.prepareStatement(sql)) {
            ps.setString(1, nuevoHash);
            ps.setInt(2, idUsuario);
            ps.executeUpdate();
        }
    }

    /* ============================================================
       12) LISTAR USUARIOS (para panel admin)
       ============================================================ */
    public List<Usuario> listarTodos() throws SQLException {
        List<Usuario> lista = new ArrayList<>();
        String sql =
            "SELECT u.id_usuario, u.correo, u.password_hash, u.estado, " +
            "       u.intentos_fallidos, u.fecha_registro, " +
            "       p.nombres, p.apellidos, p.documento, p.telefono, p.direccion, p.foto " +
            "FROM usuario u " +
            "LEFT JOIN perfil p ON u.id_usuario = p.id_usuario " +
            "ORDER BY u.fecha_registro DESC";

        try (Connection cn = ConexionDB.getConnection();
             PreparedStatement ps = cn.prepareStatement(sql);
             ResultSet rs = ps.executeQuery()) {
            while (rs.next()) lista.add(mapear(rs));
        }
        return lista;
    }

    /* ============================================================
       13) AUDITORÍA (versión pública, abre su propia conexión)
       ============================================================ */
    public void registrarAuditoria(Integer idUsuario, String accion,
                                   String detalle, String ip) throws SQLException {
        try (Connection cn = ConexionDB.getConnection()) {
            registrarAuditoriaInterno(cn, idUsuario, accion, detalle, ip);
        }
    }

    /* ============================================================
       14) AUDITORÍA INTERNA (usa conexión existente para no romper transacciones)
       ============================================================ */
    private void registrarAuditoriaInterno(Connection cn, Integer idUsuario,
                                           String accion, String detalle, String ip)
            throws SQLException {
        String sql = "INSERT INTO auditoria (id_usuario, accion, detalle, ip) VALUES (?,?,?,?)";
        try (PreparedStatement ps = cn.prepareStatement(sql)) {
            if (idUsuario == null) ps.setNull(1, Types.INTEGER);
            else                    ps.setInt(1, idUsuario);
            ps.setString(2, accion);
            ps.setString(3, detalle);
            ps.setString(4, ip);
            ps.executeUpdate();
        }
    }

    /* ============================================================
       15) LISTAR AUDITORÍA (para admin)
       ============================================================ */
    public List<String[]> listarAuditoria(int limite) throws SQLException {
        List<String[]> lista = new ArrayList<>();
        String sql =
            "SELECT a.fecha, a.accion, a.detalle, a.ip, u.correo " +
            "FROM auditoria a " +
            "LEFT JOIN usuario u ON a.id_usuario = u.id_usuario " +
            "ORDER BY a.fecha DESC LIMIT ?";
        try (Connection cn = ConexionDB.getConnection();
             PreparedStatement ps = cn.prepareStatement(sql)) {
            ps.setInt(1, limite);
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    lista.add(new String[]{
                        rs.getString("fecha"),
                        rs.getString("accion"),
                        rs.getString("detalle"),
                        rs.getString("ip"),
                        rs.getString("correo")
                    });
                }
            }
        }
        return lista;
    }

    /* ============================================================
       MAPEO ResultSet → Usuario
       ============================================================ */
    private Usuario mapear(ResultSet rs) throws SQLException {
        Usuario u = new Usuario();
        u.setIdUsuario(rs.getInt("id_usuario"));
        u.setCorreo(rs.getString("correo"));
        u.setPasswordHash(rs.getString("password_hash"));
        u.setEstado(rs.getString("estado"));
        u.setIntentosFallidos(rs.getInt("intentos_fallidos"));

        Timestamp ts = rs.getTimestamp("fecha_registro");
        if (ts != null) u.setFechaRegistro(ts.toLocalDateTime());

        // Campos del perfil (pueden venir null por LEFT JOIN)
        u.setNombres(rs.getString("nombres"));
        u.setApellidos(rs.getString("apellidos"));
        u.setDocumento(rs.getString("documento"));
        u.setTelefono(rs.getString("telefono"));
        u.setDireccion(rs.getString("direccion"));
        u.setFoto(rs.getString("foto"));
        return u;
    }
}
