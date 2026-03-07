#!/bin/bash

# Panel Web Elite - Instalador Simple y Directo
# Para VPS Ubuntu/Debian - Usa este si install.sh falla

clear
echo "════════════════════════════════════════════════════════════"
echo "  🌐 Panel Web Elite - Instalador Simple"
echo "════════════════════════════════════════════════════════════"
echo ""

set -e  # Detener si hay error

# [1] Actualizar sistema
echo "[1/6] Actualizando sistema..."
sudo apt update
echo "✅ Sistema actualizado"
echo ""

# [2] Instalar Python COMPLETO
echo "[2/6] Instalando Python completo..."
sudo apt install -y \
    python3 \
    python3-pip \
    python3-dev \
    python3-venv \
    python3-flask \
    python3-requests \
    build-essential \
    wget \
    curl \
    net-tools

echo "✅ Python instalado"
python3 --version
echo ""

# [3] Verificar Flask
echo "[3/6] Verificando Flask..."
if python3 -c "import flask" 2>/dev/null; then
    echo "✅ Flask OK"
else
    echo "Instalando Flask con pip..."
    python3 -m pip install --user flask requests
fi

if python3 -c "import requests" 2>/dev/null; then
    echo "✅ Requests OK"
else
    echo "❌ Error: Requests no se instaló"
    exit 1
fi
echo ""

# [4] Descargar archivos
echo "[4/6] Descargando archivos..."
GITHUB_URL="https://raw.githubusercontent.com/CristianBatero/panel_web/main"

wget -q -O web_panel.py "$GITHUB_URL/web_panel.py"
mkdir -p templates
wget -q -O templates/login.html "$GITHUB_URL/templates/login.html"
wget -q -O templates/dashboard.html "$GITHUB_URL/templates/dashboard.html"
wget -q -O templates/repo_view.html "$GITHUB_URL/templates/repo_view.html"

if [ ! -f web_panel.py ]; then
    echo "❌ Error al descargar archivos"
    exit 1
fi
echo "✅ Archivos descargados"
echo ""

# [5] Configurar PIN
echo "[5/6] Configuración..."
echo ""
read -p "Ingresa tu PIN de acceso: " USER_PIN < /dev/tty

cat > config.py << EOF
API_CONFIG = {'base_url': 'http://localhost:5000', 'timeout': 10}
WEB_CONFIG = {'host': '0.0.0.0', 'port': 5000, 'debug': False, 'secret_key': None}
SECURITY_CONFIG = {'admin_pin': '$USER_PIN', 'session_lifetime_hours': 2, 'max_login_attempts': 5}
REPOS_CONFIG = {'storage_dir': 'repositories', 'max_file_size_mb': 10, 'allowed_extensions': ['.json'], 'id_length': 8}
UI_CONFIG = {'app_name': 'Panel Elite', 'theme_color': '#667eea', 'items_per_page': 50}
MESSAGES = {'login_success': 'Bienvenido', 'login_error': 'PIN incorrecto'}
LOG_CONFIG = {'enabled': True, 'level': 'INFO', 'file': 'panel.log', 'max_size_mb': 10}
EOF

mkdir -p repositories
echo "✅ Configuración creada"
echo ""

# [6] Abrir firewall
echo "[6/6] Configurando firewall..."
sudo ufw allow 5000/tcp 2>/dev/null || true
echo "✅ Puerto 5000 abierto"
echo ""

# Iniciar panel
echo "════════════════════════════════════════════════════════════"
echo "  🚀 Iniciando Panel..."
echo "════════════════════════════════════════════════════════════"
echo ""

pkill -f web_panel.py 2>/dev/null || true
sleep 1

nohup python3 web_panel.py > panel.log 2>&1 &
PANEL_PID=$!
echo "PID del panel: $PANEL_PID"
sleep 3

# Verificar
if ps -p $PANEL_PID > /dev/null 2>&1; then
    echo ""
    echo "════════════════════════════════════════════════════════════"
    echo "  ✅ ¡INSTALACIÓN EXITOSA!"
    echo "════════════════════════════════════════════════════════════"
    echo ""
    SERVER_IP=$(hostname -I | awk '{print $1}')
    echo "  🌐 URL: http://$SERVER_IP:5000"
    echo "  🔐 PIN: $USER_PIN"
    echo ""
    echo "  Ver logs: tail -f panel.log"
    echo "  Detener: pkill -f web_panel.py"
    echo ""
else
    echo ""
    echo "❌ Error al iniciar el panel"
    echo ""
    echo "Log de error:"
    cat panel.log
    echo ""
    echo "Intenta iniciar manualmente:"
    echo "  python3 web_panel.py"
    exit 1
fi
