#!/bin/bash

# Panel Web Elite - Instalador Ultra Robusto
# Este instalador es el más completo y maneja todos los casos posibles

set -e  # Detener en cualquier error
trap 'last_command=$current_command; current_command=$BASH_COMMAND' DEBUG
trap 'echo "ERROR: \"${last_command}\" falló con código $?"' ERR

clear
echo "════════════════════════════════════════════════════════════"
echo "  🌐 Panel Web Elite - Instalador Ultra Robusto"
echo "════════════════════════════════════════════════════════════"
echo ""
echo "Este instalador instalará TODO lo necesario de forma robusta."
echo ""
sleep 2

# Colores
GREEN='\033[0;32m'
RED='\033[0;31m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

print_success() { echo -e "${GREEN}✅ $1${NC}"; }
print_error() { echo -e "${RED}❌ $1${NC}"; }
print_info() { echo -e "${YELLOW}ℹ️  $1${NC}"; }
print_step() { echo -e "${BLUE}▶ $1${NC}"; }

# Verificar que estamos en Ubuntu/Debian
if [ ! -f /etc/os-release ]; then
    print_error "No se pudo detectar el sistema operativo"
    exit 1
fi

. /etc/os-release
echo "Sistema: $PRETTY_NAME"
echo ""

# [1] Actualizar sistema
echo "════════════════════════════════════════════════════════════"
echo "  [1/7] Actualizando Sistema"
echo "════════════════════════════════════════════════════════════"
print_step "Actualizando lista de paquetes..."
sudo apt update -qq
print_success "Sistema actualizado"
echo ""

# [2] Instalar Python COMPLETO
echo "════════════════════════════════════════════════════════════"
echo "  [2/7] Instalando Python Completo"
echo "════════════════════════════════════════════════════════════"

PYTHON_PACKAGES=(
    "python3"
    "python3-pip"
    "python3-dev"
    "python3-venv"
    "python3-setuptools"
    "python3-wheel"
    "python3-flask"
    "python3-requests"
    "build-essential"
    "wget"
    "curl"
    "net-tools"
)

for package in "${PYTHON_PACKAGES[@]}"; do
    print_step "Instalando $package..."
    sudo apt install -y "$package" -qq > /dev/null 2>&1 || true
done

# Verificar Python
if ! command -v python3 &> /dev/null; then
    print_error "Python3 no se instaló correctamente"
    exit 1
fi

PYTHON_VERSION=$(python3 --version)
print_success "Python instalado: $PYTHON_VERSION"

# Actualizar pip
print_step "Actualizando pip..."
python3 -m pip install --upgrade pip setuptools wheel --quiet 2>/dev/null || true

print_success "Python completo instalado"
echo ""

# [3] Instalar Flask y Requests
echo "════════════════════════════════════════════════════════════"
echo "  [3/7] Instalando Flask y Requests"
echo "════════════════════════════════════════════════════════════"

# Método 1: Paquetes del sistema (más confiable)
print_step "Instalando desde repositorios del sistema..."
sudo apt install -y python3-flask python3-requests -qq > /dev/null 2>&1 || true

# Método 2: pip usuario
if ! python3 -c "import flask" 2>/dev/null; then
    print_step "Instalando con pip (usuario)..."
    python3 -m pip install --user flask requests --quiet 2>/dev/null || true
fi

# Método 3: pip global
if ! python3 -c "import flask" 2>/dev/null; then
    print_step "Instalando con pip (global)..."
    sudo python3 -m pip install flask requests --quiet 2>/dev/null || true
fi

# Verificar Flask
if python3 -c "import flask" 2>/dev/null; then
    FLASK_VERSION=$(python3 -c "import flask; print(flask.__version__)")
    print_success "Flask $FLASK_VERSION instalado"
else
    print_error "No se pudo instalar Flask"
    echo ""
    echo "Intenta manualmente:"
    echo "  sudo apt install python3-flask python3-requests"
    exit 1
fi

# Verificar Requests
if python3 -c "import requests" 2>/dev/null; then
    print_success "Requests instalado"
else
    print_error "No se pudo instalar Requests"
    exit 1
fi

echo ""

# [4] Descargar archivos
echo "════════════════════════════════════════════════════════════"
echo "  [4/7] Descargando Archivos del Panel"
echo "════════════════════════════════════════════════════════════"

GITHUB_URL="https://raw.githubusercontent.com/CristianBatero/panel_web/main"

print_step "Descargando web_panel.py..."
wget -q -O web_panel.py "$GITHUB_URL/web_panel.py" 2>/dev/null || \
curl -s -o web_panel.py "$GITHUB_URL/web_panel.py"

if [ ! -f web_panel.py ]; then
    print_error "No se pudo descargar web_panel.py"
    exit 1
fi
print_success "web_panel.py descargado"

print_step "Creando directorio templates..."
mkdir -p templates

print_step "Descargando templates..."
wget -q -O templates/login.html "$GITHUB_URL/templates/login.html" 2>/dev/null || \
curl -s -o templates/login.html "$GITHUB_URL/templates/login.html"

wget -q -O templates/dashboard.html "$GITHUB_URL/templates/dashboard.html" 2>/dev/null || \
curl -s -o templates/dashboard.html "$GITHUB_URL/templates/dashboard.html"

wget -q -O templates/repo_view.html "$GITHUB_URL/templates/repo_view.html" 2>/dev/null || \
curl -s -o templates/repo_view.html "$GITHUB_URL/templates/repo_view.html"

if [ ! -f templates/login.html ]; then
    print_error "No se pudieron descargar los templates"
    exit 1
fi

print_success "Todos los archivos descargados"
echo ""

# [5] Configurar PIN
echo "════════════════════════════════════════════════════════════"
echo "  [5/7] Configuración de Seguridad"
echo "════════════════════════════════════════════════════════════"
echo ""
echo "Ingresa un PIN para proteger tu panel (mínimo 4 caracteres):"
echo ""

while true; do
    read -p "PIN: " USER_PIN < /dev/tty
    if [ ${#USER_PIN} -lt 4 ]; then
        print_error "El PIN debe tener al menos 4 caracteres"
    else
        break
    fi
done

print_success "PIN configurado"
echo ""

# [6] Crear configuración
echo "════════════════════════════════════════════════════════════"
echo "  [6/7] Creando Configuración"
echo "════════════════════════════════════════════════════════════"

cat > config.py << EOF
"""Panel Web Elite - Configuración"""
API_CONFIG = {'base_url': 'http://localhost:5000', 'timeout': 10}
WEB_CONFIG = {'host': '0.0.0.0', 'port': 5000, 'debug': False, 'secret_key': None}
SECURITY_CONFIG = {'admin_pin': '$USER_PIN', 'session_lifetime_hours': 2, 'max_login_attempts': 5}
REPOS_CONFIG = {'storage_dir': 'repositories', 'max_file_size_mb': 10, 'allowed_extensions': ['.json'], 'id_length': 8}
UI_CONFIG = {'app_name': 'Panel Elite', 'theme_color': '#667eea', 'items_per_page': 50}
MESSAGES = {'login_success': 'Bienvenido', 'login_error': 'PIN incorrecto'}
LOG_CONFIG = {'enabled': True, 'level': 'INFO', 'file': 'panel.log', 'max_size_mb': 10}
EOF

mkdir -p repositories
print_success "Configuración creada"
echo ""

# [7] Configurar firewall e iniciar
echo "════════════════════════════════════════════════════════════"
echo "  [7/7] Iniciando Panel"
echo "════════════════════════════════════════════════════════════"

print_step "Configurando firewall..."
sudo ufw allow 5000/tcp 2>/dev/null || true
print_success "Puerto 5000 abierto"

print_step "Deteniendo instancias anteriores..."
pkill -f web_panel.py 2>/dev/null || true
sleep 2

print_step "Iniciando Panel Web Elite..."
nohup python3 web_panel.py > panel.log 2>&1 &
PANEL_PID=$!
echo "PID: $PANEL_PID"

print_step "Esperando que el panel inicie..."
sleep 4

# Verificar que está corriendo
PANEL_OK=false

if ps -p $PANEL_PID > /dev/null 2>&1; then
    PANEL_OK=true
fi

if ps aux | grep -v grep | grep web_panel.py > /dev/null 2>&1; then
    PANEL_OK=true
fi

if command -v netstat &> /dev/null; then
    if netstat -tuln 2>/dev/null | grep :5000 > /dev/null; then
        PANEL_OK=true
    fi
fi

if [ "$PANEL_OK" = true ]; then
    print_success "Panel iniciado correctamente"
else
    print_error "El panel no se inició correctamente"
    echo ""
    echo "Log de error:"
    cat panel.log
    exit 1
fi

echo ""

# Resumen final
SERVER_IP=$(hostname -I | awk '{print $1}' || echo "localhost")

clear
echo "════════════════════════════════════════════════════════════"
echo "  ✅ ¡INSTALACIÓN COMPLETADA EXITOSAMENTE!"
echo "════════════════════════════════════════════════════════════"
echo ""
echo "  🎉 Panel Web Elite está funcionando"
echo ""
echo "════════════════════════════════════════════════════════════"
echo "  📱 Acceso al Panel"
echo "════════════════════════════════════════════════════════════"
echo ""
echo "  🌐 URL Local:    http://localhost:5000"
echo "  🌐 URL Externa:  http://$SERVER_IP:5000"
echo "  🔐 PIN:          $USER_PIN"
echo ""
echo "════════════════════════════════════════════════════════════"
echo "  📋 Información del Sistema"
echo "════════════════════════════════════════════════════════════"
echo ""
echo "  Python:  $PYTHON_VERSION"
echo "  Flask:   $FLASK_VERSION"
echo "  PID:     $PANEL_PID"
echo ""
echo "════════════════════════════════════════════════════════════"
echo "  🛠️ Comandos Útiles"
echo "════════════════════════════════════════════════════════════"
echo ""
echo "  Ver logs en tiempo real:"
echo "    tail -f panel.log"
echo ""
echo "  Detener panel:"
echo "    pkill -f web_panel.py"
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
