# Notificaciones en tiempo real con Supabase (sin Firebase)

Este documento resume la arquitectura para tener avisos en tiempo real DENTRO de la app usando solo Supabase Realtime, sin integrar Firebase/APNs. Esto muestra notificaciones cuando la app está abierta. Si en el futuro quieres notificaciones del sistema (que suenen/aparezcan con la app cerrada), habrá que integrar los canales nativos (FCM/APNs) y una Edge Function de envío.

## Arquitectura

Supabase es el backend que orquesta:
  - Realtime (canales) para actualizar el contador/badge y mostrar SnackBars dentro de la app.
La app Flutter:
  - Usa providers y Realtime para mostrar avisos (SnackBars, badges) cuando está abierta.

## 1) SQL requerido

Para las notificaciones en‑app con Realtime no se requieren tablas adicionales específicas de notificaciones. Asegúrate de que las tablas funcionales (p. ej., `team_invitations`, `friendships`) estén configuradas con RLS y que tus proveedores/consultas usen Realtime cuando corresponda.

## 2) (Opcional futuro) Edge Function para push del sistema

Si más adelante quieres notificaciones del sistema (fuera de la app), se podrá agregar una Edge Function que procese eventos y envíe a los canales nativos (FCM/APNs). En este proyecto, por ahora NO se incluye ni utiliza.

## 3) Sin Firebase/APNs

Este proyecto no integra Firebase ni APNs. Todo el sistema de avisos es en‑app (Realtime). Para push nativo habrá que integrarlos en el futuro.

## 4) App Flutter

No hay paquetes de Firebase ni de notificaciones locales. La app usa Riverpod + Supabase Realtime para actualizar UI en tiempo real.

## 5) Pruebas

- Con la app instalada:
  - Inserta manualmente una `team_invitations` o `friendships` (pending) en Supabase Studio.
  - Verás SnackBars/actualizaciones en la app en tiempo real. No habrá notificaciones del sistema con la app cerrada.

## 6) Buenas prácticas

- Mantener providers y streams ligeros.
- Considerar backoff/reintentos en Realtime si se pierde conexión.

## 7) Siguientes pasos

- Si más adelante deseas push nativo, integrar FCM/APNs y preparar la Edge Function.
