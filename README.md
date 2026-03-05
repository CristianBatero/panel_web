# 🌐 Panel Web Elite

Panel de administración web profesional para gestión de usuarios y repositorios.

---

## 🚀 Instalación (1 Comando)

Copia y pega este comando en tu terminal:

```bash
wget -O - https://raw.githubusercontent.com/CristianBatero/panel_web/main/install.sh | bash
```

El instalador hará TODO automáticamente:
- ✅ Instala Python y dependencias
- ✅ Descarga el panel
- ✅ Te pide tu PIN
- ✅ Configura el puerto 5000
- ✅ Abre el firewall
- ✅ Inicia el panel

**Listo en 2 minutos.**

---

## 🌐 Acceder al Panel

Abre tu navegador:

```
http://TU_IP:5000
```

Ingresa el PIN que configuraste.

---

## 📋 Comandos Útiles

### Ver logs del panel

```bash
tail -f panel.log
```

### Reiniciar el panel

```bash
pkill -f web_panel.py
nohup python3 web_panel.py > panel.log 2>&1 &
```

### Ver si está corriendo

```bash
ps aux | grep web_panel
```

### Detener el panel

```bash
pkill -f web_panel.py
```

---

## 🔄 Actualizar el Panel

```bash
pkill -f web_panel.py
wget -O web_panel.py https://raw.githubusercontent.com/CristianBatero/panel_web/main/web_panel.py
nohup python3 web_panel.py > panel.log 2>&1 &
```

---

## ⚙️ Cambiar el PIN

Edita el archivo de configuración:

```bash
nano config.py
```

Busca y cambia:

```python
'admin_pin': 'TU_NUEVO_PIN',
```

Guarda: `CTRL + O`, Enter, `CTRL + X`

Reinicia el panel:

```bash
pkill -f web_panel.py
nohup python3 web_panel.py > panel.log 2>&1 &
```

---

## 🎯 Funcionalidades

### 👥 Gestión de Usuarios
- Crear usuarios con contraseña
- Registrar usuarios por token (Device ID)
- Renovar suscripciones
- Filtrar activos/vencidos
- Búsqueda en tiempo real
- Enviar notificaciones
- Editar y eliminar

### 📦 Repositorios
- Crear repositorios JSON
- URLs únicas para compartir
- Vista pública
- Copiar y descargar
- Eliminar repositorios

---

## 🐛 Solución de Problemas

### El panel no inicia

Ver el error:
```bash
cat panel.log
```

### Puerto 5000 ocupado

Ver qué lo usa:
```bash
sudo lsof -i :5000
```

Matar el proceso:
```bash
sudo kill -9 ID_DEL_PROCESO
```

### No puedo acceder desde el navegador

1. Verifica que esté corriendo:
   ```bash
   ps aux | grep web_panel
   ```

2. Verifica el firewall:
   ```bash
   sudo ufw status
   ```

3. Abre el puerto manualmente:
   ```bash
   sudo ufw allow 5000/tcp
   ```

---

## 📞 Soporte

**Telegram**: [@crisis1823](https://t.me/crisis1823)

---

## 👨‍💻 Créditos

Desarrollado por **CrisDev**

---

**Versión**: 2.0.0
