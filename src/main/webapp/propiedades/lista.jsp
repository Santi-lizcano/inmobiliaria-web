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
        <div>
            <c:if test="${sessionScope.roles.contains('INMOBILIARIA') or sessionScope.roles.contains('ADMINISTRADOR')}">
                <a href="${pageContext.request.contextPath}/PropiedadServlet?accion=formularioNuevo"
                   class="btn btn-light btn-sm">+ Nueva propiedad</a>
            </c:if>
            <a href="${pageContext.request.contextPath}/LogoutServlet" class="btn btn-outline-light btn-sm">Salir</a>
        </div>
    </div>
</nav>

<div class="container my-4">
    <h2>Propiedades</h2>

    <form method="get" action="${pageContext.request.contextPath}/PropiedadServlet"
          class="row g-2 mb-4">
        <input type="hidden" name="accion" value="listar">

        <div class="col-md-2">
            <select class="form-select" name="ciudad">
                <option value="">Ciudad</option>
                <c:forEach var="c" items="${ciudades}">
                    <option value="${c[1]}" ${param.ciudad == c[1] ? 'selected' : ''}>${c[1]}</option>
                </c:forEach>
            </select>
        </div>
        <div class="col-md-2">
            <select class="form-select" name="tipo">
                <option value="">Tipo</option>
                <c:forEach var="t" items="${tipos}">
                    <option value="${t[1]}" ${param.tipo == t[1] ? 'selected' : ''}>${t[1]}</option>
                </c:forEach>
            </select>
        </div>
        <div class="col-md-2">
            <input type="number" name="precioMax" class="form-control"
                   placeholder="Precio máx" value="${param.precioMax}">
        </div>
        <div class="col-md-3">
            <select class="form-select" name="estado">
                <option value="">Estado</option>
                <option value="DISPONIBLE" ${param.estado == 'DISPONIBLE' ? 'selected' : ''}>DISPONIBLE</option>
                <option value="RESERVADA"  ${param.estado == 'RESERVADA'  ? 'selected' : ''}>RESERVADA</option>
                <option value="VENDIDA"    ${param.estado == 'VENDIDA'    ? 'selected' : ''}>VENDIDA</option>
                <option value="ARRENDADA"  ${param.estado == 'ARRENDADA'  ? 'selected' : ''}>ARRENDADA</option>
            </select>
        </div>
        <div class="col-md-3">
            <button class="btn btn-primary w-100">Filtrar</button>
        </div>

        <div class="col-12">
            <small class="text-muted">Características:</small>
            <c:forEach var="ca" items="${caracteristicas}">
                <div class="form-check form-check-inline">
                    <input class="form-check-input" type="checkbox" name="car" value="${ca[0]}">
                    <label class="form-check-label">${ca[1]}</label>
                </div>
            </c:forEach>
        </div>
    </form>

    <div class="row g-4">
        <c:forEach var="p" items="${propiedades}">
            <div class="col-md-4">
                <div class="card h-100 shadow-sm">
                    <img src="${not empty p.imagenes ? p.imagenes[0] : 'https://via.placeholder.com/400x200'}"
                         class="card-img-top" style="height:200px;object-fit:cover;">
                    <div class="card-body d-flex flex-column">
                        <h5>${p.titulo}</h5>
                        <p class="text-muted mb-1">📍 ${p.nombreCiudad} · ${p.nombreTipo}</p>
                        <p class="fw-bold text-primary">$ ${p.precio}</p>
                        <span class="badge bg-secondary mb-2">${p.estado}</span>

                        <div class="mt-auto">
                            <a class="btn btn-sm btn-outline-primary"
                               href="${pageContext.request.contextPath}/PropiedadServlet?accion=ver&id=${p.idPropiedad}">
                               Ver detalle
                            </a>
                            <c:if test="${sessionScope.roles.contains('INMOBILIARIA') or sessionScope.roles.contains('ADMINISTRADOR')}">
                                <a class="btn btn-sm btn-outline-warning"
                                   href="${pageContext.request.contextPath}/PropiedadServlet?accion=formularioEditar&id=${p.idPropiedad}">
                                   Editar
                                </a>
                                <a class="btn btn-sm btn-outline-danger"
                                   href="${pageContext.request.contextPath}/PropiedadServlet?accion=baja&id=${p.idPropiedad}"
                                   onclick="return confirm('¿Dar de baja esta propiedad?');">
                                   Baja
                                </a>
                            </c:if>
                        </div>
                    </div>
                </div>
            </div>
        </c:forEach>

        <c:if test="${empty propiedades}">
            <div class="alert alert-info">No hay propiedades con esos filtros.</div>
        </c:if>
    </div>
</div>
</body>
</html>
