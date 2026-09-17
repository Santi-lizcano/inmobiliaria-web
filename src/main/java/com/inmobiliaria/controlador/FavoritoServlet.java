package com.inmobiliaria.controlador;

import com.inmobiliaria.dao.FavoritoDAO;
import com.inmobiliaria.dao.PropiedadDAO;
import com.inmobiliaria.modelo.Propiedad;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.*;

import java.io.IOException;
import java.util.List;

@WebServlet("/FavoritoServlet")
public class FavoritoServlet extends HttpServlet {

    private final FavoritoDAO  favoritoDAO  = new FavoritoDAO();
    private final PropiedadDAO propiedadDAO = new PropiedadDAO();

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse res)
            throws ServletException, IOException {

        if (!esCliente(req)) {
            res.sendRedirect(req.getContextPath() + "/acceso-denegado.jsp");
            return;
        }

        String accion = req.getParameter("accion");
        if (accion == null) accion = "listar";

        try {
            switch (accion) {
                case "agregar" -> agregar(req, res);
                case "quitar"  -> quitar(req, res);
                default        -> listar(req, res);
            }
        } catch (Exception e) {
            e.printStackTrace();
            req.setAttribute("error", "Error: " + e.getMessage());
            req.getRequestDispatcher("/error.jsp").forward(req, res);
        }
    }

    /* =========================================================
       ACCIONES
       ========================================================= */

    private void listar(HttpServletRequest req, HttpServletResponse res) throws Exception {
        Integer idUsuario = (Integer) req.getSession().getAttribute("idUsuario");
        List<Propiedad> favoritas = favoritoDAO.listarPorUsuario(idUsuario);

        // Cargar imágenes y características de cada una
        for (Propiedad p : favoritas) {
            Propiedad completa = propiedadDAO.buscarPorId(p.getIdPropiedad());
            if (completa != null) {
                p.setImagenes(completa.getImagenes());
                p.setCaracteristicas(completa.getCaracteristicas());
                p.setNombreCiudad(completa.getNombreCiudad());
                p.setNombreTipo(completa.getNombreTipo());
                p.setRazonSocialInmobiliaria(completa.getRazonSocialInmobiliaria());
            }
        }

        req.setAttribute("favoritos", favoritas);
        req.getRequestDispatcher("/cliente/favoritos.jsp").forward(req, res);
    }

    private void agregar(HttpServletRequest req, HttpServletResponse res) throws Exception {
        Integer idUsuario = (Integer) req.getSession().getAttribute("idUsuario");
        int idPropiedad = Integer.parseInt(req.getParameter("id"));

        favoritoDAO.agregar(idUsuario, idPropiedad);

        // Volver a donde estaba (detalle de la propiedad)
        String referer = req.getHeader("Referer");
        if (referer != null) res.sendRedirect(referer);
        else res.sendRedirect(req.getContextPath() + "/PropiedadServlet?accion=ver&id=" + idPropiedad);
    }

    private void quitar(HttpServletRequest req, HttpServletResponse res) throws Exception {
        Integer idUsuario = (Integer) req.getSession().getAttribute("idUsuario");
        int idPropiedad = Integer.parseInt(req.getParameter("id"));

        favoritoDAO.quitar(idUsuario, idPropiedad);

        String referer = req.getHeader("Referer");
        if (referer != null) res.sendRedirect(referer);
        else res.sendRedirect(req.getContextPath() + "/FavoritoServlet?accion=listar");
    }

    /* =========================================================
       Helpers
       ========================================================= */
    @SuppressWarnings("unchecked")
    private boolean esCliente(HttpServletRequest req) {
        HttpSession ses = req.getSession(false);
        if (ses == null) return false;
        List<String> roles = (List<String>) ses.getAttribute("roles");
        return roles != null && roles.contains("CLIENTE");
    }
}
