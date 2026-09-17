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

    <div class="card shadow-sm">
        <div class="card-body p-3">
            <p class="text-muted mb-0">
                Para asignar un rol a un usuario: selecciona rol y usuario, y presiona <strong>Asignar</strong>.
                Para revocar: hazlo desde la lista de asignaciones de abajo.
            </p>
        </div>
    </div>

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
    <div class="card shadow-sm">
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
                                        <c:otherwise>
                                            <span class="badge bg-secondary">${u.estado}</span>
                                        </c:otherwise>
                                    </c:choose>
                                </td>
                                <td>
                                    <%-- Nota: para ver los roles por fila necesitas
                                         una consulta adicional; aquí mostramos un botón
                                         para ir al detalle del usuario. --%>
                                    <a class="btn btn-sm btn-outline-secondary"
                                       href="${pageContext.request.contextPath}/AdminServlet?accion=editarUsuario&id=${u.idUsuario}">
                                        Ver roles
                                    </a>
                                </td>
                                <td>
                                    <form method="post"
                                          action="${pageContext.request.contextPath}/AdminServlet"
                                          class="row g-1">
                                        <input type="hidden" name="accion" value="revocarRol">
                                        <input type="hidden" name="idUsuario" value="${u.idUsuario}">
                                        <div class="col-8">
                                            <select name="idRol" class="form-select form-select-sm">
                                                <option value="">Rol a revocar</option>
                                                <c:forEach var="r" items="${rolesDisponibles}">
                                                    <option value="${r[0]}">${r[1]}</option>
                                                </c:forEach>
                                            </select>
                                        </div>
                                        <div class="col-4">
                                            <button class="btn btn-sm btn-outline-danger w-100">Revocar</button>
                                        </div>
                                    </form>
                                </td>
                            </tr>
                        </c:forEach>
                    </tbody>
                </table>
            </div>
        </div>
    </div>

    <div class="alert alert-info mt-4">
        <strong>💡 Nota:</strong> la tabla <code>usuario_rol</code> tiene clave primaria compuesta
        <code>(id_usuario, id_rol)</code>, por lo que es imposible asignar el mismo rol dos veces
        a un usuario (relación N:M).
    </div>

</div>
</body>
</html>
