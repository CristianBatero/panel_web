# 📝 Comandos Git Útiles

## 🚀 Configuración Inicial

### 1. Configurar Git (primera vez)
```bash
git config --global user.name "Tu Nombre"
git config --global user.email "tu@email.com"
```

### 2. Inicializar Repositorio
```bash
cd panel
git init
```

### 3. Añadir Archivos
```bash
# Añadir todos los archivos
git add .

# O añadir archivos específicos
git add README.md
git add web_panel.py
```

### 4. Primer Commit
```bash
git commit -m "feat: versión 2.0.0 con diseño iOS completo"
```

### 5. Conectar con GitHub
```bash
# Crear repositorio en GitHub primero, luego:
git remote add origin https://github.com/CristianBatero/panel_web.git

# Verificar
git remote -v
```

### 6. Subir a GitHub
```bash
# Primera vez
git push -u origin main

# O si tu rama se llama master
git push -u origin master
```

## 🏷️ Tags y Versiones

### Crear Tag
```bash
git tag -a v2.0.0 -m "Versión 2.0.0 - Diseño iOS completo"
```

### Subir Tags
```bash
# Un tag específico
git push origin v2.0.0

# Todos los tags
git push origin --tags
```

### Listar Tags
```bash
git tag
```

### Eliminar Tag
```bash
# Local
git tag -d v2.0.0

# Remoto
git push origin --delete v2.0.0
```

## 🔄 Trabajo Diario

### Ver Estado
```bash
git status
```

### Ver Cambios
```bash
# Cambios no staged
git diff

# Cambios staged
git diff --staged
```

### Añadir y Commitear
```bash
# Añadir archivos modificados
git add .

# Commit con mensaje
git commit -m "fix: corregir error en login"

# Añadir y commitear en un paso (solo archivos ya trackeados)
git commit -am "fix: corregir error en login"
```

### Subir Cambios
```bash
git push
```

### Bajar Cambios
```bash
git pull
```

## 🌿 Ramas (Branches)

### Crear Rama
```bash
git checkout -b feature/nueva-funcionalidad
```

### Cambiar de Rama
```bash
git checkout main
```

### Listar Ramas
```bash
# Locales
git branch

# Todas (locales y remotas)
git branch -a
```

### Eliminar Rama
```bash
# Local
git branch -d feature/nueva-funcionalidad

# Remota
git push origin --delete feature/nueva-funcionalidad
```

### Fusionar Rama
```bash
# Estar en la rama destino (ej: main)
git checkout main

# Fusionar
git merge feature/nueva-funcionalidad
```

## 📜 Historial

### Ver Commits
```bash
# Historial completo
git log

# Historial resumido
git log --oneline

# Últimos 5 commits
git log -5

# Con gráfico
git log --graph --oneline --all
```

### Ver Cambios de un Commit
```bash
git show <commit-hash>
```

## ⏪ Deshacer Cambios

### Descartar Cambios Locales
```bash
# Un archivo
git checkout -- archivo.py

# Todos los archivos
git checkout -- .
```

### Deshacer Último Commit (mantener cambios)
```bash
git reset --soft HEAD~1
```

### Deshacer Último Commit (descartar cambios)
```bash
git reset --hard HEAD~1
```

### Revertir un Commit (crear nuevo commit)
```bash
git revert <commit-hash>
```

## 🔍 Búsqueda

### Buscar en Archivos
```bash
git grep "texto a buscar"
```

### Buscar en Commits
```bash
git log --grep="palabra"
```

## 🧹 Limpieza

### Limpiar Archivos No Trackeados
```bash
# Ver qué se eliminará
git clean -n

# Eliminar archivos
git clean -f

# Eliminar archivos y directorios
git clean -fd
```

### Ver Archivos Ignorados
```bash
git status --ignored
```

## 📦 Stash (Guardar Temporalmente)

### Guardar Cambios
```bash
git stash

# Con mensaje
git stash save "trabajo en progreso"
```

### Ver Stashes
```bash
git stash list
```

### Aplicar Stash
```bash
# Último stash
git stash apply

# Stash específico
git stash apply stash@{0}
```

### Eliminar Stash
```bash
# Último stash
git stash drop

# Todos los stashes
git stash clear
```

## 🔧 Configuración

### Ver Configuración
```bash
git config --list
```

### Configurar Editor
```bash
git config --global core.editor "code --wait"
```

### Configurar Alias
```bash
git config --global alias.st status
git config --global alias.co checkout
git config --global alias.br branch
git config --global alias.ci commit
```

## 📊 Estadísticas

### Contribuciones por Autor
```bash
git shortlog -sn
```

### Archivos Más Modificados
```bash
git log --pretty=format: --name-only | sort | uniq -c | sort -rg | head -10
```

## 🆘 Ayuda

### Ayuda General
```bash
git help
```

### Ayuda de un Comando
```bash
git help commit
git commit --help
```

## 💡 Tips

### Ignorar Cambios en Archivo Trackeado
```bash
git update-index --assume-unchanged config.py
```

### Dejar de Ignorar
```bash
git update-index --no-assume-unchanged config.py
```

### Ver Archivos Trackeados
```bash
git ls-files
```

### Clonar Solo Última Versión (más rápido)
```bash
git clone --depth 1 https://github.com/usuario/repo.git
```

## 🔐 SSH (Opcional)

### Generar Clave SSH
```bash
ssh-keygen -t ed25519 -C "tu@email.com"
```

### Añadir a SSH Agent
```bash
eval "$(ssh-agent -s)"
ssh-add ~/.ssh/id_ed25519
```

### Cambiar URL a SSH
```bash
git remote set-url origin git@github.com:CristianBatero/panel_web.git
```

## 📝 Convenciones de Commits

### Formato
```
tipo: descripción breve

Descripción detallada (opcional)
```

### Tipos
- `feat:` Nueva funcionalidad
- `fix:` Corrección de bug
- `docs:` Documentación
- `style:` Formato (sin cambios de código)
- `refactor:` Refactorización
- `test:` Añadir tests
- `chore:` Tareas de mantenimiento

### Ejemplos
```bash
git commit -m "feat: añadir sistema de notificaciones"
git commit -m "fix: corregir cálculo de días restantes"
git commit -m "docs: actualizar README con nuevas funcionalidades"
git commit -m "style: formatear código según PEP 8"
git commit -m "refactor: optimizar consultas a base de datos"
```

---

## 🔗 Referencias

- [Git Documentation](https://git-scm.com/doc)
- [GitHub Guides](https://guides.github.com/)
- [Conventional Commits](https://www.conventionalcommits.org/)
