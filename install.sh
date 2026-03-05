#!/bin/bash

echo "========================================"
echo "  Panel Web Elite - Instalación"
echo "========================================"
echo ""

# Verificar Python
if ! command -v python3 &> /dev/null; then
    echo "[ERROR] Python 3 no está instalado"
    echo "Por favor instala Python 3.7 o superior"
    exit 1
fi

echo "[OK] Python encontrado: $(python3 --version)"
echo ""

# Crear configuración si no existe
if [ ! -f config.py ]; then
    echo "[INFO] Creando archivo de configuración..."
    cp config.example.py config.py
    echo "[OK] config.py creado"
    echo ""
    echo "[IMPORTANTE] Edita config.py y cambia el PIN por defecto"
    echo ""
else
    echo "[INFO] config.py ya existe"
    echo ""
fi

# Crear entorno virtual (opcional)
read -p "¿Deseas crear un entorno virtual? (s/n): " crear_venv
if [ "$crear_venv" = "s" ] || [ "$crear_venv" = "S" ]; then
    if [ ! -d "venv" ]; then
        echo "[INFO] Creando entorno virtual..."
        python3 -m venv venv
        echo "[OK] Entorno virtual creado"
        echo ""
        echo "[INFO] Activando entorno virtual..."
        source venv/bin/activate
        echo "[OK] Entorno virtual activado"
        echo ""
    else
        echo "[INFO] Entorno virtual ya existe"
        source venv/bin/activate
        echo ""
    fi
fi

# Instalar dependencias
echo "[INFO] Instalando dependencias..."
pip install -r requirements.txt
if [ $? -ne 0 ]; then
    echo "[ERROR] Error al instalar dependencias"
    exit 1
fi

echo ""
echo "========================================"
echo "  Instalación Completada"
echo "========================================"
echo ""
echo "Para iniciar el panel ejecuta:"
echo "  python3 web_panel.py"
echo ""
echo "O si usas entorno virtual:"
echo "  source venv/bin/activate"
echo "  python web_panel.py"
echo ""
echo "Accede en: http://localhost:8080"
echo "PIN por defecto: 1823"
echo ""
echo "[IMPORTANTE] Cambia el PIN en config.py"
echo ""
