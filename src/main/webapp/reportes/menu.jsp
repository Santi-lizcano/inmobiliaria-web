<%@ page contentType="text/html; charset=UTF-8" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<!DOCTYPE html>
<html lang="es">
<head>
    <meta charset="UTF-8">
    <title>Reportes</title>
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.2/dist/css/bootstrap.min.css" rel="stylesheet">
    <link rel="stylesheet" href="${pageContext.request.contextPath}/css/estilos.css">
</head>
<body>
<nav class="navbar navbar-dark bg-dark">
    <div class="container">
        <a class="navbar-brand" href="${pageContext.request.contextPath}/">🏠 Inmobiliaria UTS · Reportes</a>
        <div>
            <c:if test="${sessionScope.roles.contains('ADMINISTRADOR')}">
                <a href="${pageContext.request.contextPath}/dashboard/admin.jsp"
                   class="btn btn-outline-light btn-sm">Panel</a>
            </c:if>
            <c:if test="${sessionScope.roles.contains('INMOBILIARIA')}">
                <a href="${pageContext.request.contextPath}/dashboard/inmobiliaria.jsp"
                   class="btn btn-outline-light btn-sm">Panel</a>
            </c:if>
            <a href="${pageContext.request.contextPath}/LogoutServlet"
               class="btn btn-outline-light btn-sm">Salir</a>
        </div>
    </div>
</nav>

<div class="container my-5">
    <h2 class="mb-4">📊 Reportes del sistema</h2>

    <div class="row g-3">

        <div class="col-md-6 col-lg-4">
            <a class="card text-decoration-none p-4 shadow-sm h-100"
               href="${pageContext.request.contextPath}/ReporteServlet?tipo=propiedades">
                <h5>🏘️ Propiedades con detalle</h5>
                <small class="text-muted">INNER JOIN: propiedad + ciudad + tipo + inmobiliaria</small>
            </a>
        </div>

        <div class="col-md-6 col-lg-4">
            <a class="card text-decoration-none p-4 shadow-sm h-100"
               href="${pageContext.request.contextPath}/ReporteServlet?tipo=citas">
                <h5>📅 Citas con cliente y propiedad</h5>
                <small class="text-muted">INNER JOIN con 5 tablas</small>
            </a>
        </div>

        <div class="col-md-6 col-lg-4">
            <a class="card text-decoration-none p-4 shadow-sm h-100"
               href="${pageContext.request.contextPath}/ReporteServlet?tipo=caracteristicas">
                <h5>🏷️ Características por propiedad</h5>
                <small class="text-muted">Relación N:M con GROUP_CONCAT</small>
            </a>
        </div>

        <div class="col-md-6 col-lg-4">
            <a class="card text-decoration-none p-4 shadow-sm h-100"
               href="${pageContext.request.contextPath}/ReporteServlet?tipo=sinCitas">
                <h5>🚫 Propiedades sin citas</h5>
                <small class="text-muted">LEFT JOIN + IS NULL</small>
            </a>
        </div>

        <div class="col-md-6 col-lg-4">
            <a class="card text-decoration-none p-4 shadow-sm h-100"
               href="${pageContext.request.contextPath}/ReporteServlet?tipo=porCiudad">
                <h5>📍 Disponibles por ciudad</h5>
                <small class="text-muted">GROUP BY + HAVING</small>
            </a>
        </div>

        <div class="col-md-6 col-lg-4">
            <a class="card text-decoration-none p-4 shadow-sm h-100"
               href="${pageContext.request.contextPath}/ReporteServlet?tipo=solicitudes">
                <h5>📝 Solicitudes por estado</h5>
                <small class="text-muted">GROUP BY + COUNT</small>
            </a>
        </div>

        <c:if test="${sessionScope.roles.contains('ADMINISTRADOR')}">
            <div class="col-md-6 col-lg-4">
                <a class="card text-decoration-none p-4 shadow-sm h-100"
                   href="${pageContext.request.contextPath}/ReporteServlet?tipo=inmobiliarias">
                    <h5>🏢 Resumen por inmobiliaria</h5>
                    <small class="text-muted">LEFT JOIN + múltiples COUNT</small>
                </a>
            </div>
        </c:if>

    </div>
</div>
</body>
</html>
