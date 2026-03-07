#!/bin/bash

# Script para verificar que el sistema está listo para instalar Panel Web Elite

echo "════════════════════════════════════════════════════════════"
echo "  🔍 Verificación del Sistema"
echo "════════════════════════════════════════════════════════════"
echo ""

ERRORS=0

# Verificar sistema operativo
echo "[1] Sistema Operativo:"
if [ -f /etc/os-release ]; then
    . /etc/os-release
    echo "    ✅ $PRETTY_NAME"
else
    echo "    ❌ No se pudo detectar el sistema"
    ERRORS=$((ERRORS + 1))
fi
echo ""

# Verificar permisos sudo
echo "[2] Permisos sudo:"
if sudo -n true 2>/dev/null; then
    echo "    ✅ Tienes permisos sudo"
else
    echo "    ⚠️  Necesitarás ingresar contraseña sudo"
fi
echo ""

# Verificar conexión a internet
echo "[3] Conexión a Internet:"
if ping -c 1 8.8.8.8 > /dev/null 2>&1; then
    echo "    ✅ Conexión OK"
else
    echo "    ❌ Sin conexión a internet"
    ERRORS=$((ERRORS + 1))
fi
echo ""

# Verificar Python
echo "[4] Python:"
if command -v python3 &> /dev/null; then
    PYTHON_VERSION=$(python3 --version)
    echo "    ✅ $PYTHON_VERSION"
else
    echo "    ❌ Python3 no instalado"
    ERRORS=$((ERRORS + 1))
fi
echo ""

# Verificar pip
echo "[5] pip (gestor de paquetes Python):"
if python3 -m pip --version &> /dev/null; then
    PIP_VERSION=$(python3 -m pip --version | awk '{print $2}')
    echo "    ✅ pip $PIP_VERSION"
else
    echo "    ❌ pip no instalado"
    ERRORS=$((ERRORS + 1))
fi
echo ""

# Verificar Flask
echo "[6] Flask:"
if python3 -c "import flask" 2>/dev/null; then
    FLASK_VERSION=$(python3 -c "import flask; print(flask.__version__)")
    echo "    ✅ Flask $FLASK_VERSION instalado"
else
    echo "    ⚠️  Flask no instalado (se instalará)"
fi
echo ""

# Verificar Requests
echo "[7] Requests:"
if python3 -c "import requests" 2>/dev/null; then
    echo "    ✅ Requests instalado"
else
    echo "    ⚠️  Requests no instalado (se instalará)"
fi
echo ""

# Verificar puerto 5000
echo "[8] Puerto 5000:"
if command -v netstat &> /dev/null; then
    if netstat -tuln 2>/dev/null | grep :5000 > /dev/null; then
        echo "    ⚠️  Puerto 5000 está ocupado"
        echo "        Proceso usando el puerto:"
        sudo netstat -tulnp | grep :5000
    else
        echo "    ✅ Puerto 5000 disponible"
    fi
elif command -v ss &> /dev/null; then
    if ss -tuln 2>/dev/null | grep :5000 > /dev/null; then
        echo "    ⚠️  Puerto 5000 está ocupado"
    else
        echo "    ✅ Puerto 5000 disponible"
    fi
else
    echo "    ⚠️  No se puede verificar (netstat/ss no disponible)"
fi
echo ""

# Verificar espacio en disco
echo "[9] Espacio en disco:"
DISK_SPACE=$(df -h . | awk 'NR==2 {print $4}')
echo "    ℹ️  Espacio disponible: $DISK_SPACE"
echo ""

# Verificar memoria
echo "[10] Memoria RAM:"
if command -v free &> /dev/null; then
    FREE_MEM=$(free -h | awk 'NR==2 {print $7}')
    echo "    ℹ️  Memoria disponible: $FREE_MEM"
else
    echo "    ⚠️  No se puede verificar"
fi
echo ""

# Resumen
echo "════════════════════════════════════════════════════════════"
if [ $ERRORS -eq 0 ]; then
    echo "  ✅ Sistema listo para instalar Panel Web Elite"
    echo ""
    echo "  Ejecuta el instalador:"
    echo "    chmod +x install.sh"
    echo "    ./install.sh"
    echo ""
    echo "  O el instalador simple:"
    echo "    chmod +x install_simple.sh"
    echo "    ./install_simple.sh"
else
    echo "  ⚠️  Se encontraron $ERRORS problemas"
    echo ""
    echo "  Soluciones:"
    if ! command -v python3 &> /dev/null; then
        echo "    - Instalar Python: sudo apt install python3 python3-pip"
    fi
    if ! ping -c 1 8.8.8.8 > /dev/null 2>&1; then
        echo "    - Verificar conexión a internet"
    fi
fi
echo "════════════════════════════════════════════════════════════"
echo ""
