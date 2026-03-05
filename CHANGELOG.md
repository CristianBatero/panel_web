# 📋 Changelog

Todos los cambios notables del proyecto serán documentados en este archivo.

## [2.0.0] - 2026-03-05

### ✨ Añadido
- Diseño completamente renovado con tema oscuro estilo iOS
- Sistema de gestión de usuarios con tabla profesional
- Filtros por estado (Activos/Vencidos) y búsqueda en tiempo real
- Función de renovación de usuarios con preview de nueva fecha
- Sistema de notificaciones (individual y masiva)
- Modales para crear/editar usuarios
- Badges de estado con colores (Activo, Vencido, Token, Password)
- Cálculo automático de días restantes
- Diseño responsive optimizado para móvil
- Transformación de tabla a cards en móvil
- Botones touch-friendly (44x44px mínimo)
- Favicon personalizado
- Créditos del desarrollador en todas las páginas
- Glassmorphism y efectos de blur
- Gradientes iOS (azul #007AFF → púrpura #5856D6)
- Animaciones suaves y transiciones

### 🎨 Mejorado
- Interfaz de usuario completamente rediseñada
- Experiencia móvil optimizada
- Tipografía con fuente -apple-system
- Colores profesionales y consistentes
- Accesibilidad mejorada
- Performance de renderizado

### 🔧 Técnico
- Estructura de archivos limpia y organizada
- Documentación consolidada
- Configuración separada en config.py
- .gitignore actualizado
- .gitattributes para normalización de archivos
- Licencia MIT añadida
- Guía de contribución

### 📱 Responsive
- Breakpoints: >1024px, 769-1024px, 481-768px, <480px
- Tabla → Cards en móvil
- Botones adaptativos
- Modales optimizados para pantallas pequeñas
- Prevención de auto-zoom en iOS

## [1.0.0] - 2026-03-01

### ✨ Inicial
- Panel web básico con Flask
- Autenticación con PIN
- Gestión básica de usuarios
- Sistema de repositorios JSON
- Vista pública de repositorios
- API REST básica
- Templates HTML simples
- Almacenamiento en archivos JSON

---

## Formato

El formato está basado en [Keep a Changelog](https://keepachangelog.com/es-ES/1.0.0/),
y este proyecto adhiere a [Semantic Versioning](https://semver.org/lang/es/).

### Tipos de cambios
- `✨ Añadido` - Nuevas funcionalidades
- `🔧 Cambiado` - Cambios en funcionalidades existentes
- `⚠️ Deprecado` - Funcionalidades que serán removidas
- `🗑️ Removido` - Funcionalidades removidas
- `🐛 Corregido` - Corrección de bugs
- `🔒 Seguridad` - Cambios de seguridad
