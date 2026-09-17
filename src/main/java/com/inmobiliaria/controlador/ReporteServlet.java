package com.inmobiliaria.controlador;

import com.inmobiliaria.dao.ReporteDAO;
import com.inmobiliaria.dao.UsuarioDAO;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.*;

import java.io.IOException;
import java.util.List;
import java.util.Map;

@WebServlet("/ReporteServlet")
public class ReporteServlet extends HttpServlet {

    private final ReporteDAO reporteDAO = new ReporteDAO();
    private final UsuarioDAO usuarioDAO = new UsuarioDAO();

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse res)
            throws ServletException, IOException {

        // Solo admin e inmobiliaria pueden ver reportes
        if (!tieneRol(req, "ADMINISTRADOR", "INMOBILIARIA")) {
            res.sendRedirect(req.getContextPath() + "/acceso-denegado.jsp");
            return;
        }

        String tipo = req.getParameter("tipo");
        if (tipo == null || tipo.isEmpty()) tipo = "menu";

        try {
            switch (tipo) {
                case "propiedades"      -> propiedades(req, res);
                case "citas"            -> citas(req, res);
                case "caracteristicas"  -> caracteristicas(req, res);
                case "sinCitas"         -> sinCitas(req, res);
                case "porCiudad"        -> porCiudad(req, res);
                case "inmobiliarias"    -> inmobiliarias(req, res);
                case "solicitudes"      -> solicitudes(req, res);
                default                 -> res.sendRedirect(req.getContextPath() + "/reportes/menu.jsp");
            }

            // Auditoría del reporte consultado
            usuarioDAO.registrarAuditoria(
                    (Integer) req.getSession().getAttribute("idUsuario"),
                    "REPORTE_CONSULTADO",
                    "Reporte: " + tipo,
                    req.getRemoteAddr());

        } catch (Exception e) {
            e.printStackTrace();
            req.setAttribute("error", "Error al generar el reporte: " + e.getMessage());
            req.getRequestDispatcher("/error.jsp").forward(req, res);
        }
    }

    /* =========================================================
       Cada acción carga los datos y despacha al JSP correspondiente
       ========================================================= */

    private void propiedades(HttpServletRequest req, HttpServletResponse res)
            throws Exception {
        List<Map<String, Object>> datos = reporteDAO.propiedadesConDetalle();
        req.setAttribute("datos", datos);
        req.getRequestDispatcher("/reportes/propiedades.jsp").forward(req, res);
    }

    private void citas(HttpServletRequest req, HttpServletResponse res)
            throws Exception {
        List<Map<String, Object>> datos = reporteDAO.citasConDetalle();
        req.setAttribute("datos", datos);
        req.getRequestDispatcher("/reportes/citas.jsp").forward(req, res);
    }

    private void caracteristicas(HttpServletRequest req, HttpServletResponse res)
            throws Exception {
        List<Map<String, Object>> datos = reporteDAO.propiedadesConCaracteristicas();
        req.setAttribute("datos", datos);
        req.getRequestDispatcher("/reportes/caracteristicas.jsp").forward(req, res);
    }

    private void sinCitas(HttpServletRequest req, HttpServletResponse res)
            throws Exception {
        List<Map<String, Object>> datos = reporteDAO.propiedadesSinCitas();
        req.setAttribute("datos", datos);
        req.getRequestDispatcher("/reportes/sin-citas.jsp").forward(req, res);
    }

    private void porCiudad(HttpServletRequest req, HttpServletResponse res)
            throws Exception {
        List<Map<String, Object>> datos = reporteDAO.propiedadesDisponiblesPorCiudad();
        req.setAttribute("datos", datos);
        req.getRequestDispatcher("/reportes/por-ciudad.jsp").forward(req, res);
    }

    private void inmobiliarias(HttpServletRequest req, HttpServletResponse res)
            throws Exception {
        List<Map<String, Object>> datos = reporteDAO.resumenPorInmobiliaria();
        req.setAttribute("datos", datos);
        req.getRequestDispatcher("/reportes/inmobiliarias.jsp").forward(req, res);
    }

    private void solicitudes(HttpServletRequest req, HttpServletResponse res)
            throws Exception {
        List<Map<String, Object>> datos = reporteDAO.solicitudesPorEstado();
        req.setAttribute("datos", datos);
        req.getRequestDispatcher("/reportes/solicitudes.jsp").forward(req, res);
    }

    /* =========================================================
       Helper de rol
       ========================================================= */
    @SuppressWarnings("unchecked")
    private boolean tieneRol(HttpServletRequest req, String... requeridos) {
        HttpSession ses = req.getSession(false);
        if (ses == null) return false;
        List<String> roles = (List<String>) ses.getAttribute("roles");
        if (roles == null) return false;
        for (String r : requeridos) if (roles.contains(r)) return true;
        return false;
    }
}
