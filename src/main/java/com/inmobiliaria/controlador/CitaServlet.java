package com.inmobiliaria.controlador;

import com.inmobiliaria.dao.CitaDAO;
import com.inmobiliaria.dao.PropiedadDAO;
import com.inmobiliaria.dao.UsuarioDAO;
import com.inmobiliaria.modelo.Cita;
import com.inmobiliaria.modelo.Propiedad;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.*;

import java.io.IOException;
import java.sql.SQLIntegrityConstraintViolationException;
import java.time.LocalDateTime;
import java.util.List;

@WebServlet("/CitaServlet")
public class CitaServlet extends HttpServlet {

    private final CitaDAO      citaDAO      = new CitaDAO();
    private final PropiedadDAO propiedadDAO = new PropiedadDAO();
    private final UsuarioDAO   usuarioDAO   = new UsuarioDAO();

    /* =========================================================
       GET: listar | ver | formulario
       ========================================================= */
    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse res)
            throws ServletException, IOException {

        String accion = req.getParameter("accion");
        if (accion == null) accion = "listar";

        try {
            switch (accion) {
                case "ver"      -> ver(req, res);
                case "formulario" -> formulario(req, res);
                default         -> listar(req, res);
            }
        } catch (Exception e) {
            e.printStackTrace();
            req.setAttribute("error", "Error al procesar la solicitud: " + e.getMessage());
            req.getRequestDispatcher("/error.jsp").forward(req, res);
        }
    }

    /* =========================================================
       POST: crear | cambiarEstado | cancelar
       ========================================================= */
    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse res)
            throws ServletException, IOException {

        req.setCharacterEncoding("UTF-8");
        String accion = req.getParameter("accion");

        try {
            if ("crear".equals(accion))              crear(req, res);
            else if ("cambiarEstado".equals(accion)) cambiarEstado(req, res);
            else if ("cancelar".equals(accion))      cancelar(req, res);
            else res.sendRedirect(req.getContextPath() + "/CitaServlet?accion=listar");

        } catch (SQLIntegrityConstraintViolationException e) {
            // Captura del UNIQUE (id_propiedad, fecha_hora)
            req.setAttribute("error",
                "Ya existe una visita agendada para esa propiedad en ese horario. " +
                "Por favor elige otra fecha u hora.");
            req.setAttribute("propiedad",
                propiedadDAO.buscarPorId(Integer.parseInt(req.getParameter("idPropiedad"))));
            req.getRequestDispatcher("/citas/formulario.jsp").forward(req, res);

        } catch (Exception e) {
            e.printStackTrace();
            req.setAttribute("error", "Error inesperado: " + e.getMessage());
            req.getRequestDispatcher("/error.jsp").forward(req, res);
        }
    }

    /* =========================================================
       ACCIÓN: LISTAR (según rol)
       ========================================================= */
    @SuppressWarnings("unchecked")
    private void listar(HttpServletRequest req, HttpServletResponse res)
            throws Exception {

        HttpSession ses = req.getSession(false);
        if (ses == null || ses.getAttribute("idUsuario") == null) {
            res.sendRedirect(req.getContextPath() + "/login.jsp?error=sesion");
            return;
        }

        int idUsuario = (Integer) ses.getAttribute("idUsuario");
        List<String> roles = (List<String>) ses.getAttribute("roles");

        List<Cita> citas;
        if (roles.contains("ADMINISTRADOR")) {
            citas = citaDAO.listarTodas();
        } else if (roles.contains("INMOBILIARIA")) {
            Integer idInm = obtenerIdInmobiliariaDeSesion(req);
            citas = (idInm != null) ? citaDAO.listarPorInmobiliaria(idInm) : List.of();
        } else {
            citas = citaDAO.listarPorUsuario(idUsuario);
        }

        req.setAttribute("citas", citas);
        req.getRequestDispatcher("/citas/lista.jsp").forward(req, res);
    }

    /* =========================================================
       ACCIÓN: VER detalle
       ========================================================= */
    private void ver(HttpServletRequest req, HttpServletResponse res)
            throws Exception {

        int id = Integer.parseInt(req.getParameter("id"));
        Cita c = citaDAO.buscarPorId(id);
        if (c == null) {
            req.setAttribute("error", "La cita no existe.");
            req.getRequestDispatcher("/error.jsp").forward(req, res);
            return;
        }

        // Control: solo el dueño, la inmobiliaria de la propiedad o admin
        if (!puedeAcceder(req, c)) {
            res.sendRedirect(req.getContextPath() + "/acceso-denegado.jsp");
            return;
        }

        req.setAttribute("cita", c);
        req.getRequestDispatcher("/citas/detalle.jsp").forward(req, res);
    }

    /* =========================================================
       ACCIÓN: formulario de agendar visita
       ========================================================= */
    private void formulario(HttpServletRequest req, HttpServletResponse res)
            throws Exception {

        if (!tieneRol(req, "CLIENTE", "ADMINISTRADOR")) {
            res.sendRedirect(req.getContextPath() + "/acceso-denegado.jsp");
            return;
        }

        int idPropiedad = Integer.parseInt(req.getParameter("id"));
        Propiedad p = propiedadDAO.buscarPorId(idPropiedad);
        if (p == null) {
            req.setAttribute("error", "La propiedad no existe.");
            req.getRequestDispatcher("/error.jsp").forward(req, res);
            return;
        }

        req.setAttribute("propiedad", p);
        req.getRequestDispatcher("/citas/formulario.jsp").forward(req, res);
    }

    /* =========================================================
       ACCIÓN: CREAR cita (POST)
       ========================================================= */
    private void crear(HttpServletRequest req, HttpServletResponse res)
            throws Exception {

        if (!tieneRol(req, "CLIENTE", "ADMINISTRADOR")) {
            res.sendRedirect(req.getContextPath() + "/acceso-denegado.jsp");
            return;
        }

        int idPropiedad = Integer.parseInt(req.getParameter("idPropiedad"));
        int idUsuario   = (Integer) req.getSession().getAttribute("idUsuario");

        // fecha viene como "2026-08-30T14:30" (input datetime-local)
        LocalDateTime fechaHora = LocalDateTime.parse(req.getParameter("fechaHora"));

        // Validación previa: no permitir fechas en el pasado
        if (fechaHora.isBefore(LocalDateTime.now())) {
            req.setAttribute("error", "No puedes agendar una cita en una fecha pasada.");
            req.setAttribute("propiedad", propiedadDAO.buscarPorId(idPropiedad));
            req.getRequestDispatcher("/citas/formulario.jsp").forward(req, res);
            return;
        }

        // Validación explícita del UNIQUE (además de la restricción en BD)
        if (citaDAO.existeEnHorario(idPropiedad, fechaHora)) {
            req.setAttribute("error",
                "Ya existe una visita agendada para esa propiedad en ese horario.");
            req.setAttribute("propiedad", propiedadDAO.buscarPorId(idPropiedad));
            req.getRequestDispatcher("/citas/formulario.jsp").forward(req, res);
            return;
        }

        Cita c = new Cita();
        c.setIdPropiedad(idPropiedad);
        c.setIdUsuario(idUsuario);
        c.setFechaHora(fechaHora);
        c.setEstado("PENDIENTE");
        c.setObservaciones(req.getParameter("observaciones"));

        int idNueva = citaDAO.insertar(c);

        usuarioDAO.registrarAuditoria(idUsuario, "CITA_CREADA",
                "Cita ID " + idNueva + " para propiedad " + idPropiedad,
                req.getRemoteAddr());

        res.sendRedirect(req.getContextPath() + "/CitaServlet?accion=listar");
    }

    /* =========================================================
       ACCIÓN: CAMBIAR ESTADO (CONFIRMADA / REALIZADA / RECHAZADA)
       Solo inmobiliaria dueña de la propiedad o admin.
       ========================================================= */
    private void cambiarEstado(HttpServletRequest req, HttpServletResponse res)
            throws Exception {

        if (!tieneRol(req, "INMOBILIARIA", "ADMINISTRADOR")) {
            res.sendRedirect(req.getContextPath() + "/acceso-denegado.jsp");
            return;
        }

        int idCita = Integer.parseInt(req.getParameter("id"));
        String nuevoEstado = req.getParameter("estado");

        Cita c = citaDAO.buscarPorId(idCita);
        if (c == null) {
            req.setAttribute("error", "La cita no existe.");
            req.getRequestDispatcher("/error.jsp").forward(req, res);
            return;
        }

        if (!puedeAcceder(req, c)) {
            res.sendRedirect(req.getContextPath() + "/acceso-denegado.jsp");
            return;
        }

        citaDAO.cambiarEstado(idCita, nuevoEstado);

        usuarioDAO.registrarAuditoria(
                (Integer) req.getSession().getAttribute("idUsuario"),
                "CITA_ESTADO",
                "Cita " + idCita + " → " + nuevoEstado,
                req.getRemoteAddr());

        res.sendRedirect(req.getContextPath() + "/CitaServlet?accion=listar");
    }

    /* =========================================================
       ACCIÓN: CANCELAR (cliente dueño de la cita o admin)
       ========================================================= */
    private void cancelar(HttpServletRequest req, HttpServletResponse res)
            throws Exception {

        int idCita = Integer.parseInt(req.getParameter("id"));
        Cita c = citaDAO.buscarPorId(idCita);
        if (c == null) {
            req.setAttribute("error", "La cita no existe.");
            req.getRequestDispatcher("/error.jsp").forward(req, res);
            return;
        }

        int idUsuario = (Integer) req.getSession().getAttribute("idUsuario");
        boolean esAdmin = tieneRol(req, "ADMINISTRADOR");
        boolean esDueño = (c.getIdUsuario() == idUsuario);

        if (!esAdmin && !esDueño) {
            res.sendRedirect(req.getContextPath() + "/acceso-denegado.jsp");
            return;
        }

        citaDAO.cambiarEstado(idCita, "CANCELADA");

        usuarioDAO.registrarAuditoria(idUsuario, "CITA_CANCELADA",
                "Cita " + idCita, req.getRemoteAddr());

        res.sendRedirect(req.getContextPath() + "/CitaServlet?accion=listar");
    }

    /* =========================================================
       HELPERS
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

    /** Puede acceder si: es admin, es el cliente dueño de la cita,
        o es la inmobiliaria dueña de la propiedad de la cita. */
    @SuppressWarnings("unchecked")
    private boolean puedeAcceder(HttpServletRequest req, Cita c) throws Exception {
        if (tieneRol(req, "ADMINISTRADOR")) return true;

        HttpSession ses = req.getSession(false);
        if (ses == null) return false;
        int idUsuario = (Integer) ses.getAttribute("idUsuario");
        List<String> roles = (List<String>) ses.getAttribute("roles");

        if (roles.contains("CLIENTE") && c.getIdUsuario() == idUsuario) return true;

        if (roles.contains("INMOBILIARIA")) {
            Integer idInm = obtenerIdInmobiliariaDeSesion(req);
            if (idInm == null) return false;
            // Verificar si la propiedad de la cita es de esa inmobiliaria
            Propiedad p = propiedadDAO.buscarPorId(c.getIdPropiedad());
            return p != null && p.getIdInmobiliaria() == idInm;
        }
        return false;
    }

    private Integer obtenerIdInmobiliariaDeSesion(HttpServletRequest req) throws Exception {
        HttpSession ses = req.getSession(false);
        if (ses == null) return null;

        Object idInm = ses.getAttribute("idInmobiliaria");
        if (idInm instanceof Integer) return (Integer) idInm;

        String correo = (String) ses.getAttribute("correo");
        if (correo == null) return null;

        String sql = "SELECT i.id_inmobiliaria FROM inmobiliaria i " +
                     "INNER JOIN usuario u ON i.correo = u.correo " +
                     "WHERE u.correo = ?";
        try (java.sql.Connection cn = com.inmobiliaria.config.ConexionDB.getConnection();
             java.sql.PreparedStatement ps = cn.prepareStatement(sql)) {
            ps.setString(1, correo);
            try (java.sql.ResultSet rs = ps.executeQuery()) {
                if (rs.next()) return rs.getInt(1);
            }
        }
        return null;
    }
}
