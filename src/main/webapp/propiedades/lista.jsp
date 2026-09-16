<%@ page contentType="text/html; charset=UTF-8" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<!DOCTYPE html>
<html lang="es">
<head>
    <meta charset="UTF-8">
    <title>Propiedades</title>
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.2/dist/css/bootstrap.min.css" rel="stylesheet">
</head>
<body>
<nav class="navbar navbar-dark bg-primary">
    <div class="container">
        <a class="navbar-brand" href="${pageContext.request.contextPath}/">🏠 Inmobiliaria UTS</a>
        <a href="${pageContext.request.contextPath}/LogoutServlet" class="btn btn-outline-light btn-sm">Salir</a>
    </div>
</nav>

<div class="container my-4">
    <h2>Propiedades disponibles</h2>

    <!-- Filtros -->
    <form class="row g-2 mb-4" method="get" action="${pageContext.request.contextPath}/PropiedadServlet">
        <input type="hidden" name="accion" value="listar">
        <div class="col-md-3">
            <input class="form-control" name="ciudad" value="${param.ciudad}" placeholder="Ciudad">
        </div>
        <div class="col-md-3">
            <input class="form-control" name="tipo" value="${param.tipo}" placeholder="Tipo">
        </div>
        <div class="col-md-3">
            <input class="form-control" type="number" name="precioMax" value="${param.precioMax}" placeholder="Precio máximo">
        </div>
        <div class="col-md-3">
            <button class="btn btn-primary w-100">Filtrar</button>
        </div>
    </form>

    <div class="row g-4">
        <c:forEach var="p" items="${propiedades}">
            <div class="col-md-4">
                <div class="card h-100 shadow-sm">
                    <img src="${not empty p.imagenes ? p.imagenes[0] : 'https://via.placeholder.com/400x200'}"
                         class="card-img-top" style="height:200px;object-fit:cover;">
                    <div class="card-body">
                        <h5>${p.titulo}</h5>
                        <p class="text-muted mb-1">📍 ${p.nombreCiudad} · ${p.nombreTipo}</p>
                        <p class="fw-bold text-primary">$ ${p.precio}</p>
                        <a class="btn btn-sm btn-outline-primary"
                           href="${pageContext.request.contextPath}/propiedades/detalle.jsp?id=${p.idPropiedad}">
                           Ver detalle
                        </a>
                    </div>
                </div>
            </div>
        </c:forEach>
        <c:if test="${empty propiedades}">
            <div class="alert alert-info">No se encontraron propiedades con esos filtros.</div>
        </c:if>
    </div>
</div>
</body>
</html>
