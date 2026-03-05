# 🌐 Panel Web Elite - Guía de Instalación

Panel de administración web profesional con diseño iOS oscuro para gestión de usuarios y repositorios JSON.

---

## 📋 Requisitos

- Ubuntu/Debian/CentOS (VPS o servidor)
- Python 3.7 o superior
- Acceso root o sudo

---

## 🚀 Instalación Rápida

Copia y pega estos comandos en tu terminal:

### 1. Actualizar sistema e instalar dependencias

```bash
sudo apt update
pip3 install flask requests
```

### 2. Descargar archivos del panel

```bash
# Descargar servidor principal
wget -O web_panel.py https://raw.githubusercontent.com/CristianBatero/panel_web/main/web_panel.py

# Descargar archivo de configuración
wget -O config.py https://raw.githubusercontent.com/CristianBatero/panel_web/main/config.example.py

# Descargar plantillas HTML
mkdir -p templates
wget -O templates/login.html https://raw.githubusercontent.com/CristianBatero/panel_web/main/templates/login.html
wget -O templates/dashboard.html https://raw.githubusercontent.com/CristianBatero/panel_web/main/templates/dashboard.html
wget -O templates/repo_view.html https://raw.githubusercontent.com/CristianBatero/panel_web/main/templates/repo_view.html
```

### 3. Configurar tu PIN

Edita el archivo de configuración:

```bash
nano config.py
```

Busca esta línea y cambia el PIN:

```python
'admin_pin': '1823',  # Cambia 1823 por tu PIN
```

Guarda con `CTRL + O`, Enter, y sal con `CTRL + X`

### 4. Iniciar el panel

```bash
# Iniciar en segundo plano
nohup python3 web_panel.py > panel.log 2>&1 &
```

### 5. Acceder al panel

Abre tu navegador y ve a:

```
http://TU_IP_VPS:8080
```

Ingresa el PIN que configuraste.

---

## 🔥 Configurar Firewall

Permite el acceso al puerto 8080:

```bash
# Ubuntu/Debian
sudo ufw allow 8080/tcp
sudo ufw reload

# CentOS/RHEL
sudo firewall-cmd --permanent --add-port=8080/tcp
sudo firewall-cmd --reload
```

---

## 📱 Acceso desde Móvil/PC

Una vez instalado, puedes acceder desde cualquier dispositivo:

```
http://TU_IP_VPS:8080
```

Ejemplo: `http://192.168.1.100:8080`

---

## 🔄 Comandos de Mantenimiento

### Ver si el panel está corriendo

```bash
ps aux | grep web_panel.py
```

### Ver logs del panel

```bash
tail -f panel.log
```

### Detener el panel

```bash
pkill -f web_panel.py
```

### Reiniciar el panel

```bash
# Detener
pkill -f web_panel.py

# Iniciar de nuevo
nohup python3 web_panel.py > panel.log 2>&1 &
```

### Actualizar el panel

```bash
# Detener el panel
pkill -f web_panel.py

# Descargar nueva versión
wget -O web_panel.py https://raw.githubusercontent.com/CristianBatero/panel_web/main/web_panel.py

# Iniciar de nuevo
nohup python3 web_panel.py > panel.log 2>&1 &
```

---

## ⚙️ Configuración Avanzada

### Cambiar el puerto

Edita `config.py`:

```bash
nano config.py
```

Busca y cambia:

```python
'port': 8080,  # Cambia a tu puerto deseado
```

### Cambiar el PIN

Edita `config.py`:

```bash
nano config.py
```

Busca y cambia:

```python
'admin_pin': 'TU_NUEVO_PIN',
```

Reinicia el panel después de cualquier cambio.

---

## � Funcionalidades del Panel

### 👥 Gestión de Usuarios

- ✅ Crear usuarios con contraseña
- ✅ Registrar usuarios por token (Device ID)
- ✅ Renovar suscripciones (añadir días)
- ✅ Filtrar por estado (Activos/Vencidos)
- ✅ Búsqueda en tiempo real
- ✅ Enviar notificaciones
- ✅ Editar y eliminar usuarios

### 📦 Sistema de Repositorios

- ✅ Crear repositorios con contenido JSON
- ✅ URLs únicas para compartir
- ✅ Vista pública (solo lectura)
- ✅ Copiar y descargar archivos
- ✅ Eliminar repositorios

---

## 🐛 Solución de Problemas

### Error: "No module named 'flask'"

```bash
pip3 install flask requests
```

### Error: "Permission denied"

Usa sudo:

```bash
sudo python3 web_panel.py
```

### No puedo acceder desde el navegador

1. Verifica que el panel esté corriendo:
   ```bash
   ps aux | grep web_panel.py
   ```

2. Verifica el firewall:
   ```bash
   sudo ufw status
   ```

3. Verifica los logs:
   ```bash
   tail -f panel.log
   ```

### Puerto 8080 ocupado

Cambia el puerto en `config.py` o detén el proceso que lo usa:

```bash
# Ver qué usa el puerto
sudo lsof -i :8080

# Matar el proceso
sudo kill -9 ID_DEL_PROCESO
```

---

## 📦 Instalación Completa (Script Automático)

Si prefieres un script que lo haga todo automáticamente:

```bash
# Descargar instalador
wget -O install.sh https://raw.githubusercontent.com/CristianBatero/panel_web/main/install.sh

# Dar permisos
chmod +x install.sh

# Ejecutar (te pedirá el PIN)
./install.sh
```

---

## � Seguridad

### Recomendaciones:

- ✅ Usa un PIN fuerte (mínimo 8 caracteres)
- ✅ Cambia el PIN por defecto
- ✅ Mantén el sistema actualizado
- ✅ Usa HTTPS en producción (con Nginx)
- ✅ Haz backups regulares de la carpeta `repositories/`

### Backup de datos:

```bash
# Crear backup
tar -czf panel_backup_$(date +%Y%m%d).tar.gz repositories/ config.py

# Restaurar backup
tar -xzf panel_backup_20260305.tar.gz
```

---

## � Soporte

¿Necesitas ayuda?

- 📱 **Telegram**: [@crisis1823](https://t.me/crisis1823)
- 🐛 **Issues**: [GitHub Issues](https://github.com/CristianBatero/panel_web/issues)

---

## 👨‍💻 Créditos

Desarrollado con ❤️ por **CrisDev**

- Telegram: [@crisis1823](https://t.me/crisis1823)
- GitHub: [CristianBatero](https://github.com/CristianBatero)

---

## 📄 Licencia

Este proyecto está bajo la Licencia MIT.

---

## 🎉 ¡Listo!

Tu Panel Web Elite está instalado y funcionando.

Accede en: **http://TU_IP:8080**

---

**Versión**: 2.0.0  
**Última actualización**: Marzo 2026
