package com.inmobiliaria.config;

import java.io.InputStream;
import java.sql.*;
import java.util.Properties;

public class ConexionDB {
    private static Connection con;

    public static Connection getConnection() throws SQLException {
        try {
            if (con == null || con.isClosed()) {
                Properties p = new Properties();
                InputStream in = ConexionDB.class.getClassLoader()
                                                 .getResourceAsStream("db.properties");
                if (in == null) throw new RuntimeException("No se encontró db.properties");
                p.load(in);
                Class.forName(p.getProperty("db.driver"));
                con = DriverManager.getConnection(
                        p.getProperty("db.url"),
                        p.getProperty("db.user"),
                        p.getProperty("db.password"));
            }
        } catch (Exception e) {
            throw new SQLException("Error al conectar a la BD", e);
        }
        return con;
    }

    public static void cerrar() {
        try { if (con != null && !con.isClosed()) con.close(); }
        catch (SQLException ignored) {}
    }
}
