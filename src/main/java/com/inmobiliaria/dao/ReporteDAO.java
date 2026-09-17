package com.inmobiliaria.dao;

import com.inmobiliaria.config.ConexionDB;

import java.sql.*;
import java.util.ArrayList;
import java.util.LinkedHashMap;
import java.util.List;
import java.util.Map;

public class ReporteDAO {

    /* ============================================================
       CONSULTA 1 (INNER JOIN con 3 tablas)
       Propiedades con su ciudad, tipo e inmobiliaria.
       ============================================================ */
    public List<Map<String, Object>> propiedadesConDetalle() throws SQLException {
        String sql =
            "SELECT p.id_propiedad, p.titulo, p.precio, p.estado, " +
            "       c.nombre AS ciudad, t.nombre AS tipo, i.razon_social " +
            "FROM propiedad p " +
            "INNER JOIN ciudad c ON p.id_ciudad = c.id_ciudad " +
            "INNER JOIN tipo_propiedad t ON p.id_tipo = t.id_tipo " +
            "INNER JOIN inmobiliaria i ON p.id_inmobiliaria = i.id_inmobiliaria " +
            "ORDER BY p.fecha_publicacion DESC";
        return ejecutar(sql);
    }

    /* ============================================================
       CONSULTA 2 (INNER JOIN con 5 tablas)
       Citas con cliente, propiedad e inmobiliaria.
       ============================================================ */
    public List<Map<String, Object>> citasConDetalle() throws SQLException {
        String sql =
            "SELECT c.id_cita, c.fecha_hora, c.estado, " +
            "       CONCAT(pe.nombres,' ',pe.apellidos) AS cliente, " +
            "       u.correo AS correo_cliente, " +
            "       p.titulo AS propiedad, " +
            "       i.razon_social AS inmobiliaria " +
            "FROM cita c " +
            "INNER JOIN usuario u   ON c.id_usuario = u.id_usuario " +
            "INNER JOIN perfil pe   ON pe.id_usuario = u.id_usuario " +
            "INNER JOIN propiedad p ON c.id_propiedad = p.id_propiedad " +
            "INNER JOIN inmobiliaria i ON p.id_inmobiliaria = i.id_inmobiliaria " +
            "ORDER BY c.fecha_hora DESC";
        return ejecutar(sql);
    }

    /* ============================================================
       CONSULTA 3 (N:M)
       Propiedades con sus características agrupadas.
       ============================================================ */
    public List<Map<String, Object>> propiedadesConCaracteristicas() throws SQLException {
        String sql =
            "SELECT p.id_propiedad, p.titulo, " +
            "       GROUP_CONCAT(ca.nombre SEPARATOR ', ') AS caracteristicas " +
            "FROM propiedad p " +
            "INNER JOIN propiedad_caracteristica pc ON p.id_propiedad = pc.id_propiedad " +
            "INNER JOIN caracteristica ca ON pc.id_caracteristica = ca.id_caracteristica " +
            "GROUP BY p.id_propiedad, p.titulo " +
            "ORDER BY p.titulo";
        return ejecutar(sql);
    }

    /* ============================================================
       CONSULTA 4 (LEFT JOIN)
       Propiedades que aún NO tienen citas agendadas.
       ============================================================ */
    public List<Map<String, Object>> propiedadesSinCitas() throws SQLException {
        String sql =
            "SELECT p.id_propiedad, p.titulo, p.estado, " +
            "       c.nombre AS ciudad, " +
            "       ci.id_cita, ci.fecha_hora " +
            "FROM propiedad p " +
            "INNER JOIN ciudad c ON p.id_ciudad = c.id_ciudad " +
            "LEFT JOIN cita ci ON p.id_propiedad = ci.id_propiedad " +
            "WHERE ci.id_cita IS NULL " +
            "ORDER BY p.titulo";
        return ejecutar(sql);
    }

    /* ============================================================
       CONSULTA 5 (GROUP BY + HAVING)
       Propiedades disponibles por ciudad (con al menos 1 disponible).
       ============================================================ */
    public List<Map<String, Object>> propiedadesDisponiblesPorCiudad() throws SQLException {
        String sql =
            "SELECT c.nombre AS ciudad, COUNT(p.id_propiedad) AS total " +
            "FROM ciudad c " +
            "LEFT JOIN propiedad p ON c.id_ciudad = p.id_ciudad " +
            "     AND p.estado = 'DISPONIBLE' " +
            "GROUP BY c.id_ciudad, c.nombre " +
            "HAVING COUNT(p.id_propiedad) >= 1 " +
            "ORDER BY total DESC, c.nombre";
        return ejecutar(sql);
    }

    /* ============================================================
       REPORTE EXTRA (agregación por inmobiliaria — para admin)
       ============================================================ */
    public List<Map<String, Object>> resumenPorInmobiliaria() throws SQLException {
        String sql =
            "SELECT i.razon_social, " +
            "       COUNT(DISTINCT p.id_propiedad) AS propiedades, " +
            "       COUNT(DISTINCT c.id_cita)      AS citas, " +
            "       COUNT(DISTINCT s.id_solicitud) AS solicitudes " +
            "FROM inmobiliaria i " +
            "LEFT JOIN propiedad p ON p.id_inmobiliaria = i.id_inmobiliaria " +
            "LEFT JOIN cita c      ON c.id_propiedad = p.id_propiedad " +
            "LEFT JOIN solicitud s ON s.id_propiedad = p.id_propiedad " +
            "GROUP BY i.id_inmobiliaria, i.razon_social " +
            "ORDER BY propiedades DESC";
        return ejecutar(sql);
    }

    /* ============================================================
       REPORTE EXTRA (solicitudes por estado — para admin)
       ============================================================ */
    public List<Map<String, Object>> solicitudesPorEstado() throws SQLException {
        String sql =
            "SELECT s.estado, COUNT(*) AS total " +
            "FROM solicitud s " +
            "GROUP BY s.estado " +
            "ORDER BY total DESC";
        return ejecutar(sql);
    }

    /* ============================================================
       HELPER: ejecuta un SELECT y devuelve filas como List<Map>
       (Usa ResultSetMetaData para no escribir un mapeo por consulta)
       ============================================================ */
    private List<Map<String, Object>> ejecutar(String sql) throws SQLException {
        List<Map<String, Object>> filas = new ArrayList<>();
        try (Connection cn = ConexionDB.getConnection();
             PreparedStatement ps = cn.prepareStatement(sql);
             ResultSet rs = ps.executeQuery()) {

            ResultSetMetaData meta = rs.getMetaData();
            int cols = meta.getColumnCount();

            while (rs.next()) {
                Map<String, Object> fila = new LinkedHashMap<>();
                for (int i = 1; i <= cols; i++) {
                    String etiqueta = meta.getColumnLabel(i);
                    Object valor    = rs.getObject(i);
                    fila.put(etiqueta, valor);
                }
                filas.add(fila);
            }
        }
        return filas;
    }
}
