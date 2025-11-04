# Fútbol App Quilicura — Guía Completa

Una app Flutter (Web + Mobile) para la comunidad futbolera de Quilicura: autenticación personalizada, onboarding, dashboard con métricas, sistema territorial con mapas, ranking ELO y funcionalidades sociales (equipos, amistades, desafíos) sobre Supabase (Auth + PostgreSQL + Realtime).


## 🎯 Características principales

- Autenticación personalizada (sin redes sociales)
- Onboarding paso a paso con animaciones
- Dashboard con estadísticas y accesos rápidos
- Sistema territorial (barrios/sectores de Quilicura)
- Ranking ELO de jugadores y equipos (global y por territorio)
- Social: equipos, invitaciones, amistades y desafíos
- Chat de equipos en tiempo real con contadores de no leído
- Centro de notificaciones en-app con badge en AppBar
- Arquitectura limpia, feature-based + Riverpod + GoRouter


## 🧱 Stack

- Flutter 3.x (Web + Android/iOS)
- Estado: Riverpod (con anotations cuando aplica)
- Navegación: GoRouter (con auth guards)
- Backend: Supabase (Auth + PostgREST + Realtime)
- Animaciones: Lottie + flutter_animate
- Mapas: Google Maps Flutter


## 📁 Estructura del proyecto

```
lib/
├─ core/                  # Config y servicios base
│  ├─ app.dart            # App principal
│  ├─ config/             # Configuraciones (Supabase, tema, etc.)
│  ├─ router/             # GoRouter + guards
│  └─ theme/              # Colores y Tipografías
├─ features/
│  ├─ auth/               # Autenticación
│  ├─ onboarding/         # Flujo inicial de perfil
│  ├─ dashboard/          # Panel principal
│  ├─ maps/               # Sistema de mapas
│  ├─ teams/              # Equipos + chat
│  ├─ notifications/      # Centro de notificaciones
│  └─ profile/            # Perfil de usuario
└─ shared/
   ├─ widgets/            # Widgets reutilizables
   └─ models/             # Modelos de datos
```

- Configuración de Supabase: `lib/core/config/supabase_config.dart`
- Rutas: `lib/core/router/app_router.dart` (o `app_router_simple.dart`)
- Proveedores clave (badges/RT): `lib/features/notifications/presentation/providers/notifications_providers.dart`
- Chat y repositorio: `lib/features/teams/presentation/pages/team_chat_page.dart`, `lib/features/teams/data/team_chat_repository.dart`


## 🔐 Supabase

- La app usa Supabase Flutter. Las credenciales se leen desde `SupabaseConfig`:
  - `lib/core/config/supabase_config.dart`
  - Puedes migrar a variables de entorno o inyección segura según tu proceso de build.

- Realtime: El proyecto usa Postgres Changes. Asegúrate de publicar tablas necesarias en `supabase_realtime` y configurar `REPLICA IDENTITY FULL` cuando se requieran payloads completos.


## 🗄️ Base de datos (scripts)

Todos los scripts viven en `database/`. Recomendado ejecutar en este orden mínimo para la app:

1) Core y seguridad (elige el que se alinee a tu estado actual):
- `new_database_setup.sql` o `complete_setup.sql` (según tu entorno)
- `secure_rls_setup.sql` o `essential_rls_setup.sql`
- `profiles_rls_for_safety.sql`

2) Perfiles/Jugadores/Amistades/Equipos:
- `players_table_setup.sql`, `friends_system_setup.sql` (o `friends_system_compatible.sql`)
- `team_invitations_table_setup.sql`
- `team_chat_schema.sql`

3) Chat en tiempo real y contadores no leídos:
- `team_chat_enable_realtime.sql`
- `chat_unread_setup.sql` (crea `last_seen_chat` + RPCs: `set_last_seen_chat`, `get_unread_conversations_count`, `get_unread_by_team`)

4) Rankings y vistas:
- `create_player_global_rank_view.sql`, `create_team_global_rank_view.sql`
- `ranking_functions.sql` (si aplica)

5) Realtime y publicación de tablas:
- `realtime_enable_core_tables.sql` (añade tablas a `supabase_realtime` y ajusta `replica identity`)

6) Notificaciones (opcional pero recomendado para el badge unificado):
- `notifications_table_setup.sql` (crea `public.notifications`, RLS, índices, helper `mark_all_notifications_read()` y la publica a Realtime)
- Si deseas revertir: `notifications_teardown.sql`

Notas:
- Hay scripts de diagnóstico y fixes (ej. `fix_*`, `diagnose_*`) que puedes aplicar si migras desde un estado previo.
- El centro de notificaciones funciona incluso si no existe `public.notifications`; en ese caso verás invitaciones/amistades/unread de chat, y se omite el conteo de `notifications` para evitar 404.


## 🔔 Notificaciones y badges

- Badge global (campana) suma:
  - Invitaciones de equipo pendientes
  - Solicitudes de amistad
  - Unread de chats de equipos (por equipo)
  - Unread de `public.notifications` (si la tabla existe)
- Proveedor: `notificationsBadgeCountProvider` con Stream + debounce y deduplicación.
- Página `/notifications` unifica:
  - Invitaciones de equipo (aceptar/rechazar)
  - Solicitudes de amistad
  - “Chats de equipos” con acceso directo al chat y contador por equipo
- Realtime: listeners con alcance reducido (ej. insert-only en `messages`) y claves de provider estables para evitar loops.


## 💬 Chat de equipos (Realtime + unread)

- Tablas: `messages` (en `team_chat_schema.sql`), `last_seen_chat` (en `chat_unread_setup.sql`).
- RPCs: `set_last_seen_chat(team_id)`, `get_unread_conversations_count()`, `get_unread_by_team()`.
- La página de chat:
  - Marca leído al abrir/scroll/enviar
  - Muestra contador de no leído si no estás al fondo
  - Enruta solo si eres miembro del equipo (guard de membresía)
- Realtime habilitado vía `team_chat_enable_realtime.sql` y `realtime_enable_core_tables.sql`.


## 🧭 Rutas clave (GoRouter)

- `/` → Welcome/Login/Register (según sesión)
- `/onboarding` → Configuración inicial de perfil
- `/dashboard` → Panel principal
- `/maps` → Territorio y sectores
- `/teams` → Equipos; incluye badges por equipo
- `/teams/:teamId/chat` → Chat de equipo (enforced membership)
- `/notifications` → Centro de notificaciones
- `/profile/:userId` → Perfil público

Los guards consultan `Supabase.instance.client.auth.currentUser` y tablas relacionadas (p. ej. membresías) para permitir/denegar.


## 🎨 Tema y UX

- Colores: Verde césped `#2E7D32`, verde oscuro `#1B5E20`, acento naranja `#FF6F00`, fondo `#F8F9FA`.
- Microinteracciones con `flutter_animate` y Lottie.
- Responsive: pensado para móvil y web.
- Accesibilidad: semanticLabels y contrastes adecuados.


## 🏃 Ejecutar la app

- VS Code Tasks incluidos:
  - “Flutter: Run App” (dispositivo actual)
  - “Flutter: Run Chrome” (Web)

- Opcional (documentación):
```powershell
# Web (Chrome)
flutter run -d chrome

# Dispositivo conectado por defecto
flutter run
```

Requisitos previos: Flutter SDK, Android SDK/Xcode/iOS sim dependiendo del destino.


## 🧪 Pruebas rápidas de extremo a extremo

- Abrir la app como Usuario A (Chrome) y Usuario B (otro navegador o dispositivo)
- Usuario A envía mensaje en chat de equipo → Usuario B ve “Chats de equipos” con contador; entra al chat y el contador baja automáticamente
- Usuario A envía invitación de equipo o solicitud de amistad → Usuario B la ve en `/notifications` y la gestiona (aceptar/rechazar)


## 🧩 Patrones y convenciones

- Feature-based + Riverpod Streams para datos en vivo
- Proveedores con debounce/dedupe para evitar loops de rebuild
- Firmas estables en providers “family” (no pasar List sin canonicalización)
- RLS estricta en Supabase; se consulta con `auth.uid()`


## 🔧 Solución de problemas (FAQ)

- 404 en `/rest/v1/notifications` → Ejecuta `database/notifications_table_setup.sql` o desactiva la sección que consulta esa tabla.
- La campana no actualiza hasta recargar → Asegura que `realtime_enable_core_tables.sql` haya agregado todas las tablas relevantes a `supabase_realtime` y que `REPLICA IDENTITY FULL` esté configurado donde haga falta.
- Loops en notificaciones/chats → Actualiza providers para usar claves estables (CSV ordenado en lugar de List) y mantén listeners de Realtime con alcance mínimo (p. ej., insert-only para `messages`).
- No puedo entrar a chat de otro equipo → Comportamiento esperado: hay guard de membresía.


## 📜 Licencia y notas

- El proyecto está orientado a la comunidad de Quilicura.
- Push externo (FCM/APNs) fue removido: solo in-app Realtime de Supabase.
- Asegura credenciales/rollout adecuados para tu entorno (no uses anon keys públicas fuera de los canales esperados).


## 📌 Referencias internas

- `database/notifications_table_setup.sql` — Crea `public.notifications` + RLS + publication + helper
- `database/chat_unread_setup.sql` — `last_seen_chat` + RPCs unread
- `database/realtime_enable_core_tables.sql` — Publicación y replica identity
- `lib/features/notifications/presentation/providers/notifications_providers.dart` — Badge, invitaciones, amistades, unread chat
- `lib/features/teams/data/team_chat_repository.dart` — Acceso a `messages`/RPCs y Realtime
- `lib/features/teams/presentation/pages/team_chat_page.dart` — UI chat + mark seen + guard membresía

---

Si quieres que agreguemos un feed de notificaciones para “nuevo mensaje de equipo” (inserciones en `public.notifications` con deep link al chat), lo implementamos con un trigger o inserción controlada desde el cliente/Edge Function siguiendo el esquema actual.
