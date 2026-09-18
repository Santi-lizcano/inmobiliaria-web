-- =========================================================
--  Inmobiliaria UTS · DDL
--  Base de datos: inmobiliaria_db
-- =========================================================
USE inmobiliaria_db;

SET FOREIGN_KEY_CHECKS = 0;
DROP TABLE IF EXISTS documento_solicitud;
DROP TABLE IF EXISTS solicitud;
DROP TABLE IF EXISTS cita;
DROP TABLE IF EXISTS favorito;
DROP TABLE IF EXISTS propiedad_caracteristica;
DROP TABLE IF EXISTS imagen_propiedad;
DROP TABLE IF EXISTS propiedad;
DROP TABLE IF EXISTS inmobiliaria;
DROP TABLE IF EXISTS usuario_rol;
DROP TABLE IF EXISTS perfil;
DROP TABLE IF EXISTS usuario;
DROP TABLE IF EXISTS caracteristica;
DROP TABLE IF EXISTS tipo_propiedad;
DROP TABLE IF EXISTS ciudad;
DROP TABLE IF EXISTS rol;
DROP TABLE IF EXISTS auditoria;
SET FOREIGN_KEY_CHECKS = 1;

-- ============ CATÁLOGOS ============
CREATE TABLE rol (
  id_rol INT AUTO_INCREMENT PRIMARY KEY,
  nombre VARCHAR(30) NOT NULL UNIQUE,
  descripcion VARCHAR(120)
);

CREATE TABLE ciudad (
  id_ciudad INT AUTO_INCREMENT PRIMARY KEY,
  nombre VARCHAR(60) NOT NULL UNIQUE,
  departamento VARCHAR(60) NOT NULL
);

CREATE TABLE tipo_propiedad (
  id_tipo INT AUTO_INCREMENT PRIMARY KEY,
  nombre VARCHAR(40) NOT NULL UNIQUE,
  descripcion VARCHAR(120)
);

CREATE TABLE caracteristica (
  id_caracteristica INT AUTO_INCREMENT PRIMARY KEY,
  nombre VARCHAR(50) NOT NULL UNIQUE,
  icono VARCHAR(80)
);

-- ============ USUARIOS ============
CREATE TABLE usuario (
  id_usuario INT AUTO_INCREMENT PRIMARY KEY,
  correo VARCHAR(120) NOT NULL UNIQUE,
  password_hash VARCHAR(255) NOT NULL,
  estado ENUM('ACTIVO','INACTIVO','BLOQUEADO') DEFAULT 'ACTIVO',
  intentos_fallidos INT DEFAULT 0,
  fecha_registro DATETIME DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE perfil (
  id_perfil INT AUTO_INCREMENT PRIMARY KEY,
  id_usuario INT NOT NULL UNIQUE,
  nombres VARCHAR(80) NOT NULL,
  apellidos VARCHAR(80) NOT NULL,
  documento VARCHAR(20) NOT NULL UNIQUE,
  telefono VARCHAR(20),
  direccion VARCHAR(150),
  foto VARCHAR(255),
  CONSTRAINT fk_perfil_usuario FOREIGN KEY (id_usuario)
    REFERENCES usuario(id_usuario) ON DELETE CASCADE ON UPDATE CASCADE
);

CREATE TABLE usuario_rol (
  id_usuario INT NOT NULL,
  id_rol INT NOT NULL,
  fecha_asignacion DATETIME DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (id_usuario, id_rol),
  CONSTRAINT fk_ur_usuario FOREIGN KEY (id_usuario)
    REFERENCES usuario(id_usuario) ON DELETE CASCADE,
  CONSTRAINT fk_ur_rol FOREIGN KEY (id_rol)
    REFERENCES rol(id_rol) ON DELETE CASCADE
);

-- ============ NEGOCIO ============
CREATE TABLE inmobiliaria (
  id_inmobiliaria INT AUTO_INCREMENT PRIMARY KEY,
  nit VARCHAR(20) NOT NULL UNIQUE,
  razon_social VARCHAR(120) NOT NULL,
  telefono VARCHAR(20),
  correo VARCHAR(120),
  direccion VARCHAR(150),
  id_ciudad INT,
  CONSTRAINT fk_inm_ciudad FOREIGN KEY (id_ciudad) REFERENCES ciudad(id_ciudad)
);

CREATE TABLE propiedad (
  id_propiedad INT AUTO_INCREMENT PRIMARY KEY,
  matricula_inmobiliaria VARCHAR(40) NOT NULL UNIQUE,
  titulo VARCHAR(150) NOT NULL,
  descripcion TEXT,
  precio DECIMAL(14,2) NOT NULL,
  area_m2 DECIMAL(8,2),
  habitaciones INT DEFAULT 0,
  banos INT DEFAULT 0,
  direccion VARCHAR(180),
  estado ENUM('DISPONIBLE','RESERVADA','VENDIDA','ARRENDADA','INACTIVA') DEFAULT 'DISPONIBLE',
  id_tipo INT NOT NULL,
  id_ciudad INT NOT NULL,
  id_inmobiliaria INT NOT NULL,
  fecha_publicacion DATETIME DEFAULT CURRENT_TIMESTAMP,
  CONSTRAINT fk_prop_tipo FOREIGN KEY (id_tipo) REFERENCES tipo_propiedad(id_tipo),
  CONSTRAINT fk_prop_ciudad FOREIGN KEY (id_ciudad) REFERENCES ciudad(id_ciudad),
  CONSTRAINT fk_prop_inm FOREIGN KEY (id_inmobiliaria) REFERENCES inmobiliaria(id_inmobiliaria)
);

CREATE TABLE imagen_propiedad (
  id_imagen INT AUTO_INCREMENT PRIMARY KEY,
  id_propiedad INT NOT NULL,
  url VARCHAR(255) NOT NULL,
  orden INT DEFAULT 1,
  CONSTRAINT fk_img_prop FOREIGN KEY (id_propiedad)
    REFERENCES propiedad(id_propiedad) ON DELETE CASCADE
);

CREATE TABLE propiedad_caracteristica (
  id_propiedad INT NOT NULL,
  id_caracteristica INT NOT NULL,
  valor VARCHAR(50),
  PRIMARY KEY (id_propiedad, id_caracteristica),
  CONSTRAINT fk_pc_prop FOREIGN KEY (id_propiedad)
    REFERENCES propiedad(id_propiedad) ON DELETE CASCADE,
  CONSTRAINT fk_pc_car FOREIGN KEY (id_caracteristica)
    REFERENCES caracteristica(id_caracteristica) ON DELETE CASCADE
);

CREATE TABLE cita (
  id_cita INT AUTO_INCREMENT PRIMARY KEY,
  id_propiedad INT NOT NULL,
  id_usuario INT NOT NULL,
  fecha_hora DATETIME NOT NULL,
  estado ENUM('PENDIENTE','CONFIRMADA','CANCELADA','REALIZADA') DEFAULT 'PENDIENTE',
  observaciones VARCHAR(255),
  UNIQUE KEY uq_cita_prop_fecha (id_propiedad, fecha_hora),
  CONSTRAINT fk_cita_prop FOREIGN KEY (id_propiedad) REFERENCES propiedad(id_propiedad),
  CONSTRAINT fk_cita_user FOREIGN KEY (id_usuario) REFERENCES usuario(id_usuario)
);

CREATE TABLE solicitud (
  id_solicitud INT AUTO_INCREMENT PRIMARY KEY,
  id_cita INT,
  id_usuario INT NOT NULL,
  id_propiedad INT NOT NULL,
  tipo ENUM('COMPRA','ARRIENDO') NOT NULL,
  estado ENUM('RADICADA','EN_REVISION','APROBADA','RECHAZADA') DEFAULT 'RADICADA',
  fecha_radicacion DATETIME DEFAULT CURRENT_TIMESTAMP,
  observaciones VARCHAR(255),
  CONSTRAINT fk_sol_cita FOREIGN KEY (id_cita) REFERENCES cita(id_cita),
  CONSTRAINT fk_sol_user FOREIGN KEY (id_usuario) REFERENCES usuario(id_usuario),
  CONSTRAINT fk_sol_prop FOREIGN KEY (id_propiedad) REFERENCES propiedad(id_propiedad)
);

CREATE TABLE documento_solicitud (
  id_documento INT AUTO_INCREMENT PRIMARY KEY,
  id_solicitud INT NOT NULL,
  nombre VARCHAR(120) NOT NULL,
  url VARCHAR(255) NOT NULL,
  fecha_carga DATETIME DEFAULT CURRENT_TIMESTAMP,
  CONSTRAINT fk_doc_sol FOREIGN KEY (id_solicitud)
    REFERENCES solicitud(id_solicitud) ON DELETE CASCADE
);

CREATE TABLE favorito (
  id_usuario INT NOT NULL,
  id_propiedad INT NOT NULL,
  fecha DATETIME DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (id_usuario, id_propiedad),
  CONSTRAINT fk_fav_user FOREIGN KEY (id_usuario) REFERENCES usuario(id_usuario) ON DELETE CASCADE,
  CONSTRAINT fk_fav_prop FOREIGN KEY (id_propiedad) REFERENCES propiedad(id_propiedad) ON DELETE CASCADE
);

CREATE TABLE auditoria (
  id_auditoria INT AUTO_INCREMENT PRIMARY KEY,
  id_usuario INT,
  accion VARCHAR(100) NOT NULL,
  detalle VARCHAR(255),
  ip VARCHAR(45),
  fecha DATETIME DEFAULT CURRENT_TIMESTAMP,
  CONSTRAINT fk_aud_user FOREIGN KEY (id_usuario) REFERENCES usuario(id_usuario)
);

SELECT 'DDL ejecutado correctamente' AS resultado;
