# Plan Maestro de Implementación: Vantage (v1.1)

**Vantage** es un Gestor de Vida Contextual que adapta su interfaz y notificaciones según la ubicación (Geofencing) y el "Estado Mental" definido por el usuario.

## 1. Arquitectura del Proyecto (Clean Architecture)
- **Core:** Temas dinámicos, cliente API, persistencia local (Isar/Hive) y remota.
- **Features:**
  - **ContextEngine:** Gestión de Geofencing y lógica de "Modos".
  - **Auth:** Firebase Authentication.
  - **Tasks:** TODOs vinculados a contextos.
  - **Finance:** Nómina y gastos manuales.
  - **Media:** Hub de Anime/Manga/Series (API Integration).
  - **DevHub:** GitHub API + Notas técnicas.

## 2. El Sistema de Modos (Novedad)
La app no será rígida. El usuario podrá configurar "Modos" que filtran la información:
- **Modo Control Total:** Dashboard con métricas de finanzas, tareas pendientes y progreso de series.
- **Modo Desconexión:** Oculta automáticamente todo lo relacionado con "Trabajo" y "Proyectos GitHub". Prioriza Anime y Tareas de Hogar.
- **Modo Tránsito (Misiones):** Al detectar que estás "En Movimiento" o fuera de tus zonas seguras, muestra solo tareas de calle (compras, recados).
- **Modo Vacaciones:** Desactiva recordatorios de nómina/trabajo y se enfoca en listas de viaje y ocio.

## 3. Módulos de Implementación Progresiva

### Fase 1: Cimientos y Motor de Contexto
- Estructura base en Flutter.
- Configuración de Firebase.
- **MVP del ContextEngine:** Pantalla de configuración para definir el radio de "Casa", "Trabajo" y "Escuela", y qué modo activar en cada uno.

### Fase 2: Módulos de Datos (Hogar, Trabajo, Finanzas)
- Implementación de listas de tareas inteligentes.
- Módulo financiero con automatización de ingresos por nómina.

### Fase 3: Integraciones de APIs Externas
- Conexión con GitHub (Repos, Issues).
- Conexión con AniList/MyAnimeList.

### Fase 4: Pulido y Personalización
- UI/UX avanzada: Cambio de paleta de colores según el modo activo.
- Sistema de notificaciones proactivas basado en el modo.

## 4. Stack Tecnológico
- **UI:** Flutter (Material 3 con Temas Adaptativos).
- **Estado:** Riverpod.
- **Backend:** Firebase (Firestore + Cloud Functions).
- **DB Local:** Isar (ideal para Flutter y manejo de grandes volúmenes de datos locales con índices).
