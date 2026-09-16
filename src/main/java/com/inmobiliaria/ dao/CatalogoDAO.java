package com.inmobiliaria.dao;

import com.inmobiliaria.config.ConexionDB;
import java.sql.*;
import java.util.ArrayList;
import java.util.List;

public class CatalogoDAO {

    public List<String[]> listarCiudades() throws SQLException {
        List<String[]> lista = new ArrayList<>();
        String sql = "SELECT id_ciudad, nombre FROM ciudad ORDER BY nombre";
        try (Connection cn = ConexionDB.getConnection();
             PreparedStatement ps = cn.prepareStatement(sql);
             ResultSet rs = ps.executeQuery()) {
            while (rs.next()) {
                lista.add(new String[]{ rs.getString("id_ciudad"), rs.getString("nombre") });
            }
        }
        return lista;
    }

    public List<String[]> listarTipos() throws SQLException {
        List<String[]> lista = new ArrayList<>();
        String sql = "SELECT id_tipo, nombre FROM tipo_propiedad ORDER BY nombre";
        try (Connection cn = ConexionDB.getConnection();
             PreparedStatement ps = cn.prepareStatement(sql);
             ResultSet rs = ps.executeQuery()) {
            while (rs.next()) {
                lista.add(new String[]{ rs.getString("id_tipo"), rs.getString("nombre") });
            }
        }
        return lista;
    }

    public List<String[]> listarCaracteristicas() throws SQLException {
        List<String[]> lista = new ArrayList<>();
        String sql = "SELECT id_caracteristica, nombre FROM caracteristica ORDER BY nombre";
        try (Connection cn = ConexionDB.getConnection();
             PreparedStatement ps = cn.prepareStatement(sql);
             ResultSet rs = ps.executeQuery()) {
            while (rs.next()) {
                lista.add(new String[]{ rs.getString("id_caracteristica"), rs.getString("nombre") });
            }
        }
        return lista;
    }

    /** Devuelve los IDs de características marcadas de una propiedad (para el formulario editar). */
    public List<Integer> caracteristicasDePropiedad(int idPropiedad) throws SQLException {
        List<Integer> ids = new ArrayList<>();
        String sql = "SELECT id_caracteristica FROM propiedad_caracteristica WHERE id_propiedad = ?";
        try (Connection cn = ConexionDB.getConnection();
             PreparedStatement ps = cn.prepareStatement(sql)) {
            ps.setInt(1, idPropiedad);
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) ids.add(rs.getInt(1));
            }
        }
        return ids;
    }
}
