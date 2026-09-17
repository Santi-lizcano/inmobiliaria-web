package com.inmobiliaria.controlador;

import com.inmobiliaria.dao.CatalogoDAO;
import com.inmobiliaria.dao.UsuarioDAO;
import com.inmobiliaria.modelo.Usuario;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.*;

import java.io.IOException;
import java.sql.SQLIntegrityConstraintViolationException;
import java.util.List;

@WebServlet("/AdminServlet")
public class AdminServlet extends HttpServlet {

    private final UsuarioDAO  usuarioDAO  = new UsuarioDAO();
    private final CatalogoDAO catalogoDAO = new CatalogoDAO();

    /* =========================================================
       GET: vista por defecto de cada módulo
       ========================================================= */
    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse res)
            throws ServletException, IOException {

        if (!esAdmin(req)) {
            res.sendRedirect(req.getContextPath() + "/acceso-denegado.jsp");
            return;
        }

        String accion = req.getParameter("accion");
        if (accion == null) accion = "usuarios";

        try {
            switch (accion) {
                case "usuarios"    -> verUsuarios(req, res);
                case "roles"       -> verRoles(req, res);
                case "catalogos"   -> verCatalogos(req, res);
                case "auditoria"   -> verAuditoria(req, res);
                case "editarUsuario" -> editarUsuario(req, res);
                default            -> verUsuarios(req, res);
            }
        } catch (Exception e) {
            e.printStackTrace();
            req.setAttribute("error", "Error al procesar la solicitud: " + e.getMessage());
            req.getRequestDispatcher("/error.jsp").forward(req, res);
        }
    }

    /* =========================================================
       POST: acciones que cambian estado
       ========================================================= */
    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse res)
            throws ServletException, IOException {

        if (!esAdmin(req)) {
            res.sendRedirect(req.getContextPath() + "/acceso-denegado.jsp");
            return;
        }

        req.setCharacterEncoding("UTF-8");
        String accion = req.getParameter("accion");
        if (accion == null) accion = "";

        try {
            switch (accion) {
                case "cambiarEstado" -> cambiarEstado(req, res);
                case "asignarRol"    -> asignarRol(req, res);
                case "revocarRol"    -> revocarRol(req, res);
                case "actualizarUsuario" -> actualizarUsuario(req, res);
                default -> res.sendRedirect(req.getContextPath() + "/admin/usuarios.jsp");
            }
        } catch (SQLIntegrityConstraintViolationException e) {
            req.setAttribute("error", "Conflicto con datos únicos (correo o documento duplicado).");
            try { verUsuarios(req, res); } catch (Exception ex) { throw new ServletException(ex); }
        } catch (Exception e) {
            e.printStackTrace();
            req.setAttribute("error", "Error inesperado: " + e.getMessage());
            req.getRequestDispatcher("/error.jsp").forward(req, res);
        }
    }

    /* =========================================================
       VISTAS
       ========================================================= */

    private void verUsuarios(HttpServletRequest req, HttpServletResponse res) throws Exception {
        List<Usuario> usuarios = usuarioDAO.listarTodos();
        req.setAttribute("usuarios", usuarios);
        req.getRequestDispatcher("/admin/usuarios.jsp").forward(req, res);
    }

    private void verRoles(HttpServletRequest req, HttpServletResponse res) throws Exception {
        // Pasamos usuarios y roles disponibles para armar la matriz de asignación
        req.setAttribute("usuarios", usuarioDAO.listarTodos());
        req.setAttribute("rolesDisponibles", catalogoDAO.listarRoles());
        req.getRequestDispatcher("/admin/roles.jsp").forward(req, res);
    }

    private void verCatalogos(HttpServletRequest req, HttpServletResponse res) throws Exception {
        req.setAttribute("ciudades", catalogoDAO.listarCiudades());
        req.setAttribute("tipos", catalogoDAO.listarTipos());
        req.setAttribute("caracteristicas", catalogoDAO.listarCaracteristicas());
        req.getRequestDispatcher("/admin/catalogos.jsp").forward(req, res);
    }

    private void verAuditoria(HttpServletRequest req, HttpServletResponse res) throws Exception {
        int limite = 200;
        req.setAttribute("auditoria", usuarioDAO.listarAuditoria(limite));
        req.getRequestDispatcher("/admin/auditoria.jsp").forward(req, res);
    }

    private void editarUsuario(HttpServletRequest req, HttpServletResponse res) throws Exception {
        int id = Integer.parseInt(req.getParameter("id"));
        Usuario u = usuarioDAO.buscarPorId(id);
        if (u == null) {
            req.setAttribute("error", "Usuario no encontrado.");
            verUsuarios(req, res);
            return;
        }
        req.setAttribute("usuarioEditado", u);
        req.setAttribute("rolesUsuario", usuarioDAO.obtenerRoles(id));
        req.setAttribute("rolesDisponibles", catalogoDAO.listarRoles());
        req.setAttribute("usuarios", usuarioDAO.listarTodos());
        req.getRequestDispatcher("/admin/usuarios.jsp").forward(req, res);
    }

    /* =========================================================
       ACCIONES POST
       ========================================================= */

    private void cambiarEstado(HttpServletRequest req, HttpServletResponse res) throws Exception {
        int id = Integer.parseInt(req.getParameter("id"));
        String estado = req.getParameter("estado"); // ACTIVO / INACTIVO / BLOQUEADO
        usuarioDAO.cambiarEstado(id, estado);
        usuarioDAO.registrarAuditoria(idAdmin(req), "USUARIO_ESTADO",
                "Usuario " + id + " → " + estado, req.getRemoteAddr());
        res.sendRedirect(req.getContextPath() + "/AdminServlet?accion=usuarios");
    }

    private void asignarRol(HttpServletRequest req, HttpServletResponse res) throws Exception {
        int idUsuario = Integer.parseInt(req.getParameter("idUsuario"));
        int idRol = Integer.parseInt(req.getParameter("idRol"));
        usuarioDAO.asignarRol(idUsuario, idRol);
        usuarioDAO.registrarAuditoria(idAdmin(req), "ROL_ASIGNADO",
                "Usuario " + idUsuario + " ← rol " + idRol, req.getRemoteAddr());
        res.sendRedirect(req.getContextPath() + "/AdminServlet?accion=roles");
    }

    private void revocarRol(HttpServletRequest req, HttpServletResponse res) throws Exception {
        int idUsuario = Integer.parseInt(req.getParameter("idUsuario"));
        int idRol = Integer.parseInt(req.getParameter("idRol"));
        usuarioDAO.revocarRol(idUsuario, idRol);
        usuarioDAO.registrarAuditoria(idAdmin(req), "ROL_REVOCADO",
                "Usuario " + idUsuario + " ⊘ rol " + idRol, req.getRemoteAddr());
        res.sendRedirect(req.getContextPath() + "/AdminServlet?accion=roles");
    }

    private void actualizarUsuario(HttpServletRequest req, HttpServletResponse res) throws Exception {
        int id = Integer.parseInt(req.getParameter("id"));
        Usuario u = new Usuario();
        u.setIdUsuario(id);
        u.setNombres(req.getParameter("nombres"));
        u.setApellidos(req.getParameter("apellidos"));
        u.setDocumento(req.getParameter("documento"));
        u.setTelefono(req.getParameter("telefono"));
        u.setDireccion(req.getParameter("direccion"));
        usuarioDAO.actualizarPerfil(u);
        usuarioDAO.registrarAuditoria(idAdmin(req), "USUARIO_EDITADO",
                "Usuario " + id, req.getRemoteAddr());
        res.sendRedirect(req.getContextPath() + "/AdminServlet?accion=usuarios");
    }

    /* =========================================================
       Helpers
       ========================================================= */
    @SuppressWarnings("unchecked")
    private boolean esAdmin(HttpServletRequest req) {
        HttpSession ses = req.getSession(false);
        if (ses == null) return false;
        List<String> roles = (List<String>) ses.getAttribute("roles");
        return roles != null && roles.contains("ADMINISTRADOR");
    }

    private Integer idAdmin(HttpServletRequest req) {
        Object o = req.getSession().getAttribute("idUsuario");
        return o instanceof Integer ? (Integer) o : null;
    }
}
