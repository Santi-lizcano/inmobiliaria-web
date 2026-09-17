<%@ page contentType="text/html; charset=UTF-8" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<!DOCTYPE html>
<html lang="es">
<head>
    <meta charset="UTF-8">
    <title>Reporte: Características por propiedad</title>
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.2/dist/css/bootstrap.min.css" rel="stylesheet">
    <link rel="stylesheet" href="${pageContext.request.contextPath}/css/estilos.css">
</head>
<body>
<nav class="navbar navbar-dark bg-dark">
    <div class="container">
        <span class="navbar-brand">📊 Características por propiedad (N:M)</span>
        <a href="${pageContext.request.contextPath}/reportes/menu.jsp"
           class="btn btn-outline-light btn-sm">Volver</a>
    </div>
</nav>

<div class="container my-4">
    <h3>Propiedad · Características</h3>
    <p class="text-muted">
        Consulta: <code>propiedad_caracteristica</code> con <code>GROUP_CONCAT</code>
        (relación muchos a muchos).
    </p>

    <table class="table table-striped">
        <thead class="table-primary">
            <tr>
                <th>#</th>
                <th>Título</th>
                <th>Características</th>
            </tr>
        </thead>
        <tbody>
            <c:forEach var="f" items="${datos}">
                <tr>
                    <td>${f.id_propiedad}</td>
                    <td>${f.titulo}</td>
                    <td>
                        <c:forEach var="car" items="${f.caracteristicas.split(', ')}">
                            <span class="badge bg-info text-dark me-1">${car}</span>
                        </c:forEach>
                    </td>
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
