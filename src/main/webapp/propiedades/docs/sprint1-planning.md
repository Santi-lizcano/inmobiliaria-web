# Sprint 1 — Planning (Días 1-7)
**Sprint Goal:** Tener cimientos técnicos y acceso seguro al sistema.

## Historias comprometidas
| ID | Historia | Est. | Prioridad |
|----|----------|------|-----------|
| 1  | Landing page responsiva | 5 | Alta |
| 2  | Registro con correo único | 5 | Alta |
| 3  | Login/logout con BCrypt | 5 | Alta |
| 4  | Filtro de rutas por rol | 5 | Alta |

**Total puntos:** 20

## Tareas técnicas
- Diseñar MER y modelo relacional 3FN
- Crear DDL y DML
- Configurar proyecto Maven + Tomcat
- Implementar ConexionDB (Singleton)
- Implementar PasswordUtil con BCrypt
- AuthFilter

## Riesgos
- Configuración de Tomcat 10 con Jakarta (servlet 6) puede dar problemas de compatibilidad.
- Curva de aprendizaje de BCrypt.
