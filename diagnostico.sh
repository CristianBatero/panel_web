#!/bin/bash

# Script de diagnóstico para Panel Web Elite

echo "════════════════════════════════════════════════════════════"
echo "  🔍 Diagnóstico Panel Web Elite"
echo "════════════════════════════════════════════════════════════"
echo ""

# Verificar Python
echo "[1] Verificando Python..."
if command -v python3 &> /dev/null; then
    PYTHON_VERSION=$(python3 --version)
    echo "✅ Python instalado: $PYTHON_VERSION"
else
    echo "❌ Python no encontrado"
fi
echo ""

# Verificar dependencias
echo "[2] Verificando dependencias..."
python3 -c "import flask" 2>/dev/null && echo "✅ Flask instalado" || echo "❌ Flask no instalado"
python3 -c "import requests" 2>/dev/null && echo "✅ Requests instalado" || echo "❌ Requests no instalado"
echo ""

# Verificar archivos
echo "[3] Verificando archivos..."
[ -f web_panel.py ] && echo "✅ web_panel.py existe" || echo "❌ web_panel.py no existe"
[ -f config.py ] && echo "✅ config.py existe" || echo "❌ config.py no existe"
[ -d templates ] && echo "✅ Directorio templates existe" || echo "❌ Directorio templates no existe"
[ -f templates/login.html ] && echo "✅ login.html existe" || echo "❌ login.html no existe"
[ -f templates/dashboard.html ] && echo "✅ dashboard.html existe" || echo "❌ dashboard.html no existe"
echo ""

# Verificar procesos
echo "[4] Verificando procesos..."
if ps aux | grep -v grep | grep web_panel.py > /dev/null; then
    echo "✅ Panel está corriendo"
    ps aux | grep -v grep | grep web_panel.py
else
    echo "❌ Panel no está corriendo"
fi
echo ""

# Verificar puerto
echo "[5] Verificando puerto 5000..."
if command -v netstat &> /dev/null; then
    if netstat -tuln | grep :5000 > /dev/null; then
        echo "✅ Puerto 5000 en uso"
    else
        echo "❌ Puerto 5000 no está en uso"
    fi
elif command -v ss &> /dev/null; then
    if ss -tuln | grep :5000 > /dev/null; then
        echo "✅ Puerto 5000 en uso"
    else
        echo "❌ Puerto 5000 no está en uso"
    fi
else
    echo "⚠️  No se puede verificar el puerto (netstat/ss no disponible)"
fi
echo ""

# Mostrar log si existe
echo "[6] Últimas líneas del log..."
if [ -f panel.log ]; then
    echo "════════════════════════════════════════════════════════════"
    tail -n 20 panel.log
    echo "════════════════════════════════════════════════════════════"
else
    echo "❌ No se encontró panel.log"
fi
echo ""

# Intentar iniciar manualmente
echo "[7] Intentando iniciar panel manualmente..."
echo "Ejecutando: python3 web_panel.py"
echo ""
python3 web_panel.py 2>&1 | head -n 10 &
MANUAL_PID=$!
sleep 3
kill $MANUAL_PID 2>/dev/null
echo ""

echo "════════════════════════════════════════════════════════════"
echo "  📋 Comandos útiles"
echo "════════════════════════════════════════════════════════════"
echo ""
echo "Ver log completo:"
echo "  cat panel.log"
echo ""
echo "Iniciar panel manualmente:"
echo "  python3 web_panel.py"
echo ""
echo "Iniciar en segundo plano:"
echo "  nohup python3 web_panel.py > panel.log 2>&1 &"
echo ""
echo "Detener panel:"
echo "  pkill -f web_panel.py"
echo ""
echo "Ver procesos:"
echo "  ps aux | grep web_panel"
echo ""
