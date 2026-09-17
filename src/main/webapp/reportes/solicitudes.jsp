<%@ page contentType="text/html; charset=UTF-8" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<!DOCTYPE html>
<html lang="es">
<head>
    <meta charset="UTF-8">
    <title>Reporte: Solicitudes por estado</title>
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.2/dist/css/bootstrap.min.css" rel="stylesheet">
    <link rel="stylesheet" href="${pageContext.request.contextPath}/css/estilos.css">
</head>
<body>
<nav class="navbar navbar-dark bg-dark">
    <div class="container">
        <span class="navbar-brand">📊 Solicitudes por estado</span>
        <a href="${pageContext.request.contextPath}/reportes/menu.jsp"
           class="btn btn-outline-light btn-sm">Volver</a>
    </div>
</nav>

<div class="container my-4">
    <h3>Solicitudes agrupadas por estado</h3>
    <p class="text-muted">Consulta: <code>GROUP BY s.estado</code></p>

    <table class="table table-striped">
        <thead class="table-primary">
            <tr>
                <th>Estado</th>
                <th>Total</th>
            </tr>
        </thead>
        <tbody>
            <c:forEach var="f" items="${datos}">
                <tr>
                    <td>
                        <c:choose>
                            <c:when test="${f.estado == 'RADICADA'}">
                                <span class="badge bg-warning text-dark">RADICADA</span>
                            </c:when>
                            <c:when test="${f.estado == 'EN_REVISION'}">
                                <span class="badge bg-info text-dark">EN REVISIÓN</span>
                            </c:when>
                            <c:when test="${f.estado == 'APROBADA'}">
                                <span class="badge bg-success">APROBADA</span>
                            </c:when>
                            <c:when test="${f.estado == 'RECHAZADA'}">
                                <span class="badge bg-danger">RECHAZADA</span>
                            </c:when>
                            <c:otherwise>
                                <span class="badge bg-secondary">${f.estado}</span>
                            </c:otherwise>
                        </c:choose>
                    </td>
                    <td><strong>${f.total}</strong></td>
                </tr>
            </c:forEach>
        </tbody>
    </table>
</div>
</body>
</html>
