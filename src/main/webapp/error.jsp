<%@ page contentType="text/html; charset=UTF-8" isErrorPage="true" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<!DOCTYPE html>
<html lang="es">
<head>
    <meta charset="UTF-8">
    <title>Error del sistema</title>
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.2/dist/css/bootstrap.min.css" rel="stylesheet">
    <link rel="stylesheet" href="${pageContext.request.contextPath}/css/estilos.css">
</head>
<body class="bg-light d-flex align-items-center" style="min-height:100vh;">

<div class="container">
    <div class="row justify-content-center">
        <div class="col-md-7">

            <div class="card shadow border-warning">
                <div class="card-body p-5 text-center">
                    <div class="display-1 text-warning">⚠️</div>
                    <h2 class="mt-3">Algo salió mal</h2>
                    <p class="text-muted">
                        Ha ocurrido un error inesperado al procesar tu solicitud.
                        El equipo técnico ha sido notificado.
                    </p>

                    <%-- Mensaje específico si el Servlet lo dejó en request --%>
                    <c:if test="${not empty error}">
                        <div class="alert alert-danger text-start mt-3">
                            <strong>Detalle:</strong> ${error}
                        </div>
                    </c:if>

                    <%-- Información técnica del error (solo visible para admin) --%>
                    <c:if test="${sessionScope.roles.contains('ADMINISTRADOR')}">
                        <div class="alert alert-secondary text-start small mt-3">
                            <strong>Detalles técnicos:</strong><br>
                            <c:if test="${not empty pageContext.exception}">
                                <code>${pageContext.exception['class'].name}</code><br>
                                <code>${pageContext.exception.message}</code>
                            </c:if>
                            <c:if test="${empty pageContext.exception}">
                                <em>No hay excepción asociada.</em>
                            </c:if>
                        </div>
                    </c:if>

                    <div class="d-grid gap-2 mt-4">
                        <a href="${pageContext.request.contextPath}/" class="btn btn-primary">
                            Volver al inicio
                        </a>
                        <button onclick="history.back()" class="btn btn-outline-secondary">
                            Regresar a la página anterior
                        </button>
                    </div>
                </div>
            </div>

            <p class="text-muted text-center mt-3 small">
                Si el problema persiste, contacta al administrador del sistema.
            </p>

        </div>
    </div>
</div>
</body>
</html>
