package com.inmobiliaria.controlador;

import com.inmobiliaria.dao.CatalogoDAO;
import com.inmobiliaria.dao.PropiedadDAO;
import com.inmobiliaria.dao.UsuarioDAO;
import com.inmobiliaria.modelo.Propiedad;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.MultipartConfig;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.*;

import java.io.File;
import java.io.IOException;
import java.math.BigDecimal;
import java.nio.file.Paths;
import java.sql.SQLIntegrityConstraintViolationException;
import java.util.ArrayList;
import java.util.List;
import java.util.UUID;

@WebServlet("/PropiedadServlet")
@MultipartConfig(
    fileSizeThreshold = 1024 * 1024 * 2,   // 2 MB
    maxFileSize       = 1024 * 1024 * 10,  // 10 MB por archivo
    maxRequestSize    = 1024 * 1024 * 50   // 50 MB total
)
public class PropiedadServlet extends HttpServlet {

    private final PropiedadDAO propiedadDAO = new PropiedadDAO();
    private final CatalogoDAO  catalogoDAO  = new CatalogoDAO();
    private final UsuarioDAO   usuarioDAO   = new UsuarioDAO();

    /* =========================================================
       GET: listar | ver | formularioNuevo | formularioEditar | baja
       ========================================================= */
    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse res)
            throws ServletException, IOException {

        String accion = req.getParameter("accion");
        if (accion == null) accion = "listar";

        try {
            switch (accion) {
                case "ver"             -> ver(req, res);
                case "formularioNuevo" -> formularioNuevo(req, res);
                case "formularioEditar"-> formularioEditar(req, res);
                case "baja"            -> baja(req, res);
                default                -> listar(req, res);
            }
        } catch (Exception e) {
            e.printStackTrace();
            req.setAttribute("error", "Error al procesar la solicitud: " + e.getMessage());
            req.getRequestDispatcher("/error.jsp").forward(req, res);
        }
    }

    /* =========================================================
       POST: crear | actualizar
       ========================================================= */
    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse res)
            throws ServletException, IOException {

        req.setCharacterEncoding("UTF-8");
        String accion = req.getParameter("accion");

        try {
            if ("crear".equals(accion))      crear(req, res);
            else if ("actualizar".equals(accion)) actualizar(req, res);
            else res.sendRedirect(req.getContextPath() + "/PropiedadServlet?accion=listar");

        } catch (SQLIntegrityConstraintViolationException e) {
            // Captura del UNIQUE en matricula_inmobiliaria
            String msg = e.getMessage() == null ? "" : e.getMessage().toLowerCase();
            if (msg.contains("matricula")) {
                req.setAttribute("error", "La matrícula inmobiliaria ya está registrada.");
            } else {
                req.setAttribute("error", "Ya existe un registro con esos datos.");
            }
            // Volver al formulario conservando lo que el usuario escribió
            req.setAttribute("propiedad", construirDesdeRequest(req));
            try {
                cargarCatalogos(req);
            } catch (Exception ex) {
                throw new ServletException("No se pudieron recargar los catálogos", ex);
            }
            req.getRequestDispatcher("/propiedades/formulario.jsp").forward(req, res);

        } catch (Exception e) {
            e.printStackTrace();
            req.setAttribute("error", "Error inesperado: " + e.getMessage());
            req.getRequestDispatcher("/error.jsp").forward(req, res);
        }
    }

    /* =========================================================
       ACCIÓN: LISTAR con filtros
       ========================================================= */
    private void listar(HttpServletRequest req, HttpServletResponse res)
            throws Exception {

        String ciudad    = trim(req.getParameter("ciudad"));
        String tipo      = trim(req.getParameter("tipo"));
        String precioMax = trim(req.getParameter("precioMax"));
        String estado    = trim(req.getParameter("estado"));

        Double precio = null;
        if (precioMax != null && !precioMax.isEmpty()) {
            try { precio = Double.parseDouble(precioMax); } catch (NumberFormatException ignored) {}
        }

        // Características: vienen como ?car=1&car=2...
        String[] carArr = req.getParameterValues("car");
        List<Integer> idCaracteristicas = new ArrayList<>();
        if (carArr != null) {
            for (String c : carArr) {
                try { idCaracteristicas.add(Integer.parseInt(c)); } catch (NumberFormatException ignored) {}
            }
        }

        List<Propiedad> lista = propiedadDAO.listar(ciudad, tipo, precio, idCaracteristicas, estado);

        req.setAttribute("propiedades", lista);
        cargarCatalogos(req);
        req.getRequestDispatcher("/propiedades/lista.jsp").forward(req, res);
    }

    /* =========================================================
       ACCIÓN: VER detalle de una propiedad
       ========================================================= */
    private void ver(HttpServletRequest req, HttpServletResponse res)
            throws Exception {

        int id = Integer.parseInt(req.getParameter("id"));
        Propiedad p = propiedadDAO.buscarPorId(id);

        if (p == null) {
            req.setAttribute("error", "La propiedad no existe.");
            req.getRequestDispatcher("/error.jsp").forward(req, res);
            return;
        }

        req.setAttribute("propiedad", p);
        req.getRequestDispatcher("/propiedades/detalle.jsp").forward(req, res);
    }

    /* =========================================================
       ACCIÓN: formulario NUEVO
       ========================================================= */
    private void formularioNuevo(HttpServletRequest req, HttpServletResponse res)
            throws Exception {

        if (!tieneRol(req, "INMOBILIARIA", "ADMINISTRADOR")) {
            res.sendRedirect(req.getContextPath() + "/acceso-denegado.jsp");
            return;
        }

        // Si venimos de un error previo, conservamos la propiedad
        if (req.getAttribute("propiedad") == null) {
            req.setAttribute("propiedad", new Propiedad());
        }
        cargarCatalogos(req);
        req.getRequestDispatcher("/propiedades/formulario.jsp").forward(req, res);
    }

    /* =========================================================
       ACCIÓN: formulario EDITAR
       ========================================================= */
    private void formularioEditar(HttpServletRequest req, HttpServletResponse res)
            throws Exception {

        if (!tieneRol(req, "INMOBILIARIA", "ADMINISTRADOR")) {
            res.sendRedirect(req.getContextPath() + "/acceso-denegado.jsp");
            return;
        }

        int id = Integer.parseInt(req.getParameter("id"));
        Propiedad p = propiedadDAO.buscarPorId(id);

        if (p == null) {
            req.setAttribute("error", "La propiedad no existe.");
            req.getRequestDispatcher("/error.jsp").forward(req, res);
            return;
        }

        req.setAttribute("propiedad", p);
        req.setAttribute("caracteristicasSeleccionadas", catalogoDAO.caracteristicasDePropiedad(id));
        cargarCatalogos(req);
        req.getRequestDispatcher("/propiedades/formulario.jsp").forward(req, res);
    }

    /* =========================================================
       ACCIÓN: CREAR (POST)
       ========================================================= */
    private void crear(HttpServletRequest req, HttpServletResponse res)
            throws Exception {

        if (!tieneRol(req, "INMOBILIARIA", "ADMINISTRADOR")) {
            res.sendRedirect(req.getContextPath() + "/acceso-denegado.jsp");
            return;
        }

        Propiedad p = construirDesdeRequest(req);

        // La inmobiliaria se asigna desde la sesión (no se confía en el form)
        Integer idInmobiliaria = obtenerIdInmobiliariaDeSesion(req);
        if (idInmobiliaria == null) {
            req.setAttribute("error", "No se pudo determinar la inmobiliaria del usuario.");
            cargarCatalogos(req);
            req.setAttribute("propiedad", p);
            req.getRequestDispatcher("/propiedades/formulario.jsp").forward(req, res);
            return;
        }
        p.setIdInmobiliaria(idInmobiliaria);

        // Imágenes: subir al disco y guardar rutas relativas
        List<String> urls = subirImagenes(req, p.getMatriculaInmobiliaria());

        // Características: vienen como car=1&car=2...
        List<Integer> idsCar = parsearCaracteristicas(req);

        int idNuevo = propiedadDAO.insertar(p, urls, idsCar);

        usuarioDAO.registrarAuditoria(
                (Integer) req.getSession().getAttribute("idUsuario"),
                "PROPIEDAD_CREADA",
                "Propiedad ID " + idNuevo + " - " + p.getTitulo(),
                req.getRemoteAddr());

        res.sendRedirect(req.getContextPath() + "/PropiedadServlet?accion=ver&id=" + idNuevo);
    }

    /* =========================================================
       ACCIÓN: ACTUALIZAR (POST)
       ========================================================= */
    private void actualizar(HttpServletRequest req, HttpServletResponse res)
            throws Exception {

        if (!tieneRol(req, "INMOBILIARIA", "ADMINISTRADOR")) {
            res.sendRedirect(req.getContextPath() + "/acceso-denegado.jsp");
            return;
        }

        int id = Integer.parseInt(req.getParameter("id"));
        Propiedad original = propiedadDAO.buscarPorId(id);
        if (original == null) {
            req.setAttribute("error", "La propiedad no existe.");
            req.getRequestDispatcher("/error.jsp").forward(req, res);
            return;
        }

        // Solo el dueño (inmobiliaria) o admin pueden editarla
        Integer idInm = obtenerIdInmobiliariaDeSesion(req);
        boolean esAdmin = tieneRol(req, "ADMINISTRADOR");
        if (!esAdmin && (idInm == null || idInm != original.getIdInmobiliaria())) {
            res.sendRedirect(req.getContextPath() + "/acceso-denegado.jsp");
            return;
        }

        Propiedad p = construirDesdeRequest(req);
        p.setIdPropiedad(id);
        p.setIdInmobiliaria(original.getIdInmobiliaria()); // no cambia de dueño

        // Nuevas imágenes: si el usuario subió archivos, reemplazan a las anteriores.
        // Si no subió nada, se conservan las que ya estaban.
        List<String> urls;
        List<String> nuevas = subirImagenes(req, original.getMatriculaInmobiliaria());
        if (nuevas.isEmpty()) {
            urls = original.getImagenes();
        } else {
            urls = nuevas;
        }

        List<Integer> idsCar = parsearCaracteristicas(req);

        propiedadDAO.actualizar(p, urls, idsCar);

        usuarioDAO.registrarAuditoria(
                (Integer) req.getSession().getAttribute("idUsuario"),
                "PROPIEDAD_ACTUALIZADA",
                "Propiedad ID " + id,
                req.getRemoteAddr());

        res.sendRedirect(req.getContextPath() + "/PropiedadServlet?accion=ver&id=" + id);
    }

    /* =========================================================
       ACCIÓN: BAJA LÓGICA
       ========================================================= */
    private void baja(HttpServletRequest req, HttpServletResponse res)
            throws Exception {

        if (!tieneRol(req, "INMOBILIARIA", "ADMINISTRADOR")) {
            res.sendRedirect(req.getContextPath() + "/acceso-denegado.jsp");
            return;
        }

        int id = Integer.parseInt(req.getParameter("id"));
        Propiedad original = propiedadDAO.buscarPorId(id);
        if (original == null) {
            req.setAttribute("error", "La propiedad no existe.");
            req.getRequestDispatcher("/error.jsp").forward(req, res);
            return;
        }

        Integer idInm = obtenerIdInmobiliariaDeSesion(req);
        boolean esAdmin = tieneRol(req, "ADMINISTRADOR");
        if (!esAdmin && (idInm == null || idInm != original.getIdInmobiliaria())) {
            res.sendRedirect(req.getContextPath() + "/acceso-denegado.jsp");
            return;
        }

        propiedadDAO.darDeBaja(id);

        usuarioDAO.registrarAuditoria(
                (Integer) req.getSession().getAttribute("idUsuario"),
                "PROPIEDAD_BAJA",
                "Propiedad ID " + id,
                req.getRemoteAddr());

        res.sendRedirect(req.getContextPath() + "/PropiedadServlet?accion=listar");
    }

    /* =========================================================
       HELPERS
       ========================================================= */

    private Propiedad construirDesdeRequest(HttpServletRequest req) {
        Propiedad p = new Propiedad();
        p.setMatriculaInmobiliaria(trim(req.getParameter("matricula")));
        p.setTitulo(trim(req.getParameter("titulo")));
        p.setDescripcion(trim(req.getParameter("descripcion")));

        try { p.setPrecio(new BigDecimal(req.getParameter("precio"))); }
        catch (Exception e) { p.setPrecio(BigDecimal.ZERO); }

        try { p.setAreaM2(new BigDecimal(req.getParameter("areaM2"))); }
        catch (Exception e) { p.setAreaM2(BigDecimal.ZERO); }

        try { p.setHabitaciones(Integer.parseInt(req.getParameter("habitaciones"))); }
        catch (Exception e) { p.setHabitaciones(0); }

        try { p.setBanos(Integer.parseInt(req.getParameter("banos"))); }
        catch (Exception e) { p.setBanos(0); }

        p.setDireccion(trim(req.getParameter("direccion")));
        p.setEstado(req.getParameter("estado") == null ? "DISPONIBLE" : req.getParameter("estado"));

        try { p.setIdTipo(Integer.parseInt(req.getParameter("idTipo"))); }
        catch (Exception e) { p.setIdTipo(0); }

        try { p.setIdCiudad(Integer.parseInt(req.getParameter("idCiudad"))); }
        catch (Exception e) { p.setIdCiudad(0); }

        return p;
    }

    private List<Integer> parsearCaracteristicas(HttpServletRequest req) {
        List<Integer> ids = new ArrayList<>();
        String[] arr = req.getParameterValues("car");
        if (arr != null) {
            for (String s : arr) {
                try { ids.add(Integer.parseInt(s)); } catch (NumberFormatException ignored) {}
            }
        }
        return ids;
    }

    /**
     * Sube los archivos <input type="file" name="imagenes" multiple>
     * a /uploads/propiedades/ y devuelve las rutas relativas.
     */
    private List<String> subirImagenes(HttpServletRequest req, String matricula)
            throws IOException, ServletException {

        List<String> urls = new ArrayList<>();
        String uploadPath = getServletContext().getRealPath("/uploads/propiedades");
        File dir = new File(uploadPath);
        if (!dir.exists()) dir.mkdirs();

        for (Part part : req.getParts()) {
            if (!"imagenes".equals(part.getName())) continue;
            if (part.getSize() == 0) continue;

            String original = Paths.get(part.getSubmittedFileName()).getFileName().toString();
            String ext = original.contains(".")
                    ? original.substring(original.lastIndexOf('.'))
                    : ".jpg";
            String nombreArchivo = UUID.randomUUID() + ext;

            File destino = new File(dir, nombreArchivo);
            part.write(destino.getAbsolutePath());

            urls.add(req.getContextPath() + "/uploads/propiedades/" + nombreArchivo);
        }
        return urls;
    }

    /** Busca el id_inmobiliaria del usuario logueado (si es rol INMOBILIARIA). */
    private Integer obtenerIdInmobiliariaDeSesion(HttpServletRequest req) throws Exception {
        HttpSession ses = req.getSession(false);
        if (ses == null) return null;

        // Si en sesión guardaste el idInmobiliaria al hacer login, úsalo directo.
        Object idInm = ses.getAttribute("idInmobiliaria");
        if (idInm instanceof Integer) return (Integer) idInm;

        // Si no, lo buscamos por correo
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

    private void cargarCatalogos(HttpServletRequest req) throws Exception {
        req.setAttribute("ciudades", catalogoDAO.listarCiudades());
        req.setAttribute("tipos", catalogoDAO.listarTipos());
        req.setAttribute("caracteristicas", catalogoDAO.listarCaracteristicas());
    }

    @SuppressWarnings("unchecked")
    private boolean tieneRol(HttpServletRequest req, String... rolesRequeridos) {
        HttpSession ses = req.getSession(false);
        if (ses == null) return false;
        List<String> roles = (List<String>) ses.getAttribute("roles");
        if (roles == null) return false;
        for (String r : rolesRequeridos) if (roles.contains(r)) return true;
        return false;
    }

    private String trim(String s) { return s == null ? null : s.trim(); }
}
