#!/bin/bash

# Script para actualizar Panel Web Elite sin perder datos

echo "════════════════════════════════════════════════════════════"
echo "  🔄 Actualizando Panel Web Elite"
echo "════════════════════════════════════════════════════════════"
echo ""

# Colores
GREEN='\033[0;32m'
RED='\033[0;31m'
YELLOW='\033[1;33m'
NC='\033[0m'

print_success() { echo -e "${GREEN}✅ $1${NC}"; }
print_error() { echo -e "${RED}❌ $1${NC}"; }
print_info() { echo -e "${YELLOW}ℹ️  $1${NC}"; }

GITHUB_URL="https://raw.githubusercontent.com/CristianBatero/panel_web/main"

# Verificar que estamos en el directorio correcto
if [ ! -f "web_panel.py" ]; then
    print_error "No se encontró web_panel.py. Ejecuta este script desde el directorio del panel."
    exit 1
fi

# Hacer backup de archivos importantes
print_info "Haciendo backup de datos..."
if [ -f "config.py" ]; then
    cp config.py config.py.backup
    print_success "Backup de config.py creado"
fi

if [ -d "repositories" ]; then
    cp -r repositories repositories.backup
    print_success "Backup de repositories creado"
fi

# Detener panel
print_info "Deteniendo panel..."
pkill -f web_panel.py 2>/dev/null || true
sleep 2
print_success "Panel detenido"

# Descargar nueva versión
print_info "Descargando nueva versión..."
wget -q -O web_panel.py.new "$GITHUB_URL/web_panel.py"

if [ ! -f "web_panel.py.new" ]; then
    print_error "No se pudo descargar la nueva versión"
    exit 1
fi

# Reemplazar archivo
mv web_panel.py web_panel.py.old
mv web_panel.py.new web_panel.py
print_success "Archivo actualizado"

# Actualizar templates
print_info "Actualizando templates..."
mkdir -p templates

wget -q -O templates/login.html "$GITHUB_URL/templates/login.html" 2>/dev/null || true
wget -q -O templates/dashboard.html "$GITHUB_URL/templates/dashboard.html" 2>/dev/null || true
wget -q -O templates/repo_view.html "$GITHUB_URL/templates/repo_view.html" 2>/dev/null || true

print_success "Templates actualizados"

# Reiniciar panel
print_info "Reiniciando panel..."
nohup python3 web_panel.py > panel.log 2>&1 &
PANEL_PID=$!
sleep 3

# Verificar que está corriendo
if ps -p $PANEL_PID > /dev/null 2>&1; then
    print_success "Panel actualizado y reiniciado correctamente (PID: $PANEL_PID)"
    echo ""
    echo "════════════════════════════════════════════════════════════"
    echo "  ✅ Actualización Completada"
    echo "════════════════════════════════════════════════════════════"
    echo ""
    echo "  Backups creados:"
    echo "    - config.py.backup"
    echo "    - repositories.backup/"
    echo "    - web_panel.py.old"
    echo ""
    echo "  Ver logs: tail -f panel.log"
    echo ""
else
    print_error "Error al reiniciar el panel"
    echo ""
    echo "Restaurando versión anterior..."
    mv web_panel.py.old web_panel.py
    nohup python3 web_panel.py > panel.log 2>&1 &
    echo ""
    echo "Versión anterior restaurada"
    exit 1
fi
