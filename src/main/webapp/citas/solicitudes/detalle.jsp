<%@ page contentType="text/html; charset=UTF-8" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<!DOCTYPE html>
<html lang="es">
<head>
    <meta charset="UTF-8">
    <title>Detalle de solicitud</title>
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.2/dist/css/bootstrap.min.css" rel="stylesheet">
</head>
<body>
<nav class="navbar navbar-dark bg-primary">
    <div class="container">
        <a class="navbar-brand" href="${pageContext.request.contextPath}/">🏠 Inmobiliaria UTS</a>
        <a href="${pageContext.request.contextPath}/SolicitudServlet?accion=listar"
           class="btn btn-outline-light btn-sm">Volver</a>
    </div>
</nav>

<div class="container my-5">
    <div class="row justify-content-center">
        <div class="col-md-9">
            <div class="card shadow">
                <div class="card-header bg-primary text-white d-flex justify-content-between">
                    <h4 class="mb-0">Solicitud #${solicitud.idSolicitud}</h4>
                    <span>
                        <c:choose>
                            <c:when test="${solicitud.estado == 'RADICADA'}">
                                <span class="badge bg-warning text-dark">RADICADA</span>
                            </c:when>
                            <c:when test="${solicitud.estado == 'EN_REVISION'}">
                                <span class="badge bg-info text-dark">EN REVISIÓN</span>
                            </c:when>
                            <c:when test="${solicitud.estado == 'APROBADA'}">
                                <span class="badge bg-success">APROBADA</span>
                            </c:when>
                            <c:when test="${solicitud.estado == 'RECHAZADA'}">
                                <span class="badge bg-danger">RECHAZADA</span>
                            </c:when>
                        </c:choose>
                    </span>
                </div>
                <div class="card-body">

                    <c:if test="${not empty error}">
                        <div class="alert alert-danger">${error}</div>
                    </c:if>

                    <dl class="row">
                        <dt class="col-sm-4">Propiedad</dt>
                        <dd class="col-sm-8">${solicitud.tituloPropiedad}</dd>

                        <dt class="col-sm-4">Cliente</dt>
                        <dd class="col-sm-8">
                            ${solicitud.nombreCliente}<br>
                            <small class="text-muted">${solicitud.correoCliente}</small>
                        </dd>

                        <dt class="col-sm-4">Tipo</dt>
                        <dd class="col-sm-8">${solicitud.tipo}</dd>

                        <dt class="col-sm-4">Fecha radicación</dt>
                        <dd class="col-sm-8">${solicitud.fechaRadicacion}</dd>

                        <c:if test="${not empty solicitud.idCita}">
                            <dt class="col-sm-4">Cita asociada</dt>
                            <dd class="col-sm-8">
                                <a href="${pageContext.request.contextPath}/CitaServlet?accion=ver&id=${solicitud.idCita}">
                                    Ver cita #${solicitud.idCita}
                                </a>
                            </dd>
                        </c:if>

                        <dt class="col-sm-4">Observaciones</dt>
                        <dd class="col-sm-8">
                            <c:choose>
                                <c:when test="${not empty solicitud.observaciones}">
                                    ${solicitud.observaciones}
                                </c:when>
                                <c:otherwise><em class="text-muted">Sin observaciones</em></c:otherwise>
                            </c:choose>
                        </dd>
                    </dl>

                    <hr>

                    <h5>📎 Documentos adjuntos (${solicitud.documentos.size()})</h5>
                    <c:if test="${empty solicitud.documentos}">
                        <div class="alert alert-secondary">No hay documentos cargados.</div>
                    </c:if>
                    <c:if test="${not empty solicitud.documentos}">
                        <ul class="list-group mb-3">
                            <c:forEach var="d" items="${solicitud.documentos}">
                                <li class="list-group-item d-flex justify-content-between align-items-center">
                                    <div>
                                        <strong>${d.nombre}</strong><br>
                                        <small class="text-muted">Cargado: ${d.fechaCarga}</small>
                                    </div>
                                    <a href="${d.url}" target="_blank"
                                       class="btn btn-sm btn-outline-primary">Descargar</a>
                                </li>
                            </c:forEach>
                        </ul>
                    </c:if>

                    <%-- Cliente o admin: subir documento adicional --%>
                    <c:if test="${sessionScope.roles.contains('CLIENTE') || sessionScope.roles.contains('ADMINISTRADOR')}">
                        <div class="card bg-light mb-3">
                            <div class="card-body">
                                <h6>Agregar documento</h6>
                                <form method="post"
                                      action="${pageContext.request.contextPath}/SolicitudServlet"
                                      enctype="multipart/form-data"
                                      class="row g-2">
                                    <input type="hidden" name="accion" value="agregarDocumento">
                                    <input type="hidden" name="id" value="${solicitud.idSolicitud}">
                                    <div class="col-md-9">
                                        <input type="file" name="documentos"
                                               class="form-control" multiple required>
                                    </div>
                                    <div class="col-md-3">
                                        <button class="btn btn-primary w-100">Subir</button>
                                    </div>
                                </form>
                            </div>
                        </div>
                    </c:if>

                    <hr>

                    <%-- Acciones de la inmobiliaria: aprobar/rechazar --%>
                    <c:if test="${sessionScope.roles.contains('INMOBILIARIA') || sessionScope.roles.contains('ADMINISTRADOR')}">
                        <h5>Acciones de revisión</h5>
                        <div class="d-flex gap-2 flex-wrap">

                            <c:if test="${solicitud.estado == 'RADICADA'}">
                                <form method="post"
                                      action="${pageContext.request.contextPath}/SolicitudServlet">
                                    <input type="hidden" name="accion" value="cambiarEstado">
                                    <input type="hidden" name="id" value="${solicitud.idSolicitud}">
                                    <input type="hidden" name="estado" value="EN_REVISION">
                                    <button class="btn btn-info">Marcar en revisión</button>
                                </form>
                            </c:if>

                            <c:if test="${solicitud.estado != 'APROBADA' && solicitud.estado != 'RECHAZADA'}">
                                <form method="post"
                                      action="${pageContext.request.contextPath}/SolicitudServlet"
                                      onsubmit="return confirm('¿Aprobar esta solicitud?');">
                                    <input type="hidden" name="accion" value="cambiarEstado">
                                    <input type="hidden" name="id" value="${solicitud.idSolicitud}">
                                    <input type="hidden" name="estado" value="APROBADA">
                                    <button class="btn btn-success">Aprobar</button>
                                </form>

                                <form method="post"
                                      action="${pageContext.request.contextPath}/SolicitudServlet"
                                      onsubmit="return confirm('¿Rechazar esta solicitud?');">
                                    <input type="hidden" name="accion" value="cambiarEstado">
                                    <input type="hidden" name="id" value="${solicitud.idSolicitud}">
                                    <input type="hidden" name="estado" value="RECHAZADA">
                                    <button class="btn btn-danger">Rechazar</button>
                                </form>
                            </c:if>

                        </div>
                    </c:if>

                </div>
            </div>
        </div>
    </div>
</div>
</body>
</html>
