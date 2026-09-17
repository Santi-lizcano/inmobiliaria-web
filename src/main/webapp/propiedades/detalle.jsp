<%@ page contentType="text/html; charset=UTF-8" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<!DOCTYPE html>
<html lang="es">
<head>
    <meta charset="UTF-8">
    <title>${propiedad.titulo}</title>
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.2/dist/css/bootstrap.min.css" rel="stylesheet">
</head>
<body>
<nav class="navbar navbar-dark bg-primary">
    <div class="container">
        <a class="navbar-brand" href="${pageContext.request.contextPath}/">🏠 Inmobiliaria UTS</a>
        <a href="${pageContext.request.contextPath}/PropiedadServlet?accion=listar"
           class="btn btn-outline-light btn-sm">Volver</a>
    </div>
</nav>

<div class="container my-4">
    <h2>${propiedad.titulo}</h2>
    <p class="text-muted">📍 ${propiedad.nombreCiudad} · ${propiedad.nombreTipo} · ${propiedad.razonSocialInmobiliaria}</p>

    <!-- Galería -->
    <div class="row g-2 mb-4">
        <c:forEach var="img" items="${propiedad.imagenes}">
            <div class="col-md-3">
                <img src="${img}" class="img-fluid rounded" style="height:180px;object-fit:cover;">
            </div>
        </c:forEach>
        <c:if test="${empty propiedad.imagenes}">
            <div class="alert alert-secondary">Sin imágenes registradas.</div>
        </c:if>
    </div>

    <div class="row">
        <div class="col-md-8">
            <h4>Descripción</h4>
            <p>${propiedad.descripcion}</p>

            <h5>Características</h5>
            <ul>
                <c:forEach var="ca" items="${propiedad.caracteristicas}">
                    <li>${ca}</li>
                </c:forEach>
            </ul>
        </div>

        <div class="col-md-4">
            <div class="card p-3 shadow-sm">
                <h3 class="text-primary">$ ${propiedad.precio}</h3>
                <p><strong>Área:</strong> ${propiedad.areaM2} m²</p>
                <p><strong>Habitaciones:</strong> ${propiedad.habitaciones}</p>
                <p><strong>Baños:</strong> ${propiedad.banos}</p>
                <p><strong>Dirección:</strong> ${propiedad.direccion}</p>
                <p><strong>Estado:</strong> <span class="badge bg-success">${propiedad.estado}</span></p>

                <c:if test="${sessionScope.roles.contains('CLIENTE')}">
                    <a href="${pageContext.request.contextPath}/CitaServlet?accion=formulario&id=${propiedad.idPropiedad}"
                    class="btn btn-warning w-100 mt-2">📅 Agendar visita</a>

                    <a href="${pageContext.request.contextPath}/FavoritoServlet?accion=agregar&id=${propiedad.idPropiedad}"
                    class="btn btn-outline-danger w-100 mt-2">❤️ Guardar en favoritos</a>
                </c:if>
            </div>
        </div>
    </div>
</div>
</body>
</html>
