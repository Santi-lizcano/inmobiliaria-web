package com.inmobiliaria.filtro;

import jakarta.servlet.*;
import jakarta.servlet.annotation.WebFilter;
import jakarta.servlet.http.*;
import java.io.IOException;
import java.util.*;

@WebFilter("/*")
public class AuthFilter implements Filter {

    private static final Set<String> PUBLICAS = Set.of(
        "/", "/index.jsp", "/login.jsp", "/registro.jsp",
        "/LoginServlet", "/RegistroServlet", "/css", "/js", "/img"
    );

    @Override
    public void doFilter(ServletRequest req, ServletResponse res, FilterChain chain)
            throws IOException, ServletException {
        HttpServletRequest r = (HttpServletRequest) req;
        HttpServletResponse s = (HttpServletResponse) res;
        String path = r.getRequestURI().substring(r.getContextPath().length());

        if (esPublica(path)) { chain.doFilter(req, res); return; }

        HttpSession ses = r.getSession(false);
        if (ses == null || ses.getAttribute("idUsuario") == null) {
            s.sendRedirect(r.getContextPath() + "/login.jsp?error=sesion");
            return;
        }

        // Control por rol para /admin/*, /inmobiliaria/*, /cliente/*
        List<String> roles = (List<String>) ses.getAttribute("roles");
        if (path.startsWith("/admin") && !roles.contains("ADMINISTRADOR")) {
            s.sendRedirect(r.getContextPath() + "/acceso-denegado.jsp"); return;
        }
        if (path.startsWith("/inmobiliaria") && !roles.contains("INMOBILIARIA")
                && !roles.contains("ADMINISTRADOR")) {
            s.sendRedirect(r.getContextPath() + "/acceso-denegado.jsp"); return;
        }
        if (path.startsWith("/cliente") && !roles.contains("CLIENTE")
                && !roles.contains("ADMINISTRADOR")) {
            s.sendRedirect(r.getContextPath() + "/acceso-denegado.jsp"); return;
        }
        chain.doFilter(req, res);
    }

    private boolean esPublica(String path) {
        return PUBLICAS.stream().anyMatch(path::startsWith);
    }
}
