# Team Chat (React Native + Expo + Supabase)

Chat de equipo estilo "clan" con mensajes en tiempo real por `team_id`.

## Requisitos
- Node 18+
- Expo CLI
- Proyecto Supabase con Auth

Configura variables en tiempo de ejecución (Expo):
- `EXPO_PUBLIC_SUPABASE_URL`
- `EXPO_PUBLIC_SUPABASE_ANON_KEY`
- `EXPO_PUBLIC_TEAM_ID` (opcional, para saltar el input de teamId)

## Instalación

```powershell
# dentro de react-native-team-chat/
npm i
npm run start
```

Abre con Expo Go (Android/iOS) o web.

## Estructura

```
src/
  lib/supabase.ts            # Cliente Supabase
  hooks/useTeamChat.ts       # Hook: estado y lógica (carga, paginación, realtime, envío)
  components/MessageList.tsx # Lista invertida, burbujas, timestamp relativo
  components/MessageInput.tsx# Input multiline + enviar con estado
  screens/TeamChatScreen.tsx # Orquesta UI + sesión
  screens/LoginScreen.tsx    # Login email+password (sign in / sign up)
App.tsx                      # Puerta de entrada: Login -> TeamChatScreen (con teamId)
  utils/time.ts              # Formateo relativo simple
  types/models.ts            # Tipos TS
```

## Backend (Supabase)

Ejecuta el SQL en `../database/team_chat_schema.sql` en tu proyecto Supabase.
Incluye:
- Tablas: `teams`, `team_members`, `messages`
- RLS para que solo miembros accedan
- RPC `send_team_message(p_team, p_content)` con anti-spam y filtro de palabras

## Uso

- Renderiza `TeamChatScreen` pasando `teamId` (string):

```tsx
<TeamChatScreen teamId={"<uuid-del-team>"} />

O, en App.tsx, define `EXPO_PUBLIC_TEAM_ID` en tu entorno y entra directo tras login.
```

- El hook carga 50 últimos mensajes (desc), mantiene estado en ASC (para UI estable), y la `FlatList` va `inverted`.
- Paginación con `onEndReached` ("cargar más").
- Envío a través de RPC (optimistic UI + reemplazo por realtime).

## Pruebas

- Abre dos sesiones (dos cuentas) en el mismo `team_id` y envía mensajes.
- Verifica paginación con >100 mensajes.
- Prueba errores:
  - Usuario no miembro → error en RPC
  - Rate limit (5/10s) → muestra mensaje
  - Palabra prohibida → muestra mensaje

## Notas

- Asegúrate de habilitar Realtime en la tabla `messages`.
- Si ya tienes tablas `teams`/`team_members` en tu app, puedes:
  - Ajustar el SQL para reutilizarlas (cambia la FK de `messages.team_id` a tu `teams` existente).
  - O mantener `messages` y políticas, usando tus propias tablas para membership.

### Dependencias extra
- `@react-native-async-storage/async-storage` para persistir sesión de Supabase.
