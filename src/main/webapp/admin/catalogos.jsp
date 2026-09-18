<%@ page contentType="text/html; charset=UTF-8" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<%
    if (session.getAttribute("roles") == null ||
        !((java.util.List<String>) session.getAttribute("roles")).contains("ADMINISTRADOR")) {
        response.sendRedirect(request.getContextPath() + "/acceso-denegado.jsp");
        return;
    }
%>
<!DOCTYPE html>
<html lang="es">
<head>
    <meta charset="UTF-8">
    <title>Catálogos</title>
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.2/dist/css/bootstrap.min.css" rel="stylesheet">
</head>
<body class="bg-light">

<nav class="navbar navbar-dark bg-dark">
    <div class="container-fluid">
        <a class="navbar-brand" href="${pageContext.request.contextPath}/dashboard/admin.jsp">
            🛡️ Panel Admin · Catálogos
        </a>
        <a href="${pageContext.request.contextPath}/LogoutServlet"
           class="btn btn-outline-light btn-sm">Salir</a>
    </div>
</nav>

<div class="container my-4">

    <div class="d-flex justify-content-between align-items-center mb-3">
        <h2>🗂️ Catálogos del sistema</h2>
        <a href="${pageContext.request.contextPath}/dashboard/admin.jsp"
           class="btn btn-outline-secondary btn-sm">← Volver al panel</a>
    </div>

    <div class="row g-4">

        <%-- CIUDADES --%>
        <div class="col-md-4">
            <div class="card shadow-sm h-100">
                <div class="card-header bg-primary text-white">
                    📍 Ciudades (${ciudades.size()})
                </div>
                <ul class="list-group list-group-flush" style="max-height: 500px; overflow-y:auto;">
                    <c:forEach var="c" items="${ciudades}">
                        <li class="list-group-item d-flex justify-content-between">
                            <span>${c[1]}</span>
                            <small class="text-muted">ID ${c[0]}</small>
                        </li>
                    </c:forEach>
                    <c:if test="${empty ciudades}">
                        <li class="list-group-item text-muted">Sin ciudades registradas</li>
                    </c:if>
                </ul>
            </div>
        </div>

        <%-- TIPOS DE PROPIEDAD --%>
        <div class="col-md-4">
            <div class="card shadow-sm h-100">
                <div class="card-header bg-success text-white">
                    🏘️ Tipos de propiedad (${tipos.size()})
                </div>
                <ul class="list-group list-group-flush" style="max-height: 500px; overflow-y:auto;">
                    <c:forEach var="t" items="${tipos}">
                        <li class="list-group-item d-flex justify-content-between">
                            <span>${t[1]}</span>
                            <small class="text-muted">ID ${t[0]}</small>
                        </li>
                    </c:forEach>
                    <c:if test="${empty tipos}">
                        <li class="list-group-item text-muted">Sin tipos registrados</li>
                    </c:if>
                </ul>
            </div>
        </div>

        <%-- CARACTERÍSTICAS --%>
        <div class="col-md-4">
            <div class="card shadow-sm h-100">
                <div class="card-header bg-info text-dark">
                    🏷️ Características (${caracteristicas.size()})
                </div>
                <ul class="list-group list-group-flush" style="max-height: 500px; overflow-y:auto;">
                    <c:forEach var="ca" items="${caracteristicas}">
                        <li class="list-group-item d-flex justify-content-between">
                            <span>${ca[1]}</span>
                            <small class="text-muted">ID ${ca[0]}</small>
                        </li>
                    </c:forEach>
                    <c:if test="${empty caracteristicas}">
                        <li class="list-group-item text-muted">Sin características registradas</li>
                    </c:if>
                </ul>
            </div>
        </div>

    </div>

    <div class="alert alert-secondary mt-4">
        <strong>📝 Nota:</strong> los catálogos se cargan desde la base de datos.
        Si necesitas agregar una ciudad, tipo o característica nueva, ejecuta el INSERT
        directamente en la BD (por simplicidad del parcial se manejan como datos maestros).
    </div>

</div>
</body>
</html>
