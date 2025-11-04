# futbol_app

A new Flutter project.

## Getting Started

# Fútbol App - Quilicura ⚽

Una aplicación Flutter completa e interactiva para la comunidad futbolera de Quilicura que incluye sistema territorial, ranking ELO, y funcionalidades sociales avanzadas.

## 🚀 Características Principales

### ✅ Implementado
- **Autenticación personalizada** - Sistema de registro e inicio de sesión sin redes sociales
- **Onboarding interactivo** - Proceso guiado de configuración del perfil con animaciones
- **Dashboard dinámico** - Panel principal con estadísticas ELO y acciones rápidas
- **Navegación fluida** - Sistema de navegación con GoRouter y animaciones
- **Tema personalizado** - Diseño con colores de fútbol y microinteracciones

### 🔄 En Desarrollo
- **Mapa territorial** - Sistema de dominio de sectores de Quilicura
- **Ranking ELO** - Sistema de puntuación dinámico por territorio
- **Partidos en tiempo real** - Seguimiento minuto a minuto de partidos
- **Sistema social** - Equipos, desafíos y feed de actividades
- **Base de datos completa** - PostgreSQL con Supabase

## 🛠️ Stack Tecnológico

- **Framework**: Flutter (Web + Mobile)
- **Estado**: Riverpod con annotations
- **Navegación**: GoRouter
- **Backend**: Supabase (PostgreSQL + Auth + Realtime)
- **Animaciones**: Lottie + Flutter Animate
- **Mapas**: Google Maps Flutter
- **UI**: Material Design 3

## 📱 Capturas de Pantalla

### Onboarding Interactivo
- Bienvenida con animaciones
- Formulario paso a paso del perfil
- Selección de preferencias de juego
- Configuración de objetivos

### Dashboard Principal
- Estadísticas ELO en tiempo real
- Acciones rápidas (crear/buscar partidos)
- Próximos partidos confirmados
- Feed de actividad reciente

## 🏗️ Arquitectura

```
lib/
├── core/                 # Configuración base
│   ├── app.dart         # App principal
│   ├── config/          # Configuraciones
│   ├── theme/           # Temas y estilos
│   └── router/          # Rutas y navegación
├── features/            # Funcionalidades
│   ├── auth/            # Autenticación
│   ├── onboarding/      # Proceso inicial
│   ├── dashboard/       # Panel principal
│   ├── maps/            # Sistema territorial
│   └── profile/         # Perfil de usuario
└── shared/              # Componentes compartidos
    ├── widgets/         # Widgets reutilizables
    └── models/          # Modelos de datos
```

## 🚀 Instalación y Uso

### Prerrequisitos
- Flutter 3.7.2 o superior
- Dart SDK
- Android Studio / VS Code
- Git

### Pasos
1. **Clonar el repositorio**
   ```bash
   git clone <repository-url>
   cd futbol_app
   ```

2. **Instalar dependencias**
   ```bash
   flutter pub get
   ```

3. **Configurar Supabase** (próximamente)
   - Crear proyecto en Supabase
   - Actualizar `lib/core/config/supabase_config.dart`

4. **Ejecutar la aplicación**
   ```bash
   flutter run
   ```

## 📋 Funcionalidades por Fase

### Fase 1: Fundamentos ✅
- [x] Setup del proyecto Flutter
- [x] Configuración de dependencias
- [x] Sistema de navegación con GoRouter
- [x] Tema personalizado de fútbol
- [x] Páginas principales (Welcome, Login, Register)

### Fase 2: Onboarding Interactivo ✅
- [x] Proceso paso a paso del perfil
- [x] Animaciones con Flutter Animate
- [x] Formularios con validación
- [x] Selección de preferencias de juego

### Fase 3: Dashboard Principal ✅
- [x] Panel de estadísticas ELO
- [x] Acciones rápidas
- [x] Lista de próximos partidos
- [x] Feed de actividad reciente

### Fase 4: Sistema de Mapas 🔄
- [ ] Integración con Google Maps
- [ ] Sectores de Quilicura
- [ ] Sistema de dominio territorial
- [ ] Animaciones de conquista

### Fase 5: Base de Datos 🔄
- [ ] Configuración de Supabase
- [ ] Esquemas de PostgreSQL
- [ ] Autenticación real
- [ ] Sincronización en tiempo real

## 🎯 Objetivos del Proyecto

1. **Comunidad Local**: Conectar jugadores de Quilicura
2. **Experiencia Interactiva**: App completamente animada e intuitiva
3. **Sistema Territorial**: Innovador sistema de dominio por sectores
4. **Competencia Sana**: Ranking ELO para motivar mejora
5. **Social**: Formar equipos y hacer amigos

## 🤝 Contribución

1. Fork el proyecto
2. Crea una rama para tu feature (`git checkout -b feature/nueva-funcionalidad`)
3. Commit tus cambios (`git commit -am 'Agrega nueva funcionalidad'`)
4. Push a la rama (`git push origin feature/nueva-funcionalidad`)
5. Abre un Pull Request

## 📄 Licencia

Este proyecto está bajo la Licencia MIT - ver el archivo [LICENSE](LICENSE) para más detalles.

## 📞 Contacto

- **Desarrollador**: Equipo Fútbol App
- **Email**: contacto@futbolquilicura.cl
- **Website**: [futbolquilicura.cl](https://futbolquilicura.cl)

---

**¡Únete a la revolución del fútbol en Quilicura! ⚽🔥**
