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
    <title>Cambiar contraseña</title>
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.2/dist/css/bootstrap.min.css" rel="stylesheet">
</head>
<body class="bg-light">

<nav class="navbar navbar-dark bg-success">
    <div class="container-fluid">
        <a class="navbar-brand" href="${pageContext.request.contextPath}/dashboard/cliente.jsp">
            🔒 Cambiar contraseña
        </a>
        <a href="${pageContext.request.contextPath}/LogoutServlet"
           class="btn btn-outline-light btn-sm">Salir</a>
    </div>
</nav>

<div class="container my-5">
    <div class="row justify-content-center">
        <div class="col-md-6">

            <div class="card shadow">
                <div class="card-body p-4">

                    <h3 class="mb-3">🔒 Cambiar contraseña</h3>

                    <c:if test="${not empty error}">
                        <div class="alert alert-danger">${error}</div>
                    </c:if>

                    <form method="post"
                          action="${pageContext.request.contextPath}/ClienteServlet">

                        <input type="hidden" name="accion" value="guardarPassword">

                        <div class="mb-3">
                            <label class="form-label">Contraseña actual *</label>
                            <input type="password" name="passwordActual"
                                   class="form-control" required>
                        </div>

                        <div class="mb-3">
                            <label class="form-label">Nueva contraseña *</label>
                            <input type="password" name="passwordNueva"
                                   class="form-control" minlength="8" required>
                            <small class="text-muted">Mínimo 8 caracteres.</small>
                        </div>

                        <div class="mb-3">
                            <label class="form-label">Confirmar nueva contraseña *</label>
                            <input type="password" name="passwordConfirmar"
                                   class="form-control" minlength="8" required>
                        </div>

                        <div class="d-grid gap-2">
                            <button class="btn btn-primary">Guardar contraseña</button>
                            <a href="${pageContext.request.contextPath}/ClienteServlet?accion=ver"
                               class="btn btn-outline-secondary">Cancelar</a>
                        </div>

                    </form>

                </div>
            </div>

        </div>
    </div>
</div>
</body>
</html>
