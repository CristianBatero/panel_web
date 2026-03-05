# 🌐 Panel Web Elite

![Version](https://img.shields.io/badge/version-2.0.0-blue.svg)
![Python](https://img.shields.io/badge/python-3.7+-green.svg)
![Flask](https://img.shields.io/badge/flask-2.0+-red.svg)
![License](https://img.shields.io/badge/license-MIT-yellow.svg)

Panel de administración web profesional con diseño iOS oscuro para gestión de usuarios y repositorios JSON.

![Panel Preview](https://raw.githubusercontent.com/CristianBatero/panel_web/main/icono.png)

## ✨ Características

- 🎨 **Diseño moderno** estilo iOS con tema oscuro
- 👥 **Gestión completa de usuarios** (contraseña y token)
- 📦 **Sistema de repositorios** con URLs únicas
- 📱 **Totalmente responsive** (móvil, tablet, desktop)
- 🔒 **Autenticación segura** con PIN
- 🔄 **Renovación de usuarios** con cálculo automático de días
- 📊 **Filtros y búsqueda** en tiempo real
- 🔔 **Sistema de notificaciones** individual y masiva
- ⚡ **Interfaz rápida** con efectos glassmorphism
- 🎯 **Fácil de usar** con modales intuitivos

## 📸 Capturas de Pantalla

### Dashboard - Vista Desktop
Gestión de usuarios con tabla profesional, filtros y acciones rápidas.

### Dashboard - Vista Móvil
Diseño adaptativo que transforma la tabla en cards para mejor experiencia móvil.

### Repositorios
Sistema de repositorios con visualización de JSON, copiar y descargar.

## 🚀 Inicio Rápido

### 1. Clonar el repositorio
```bash
git clone https://github.com/CristianBatero/panel_web.git
cd panel_web
```

### 2. Configurar
```bash
# Copiar archivo de configuración
cp config.example.py config.py

# Editar config.py y cambiar el PIN por defecto
```

### 3. Instalar dependencias
```bash
pip install -r requirements.txt
```

### 4. Iniciar el panel
```bash
python web_panel.py
```

### 5. Acceder
Abre tu navegador en: **http://localhost:8080**
- PIN por defecto: **1823** (cámbialo en config.py)

## 📱 Acceso desde Móvil

1. Encuentra tu IP:
   ```bash
   ipconfig  # Windows
   ifconfig  # Linux/Mac
   ```

2. Accede desde tu móvil:
   ```
   http://TU_IP:8080
   ```

## 🎯 Funcionalidades Principales

### Gestión de Usuarios
- ✅ Crear usuarios con contraseña o token (Device ID)
- ✅ Editar información de usuarios
- ✅ Renovar suscripciones (añadir días)
- ✅ Filtrar por estado (Activos/Vencidos)
- ✅ Búsqueda en tiempo real
- ✅ Enviar notificaciones individuales o masivas
- ✅ Eliminar usuarios

### Sistema de Repositorios
- ✅ Crear repositorios con contenido JSON
- ✅ URLs únicas para cada repositorio
- ✅ Vista pública (solo lectura)
- ✅ Copiar y descargar archivos JSON
- ✅ Eliminar repositorios

## 📁 Estructura del Proyecto

```
panel/
├── web_panel.py              # Servidor principal
├── config.py                 # Configuración
├── requirements.txt          # Dependencias
├── start_panel.bat          # Script de inicio (Windows)
├── ejemplo_uso_api.py       # Ejemplos de uso de API
├── templates/               # Plantillas HTML
│   ├── login.html          # Página de login
│   ├── dashboard.html      # Panel principal
│   └── repo_view.html      # Vista de repositorios
└── repositories/           # Almacenamiento
    └── repos_db.json       # Base de datos

```

## ⚙️ Configuración

### Cambiar PIN
Edita `config.py`:
```python
SECURITY_CONFIG = {
    'admin_pin': 'TU_PIN',
    ...
}
```

### Cambiar Puerto
Edita `config.py`:
```python
WEB_CONFIG = {
    'port': 9000,  # Tu puerto
    ...
}
```

## 📡 API Endpoints

### Autenticación
- `POST /login` - Iniciar sesión
- `GET /logout` - Cerrar sesión

### Usuarios (requiere autenticación)
- `GET /api/users` - Listar usuarios
- `POST /api/users/add` - Crear/editar usuario
- `POST /api/users/renew` - Renovar usuario
- `POST /api/users/delete` - Eliminar usuario
- `POST /api/notify` - Enviar notificación

### Repositorios (requiere autenticación)
- `GET /api/repos` - Listar repositorios
- `POST /api/repos/create` - Crear repositorio
- `DELETE /api/repos/<id>/delete` - Eliminar repositorio

### Público (sin autenticación)
- `GET /repo/<id>` - Ver repositorio
- `GET /repo/<id>/data` - Obtener datos JSON

## 💡 Ejemplos de Uso

### Crear Usuario con Contraseña
```python
import requests

response = requests.post('http://localhost:8080/api/users/add', json={
    'username': 'cliente1',
    'password': 'pass123',
    'days': 30
})
```

### Crear Usuario por Token
```python
response = requests.post('http://localhost:8080/api/users/add', json={
    'token': 'ABC123XYZ',
    'alias': 'Cliente Juan',
    'days': 30
})
```

### Renovar Usuario
```python
response = requests.post('http://localhost:8080/api/users/renew', json={
    'username': 'cliente1',
    'days': 15
})
```

### Crear Repositorio
```python
response = requests.post('http://localhost:8080/api/repos/create', json={
    'name': 'Config VPN',
    'content': {
        'servidores': [
            {'nombre': 'US Server', 'ip': '192.168.1.10'}
        ]
    }
})
```

## 🔒 Seguridad

- Autenticación con PIN
- Sesiones con expiración (2 horas)
- URLs únicas para repositorios
- Solo administradores pueden crear/eliminar
- Repositorios públicos en modo solo lectura

## 🐛 Solución de Problemas

### No puedo acceder desde otra máquina
- Verifica que el firewall permita el puerto 8080
- Asegúrate de usar la IP correcta
- El servidor debe estar corriendo

### Error al crear repositorio
- Verifica que el JSON sea válido
- Asegúrate de tener permisos de escritura

## 📚 Documentación Adicional

- `ejemplo_uso_api.py` - Ejemplos de código
- `config.py` - Opciones de configuración

## 👨‍💻 Créditos

Desarrollado por **CrisDev**
- Telegram: [@crisis1823](https://t.me/crisis1823)

## 🛠️ Tecnologías

- **Backend**: Python 3.7+, Flask 2.0+
- **Frontend**: HTML5, CSS3, JavaScript (Vanilla)
- **Diseño**: iOS Dark Theme, Glassmorphism
- **Almacenamiento**: JSON (archivos)
- **Autenticación**: Session-based

## 🗺️ Roadmap

- [ ] Sistema de roles (admin, moderador, usuario)
- [ ] Exportar/importar usuarios en CSV
- [ ] Gráficos de estadísticas de uso
- [ ] Logs de actividad del sistema
- [ ] API REST completa con documentación
- [ ] Autenticación de dos factores (2FA)
- [ ] Temas personalizables (claro/oscuro)
- [ ] Soporte multi-idioma (i18n)
- [ ] Tests automatizados
- [ ] Docker support

## 🤝 Contribuir

¡Las contribuciones son bienvenidas! Lee [CONTRIBUTING.md](CONTRIBUTING.md) para más información.

## 📝 Changelog

Ver [CHANGELOG.md](CHANGELOG.md) para el historial de cambios.

## 📄 Licencia

Este proyecto es de uso privado.

---

**Versión**: 2.0  
**Última actualización**: Marzo 2026
