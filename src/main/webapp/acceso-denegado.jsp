<%@ taglib prefix="c" uri="jakarta.tags.core" %>
...
<div class="d-grid gap-2 mt-4">
    <link rel="stylesheet" href="${pageContext.request.contextPath}/css/estilos.css">
    <a href="${pageContext.request.contextPath}/" class="btn btn-primary">Volver al inicio</a>

    <c:choose>
        <c:when test="${sessionScope.roles.contains('ADMINISTRADOR')}">
            <a href="${pageContext.request.contextPath}/dashboard/admin.jsp"
               class="btn btn-outline-secondary">Ir a mi panel</a>
        </c:when>
        <c:when test="${sessionScope.roles.contains('INMOBILIARIA')}">
            <a href="${pageContext.request.contextPath}/dashboard/inmobiliaria.jsp"
               class="btn btn-outline-secondary">Ir a mi panel</a>
        </c:when>
        <c:when test="${sessionScope.roles.contains('CLIENTE')}">
            <a href="${pageContext.request.contextPath}/dashboard/cliente.jsp"
               class="btn btn-outline-secondary">Ir a mi panel</a>
        </c:when>
        <c:otherwise>
            <a href="${pageContext.request.contextPath}/login.jsp"
               class="btn btn-outline-secondary">Iniciar sesión</a>
        </c:otherwise>
    </c:choose>
</div>
