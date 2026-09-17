# Inmobiliaria UTS · Proyecto Java Web

Aplicación web dinámica para la administración de una inmobiliaria,
desarrollada con **Java EE (JSP + Servlets)**, **JDBC**, **MySQL** y
**Bootstrap 5**, siguiendo el patrón MVC y el marco de trabajo **Scrum**
(3 sprints de 7 días).

---

## 👥 Roles del sistema

- **Visitante** (no autenticado): explora landing, catálogo y detalle.
- **Cliente**: agenda citas, radica solicitudes, guarda favoritos.
- **Inmobiliaria**: publica/edita propiedades, gestiona citas y solicitudes.
- **Administrador**: gestiona usuarios, roles, catálogos y reportes.

---

## 🧱 Tecnologías

| Capa | Tecnología |
|------|------------|
| Backend | Java 17 · Jakarta Servlet 6 · JSP 3.1 · JSTL 3.0 |
| BD | MySQL 8 (local y en línea) · JDBC |
| Frontend | HTML5 · CSS3 · Bootstrap 5.3 · JavaScript |
| Servidor | Apache Tomcat 10+ |
| Build | Maven 3.8+ |
| Seguridad | BCrypt (jBCrypt) · HttpSession · Filter |
| Control de versiones | Git + GitHub + Codespaces |

---

## 🚀 Requisitos

- JDK 17+
- Maven 3.8+
- Tomcat 10+ (Jakarta EE 9+)
- MySQL 8+

---

## ⚙️ Configuración

1. **Clonar el repositorio**
   ```bash
   git clone https://github.com/<usuario>/inmobiliaria-web.git
   cd inmobiliaria-web