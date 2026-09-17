<%@ page contentType="text/html; charset=UTF-8" %>
<!DOCTYPE html>
<html lang="es">
<head>
    <meta charset="UTF-8">
    <title>Acceso denegado</title>
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.2/dist/css/bootstrap.min.css" rel="stylesheet">
</head>
<body class="bg-light d-flex align-items-center" style="min-height:100vh;">

<div class="container">
    <div class="row justify-content-center">
        <div class="col-md-6 text-center">

            <div class="card shadow border-danger">
                <div class="card-body p-5">
                    <div class="display-1 text-danger">🚫</div>
                    <h2 class="mt-3">Acceso denegado</h2>
                    <p class="text-muted">
                        No tienes permisos para ingresar a esta sección.
                        Si crees que es un error, contacta al administrador del sistema.
                    </p>

                    <div class="d-grid gap-2 mt-4">
                        <a href="${pageContext.request.contextPath}/"
                           class="btn btn-primary">Volver al inicio</a>

                        <%
                            // Si hay sesión activa, ofrecer volver al panel correspondiente
                            if (session != null && session.getAttribute("roles") != null) {
                                java.util.List<String> roles =
                                    (java.util.List<String>) session.getAttribute("roles");
                                String panel = "cliente";
                                if (roles.contains("ADMINISTRADOR")) panel = "admin";
                                else if (roles.contains("INMOBILIARIA")) panel = "inmobiliaria";
                        %>
                            <a href="${pageContext.request.contextPath}/dashboard/<%= panel %>.jsp"
                               class="btn btn-outline-secondary">Ir a mi panel</a>
                        <%
                            } else {
                        %>
                            <a href="${pageContext.request.contextPath}/login.jsp"
                               class="btn btn-outline-secondary">Iniciar sesión</a>
                        <%
                            }
                        %>
                    </div>
                </div>
            </div>

            <p class="text-muted mt-3 small">
                Código: 403 Forbidden · <%= new java.util.Date() %>
            </p>

        </div>
    </div>
</div>
</body>
</html>
