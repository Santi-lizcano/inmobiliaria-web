<%@ page contentType="text/html; charset=UTF-8" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<%
    if (session.getAttribute("idUsuario") == null ||
        session.getAttribute("roles") == null ||
        !((java.util.List<String>) session.getAttribute("roles")).contains("CLIENTE")) {
        response.sendRedirect(request.getContextPath() + "/acceso-denegado.jsp");
        return;
    }
%>
<!DOCTYPE html>
<html lang="es">
<head>
    <meta charset="UTF-8">
    <title>Mi panel</title>
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.2/dist/css/bootstrap.min.css" rel="stylesheet">
</head>
<body class="bg-light">

<nav class="navbar navbar-dark bg-success">
    <div class="container-fluid">
        <span class="navbar-brand fw-bold">🏠 Mi panel</span>
        <div class="d-flex align-items-center">
            <span class="text-white me-3">
                👤 ${sessionScope.nombreCompleto}
                <small class="badge bg-light text-success ms-1">CLIENTE</small>
            </span>
            <a href="${pageContext.request.contextPath}/LogoutServlet"
               class="btn btn-outline-light btn-sm">Salir</a>
        </div>
    </div>
</nav>

<div class="container my-4">
    <h2 class="mb-1">Hola, ${sessionScope.nombreCompleto}</h2>
    <p class="text-muted">
        Explora el catálogo, agenda visitas y haz seguimiento a tus trámites.
    </p>

    <!-- ===================== BUSCAR PROPIEDADES ===================== -->
    <h4 class="mt-4 mb-3">🔍 Encuentra tu inmueble</h4>
    <div class="row g-3">

        <div class="col-md-6 col-lg-3">
            <a href="${pageContext.request.contextPath}/PropiedadServlet?accion=listar"
               class="card text-decoration-none shadow-sm h-100 p-3 text-center">
                <div class="display-5">🏘️</div>
                <h6 class="mt-2">Ver catálogo</h6>
                <small class="text-muted">Todas las propiedades</small>
            </a>
        </div>

        <div class="col-md-6 col-lg-3">
            <a href="${pageContext.request.contextPath}/PropiedadServlet?accion=listar&estado=DISPONIBLE"
               class="card text-decoration-none shadow-sm h-100 p-3 text-center">
                <div class="display-5">✅</div>
                <h6 class="mt-2">Solo disponibles</h6>
                <small class="text-muted">Listas para visitar</small>
            </a>
        </div>

        <div class="col-md-6 col-lg-3">
            <a href="${pageContext.request.contextPath}/PropiedadServlet?accion=listar&tipo=Casa"
               class="card text-decoration-none shadow-sm h-100 p-3 text-center">
                <div class="display-5">🏡</div>
                <h6 class="mt-2">Casas</h6>
                <small class="text-muted">Filtrar por tipo</small>
            </a>
        </div>

        <div class="col-md-6 col-lg-3">
            <a href="${pageContext.request.contextPath}/PropiedadServlet?accion=listar&tipo=Apartamento"
               class="card text-decoration-none shadow-sm h-100 p-3 text-center">
                <div class="display-5">🏢</div>
                <h6 class="mt-2">Apartamentos</h6>
                <small class="text-muted">Filtrar por tipo</small>
            </a>
        </div>

    </div>

    <!-- ===================== MIS TRÁMITES ===================== -->
    <h4 class="mt-4 mb-3">📋 Mis trámites</h4>
    <div class="row g-3">

        <div class="col-md-6 col-lg-4">
            <a href="${pageContext.request.contextPath}/CitaServlet?accion=listar"
               class="card text-decoration-none shadow-sm h-100 p-3">
                <h6>📅 Mis citas</h6>
                <small class="text-muted">Visitas que he agendado</small>
            </a>
        </div>

        <div class="col-md-6 col-lg-4">
            <a href="${pageContext.request.contextPath}/SolicitudServlet?accion=listar"
               class="card text-decoration-none shadow-sm h-100 p-3">
                <h6>📝 Mis solicitudes</h6>
                <small class="text-muted">Compra o arriendo en curso</small>
            </a>
        </div>

        <div class="col-md-6 col-lg-4">
            <a href="${pageContext.request.contextPath}/cliente/favoritos.jsp"
               class="card text-decoration-none shadow-sm h-100 p-3">
                <h6>❤️ Favoritos</h6>
                <small class="text-muted">Propiedades que guardé</small>
            </a>
        </div>

    </div>

    <!-- ===================== MI CUENTA ===================== -->
    <h4 class="mt-4 mb-3">⚙️ Mi cuenta</h4>
    <div class="row g-3">

        <div class="col-md-6 col-lg-4">
            <a href="${pageContext.request.contextPath}/cliente/perfil.jsp"
               class="card text-decoration-none shadow-sm h-100 p-3">
                <h6>👤 Mi perfil</h6>
                <small class="text-muted">Actualizar datos personales</small>
            </a>
        </div>

        <div class="col-md-6 col-lg-4">
            <a href="${pageContext.request.contextPath}/cliente/cambiar-password.jsp"
               class="card text-decoration-none shadow-sm h-100 p-3">
                <h6>🔒 Cambiar contraseña</h6>
                <small class="text-muted">Seguridad de la cuenta</small>
            </a>
        </div>

    </div>

    <div class="alert alert-success mt-5">
        <strong>🎯 Tip:</strong> agrega propiedades a favoritos y agenda visitas
        en los horarios disponibles para que la inmobiliaria te confirme rápido.
    </div>

</div>

<script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.2/dist/js/bootstrap.bundle.min.js"></script>
</body>
</html>
