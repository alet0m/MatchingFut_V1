# Instrucciones para Actualizar el Sistema de Amigos

Para actualizar el sistema de amigos de tu aplicación Fútbol App de Quilicura, sigue estos pasos:

## 1. Actualizar la Base de Datos

1. Abre el panel de administración de Supabase
2. Ve a la sección "SQL Editor"
3. Copia y pega el contenido del archivo `updated_friends_system.sql` 
4. Ejecuta el script completo

Este script:
- Elimina funciones y vistas existentes
- Crea o actualiza la tabla `friendships` con la estructura correcta
- Establece políticas de seguridad (RLS)
- Crea las funciones RPC necesarias
- Crea la vista `user_friends` actualizada

## 2. Actualizar el Código Flutter

### Reemplazar archivos existentes

```powershell
# Ejecuta estos comandos en una terminal PowerShell

# 1. Reemplazar el servicio de amigos
Copy-Item -Path "lib\features\teams\data\friends_service_updated.dart" -Destination "lib\features\teams\data\friends_service.dart" -Force

# 2. Reemplazar el modelo de amistad
Copy-Item -Path "lib\shared\models\friendship_model_updated.dart" -Destination "lib\shared\models\friendship_model.dart" -Force

# 3. Reemplazar los providers
Copy-Item -Path "lib\features\teams\data\providers\friends_providers_updated.dart" -Destination "lib\features\teams\data\providers\friends_providers.dart" -Force
```

## 3. Verificar la Implementación

Una vez aplicados los cambios, debes probar las siguientes funcionalidades:

1. **Enviar solicitud de amistad** - Verifica que la solicitud se envía correctamente
2. **Ver solicitudes pendientes** - Confirma que las solicitudes pendientes aparecen en la lista
3. **Aceptar/rechazar solicitudes** - Prueba ambas acciones
4. **Ver lista de amigos** - Verifica que los amigos aceptados aparecen en la lista
5. **Eliminar amigos** - Comprueba que la eliminación funciona correctamente

## 4. Solución de Problemas

Si encuentras errores después de la actualización:

1. **Errores de base de datos**:
   - Verifica en la consola de Supabase los errores específicos
   - Comprueba que todas las funciones RPC estén creadas correctamente

2. **Errores de código**:
   - Revisa las importaciones en los archivos que utilizan el sistema de amigos
   - Verifica que las llamadas a las funciones coincidan con las firmas actualizadas

3. **Problemas de UI**:
   - Si la interfaz de usuario no muestra correctamente los datos, asegúrate de que los widgets estén utilizando las propiedades correctas del modelo actualizado

## Estructura Final

La estructura actualizada del sistema de amigos utiliza:

- **Tabla**: `friendships` con campos `requester_id` y `receiver_id`
- **Vista**: `user_friends` para mostrar amistades aceptadas
- **Funciones RPC**: 
  - `send_friend_request`
  - `accept_friend_request`
  - `reject_friend_request`
  - `remove_friend`
  - `get_pending_friend_requests`
