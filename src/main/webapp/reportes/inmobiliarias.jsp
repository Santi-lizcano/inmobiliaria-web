<%@ page contentType="text/html; charset=UTF-8" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<!DOCTYPE html>
<html lang="es">
<head>
    <meta charset="UTF-8">
    <title>Reporte: Resumen por inmobiliaria</title>
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.2/dist/css/bootstrap.min.css" rel="stylesheet">
</head>
<body>
<nav class="navbar navbar-dark bg-dark">
    <div class="container">
        <span class="navbar-brand">📊 Resumen por inmobiliaria</span>
        <a href="${pageContext.request.contextPath}/reportes/menu.jsp"
           class="btn btn-outline-light btn-sm">Volver</a>
    </div>
</nav>

<div class="container my-4">
    <h3>Actividad por inmobiliaria</h3>
    <p class="text-muted">
        Consulta: <code>LEFT JOIN propiedad, cita, solicitud</code> +
        <code>COUNT DISTINCT</code> agrupado por inmobiliaria.
    </p>

    <table class="table table-striped">
        <thead class="table-primary">
            <tr>
                <th>Inmobiliaria</th>
                <th>Propiedades</th>
                <th>Citas</th>
                <th>Solicitudes</th>
            </tr>
        </thead>
        <tbody>
            <c:forEach var="f" items="${datos}">
                <tr>
                    <td>${f.razon_social}</td>
                    <td><span class="badge bg-primary">${f.propiedades}</span></td>
                    <td><span class="badge bg-info text-dark">${f.citas}</span></td>
                    <td><span class="badge bg-warning text-dark">${f.solicitudes}</span></td>
                </tr>
            </c:forEach>
        </tbody>
    </table>
</div>
</body>
</html>
