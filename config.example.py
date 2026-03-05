"""
Archivo de configuración del Panel Web Elite
Copia este archivo como config.py y modifica según tus necesidades
"""

# Configuración del servidor API backend
API_CONFIG = {
    'base_url': 'http://localhost:5000',  # URL del servidor cris.py
    'timeout': 10  # Timeout en segundos para las peticiones
}

# Configuración del panel web
WEB_CONFIG = {
    'host': '0.0.0.0',  # 0.0.0.0 permite acceso desde otras máquinas
    'port': 8080,       # Puerto del panel web
    'debug': True,      # Modo debug (desactivar en producción)
    'secret_key': None  # Se genera automáticamente si es None
}

# Configuración de seguridad
SECURITY_CONFIG = {
    'admin_pin': '1823',  # PIN de administrador - CAMBIAR EN PRODUCCIÓN
    'session_lifetime_hours': 2,  # Duración de la sesión en horas
    'max_login_attempts': 5  # Intentos máximos de login (futuro)
}

# Configuración de repositorios
REPOS_CONFIG = {
    'storage_dir': 'repositories',  # Directorio de almacenamiento
    'max_file_size_mb': 10,  # Tamaño máximo de archivo JSON
    'allowed_extensions': ['.json'],  # Extensiones permitidas
    'id_length': 8  # Longitud del ID único del repositorio
}

# Configuración de interfaz
UI_CONFIG = {
    'app_name': 'Panel Elite',
    'theme_color': '#667eea',  # Color principal del tema
    'items_per_page': 50  # Items por página en listados
}

# Mensajes personalizables
MESSAGES = {
    'login_success': 'Bienvenido al Panel Elite',
    'login_error': 'PIN incorrecto',
    'user_created': 'Usuario creado exitosamente',
    'user_deleted': 'Usuario eliminado',
    'repo_created': 'Repositorio creado exitosamente',
    'repo_deleted': 'Repositorio eliminado',
    'error_generic': 'Ha ocurrido un error'
}

# Configuración de logs (futuro)
LOG_CONFIG = {
    'enabled': True,
    'level': 'INFO',  # DEBUG, INFO, WARNING, ERROR
    'file': 'panel.log',
    'max_size_mb': 10
}
