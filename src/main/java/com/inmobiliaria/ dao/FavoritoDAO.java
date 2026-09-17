package com.inmobiliaria.dao;

import com.inmobiliaria.config.ConexionDB;
import com.inmobiliaria.modelo.Propiedad;

import java.sql.*;
import java.util.ArrayList;
import java.util.List;

public class FavoritoDAO {

    /* Agregar a favoritos (idempotente: no falla si ya existe) */
    public void agregar(int idUsuario, int idPropiedad) throws SQLException {
        String sql = "INSERT IGNORE INTO favorito (id_usuario, id_propiedad) VALUES (?, ?)";
        try (Connection cn = ConexionDB.getConnection();
             PreparedStatement ps = cn.prepareStatement(sql)) {
            ps.setInt(1, idUsuario);
            ps.setInt(2, idPropiedad);
            ps.executeUpdate();
        }
    }

    /* Quitar de favoritos */
    public void quitar(int idUsuario, int idPropiedad) throws SQLException {
        String sql = "DELETE FROM favorito WHERE id_usuario = ? AND id_propiedad = ?";
        try (Connection cn = ConexionDB.getConnection();
             PreparedStatement ps = cn.prepareStatement(sql)) {
            ps.setInt(1, idUsuario);
            ps.setInt(2, idPropiedad);
            ps.executeUpdate();
        }
    }

    /* ¿Ya es favorito? */
    public boolean esFavorito(int idUsuario, int idPropiedad) throws SQLException {
        String sql = "SELECT 1 FROM favorito WHERE id_usuario = ? AND id_propiedad = ?";
        try (Connection cn = ConexionDB.getConnection();
             PreparedStatement ps = cn.prepareStatement(sql)) {
            ps.setInt(1, idUsuario);
            ps.setInt(2, idPropiedad);
            try (ResultSet rs = ps.executeQuery()) {
                return rs.next();
            }
        }
    }

    /* Listar propiedades favoritas de un usuario */
    public List<Propiedad> listarPorUsuario(int idUsuario) throws SQLException {
        List<Propiedad> lista = new ArrayList<>();
        String sql =
            "SELECT p.*, c.nombre AS ciudad, t.nombre AS tipo, i.razon_social " +
            "FROM favorito f " +
            "INNER JOIN propiedad p ON f.id_propiedad = p.id_propiedad " +
            "INNER JOIN ciudad c ON p.id_ciudad = c.id_ciudad " +
            "INNER JOIN tipo_propiedad t ON p.id_tipo = t.id_tipo " +
            "INNER JOIN inmobiliaria i ON p.id_inmobiliaria = i.id_inmobiliaria " +
            "WHERE f.id_usuario = ? " +
            "ORDER BY f.fecha DESC";

        try (Connection cn = ConexionDB.getConnection();
             PreparedStatement ps = cn.prepareStatement(sql)) {
            ps.setInt(1, idUsuario);
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
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
                    p.setNombreCiudad(rs.getString("ciudad"));
                    p.setNombreTipo(rs.getString("tipo"));
                    p.setRazonSocialInmobiliaria(rs.getString("razon_social"));
                    lista.add(p);
                }
            }
        }
        return lista;
    }
}
