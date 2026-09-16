package com.inmobiliaria.controlador;

import com.inmobiliaria.dao.UsuarioDAO;
import com.inmobiliaria.modelo.Usuario;
import com.inmobiliaria.util.PasswordUtil;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.*;
import java.io.IOException;

@WebServlet("/LoginServlet")
public class LoginServlet extends HttpServlet {
    protected void doPost(HttpServletRequest req, HttpServletResponse res)
            throws IOException {
        String correo = req.getParameter("correo");
        String pass   = req.getParameter("password");
        UsuarioDAO dao = new UsuarioDAO();
        Usuario u = dao.buscarPorCorreo(correo);

        if (u != null && PasswordUtil.verify(pass, u.getPasswordHash())) {
            HttpSession ses = req.getSession(true);
            ses.setAttribute("idUsuario", u.getIdUsuario());
            ses.setAttribute("correo", u.getCorreo());
            ses.setAttribute("roles", dao.obtenerRoles(u.getIdUsuario()));
            dao.registrarAuditoria(u.getIdUsuario(), "LOGIN", req.getRemoteAddr());
            // Redirección por rol
            String destino = "/dashboard/" + resolverPanel(ses) + ".jsp";
            res.sendRedirect(req.getContextPath() + destino);
        } else {
            if (u != null) dao.incrementarIntentos(u.getIdUsuario());
            res.sendRedirect(req.getContextPath() + "/login.jsp?error=credenciales");
        }
    }
    private String resolverPanel(HttpSession s) {
        java.util.List<String> roles = (java.util.List<String>) s.getAttribute("roles");
        if (roles.contains("ADMINISTRADOR")) return "admin";
        if (roles.contains("INMOBILIARIA"))  return "inmobiliaria";
        return "cliente";
    }
}
