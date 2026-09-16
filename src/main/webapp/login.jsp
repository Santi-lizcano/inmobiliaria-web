<%@ page contentType="text/html; charset=UTF-8" %>
<!DOCTYPE html>
<html lang="es">
<head>
    <meta charset="UTF-8">
    <title>Iniciar sesión</title>
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.2/dist/css/bootstrap.min.css" rel="stylesheet">
</head>
<body class="bg-light d-flex align-items-center" style="min-height:100vh;">

<div class="container">
    <div class="row justify-content-center">
        <div class="col-md-5">
            <div class="card shadow">
                <div class="card-body p-4">
                    <h3 class="text-center mb-3">Iniciar sesión</h3>

                    <% if (request.getParameter("error") != null) { %>
                        <div class="alert alert-danger">
                            <%= "credenciales".equals(request.getParameter("error"))
                                ? "Correo o contraseña incorrectos."
                                : "Debes iniciar sesión para continuar." %>
                        </div>
                    <% } %>
                    <% if ("registrado".equals(request.getParameter("ok"))) { %>
                        <div class="alert alert-success">Registro exitoso. Ya puedes iniciar sesión.</div>
                    <% } %>

                    <form action="${pageContext.request.contextPath}/LoginServlet" method="post">
                        <div class="mb-3">
                            <label class="form-label">Correo</label>
                            <input type="email" name="correo" class="form-control" required>
                        </div>
                        <div class="mb-3">
                            <label class="form-label">Contraseña</label>
                            <input type="password" name="password" class="form-control" required>
                        </div>
                        <button class="btn btn-primary w-100">Ingresar</button>
                    </form>

                    <p class="text-center mt-3 mb-0">
                        ¿No tienes cuenta? <a href="${pageContext.request.contextPath}/registro.jsp">Regístrate</a>
                    </p>
                </div>
            </div>
        </div>
    </div>
</div>
</body>
</html>
