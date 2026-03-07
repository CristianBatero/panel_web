#!/bin/bash

# Script simple para iniciar Panel Web Elite

echo "Iniciando Panel Web Elite..."

# Detener instancias anteriores
pkill -f web_panel.py 2>/dev/null
sleep 1

# Verificar archivos necesarios
if [ ! -f web_panel.py ]; then
    echo "❌ Error: web_panel.py no encontrado"
    exit 1
fi

if [ ! -f config.py ]; then
    echo "❌ Error: config.py no encontrado"
    exit 1
fi

# Iniciar panel
echo "Iniciando panel en puerto 5000..."
nohup python3 web_panel.py > panel.log 2>&1 &
PANEL_PID=$!

sleep 2

# Verificar que esté corriendo
if ps -p $PANEL_PID > /dev/null 2>&1; then
    echo "✅ Panel iniciado correctamente (PID: $PANEL_PID)"
    echo ""
    echo "Accede en: http://localhost:5000"
    echo "Ver logs: tail -f panel.log"
else
    echo "❌ Error al iniciar el panel"
    echo ""
    echo "Revisa el log:"
    cat panel.log
    exit 1
fi
