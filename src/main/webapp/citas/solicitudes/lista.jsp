<%@ page contentType="text/html; charset=UTF-8" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<!DOCTYPE html>
<html lang="es">
<head>
    <meta charset="UTF-8">
    <title>Solicitudes</title>
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.2/dist/css/bootstrap.min.css" rel="stylesheet">
</head>
<body>
<nav class="navbar navbar-dark bg-primary">
    <div class="container">
        <a class="navbar-brand" href="${pageContext.request.contextPath}/">🏠 Inmobiliaria UTS</a>
        <div>
            <c:if test="${sessionScope.roles.contains('ADMINISTRADOR')}">
                <a href="${pageContext.request.contextPath}/dashboard/admin.jsp"
                   class="btn btn-outline-light btn-sm">Panel</a>
            </c:if>
            <c:if test="${sessionScope.roles.contains('INMOBILIARIA')}">
                <a href="${pageContext.request.contextPath}/dashboard/inmobiliaria.jsp"
                   class="btn btn-outline-light btn-sm">Panel</a>
            </c:if>
            <c:if test="${sessionScope.roles.contains('CLIENTE')}">
                <a href="${pageContext.request.contextPath}/dashboard/cliente.jsp"
                   class="btn btn-outline-light btn-sm">Panel</a>
            </c:if>
            <a href="${pageContext.request.contextPath}/LogoutServlet"
               class="btn btn-outline-light btn-sm">Salir</a>
        </div>
    </div>
</nav>

<div class="container my-4">
    <h2>
        <c:choose>
            <c:when test="${sessionScope.roles.contains('ADMINISTRADOR')}">Todas las solicitudes</c:when>
            <c:when test="${sessionScope.roles.contains('INMOBILIARIA')}">Solicitudes de mis propiedades</c:when>
            <c:otherwise>Mis solicitudes</c:otherwise>
        </c:choose>
    </h2>

    <c:if test="${not empty error}">
        <div class="alert alert-danger">${error}</div>
    </c:if>

    <c:if test="${empty solicitudes}">
        <div class="alert alert-info">No hay solicitudes registradas.</div>
    </c:if>

    <c:if test="${not empty solicitudes}">
        <div class="table-responsive">
            <table class="table table-striped align-middle">
                <thead class="table-dark">
                    <tr>
                        <th>#</th>
                        <th>Propiedad</th>
                        <c:if test="${not sessionScope.roles.contains('CLIENTE')}">
                            <th>Cliente</th>
                        </c:if>
                        <th>Tipo</th>
                        <th>Fecha radicación</th>
                        <th>Estado</th>
                        <th>Acciones</th>
                    </tr>
                </thead>
                <tbody>
                    <c:forEach var="s" items="${solicitudes}">
                        <tr>
                            <td>${s.idSolicitud}</td>
                            <td>${s.tituloPropiedad}</td>
                            <c:if test="${not sessionScope.roles.contains('CLIENTE')}">
                                <td>
                                    ${s.nombreCliente}<br>
                                    <small class="text-muted">${s.correoCliente}</small>
                                </td>
                            </c:if>
                            <td>
                                <c:choose>
                                    <c:when test="${s.tipo == 'COMPRA'}">
                                        <span class="badge bg-info text-dark">COMPRA</span>
                                    </c:when>
                                    <c:otherwise>
                                        <span class="badge bg-secondary">ARRIENDO</span>
                                    </c:otherwise>
                                </c:choose>
                            </td>
                            <td>${s.fechaRadicacion}</td>
                            <td>
                                <c:choose>
                                    <c:when test="${s.estado == 'RADICADA'}">
                                        <span class="badge bg-warning text-dark">RADICADA</span>
                                    </c:when>
                                    <c:when test="${s.estado == 'EN_REVISION'}">
                                        <span class="badge bg-info text-dark">EN REVISIÓN</span>
                                    </c:when>
                                    <c:when test="${s.estado == 'APROBADA'}">
                                        <span class="badge bg-success">APROBADA</span>
                                    </c:when>
                                    <c:when test="${s.estado == 'RECHAZADA'}">
                                        <span class="badge bg-danger">RECHAZADA</span>
                                    </c:when>
                                </c:choose>
                            </td>
                            <td>
                                <a class="btn btn-sm btn-outline-primary"
                                   href="${pageContext.request.contextPath}/SolicitudServlet?accion=ver&id=${s.idSolicitud}">
                                    Ver
                                </a>
                            </td>
                        </tr>
                    </c:forEach>
                </tbody>
            </table>
        </div>
    </c:if>
</div>
</body>
</html>
