<%@ page contentType="text/html; charset=UTF-8" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<!DOCTYPE html>
<html lang="es">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1">
    <title>Crear cuenta · Inmobiliaria UTS</title>
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.2/dist/css/bootstrap.min.css" rel="stylesheet">
</head>
<body class="bg-light">

<div class="container my-5">
    <div class="row justify-content-center">
        <div class="col-md-8 col-lg-7">

            <div class="text-center mb-4">
                <a href="${pageContext.request.contextPath}/"
                   class="text-decoration-none">
                    <h2 class="text-primary">🏠 Inmobiliaria UTS</h2>
                </a>
                <p class="text-muted mb-0">Crea tu cuenta para agendar visitas y radicar solicitudes.</p>
            </div>

            <div class="card shadow">
                <div class="card-body p-4">

                    <h3 class="mb-4 text-center">Crear cuenta</h3>

                    <%-- Mensaje de error devuelto por el servlet --%>
                    <c:if test="${not empty error}">
                        <div class="alert alert-danger">${error}</div>
                    </c:if>

                    <form method="post"
                          action="${pageContext.request.contextPath}/RegistroServlet"
                          class="row g-3"
                          novalidate>

                        <%-- ============ DATOS PERSONALES ============ --%>
                        <div class="col-md-6">
                            <label class="form-label">Nombres *</label>
                            <input type="text" name="nombres" class="form-control"
                                   value="${nombres}" required maxlength="80">
                        </div>
                        <div class="col-md-6">
                            <label class="form-label">Apellidos *</label>
                            <input type="text" name="apellidos" class="form-control"
                                   value="${apellidos}" required maxlength="80">
                        </div>

                        <div class="col-md-6">
                            <label class="form-label">Documento *</label>
                            <input type="text" name="documento" class="form-control"
                                   value="${documento}" required
                                   pattern="[0-9]{6,20}"
                                   title="Solo números, entre 6 y 20 dígitos">
                            <small class="text-muted">Solo números, entre 6 y 20 dígitos.</small>
                        </div>
                        <div class="col-md-6">
                            <label class="form-label">Teléfono</label>
                            <input type="text" name="telefono" class="form-control"
                                   value="${telefono}" maxlength="20">
                        </div>

                        <div class="col-12">
                            <label class="form-label">Dirección</label>
                            <input type="text" name="direccion" class="form-control"
                                   value="${direccion}" maxlength="150">
                        </div>

                        <%-- ============ CREDENCIALES ============ --%>
                        <div class="col-12">
                            <label class="form-label">Correo electrónico *</label>
                            <input type="email" name="correo" class="form-control"
                                   value="${correo}" required maxlength="120"
                                   placeholder="tu@correo.com">
                            <small class="text-muted">Será tu usuario de ingreso.</small>
                        </div>

                        <div class="col-md-6">
                            <label class="form-label">Contraseña *</label>
                            <input type="password" name="password" class="form-control"
                                   required minlength="8" maxlength="64">
                            <small class="text-muted">Mínimo 8 caracteres.</small>
                        </div>
                        <div class="col-md-6">
                            <label class="form-label">Confirmar contraseña *</label>
                            <input type="password" name="confirmar" class="form-control"
                                   required minlength="8" maxlength="64">
                        </div>

                        <%-- ============ TÉRMINOS Y ENVÍO ============ --%>
                        <div class="col-12">
                            <div class="form-check">
                                <input class="form-check-input" type="checkbox"
                                       id="acepto" required>
                                <label class="form-check-label" for="acepto">
                                    Acepto los términos y el tratamiento de datos personales.
                                </label>
                            </div>
                        </div>

                        <div class="col-12 mt-2">
                            <button class="btn btn-primary w-100 py-2">
                                Crear mi cuenta
                            </button>
                        </div>

                    </form>

                    <hr class="my-4">

                    <p class="text-center mb-0">
                        ¿Ya tienes una cuenta?
                        <a href="${pageContext.request.contextPath}/login.jsp">
                            Inicia sesión
                        </a>
                    </p>

                </div>
            </div>

            <p class="text-center text-muted mt-3 small">
                <a href="${pageContext.request.contextPath}/"
                   class="text-decoration-none">← Volver al inicio</a>
            </p>

        </div>
    </div>
</div>

<script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.2/dist/js/bootstrap.bundle.min.js"></script>
</body>
</html>
