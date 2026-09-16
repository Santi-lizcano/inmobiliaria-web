<%@ page contentType="text/html; charset=UTF-8" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<%
    // Doble verificación (además del filtro)
    if (session.getAttribute("idUsuario") == null ||
        !((java.util.List<String>) session.getAttribute("roles")).contains("ADMINISTRADOR")) {
        response.sendRedirect(request.getContextPath() + "/acceso-denegado.jsp");
        return;
    }
%>
<!DOCTYPE html>
<html lang="es">
<head>
    <meta charset="UTF-8">
    <title>Panel Administrador</title>
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.2/dist/css/bootstrap.min.css" rel="stylesheet">
</head>
<body>
<nav class="navbar navbar-dark bg-dark">
    <div class="container">
        <span class="navbar-brand">Panel Administrador</span>
        <a href="${pageContext.request.contextPath}/LogoutServlet" class="btn btn-outline-light btn-sm">Cerrar sesión</a>
    </div>
</nav>

<div class="container my-4">
    <h2>Bienvenido, ${sessionScope.correo}</h2>

    <div class="row g-3 mt-3">
        <div class="col-md-3">
            <a href="${pageContext.request.contextPath}/admin/usuarios.jsp" class="card text-decoration-none p-3 shadow-sm">
                👥 Gestionar usuarios
            </a>
        </div>
        <div class="col-md-3">
            <a href="${pageContext.request.contextPath}/admin/roles.jsp" class="card text-decoration-none p-3 shadow-sm">
                🔑 Asignar roles
            </a>
        </div>
        <div class="col-md-3">
            <a href="${pageContext.request.contextPath}/admin/catalogos.jsp" class="card text-decoration-none p-3 shadow-sm">
                🗂️ Catálogos
            </a>
        </div>
        <div class="col-md-3">
            <a href="${pageContext.request.contextPath}/ReporteServlet" class="card text-decoration-none p-3 shadow-sm">
                📊 Reportes
            </a>
        </div>
    </div>
</div>
</body>
</html>
