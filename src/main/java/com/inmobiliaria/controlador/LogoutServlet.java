package com.inmobiliaria.controlador;

import com.inmobiliaria.dao.UsuarioDAO;

import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.*;

import java.io.IOException;

@WebServlet("/LogoutServlet")
public class LogoutServlet extends HttpServlet {

    private final UsuarioDAO usuarioDAO = new UsuarioDAO();

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse res)
            throws IOException {

        HttpSession ses = req.getSession(false);
        if (ses != null) {
            // Registrar auditoría antes de invalidar la sesión
            Object idUsuario = ses.getAttribute("idUsuario");
            if (idUsuario instanceof Integer) {
                try {
                    usuarioDAO.registrarAuditoria((Integer) idUsuario, "LOGOUT",
                            "Cierre de sesión", req.getRemoteAddr());
                } catch (Exception ignored) {
                    // Si falla la auditoría no impedimos el logout
                }
            }
            ses.invalidate();
        }

        // Redirigir al login con aviso
        res.sendRedirect(req.getContextPath() + "/login.jsp?ok=sesionCerrada");
    }

    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse res)
            throws IOException {
        doGet(req, res);
    }
}
