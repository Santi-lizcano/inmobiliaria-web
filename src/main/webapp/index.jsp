<%@ page contentType="text/html; charset=UTF-8" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<%@ page import="com.inmobiliaria.dao.PropiedadDAO" %>
<%@ page import="com.inmobiliaria.modelo.Propiedad" %>
<%@ page import="java.util.List" %>
<%
    // Cargar hasta 6 propiedades disponibles para mostrar como destacadas
    List<Propiedad> destacadas = null;
    try {
        PropiedadDAO dao = new PropiedadDAO();
        destacadas = dao.listar(null, null, null, null, "DISPONIBLE");
        if (destacadas != null && destacadas.size() > 6) {
            destacadas = destacadas.subList(0, 6);
        }
    } catch (Exception e) {
        destacadas = java.util.Collections.emptyList();
    }
    request.setAttribute("destacadas", destacadas);
%>
<!DOCTYPE html>
<html lang="es">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1">
    <title>Inmobiliaria UTS · Encuentra tu hogar</title>

    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.2/dist/css/bootstrap.min.css" rel="stylesheet">
    <link rel="stylesheet" href="${pageContext.request.contextPath}/css/estilos.css">
</head>
<body>

<!-- ==================== NAVBAR ==================== -->
<nav class="navbar navbar-expand-lg navbar-dark bg-primary shadow-sm">
    <div class="container">
        <a class="navbar-brand" href="${pageContext.request.contextPath}/">
            🏠 Inmobiliaria UTS
        </a>

        <button class="navbar-toggler" type="button"
                data-bs-toggle="collapse" data-bs-target="#menuPrincipal">
            <span class="navbar-toggler-icon"></span>
        </button>

        <div class="collapse navbar-collapse" id="menuPrincipal">
            <ul class="navbar-nav ms-auto align-items-lg-center">
                <li class="nav-item">
                    <a class="nav-link" href="#destacadas">Propiedades</a>
                </li>
                <li class="nav-item">
                    <a class="nav-link" href="#nosotros">Nosotros</a>
                </li>

                <%-- Si hay sesión activa, mostramos "Mi panel" --%>
                <c:choose>
                    <c:when test="${not empty sessionScope.idUsuario}">
                        <li class="nav-item">
                            <c:choose>
                                <c:when test="${sessionScope.roles.contains('ADMINISTRADOR')}">
                                    <a class="nav-link"
                                       href="${pageContext.request.contextPath}/dashboard/admin.jsp">
                                        Mi panel
                                    </a>
                                </c:when>
                                <c:when test="${sessionScope.roles.contains('INMOBILIARIA')}">
                                    <a class="nav-link"
                                       href="${pageContext.request.contextPath}/dashboard/inmobiliaria.jsp">
                                        Mi panel
                                    </a>
                                </c:when>
                                <c:otherwise>
                                    <a class="nav-link"
                                       href="${pageContext.request.contextPath}/dashboard/cliente.jsp">
                                        Mi panel
                                    </a>
                                </c:otherwise>
                            </c:choose>
                        </li>
                        <li class="nav-item ms-lg-2">
                            <a class="btn btn-light btn-sm"
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
                        <li class="nav-item ms-lg-2">
                            <a class="btn btn-warning btn-sm fw-bold"
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

<!-- ==================== HERO ==================== -->
<header class="hero text-center">
    <div class="container">
        <h1 class="display-5 display-md-3">
            Encuentra el inmueble de tus sueños
        </h1>
        <p class="lead">
            Casas, apartamentos, locales, oficinas y terrenos
            en las mejores ciudades del país.
        </p>

        <!-- Buscador rápido -->
        <div class="search-box mx-auto" style="max-width: 900px;">
            <form class="row g-2 align-items-end"
                  action="${pageContext.request.contextPath}/PropiedadServlet"
                  method="get">
                <input type="hidden" name="accion" value="listar">

                <div class="col-md-3">
                    <label class="form-label small fw-bold text-dark">Ciudad</label>
                    <input type="text" class="form-control" name="ciudad"
                           placeholder="Ej: Bucaramanga">
                </div>

                <div class="col-md-3">
                    <label class="form-label small fw-bold text-dark">Tipo</label>
                    <select class="form-select" name="tipo">
                        <option value="">Todos</option>
                        <option>Casa</option>
                        <option>Apartamento</option>
                        <option>Local</option>
                        <option>Oficina</option>
                        <option>Terreno</option>
                    </select>
                </div>

                <div class="col-md-3">
                    <label class="form-label small fw-bold text-dark">Precio máximo</label>
                    <input type="number" class="form-control" name="precioMax"
                           placeholder="Ej: 500000000">
                </div>

                <div class="col-md-3">
                    <button class="btn btn-warning w-100 fw-bold py-2">
                        🔍 Buscar
                    </button>
                </div>
            </form>
        </div>
    </div>
</header>

<!-- ==================== FEATURES ==================== -->
<section class="py-5 bg-light" id="nosotros">
    <div class="container">
        <div class="text-center mb-5">
            <h2 class="section-titulo">¿Por qué elegirnos?</h2>
            <p class="section-subtitulo">
                Más de 10 años conectando personas con el hogar perfecto.
            </p>
        </div>

        <div class="row g-4 text-center">
            <div class="col-md-4">
                <div class="icono-feature">🏘️</div>
                <h5>Amplio catálogo</h5>
                <p class="text-muted">
                    Cientos de propiedades verificadas en las principales
                    ciudades del país.
                </p>
            </div>
            <div class="col-md-4">
                <div class="icono-feature">🔒</div>
                <h5>Compra segura</h5>
                <p class="text-muted">
                    Acompañamiento jurídico en cada etapa del proceso
                    de compra o arriendo.
                </p>
            </div>
            <div class="col-md-4">
                <div class="icono-feature">📞</div>
                <h5>Atención personalizada</h5>
                <p class="text-muted">
                    Agentes disponibles para agendar visitas y resolver
                    todas tus dudas.
                </p>
            </div>
        </div>
    </div>
</section>

<!-- ==================== PROPIEDADES DESTACADAS ==================== -->
<section class="py-5" id="destacadas">
    <div class="container">
        <div class="text-center mb-5">
            <h2 class="section-titulo">Propiedades destacadas</h2>
            <p class="section-subtitulo">
                Una selección de los inmuebles más consultados esta semana.
            </p>
        </div>

        <div class="row g-4">
            <c:choose>
                <c:when test="${not empty destacadas}">
                    <c:forEach var="p" items="${destacadas}">
                        <div class="col-md-6 col-lg-4">
                            <div class="card card-propiedad position-relative">
                                <img src="${not empty p.imagenes ? p.imagenes[0] : 'https://via.placeholder.com/400x220'}"
                                     alt="${p.titulo}">
                                <span class="badge badge-estado badge-estado-${p.estado}">
                                    ${p.estado}
                                </span>

                                <div class="card-body">
                                    <h5 class="card-title">${p.titulo}</h5>
                                    <p class="text-muted small mb-2">
                                        📍 ${p.nombreCiudad} · ${p.nombreTipo}
                                    </p>
                                    <p class="precio mb-3">
                                        $ ${p.precio}
                                    </p>

                                    <a href="${pageContext.request.contextPath}/PropiedadServlet?accion=ver&id=${p.idPropiedad}"
                                       class="btn btn-outline-primary btn-sm w-100">
                                        Ver detalle
                                    </a>
                                </div>
                            </div>
                        </div>
                    </c:forEach>
                </c:when>

                <c:otherwise>
                    <%-- Si no hay destacadas cargadas desde el servidor,
                         mostramos un mensaje y un botón para explorar todo. --%>
                    <div class="col-12 text-center">
                        <div class="alert alert-info">
                            Aún no hay propiedades publicadas.
                            <c:if test="${sessionScope.roles.contains('INMOBILIARIA')
                                          or sessionScope.roles.contains('ADMINISTRADOR')}">
                                <a href="${pageContext.request.contextPath}/PropiedadServlet?accion=formularioNuevo"
                                   class="alert-link">Publica la primera</a>.
                            </c:if>
                        </div>
                    </div>
                </c:otherwise>
            </c:choose>
        </div>

        <div class="text-center mt-5">
            <a href="${pageContext.request.contextPath}/PropiedadServlet?accion=listar"
               class="btn btn-primary px-4 py-2">
                Ver todas las propiedades →
            </a>
        </div>
    </div>
</section>

<!-- ==================== CTA FINAL ==================== -->
<section class="py-5 bg-primary text-white text-center">
    <div class="container">
        <h2 class="mb-3">¿Listo para encontrar tu próximo hogar?</h2>
        <p class="mb-4">
            Regístrate gratis y comienza a agendar visitas hoy mismo.
        </p>

        <c:choose>
            <c:when test="${empty sessionScope.idUsuario}">
                <a href="${pageContext.request.contextPath}/registro.jsp"
                   class="btn btn-warning btn-lg fw-bold px-5">
                    Crear cuenta gratis
                </a>
            </c:when>
            <c:otherwise>
                <a href="${pageContext.request.contextPath}/PropiedadServlet?accion=listar"
                   class="btn btn-warning btn-lg fw-bold px-5">
                    Explorar propiedades
                </a>
            </c:otherwise>
        </c:choose>
    </div>
</section>

<!-- ==================== FOOTER ==================== -->
<footer>
    <div class="container">
        <div class="row g-4">
            <div class="col-md-5">
                <h5 class="text-white">🏠 Inmobiliaria UTS</h5>
                <p class="small mb-0">
                    Proyecto académico de Programación Java · Unidades
                    Tecnológicas de Santander. Gestión completa de
                    propiedades, citas y solicitudes.
                </p>
            </div>

            <div class="col-md-3">
                <h6 class="text-white">Enlaces</h6>
                <ul class="list-unstyled small">
                    <li><a href="#destacadas">Propiedades</a></li>
                    <li><a href="#nosotros">Nosotros</a></li>
                    <li><a href="${pageContext.request.contextPath}/login.jsp">Iniciar sesión</a></li>
                    <li><a href="${pageContext.request.contextPath}/registro.jsp">Registrarse</a></li>
                </ul>
            </div>

            <div class="col-md-4">
                <h6 class="text-white">Contacto</h6>
                <p class="small mb-1">📧 contacto@inmobiliaria-uts.com</p>
                <p class="small mb-1">📞 (607) 000-0000</p>
                <p class="small mb-0">📍 Bucaramanga, Santander</p>
            </div>
        </div>

        <hr class="border-secondary my-4">

        <p class="text-center small mb-0">
            © 2026 Inmobiliaria UTS · Todos los derechos reservados.
        </p>
    </div>
</footer>

<script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.2/dist/js/bootstrap.bundle.min.js"></script>
</body>
</html>