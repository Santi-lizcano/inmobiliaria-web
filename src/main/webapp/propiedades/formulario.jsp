<%@ page contentType="text/html; charset=UTF-8" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<!DOCTYPE html>
<html lang="es">
<head>
    <meta charset="UTF-8">
    <title>${propiedad.idPropiedad > 0 ? 'Editar' : 'Nueva'} propiedad</title>
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.2/dist/css/bootstrap.min.css" rel="stylesheet">
    <link rel="stylesheet" href="${pageContext.request.contextPath}/css/estilos.css">
</head>
<body>
<nav class="navbar navbar-dark bg-primary">
    <div class="container">
        <a class="navbar-brand" href="${pageContext.request.contextPath}/dashboard/inmobiliaria.jsp">
            🏠 Panel Inmobiliaria
        </a>
        <a href="${pageContext.request.contextPath}/LogoutServlet" class="btn btn-outline-light btn-sm">Salir</a>
    </div>
</nav>

<div class="container my-4">
    <h2>${propiedad.idPropiedad > 0 ? 'Editar' : 'Publicar nueva'} propiedad</h2>

    <c:if test="${not empty error}">
        <div class="alert alert-danger">${error}</div>
    </c:if>

    <form method="post"
          action="${pageContext.request.contextPath}/PropiedadServlet"
          enctype="multipart/form-data" class="row g-3">

        <input type="hidden" name="accion" value="${propiedad.idPropiedad > 0 ? 'actualizar' : 'crear'}">
        <c:if test="${propiedad.idPropiedad > 0}">
            <input type="hidden" name="id" value="${propiedad.idPropiedad}">
        </c:if>

        <div class="col-md-4">
            <label class="form-label">Matrícula inmobiliaria *</label>
            <input type="text" name="matricula" class="form-control" required
                   value="${propiedad.matriculaInmobiliaria}"
                   ${propiedad.idPropiedad > 0 ? 'readonly' : ''}>
        </div>
        <div class="col-md-8">
            <label class="form-label">Título *</label>
            <input type="text" name="titulo" class="form-control" required value="${propiedad.titulo}">
        </div>

        <div class="col-12">
            <label class="form-label">Descripción</label>
            <textarea name="descripcion" class="form-control" rows="3">${propiedad.descripcion}</textarea>
        </div>

        <div class="col-md-3">
            <label class="form-label">Precio *</label>
            <input type="number" step="0.01" name="precio" class="form-control" required value="${propiedad.precio}">
        </div>
        <div class="col-md-3">
            <label class="form-label">Área m²</label>
            <input type="number" step="0.01" name="areaM2" class="form-control" value="${propiedad.areaM2}">
        </div>
        <div class="col-md-2">
            <label class="form-label">Habitaciones</label>
            <input type="number" name="habitaciones" class="form-control" value="${propiedad.habitaciones}">
        </div>
        <div class="col-md-2">
            <label class="form-label">Baños</label>
            <input type="number" name="banos" class="form-control" value="${propiedad.banos}">
        </div>
        <div class="col-md-2">
            <label class="form-label">Estado</label>
            <select name="estado" class="form-select">
                <c:forEach var="e" items="${['DISPONIBLE','RESERVADA','VENDIDA','ARRENDADA','INACTIVA']}">
                    <option value="${e}" ${propiedad.estado == e ? 'selected' : ''}>${e}</option>
                </c:forEach>
            </select>
        </div>

        <div class="col-md-6">
            <label class="form-label">Tipo *</label>
            <select name="idTipo" class="form-select" required>
                <option value="">-- Seleccione --</option>
                <c:forEach var="t" items="${tipos}">
                    <option value="${t[0]}" ${propiedad.idTipo == t[0] ? 'selected' : ''}>${t[1]}</option>
                </c:forEach>
            </select>
        </div>
        <div class="col-md-6">
            <label class="form-label">Ciudad *</label>
            <select name="idCiudad" class="form-select" required>
                <option value="">-- Seleccione --</option>
                <c:forEach var="c" items="${ciudades}">
                    <option value="${c[0]}" ${propiedad.idCiudad == c[0] ? 'selected' : ''}>${c[1]}</option>
                </c:forEach>
            </select>
        </div>

        <div class="col-12">
            <label class="form-label">Dirección</label>
            <input type="text" name="direccion" class="form-control" value="${propiedad.direccion}">
        </div>

        <!-- Características (N:M) -->
        <div class="col-12">
            <label class="form-label">Características</label>
            <div class="row">
                <c:forEach var="ca" items="${caracteristicas}">
                    <div class="col-md-3">
                        <div class="form-check">
                            <input class="form-check-input" type="checkbox" name="car"
                                   value="${ca[0]}"
                                   <c:if test="${caracteristicasSeleccionadas != null && caracteristicasSeleccionadas.contains(Integer.parseInt(ca[0]))}">checked</c:if>>
                            <label class="form-check-label">${ca[1]}</label>
                        </div>
                    </div>
                </c:forEach>
            </div>
        </div>

        <!-- Imágenes (1:N) -->
        <div class="col-12">
            <label class="form-label">Imágenes (múltiples)</label>
            <input type="file" name="imagenes" class="form-control" accept="image/*" multiple>
            <small class="text-muted">Si no subes nuevas, se conservan las existentes al editar.</small>
        </div>

        <div class="col-12 mt-3">
            <button class="btn btn-primary">Guardar</button>
            <a href="${pageContext.request.contextPath}/PropiedadServlet?accion=listar"
               class="btn btn-secondary">Cancelar</a>
        </div>
    </form>
</div>
</body>
</html>
