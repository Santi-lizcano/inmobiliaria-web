package com.inmobiliaria.controlador;

import com.inmobiliaria.dao.UsuarioDAO;
import com.inmobiliaria.modelo.Usuario;
import com.inmobiliaria.util.PasswordUtil;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.*;

import java.io.IOException;
import java.sql.SQLIntegrityConstraintViolationException;

@WebServlet("/RegistroServlet")
public class RegistroServlet extends HttpServlet {

    private final UsuarioDAO usuarioDAO = new UsuarioDAO();

    /* =========================================================
       GET: redirige al formulario (evita 405 si entran por URL)
       ========================================================= */
    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse res)
            throws ServletException, IOException {
        res.sendRedirect(req.getContextPath() + "/registro.jsp");
    }

    /* =========================================================
       POST: procesa el registro
       ========================================================= */
    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse res)
            throws ServletException, IOException {

        req.setCharacterEncoding("UTF-8");

        // ---- 1. Normalizar entradas (trim) ----
        String correo    = trim(req.getParameter("correo"));
        String password  = req.getParameter("password");        // no trim: espacios son válidos
        String confirmar = req.getParameter("confirmar");
        String nombres   = trim(req.getParameter("nombres"));
        String apellidos = trim(req.getParameter("apellidos"));
        String documento = trim(req.getParameter("documento"));
        String telefono  = trim(req.getParameter("telefono"));
        String direccion = trim(req.getParameter("direccion"));

        // ---- 2. Validaciones ----
        if (esVacio(correo) || !correo.matches("^[\\w.-]+@[\\w.-]+\\.[a-zA-Z]{2,}$")) {
            devolverConError(req, res, "El correo no tiene un formato válido.", correo, nombres, apellidos, documento, telefono, direccion);
            return;
        }
        if (esVacio(password) || password.length() < 8) {
            devolverConError(req, res, "La contraseña debe tener al menos 8 caracteres.", correo, nombres, apellidos, documento, telefono, direccion);
            return;
        }
        if (!password.equals(confirmar)) {
            devolverConError(req, res, "Las contraseñas no coinciden.", correo, nombres, apellidos, documento, telefono, direccion);
            return;
        }
        if (esVacio(nombres) || esVacio(apellidos)) {
            devolverConError(req, res, "Nombres y apellidos son obligatorios.", correo, nombres, apellidos, documento, telefono, direccion);
            return;
        }
        if (esVacio(documento) || !documento.matches("^[0-9]{6,20}$")) {
            devolverConError(req, res, "El documento debe contener solo números (6 a 20 dígitos).", correo, nombres, apellidos, documento, telefono, direccion);
            return;
        }
        if (!esVacio(telefono) && !telefono.matches("^[0-9+\\-\\s()]{7,20}$")) {
            devolverConError(req, res, "El teléfono no tiene un formato válido.", correo, nombres, apellidos, documento, telefono, direccion);
            return;
        }

        // ---- 3. Construir modelo ----
        Usuario u = new Usuario();
        u.setCorreo(correo);
        u.setPasswordHash(PasswordUtil.hash(password));   // BCrypt
        u.setNombres(nombres);
        u.setApellidos(apellidos);
        u.setDocumento(documento);
        u.setTelefono(telefono);
        u.setDireccion(direccion);

        // ---- 4. Insertar con manejo de errores ----
        try {
            int idUsuario = usuarioDAO.insertarConPerfil(u);   // usuario + perfil + rol CLIENTE

            // Auditoría del registro (usuario recién creado, sin IP aún conocida del usuario)
            usuarioDAO.registrarAuditoria(idUsuario, "REGISTRO",
                    "Nuevo usuario registrado: " + correo, req.getRemoteAddr());

            res.sendRedirect(req.getContextPath() + "/login.jsp?ok=registrado");

        } catch (SQLIntegrityConstraintViolationException e) {
            String msg = (e.getMessage() == null ? "" : e.getMessage().toLowerCase());
            String error;
            if (msg.contains("correo"))          error = "El correo ya se encuentra registrado.";
            else if (msg.contains("documento"))  error = "El documento ya se encuentra registrado.";
            else if (msg.contains("perfil.id_usuario")) error = "Ya existe un perfil para este usuario.";
            else                                 error = "Ya existe un registro con esos datos.";

            devolverConError(req, res, error, correo, nombres, apellidos, documento, telefono, direccion);

        } catch (Exception e) {
            e.printStackTrace();
            devolverConError(req, res,
                    "Ocurrió un error inesperado, intente más tarde.",
                    correo, nombres, apellidos, documento, telefono, direccion);
        }
    }

    /* =========================================================
       Helpers
       ========================================================= */

    /** Devuelve al formulario con error, conservando lo que el usuario ya escribió. */
    private void devolverConError(HttpServletRequest req, HttpServletResponse res,
                                  String error, String correo, String nombres,
                                  String apellidos, String documento,
                                  String telefono, String direccion)
            throws ServletException, IOException {

        req.setAttribute("error", error);
        // Conservar valores ya ingresados (excepto password por seguridad)
        req.setAttribute("correo", correo);
        req.setAttribute("nombres", nombres);
        req.setAttribute("apellidos", apellidos);
        req.setAttribute("documento", documento);
        req.setAttribute("telefono", telefono);
        req.setAttribute("direccion", direccion);

        req.getRequestDispatcher("/registro.jsp").forward(req, res);
    }

    private String trim(String s) { return s == null ? null : s.trim(); }

    private boolean esVacio(String s) { return s == null || s.isEmpty(); }
}
