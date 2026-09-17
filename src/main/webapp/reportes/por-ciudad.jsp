<%@ page contentType="text/html; charset=UTF-8" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<!DOCTYPE html>
<html lang="es">
<head>
    <meta charset="UTF-8">
    <title>Reporte: Disponibles por ciudad</title>
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.2/dist/css/bootstrap.min.css" rel="stylesheet">
</head>
<body>
<nav class="navbar navbar-dark bg-dark">
    <div class="container">
        <span class="navbar-brand">📊 Propiedades disponibles por ciudad</span>
        <a href="${pageContext.request.contextPath}/reportes/menu.jsp"
           class="btn btn-outline-light btn-sm">Volver</a>
    </div>
</nav>

<div class="container my-4">
    <h3>Disponibles por ciudad</h3>
    <p class="text-muted">
        Consulta: <code>GROUP BY c.nombre</code> +
        <code>HAVING COUNT(p.id_propiedad) &gt;= 1</code>.
    </p>

    <table class="table table-striped">
        <thead class="table-primary">
            <tr>
                <th>Ciudad</th>
                <th>Total disponibles</th>
            </tr>
        </thead>
        <tbody>
            <c:forEach var="f" items="${datos}">
                <tr>
                    <td>${f.ciudad}</td>
                    <td><span class="badge bg-success">${f.total}</span></td>
                </tr>
            </c:forEach>
        </tbody>
    </table>

    <c:if test="${empty datos}">
        <div class="alert alert-info">
            No hay ciudades con propiedades disponibles.
        </div>
    </c:if>
</div>
</body>
</html>
