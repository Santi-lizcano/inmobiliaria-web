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
    <title>Mis favoritos</title>
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.2/dist/css/bootstrap.min.css" rel="stylesheet">
    <link rel="stylesheet" href="${pageContext.request.contextPath}/css/estilos.css">
</head>
<body class="bg-light">

<nav class="navbar navbar-dark bg-success">
    <div class="container-fluid">
        <a class="navbar-brand" href="${pageContext.request.contextPath}/dashboard/cliente.jsp">
            ❤️ Mis favoritos
        </a>
        <a href="${pageContext.request.contextPath}/LogoutServlet"
           class="btn btn-outline-light btn-sm">Salir</a>
    </div>
</nav>

<div class="container my-4">

    <div class="d-flex justify-content-between align-items-center mb-3">
        <h2>Propiedades guardadas (${favoritos.size()})</h2>
        <a href="${pageContext.request.contextPath}/dashboard/cliente.jsp"
           class="btn btn-outline-secondary btn-sm">← Volver al panel</a>
    </div>

    <c:if test="${empty favoritos}">
        <div class="alert alert-info">
            Aún no has guardado propiedades en favoritos.
            <a href="${pageContext.request.contextPath}/PropiedadServlet?accion=listar">
                Explorar catálogo
            </a>
        </div>
    </c:if>

    <div class="row g-4">
        <c:forEach var="p" items="${favoritos}">
            <div class="col-md-6 col-lg-4">
                <div class="card shadow-sm h-100">
                    <img src="${not empty p.imagenes ? p.imagenes[0] : 'https://via.placeholder.com/400x200'}"
                         class="card-img-top" style="height:200px;object-fit:cover;">

                    <div class="card-body d-flex flex-column">
                        <h5>${p.titulo}</h5>
                        <p class="text-muted mb-1">
                            📍 ${p.nombreCiudad} · ${p.nombreTipo}
                        </p>
                        <p class="fw-bold text-primary mb-2">$ ${p.precio}</p>
                        <span class="badge bg-secondary mb-2 align-self-start">${p.estado}</span>

                        <div class="mt-auto d-flex gap-2">
                            <a class="btn btn-sm btn-outline-primary flex-fill"
                               href="${pageContext.request.contextPath}/PropiedadServlet?accion=ver&id=${p.idPropiedad}">
                                Ver detalle
                            </a>
                            <a class="btn btn-sm btn-outline-danger"
                               href="${pageContext.request.contextPath}/FavoritoServlet?accion=quitar&id=${p.idPropiedad}"
                               onclick="return confirm('¿Quitar de favoritos?');">
                                💔 Quitar
                            </a>
                        </div>
                    </div>
                </div>
            </div>
        </c:forEach>
    </div>

</div>
</body>
</html>
