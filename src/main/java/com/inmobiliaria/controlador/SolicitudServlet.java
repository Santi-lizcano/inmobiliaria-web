package com.inmobiliaria.controlador;

import com.inmobiliaria.dao.PropiedadDAO;
import com.inmobiliaria.dao.SolicitudDAO;
import com.inmobiliaria.dao.UsuarioDAO;
import com.inmobiliaria.modelo.Propiedad;
import com.inmobiliaria.modelo.Solicitud;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.MultipartConfig;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.*;

import java.io.File;
import java.io.IOException;
import java.nio.file.Paths;
import java.util.ArrayList;
import java.util.List;
import java.util.UUID;

@WebServlet("/SolicitudServlet")
@MultipartConfig(
    fileSizeThreshold = 1024 * 1024 * 2,
    maxFileSize       = 1024 * 1024 * 10,
    maxRequestSize    = 1024 * 1024 * 50
)
public class SolicitudServlet extends HttpServlet {

    private final SolicitudDAO solicitudDAO = new SolicitudDAO();
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
                case "ver"        -> ver(req, res);
                case "formulario" -> formulario(req, res);
                default           -> listar(req, res);
            }
        } catch (Exception e) {
            e.printStackTrace();
            req.setAttribute("error", "Error al procesar la solicitud: " + e.getMessage());
            req.getRequestDispatcher("/error.jsp").forward(req, res);
        }
    }

    /* =========================================================
       POST: crear | cambiarEstado | agregarDocumento
       ========================================================= */
    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse res)
            throws ServletException, IOException {

        req.setCharacterEncoding("UTF-8");
        String accion = req.getParameter("accion");

        try {
            if ("crear".equals(accion))                 crear(req, res);
            else if ("cambiarEstado".equals(accion))    cambiarEstado(req, res);
            else if ("agregarDocumento".equals(accion)) agregarDocumento(req, res);
            else res.sendRedirect(req.getContextPath() + "/SolicitudServlet?accion=listar");

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

        List<Solicitud> solicitudes;
        if (roles.contains("ADMINISTRADOR")) {
            solicitudes = solicitudDAO.listarTodas();
        } else if (roles.contains("INMOBILIARIA")) {
            Integer idInm = obtenerIdInmobiliariaDeSesion(req);
            solicitudes = (idInm != null) ? solicitudDAO.listarPorInmobiliaria(idInm) : List.of();
        } else {
            solicitudes = solicitudDAO.listarPorUsuario(idUsuario);
        }

        req.setAttribute("solicitudes", solicitudes);
        req.getRequestDispatcher("/solicitudes/lista.jsp").forward(req, res);
    }

    /* =========================================================
       ACCIÓN: VER detalle
       ========================================================= */
    private void ver(HttpServletRequest req, HttpServletResponse res)
            throws Exception {

        int id = Integer.parseInt(req.getParameter("id"));
        Solicitud s = solicitudDAO.buscarPorId(id);
        if (s == null) {
            req.setAttribute("error", "La solicitud no existe.");
            req.getRequestDispatcher("/error.jsp").forward(req, res);
            return;
        }

        if (!puedeAcceder(req, s)) {
            res.sendRedirect(req.getContextPath() + "/acceso-denegado.jsp");
            return;
        }

        req.setAttribute("solicitud", s);
        req.getRequestDispatcher("/solicitudes/detalle.jsp").forward(req, res);
    }

    /* =========================================================
       ACCIÓN: formulario (radicar solicitud)
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
        req.getRequestDispatcher("/solicitudes/formulario.jsp").forward(req, res);
    }

    /* =========================================================
       ACCIÓN: CREAR solicitud con documentos adjuntos
       ========================================================= */
    private void crear(HttpServletRequest req, HttpServletResponse res)
            throws Exception {

        if (!tieneRol(req, "CLIENTE", "ADMINISTRADOR")) {
            res.sendRedirect(req.getContextPath() + "/acceso-denegado.jsp");
            return;
        }

        int idPropiedad = Integer.parseInt(req.getParameter("idPropiedad"));
        int idUsuario   = (Integer) req.getSession().getAttribute("idUsuario");
        String tipo     = req.getParameter("tipo");               // COMPRA / ARRIENDO
        String observ   = req.getParameter("observaciones");
        String idCitaStr = req.getParameter("idCita");

        Solicitud s = new Solicitud();
        s.setIdPropiedad(idPropiedad);
        s.setIdUsuario(idUsuario);
        s.setTipo(tipo);
        s.setObservaciones(observ);
        if (idCitaStr != null && !idCitaStr.isEmpty()) {
            try { s.setIdCita(Integer.parseInt(idCitaStr)); } catch (NumberFormatException ignored) {}
        }

        // Subir los documentos adjuntos
        s.setDocumentos(subirDocumentos(req, idPropiedad));

        int idNueva = solicitudDAO.insertar(s);

        usuarioDAO.registrarAuditoria(idUsuario, "SOLICITUD_CREADA",
                "Solicitud ID " + idNueva + " (" + tipo + ") propiedad " + idPropiedad,
                req.getRemoteAddr());

        res.sendRedirect(req.getContextPath() + "/SolicitudServlet?accion=ver&id=" + idNueva);
    }

    /* =========================================================
       ACCIÓN: CAMBIAR ESTADO (solo inmobiliaria dueña o admin)
       ========================================================= */
    private void cambiarEstado(HttpServletRequest req, HttpServletResponse res)
            throws Exception {

        if (!tieneRol(req, "INMOBILIARIA", "ADMINISTRADOR")) {
            res.sendRedirect(req.getContextPath() + "/acceso-denegado.jsp");
            return;
        }

        int idSolicitud = Integer.parseInt(req.getParameter("id"));
        String nuevoEstado = req.getParameter("estado");  // EN_REVISION / APROBADA / RECHAZADA

        Solicitud s = solicitudDAO.buscarPorId(idSolicitud);
        if (s == null) {
            req.setAttribute("error", "La solicitud no existe.");
            req.getRequestDispatcher("/error.jsp").forward(req, res);
            return;
        }

        if (!puedeAcceder(req, s)) {
            res.sendRedirect(req.getContextPath() + "/acceso-denegado.jsp");
            return;
        }

        solicitudDAO.cambiarEstado(idSolicitud, nuevoEstado);

        usuarioDAO.registrarAuditoria(
                (Integer) req.getSession().getAttribute("idUsuario"),
                "SOLICITUD_ESTADO",
                "Solicitud " + idSolicitud + " → " + nuevoEstado,
                req.getRemoteAddr());

        res.sendRedirect(req.getContextPath() + "/SolicitudServlet?accion=ver&id=" + idSolicitud);
    }

    /* =========================================================
       ACCIÓN: AGREGAR documento a solicitud existente
       ========================================================= */
    private void agregarDocumento(HttpServletRequest req, HttpServletResponse res)
            throws Exception {

        int idSolicitud = Integer.parseInt(req.getParameter("id"));
        Solicitud s = solicitudDAO.buscarPorId(idSolicitud);
        if (s == null) {
            req.setAttribute("error", "La solicitud no existe.");
            req.getRequestDispatcher("/error.jsp").forward(req, res);
            return;
        }

        if (!puedeAcceder(req, s)) {
            res.sendRedirect(req.getContextPath() + "/acceso-denegado.jsp");
            return;
        }

        List<Solicitud.Documento> nuevos = subirDocumentos(req, s.getIdPropiedad());
        for (Solicitud.Documento d : nuevos) {
            solicitudDAO.agregarDocumento(idSolicitud, d.getNombre(), d.getUrl());
        }

        usuarioDAO.registrarAuditoria(
                (Integer) req.getSession().getAttribute("idUsuario"),
                "SOLICITUD_DOC_AGREGADO",
                "Solicitud " + idSolicitud + " + " + nuevos.size() + " documentos",
                req.getRemoteAddr());

        res.sendRedirect(req.getContextPath() + "/SolicitudServlet?accion=ver&id=" + idSolicitud);
    }

    /* =========================================================
       HELPERS
       ========================================================= */

    /** Sube los archivos <input type="file" name="documentos" multiple> */
    private List<Solicitud.Documento> subirDocumentos(HttpServletRequest req, int idPropiedad)
            throws IOException, ServletException {

        List<Solicitud.Documento> docs = new ArrayList<>();
        String uploadPath = getServletContext().getRealPath("/uploads/documentos");
        File dir = new File(uploadPath);
        if (!dir.exists()) dir.mkdirs();

        for (Part part : req.getParts()) {
            if (!"documentos".equals(part.getName())) continue;
            if (part.getSize() == 0) continue;

            String original = Paths.get(part.getSubmittedFileName())
                                    .getFileName().toString();
            String ext = original.contains(".")
                    ? original.substring(original.lastIndexOf('.'))
                    : ".pdf";
            String nombreGuardado = UUID.randomUUID() + ext;

            File destino = new File(dir, nombreGuardado);
            part.write(destino.getAbsolutePath());

            Solicitud.Documento d = new Solicitud.Documento();
            d.setNombre(original);     // nombre original visible
            d.setUrl(req.getContextPath() + "/uploads/documentos/" + nombreGuardado);
            docs.add(d);
        }
        return docs;
    }

    @SuppressWarnings("unchecked")
    private boolean tieneRol(HttpServletRequest req, String... requeridos) {
        HttpSession ses = req.getSession(false);
        if (ses == null) return false;
        List<String> roles = (List<String>) ses.getAttribute("roles");
        if (roles == null) return false;
        for (String r : requeridos) if (roles.contains(r)) return true;
        return false;
    }

    @SuppressWarnings("unchecked")
    private boolean puedeAcceder(HttpServletRequest req, Solicitud s) throws Exception {
        if (tieneRol(req, "ADMINISTRADOR")) return true;

        HttpSession ses = req.getSession(false);
        if (ses == null) return false;
        int idUsuario = (Integer) ses.getAttribute("idUsuario");
        List<String> roles = (List<String>) ses.getAttribute("roles");

        if (roles.contains("CLIENTE") && s.getIdUsuario() == idUsuario) return true;

        if (roles.contains("INMOBILIARIA")) {
            Integer idInm = obtenerIdInmobiliariaDeSesion(req);
            if (idInm == null) return false;
            Propiedad p = propiedadDAO.buscarPorId(s.getIdPropiedad());
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
