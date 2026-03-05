#!/bin/bash

# Panel Web Elite - Instalador Automático Completo
# Este script instala TODO lo necesario automáticamente

clear
echo "════════════════════════════════════════════════════════════"
echo "  🌐 Panel Web Elite - Instalación Automática"
echo "════════════════════════════════════════════════════════════"
echo ""
echo "Este instalador configurará todo automáticamente."
echo "Solo necesitas ingresar un PIN cuando se solicite."
echo ""
sleep 2

# Colores
GREEN='\033[0;32m'
RED='\033[0;31m'
YELLOW='\033[1;33m'
NC='\033[0m'

print_success() { echo -e "${GREEN}✅ $1${NC}"; }
print_error() { echo -e "${RED}❌ $1${NC}"; exit 1; }
print_info() { echo -e "${YELLOW}ℹ️  $1${NC}"; }

# URL de GitHub
GITHUB_URL="https://raw.githubusercontent.com/CristianBatero/panel_web/main"

# [1] Detectar sistema operativo
echo "[1/8] Detectando sistema operativo..."
if [ -f /etc/os-release ]; then
    . /etc/os-release
    OS=$ID
    print_success "Sistema detectado: $PRETTY_NAME"
else
    print_error "No se pudo detectar el sistema operativo"
fi
echo ""

# [2] Actualizar sistema e instalar Python
echo "[2/8] Instalando Python y dependencias del sistema..."
if [[ "$OS" == "ubuntu" ]] || [[ "$OS" == "debian" ]]; then
    sudo apt update -qq > /dev/null 2>&1
    sudo apt install -y python3 python3-pip wget curl -qq > /dev/null 2>&1
elif [[ "$OS" == "centos" ]] || [[ "$OS" == "rhel" ]]; then
    sudo yum install -y python3 python3-pip wget curl -q > /dev/null 2>&1
else
    print_info "Sistema no reconocido, intentando instalación genérica..."
    sudo apt install -y python3 python3-pip wget curl -qq > /dev/null 2>&1 || \
    sudo yum install -y python3 python3-pip wget curl -q > /dev/null 2>&1
fi

if ! command -v python3 &> /dev/null; then
    print_error "No se pudo instalar Python. Instálalo manualmente."
fi
print_success "Python instalado correctamente"
echo ""

# [3] Instalar dependencias de Python
echo "[3/8] Instalando Flask y dependencias..."
pip3 install --upgrade pip > /dev/null 2>&1
pip3 install flask requests > /dev/null 2>&1
if [ $? -ne 0 ]; then
    sudo pip3 install flask requests > /dev/null 2>&1
fi
print_success "Dependencias instaladas"
echo ""

# [4] Descargar archivos del panel
echo "[4/8] Descargando Panel Web Elite desde GitHub..."

# Descargar web_panel.py
wget -q -O web_panel.py "$GITHUB_URL/web_panel.py" 2>/dev/null
if [ $? -ne 0 ]; then
    curl -s -o web_panel.py "$GITHUB_URL/web_panel.py"
fi

# Crear directorio templates
mkdir -p templates

# Descargar templates
wget -q -O templates/login.html "$GITHUB_URL/templates/login.html" 2>/dev/null || \
curl -s -o templates/login.html "$GITHUB_URL/templates/login.html"

wget -q -O templates/dashboard.html "$GITHUB_URL/templates/dashboard.html" 2>/dev/null || \
curl -s -o templates/dashboard.html "$GITHUB_URL/templates/dashboard.html"

wget -q -O templates/repo_view.html "$GITHUB_URL/templates/repo_view.html" 2>/dev/null || \
curl -s -o templates/repo_view.html "$GITHUB_URL/templates/repo_view.html"

if [ ! -f web_panel.py ]; then
    print_error "Error al descargar archivos. Verifica tu conexión a internet."
fi
print_success "Archivos descargados correctamente"
echo ""

# [5] Solicitar PIN
echo "[5/8] Configuración de seguridad..."
echo ""
echo "════════════════════════════════════════════════════════════"
echo "  🔐 Configura tu PIN de Acceso"
echo "════════════════════════════════════════════════════════════"
echo ""
echo "Ingresa un PIN para proteger tu panel."
echo "Recomendación: Usa mínimo 4 caracteres."
echo ""

while true; do
    read -p "Tu PIN: " USER_PIN
    if [ -z "$USER_PIN" ]; then
        echo "❌ El PIN no puede estar vacío"
    else
        break
    fi
done

print_success "PIN configurado"
echo ""

# [6] Crear archivo de configuración
echo "[6/8] Creando configuración..."

cat > config.py << EOF
"""
Panel Web Elite - Configuración
Generado automáticamente
"""

API_CONFIG = {
    'base_url': 'http://localhost:5000',
    'timeout': 10
}

WEB_CONFIG = {
    'host': '0.0.0.0',
    'port': 5000,
    'debug': False,
    'secret_key': None
}

SECURITY_CONFIG = {
    'admin_pin': '$USER_PIN',
    'session_lifetime_hours': 2,
    'max_login_attempts': 5
}

REPOS_CONFIG = {
    'storage_dir': 'repositories',
    'max_file_size_mb': 10,
    'allowed_extensions': ['.json'],
    'id_length': 8
}

UI_CONFIG = {
    'app_name': 'Panel Elite',
    'theme_color': '#667eea',
    'items_per_page': 50
}

MESSAGES = {
    'login_success': 'Bienvenido al Panel Elite',
    'login_error': 'PIN incorrecto',
    'user_created': 'Usuario creado exitosamente',
    'user_deleted': 'Usuario eliminado',
    'repo_created': 'Repositorio creado exitosamente',
    'repo_deleted': 'Repositorio eliminado',
    'error_generic': 'Ha ocurrido un error'
}

LOG_CONFIG = {
    'enabled': True,
    'level': 'INFO',
    'file': 'panel.log',
    'max_size_mb': 10
}
EOF

mkdir -p repositories
print_success "Configuración creada"
echo ""

# [7] Configurar firewall automáticamente
echo "[7/8] Configurando firewall..."

# Detectar y configurar firewall
if command -v ufw &> /dev/null; then
    sudo ufw allow 5000/tcp > /dev/null 2>&1
    sudo ufw --force enable > /dev/null 2>&1
    print_success "Puerto 5000 abierto (UFW)"
elif command -v firewall-cmd &> /dev/null; then
    sudo firewall-cmd --permanent --add-port=5000/tcp > /dev/null 2>&1
    sudo firewall-cmd --reload > /dev/null 2>&1
    print_success "Puerto 5000 abierto (firewalld)"
elif command -v iptables &> /dev/null; then
    sudo iptables -A INPUT -p tcp --dport 5000 -j ACCEPT > /dev/null 2>&1
    print_success "Puerto 5000 abierto (iptables)"
else
    print_info "No se detectó firewall, puerto 5000 debería estar abierto"
fi
echo ""

# [8] Detener panel anterior si existe e iniciar nuevo
echo "[8/8] Iniciando Panel Web Elite..."

# Detener cualquier instancia anterior
pkill -f web_panel.py > /dev/null 2>&1
pkill -f "python.*web_panel" > /dev/null 2>&1
sleep 1

# Iniciar panel en segundo plano
nohup python3 web_panel.py > panel.log 2>&1 &
sleep 3

# Verificar que esté corriendo
if ps aux | grep -v grep | grep web_panel.py > /dev/null; then
    print_success "Panel iniciado correctamente"
else
    print_error "Error al iniciar el panel. Revisa: cat panel.log"
fi
echo ""

# Obtener IP del servidor
SERVER_IP=$(hostname -I | awk '{print $1}')
if [ -z "$SERVER_IP" ]; then
    SERVER_IP=$(curl -s ifconfig.me 2>/dev/null || echo "TU_IP")
fi

# Resumen final
clear
echo "════════════════════════════════════════════════════════════"
echo "  ✅ ¡Instalación Completada!"
echo "════════════════════════════════════════════════════════════"
echo ""
echo "🎉 Panel Web Elite instalado y funcionando"
echo ""
echo "════════════════════════════════════════════════════════════"
echo "  📱 Accede a tu Panel"
echo "════════════════════════════════════════════════════════════"
echo ""
echo "  🌐 URL: http://$SERVER_IP:5000"
echo "  🔐 PIN: (el que configuraste)"
echo ""
echo "════════════════════════════════════════════════════════════"
echo "  📋 Comandos Útiles"
echo "════════════════════════════════════════════════════════════"
echo ""
echo "  Ver logs:"
echo "    tail -f panel.log"
echo ""
echo "  Reiniciar panel:"
echo "    pkill -f web_panel.py"
echo "    nohup python3 web_panel.py > panel.log 2>&1 &"
echo ""
echo "  Ver estado:"
echo "    ps aux | grep web_panel"
echo ""
echo "════════════════════════════════════════════════════════════"
echo "  📞 Soporte: @crisis1823 en Telegram"
echo "════════════════════════════════════════════════════════════"
echo ""
echo "¡Disfruta tu Panel Web Elite! 🚀"
echo ""
