<%@ page contentType="text/html; charset=UTF-8" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<%
    if (session.getAttribute("idUsuario") == null ||
        session.getAttribute("roles") == null ||
        !((java.util.List<String>) session.getAttribute("roles")).contains("INMOBILIARIA")) {
        response.sendRedirect(request.getContextPath() + "/acceso-denegado.jsp");
        return;
    }
%>
<!DOCTYPE html>
<html lang="es">
<head>
    <meta charset="UTF-8">
    <title>Panel Inmobiliaria</title>
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.2/dist/css/bootstrap.min.css" rel="stylesheet">
</head>
<body class="bg-light">

<nav class="navbar navbar-dark bg-primary">
    <div class="container-fluid">
        <span class="navbar-brand fw-bold">🏢 Panel Inmobiliaria</span>
        <div class="d-flex align-items-center">
            <span class="text-white me-3">
                👤 ${sessionScope.nombreCompleto}
                <small class="badge bg-light text-primary ms-1">AGENTE</small>
            </span>
            <a href="${pageContext.request.contextPath}/LogoutServlet"
               class="btn btn-outline-light btn-sm">Salir</a>
        </div>
    </div>
</nav>

<div class="container my-4">
    <h2 class="mb-1">Hola, ${sessionScope.nombreCompleto}</h2>
    <p class="text-muted">
        Administra tu catálogo, atiende las visitas y aprueba las solicitudes de tus clientes.
    </p>

    <!-- ===================== GESTIÓN DE PROPIEDADES ===================== -->
    <h4 class="mt-4 mb-3">🏘️ Propiedades</h4>
    <div class="row g-3">

        <div class="col-md-6 col-lg-3">
            <a href="${pageContext.request.contextPath}/PropiedadServlet?accion=listar"
               class="card text-decoration-none shadow-sm h-100 p-3 text-center">
                <div class="display-5">🏠</div>
                <h6 class="mt-2">Mis propiedades</h6>
                <small class="text-muted">Listado completo</small>
            </a>
        </div>

        <div class="col-md-6 col-lg-3">
            <a href="${pageContext.request.contextPath}/PropiedadServlet?accion=formularioNuevo"
               class="card text-decoration-none shadow-sm h-100 p-3 text-center bg-success text-white">
                <div class="display-5">➕</div>
                <h6 class="mt-2">Publicar nueva</h6>
                <small>Con imágenes y características</small>
            </a>
        </div>

        <div class="col-md-6 col-lg-3">
            <a href="${pageContext.request.contextPath}/PropiedadServlet?accion=listar&estado=DISPONIBLE"
               class="card text-decoration-none shadow-sm h-100 p-3 text-center">
                <div class="display-5">✅</div>
                <h6 class="mt-2">Disponibles</h6>
                <small class="text-muted">Solo activas</small>
            </a>
        </div>

        <div class="col-md-6 col-lg-3">
            <a href="${pageContext.request.contextPath}/PropiedadServlet?accion=listar&estado=INACTIVA"
               class="card text-decoration-none shadow-sm h-100 p-3 text-center">
                <div class="display-5">🚫</div>
                <h6 class="mt-2">Dadas de baja</h6>
                <small class="text-muted">Reactivar o editar</small>
            </a>
        </div>

    </div>

    <!-- ===================== CITAS Y SOLICITUDES ===================== -->
    <h4 class="mt-4 mb-3">📅 Operación</h4>
    <div class="row g-3">

        <div class="col-md-6 col-lg-4">
            <a href="${pageContext.request.contextPath}/CitaServlet?accion=listar"
               class="card text-decoration-none shadow-sm h-100 p-3">
                <h6>📅 Citas agendadas</h6>
                <small class="text-muted">Confirmar, marcar realizada o cancelar</small>
            </a>
        </div>

        <div class="col-md-6 col-lg-4">
            <a href="${pageContext.request.contextPath}/SolicitudServlet?accion=listar"
               class="card text-decoration-none shadow-sm h-100 p-3">
                <h6>📝 Solicitudes recibidas</h6>
                <small class="text-muted">Revisar documentos y aprobar/rechazar</small>
            </a>
        </div>

        <div class="col-md-6 col-lg-4">
            <a href="${pageContext.request.contextPath}/ReporteServlet?tipo=porCiudad"
               class="card text-decoration-none shadow-sm h-100 p-3">
                <h6>📊 Reporte por ciudad</h6>
                <small class="text-muted">Disponibilidad consolidada</small>
            </a>
        </div>

    </div>

    <!-- ===================== REPORTES PROPIOS ===================== -->
    <h4 class="mt-4 mb-3">📊 Mis reportes</h4>
    <div class="row g-3">

        <div class="col-md-6 col-lg-4">
            <a href="${pageContext.request.contextPath}/ReporteServlet?tipo=propiedades"
               class="card text-decoration-none shadow-sm h-100 p-3">
                <h6>📋 Propiedades con detalle</h6>
                <small class="text-muted">Con ciudad, tipo e inmobiliaria</small>
            </a>
        </div>

        <div class="col-md-6 col-lg-4">
            <a href="${pageContext.request.contextPath}/ReporteServlet?tipo=citas"
               class="card text-decoration-none shadow-sm h-100 p-3">
                <h6>📅 Citas con detalle</h6>
                <small class="text-muted">Con cliente y propiedad</small>
            </a>
        </div>

        <div class="col-md-6 col-lg-4">
            <a href="${pageContext.request.contextPath}/ReporteServlet?tipo=caracteristicas"
               class="card text-decoration-none shadow-sm h-100 p-3">
                <h6>🏷️ Características</h6>
                <small class="text-muted">N:M por propiedad</small>
            </a>
        </div>

    </div>

    <div class="alert alert-primary mt-5">
        <strong>💡 Consejo:</strong> mantén tus propiedades con imágenes actualizadas
        y responde las solicitudes de cita cuanto antes para mejorar la conversión.
    </div>

</div>

<script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.2/dist/js/bootstrap.bundle.min.js"></script>
</body>
</html>
