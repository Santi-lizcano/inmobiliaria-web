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
    <title>Usuarios</title>
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.2/dist/css/bootstrap.min.css" rel="stylesheet">
</head>
<body class="bg-light">

<nav class="navbar navbar-dark bg-dark">
    <div class="container-fluid">
        <a class="navbar-brand" href="${pageContext.request.contextPath}/dashboard/admin.jsp">
            🛡️ Panel Admin · Usuarios
        </a>
        <a href="${pageContext.request.contextPath}/LogoutServlet"
           class="btn btn-outline-light btn-sm">Salir</a>
    </div>
</nav>

<div class="container my-4">

    <div class="d-flex justify-content-between align-items-center mb-3">
        <h2>👥 Gestión de usuarios</h2>
        <a href="${pageContext.request.contextPath}/dashboard/admin.jsp"
           class="btn btn-outline-secondary btn-sm">← Volver al panel</a>
    </div>

    <c:if test="${not empty error}">
        <div class="alert alert-danger">${error}</div>
    </c:if>

    <div class="card shadow-sm">
        <div class="card-body p-0">
            <div class="table-responsive">
                <table class="table table-hover align-middle mb-0">
                    <thead class="table-dark">
                        <tr>
                            <th>ID</th>
                            <th>Nombre</th>
                            <th>Correo</th>
                            <th>Documento</th>
                            <th>Teléfono</th>
                            <th>Estado</th>
                            <th>Intentos</th>
                            <th>Registro</th>
                            <th>Acciones</th>
                        </tr>
                    </thead>
                    <tbody>
                        <c:forEach var="u" items="${usuarios}">
                            <tr>
                                <td>${u.idUsuario}</td>
                                <td>${u.nombreCompleto}</td>
                                <td>${u.correo}</td>
                                <td>${u.documento}</td>
                                <td>${u.telefono}</td>
                                <td>
                                    <c:choose>
                                        <c:when test="${u.estado == 'ACTIVO'}">
                                            <span class="badge bg-success">ACTIVO</span>
                                        </c:when>
                                        <c:when test="${u.estado == 'INACTIVO'}">
                                            <span class="badge bg-secondary">INACTIVO</span>
                                        </c:when>
                                        <c:when test="${u.estado == 'BLOQUEADO'}">
                                            <span class="badge bg-danger">BLOQUEADO</span>
                                        </c:when>
                                    </c:choose>
                                </td>
                                <td>${u.intentosFallidos}</td>
                                <td><small>${u.fechaRegistro}</small></td>
                                <td>
                                    <%-- Cambiar estado --%>
                                    <c:if test="${u.estado != 'ACTIVO'}">
                                        <form method="post"
                                              action="${pageContext.request.contextPath}/AdminServlet"
                                              class="d-inline">
                                            <input type="hidden" name="accion" value="cambiarEstado">
                                            <input type="hidden" name="id" value="${u.idUsuario}">
                                            <input type="hidden" name="estado" value="ACTIVO">
                                            <button class="btn btn-sm btn-success">Activar</button>
                                        </form>
                                    </c:if>
                                    <c:if test="${u.estado == 'ACTIVO'}">
                                        <form method="post"
                                              action="${pageContext.request.contextPath}/AdminServlet"
                                              class="d-inline"
                                              onsubmit="return confirm('¿Inactivar a ${u.correo}?');">
                                            <input type="hidden" name="accion" value="cambiarEstado">
                                            <input type="hidden" name="id" value="${u.idUsuario}">
                                            <input type="hidden" name="estado" value="INACTIVO">
                                            <button class="btn btn-sm btn-warning">Inactivar</button>
                                        </form>
                                    </c:if>

                                    <a class="btn btn-sm btn-outline-primary"
                                       href="${pageContext.request.contextPath}/AdminServlet?accion=editarUsuario&id=${u.idUsuario}">
                                        Editar
                                    </a>
                                </td>
                            </tr>
                        </c:forEach>
                    </tbody>
                </table>
            </div>
        </div>
    </div>

    <%-- Si hay un usuario seleccionado para editar, mostramos formulario --%>
    <c:if test="${not empty usuarioEditado}">
        <div class="card shadow-sm mt-4">
            <div class="card-header bg-primary text-white">
                Editar perfil de <strong>${usuarioEditado.correo}</strong>
            </div>
            <div class="card-body">
                <form method="post"
                      action="${pageContext.request.contextPath}/AdminServlet"
                      class="row g-3">
                    <input type="hidden" name="accion" value="actualizarUsuario">
                    <input type="hidden" name="id" value="${usuarioEditado.idUsuario}">

                    <div class="col-md-6">
                        <label class="form-label">Nombres</label>
                        <input type="text" name="nombres" class="form-control"
                               value="${usuarioEditado.nombres}" required>
                    </div>
                    <div class="col-md-6">
                        <label class="form-label">Apellidos</label>
                        <input type="text" name="apellidos" class="form-control"
                               value="${usuarioEditado.apellidos}" required>
                    </div>
                    <div class="col-md-4">
                        <label class="form-label">Documento</label>
                        <input type="text" name="documento" class="form-control"
                               value="${usuarioEditado.documento}" required>
                    </div>
                    <div class="col-md-4">
                        <label class="form-label">Teléfono</label>
                        <input type="text" name="telefono" class="form-control"
                               value="${usuarioEditado.telefono}">
                    </div>
                    <div class="col-md-4">
                        <label class="form-label">Dirección</label>
                        <input type="text" name="direccion" class="form-control"
                               value="${usuarioEditado.direccion}">
                    </div>

                    <div class="col-12">
                        <button class="btn btn-primary">Guardar cambios</button>
                        <a href="${pageContext.request.contextPath}/AdminServlet?accion=usuarios"
                           class="btn btn-secondary">Cancelar</a>
                    </div>
                </form>

                <hr class="mt-4">

                <h6>Roles actuales:</h6>
                <div>
                    <c:forEach var="r" items="${rolesUsuario}">
                        <span class="badge bg-info text-dark me-1">${r}</span>
                    </c:forEach>
                    <c:if test="${empty rolesUsuario}">
                        <em class="text-muted">Sin roles asignados</em>
                    </c:if>
                </div>

                <a href="${pageContext.request.contextPath}/AdminServlet?accion=roles"
                   class="btn btn-sm btn-outline-primary mt-2">
                    Gestionar roles
                </a>
            </div>
        </div>
    </c:if>

</div>
</body>
</html>
