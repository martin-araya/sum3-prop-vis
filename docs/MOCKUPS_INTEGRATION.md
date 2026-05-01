# 📱💻 AuditChain — Mockups y Propuesta de Integración Móvil/Web

> Este documento describe la propuesta de integración entre la **aplicación web** (admin / supervisor) y la **aplicación móvil** (auditor en terreno) de AuditChain. Acompaña a tres mockups SVG que ilustran las pantallas clave y a la propuesta de diseño (`DESIGN_PROPOSAL.md`) que define los tokens visuales.

---

## 1. Visión general

AuditChain tiene **tres tipos de usuario** con contextos de uso radicalmente distintos:

| Persona | Contexto | Dispositivo principal | Frecuencia |
|---|---|---|---|
| **Administrador** | Oficina central, decisiones de red, reportes a directorio | Desktop (1366–1920 px) | Diario, sesiones largas (1–4 h) |
| **Supervisor regional** | Mixto: oficina + viajes a sucursales | Laptop + tablet | Diario, sesiones medias (15–60 min) |
| **Auditor de terreno** | En sucursal, de pie, manos ocupadas, sin escritorio | **Mobile (smartphone)**, ocasional tablet | Diario, sesiones cortas y frecuentes (5–15 min, varias por día) |

**Conclusión de diseño**: la aplicación NO puede ser "responsive una sola UI". Debe ser **dos experiencias coherentes en sistema de diseño pero diferentes en flujo y densidad**. Web optimiza para análisis y administración; mobile optimiza para captura rápida en condiciones adversas.

---

## 2. Mockups entregados

### 2.1 `web_dashboard.svg` — Dashboard administrativo (1440 × 900 px)

**Audiencia**: Admin / Supervisor regional.
**Pantalla raíz tras login.**

**Anatomía:**
- **Sidebar izquierda** (240 px, `--primary-900`): logo + navegación primaria (Dashboard, Sucursales, Auditores, Auditorías, Reportes, Configuración). Footer con avatar y estado del usuario actual.
- **Topbar** (64 px, blanco con borde inferior): búsqueda global con atajo `⌘K`, icono de notificaciones con dot rojo, avatar del usuario.
- **Header de contenido**: saludo personalizado en español ("Bienvenida, Jane 👋"), fecha localizada (`26 oct 2023`), subtítulo descriptivo del módulo. Acciones a la derecha: filtro de fecha + botón primary "Nueva auditoría".
- **Fila de KPIs**: 5 cards con métricas críticas:
  1. **Total auditorías**: 1.452 (formato es-CL) con delta ↑ 8,5% en verde.
  2. **Cumplimiento general**: 91,2% con delta ↑ 1,2%.
  3. **Auditorías pendientes**: 128 con delta ↓ -3,1% (ámbar, indica alerta).
  4. **Auditores activos**: 45 con delta ↑ 2,2%.
  5. **Score promedio red**: 87,6 / 100.
- **Sección de gráficos** (grid 2 columnas):
  - **Bar chart agrupado**: Compliance por región × trimestre. 4 grupos (Norte, Centro, Sur, Metropolitana) × 4 barras (Q1–Q4). Gradientes de `--primary-900` a `--accent-500`.
  - **Donut chart**: Distribución de estados. 70% completadas (verde), 20% pendientes (cyan), 10% vencidas (gris). Centro con número grande.
- **Card de riesgo**: ancho completo bajo los charts. Listado de las 3 sucursales con peor desempeño + CTA "Ver detalle".
- **Tabla de auditorías recientes**: columnas `ID | Sucursal | Auditor | Fecha | Score | Estado | Acciones`. IDs en JetBrains Mono. Estados como badges. Acciones en menú de 3 puntos. Paginación inferior.

**Diferencias frente al mockup original (en inglés):**
- 100% en español, formato numérico es-CL.
- 5 KPIs en lugar de 4 (agregado "Score promedio red").
- Gradientes sutiles en barras (en vez de colores planos).
- Card de riesgo proactivo (no presente en original).
- Topbar con búsqueda global con `⌘K` (estándar moderno).

### 2.2 `mobile_screens.svg` — Tres pantallas móviles para auditor (1320 × 900 px)

**Audiencia**: Auditor en terreno.
**Tres pantallas en formato iPhone 14 Pro (393 × 852 lógicos, escaladas).**

#### Pantalla A — Dashboard del auditor

- **Header degradado** (`--primary-900` → `--primary-800`) con avatar, nombre y rol "Auditor regional".
- **Buscador** prominente con placeholder "Buscar sucursal o auditoría".
- **Grid 2×2 de KPIs personales**: Mis auditorías hoy / Esta semana / Score promedio / Pendientes urgentes.
- **Mini donut chart**: estado de mis auditorías personales.
- **Lista de "Próximas auditorías"**: cards con sucursal, dirección, fecha+hora, badge de prioridad.
- **Bottom navigation** (5 ítems): Inicio · Buscar · **➕ FAB centrado** (nueva auditoría) · Historial · Perfil. El FAB tiene elevación `--elev-2` y color `--accent-500`.

#### Pantalla B — Formulario de captura de auditoría

- **Progress bar** superior: 4 pasos (Sucursal → Categorías → Evidencia → Confirmar). Paso actual destacado.
- **Card de sucursal seleccionada**: foto + nombre + dirección + score histórico.
- **Score grande central**: 94 / 100 con slider táctil (control directo del puntaje).
- **4 cards de categoría** (Limpieza, Atención, Inventario, Seguridad) con score parcial cada una y badge de color según rango.
- **Chips de evidencia**: "📷 Adjuntar foto" · "🎤 Nota de voz" · "📝 Comentario".
- **Footer fijo** con dos botones: "Guardar borrador" (secondary) y "Continuar" (primary).

#### Pantalla C — Detalle de sucursal

- **Hero header** con foto/imagen genérica + nombre de sucursal + región.
- **Score actual grande**: 91,5 con sparkline de tendencia 12 meses, delta ↑ 3,2%.
- **Tabs**: Resumen | Auditorías | Equipo | Acciones.
- **Stats grid**: Total auditorías, Última auditoría, Auditor asignado, Próxima programada.
- **Chart hexagonal (radar)** de 6 categorías: Limpieza, Atención, Inventario, Seguridad, Procesos, Imagen. Permite ver el "perfil" de la sucursal de un vistazo.
- **Dual CTA inferior**: "Programar auditoría" (secondary) + "Iniciar ahora" (primary).

### 2.3 `design_system.svg` — Tokens visuales (1200 × 900 px)

Vista panorámica del sistema de diseño:
- Escala completa de paleta primaria (50 → 950), con `--primary-800` y `--primary-900` marcados con ★ como tokens primarios.
- Escala de accent cyan.
- Semantic colors (Success / Warning / Error / Neutral).
- Escala neutral slate.
- Muestra tipográfica (Inter en 5 estilos + JetBrains Mono).
- Escala de espaciado 4-pt visualizada como rectángulos.
- Escala de border radius (4 → 8 → 12 → 14★ → full).

---

## 3. Estrategia de adaptación Web → Mobile

| Aspecto | Web | Mobile | Justificación |
|---|---|---|---|
| **Navegación** | Sidebar lateral fija (240 px) | Bottom navigation (5 ítems) + drawer secundario | El sidebar consume ancho valioso en mobile; bottom nav respeta los pulgares (Fitts's Law). |
| **Densidad** | Alta: tablas con 8–15 filas visibles | Baja: cards apiladas, 2–4 ítems visibles | El contexto de uso difiere: oficina vs. terreno. |
| **Tablas** | Tabla clásica con todas las columnas | "Card-list": cada fila es un card con label-value verticales | Las tablas no escalan bien en < 600 px. Linear, GitHub mobile, Stripe lo resuelven igual. |
| **Multi-columna** | Grids 4×N | Stack vertical 1 col | Lectura natural en mobile = vertical. |
| **Charts complejos** | Bar groups, scatter plots, multi-series | Sparklines, donut simple, stat highlights | Charts intrincados son ilegibles en 393 px. |
| **Filtros** | Toolbar inline persistente | Bottom sheet modal accionable | El espacio vertical es premium en mobile. |
| **Búsqueda** | Búsqueda global con `⌘K` | Search bar dedicada en pantalla home + filtro contextual | Hábito mobile distinto del desktop. |
| **CTAs primarias** | Botón en topbar / header de card | FAB flotante centrado + sticky bottom buttons | El pulgar del usuario está abajo. |
| **Formularios** | Multi-columna, todo visible | Single column, paso a paso (wizard) | Reducir scope cognitivo + permitir progress feedback. |

---

## 4. Breakpoints y comportamientos por pantalla

| Pantalla | `< 768 px` (mobile) | `768–1023 px` (tablet) | `≥ 1024 px` (desktop) |
|---|---|---|---|
| **Dashboard** | Stack vertical: KPIs en 2×2, charts apilados, tabla → cards | Sidebar colapsado a iconos, KPIs en 4×1, charts en 1×2 | Sidebar expandido, layout completo descrito en §2.1 |
| **Listado sucursales** | Cards verticales con score + dirección + acción | Grid 2 columnas | Tabla densa con filtros |
| **Detalle auditoría** | Stack: header → score → categorías → evidencia | 2 columnas: detalle ↔ línea de tiempo | 3 columnas: detalle ↔ historial ↔ acciones |
| **Formulario nueva auditoría** | Wizard 4 pasos a pantalla completa | Wizard con sidebar de progreso | Vista única con todas las secciones colapsables |

> **Regla de oro**: el contenido se reorganiza, **nunca se oculta**. Si un dato es importante en desktop, debe ser accesible en mobile (aunque sea en una pestaña adicional).

---

## 5. Mapeo de componentes Web ↔ Mobile

| Web | Mobile equivalente | Notas |
|---|---|---|
| Sidebar | Bottom navigation + drawer | Drawer para ítems secundarios (Reportes, Config) |
| Topbar con `⌘K` | Search bar en home + icono lupa en otras pantallas | |
| Tabla `<table>` | List of `Card` widgets | Mantener orden de columnas como labels |
| Modal centrado | Bottom sheet (`showModalBottomSheet`) | Más natural en mobile |
| Tooltip on hover | Long-press → snackbar contextual | No hay hover real en touch |
| Dropdown | Bottom sheet con opciones | Más fácil de tocar |
| Filter dropdown | Bottom sheet "Filtros" con apply/reset | |
| Button primary derecha | Sticky button al fondo o FAB | |
| Hover row | Active/pressed state visual | |
| Doble click | Single tap + long press para acciones secundarias | |

---

## 6. Flujos de usuario clave

### 6.1 Flujo Admin: Análisis semanal de cumplimiento (web)

```
Login → Dashboard → ver KPIs → click "Compliance por región" Q3
  → drill-down a sucursales con menor score
  → seleccionar sucursal "Punta Arenas"
  → ver historial de auditorías
  → exportar reporte PDF para directorio
```

### 6.2 Flujo Auditor: Realizar auditoría en terreno (mobile)

```
Login → Dashboard → tap FAB (+)
  → Paso 1: seleccionar sucursal (lista filtrada por proximidad GPS)
  → Paso 2: completar checklist de categorías (sliders + comentarios)
  → Paso 3: adjuntar evidencia (fotos cámara, audio, notas)
  → Paso 4: confirmar y firmar (firma táctil)
  → Sync automático cuando hay red
  → Notificación de éxito al supervisor
```

### 6.3 Flujo Supervisor: Revisar auditorías pendientes de validación (web/tablet)

```
Login → Auditorías → filtro estado="con_observaciones"
  → seleccionar auditoría → revisar evidencia
  → comentar / aprobar / rechazar / solicitar repetir
  → sistema notifica al auditor + a la sucursal
```

---

## 7. Estrategia offline-first (mobile)

El auditor de terreno **frecuentemente trabaja sin conectividad confiable** (sucursales en zonas rurales, sótanos de centros comerciales, redes saturadas). La app mobile debe ser offline-first.

### Componentes de la estrategia

1. **Almacenamiento local**: SQLite (vía `drift` en Flutter) con réplica del esquema de auditorías + sucursales del auditor.
2. **Captura siempre disponible**: el formulario de auditoría funciona 100% offline; los datos se persisten localmente con un campo `sync_status` (`pending` | `syncing` | `synced` | `failed`).
3. **Cola de sync**: al detectar conectividad (`connectivity_plus`), se procesa la cola en background con retry exponencial.
4. **Conflict resolution**: server wins por defecto, excepto en evidencia (fotos/audio) donde el cliente siempre tiene prioridad si fue capturada offline.
5. **Indicador visual**: badge persistente en el topbar mobile con el conteo de items pendientes de sync. Tap → detalle.
6. **Resiliencia de evidencia**: las fotos se comprimen en cliente (max 1920 px lado largo, JPEG calidad 80%) y se suben en chunks. Si falla, se reintenta hasta 5 veces con backoff.
7. **Pre-fetch inteligente**: al iniciar sesión, descargar las 50 sucursales más cercanas (por GPS) + auditorías programadas próximas 7 días.

### Diagrama simplificado

```
┌──────────────┐   captura   ┌──────────────┐
│  UI Flutter  │────────────▶│ Repo local   │
│  (formulario)│             │ (drift/SQLite)│
└──────────────┘             └──────┬───────┘
                                    │ sync_status=pending
                                    ▼
                             ┌──────────────┐
                             │  SyncWorker  │
                             │ (workmanager)│
                             └──────┬───────┘
                          ┌─────────┴─────────┐
                          │ ¿hay conectividad?│
                          └─────────┬─────────┘
                                  sí │
                                    ▼
                             ┌──────────────┐
                             │  API FastAPI │ ← retry exponencial 1s, 2s, 4s, 8s, 16s
                             └──────┬───────┘
                                  ok│
                                    ▼
                             sync_status=synced + notificación push al admin
```

---

## 8. Patrones de navegación

### Web

- **Estructura**: sidebar fija (módulos) + breadcrumbs (`Auditorías / Q3 2023 / Punta Arenas / #1043`).
- **URLs significativas**: `/auditorias/1043`, `/sucursales/punta-arenas`, `/reportes/compliance?region=sur&q=3`.
- **Back/forward del navegador**: 100% funcional (rutas persistidas en historial).
- **Atajos de teclado**: `g+d` dashboard, `g+a` auditorías, `/` foco buscador, `Esc` cerrar modal, `⌘K` command palette.

### Mobile

- **Estructura**: bottom nav (5 destinos primarios) + push navigation hacia detalle.
- **Back gesture**: swipe desde borde izquierdo (iOS), botón hardware (Android).
- **Deep linking**: `auditchain://auditoria/1043` para notificaciones push y SMS.
- **Tabs internas**: en pantallas de detalle, no más de 4 tabs.

---

## 9. Performance targets

| Métrica | Web | Mobile |
|---|---|---|
| First Contentful Paint | < 1.5 s en 4G | < 1.0 s (app nativa) |
| Time to Interactive | < 3.0 s en 4G | < 2.0 s |
| Largest Contentful Paint | < 2.5 s | < 2.0 s |
| Bundle inicial JS | < 300 KB gzip | N/A |
| Tamaño app instalada | N/A | < 40 MB |
| Carga de dashboard | < 1.0 s con cache cálido | < 800 ms |
| Captura de auditoría offline | < 200 ms al guardar localmente | crítico |

---

## 10. Diferencias clave con el mockup base

El mockup `dashboard_mockup.png` provisto sirvió como punto de partida. Las propuestas adoptan e iteran:

| Mockup base | Propuesta AuditChain |
|---|---|
| Texto en inglés ("Welcome back, Admin") | Español es-CL ("Bienvenida, Jane") |
| 4 KPI cards en columna izquierda | 5 KPI cards en grid horizontal con deltas |
| Logo "AuditChain" en sidebar | Logo + nombre + subtle tagline opcional |
| 4 ítems de navegación | 6 ítems (agregamos Reportes y Configuración) |
| Tabla básica de auditorías | Tabla con filtros, ordenable, exportable |
| Sin búsqueda global | `⌘K` command palette |
| Sin avatar/usuario en sidebar | User chip al final del sidebar con estado |
| Charts estáticos | Charts interactivos (hover → tooltip, click → drill-down) |
| Solo desktop | Sistema completo: web + mobile + tablet |

---

## 11. Roadmap de implementación visual

| Sprint | Entregable |
|---|---|
| 1 | Tokens en código (CSS vars + Flutter ThemeData), tipografías cargadas |
| 2 | Componentes atómicos: Button, Input, Badge, Card |
| 3 | Componentes moleculares: Table (web), Card-list (mobile), Form fields, Filters |
| 4 | Componentes orgánicos: Sidebar, Topbar, Bottom nav, FAB |
| 5 | Pantallas: Login, Dashboard (web), Dashboard (mobile) |
| 6 | Pantallas: Listados, Detalles, Formulario de auditoría |
| 7 | Charts: Bar, Donut, Sparkline, Radar |
| 8 | Storybook (web) + Widgetbook (Flutter) publicados |
| 9 | Audit accesibilidad WCAG AA (axe + tester humano) |
| 10 | Performance audit (Lighthouse + Flutter DevTools) |

---

## 12. Archivos relacionados

| Archivo | Descripción |
|---|---|
| `mockups/web_dashboard.svg` | Dashboard administrativo desktop, 1440×900 |
| `mockups/mobile_screens.svg` | Tres pantallas mobile: dashboard, captura, detalle |
| `mockups/design_system.svg` | Tokens visuales: paleta, tipografía, spacing, radius |
| `DESIGN_PROPOSAL.md` | Sistema de diseño completo (este documento es su complemento operativo) |
| `AGENT_FLUTTER.md` | Cómo implementar la UI mobile/web en Flutter |
| `AGENT_FASTAPI.md` | API que sirve los datos del dashboard |
| `AGENT_POSTGRES.md` | Esquema de datos detrás de los KPIs |
| `AGENT_REVIEW.md` | Checklist de revisión de diseño + código |
