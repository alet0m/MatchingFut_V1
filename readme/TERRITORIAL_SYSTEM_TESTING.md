# 🧪 Guía de Pruebas - Sistema Territorial

## 📋 Plan de Pruebas para el Sistema Territorial

Esta guía proporciona un enfoque sistemático para verificar la correcta implementación del sistema territorial después de la migración de la base de datos.

---

## 1. 🔍 Pruebas de Modelos y Servicios Básicos

### 1.1. Modelos Geográficos
- [ ] **RegionModel**: Verificar serialización/deserialización de JSON
- [ ] **ComunaModel**: Verificar relaciones con regiones
- [ ] **SectorModel**: Verificar relaciones con comunas
- [ ] **SectorControlHistoryModel**: Verificar registro histórico
- [ ] **FootballModalityModel**: Verificar compatibilidad con sectores

### 1.2. Servicios de Ubicación
- [ ] **LocationService.getRegions()**: Devuelve todas las regiones activas
- [ ] **LocationService.getComunas(regionId)**: Filtra correctamente por región
- [ ] **LocationService.getSectors(comunaId)**: Filtra correctamente por comuna
- [ ] **LocationService.getActiveComunas()**: Solo devuelve comunas activas

### 1.3. Servicios de Control de Sectores
- [ ] **SectorControlService.getSectorControllingTeam(sectorId)**: Devuelve equipo correcto
- [ ] **SectorControlService.getSectorControlHistory(sectorId)**: Historial ordenado
- [ ] **SectorControlService.updateSectorControl()**: Actualiza BD correctamente

---

## 2. 🖼️ Pruebas de UI y Widgets

### 2.1. Selector de Comuna
- [ ] Al iniciar, carga todas las regiones disponibles
- [ ] Al seleccionar región, carga sus comunas correspondientes
- [ ] Callback `onComunaSelected` se ejecuta con parámetros correctos
- [ ] Carga comuna inicial si se proporciona `initialComunaId`
- [ ] Visualización correcta en diferentes tamaños de pantalla

### 2.2. Mapa Territorial
- [ ] Carga Google Maps correctamente
- [ ] Visualiza sectores con polígonos precisos
- [ ] Colores de sectores indican control por equipos
- [ ] Interacción al tocar sectores muestra información
- [ ] Zoom/pan funcionan correctamente
- [ ] Actualización en tiempo real al cambiar comuna

---

## 3. 📱 Pruebas de Páginas y Flujos Completos

### 3.1. Página de Mapa Territorial
- [ ] Carga con Quilicura como comuna por defecto
- [ ] Selector de comuna funciona y actualiza mapa
- [ ] Al seleccionar sector se muestran detalles correctos
- [ ] Botón flotante navega a Rankings
- [ ] Diálogo informativo funciona correctamente

### 3.2. Página de Rankings
- [ ] Muestra tres pestañas: Global, Comuna, Sectores
- [ ] Datos ordenados correctamente por ELO
- [ ] Selector de comuna filtra rankings de Comuna y Sectores
- [ ] Visualización correcta de equipos con control territorial
- [ ] Navegación a perfiles de equipos funciona

### 3.3. Sistema de Desafíos
- [ ] **ChallengesPage**: Muestra desafíos pendientes/activos/históricos
- [ ] Aceptar/rechazar desafío actualiza estado en tiempo real
- [ ] **CreateChallengePage**: Permite seleccionar sector y equipo defensor
- [ ] Creación de desafío inserta registro en BD
- [ ] Validaciones impiden desafiar al propio equipo

---

## 4. 🔄 Pruebas de Integración Específicas

### 4.1. Integración Mapa-Control
- [ ] Al ganar control de sector, mapa actualiza visualización
- [ ] Historial de control registra cambios con timestamps
- [ ] Rankings se actualizan al cambiar control territorial

### 4.2. Integración Desafíos-Partidos
- [ ] Aceptar desafío crea partido programado en la tabla matches
- [ ] Completar partido actualiza control del sector según ganador
- [ ] ELO de equipos se ajusta considerando control territorial

### 4.3. Prueba de Flujo Completo
- [ ] **Flujo completo**: Visualizar mapa → Crear desafío → Aceptar → Jugar partido → Ver control actualizado → Verificar ranking
- [ ] Datos consistentes entre todas las pantallas
- [ ] Cambios persisten correctamente en BD

---

## 5. ⚡ Pruebas de Rendimiento y Casos Límite

### 5.1. Rendimiento
- [ ] Tiempo de carga del mapa con 50+ sectores
- [ ] Rendimiento con 100+ equipos en rankings
- [ ] Eficiencia de consultas a BD (revisar logs)

### 5.2. Casos Límite
- [ ] Usuario sin equipo intenta crear desafío
- [ ] Sector sin control territorial
- [ ] Comportamiento con conexión intermitente
- [ ] Múltiples desafíos simultáneos al mismo sector

---

## 📝 Instrucciones para Ejecución

### Preparación:
1. Ejecutar app en modo desarrollo
2. Tener Supabase con datos de prueba cargados
3. Preparar 2+ cuentas de usuario para probar interacciones
4. Tener 3+ equipos creados en diferentes comunas

### Procedimiento:
1. Ejecutar pruebas en orden secuencial
2. Documentar resultados con capturas de pantalla
3. Para cada prueba, registrar:
   - ✅ ÉXITO: Funciona según especificaciones
   - ⚠️ PARCIAL: Funciona con limitaciones
   - ❌ FALLO: No funciona correctamente
4. Documentar cualquier comportamiento inesperado

---

## 🔍 Verificación de Base de Datos

Para confirmar correcta persistencia, verificar en Supabase:

### Tablas a revisar:
- **regions**: Datos completos de regiones
- **comunas**: Relación correcta con regiones
- **sectors**: Polígonos correctos, relación con comunas
- **sector_control**: Registros actualizados de control
- **sector_control_history**: Historial completo y ordenado
- **challenges**: Estado correcto de desafíos
- **matches**: Partidos creados desde desafíos

---

## 📊 Métricas de Éxito

### Rendimiento:
- ⏱️ Tiempo de carga inicial < 3 segundos
- 🗺️ Renderizado de mapa < 2 segundos
- 📋 Carga de rankings < 1 segundo
- 🔄 Actualización en tiempo real < 500ms

### Funcionalidad:
- 🎯 100% de operaciones CRUD exitosas
- 📱 UI responsiva en todos los tamaños de pantalla
- 🔄 Sincronización correcta con backend
- 🧩 Integración perfecta con sistema existente

---

## 🚀 Próximos Pasos Después de Testing

1. Corregir cualquier error identificado
2. Implementar mejoras de rendimiento si es necesario
3. Considerar expansión con características adicionales:
   - Sistema de temporadas
   - Eventos especiales en sectores
   - Alianzas entre equipos

---

*Guía de Pruebas v1.0 - Septiembre 2025*  
*Creada para validación del Sistema Territorial*