<%@ page contentType="text/html; charset=UTF-8" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<%
    if (session.getAttribute("roles") == null ||
        !((java.util.List<String>) session.getAttribute("roles")).contains("CLIENTE")) {
        response.sendRedirect(request.getContextPath() + "/acceso-denegado.jsp");
        return;
    }
%>
<!DOCTYPE html>
<html lang="es">
<head>
    <meta charset="UTF-8">
    <title>Mi perfil</title>
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.2/dist/css/bootstrap.min.css" rel="stylesheet">
    <link rel="stylesheet" href="${pageContext.request.contextPath}/css/estilos.css">
</head>
<body class="bg-light">

<nav class="navbar navbar-dark bg-success">
    <div class="container-fluid">
        <a class="navbar-brand" href="${pageContext.request.contextPath}/dashboard/cliente.jsp">
            👤 Mi cuenta
        </a>
        <a href="${pageContext.request.contextPath}/LogoutServlet"
           class="btn btn-outline-light btn-sm">Salir</a>
    </div>
</nav>

<div class="container my-4">

    <div class="d-flex justify-content-between align-items-center mb-3">
        <h2>Mi perfil</h2>
        <a href="${pageContext.request.contextPath}/dashboard/cliente.jsp"
           class="btn btn-outline-secondary btn-sm">← Volver al panel</a>
    </div>

    <c:if test="${param.ok == 'perfilGuardado'}">
        <div class="alert alert-success">✅ Perfil actualizado correctamente.</div>
    </c:if>
    <c:if test="${param.ok == 'passwordCambiada'}">
        <div class="alert alert-success">✅ Contraseña actualizada correctamente.</div>
    </c:if>
    <c:if test="${not empty error}">
        <div class="alert alert-danger">${error}</div>
    </c:if>

    <div class="row g-3">

        <%-- Datos de la cuenta (no editables) --%>
        <div class="col-md-4">
            <div class="card card-auth"></div>
                <div class="card-header bg-dark text-white">Cuenta</div>
                <div class="card-body">
                    <p class="mb-1"><strong>Correo:</strong><br>${usuario.correo}</p>
                    <p class="mb-1"><strong>Estado:</strong>
                        <span class="badge bg-success">${usuario.estado}</span>
                    </p>
                    <p class="mb-1"><strong>Registrado:</strong><br>
                        <small class="text-muted">${usuario.fechaRegistro}</small>
                    </p>

                    <hr>

                    <a href="${pageContext.request.contextPath}/ClienteServlet?accion=cambiarPassword"
                       class="btn btn-outline-warning w-100">
                        🔒 Cambiar contraseña
                    </a>
                </div>
            </div>
        </div>

        <%-- Datos del perfil (editables) --%>
        <div class="col-md-8">
            <div class="card card-auth">
                <div class="card-header bg-primary text-white">Datos personales</div>
                <div class="card-body">

                    <c:choose>
                        <%-- Modo visualización --%>
                        <c:when test="${modo != 'editar'}">
                            <dl class="row mb-3">
                                <dt class="col-sm-4">Nombres</dt>
                                <dd class="col-sm-8">${usuario.nombres}</dd>

                                <dt class="col-sm-4">Apellidos</dt>
                                <dd class="col-sm-8">${usuario.apellidos}</dd>

                                <dt class="col-sm-4">Documento</dt>
                                <dd class="col-sm-8">${usuario.documento}</dd>

                                <dt class="col-sm-4">Teléfono</dt>
                                <dd class="col-sm-8">${usuario.telefono}</dd>

                                <dt class="col-sm-4">Dirección</dt>
                                <dd class="col-sm-8">${usuario.direccion}</dd>
                            </dl>

                            <a href="${pageContext.request.contextPath}/ClienteServlet?accion=editarPerfil"
                               class="btn btn-primary">
                                ✏️ Editar datos
                            </a>
                        </c:when>

                        <%-- Modo edición --%>
                        <c:otherwise>
                            <form method="post"
                                  action="${pageContext.request.contextPath}/ClienteServlet"
                                  class="row g-3">
                                <input type="hidden" name="accion" value="guardarPerfil">

                                <div class="col-md-6">
                                    <label class="form-label">Nombres *</label>
                                    <input type="text" name="nombres" class="form-control"
                                           value="${usuario.nombres}" required>
                                </div>
                                <div class="col-md-6">
                                    <label class="form-label">Apellidos *</label>
                                    <input type="text" name="apellidos" class="form-control"
                                           value="${usuario.apellidos}" required>
                                </div>
                                <div class="col-md-6">
                                    <label class="form-label">Documento *</label>
                                    <input type="text" name="documento" class="form-control"
                                           value="${usuario.documento}" required>
                                </div>
                                <div class="col-md-6">
                                    <label class="form-label">Teléfono</label>
                                    <input type="text" name="telefono" class="form-control"
                                           value="${usuario.telefono}">
                                </div>
                                <div class="col-12">
                                    <label class="form-label">Dirección</label>
                                    <input type="text" name="direccion" class="form-control"
                                           value="${usuario.direccion}">
                                </div>

                                <div class="col-12 mt-3">
                                    <button class="btn btn-primary">💾 Guardar cambios</button>
                                    <a href="${pageContext.request.contextPath}/ClienteServlet?accion=ver"
                                       class="btn btn-secondary">Cancelar</a>
                                </div>
                            </form>
                        </c:otherwise>
                    </c:choose>

                </div>
            </div>
        </div>

    </div>

</div>
</body>
</html>
