USE inmobiliaria_db;

-- ============ ROLES ============
INSERT INTO rol (nombre, descripcion) VALUES
('ADMINISTRADOR', 'Acceso total al sistema'),
('INMOBILIARIA',  'Agente que publica propiedades'),
('CLIENTE',       'Usuario que busca y arrienda/compra'),
('VISITANTE',     'Usuario no autenticado');

-- ============ CIUDADES ============
INSERT INTO ciudad (nombre, departamento) VALUES
('Bucaramanga','Santander'),
('Bogotá','Cundinamarca'),
('Medellín','Antioquia'),
('Cali','Valle del Cauca'),
('Cartagena','Bolívar'),
('Cúcuta','Norte de Santander'),
('Pereira','Risaralda'),
('Manizales','Caldas'),
('Ibagué','Tolima'),
('Villavicencio','Meta');

-- ============ TIPOS DE PROPIEDAD ============
INSERT INTO tipo_propiedad (nombre, descripcion) VALUES
('Casa','Vivienda unifamiliar'),
('Apartamento','Vivienda en edificio'),
('Local','Local comercial'),
('Oficina','Espacio de trabajo'),
('Terreno','Lote o loteo');

-- ============ CARACTERÍSTICAS ============
INSERT INTO caracteristica (nombre) VALUES
('Piscina'),('Parqueadero'),('Ascensor'),('Gimnasio'),
('Balcón'),('Jardín'),('Seguridad 24/7'),('Aire acondicionado'),
('Chimenea'),('Terraza');

-- ============ USUARIOS ============
-- password de todos: Admin123*  (hash BCrypt)
INSERT INTO usuario (correo, password_hash, estado) VALUES
('admin@inmobiliaria.com',       '$2a$10$N9qo8uLOickgx2ZMRZoMyeIjZAgcfl7p92ldGxad68LJZdL17lhWy', 'ACTIVO'),
('agente1@inmobiliaria.com',     '$2a$10$N9qo8uLOickgx2ZMRZoMyeIjZAgcfl7p92ldGxad68LJZdL17lhWy', 'ACTIVO'),
('agente2@inmobiliaria.com',     '$2a$10$N9qo8uLOickgx2ZMRZoMyeIjZAgcfl7p92ldGxad68LJZdL17lhWy', 'ACTIVO'),
('cliente1@correo.com',          '$2a$10$N9qo8uLOickgx2ZMRZoMyeIjZAgcfl7p92ldGxad68LJZdL17lhWy', 'ACTIVO'),
('cliente2@correo.com',          '$2a$10$N9qo8uLOickgx2ZMRZoMyeIjZAgcfl7p92ldGxad68LJZdL17lhWy', 'ACTIVO'),
('cliente3@correo.com',          '$2a$10$N9qo8uLOickgx2ZMRZoMyeIjZAgcfl7p92ldGxad68LJZdL17lhWy', 'ACTIVO'),
('cliente4@correo.com',          '$2a$10$N9qo8uLOickgx2ZMRZoMyeIjZAgcfl7p92ldGxad68LJZdL17lhWy', 'ACTIVO'),
('cliente5@correo.com',          '$2a$10$N9qo8uLOickgx2ZMRZoMyeIjZAgcfl7p92ldGxad68LJZdL17lhWy', 'ACTIVO'),
('visitante1@correo.com',        '$2a$10$N9qo8uLOickgx2ZMRZoMyeIjZAgcfl7p92ldGxad68LJZdL17lhWy', 'ACTIVO'),
('bloqueado@correo.com',         '$2a$10$N9qo8uLOickgx2ZMRZoMyeIjZAgcfl7p92ldGxad68LJZdL17lhWy', 'BLOQUEADO');

-- ============ PERFILES (1:1) ============
INSERT INTO perfil (id_usuario, nombres, apellidos, documento, telefono, direccion) VALUES
(1,'Admin','Sistema','1000000001','3001111111','Cra 1 #1-01'),
(2,'Laura','Gómez','1000000002','3001111112','Cll 2 #2-02'),
(3,'Carlos','Ramírez','1000000003','3001111113','Cra 3 #3-03'),
(4,'Ana','Martínez','1000000004','3001111114','Cll 4 #4-04'),
(5,'Pedro','López','1000000005','3001111115','Cra 5 #5-05'),
(6,'María','Rodríguez','1000000006','3001111116','Cll 6 #6-06'),
(7,'Juan','Pérez','1000000007','3001111117','Cra 7 #7-07'),
(8,'Sofía','Torres','1000000008','3001111118','Cll 8 #8-08'),
(9,'Visitante','Anónimo','1000000009','3001111119','N/A'),
(10,'Usuario','Bloqueado','1000000010','3001111120','N/A');

-- ============ USUARIO_ROL (N:M) ============
INSERT INTO usuario_rol (id_usuario, id_rol) VALUES
(1,1),  -- admin → ADMINISTRADOR
(2,2),  -- agente1 → INMOBILIARIA
(3,2),  -- agente2 → INMOBILIARIA
(4,3),(5,3),(6,3),(7,3),(8,3),  -- clientes
(9,4),  -- visitante
(10,3);

-- ============ INMOBILIARIAS ============
INSERT INTO inmobiliaria (nit, razon_social, telefono, correo, direccion, id_ciudad) VALUES
('900111111-1','Inmobiliaria Los Andes','6071111111','contacto@losandes.com','Cra 10 #20-30',1),
('900222222-2','Bienes Raíces del Norte','6072222222','info@bienesnorte.com','Cll 30 #45-10',2),
('900333333-3','Propiedades del Caribe','6053333333','ventas@caribe.com','Av 5 #10-20',5);

-- ============ PROPIEDADES ============
INSERT INTO propiedad (matricula_inmobiliaria, titulo, descripcion, precio, area_m2, habitaciones, banos, direccion, estado, id_tipo, id_ciudad, id_inmobiliaria) VALUES
('MAT-0001','Casa moderna en Bucaramanga','Hermosa casa esquinera con jardín y piscina',550000000.00,220.50,4,3,'Cra 15 #22-10','DISPONIBLE',1,1,1),
('MAT-0002','Apartamento en Bogotá Norte','Apartamento con balcón y vista panorámica',380000000.00,90.00,3,2,'Cll 100 #15-40','DISPONIBLE',2,2,2),
('MAT-0003','Local comercial centro Medellín','Local esquinero, alto flujo peatonal',420000000.00,120.00,0,1,'Cra 50 #45-30','DISPONIBLE',3,3,1),
('MAT-0004','Oficina moderna en Cali','Oficina en edificio empresarial con ascensor',280000000.00,80.00,0,2,'Av 6N #20-15','DISPONIBLE',4,4,2),
('MAT-0005','Terreno en Cartagena','Lote urbanizable cerca a la playa',900000000.00,500.00,0,0,'Anillo Vial Km 5','DISPONIBLE',5,5,3),
('MAT-0006','Casa campestre en Bucaramanga','Amplia casa con chimenea y jardín',720000000.00,350.00,5,4,'Km 3 Vía Girón','DISPONIBLE',1,1,1),
('MAT-0007','Apartaestudio en Medellín','Ideal para estudiante o pareja',150000000.00,45.00,1,1,'Cra 70 #30-20','DISPONIBLE',2,3,1),
('MAT-0008','Casa en conjunto cerrado','Con seguridad 24/7 y zona verde',430000000.00,180.00,3,3,'Cll 45 #12-30','RESERVADA',1,2,2),
('MAT-0009','Bodega comercial Bogotá','Bodega con muelle de carga',1200000000.00,800.00,0,2,'Zona Industrial','DISPONIBLE',3,2,2),
('MAT-0010','Penthouse en Cartagena','Con terraza y vista al mar',1500000000.00,300.00,4,5,'Bocagrande','DISPONIBLE',2,5,3),
('MAT-0011','Casa familiar en Cúcuta','Cómoda casa con parqueadero doble',320000000.00,160.00,3,2,'Cll 10 #5-30','DISPONIBLE',1,6,1),
('MAT-0012','Oficina en Pereira','Oficina con recepción y sala de juntas',210000000.00,65.00,0,1,'Cra 8 #20-15','VENDIDA',4,7,3);

-- ============ IMÁGENES (1:N) ============
INSERT INTO imagen_propiedad (id_propiedad, url, orden) VALUES
(1,'https://picsum.photos/400/300?random=1',1),
(1,'https://picsum.photos/400/300?random=2',2),
(1,'https://picsum.photos/400/300?random=3',3),
(2,'https://picsum.photos/400/300?random=4',1),
(2,'https://picsum.photos/400/300?random=5',2),
(3,'https://picsum.photos/400/300?random=6',1),
(4,'https://picsum.photos/400/300?random=7',1),
(5,'https://picsum.photos/400/300?random=8',1),
(6,'https://picsum.photos/400/300?random=9',1),
(6,'https://picsum.photos/400/300?random=10',2),
(7,'https://picsum.photos/400/300?random=11',1),
(8,'https://picsum.photos/400/300?random=12',1),
(9,'https://picsum.photos/400/300?random=13',1),
(10,'https://picsum.photos/400/300?random=14',1),
(11,'https://picsum.photos/400/300?random=15',1),
(12,'https://picsum.photos/400/300?random=16',1);

-- ============ PROPIEDAD_CARACTERISTICA (N:M) ============
INSERT INTO propiedad_caracteristica (id_propiedad, id_caracteristica) VALUES
(1,1),(1,2),(1,6),(1,7),
(2,2),(2,3),(2,5),
(3,2),(3,7),
(4,2),(4,3),(4,8),
(5,6),
(6,1),(6,2),(6,5),(6,6),(6,9),
(7,3),
(8,2),(8,7),
(9,2),(9,8),
(10,1),(10,2),(10,5),(10,10),
(11,2),(11,6),
(12,3),(12,8);

-- ============ CITAS ============
INSERT INTO cita (id_propiedad, id_usuario, fecha_hora, estado, observaciones) VALUES
(1,4,'2026-09-20 10:00:00','PENDIENTE','Primera visita'),
(2,5,'2026-09-20 14:30:00','CONFIRMADA','Interesado en financiación'),
(3,6,'2026-09-21 09:00:00','PENDIENTE','Revisar contrato'),
(6,7,'2026-09-22 11:00:00','PENDIENTE','Visita familiar'),
(10,8,'2026-09-23 15:00:00','CONFIRMADA','Cliente recurrente'),
(1,5,'2026-09-25 16:00:00','PENDIENTE','Segunda visita con familia'),
(7,4,'2026-09-26 08:30:00','CANCELADA','Reagendar'),
(11,6,'2026-09-27 10:00:00','PENDIENTE','Ver oportunidades'),
(12,8,'2026-09-28 13:00:00','REALIZADA','Ya visitada'),
(2,7,'2026-09-29 09:30:00','PENDIENTE','Solo consulta');

-- ============ SOLICITUDES ============
INSERT INTO solicitud (id_cita, id_usuario, id_propiedad, tipo, estado, observaciones) VALUES
(1,4,1,'COMPRA','RADICADA','Documentos al día'),
(2,5,2,'ARRIENDO','EN_REVISION','Verificar ingresos'),
(3,6,3,'COMPRA','APROBADA','Todo en orden'),
(4,7,6,'ARRIENDO','RECHAZADA','Documentación incompleta'),
(5,8,10,'COMPRA','APROBADA','Cliente premium'),
(6,5,1,'COMPRA','RADICADA','Interesado'),
(8,6,11,'ARRIENDO','EN_REVISION','Revisando'),
(9,8,12,'COMPRA','APROBADA','Ya firmado'),
(10,7,2,'ARRIENDO','RADICADA','Pendiente'),
(7,4,7,'ARRIENDO','RECHAZADA','Cancelada por cliente');

-- ============ DOCUMENTOS ============
INSERT INTO documento_solicitud (id_solicitud, nombre, url) VALUES
(1,'cedula.pdf','/uploads/documentos/demo-cedula.pdf'),
(1,'certificado_laboral.pdf','/uploads/documentos/demo-cert.pdf'),
(2,'camara_comercio.pdf','/uploads/documentos/demo-camara.pdf'),
(3,'cedula.pdf','/uploads/documentos/demo-cedula.pdf'),
(3,'extractos.pdf','/uploads/documentos/demo-extractos.pdf'),
(5,'cedula.pdf','/uploads/documentos/demo-cedula.pdf'),
(6,'certificado.pdf','/uploads/documentos/demo-cert.pdf'),
(8,'escritura.pdf','/uploads/documentos/demo-escritura.pdf'),
(10,'rechazo.pdf','/uploads/documentos/demo-rechazo.pdf');

-- ============ FAVORITOS ============
INSERT INTO favorito (id_usuario, id_propiedad) VALUES
(4,1),(4,2),(4,6),
(5,3),(5,5),
(6,1),(6,7),(6,10),
(7,11),(8,12);

-- ============ AUDITORÍA ============
INSERT INTO auditoria (id_usuario, accion, detalle, ip) VALUES
(1,'REGISTRO','Admin inicial','127.0.0.1'),
(2,'LOGIN_OK','Ingreso agente1','127.0.0.1'),
(4,'REGISTRO','Cliente 1','127.0.0.1'),
(4,'LOGIN_OK','Ingreso cliente1','127.0.0.1'),
(5,'LOGIN_FALLIDO','Contraseña incorrecta','127.0.0.1'),
(6,'CITA_CREADA','Cita propiedad 3','127.0.0.1'),
(7,'SOLICITUD_CREADA','Solicitud propiedad 6','127.0.0.1'),
(1,'REPORTE_CONSULTADO','Reporte por ciudad','127.0.0.1'),
(2,'PROPIEDAD_CREADA','Propiedad MAT-0006','127.0.0.1'),
(3,'PROPIEDAD_ACTUALIZADA','Propiedad MAT-0010','127.0.0.1');

SELECT 'DML ejecutado correctamente' AS resultado;
