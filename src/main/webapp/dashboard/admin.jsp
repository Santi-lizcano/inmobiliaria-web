<%@ page contentType="text/html; charset=UTF-8" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<%
    // Doble verificación de rol
    if (session.getAttribute("idUsuario") == null ||
        session.getAttribute("roles") == null ||
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
<body class="bg-light">

<nav class="navbar navbar-dark bg-dark">
    <div class="container-fluid">
        <span class="navbar-brand fw-bold">🛡️ Panel Administrador</span>
        <div class="d-flex align-items-center">
            <span class="text-white me-3">
                👤 ${sessionScope.nombreCompleto}
                <small class="badge bg-warning text-dark ms-1">ADMIN</small>
            </span>
            <a href="${pageContext.request.contextPath}/LogoutServlet"
               class="btn btn-outline-light btn-sm">Salir</a>
        </div>
    </div>
</nav>

<div class="container my-4">
    <h2 class="mb-1">Bienvenido, ${sessionScope.nombreCompleto}</h2>
    <p class="text-muted">Administra usuarios, catálogos y consulta los reportes del sistema.</p>

    <!-- ===================== ACCESOS RÁPIDOS ===================== -->
    <h4 class="mt-4 mb-3">🔧 Administración</h4>
    <div class="row g-3">

        <div class="col-md-6 col-lg-3">
            <a href="${pageContext.request.contextPath}/AdminServlet?accion=usuarios" 
               class="card text-decoration-none shadow-sm h-100 p-3 text-center">
                <div class="display-5">👥</div>
                <h6 class="mt-2">Usuarios</h6>
                <small class="text-muted">Listar, activar, inactivar</small>
            </a>
        </div>

        <div class="col-md-6 col-lg-3">
            <a href="${pageContext.request.contextPath}/AdminServlet?accion=roles"
               class="card text-decoration-none shadow-sm h-100 p-3 text-center">
                <div class="display-5">🔑</div>
                <h6 class="mt-2">Roles</h6>
                <small class="text-muted">Asignar y revocar</small>
            </a>
        </div>

        <div class="col-md-6 col-lg-3">
            <a href="${pageContext.request.contextPath}/AdminServlet?accion=catalogos"
               class="card text-decoration-none shadow-sm h-100 p-3 text-center">
                <div class="display-5">🗂️</div>
                <h6 class="mt-2">Catálogos</h6>
                <small class="text-muted">Ciudades, tipos, características</small>
            </a>
        </div>

        <div class="col-md-6 col-lg-3">
            <a href="${pageContext.request.contextPath}/AdminServlet?accion=auditoria"
               class="card text-decoration-none shadow-sm h-100 p-3 text-center">
                <div class="display-5">📜</div>
                <h6 class="mt-2">Auditoría</h6>
                <small class="text-muted">Historial de actividad</small>
            </a>
        </div>

    </div>

    <!-- ===================== GESTIÓN DE NEGOCIO ===================== -->
    <h4 class="mt-4 mb-3">🏘️ Gestión</h4>
    <div class="row g-3">

        <div class="col-md-6 col-lg-4">
            <a href="${pageContext.request.contextPath}/PropiedadServlet?accion=listar"
               class="card text-decoration-none shadow-sm h-100 p-3">
                <h6>🏠 Propiedades</h6>
                <small class="text-muted">Ver, crear, editar, dar de baja</small>
            </a>
        </div>

        <div class="col-md-6 col-lg-4">
            <a href="${pageContext.request.contextPath}/CitaServlet?accion=listar"
               class="card text-decoration-none shadow-sm h-100 p-3">
                <h6>📅 Citas</h6>
                <small class="text-muted">Visitas agendadas</small>
            </a>
        </div>

        <div class="col-md-6 col-lg-4">
            <a href="${pageContext.request.contextPath}/SolicitudServlet?accion=listar"
               class="card text-decoration-none shadow-sm h-100 p-3">
                <h6>📝 Solicitudes</h6>
                <small class="text-muted">Compra y arriendo</small>
            </a>
        </div>

    </div>

    <!-- ===================== REPORTES ===================== -->
    <h4 class="mt-4 mb-3">📊 Reportes</h4>
    <div class="row g-3">

        <div class="col-md-6 col-lg-4">
            <a href="${pageContext.request.contextPath}/ReporteServlet?tipo=porCiudad"
               class="card text-decoration-none shadow-sm h-100 p-3">
                <h6>📍 Disponibles por ciudad</h6>
                <small class="text-muted">GROUP BY + HAVING</small>
            </a>
        </div>

        <div class="col-md-6 col-lg-4">
            <a href="${pageContext.request.contextPath}/ReporteServlet?tipo=inmobiliarias"
               class="card text-decoration-none shadow-sm h-100 p-3">
                <h6>🏢 Resumen inmobiliarias</h6>
                <small class="text-muted">LEFT JOIN múltiple</small>
            </a>
        </div>

        <div class="col-md-6 col-lg-4">
            <a href="${pageContext.request.contextPath}/ReporteServlet?tipo=solicitudes"
               class="card text-decoration-none shadow-sm h-100 p-3">
                <h6>📈 Solicitudes por estado</h6>
                <small class="text-muted">GROUP BY</small>
            </a>
        </div>

        <div class="col-md-6 col-lg-4">
            <a href="${pageContext.request.contextPath}/ReporteServlet?tipo=propiedades"
               class="card text-decoration-none shadow-sm h-100 p-3">
                <h6>📋 Propiedades con detalle</h6>
                <small class="text-muted">INNER JOIN 3 tablas</small>
            </a>
        </div>

        <div class="col-md-6 col-lg-4">
            <a href="${pageContext.request.contextPath}/ReporteServlet?tipo=citas"
               class="card text-decoration-none shadow-sm h-100 p-3">
                <h6>📅 Citas con detalle</h6>
                <small class="text-muted">INNER JOIN 5 tablas</small>
            </a>
        </div>

        <div class="col-md-6 col-lg-4">
            <a href="${pageContext.request.contextPath}/reportes/menu.jsp"
               class="card text-decoration-none shadow-sm h-100 p-3 bg-primary text-white">
                <h6>📊 Todos los reportes</h6>
                <small>Ir al menú completo</small>
            </a>
        </div>

    </div>

    <!-- ===================== AYUDA ===================== -->
    <div class="alert alert-info mt-5">
        <strong>ℹ️ Recuerda:</strong> como administrador tienes acceso total.
        El filtro de rutas y las verificaciones internas de cada servlet
        validan tu rol en cada petición.
    </div>

</div>

<script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.2/dist/js/bootstrap.bundle.min.js"></script>
</body>
</html>
