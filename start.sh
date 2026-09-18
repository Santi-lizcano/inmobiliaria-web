#!/bin/bash
# =========================================================
# Arranque completo: MySQL + BD + Tomcat + WAR
# =========================================================
set -e

echo "=========================================="
echo "  Arrancando entorno Inmobiliaria UTS"
echo "=========================================="

# ---------- 1. INSTALAR MYSQL SI NO EXISTE ----------
if ! command -v mysql &> /dev/null; then
    echo "📦 Instalando MySQL..."
    sudo apt-get update -qq
    sudo apt-get install -y -qq mysql-server
fi

# ---------- 2. ARRANCAR MYSQL ----------
echo "🚀 Arrancando MySQL..."
sudo service mysql start 2>/dev/null || sudo service mariadb start 2>/dev/null || true
sleep 3

# ---------- 3. CREAR BD Y USUARIO ----------
echo "🗄️ Configurando base de datos..."
sudo mysql <<'EOF'
CREATE DATABASE IF NOT EXISTS inmobiliaria_db
  CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;
CREATE USER IF NOT EXISTS 'inmo_user'@'localhost' IDENTIFIED BY 'Inmo2026*';
CREATE USER IF NOT EXISTS 'inmo_user'@'127.0.0.1' IDENTIFIED BY 'Inmo2026*';
CREATE USER IF NOT EXISTS 'inmo_user'@'%' IDENTIFIED BY 'Inmo2026*';
GRANT ALL PRIVILEGES ON inmobiliaria_db.* TO 'inmo_user'@'localhost';
GRANT ALL PRIVILEGES ON inmobiliaria_db.* TO 'inmo_user'@'127.0.0.1';
GRANT ALL PRIVILEGES ON inmobiliaria_db.* TO 'inmo_user'@'%';
FLUSH PRIVILEGES;
EOF

# ---------- 4. EJECUTAR DDL SI FALTAN TABLAS ----------
TABLAS=$(sudo mysql inmobiliaria_db -N -e "SHOW TABLES;" 2>/dev/null | wc -l)
if [ "$TABLAS" -lt 5 ]; then
    echo "📋 Creando tablas (DDL)..."
    sudo mysql inmobiliaria_db < /workspaces/inmobiliaria-web/db/ddl.sql

    echo "📋 Insertando datos de prueba (DML)..."
    sudo mysql inmobiliaria_db < /workspaces/inmobiliaria-web/db/dml.sql
else
    echo "✅ Base de datos ya tiene tablas ($TABLAS)"
fi

# ---------- 5. INSTALAR TOMCAT SI NO EXISTE ----------
TOMCAT_DIR="/home/codespace/tomcat"
if [ ! -d "$TOMCAT_DIR" ]; then
    echo "📦 Instalando Tomcat 10..."
    cd /home/codespace
    wget -q https://archive.apache.org/dist/tomcat/tomcat-10/v10.1.34/bin/apache-tomcat-10.1.34.tar.gz
    mkdir -p "$TOMCAT_DIR"
    tar -xzf apache-tomcat-10.1.34.tar.gz -C "$TOMCAT_DIR" --strip-components=1
    rm apache-tomcat-10.1.34.tar.gz
    echo "✅ Tomcat instalado."
fi

# ---------- 6. COMPILAR PROYECTO ----------
echo "🔨 Compilando proyecto con Maven..."
cd /workspaces/inmobiliaria-web
mvn -q clean package

# ---------- 7. DESPLEGAR WAR ----------
echo "🚀 Desplegando WAR en Tomcat..."
"$TOMCAT_DIR/bin/shutdown.sh" 2>/dev/null || true
sleep 2
rm -rf "$TOMCAT_DIR/webapps/inmobiliaria-web"
rm -f "$TOMCAT_DIR/webapps/inmobiliaria-web.war"
cp target/inmobiliaria-web.war "$TOMCAT_DIR/webapps/"
"$TOMCAT_DIR/bin/startup.sh"

# ---------- 8. ESPERAR DESPLIEGUE ----------
echo "⏳ Esperando despliegue (10s)..."
sleep 10

# ---------- 9. VERIFICAR ----------
if netstat -an | grep -q ":8080.*LISTEN"; then
    echo ""
    echo "=========================================="
    echo "  ✅ TODO LISTO"
    echo "=========================================="
    echo ""
    echo "Abre en el navegador (Ports → 8080 → Public):"
    echo "  https://<tu-codespace>-8080.app.github.dev/inmobiliaria-web/"
    echo ""
    echo "Credenciales de prueba:"
    echo "  admin@inmobiliaria.com  /  Admin123*"
    echo "  cliente1@correo.com     /  Admin123*"
    echo ""
else
    echo "❌ Tomcat no está escuchando en 8080. Revisa:"
    echo "   tail -40 $TOMCAT_DIR/logs/catalina.out"
    exit 1
fi
