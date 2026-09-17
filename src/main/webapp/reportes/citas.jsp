<%@ page contentType="text/html; charset=UTF-8" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<!DOCTYPE html>
<html lang="es">
<head>
    <meta charset="UTF-8">
    <title>Reporte: Citas con detalle</title>
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.2/dist/css/bootstrap.min.css" rel="stylesheet">
</head>
<body>
<nav class="navbar navbar-dark bg-dark">
    <div class="container">
        <span class="navbar-brand">📊 Citas con detalle</span>
        <a href="${pageContext.request.contextPath}/reportes/menu.jsp"
           class="btn btn-outline-light btn-sm">Volver</a>
    </div>
</nav>

<div class="container my-4">
    <h3>Citas · Cliente · Propiedad · Inmobiliaria</h3>
    <p class="text-muted">
        Consulta: <code>INNER JOIN usuario, perfil, propiedad, inmobiliaria</code>
    </p>

    <table class="table table-striped">
        <thead class="table-primary">
            <tr>
                <th>#</th>
                <th>Fecha y hora</th>
                <th>Cliente</th>
                <th>Correo</th>
                <th>Propiedad</th>
                <th>Inmobiliaria</th>
                <th>Estado</th>
            </tr>
        </thead>
        <tbody>
            <c:forEach var="f" items="${datos}">
                <tr>
                    <td>${f.id_cita}</td>
                    <td>${f.fecha_hora}</td>
                    <td>${f.cliente}</td>
                    <td>${f.correo_cliente}</td>
                    <td>${f.propiedad}</td>
                    <td>${f.inmobiliaria}</td>
                    <td><span class="badge bg-secondary">${f.estado}</span></td>
                </tr>
            </c:forEach>
        </tbody>
    </table>

    <c:if test="${empty datos}">
        <div class="alert alert-info">No hay datos.</div>
    </c:if>
</div>
</body>
</html>
