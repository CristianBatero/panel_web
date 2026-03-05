# ⚡ Instalación Rápida

## 🚀 Instalar (1 Comando)

```bash
wget -O - https://raw.githubusercontent.com/CristianBatero/panel_web/main/install.sh | bash
```

Ingresa tu PIN cuando se solicite.

---

## 🌐 Acceder

```
http://TU_IP:5000
```

---

## 📋 Comandos

### Ver logs
```bash
tail -f panel.log
```

### Reiniciar
```bash
pkill -f web_panel.py
nohup python3 web_panel.py > panel.log 2>&1 &
```

### Actualizar
```bash
pkill -f web_panel.py
wget -O web_panel.py https://raw.githubusercontent.com/CristianBatero/panel_web/main/web_panel.py
nohup python3 web_panel.py > panel.log 2>&1 &
```

---

**Soporte**: [@crisis1823](https://t.me/crisis1823)
