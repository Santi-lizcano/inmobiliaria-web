<%@ page contentType="text/html; charset=UTF-8" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<!DOCTYPE html>
<html lang="es">
<head>
    <meta charset="UTF-8">
    <title>Reporte: Propiedades con detalle</title>
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.2/dist/css/bootstrap.min.css" rel="stylesheet">
    <link rel="stylesheet" href="${pageContext.request.contextPath}/css/estilos.css">
</head>
<body>
<nav class="navbar navbar-dark bg-dark">
    <div class="container">
        <span class="navbar-brand">📊 Propiedades con detalle</span>
        <a href="${pageContext.request.contextPath}/reportes/menu.jsp"
           class="btn btn-outline-light btn-sm">Volver</a>
    </div>
</nav>

<div class="container my-4">
    <h3>Propiedades · Ciudad · Tipo · Inmobiliaria</h3>
    <p class="text-muted">
        Consulta: <code>INNER JOIN ciudad, tipo_propiedad, inmobiliaria</code>
    </p>

    <table class="table table-striped">
        <thead class="table-primary">
            <tr>
                <th>#</th>
                <th>Título</th>
                <th>Ciudad</th>
                <th>Tipo</th>
                <th>Inmobiliaria</th>
                <th>Precio</th>
                <th>Estado</th>
            </tr>
        </thead>
        <tbody>
            <c:forEach var="f" items="${datos}">
                <tr>
                    <td>${f.id_propiedad}</td>
                    <td>${f.titulo}</td>
                    <td>${f.ciudad}</td>
                    <td>${f.tipo}</td>
                    <td>${f.razon_social}</td>
                    <td>$ ${f.precio}</td>
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
