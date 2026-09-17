<%@ page contentType="text/html; charset=UTF-8" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<!DOCTYPE html>
<html lang="es">
<head>
    <meta charset="UTF-8">
    <title>Mis citas</title>
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
            <c:when test="${sessionScope.roles.contains('ADMINISTRADOR')}">Todas las citas</c:when>
            <c:when test="${sessionScope.roles.contains('INMOBILIARIA')}">Citas de mis propiedades</c:when>
            <c:otherwise>Mis citas</c:otherwise>
        </c:choose>
    </h2>

    <c:if test="${not empty error}">
        <div class="alert alert-danger">${error}</div>
    </c:if>

    <c:if test="${empty citas}">
        <div class="alert alert-info">No hay citas registradas.</div>
    </c:if>

    <c:if test="${not empty citas}">
        <div class="table-responsive">
            <table class="table table-striped align-middle">
                <thead class="table-dark">
                    <tr>
                        <th>#</th>
                        <th>Propiedad</th>
                        <c:if test="${not sessionScope.roles.contains('CLIENTE')}">
                            <th>Cliente</th>
                        </c:if>
                        <th>Fecha y hora</th>
                        <th>Estado</th>
                        <th>Acciones</th>
                    </tr>
                </thead>
                <tbody>
                    <c:forEach var="c" items="${citas}">
                        <tr>
                            <td>${c.idCita}</td>
                            <td>${c.tituloPropiedad}</td>
                            <c:if test="${not sessionScope.roles.contains('CLIENTE')}">
                                <td>
                                    ${c.nombreCliente}<br>
                                    <small class="text-muted">${c.correoCliente}</small>
                                    <c:if test="${not empty c.telefonoCliente}">
                                        <br><small>📞 ${c.telefonoCliente}</small>
                                    </c:if>
                                </td>
                            </c:if>
                            <td>${c.fechaHora}</td>
                            <td>
                                <c:choose>
                                    <c:when test="${c.estado == 'PENDIENTE'}">
                                        <span class="badge bg-warning text-dark">PENDIENTE</span>
                                    </c:when>
                                    <c:when test="${c.estado == 'CONFIRMADA'}">
                                        <span class="badge bg-success">CONFIRMADA</span>
                                    </c:when>
                                    <c:when test="${c.estado == 'REALIZADA'}">
                                        <span class="badge bg-primary">REALIZADA</span>
                                    </c:when>
                                    <c:when test="${c.estado == 'CANCELADA'}">
                                        <span class="badge bg-danger">CANCELADA</span>
                                    </c:when>
                                    <c:otherwise>
                                        <span class="badge bg-secondary">${c.estado}</span>
                                    </c:otherwise>
                                </c:choose>
                            </td>
                            <td>
                                <a class="btn btn-sm btn-outline-primary"
                                   href="${pageContext.request.contextPath}/CitaServlet?accion=ver&id=${c.idCita}">
                                    Ver
                                </a>

                                <%-- Cliente o admin pueden cancelar --%>
                                <c:if test="${(sessionScope.roles.contains('CLIENTE') || sessionScope.roles.contains('ADMINISTRADOR'))
                                              && c.estado != 'CANCELADA' && c.estado != 'REALIZADA'}">
                                    <form method="post"
                                          action="${pageContext.request.contextPath}/CitaServlet"
                                          class="d-inline"
                                          onsubmit="return confirm('¿Cancelar esta cita?');">
                                        <input type="hidden" name="accion" value="cancelar">
                                        <input type="hidden" name="id" value="${c.idCita}">
                                        <button class="btn btn-sm btn-outline-danger">Cancelar</button>
                                    </form>
                                </c:if>

                                <%-- Inmobiliaria o admin pueden cambiar el estado --%>
                                <c:if test="${sessionScope.roles.contains('INMOBILIARIA') || sessionScope.roles.contains('ADMINISTRADOR')}">
                                    <c:if test="${c.estado == 'PENDIENTE'}">
                                        <form method="post"
                                              action="${pageContext.request.contextPath}/CitaServlet"
                                              class="d-inline">
                                            <input type="hidden" name="accion" value="cambiarEstado">
                                            <input type="hidden" name="id" value="${c.idCita}">
                                            <input type="hidden" name="estado" value="CONFIRMADA">
                                            <button class="btn btn-sm btn-success">Confirmar</button>
                                        </form>
                                    </c:if>
                                    <c:if test="${c.estado == 'CONFIRMADA'}">
                                        <form method="post"
                                              action="${pageContext.request.contextPath}/CitaServlet"
                                              class="d-inline">
                                            <input type="hidden" name="accion" value="cambiarEstado">
                                            <input type="hidden" name="id" value="${c.idCita}">
                                            <input type="hidden" name="estado" value="REALIZADA">
                                            <button class="btn btn-sm btn-primary">Marcar realizada</button>
                                        </form>
                                    </c:if>
                                </c:if>
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
