package com.inmobiliaria.dao;

import com.inmobiliaria.config.ConexionDB;
import com.inmobiliaria.modelo.Solicitud;

import java.sql.*;
import java.util.ArrayList;
import java.util.List;

public class SolicitudDAO {

    /* ============================================================
       1) INSERTAR solicitud + documentos en una sola transacción
       ============================================================ */
    public int insertar(Solicitud s) throws SQLException {
        Connection cn = null;
        try {
            cn = ConexionDB.getConnection();
            cn.setAutoCommit(false);

            String sql = "INSERT INTO solicitud " +
                "(id_cita, id_usuario, id_propiedad, tipo, estado, observaciones) " +
                "VALUES (?, ?, ?, ?, 'RADICADA', ?)";

            int idSolicitud;
            try (PreparedStatement ps = cn.prepareStatement(sql,
                    Statement.RETURN_GENERATED_KEYS)) {
                if (s.getIdCita() == null) ps.setNull(1, Types.INTEGER);
                else                        ps.setInt(1, s.getIdCita());
                ps.setInt(2, s.getIdUsuario());
                ps.setInt(3, s.getIdPropiedad());
                ps.setString(4, s.getTipo());
                ps.setString(5, s.getObservaciones());
                ps.executeUpdate();

                try (ResultSet rs = ps.getGeneratedKeys()) {
                    if (!rs.next()) throw new SQLException("No se generó ID de solicitud.");
                    idSolicitud = rs.getInt(1);
                }
            }

            // Documentos adjuntos
            if (s.getDocumentos() != null && !s.getDocumentos().isEmpty()) {
                String sqlDoc = "INSERT INTO documento_solicitud " +
                                "(id_solicitud, nombre, url) VALUES (?, ?, ?)";
                try (PreparedStatement ps = cn.prepareStatement(sqlDoc)) {
                    for (Solicitud.Documento d : s.getDocumentos()) {
                        ps.setInt(1, idSolicitud);
                        ps.setString(2, d.getNombre());
                        ps.setString(3, d.getUrl());
                        ps.addBatch();
                    }
                    ps.executeBatch();
                }
            }

            cn.commit();
            return idSolicitud;

        } catch (SQLException e) {
            if (cn != null) cn.rollback();
            throw e;
        } finally {
            if (cn != null) { cn.setAutoCommit(true); cn.close(); }
        }
    }

    /* ============================================================
       2) LISTAR por usuario (cliente)
       ============================================================ */
    public List<Solicitud> listarPorUsuario(int idUsuario) throws SQLException {
        String sql =
            "SELECT s.*, p.titulo AS titulo_propiedad " +
            "FROM solicitud s " +
            "INNER JOIN propiedad p ON s.id_propiedad = p.id_propiedad " +
            "WHERE s.id_usuario = ? " +
            "ORDER BY s.fecha_radicacion DESC";
        return ejecutarListado(sql, idUsuario);
    }

    /* ============================================================
       3) LISTAR por inmobiliaria
       ============================================================ */
    public List<Solicitud> listarPorInmobiliaria(int idInmobiliaria) throws SQLException {
        String sql =
            "SELECT s.*, p.titulo AS titulo_propiedad, " +
            "       CONCAT(pe.nombres,' ',pe.apellidos) AS nombre_cliente, " +
            "       u.correo AS correo_cliente " +
            "FROM solicitud s " +
            "INNER JOIN propiedad p ON s.id_propiedad = p.id_propiedad " +
            "INNER JOIN usuario u ON s.id_usuario = u.id_usuario " +
            "LEFT JOIN perfil pe ON pe.id_usuario = u.id_usuario " +
            "WHERE p.id_inmobiliaria = ? " +
            "ORDER BY s.fecha_radicacion DESC";
        return ejecutarListado(sql, idInmobiliaria);
    }

    /* ============================================================
       4) LISTAR TODAS (admin)
       ============================================================ */
    public List<Solicitud> listarTodas() throws SQLException {
        String sql =
            "SELECT s.*, p.titulo AS titulo_propiedad, " +
            "       CONCAT(pe.nombres,' ',pe.apellidos) AS nombre_cliente, " +
            "       u.correo AS correo_cliente " +
            "FROM solicitud s " +
            "INNER JOIN propiedad p ON s.id_propiedad = p.id_propiedad " +
            "INNER JOIN usuario u ON s.id_usuario = u.id_usuario " +
            "LEFT JOIN perfil pe ON pe.id_usuario = u.id_usuario " +
            "ORDER BY s.fecha_radicacion DESC";
        return ejecutarListado(sql, null);
    }

    /* ============================================================
       5) BUSCAR por ID (con documentos)
       ============================================================ */
    public Solicitud buscarPorId(int idSolicitud) throws SQLException {
        String sql =
            "SELECT s.*, p.titulo AS titulo_propiedad, " +
            "       CONCAT(pe.nombres,' ',pe.apellidos) AS nombre_cliente, " +
            "       u.correo AS correo_cliente " +
            "FROM solicitud s " +
            "INNER JOIN propiedad p ON s.id_propiedad = p.id_propiedad " +
            "INNER JOIN usuario u ON s.id_usuario = u.id_usuario " +
            "LEFT JOIN perfil pe ON pe.id_usuario = u.id_usuario " +
            "WHERE s.id_solicitud = ?";

        try (Connection cn = ConexionDB.getConnection();
             PreparedStatement ps = cn.prepareStatement(sql)) {
            ps.setInt(1, idSolicitud);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    Solicitud s = mapear(rs);
                    s.setDocumentos(listarDocumentos(idSolicitud));
                    return s;
                }
            }
        }
        return null;
    }

    /* ============================================================
       6) CAMBIAR ESTADO
       ============================================================ */
    public void cambiarEstado(int idSolicitud, String nuevoEstado) throws SQLException {
        String sql = "UPDATE solicitud SET estado = ? WHERE id_solicitud = ?";
        try (Connection cn = ConexionDB.getConnection();
             PreparedStatement ps = cn.prepareStatement(sql)) {
            ps.setString(1, nuevoEstado);
            ps.setInt(2, idSolicitud);
            ps.executeUpdate();
        }
    }

    /* ============================================================
       7) AGREGAR documento a solicitud existente
       ============================================================ */
    public void agregarDocumento(int idSolicitud, String nombre, String url)
            throws SQLException {
        String sql = "INSERT INTO documento_solicitud (id_solicitud, nombre, url) " +
                     "VALUES (?, ?, ?)";
        try (Connection cn = ConexionDB.getConnection();
             PreparedStatement ps = cn.prepareStatement(sql)) {
            ps.setInt(1, idSolicitud);
            ps.setString(2, nombre);
            ps.setString(3, url);
            ps.executeUpdate();
        }
    }

    /* ============================================================
       8) ELIMINAR documento
       ============================================================ */
    public void eliminarDocumento(int idDocumento) throws SQLException {
        String sql = "DELETE FROM documento_solicitud WHERE id_documento = ?";
        try (Connection cn = Conexion
