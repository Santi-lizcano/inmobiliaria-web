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

    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse res)
            throws ServletException, IOException {

        req.setCharacterEncoding("UTF-8");

        String correo    = req.getParameter("correo");
        String password  = req.getParameter("password");
        String confirmar = req.getParameter("confirmar");
        String nombres   = req.getParameter("nombres");
        String apellidos = req.getParameter("apellidos");
        String documento = req.getParameter("documento");
        String telefono  = req.getParameter("telefono");
        String direccion = req.getParameter("direccion");

        // ---- Validaciones básicas ----
        if (correo == null || !correo.matches("^[\\w.-]+@[\\w.-]+\\.[a-zA-Z]{2,}$")) {
            req.setAttribute("error", "Correo inválido.");
            req.getRequestDispatcher("/registro.jsp").forward(req, res);
            return;
        }
        if (password == null || password.length() < 8) {
            req.setAttribute("error", "La contraseña debe tener al menos 8 caracteres.");
            req.getRequestDispatcher("/registro.jsp").forward(req, res);
            return;
        }
        if (!password.equals(confirmar)) {
            req.setAttribute("error", "Las contraseñas no coinciden.");
            req.getRequestDispatcher("/registro.jsp").forward(req, res);
            return;
        }

        // ---- Construir el modelo ----
        Usuario u = new Usuario();
        u.setCorreo(correo);
        u.setPasswordHash(PasswordUtil.hash(password)); // BCrypt
        u.setNombres(nombres);
        u.setApellidos(apellidos);
        u.setDocumento(documento);
        u.setTelefono(telefono);
        u.setDireccion(direccion);

        try {
            usuarioDAO.insertarConPerfil(u);   // inserta usuario + perfil + rol CLIENTE

            // Redirige al login con aviso de éxito
            res.sendRedirect(req.getContextPath() + "/login.jsp?ok=registrado");

        } catch (SQLIntegrityConstraintViolationException e) {

            String msg = e.getMessage() == null ? "" : e.getMessage().toLowerCase();
            if (msg.contains("correo")) {
                req.setAttribute("error", "El correo ya se encuentra registrado.");
            } else if (msg.contains("documento")) {
                req.setAttribute("error", "El documento ya se encuentra registrado.");
            } else {
                req.setAttribute("error", "Ya existe un registro con esos datos.");
            }
            req.getRequestDispatcher("/registro.jsp").forward(req, res);

        } catch (Exception e) {
            e.printStackTrace();
            req.setAttribute("error", "Ocurrió un error inesperado, intente más tarde.");
            req.getRequestDispatcher("/registro.jsp").forward(req, res);
        }
    }
}
