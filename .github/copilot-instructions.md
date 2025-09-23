<!-- Use this file to provide workspace-specific custom instructions to Copilot. For more details, visit https://code.visualstudio.com/docs/copilot/copilot-customization#_use-a-githubcopilotinstructionsmd-file -->

# Fútbol App - Quilicura

## Descripción del Proyecto
Esta es una aplicación Flutter completa para la comunidad futbolera de Quilicura que incluye:

- **Sistema de autenticación personalizado** (sin redes sociales)
- **Onboarding interactivo** con animaciones y formularios paso a paso
- **Dashboard personalizado** con estadísticas y acciones rápidas
- **Sistema de mapas territorial** para dominio de sectores
- **Ranking ELO** dinámico por territorio
- **Sistema social** con equipos y desafíos
- **Arquitectura limpia** con Feature-Based Development

## Stack Tecnológico
- **Frontend**: Flutter (Web + Mobile)
- **Estado**: Riverpod con annotations
- **Navegación**: GoRouter con guards de autenticación
- **Backend**: Supabase (PostgreSQL + Auth + Realtime)
- **Animaciones**: Lottie + Flutter Animate
- **Mapas**: Google Maps Flutter

## Estructura del Proyecto
```
lib/
├── core/                     # Configuración y servicios base
│   ├── app.dart             # App principal
│   ├── config/              # Configuraciones (Supabase, etc.)
│   ├── theme/               # Temas y estilos
│   └── router/              # Configuración de rutas
├── features/                # Funcionalidades por módulos
│   ├── auth/                # Autenticación
│   ├── onboarding/          # Proceso de onboarding
│   ├── dashboard/           # Panel principal
│   ├── maps/                # Sistema de mapas
│   └── profile/             # Perfil de usuario
└── shared/                  # Componentes y modelos compartidos
    ├── widgets/             # Widgets reutilizables
    └── models/              # Modelos de datos
```

## Características Principales Implementadas

### ✅ Fase 1: Fundamentos
- [x] Setup básico de Flutter con estructura de carpetas
- [x] Configuración de dependencias (Riverpod, GoRouter, Supabase, etc.)
- [x] Tema personalizado con colores de fútbol
- [x] Sistema de navegación con GoRouter

### ✅ Páginas Principales
- [x] **WelcomePage**: Pantalla de bienvenida con animaciones
- [x] **LoginPage**: Inicio de sesión con validaciones
- [x] **RegisterPage**: Registro de usuarios con formulario completo
- [x] **OnboardingPage**: Proceso interactivo de configuración del perfil
- [x] **DashboardPage**: Panel principal con estadísticas y acciones rápidas

### 🔄 En Desarrollo
- [ ] Sistema de autenticación con Supabase
- [ ] Base de datos PostgreSQL con tablas completas
- [ ] Sistema de mapas con Google Maps
- [ ] Funcionalidad de partidos en tiempo real
- [ ] Sistema ELO y rankings territoriales

## Instrucciones para Copilot

### Patrones de Código
1. **Usar Riverpod** para manejo de estado con annotations cuando sea posible
2. **Feature-Based Architecture**: Cada funcionalidad en su propia carpeta
3. **Animaciones**: Usar flutter_animate para microinteracciones
4. **Responsive Design**: Considerar tanto mobile como web
5. **Accesibilidad**: Incluir semanticLabels y contrastes apropiados

### Convenciones de Naming
- **Páginas**: `*_page.dart` (ej: `login_page.dart`)
- **Widgets**: `*_widget.dart` (ej: `custom_button_widget.dart`)
- **Providers**: `*_provider.dart` (ej: `auth_provider.dart`)
- **Modelos**: `*_model.dart` (ej: `user_model.dart`)

### Colores del Tema
- **Verde primario**: `Color(0xFF2E7D32)` (Verde césped)
- **Verde oscuro**: `Color(0xFF1B5E20)`
- **Naranja acento**: `Color(0xFFFF6F00)`
- **Background**: `Color(0xFFF8F9FA)`

### Próximos Pasos
1. Implementar autenticación real con Supabase
2. Crear base de datos con esquemas de PostgreSQL
3. Desarrollar sistema de mapas interactivo
4. Implementar sistema de partidos y equipos
5. Agregar sistema de notificaciones push

### Notas Importantes
- La app está enfocada en la comunidad de Quilicura específicamente
- Debe ser completamente interactiva desde el primer uso
- El sistema territorial es una característica clave y única
- Priorizar la experiencia de usuario y las animaciones fluidas
