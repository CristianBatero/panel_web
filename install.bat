@echo off
chcp 65001 >nul
cls
echo ════════════════════════════════════════════════════════════
echo   🌐 Panel Web Elite - Instalación Automática
echo ════════════════════════════════════════════════════════════
echo.

REM Verificar Python
echo [1/5] Verificando Python...
python --version >nul 2>&1
if errorlevel 1 (
    echo ❌ ERROR: Python no está instalado
    echo.
    echo Por favor instala Python 3.7 o superior desde:
    echo https://www.python.org/downloads/
    echo.
    pause
    exit /b 1
)
echo ✅ Python encontrado
python --version
echo.

REM Verificar pip
echo [2/5] Verificando pip...
pip --version >nul 2>&1
if errorlevel 1 (
    echo ❌ ERROR: pip no está instalado
    echo.
    echo Instalando pip...
    python -m ensurepip --upgrade
    if errorlevel 1 (
        echo ❌ Error al instalar pip
        pause
        exit /b 1
    )
)
echo ✅ pip encontrado
echo.

REM Crear configuración
echo [3/5] Configurando el panel...
if not exist config.py (
    echo.
    echo ════════════════════════════════════════════════════════════
    echo   🔐 Configuración de Seguridad
    echo ════════════════════════════════════════════════════════════
    echo.
    echo Por favor, ingresa un PIN para proteger tu panel.
    echo Este PIN será requerido cada vez que accedas al panel.
    echo.
    echo Recomendaciones:
    echo   - Mínimo 4 caracteres
    echo   - Usa números y letras
    echo   - No uses PINs obvios como 1234 o 0000
    echo.
    set /p USER_PIN="Ingresa tu PIN: "
    
    if "!USER_PIN!"=="" (
        echo.
        echo ❌ ERROR: El PIN no puede estar vacío
        echo.
        pause
        exit /b 1
    )
    
    echo.
    echo ✅ PIN configurado correctamente
    echo.
    
    REM Crear config.py con el PIN del usuario
    (
        echo """
        echo Archivo de configuración del Panel Web Elite
        echo Generado automáticamente durante la instalación
        echo """
        echo.
        echo # Configuración del servidor API backend
        echo API_CONFIG = {
        echo     'base_url': 'http://localhost:5000',
        echo     'timeout': 10
        echo }
        echo.
        echo # Configuración del panel web
        echo WEB_CONFIG = {
        echo     'host': '0.0.0.0',
        echo     'port': 8080,
        echo     'debug': True,
        echo     'secret_key': None
        echo }
        echo.
        echo # Configuración de seguridad
        echo SECURITY_CONFIG = {
        echo     'admin_pin': '!USER_PIN!',
        echo     'session_lifetime_hours': 2,
        echo     'max_login_attempts': 5
        echo }
        echo.
        echo # Configuración de repositorios
        echo REPOS_CONFIG = {
        echo     'storage_dir': 'repositories',
        echo     'max_file_size_mb': 10,
        echo     'allowed_extensions': ['.json'],
        echo     'id_length': 8
        echo }
        echo.
        echo # Configuración de interfaz
        echo UI_CONFIG = {
        echo     'app_name': 'Panel Elite',
        echo     'theme_color': '#667eea',
        echo     'items_per_page': 50
        echo }
        echo.
        echo # Mensajes personalizables
        echo MESSAGES = {
        echo     'login_success': 'Bienvenido al Panel Elite',
        echo     'login_error': 'PIN incorrecto',
        echo     'user_created': 'Usuario creado exitosamente',
        echo     'user_deleted': 'Usuario eliminado',
        echo     'repo_created': 'Repositorio creado exitosamente',
        echo     'repo_deleted': 'Repositorio eliminado',
        echo     'error_generic': 'Ha ocurrido un error'
        echo }
        echo.
        echo # Configuración de logs
        echo LOG_CONFIG = {
        echo     'enabled': True,
        echo     'level': 'INFO',
        echo     'file': 'panel.log',
        echo     'max_size_mb': 10
        echo }
    ) > config.py
    
    echo ✅ Archivo config.py creado
    echo.
) else (
    echo ℹ️  config.py ya existe, no se modificará
    echo.
)

REM Instalar dependencias
echo [4/5] Instalando dependencias...
echo Esto puede tomar unos minutos...
echo.
pip install -r requirements.txt
if errorlevel 1 (
    echo.
    echo ❌ ERROR: Error al instalar dependencias
    echo.
    echo Intenta ejecutar manualmente:
    echo   pip install --upgrade pip
    echo   pip install -r requirements.txt
    echo.
    pause
    exit /b 1
)
echo.
echo ✅ Dependencias instaladas correctamente
echo.

REM Crear directorio de repositorios
echo [5/5] Creando directorios necesarios...
if not exist repositories mkdir repositories
echo ✅ Directorios creados
echo.

REM Resumen final
cls
echo ════════════════════════════════════════════════════════════
echo   ✅ Instalación Completada Exitosamente
echo ════════════════════════════════════════════════════════════
echo.
echo 🎉 El Panel Web Elite está listo para usar
echo.
echo ════════════════════════════════════════════════════════════
echo   📋 Información de Acceso
echo ════════════════════════════════════════════════════════════
echo.
echo   URL Local:    http://localhost:8080
echo   URL Red:      http://TU_IP:8080
echo   PIN:          (el que configuraste)
echo.
echo ════════════════════════════════════════════════════════════
echo   🚀 Cómo Iniciar el Panel
echo ════════════════════════════════════════════════════════════
echo.
echo   Opción 1: Ejecuta start_panel.bat
echo   Opción 2: Ejecuta python web_panel.py
echo.
echo ════════════════════════════════════════════════════════════
echo   📱 Acceso desde Otros Dispositivos
echo ════════════════════════════════════════════════════════════
echo.
echo   1. Encuentra tu IP con: ipconfig
echo   2. Abre en otro dispositivo: http://TU_IP:8080
echo   3. Ingresa tu PIN
echo.
echo ════════════════════════════════════════════════════════════
echo   ⚠️  Importante
echo ════════════════════════════════════════════════════════════
echo.
echo   - Guarda tu PIN en un lugar seguro
echo   - Para cambiar el PIN, edita config.py
echo   - Para producción, cambia debug a False en config.py
echo.
echo ════════════════════════════════════════════════════════════
echo.
echo ¿Deseas iniciar el panel ahora? (S/N)
set /p START_NOW=
if /i "%START_NOW%"=="S" (
    echo.
    echo Iniciando panel...
    echo.
    python web_panel.py
) else (
    echo.
    echo Para iniciar el panel más tarde, ejecuta:
    echo   start_panel.bat
    echo.
)

pause
