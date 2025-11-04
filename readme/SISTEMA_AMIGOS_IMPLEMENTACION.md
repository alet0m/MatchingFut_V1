# Implementación del Sistema de Amigos

## Estructura de la Base de Datos

### Tabla `friendships`

```sql
CREATE TABLE IF NOT EXISTS public.friendships (
    id uuid DEFAULT gen_random_uuid() PRIMARY KEY,
    user_id uuid REFERENCES auth.users(id) ON DELETE CASCADE,
    friend_id uuid REFERENCES auth.users(id) ON DELETE CASCADE,
    status text DEFAULT 'pending' CHECK (status IN ('pending', 'accepted', 'rejected')),
    created_at timestamptz DEFAULT now(),
    updated_at timestamptz DEFAULT now(),
    
    -- Evitar duplicados
    UNIQUE(user_id, friend_id)
);
```

### Vista `user_friends`

```sql
CREATE OR REPLACE VIEW public.user_friends AS
SELECT DISTINCT
    CASE 
        WHEN f.user_id = auth.uid() THEN f.friend_id 
        ELSE f.user_id 
    END as friend_user_id,
    COALESCE(p.email, '') as email,
    COALESCE(p.full_name, 'Sin nombre') as full_name,
    p.profile_image_url,
    f.status,
    f.created_at as friendship_date
FROM public.friendships f
JOIN public.profiles p ON (
    (f.user_id = auth.uid() AND p.id = f.friend_id) OR
    (f.friend_id = auth.uid() AND p.id = f.user_id)
)
WHERE f.status = 'accepted';
```

## Flujo de Trabajo para Operaciones de Amistad

### 1. Enviar Solicitud de Amistad

1. El usuario A busca al usuario B por email
2. El sistema verifica que:
   - El usuario B existe
   - No es el mismo usuario A
   - No existe ya una solicitud o amistad entre A y B
3. Se crea un registro en `friendships` con:
   - `user_id` = ID del usuario A (solicitante)
   - `friend_id` = ID del usuario B (receptor)
   - `status` = 'pending'

### 2. Aceptar Solicitud de Amistad

1. El usuario B ve las solicitudes pendientes donde `friend_id` = ID de B y `status` = 'pending'
2. Al aceptar, se actualiza el registro con:
   - `status` = 'accepted'
   - `updated_at` = timestamp actual

### 3. Rechazar Solicitud de Amistad

1. El usuario B ve las solicitudes pendientes
2. Al rechazar, se actualiza el registro con:
   - `status` = 'rejected'
   - `updated_at` = timestamp actual

### 4. Eliminar Amistad

1. Cualquier usuario puede eliminar la amistad
2. Se elimina el registro donde:
   - (`user_id` = ID de A y `friend_id` = ID de B) O
   - (`user_id` = ID de B y `friend_id` = ID de A)

## Políticas de Seguridad (RLS)

```sql
-- Política para ver amistades propias
CREATE POLICY "Users can view their own friendships" ON public.friendships
    FOR SELECT USING (
        auth.uid() = user_id OR auth.uid() = friend_id
    );

-- Política para crear solicitudes de amistad
CREATE POLICY "Users can create friendship requests" ON public.friendships
    FOR INSERT WITH CHECK (
        auth.uid() = user_id
    );

-- Política para actualizar amistades (aceptar/rechazar)
CREATE POLICY "Users can update friendships" ON public.friendships
    FOR UPDATE USING (
        auth.uid() = friend_id  -- Solo el destinatario puede aceptar/rechazar
    );

-- Política para eliminar amistades
CREATE POLICY "Users can delete their friendships" ON public.friendships
    FOR DELETE USING (
        auth.uid() = user_id OR auth.uid() = friend_id
    );
```

## Modelos de Datos en Flutter

### FriendshipModel (solicitudes)

```dart
class FriendshipModel {
  final String id;
  final String userId;         // ID del solicitante
  final String friendId;       // ID del receptor
  final String status;         // 'pending', 'accepted', 'rejected'
  final DateTime createdAt;
  final DateTime? updatedAt;
  final String? friendEmail;
  final String? friendFullName;
  final String? friendProfileImage;
}
```

### FriendModel (amigos aceptados)

```dart
class FriendModel {
  final String userId;         // ID del amigo
  final String email;
  final String fullName;
  final String? profileImageUrl;
  final String status;         // 'accepted'
  final DateTime? friendshipDate;
  final bool isOnline;
}
```

## Implementación en Flutter

### Servicios

1. `getFriends()` - Obtiene lista de amigos aceptados
2. `getPendingRequests()` - Obtiene solicitudes pendientes
3. `sendFriendRequest(email)` - Envía solicitud por email
4. `acceptFriendRequest(id)` - Acepta solicitud
5. `rejectFriendRequest(id)` - Rechaza solicitud
6. `removeFriend(id)` - Elimina amistad
7. `searchUsersByEmail(query)` - Busca usuarios por email

## Correcciones Implementadas

1. Modificada la vista `user_friends` para usar la tabla `profiles` en lugar de `users`
2. Mejorado el manejo de errores en todas las funciones del servicio
3. Añadida verificación de estado en solicitudes duplicadas
4. Implementados los providers de Riverpod para todas las acciones
5. Corregida la interfaz de usuario para manejar correctamente los estados

## Recomendaciones para Mantenimiento

1. Mantener consistencia entre los nombres de campos en la base de datos y el código
2. Documentar cualquier cambio en la estructura de tablas
3. Probar todas las operaciones después de actualizaciones de seguridad en Supabase
4. Verificar periódicamente que las políticas RLS estén funcionando correctamente
