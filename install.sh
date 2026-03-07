#!/bin/bash

# Panel Web Elite - Instalador Automático Completo
# Este script instala TODO lo necesario automáticamente

clear
echo "════════════════════════════════════════════════════════════"
echo "  🌐 Panel Web Elite - Instalación Automática"
echo "════════════════════════════════════════════════════════════"
echo ""
echo "Este instalador configurará todo automáticamente."
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

# [2] Actualizar sistema e instalar Python COMPLETO
echo "[2/8] Instalando Python y dependencias del sistema..."

if [[ "$OS" == "ubuntu" ]] || [[ "$OS" == "debian" ]]; then
    print_info "Actualizando repositorios..."
    sudo apt update > /dev/null 2>&1
    
    print_info "Instalando Python completo..."
    # Instalar Python con TODAS las dependencias necesarias
    sudo apt install -y \
        python3 \
        python3-pip \
        python3-dev \
        python3-venv \
        python3-setuptools \
        python3-wheel \
        build-essential \
        wget \
        curl \
        net-tools > /dev/null 2>&1
    
    # Actualizar pip a la última versión
    print_info "Actualizando pip..."
    python3 -m pip install --upgrade pip setuptools wheel > /dev/null 2>&1
    
elif [[ "$OS" == "centos" ]] || [[ "$OS" == "rhel" ]]; then
    sudo yum install -y python3 python3-pip python3-devel gcc wget curl net-tools > /dev/null 2>&1
    python3 -m pip install --upgrade pip setuptools wheel > /dev/null 2>&1
else
    print_info "Sistema no reconocido, intentando instalación genérica..."
    sudo apt install -y python3 python3-pip python3-dev build-essential wget curl net-tools > /dev/null 2>&1 || \
    sudo yum install -y python3 python3-pip python3-devel gcc wget curl net-tools > /dev/null 2>&1
    python3 -m pip install --upgrade pip setuptools wheel > /dev/null 2>&1
fi

# Verificar Python
if ! command -v python3 &> /dev/null; then
    print_error "No se pudo instalar Python. Instálalo manualmente: sudo apt install python3 python3-pip"
fi

# Verificar pip
if ! python3 -m pip --version &> /dev/null; then
    print_error "pip no está funcionando. Instálalo manualmente: sudo apt install python3-pip"
fi

print_success "Python instalado correctamente"
python3 --version
echo ""

# [3] Instalar dependencias de Python de forma robusta
echo "[3/8] Instalando Flask y dependencias..."

# Intentar con pip3 normal primero
print_info "Instalando Flask..."
python3 -m pip install --user flask requests 2>&1 | grep -v "WARNING" || true

# Verificar que se instaló correctamente
if python3 -c "import flask" 2>/dev/null; then
    print_success "Flask instalado correctamente"
else
    print_info "Reintentando con sudo..."
    sudo python3 -m pip install flask requests > /dev/null 2>&1
    
    if python3 -c "import flask" 2>/dev/null; then
        print_success "Flask instalado correctamente"
    else
        print_error "No se pudo instalar Flask. Ejecuta manualmente: sudo apt install python3-flask python3-requests"
    fi
fi

# Verificar requests
if ! python3 -c "import requests" 2>/dev/null; then
    print_error "Requests no se instaló. Ejecuta: sudo apt install python3-requests"
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

# [5] Solicitar PIN - CORREGIDO para funcionar con pipe
echo "[5/8] Configuración de seguridad..."
echo ""
echo "════════════════════════════════════════════════════════════"
echo "  🔐 Configura tu PIN de Acceso"
echo "════════════════════════════════════════════════════════════"
echo ""
echo "Ingresa un PIN para proteger tu panel."
echo "Recomendación: Usa mínimo 4 caracteres."
echo ""

# Redirigir desde /dev/tty para que funcione con pipe
while true; do
    read -p "Tu PIN: " USER_PIN < /dev/tty
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

# Verificar que web_panel.py existe
if [ ! -f web_panel.py ]; then
    print_error "No se encontró web_panel.py. Verifica la descarga."
fi

# Verificar que config.py existe
if [ ! -f config.py ]; then
    print_error "No se encontró config.py. Verifica la configuración."
fi

# Verificar dependencias una última vez
print_info "Verificando dependencias finales..."
if ! python3 -c "import flask, requests" 2>/dev/null; then
    print_error "Flask o Requests no están instalados correctamente. Ejecuta: sudo apt install python3-flask python3-requests"
fi

# Iniciar panel en segundo plano
print_info "Iniciando servidor Flask..."
nohup python3 web_panel.py > panel.log 2>&1 &
PANEL_PID=$!
sleep 4

# Verificar múltiples formas
PANEL_RUNNING=false

# Método 1: Verificar PID
if ps -p $PANEL_PID > /dev/null 2>&1; then
    PANEL_RUNNING=true
fi

# Método 2: Verificar proceso por nombre
if ps aux | grep -v grep | grep web_panel.py > /dev/null 2>&1; then
    PANEL_RUNNING=true
fi

# Método 3: Verificar puerto 5000
if command -v netstat &> /dev/null; then
    if netstat -tuln 2>/dev/null | grep :5000 > /dev/null; then
        PANEL_RUNNING=true
    fi
elif command -v ss &> /dev/null; then
    if ss -tuln 2>/dev/null | grep :5000 > /dev/null; then
        PANEL_RUNNING=true
    fi
fi

if [ "$PANEL_RUNNING" = true ]; then
    print_success "Panel iniciado correctamente (PID: $PANEL_PID)"
else
    echo ""
    print_error "Error al iniciar el panel"
    echo ""
    echo "════════════════════════════════════════════════════════════"
    echo "  📋 Log de Error:"
    echo "════════════════════════════════════════════════════════════"
    if [ -f panel.log ]; then
        cat panel.log
    else
        echo "No se encontró panel.log"
    fi
    echo ""
    echo "════════════════════════════════════════════════════════════"
    echo "  🔧 Soluciones:"
    echo "════════════════════════════════════════════════════════════"
    echo ""
    echo "1. Instalar Flask manualmente:"
    echo "   sudo apt install python3-flask python3-requests"
    echo ""
    echo "2. Verificar puerto 5000:"
    echo "   sudo netstat -tuln | grep 5000"
    echo ""
    echo "3. Iniciar manualmente:"
    echo "   python3 web_panel.py"
    echo ""
    exit 1
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
echo "  🔐 PIN: $USER_PIN"
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
