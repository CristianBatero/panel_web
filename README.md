# 🌐 Panel Web Elite

Panel de administración web para gestión de usuarios y repositorios.

---

## 🚀 Instalación Automática

### Método 1: Instalador Ultra Robusto (RECOMENDADO PARA VPS)

```bash
wget https://raw.githubusercontent.com/CristianBatero/panel_web/main/install_ultra.sh
chmod +x install_ultra.sh
./install_ultra.sh
```

Este instalador es el más completo:
- ✅ Instala Python completo con todas las dependencias
- ✅ Instala Flask de 3 formas diferentes (garantiza éxito)
- ✅ Verifica cada paso del proceso
- ✅ Muestra información detallada
- ✅ Maneja errores automáticamente

### Método 2: Instalador Automático Mejorado

```bash
wget https://raw.githubusercontent.com/CristianBatero/panel_web/main/install.sh
chmod +x install.sh
./install.sh
```

### Método 3: Instalador Simple

```bash
wget https://raw.githubusercontent.com/CristianBatero/panel_web/main/install_simple.sh
chmod +x install_simple.sh
./install_simple.sh
```

**Todos los instaladores:**
- ✅ Instalan Python y dependencias automáticamente
- ✅ Descargan el panel desde GitHub
- ✅ Configuran el puerto 5000
- ✅ Abren el firewall
- ✅ Inician el panel automáticamente

---

## 🔍 Verificar Sistema Antes de Instalar

```bash
wget https://raw.githubusercontent.com/CristianBatero/panel_web/main/verificar_sistema.sh
chmod +x verificar_sistema.sh
./verificar_sistema.sh
```

Esto te dirá si tu VPS está listo para la instalación.

---

## 🌐 Acceder al Panel

Abre tu navegador en:

```
http://TU_IP:5000
```

Ingresa el PIN que configuraste durante la instalación.

---

## 📋 Comandos Útiles

### Ver logs del panel

```bash
tail -f panel.log
```

### Reiniciar el panel

```bash
pkill -f web_panel.py && nohup python3 web_panel.py > panel.log 2>&1 &
```

### Detener el panel

```bash
pkill -f web_panel.py
```

### Ver si está corriendo

```bash
ps aux | grep web_panel
```

### Actualizar a la última versión

```bash
cd panel
wget https://raw.githubusercontent.com/CristianBatero/panel_web/main/actualizar.sh
chmod +x actualizar.sh
./actualizar.sh
```

### Actualización manual (alternativa)

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

Busca esta línea y cámbiala:

```python
'admin_pin': 'TU_NUEVO_PIN',
```

Guarda los cambios:
- Presiona `CTRL + O`
- Presiona `Enter`
- Presiona `CTRL + X`

Reinicia el panel:

```bash
pkill -f web_panel.py && nohup python3 web_panel.py > panel.log 2>&1 &
```

---

## � Solución de Problemas

### El panel no inicia

Ver el error en los logs:

```bash
cat panel.log
```

### Puerto 5000 ocupado

Ver qué proceso está usando el puerto:

```bash
sudo lsof -i :5000
```

Detener el proceso:

```bash
sudo kill -9 ID_DEL_PROCESO
```

### No puedo acceder desde el navegador

Verificar que el panel esté corriendo:

```bash
ps aux | grep web_panel
```

Abrir el puerto en el firewall:

```bash
sudo ufw allow 5000/tcp
sudo ufw reload
```

---

## 📞 Soporte

**Telegram**: [@crisis1823](https://t.me/crisis1823)

---

Desarrollado por **CrisDev** | Versión 2.0.0
