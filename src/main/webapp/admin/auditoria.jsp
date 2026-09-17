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
    <title>Auditoría</title>
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.2/dist/css/bootstrap.min.css" rel="stylesheet">
    <link rel="stylesheet" href="${pageContext.request.contextPath}/css/estilos.css">
</head>
<body class="bg-light">

<nav class="navbar navbar-dark bg-dark">
    <div class="container-fluid">
        <a class="navbar-brand" href="${pageContext.request.contextPath}/dashboard/admin.jsp">
            🛡️ Panel Admin · Auditoría
        </a>
        <a href="${pageContext.request.contextPath}/LogoutServlet"
           class="btn btn-outline-light btn-sm">Salir</a>
    </div>
</nav>

<div class="container my-4">

    <div class="d-flex justify-content-between align-items-center mb-3">
        <h2>📜 Auditoría del sistema</h2>
        <a href="${pageContext.request.contextPath}/dashboard/admin.jsp"
           class="btn btn-outline-secondary btn-sm">← Volver al panel</a>
    </div>

    <p class="text-muted">
        Últimos 200 eventos registrados. Cada vez que un usuario inicia sesión,
        crea una propiedad, agenda una cita o cambia un estado, queda registrado aquí.
    </p>

    <div class="card card-auth">
        <div class="card-body p-0">
            <div class="table-responsive">
                <table class="table table-sm table-hover align-middle mb-0">
                    <thead class="table-dark">
                        <tr>
                            <th>Fecha</th>
                            <th>Usuario</th>
                            <th>Acción</th>
                            <th>Detalle</th>
                            <th>IP</th>
                        </tr>
                    </thead>
                    <tbody>
                        <c:forEach var="a" items="${auditoria}">
                            <tr>
                                <td><small>${a[0]}</small></td>
                                <td>${a[4]}</td>
                                <td>
                                    <c:choose>
                                        <c:when test="${a[1] == 'LOGIN_OK'}">
                                            <span class="badge bg-success">${a[1]}</span>
                                        </c:when>
                                        <c:when test="${a[1] == 'LOGIN_FALLIDO'}">
                                            <span class="badge bg-warning text-dark">${a[1]}</span>
                                        </c:when>
                                        <c:when test="${a[1] == 'LOGOUT'}">
                                            <span class="badge bg-secondary">${a[1]}</span>
                                        </c:when>
                                        <c:when test="${a[1] == 'BLOQUEO'}">
                                            <span class="badge bg-danger">${a[1]}</span>
                                        </c:when>
                                        <c:otherwise>
                                            <span class="badge bg-info text-dark">${a[1]}</span>
                                        </c:otherwise>
                                    </c:choose>
                                </td>
                                <td><small>${a[2]}</small></td>
                                <td><small class="text-muted">${a[3]}</small></td>
                            </tr>
                        </c:forEach>
                    </tbody>
                </table>
            </div>
        </div>
    </div>

    <c:if test="${empty auditoria}">
        <div class="alert alert-info mt-3">Aún no hay registros de auditoría.</div>
    </c:if>

</div>
</body>
</html>
