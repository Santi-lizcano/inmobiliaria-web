package com.inmobiliaria.controlador;

import com.inmobiliaria.dao.SolicitudDAO;
import com.inmobiliaria.modelo.Solicitud;
import com.inmobiliaria.modelo.Usuario;

import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.servlet.http.HttpSession;
import java.io.IOException;
import java.util.List;
import java.util.logging.Level;
import java.util.logging.Logger;

@WebServlet("/solicitudes")
public class SolicitudServlet extends HttpServlet {

    private static final Logger LOGGER =
            Logger.getLogger(SolicitudServlet.class.getName());

    private static final String ROL_CLIENTE = "Cliente";
    private static final String ROL_ADMIN = "Administrador";
    private static final String ROL_INMOBILIARIA = "Inmobiliaria";
    private static final String ROL_GESTOR = "Gestor";

    private static final String ESTADO_EN_REVISION = "En Revision";
    private static final String ESTADO_APROBADA = "Aprobada";
    private static final String ESTADO_RECHAZADA = "Rechazada";

    private SolicitudDAO solicitudDAO;

    @Override
    public void init() throws ServletException {
        super.init();
        this.solicitudDAO = new SolicitudDAO();
    }

    @Override
    protected void doGet(
            HttpServletRequest request,
            HttpServletResponse response)
            throws ServletException, IOException {

        Usuario usuario = obtenerUsuarioAutenticado(request, response);

        if (usuario == null) {
            return;
        }

        String accion = leerParametro(request, "accion", "listar");

        try {
            switch (accion) {
                case "listar":
                    listarSolicitudes(request, response, usuario);
                    break;

                case "aprobar":
                case "rechazar":
                    /*
                     * Cambiar el estado mediante GET no es seguro.
                     * Estas operaciones deben ejecutarse mediante POST.
                     */
                    response.sendError(
                            HttpServletResponse.SC_METHOD_NOT_ALLOWED,
                            "La aprobación o rechazo debe realizarse mediante POST."
                    );
                    break;

                default:
                    listarSolicitudes(request, response, usuario);
                    break;
            }
        } catch (Exception e) {
            manejarError(
                    request,
                    response,
                    "Error al procesar las solicitudes.",
                    e
            );
        }
    }

    @Override
    protected void doPost(
            HttpServletRequest request,
            HttpServletResponse response)
            throws ServletException, IOException {

        request.setCharacterEncoding("UTF-8");

        Usuario usuario = obtenerUsuarioAutenticado(request, response);

        if (usuario == null) {
            return;
        }

        String accion = leerParametro(request, "accion", "");

        try {
            switch (accion) {
                case "radicar":
                    radicarSolicitud(request, response, usuario);
                    break;

                case "aprobar":
                    evaluarSolicitud(
                            request,
                            response,
                            usuario,
                            ESTADO_APROBADA
                    );
                    break;

                case "rechazar":
                    evaluarSolicitud(
                            request,
                            response,
                            usuario,
                            ESTADO_RECHAZADA
                    );
                    break;

                default:
                    response.sendRedirect(
                            request.getContextPath()
                                    + "/solicitudes?accion=listar"
                    );
                    break;
            }
        } catch (IllegalArgumentException e) {
            LOGGER.log(
                    Level.WARNING,
                    "Parámetros inválidos en solicitud",
                    e
            );

            request.setAttribute("error", e.getMessage());
            request.getRequestDispatcher("/error.jsp")
                    .forward(request, response);

        } catch (Exception e) {
            manejarError(
                    request,
                    response,
                    "Error al procesar la solicitud.",
                    e
            );
        }
    }

    // =========================================================
    // AUTENTICACIÓN
    // =========================================================

    private Usuario obtenerUsuarioAutenticado(
            HttpServletRequest request,
            HttpServletResponse response)
            throws IOException {

        HttpSession session = request.getSession(false);

        if (session == null) {
            response.sendRedirect(
                    request.getContextPath() + "/login.jsp"
            );
            return null;
        }

        Object usuarioObject = session.getAttribute("usuario");

        if (!(usuarioObject instanceof Usuario)) {
            session.invalidate();

            response.sendRedirect(
                    request.getContextPath() + "/login.jsp"
            );
            return null;
        }

        return (Usuario) usuarioObject;
    }

    // =========================================================
    // AUTORIZACIÓN
    // =========================================================

    private boolean tieneRol(
            HttpServletRequest request,
            String rolBuscado) {

        HttpSession session = request.getSession(false);

        if (session == null || rolBuscado == null) {
            return false;
        }

        Object rolesObject = session.getAttribute("roles");

        if (!(rolesObject instanceof List<?>)) {
            return false;
        }

        List<?> roles = (List<?>) rolesObject;

        for (Object rol : roles) {
            if (rol != null
                    && rolBuscado.equalsIgnoreCase(rol.toString())) {
                return true;
            }
        }

        return false;
    }

    private boolean esCliente(HttpServletRequest request) {
        return tieneRol(request, ROL_CLIENTE);
    }

    private boolean puedeEvaluarSolicitudes(
            HttpServletRequest request) {

        return tieneRol(request, ROL_ADMIN)
                || tieneRol(request, ROL_INMOBILIARIA)
                || tieneRol(request, ROL_GESTOR);
    }

    // =========================================================
    // LISTAR SOLICITUDES
    // =========================================================

    private void listarSolicitudes(
            HttpServletRequest request,
            HttpServletResponse response,
            Usuario usuario)
            throws Exception {

        List<Solicitud> lista;

        if (esCliente(request)) {
            lista = solicitudDAO.listarPorCliente(
                    usuario.getIdUsuario()
            );
        } else if (puedeEvaluarSolicitudes(request)) {
            lista = solicitudDAO.listarTodas();
        } else {
            response.sendError(
                    HttpServletResponse.SC_FORBIDDEN,
                    "No tiene permisos para consultar solicitudes."
            );
            return;
        }

        request.setAttribute("solicitudes", lista);

        request.getRequestDispatcher(
                "/solicitudes/lista.jsp"
        ).forward(request, response);
    }

    // =========================================================
    // RADICAR SOLICITUD
    // =========================================================

    private void radicarSolicitud(
            HttpServletRequest request,
            HttpServletResponse response,
            Usuario cliente)
            throws Exception {

        if (!esCliente(request)) {
            response.sendError(
                    HttpServletResponse.SC_FORBIDDEN,
                    "Solo los clientes pueden radicar solicitudes."
            );
            return;
        }

        int idPropiedad = leerEnteroPositivo(
                request,
                "idPropiedad"
        );

        String tipoSolicitud = leerParametro(
                request,
                "tipoSolicitud",
                ""
        );

        String observaciones = leerParametro(
                request,
                "observaciones",
                ""
        );

        if (!"Compra".equalsIgnoreCase(tipoSolicitud)
                && !"Arriendo".equalsIgnoreCase(tipoSolicitud)) {

            throw new IllegalArgumentException(
                    "El tipo de solicitud debe ser Compra o Arriendo."
            );
        }

        if (observaciones.length() > 1000) {
            throw new IllegalArgumentException(
                    "Las observaciones no pueden superar los 1000 caracteres."
            );
        }

        Solicitud solicitud = new Solicitud();

        solicitud.setIdPropiedad(idPropiedad);
        solicitud.setIdCliente(cliente.getIdUsuario());
        solicitud.setTipo(tipoSolicitud);
        solicitud.setObservaciones(observaciones);
        solicitud.setEstado(ESTADO_EN_REVISION);

        boolean creada = solicitudDAO.crear(solicitud);

        if (creada) {
            request.getSession().setAttribute(
                    "mensajeExito",
                    "Solicitud radicada correctamente. "
                            + "La inmobiliaria la revisará pronto."
            );

            response.sendRedirect(
                    request.getContextPath()
                            + "/solicitudes?accion=listar"
            );
        } else {
            request.getSession().setAttribute(
                    "mensajeError",
                    "No se pudo radicar la solicitud. "
                            + "Intente nuevamente."
            );

            response.sendRedirect(
                    request.getContextPath()
                            + "/propiedades?accion=ver&id="
                            + idPropiedad
            );
        }
    }

    // =========================================================
    // APROBAR O RECHAZAR SOLICITUD
    // =========================================================

    private void evaluarSolicitud(
            HttpServletRequest request,
            HttpServletResponse response,
            Usuario usuario,
            String nuevoEstado)
            throws Exception {

        if (!puedeEvaluarSolicitudes(request)) {
            response.sendError(
                    HttpServletResponse.SC_FORBIDDEN,
                    "No tiene permisos para evaluar solicitudes."
            );
            return;
        }

        int idSolicitud = leerEnteroPositivo(
                request,
                "id"
        );

        Solicitud solicitud = solicitudDAO.obtenerPorId(idSolicitud);

        if (solicitud == null) {
            response.sendError(
                    HttpServletResponse.SC_NOT_FOUND,
                    "La solicitud no existe."
            );
            return;
        }

        if (!ESTADO_EN_REVISION.equals(solicitud.getEstado())) {
            request.getSession().setAttribute(
                    "mensajeError",
                    "La solicitud ya fue procesada anteriormente."
            );

            response.sendRedirect(
                    request.getContextPath()
                            + "/solicitudes?accion=listar"
            );
            return;
        }

        if (!ESTADO_APROBADA.equals(nuevoEstado)
                && !ESTADO_RECHAZADA.equals(nuevoEstado)) {

            throw new IllegalArgumentException(
                    "Estado de solicitud no permitido."
            );
        }

        boolean actualizado = solicitudDAO.actualizarEstado(
                idSolicitud,
                nuevoEstado
        );

        if (actualizado) {
            request.getSession().setAttribute(
                    "mensajeExito",
                    "La solicitud fue actualizada a: "
                            + nuevoEstado
            );
        } else {
            request.getSession().setAttribute(
                    "mensajeError",
                    "No se pudo actualizar el estado de la solicitud."
            );
        }

        response.sendRedirect(
                request.getContextPath()
                        + "/solicitudes?accion=listar"
        );
    }

    // =========================================================
    // VALIDACIÓN DE PARÁMETROS
    // =========================================================

    private String leerParametro(
            HttpServletRequest request,
            String nombre,
            String valorPorDefecto) {

        String valor = request.getParameter(nombre);

        if (valor == null) {
            return valorPorDefecto;
        }

        valor = valor.trim();

        return valor.isEmpty()
                ? valorPorDefecto
                : valor;
    }

    private int leerEnteroPositivo(
            HttpServletRequest request,
            String nombre) {

        String valor = leerParametro(
                request,
                nombre,
                ""
        );

        if (valor.isEmpty()) {
            throw new IllegalArgumentException(
                    "El parámetro '" + nombre + "' es obligatorio."
            );
        }

        try {
            int numero = Integer.parseInt(valor);

            if (numero <= 0) {
                throw new IllegalArgumentException(
                        "El parámetro '" + nombre
                                + "' debe ser mayor que cero."
                );
            }

            return numero;

        } catch (NumberFormatException e) {
            throw new IllegalArgumentException(
                    "El parámetro '" + nombre
                            + "' debe ser un número entero válido."
            );
        }
    }

    // =========================================================
    // MANEJO DE ERRORES
    // =========================================================

    private void manejarError(
            HttpServletRequest request,
            HttpServletResponse response,
            String mensaje,
            Exception exception)
            throws ServletException, IOException {

        LOGGER.log(
                Level.SEVERE,
                mensaje,
                exception
        );

        /*
         * No se muestra exception.getMessage() al usuario,
         * porque podría revelar información de la base de datos
         * o detalles internos de la aplicación.
         */
        request.setAttribute("error", mensaje);

        request.getRequestDispatcher(
                "/error.jsp"
        ).forward(request, response);
    }
}
