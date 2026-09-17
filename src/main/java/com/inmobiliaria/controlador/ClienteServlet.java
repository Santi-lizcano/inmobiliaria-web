package com.inmobiliaria.controlador;

import com.inmobiliaria.dao.UsuarioDAO;
import com.inmobiliaria.modelo.Usuario;
import com.inmobiliaria.util.PasswordUtil;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.*;

import java.io.IOException;
import java.sql.SQLIntegrityConstraintViolationException;
import java.util.List;

@WebServlet("/ClienteServlet")
public class ClienteServlet extends HttpServlet {

    private final UsuarioDAO usuarioDAO = new UsuarioDAO();

    /* =========================================================
       GET: ver | editarPerfil | cambiarPassword
       ========================================================= */
    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse res)
            throws ServletException, IOException {

        if (!esCliente(req)) {
            res.sendRedirect(req.getContextPath() + "/acceso-denegado.jsp");
            return;
        }

        String accion = req.getParameter("accion");
        if (accion == null) accion = "ver";

        try {
            switch (accion) {
                case "editarPerfil"     -> verFormularioPerfil(req, res);
                case "cambiarPassword"  -> verFormularioPassword(req, res);
                default                 -> ver(req, res);
            }
        } catch (Exception e) {
            e.printStackTrace();
            req.setAttribute("error", "Error: " + e.getMessage());
            req.getRequestDispatcher("/error.jsp").forward(req, res);
        }
    }

    /* =========================================================
       POST: guardarPerfil | guardarPassword
       ========================================================= */
    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse res)
            throws ServletException, IOException {

        if (!esCliente(req)) {
            res.sendRedirect(req.getContextPath() + "/acceso-denegado.jsp");
            return;
        }

        req.setCharacterEncoding("UTF-8");
        String accion = req.getParameter("accion");

        try {
            if ("guardarPerfil".equals(accion))          guardarPerfil(req, res);
            else if ("guardarPassword".equals(accion))   guardarPassword(req, res);
            else res.sendRedirect(req.getContextPath() + "/ClienteServlet?accion=ver");

        } catch (SQLIntegrityConstraintViolationException e) {
            String msg = e.getMessage() == null ? "" : e.getMessage().toLowerCase();
            if (msg.contains("documento")) {
                req.setAttribute("error", "Ese documento ya está registrado en otra cuenta.");
            } else {
                req.setAttribute("error", "Datos duplicados en el sistema.");
            }
            try {
                verFormularioPerfil(req, res);
            } catch (Exception ex) {
                throw new ServletException("No se pudo recargar el perfil", ex);
            }

        } catch (Exception e) {
            e.printStackTrace();
            req.setAttribute("error", "Error inesperado: " + e.getMessage());
            req.getRequestDispatcher("/error.jsp").forward(req, res);
        }
    }

    /* =========================================================
       VISTAS
       ========================================================= */

    private void ver(HttpServletRequest req, HttpServletResponse res) throws Exception {
        Usuario u = cargarUsuarioDeSesion(req);
        req.setAttribute("usuario", u);
        req.getRequestDispatcher("/cliente/perfil.jsp").forward(req, res);
    }

    private void verFormularioPerfil(HttpServletRequest req, HttpServletResponse res) throws Exception {
        Usuario u = cargarUsuarioDeSesion(req);
        req.setAttribute("usuario", u);
        req.setAttribute("modo", "editar");
        req.getRequestDispatcher("/cliente/perfil.jsp").forward(req, res);
    }

    private void verFormularioPassword(HttpServletRequest req, HttpServletResponse res) throws Exception {
        req.getRequestDispatcher("/cliente/cambiar-password.jsp").forward(req, res);
    }

    /* =========================================================
       ACCIONES POST
       ========================================================= */

    private void guardarPerfil(HttpServletRequest req, HttpServletResponse res) throws Exception {
        Integer idUsuario = (Integer) req.getSession().getAttribute("idUsuario");

        Usuario u = new Usuario();
        u.setIdUsuario(idUsuario);
        u.setNombres(trim(req.getParameter("nombres")));
        u.setApellidos(trim(req.getParameter("apellidos")));
        u.setDocumento(trim(req.getParameter("documento")));
        u.setTelefono(trim(req.getParameter("telefono")));
        u.setDireccion(trim(req.getParameter("direccion")));

        usuarioDAO.actualizarPerfil(u);

        usuarioDAO.registrarAuditoria(idUsuario, "PERFIL_ACTUALIZADO",
                "Cliente actualizó su perfil", req.getRemoteAddr());

        res.sendRedirect(req.getContextPath() + "/ClienteServlet?accion=ver&ok=perfilGuardado");
    }

    private void guardarPassword(HttpServletRequest req, HttpServletResponse res) throws Exception {
        Integer idUsuario = (Integer) req.getSession().getAttribute("idUsuario");
        String actual    = req.getParameter("passwordActual");
        String nueva     = req.getParameter("passwordNueva");
        String confirmar = req.getParameter("passwordConfirmar");

        // Validar campos
        if (nueva == null || nueva.length() < 8) {
            req.setAttribute("error", "La nueva contraseña debe tener al menos 8 caracteres.");
            verFormularioPassword(req, res);
            return;
        }
        if (!nueva.equals(confirmar)) {
            req.setAttribute("error", "La confirmación no coincide con la nueva contraseña.");
            verFormularioPassword(req, res);
            return;
        }

        // Verificar la contraseña actual contra la BD
        Usuario u = usuarioDAO.buscarPorId(idUsuario);
        if (u == null || !PasswordUtil.verify(actual, u.getPasswordHash())) {
            req.setAttribute("error", "La contraseña actual no es correcta.");
            verFormularioPassword(req, res);
            return;
        }

        // Guardar la nueva (hash BCrypt)
        usuarioDAO.cambiarPassword(idUsuario, PasswordUtil.hash(nueva));
        usuarioDAO.registrarAuditoria(idUsuario, "PASSWORD_CAMBIADA",
                "Cliente cambió su contraseña", req.getRemoteAddr());

        res.sendRedirect(req.getContextPath() + "/ClienteServlet?accion=ver&ok=passwordCambiada");
    }

    /* =========================================================
       HELPERS
       ========================================================= */

    private Usuario cargarUsuarioDeSesion(HttpServletRequest req) throws Exception {
        Integer idUsuario = (Integer) req.getSession().getAttribute("idUsuario");
        return usuarioDAO.buscarPorId(idUsuario);
    }

    @SuppressWarnings("unchecked")
    private boolean esCliente(HttpServletRequest req) {
        HttpSession ses = req.getSession(false);
        if (ses == null) return false;
        List<String> roles = (List<String>) ses.getAttribute("roles");
        return roles != null && roles.contains("CLIENTE");
    }

    private String trim(String s) { return s == null ? null : s.trim(); }
}
