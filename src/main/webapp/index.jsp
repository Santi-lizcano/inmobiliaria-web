<%@ page contentType="text/html; charset=UTF-8" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<!DOCTYPE html>
<html lang="es">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1">
    <title>Inmobiliaria UTS - Encuentra tu hogar</title>
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.2/dist/css/bootstrap.min.css" rel="stylesheet">
    <link rel="stylesheet" href="${pageContext.request.contextPath}/css/estilos.css">
</head>
<body>

<!-- NAVBAR -->
<nav class="navbar navbar-expand-lg navbar-dark bg-primary">
    <div class="container">
        <a class="navbar-brand fw-bold" href="${pageContext.request.contextPath}/">🏠 Inmobiliaria UTS</a>
        <button class="navbar-toggler" type="button" data-bs-toggle="collapse" data-bs-target="#nav">
            <span class="navbar-toggler-icon"></span>
        </button>
        <div class="collapse navbar-collapse" id="nav">
            <ul class="navbar-nav ms-auto">
    <li class="nav-item">
        <a class="nav-link" href="#propiedades">Propiedades</a>
    </li>

    <c:choose>
        <c:when test="${not empty sessionScope.idUsuario}">
            
            <li class="nav-item">
                <c:choose>

                    <c:when test="${sessionScope.roles.contains('ADMINISTRADOR')}">
                        <a class="btn btn-light btn-sm ms-2"
                           href="${pageContext.request.contextPath}/dashboard/admin.jsp">
                            Mi panel
                        </a>
                    </c:when>

                    <c:when test="${sessionScope.roles.contains('INMOBILIARIA')}">
                        <a class="btn btn-light btn-sm ms-2"
                           href="${pageContext.request.contextPath}/dashboard/inmobiliaria.jsp">
                            Mi panel
                        </a>
                    </c:when>

                    <c:otherwise>
                        <a class="btn btn-light btn-sm ms-2"
                           href="${pageContext.request.contextPath}/dashboard/cliente.jsp">
                            Mi panel
                        </a>
                    </c:otherwise>

                </c:choose>
            </li>

            <li class="nav-item">
                <a class="nav-link"
                   href="${pageContext.request.contextPath}/LogoutServlet">
                    Salir
                </a>
            </li>

        </c:when>

        <c:otherwise>

            <li class="nav-item">
                <a class="nav-link"
                   href="${pageContext.request.contextPath}/login.jsp">
                    Iniciar sesión
                </a>
            </li>

            <li class="nav-item">
                <a class="btn btn-light btn-sm ms-2"
                   href="${pageContext.request.contextPath}/registro.jsp">
                    Registrarse
                </a>
            </li>

        </c:otherwise>
    </c:choose>
</ul>
        </div>
    </div>
</nav>

<!-- HERO + BUSCADOR -->
<header class="hero text-white text-center py-5">
    <div class="container">
        <h1 class="display-4 fw-bold">Encuentra el inmueble de tus sueños</h1>
        <p class="lead">Casas, apartamentos, locales, oficinas y terrenos en las mejores ciudades del país.</p>

        <form class="row g-2 justify-content-center mt-4" action="${pageContext.request.contextPath}/propiedades/lista.jsp" method="get">
            <div class="col-md-3">
                <input type="text" class="form-control" name="ciudad" placeholder="Ciudad">
            </div>
            <div class="col-md-3">
                <select class="form-select" name="tipo">
                    <option value="">Tipo de inmueble</option>
                    <option>Casa</option>
                    <option>Apartamento</option>
                    <option>Local</option>
                    <option>Oficina</option>
                    <option>Terreno</option>
                </select>
            </div>
            <div class="col-md-3">
                <input type="number" class="form-control" name="precioMax" placeholder="Precio máximo">
            </div>
            <div class="col-md-2">
                <button class="btn btn-warning w-100 fw-bold">Buscar</button>
            </div>
        </form>
    </div>
</header>

<!-- PROPIEDADES DESTACADAS -->
<section id="propiedades" class="py-5">
    <div class="container">
        <h2 class="text-center mb-4">Propiedades destacadas</h2>
        <div class="row g-4">
            <c:forEach var="p" items="${destacadas}">
                <div class="col-md-4">
                    <div class="card h-100 shadow-sm">
                        <img src="${p.imagenes[0]}" class="card-img-top" alt="${p.titulo}" style="height:200px;object-fit:cover;">
                        <div class="card-body">
                            <h5 class="card-title">${p.titulo}</h5>
                            <p class="text-muted mb-1">📍 ${p.nombreCiudad} - ${p.nombreTipo}</p>
                            <p class="fw-bold text-primary">$ ${p.precio}</p>
                            <a href="${pageContext.request.contextPath}/propiedades/detalle.jsp?id=${p.idPropiedad}"
                               class="btn btn-outline-primary btn-sm">Ver detalle</a>
                        </div>
                    </div>
                </div>
            </c:forEach>
        </div>
    </div>
</section>

<footer class="bg-dark text-white text-center py-3">
    <p class="mb-0">© 2026 Inmobiliaria UTS - Parcial Java</p>
</footer>

<script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.2/dist/js/bootstrap.bundle.min.js"></script>
</body>
</html>

