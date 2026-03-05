@echo off
echo ========================================
echo   INICIANDO PANEL WEB ELITE
echo ========================================
echo.
echo Verificando dependencias...
pip install -r requirements.txt
echo.
echo ========================================
echo   PANEL WEB INICIADO
echo ========================================
echo.
echo URL: http://localhost:8080
echo PIN: 1823
echo.
echo Presiona Ctrl+C para detener el servidor
echo ========================================
echo.
python web_panel.py
pause
