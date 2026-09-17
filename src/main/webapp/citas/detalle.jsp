<%@ page contentType="text/html; charset=UTF-8" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<!DOCTYPE html>
<html lang="es">
<head>
    <meta charset="UTF-8">
    <title>Detalle de cita</title>
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.2/dist/css/bootstrap.min.css" rel="stylesheet">
    <link rel="stylesheet" href="${pageContext.request.contextPath}/css/estilos.css">
</head>
<body>
<nav class="navbar navbar-dark bg-primary">
    <div class="container">
        <a class="navbar-brand" href="${pageContext.request.contextPath}/">🏠 Inmobiliaria UTS</a>
        <a href="${pageContext.request.contextPath}/CitaServlet?accion=listar"
           class="btn btn-outline-light btn-sm">Volver</a>
    </div>
</nav>

<div class="container my-5">
    <div class="row justify-content-center">
        <div class="col-md-8">
            <div class="card shadow">
                <div class="card-header bg-primary text-white">
                    <h4 class="mb-0">Cita #${cita.idCita}</h4>
                </div>
                <div class="card-body">

                    <dl class="row">
                        <dt class="col-sm-4">Propiedad</dt>
                        <dd class="col-sm-8">${cita.tituloPropiedad}</dd>

                        <dt class="col-sm-4">Cliente</dt>
                        <dd class="col-sm-8">
                            ${cita.nombreCliente}<br>
                            <small class="text-muted">${cita.correoCliente}</small>
                            <c:if test="${not empty cita.telefonoCliente}">
                                <br><small>📞 ${cita.telefonoCliente}</small>
                            </c:if>
                        </dd>

                        <dt class="col-sm-4">Fecha y hora</dt>
                        <dd class="col-sm-8">${cita.fechaHora}</dd>

                        <dt class="col-sm-4">Estado</dt>
                        <dd class="col-sm-8">
                            <c:choose>
                                <c:when test="${cita.estado == 'PENDIENTE'}">
                                    <span class="badge bg-warning text-dark">PENDIENTE</span>
                                </c:when>
                                <c:when test="${cita.estado == 'CONFIRMADA'}">
                                    <span class="badge bg-success">CONFIRMADA</span>
                                </c:when>
                                <c:when test="${cita.estado == 'REALIZADA'}">
                                    <span class="badge bg-primary">REALIZADA</span>
                                </c:when>
                                <c:when test="${cita.estado == 'CANCELADA'}">
                                    <span class="badge bg-danger">CANCELADA</span>
                                </c:when>
                            </c:choose>
                        </dd>

                        <dt class="col-sm-4">Observaciones</dt>
                        <dd class="col-sm-8">
                            <c:choose>
                                <c:when test="${not empty cita.observaciones}">
                                    ${cita.observaciones}
                                </c:when>
                                <c:otherwise><em class="text-muted">Sin observaciones</em></c:otherwise>
                            </c:choose>
                        </dd>
                    </dl>

                    <hr>

                    <%-- Acciones según rol y estado --%>
                    <div class="d-flex gap-2 flex-wrap">

                        <c:if test="${(sessionScope.roles.contains('CLIENTE') || sessionScope.roles.contains('ADMINISTRADOR'))
                                      && cita.estado != 'CANCELADA' && cita.estado != 'REALIZADA'}">
                            <form method="post"
                                  action="${pageContext.request.contextPath}/CitaServlet"
                                  onsubmit="return confirm('¿Cancelar esta cita?');">
                                <input type="hidden" name="accion" value="cancelar">
                                <input type="hidden" name="id" value="${cita.idCita}">
                                <button class="btn btn-danger">Cancelar cita</button>
                            </form>
                        </c:if>

                        <c:if test="${sessionScope.roles.contains('INMOBILIARIA') || sessionScope.roles.contains('ADMINISTRADOR')}">
                            <c:if test="${cita.estado == 'PENDIENTE'}">
                                <form method="post"
                                      action="${pageContext.request.contextPath}/CitaServlet">
                                    <input type="hidden" name="accion" value="cambiarEstado">
                                    <input type="hidden" name="id" value="${cita.idCita}">
                                    <input type="hidden" name="estado" value="CONFIRMADA">
                                    <button class="btn btn-success">Confirmar</button>
                                </form>
                            </c:if>
                            <c:if test="${cita.estado == 'CONFIRMADA'}">
                                <form method="post"
                                      action="${pageContext.request.contextPath}/CitaServlet">
                                    <input type="hidden" name="accion" value="cambiarEstado">
                                    <input type="hidden" name="id" value="${cita.idCita}">
                                    <input type="hidden" name="estado" value="REALIZADA">
                                    <button class="btn btn-primary">Marcar realizada</button>
                                </form>
                            </c:if>
                        </c:if>

                        <%-- El cliente puede radicar solicitud desde la cita --%>
                        <c:if test="${sessionScope.roles.contains('CLIENTE') && cita.estado == 'REALIZADA'}">
                            <a href="${pageContext.request.contextPath}/SolicitudServlet?accion=formulario&id=${cita.idPropiedad}&idCita=${cita.idCita}"
                               class="btn btn-warning">Radicar solicitud</a>
                        </c:if>

                    </div>

                </div>
            </div>
        </div>
    </div>
</div>
</body>
</html>
