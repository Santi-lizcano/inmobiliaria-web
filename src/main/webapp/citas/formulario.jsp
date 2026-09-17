<%@ page contentType="text/html; charset=UTF-8" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<!DOCTYPE html>
<html lang="es">
<head>
    <meta charset="UTF-8">
    <title>Agendar visita</title>
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.2/dist/css/bootstrap.min.css" rel="stylesheet">
</head>
<body>
<nav class="navbar navbar-dark bg-primary">
    <div class="container">
        <a class="navbar-brand" href="${pageContext.request.contextPath}/">🏠 Inmobiliaria UTS</a>
        <a href="${pageContext.request.contextPath}/PropiedadServlet?accion=listar"
           class="btn btn-outline-light btn-sm">Volver</a>
    </div>
</nav>

<div class="container my-5">
    <div class="row justify-content-center">
        <div class="col-md-7">
            <div class="card shadow">
                <div class="card-body p-4">

                    <h3 class="mb-3">📅 Agendar visita</h3>

                    <c:if test="${not empty error}">
                        <div class="alert alert-danger">${error}</div>
                    </c:if>

                    <c:if test="${empty propiedad}">
                        <div class="alert alert-warning">
                            No se encontró la propiedad. Vuelve al listado.
                        </div>
                    </c:if>

                    <c:if test="${not empty propiedad}">
                        <div class="alert alert-info">
                            <strong>${propiedad.titulo}</strong><br>
                            📍 ${propiedad.nombreCiudad} · ${propiedad.nombreTipo}<br>
                            💰 $ ${propiedad.precio}
                        </div>

                        <form method="post"
                              action="${pageContext.request.contextPath}/CitaServlet">
                            <input type="hidden" name="accion" value="crear">
                            <input type="hidden" name="idPropiedad" value="${propiedad.idPropiedad}">

                            <div class="mb-3">
                                <label class="form-label">Fecha y hora de la visita *</label>
                                <input type="datetime-local" name="fechaHora"
                                       class="form-control" required>
                                <small class="text-muted">
                                    No se permiten fechas en el pasado.
                                </small>
                            </div>

                            <div class="mb-3">
                                <label class="form-label">Observaciones (opcional)</label>
                                <textarea name="observaciones" class="form-control"
                                          rows="3" maxlength="255"></textarea>
                            </div>

                            <div class="d-grid gap-2">
                                <button class="btn btn-primary">Solicitar cita</button>
                                <a href="${pageContext.request.contextPath}/PropiedadServlet?accion=ver&id=${propiedad.idPropiedad}"
                                   class="btn btn-outline-secondary">Cancelar</a>
                            </div>
                        </form>
                    </c:if>

                </div>
            </div>
        </div>
    </div>
</div>
</body>
</html>
