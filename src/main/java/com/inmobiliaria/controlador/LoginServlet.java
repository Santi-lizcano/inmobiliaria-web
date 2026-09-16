package com.inmobiliaria.controlador;

import com.inmobiliaria.dao.UsuarioDAO;
import com.inmobiliaria.modelo.Usuario;
import com.inmobiliaria.util.PasswordUtil;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.*;

import java.io.IOException;

@WebServlet("/LoginServlet")
public class LoginServlet extends HttpServlet {

    private final UsuarioDAO usuarioDAO = new UsuarioDAO();

    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse res)
            throws IOException, jakarta.servlet.ServletException {

        req.setCharacterEncoding("UTF-8");
        String correo = req.getParameter("correo");
        String pass   = req.getParameter("password");

        try {
            Usuario u = usuarioDAO.buscarPorCorreo(correo);

            // 1) Usuario no existe
            if (u == null) {
                res.sendRedirect(req.getContextPath() + "/login.jsp?error=credenciales");
                return;
            }

            // 2) Cuenta bloqueada
            if ("BLOQUEADO".equals(u.getEstado())) {
                res.sendRedirect(req.getContextPath() + "/login.jsp?error=bloqueado");
                return;
            }

            // 3) Cuenta inactiva
            if ("INACTIVO".equals(u.getEstado())) {
                res.sendRedirect(req.getContextPath() + "/login.jsp?error=inactivo");
                return;
            }

            // 4) Contraseña incorrecta → incrementar intentos
            if (!PasswordUtil.verify(pass, u.getPasswordHash())) {
                usuarioDAO.incrementarIntentos(u.getIdUsuario());
                usuarioDAO.registrarAuditoria(u.getIdUsuario(), "LOGIN_FALLIDO",
                        "Contraseña incorrecta", req.getRemoteAddr());
                res.sendRedirect(req.getContextPath() + "/login.jsp?error=credenciales");
                return;
            }

            // 5) Login exitoso → sesión + roles + reset + auditoría
            usuarioDAO.resetearIntentos(u.getIdUsuario());
            usuarioDAO.registrarAuditoria(u.getIdUsuario(), "LOGIN_OK",
                    "Ingreso exitoso", req.getRemoteAddr());

            HttpSession ses = req.getSession(true);
            ses.setAttribute("idUsuario", u.getIdUsuario());
            ses.setAttribute("correo", u.getCorreo());
            ses.setAttribute("nombreCompleto", u.getNombreCompleto());
            ses.setAttribute("roles", usuarioDAO.obtenerRoles(u.getIdUsuario()));

            // Redirección al panel correcto
            String panel = resolverPanel(ses);
            res.sendRedirect(req.getContextPath() + "/dashboard/" + panel + ".jsp");

        } catch (Exception e) {
            e.printStackTrace();
            res.sendRedirect(req.getContextPath() + "/login.jsp?error=servidor");
        }
    }

    @SuppressWarnings("unchecked")
    private String resolverPanel(HttpSession ses) {
        java.util.List<String> roles =
                (java.util.List<String>) ses.getAttribute("roles");
        if (roles.contains("ADMINISTRADOR")) return "admin";
        if (roles.contains("INMOBILIARIA"))  return "inmobiliaria";
        return "cliente";
    }
}
