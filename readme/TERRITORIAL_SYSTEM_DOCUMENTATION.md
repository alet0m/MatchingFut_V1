# Sistema Territorial Completo

## Descripción General
El Sistema Territorial es una característica central de la app que permite a los equipos competir por el control de sectores geográficos dentro de comunas. Este sistema gamifica el fútbol real añadiendo una capa estratégica de control territorial.

## Componentes Principales

### 1. Estructura Geográfica
- **Regiones**: División administrativa principal del país
- **Comunas**: Subdivisiones de regiones (ej: Quilicura, Renca, etc.)
- **Sectores**: Áreas específicas dentro de cada comuna que pueden ser controladas

### 2. Control Territorial
- Cada sector puede ser controlado por un solo equipo
- El control se obtiene ganando partidos en ese sector
- Cada sector tiene un historial de control que registra qué equipos lo han dominado
- Los sectores tienen diferentes niveles de dificultad (umbral de ELO requerido)

### 3. Sistema de Desafíos
- Un equipo puede desafiar al equipo que controla un sector
- El desafío debe ser aceptado por el equipo defensor
- Se programa un partido en ese sector específico
- El ganador obtiene o mantiene el control del sector

### 4. Rankings ELO
- Sistema de puntuación basado en ELO (como en ajedrez)
- Ranking global de todos los equipos
- Ranking por comuna
- Ranking especial para equipos con control territorial

### 5. Bonificaciones
- Controlar sectores proporciona bonificaciones de ELO
- Sectores estratégicos otorgan mayores bonificaciones
- Control prolongado aumenta la reputación del equipo

## Implementación Técnica

### Base de Datos
- Tablas para regiones, comunas y sectores
- Tabla de control_sectores para registrar quién controla cada sector
- Tabla de historial_control para mantener registro histórico
- Tabla de desafíos para gestionar los retos territoriales

### Frontend
- Mapa interactivo usando Google Maps
- Sistema de selección de comunas y visualización de sectores
- Interfaz para desafíos territoriales
- Visualización de rankings ELO
- Página de detalles para cada sector

### Funcionalidades
- Visualización del mapa con sectores coloreados según control
- Creación y gestión de desafíos territoriales
- Vista de rankings y estadísticas
- Historial de control para cada sector

## Flujos de Usuario

### Visualizar Mapa Territorial
1. Usuario accede a "Sistema Territorial" desde el menú principal
2. Selecciona una comuna de interés
3. Visualiza el mapa con sectores coloreados según el equipo que los controla
4. Puede tocar un sector para ver detalles (equipo controlador, ELO requerido, etc.)

### Lanzar Desafío Territorial
1. Usuario selecciona un sector controlado por otro equipo
2. Pulsa "Desafiar" y confirma la acción
3. El equipo defensor recibe notificación del desafío
4. Si acepta, se programa un partido por el control del sector
5. El ganador del partido obtiene/mantiene el control

### Consultar Rankings
1. Usuario accede a la sección "Rankings ELO"
2. Puede ver ranking global, por comuna o de equipos con control territorial
3. Visualiza estadísticas como ELO, partidos jugados, sectores controlados, etc.

## Impacto en el Juego

El Sistema Territorial transforma partidos casuales en enfrentamientos estratégicos, donde:

- Los equipos planifican qué sectores atacar basados en su ELO actual
- Se fomenta la competencia local en cada comuna
- Se crean rivalidades naturales por el control de sectores
- Aumenta el compromiso de los usuarios al tener objetivos a largo plazo
- Los equipos nuevos pueden crecer estratégicamente enfocándose en sectores menos disputados

## Próximas Mejoras
- Eventos especiales en sectores específicos
- Alianzas entre equipos para control compartido
- Temporadas con reseteo parcial de control territorial
- Logros y recompensas por control prolongado
- Estadísticas avanzadas de control territorial