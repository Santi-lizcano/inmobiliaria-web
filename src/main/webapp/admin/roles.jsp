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
    <title>Roles</title>
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.2/dist/css/bootstrap.min.css" rel="stylesheet">
    <link rel="stylesheet" href="${pageContext.request.contextPath}/css/estilos.css">
</head>
<body class="bg-light">

<nav class="navbar navbar-dark bg-dark">
    <div class="container-fluid">
        <a class="navbar-brand" href="${pageContext.request.contextPath}/dashboard/admin.jsp">
            🛡️ Panel Admin · Roles
        </a>
        <a href="${pageContext.request.contextPath}/LogoutServlet"
           class="btn btn-outline-light btn-sm">Salir</a>
    </div>
</nav>

<div class="container my-4">

    <div class="d-flex justify-content-between align-items-center mb-3">
        <h2>🔑 Asignación de roles</h2>
        <a href="${pageContext.request.contextPath}/dashboard/admin.jsp"
           class="btn btn-outline-secondary btn-sm">← Volver al panel</a>
    </div>

    <c:if test="${not empty error}">
        <div class="alert alert-danger">${error}</div>
    </c:if>


    <%-- Formulario de asignación rápida --%>
    <div class="card shadow-sm mt-3">
        <div class="card-header bg-primary text-white">Asignar rol</div>
        <div class="card-body">
            <form method="post"
                  action="${pageContext.request.contextPath}/AdminServlet"
                  class="row g-2 align-items-end">
                <input type="hidden" name="accion" value="asignarRol">

                <div class="col-md-5">
                    <label class="form-label">Usuario</label>
                    <select name="idUsuario" class="form-select" required>
                        <option value="">-- Seleccione usuario --</option>
                        <c:forEach var="u" items="${usuarios}">
                            <option value="${u.idUsuario}">
                                ${u.correo} · ${u.nombreCompleto}
                            </option>
                        </c:forEach>
                    </select>
                </div>

                <div class="col-md-4">
                    <label class="form-label">Rol</label>
                    <select name="idRol" class="form-select" required>
                        <option value="">-- Seleccione rol --</option>
                        <c:forEach var="r" items="${rolesDisponibles}">
                            <option value="${r[0]}">${r[1]}</option>
                        </c:forEach>
                    </select>
                </div>

                <div class="col-md-3">
                    <button class="btn btn-success w-100">Asignar</button>
                </div>
            </form>
        </div>
    </div>

    <%-- Listado de usuarios para ver/revocar --%>
    <h5 class="mt-4">Usuarios y sus roles</h5>
    <div class="card card-auth">
        <div class="card-body p-0">
            <div class="table-responsive">
                <table class="table table-hover align-middle mb-0">
                    <thead class="table-dark">
                        <tr>
                            <th>ID</th>
                            <th>Correo</th>
                            <th>Nombre</th>
                            <th>Estado</th>
                            <th>Roles asignados</th>
                            <th>Acción</th>
                        </tr>
                    </thead>
                    <tbody>
                        <c:forEach var="u" items="${usuarios}">
                        <tr>
                            <td>${u.idUsuario}</td>
                            <td>${u.correo}</td>
                            <td>${u.nombreCompleto}</td>
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

                            <%-- Botones para cambiar estado --%>
                            <div class="mt-1">
                                <c:if test="${u.estado != 'ACTIVO'}">
                                    <form method="post"
                                        action="${pageContext.request.contextPath}/AdminServlet"
                                        class="d-inline">
                                    <input type="hidden" name="accion" value="cambiarEstado">
                                    <input type="hidden" name="id" value="${u.idUsuario}">
                                    <input type="hidden" name="estado" value="ACTIVO">
                                    <button class="btn btn-sm btn-outline-success">Activar</button>
                                    </form>
                                </c:if>
                                <c:if test="${u.estado != 'BLOQUEADO'}">
                                    <form method="post"
                                        action="${pageContext.request.contextPath}/AdminServlet"
                                        class="d-inline"
                                        onsubmit="return confirm('¿Bloquear a ${u.correo}?');">
                                        <input type="hidden" name="accion" value="cambiarEstado">
                                        <input type="hidden" name="id" value="${u.idUsuario}">
                                        <input type="hidden" name="estado" value="BLOQUEADO">
                                        <button class="btn btn-sm btn-outline-danger">Bloquear</button>
                                    </form>
                                </c:if>
                                <c:if test="${u.estado != 'INACTIVO'}">
                                    <form method="post"
                                        action="${pageContext.request.contextPath}/AdminServlet"
                                        class="d-inline"
                                        onsubmit="return confirm('¿Inactivar a ${u.correo}?');">
                                        <input type="hidden" name="accion" value="cambiarEstado">
                                        <input type="hidden" name="id" value="${u.idUsuario}">
                                        <input type="hidden" name="estado" value="INACTIVO">
                                        <button class="btn btn-sm btn-outline-secondary">Inactivar</button>
                                    </form>
                                </c:if>
                                </div>
                            </div>
                            </td>
                        </tr>
                        </c:forEach>
                    </tbody>
                </table>
            </div>
        </div>
    </div>
</div>
</body>
</html>
