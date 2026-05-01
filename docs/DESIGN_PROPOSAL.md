# 🎨 AuditChain — Propuesta de Diseño

> Documento maestro del sistema de diseño de **AuditChain**. Define la filosofía visual, la paleta de color, la tipografía, el espaciado, los componentes y los principios de comportamiento que rigen todas las interfaces (web, mobile y dashboards). Este documento es la fuente única de verdad: cualquier divergencia visual debe justificarse o corregirse contra él.

---

## 1. Filosofía y Principios de Diseño

AuditChain opera en un dominio **regulatorio, financiero y operativo** —auditorías de franquicias, cumplimiento, scoring y trazabilidad—. La interfaz debe transmitir **confianza, autoridad y claridad**, sin caer en lo aburrido. Los principios rectores son:

| Principio | Definición operativa |
|---|---|
| **Confianza por defecto** | Colores sobrios (azul marino dominante), tipografía legible, jerarquía clara. Cero "wow" gratuito. |
| **Datos primero, decoración después** | Cada pixel sirve a una decisión de negocio. Gráficos limpios, números grandes, badges con significado. |
| **Densidad informada** | El admin ve mucho dato; mantener densidad alta sin saturar. El auditor en mobile ve poco, pero accionable. |
| **Consistencia transversal** | Un componente (ej. badge de estado) se ve y se comporta igual en web, mobile y reportes. |
| **Accesibilidad WCAG AA mínima** | Contraste ≥ 4.5:1 en texto normal, ≥ 3:1 en texto grande y elementos UI. Sin excepciones. |
| **Mobile-first para auditores, desktop-first para admins** | Los flujos divergen porque las personas y los contextos divergen. |
| **Microinteracciones discretas** | 200–300 ms, ease-out. Nunca rebotes ni delays > 400 ms. |

> ✦ **Anti-principio.** Evitar gradientes saturados estilo SaaS-genérico, glassmorphism excesivo, neon, modos oscuros forzados con bajo contraste, e iconografía ambigua tipo "mil emojis".

---

## 2. Paleta de Color

### 2.1 Justificación del color base

El **azul marino profundo** (`#0A2540` / `#1E3A8A`) es el color dominante porque:

1. **Asociación cultural**: en finanzas, banca, auditoría y compliance, el azul oscuro es sinónimo de seriedad y solvencia (BBVA, JPMorgan, IBM, Stripe usan derivados).
2. **Contraste excelente con blanco**: 14:1 en `#0A2540` sobre `#FFFFFF`, muy por encima de WCAG AAA.
3. **No fatiga visual**: a diferencia del negro puro, el azul marino reduce la dureza en pantallas de 8h+ de uso (perfil del admin).
4. **Compatible con dark mode**: invertir a un azul más claro como superficie funciona naturalmente.

El **cyan** (`#06B6D4`) actúa como acento porque:

1. **Energía sin agresividad**: aporta vivacidad a un dominio que de otra forma sería gris.
2. **Asociación con datos en tiempo real, refresco, insight** (analytics, dashboards, BI).
3. **Análogo armónico** del azul primario en la rueda cromática.

### 2.2 Paleta primaria — Navy

| Token | HEX | Uso |
|---|---|---|
| `--primary-50` | `#F0F4F8` | Fondos sutiles, hover en filas de tabla |
| `--primary-100` | `#D9E2EC` | Bordes suaves, divisores |
| `--primary-200` | `#BCCCDC` | Estados disabled |
| `--primary-300` | `#9FB3C8` | Iconos secundarios |
| `--primary-400` | `#627D98` | Texto secundario sobre fondo claro |
| `--primary-500` | `#486581` | Texto cuerpo en headers ligeros |
| `--primary-600` | `#334E68` | Hover sobre superficies primarias |
| `--primary-700` | `#243B53` | Sidebar (fondo) |
| `--primary-800` | **`#1E3A8A`** ★ | **Primary action / CTA / botones principales** |
| `--primary-900` | **`#0A2540`** ★ | **Sidebar profundo, textos display, branding** |
| `--primary-950` | `#051C36` | Modo oscuro: fondo más profundo |

### 2.3 Paleta de acento — Cyan

| Token | HEX | Uso |
|---|---|---|
| `--accent-50` | `#ECFEFF` | Fondos de cards de KPI con tinte |
| `--accent-100` | `#CFFAFE` | Highlights muy ligeros |
| `--accent-300` | `#67E8F9` | Decoración, gradientes de chart |
| `--accent-500` | **`#06B6D4`** ★ | **Acento principal, líneas activas, focus rings** |
| `--accent-700` | `#0E7490` | Acento sobre fondo claro (mejor contraste para texto) |

### 2.4 Paleta semántica — Estados de auditoría

Mapeo directo a los estados del dominio (`pendiente`, `completada`, `con_observaciones`, `vencida`):

| Estado | Token | HEX | Fondo (badge) | Texto (badge) | Justificación |
|---|---|---|---|---|---|
| **Completada** | `--success-500` | `#10B981` | `#D1FAE5` | `#065F46` | Verde universal de "ok" |
| **Pendiente** | `--warning-500` | `#F59E0B` | `#FEF3C7` | `#92400E` | Ámbar = "en curso, atención moderada" |
| **Con observaciones** | `--info-500` | `#0EA5E9` | `#E0F2FE` | `#075985` | Sky blue = "informativo, requiere revisión" |
| **Vencida** | `--neutral-500` | `#94A3B8` | `#F1F5F9` | `#475569` | Gris = "fuera de tiempo, archivado" — *no rojo*, porque rojo se reserva para errores destructivos |
| **Error / destructivo** | `--error-500` | `#EF4444` | `#FEE2E2` | `#991B1B` | Solo para acciones destructivas y errores de validación |

> ⚠ **Decisión deliberada**: "vencida" usa gris en vez de rojo. El rojo intenso para un estado frecuente provoca **fatiga de alarma**: los usuarios dejan de reaccionar. El rojo se reserva para errores reales.

### 2.5 Paleta neutral — Slate

| Token | HEX | Uso |
|---|---|---|
| `--neutral-50` | `#F8FAFC` | Fondo de página |
| `--neutral-100` | `#F1F5F9` | Fondo de cards alternativos, headers de tabla |
| `--neutral-200` | `#E2E8F0` | Bordes de input, divisores |
| `--neutral-300` | `#CBD5E1` | Bordes de cards |
| `--neutral-400` | `#94A3B8` | Placeholders, iconos disabled |
| `--neutral-500` | `#64748B` | Texto secundario |
| `--neutral-700` | `#334155` | Texto cuerpo |
| `--neutral-900` | `#0F172A` | Texto display sobre fondo claro |

### 2.6 Validación de contraste (WCAG)

| Combinación | Ratio | Nivel |
|---|---|---|
| `#0A2540` sobre `#FFFFFF` | 14.7:1 | AAA |
| `#1E3A8A` sobre `#FFFFFF` | 9.4:1 | AAA |
| `#06B6D4` sobre `#FFFFFF` | 2.7:1 | ❌ Solo decorativo, **nunca texto** |
| `#0E7490` sobre `#FFFFFF` | 5.4:1 | AA |
| `#FFFFFF` sobre `#1E3A8A` | 9.4:1 | AAA |
| `#FFFFFF` sobre `#06B6D4` | 2.7:1 | ❌ Solo iconos grandes / decoración |
| `#475569` sobre `#F1F5F9` | 7.8:1 | AAA |
| `#10B981` sobre `#FFFFFF` | 2.5:1 | ❌ Decorativo; usar `#065F46` para texto |

> Regla: si una combinación marca ❌ para texto, **usar el token "darker" equivalente** (ej. `--accent-700` para texto cyan).

### 2.7 Modo oscuro (estrategia)

No es un MVP, pero el sistema lo soporta nativamente:

- Superficies: `--neutral-900` → `--primary-950`.
- Texto cuerpo: `--neutral-100`.
- Acento: `--accent-300` (más claro para mantener contraste).
- Estado completada: `#34D399` (verde más claro). Misma jerarquía, intensidades ajustadas.
- **No invertir literalmente**: rediseñar tonos, no aplicar `filter: invert()`.

---

## 3. Tipografía

### 3.1 Familias

| Familia | Uso | Justificación |
|---|---|---|
| **Inter** (variable, 100–900) | UI completa, dashboards, formularios | Diseñada para pantallas, x-height generosa, legibilidad excelente a 12 px en tablas densas, soporta 9 pesos como variable font (1 archivo). |
| **JetBrains Mono** | IDs (`#1045`), datos numéricos en tablas, código | Tipografía monoespaciada con caracteres bien diferenciados (`0` vs `O`, `1` vs `l`). Las columnas numéricas se alinean perfectamente. |

> ⚠ **No mezclar** con Roboto, Open Sans, Helvetica u otras. Una familia para UI, otra para datos. Punto.

### 3.2 Escala tipográfica

Escala modular basada en **ratio 1.125 (mayor segunda)**, anclada en 14 px (cuerpo).

| Token | Tamaño | Line-height | Peso | Uso |
|---|---|---|---|---|
| `--font-display-xl` | 32 / 40 px | 40 px | 700 | Hero / "Bienvenida, Jane" |
| `--font-display-lg` | 28 / 36 px | 36 px | 700 | Títulos de página |
| `--font-display-md` | 24 px | 32 px | 600 | KPIs (números grandes) |
| `--font-title-lg` | 22 px | 28 px | 600 | Títulos de card |
| `--font-title-md` | 18 px | 26 px | 600 | Subtítulos de sección |
| `--font-title-sm` | 16 px | 24 px | 600 | Encabezados de tabla |
| `--font-body-lg` | 16 px | 24 px | 400 | Texto principal |
| `--font-body-md` | 14 px | 20 px | 400 | **Cuerpo por defecto** |
| `--font-body-sm` | 13 px | 18 px | 400 | Texto secundario |
| `--font-caption` | 12 px | 16 px | 500 | Etiquetas, badges, captions |
| `--font-mono-md` | 13 px | 18 px | 500 | IDs, códigos, números en tabla |

### 3.3 Reglas tipográficas

1. **Máximo 3 tamaños por pantalla**: previene jerarquías inflacionadas.
2. **Letter-spacing**: `-0.01em` en display, `0` en cuerpo, `+0.02em` en caption uppercase.
3. **Truncado**: usar `text-overflow: ellipsis` con `title` accesible. Nunca cortar palabras a la mitad.
4. **Numerales tabulares**: en tablas y KPIs, activar `font-feature-settings: "tnum"`. Las columnas de cifras quedan alineadas.
5. **Texto en español**: contemplar diacríticos (á, é, í, ó, ú, ñ). Inter los maneja bien; verificar en pesos 700+.

---

## 4. Sistema de Espaciado

Base **4 px** (escala 4-pt), porque encaja en grids de 8/12/16/24 sin fracciones.

| Token | Valor | Uso típico |
|---|---|---|
| `--space-0` | 0 px | — |
| `--space-1` | 4 px | Padding interno de chips, gap entre icono y texto |
| `--space-2` | 8 px | Padding de inputs, gap entre badge y texto |
| `--space-3` | 12 px | Padding interno de cards densos |
| `--space-4` | 16 px | **Padding por defecto de card** |
| `--space-5` | 20 px | Gap entre cards en grids |
| `--space-6` | 24 px | Padding lateral de página, gap entre secciones |
| `--space-8` | 32 px | Margen entre bloques mayores |
| `--space-10` | 40 px | Headers de página |
| `--space-12` | 48 px | Espacio entre módulos completos |
| `--space-16` | 64 px | Hero sections (raro en este producto) |

**Regla del 8**: cualquier composición debe sumar múltiplos de 8 entre componentes mayores. Los 4 px se reservan para microajustes internos.

---

## 5. Border Radius

| Token | Valor | Uso |
|---|---|---|
| `--radius-xs` | 4 px | Chips, badges pequeños |
| `--radius-sm` | 8 px | Botones, inputs |
| `--radius-md` | 12 px | Cards secundarios |
| `--radius-lg` | **14 px** ★ | **Cards principales (default)** |
| `--radius-xl` | 20 px | Modales, sheets |
| `--radius-full` | 9999 px | Avatares, pills, badges de estado |

> 14 px (en vez del clásico 12 ó 16) es una **decisión de marca**. Lo suficientemente redondeado para sentirse moderno, lo suficientemente sutil para no infantilizar un producto de auditoría.

---

## 6. Elevación y Sombras

Solo **3 niveles**. Más sombras = caos visual.

| Token | Sombra | Uso |
|---|---|---|
| `--elev-0` | none | Cards sobre fondo neutral, items en lista |
| `--elev-1` | `0 1px 2px rgba(15, 23, 42, 0.04), 0 1px 3px rgba(15, 23, 42, 0.06)` | Cards de KPI, charts |
| `--elev-2` | `0 4px 6px rgba(15, 23, 42, 0.05), 0 10px 15px rgba(15, 23, 42, 0.08)` | Dropdowns, popovers, FAB |
| `--elev-3` | `0 20px 25px rgba(15, 23, 42, 0.10), 0 8px 10px rgba(15, 23, 42, 0.04)` | Modales, sheets |

**Color de sombra**: derivado del slate (`#0F172A`) con baja opacidad. Nunca usar sombras puras `#000` (resultan duras).

---

## 7. Iconografía

- **Set**: [Lucide Icons](https://lucide.dev) (open source, MIT, ~1500 iconos, estilo coherente).
- **Tamaños**: 16, 20, 24 px. Stroke 1.5–2 px.
- **Color**: heredan `currentColor`. Sobre sidebar oscuro → `--primary-100`; sobre fondo claro → `--neutral-700`.
- **Reglas**:
  - Icono + texto: el icono va a la izquierda, gap `--space-2`.
  - Icono solo (botón): siempre con `aria-label` y `tooltip`.
  - Evitar > 2 iconos por componente. Si hace falta más, repensar el diseño.

| Función | Icono Lucide |
|---|---|
| Dashboard | `layout-dashboard` |
| Sucursales | `building-2` |
| Auditores | `users` |
| Auditorías | `clipboard-check` |
| Reportes | `bar-chart-3` |
| Configuración | `settings` |
| Notificaciones | `bell` |
| Búsqueda | `search` |
| Filtro | `sliders-horizontal` |
| Exportar | `download` |
| Más opciones | `more-horizontal` |

---

## 8. Componentes Clave (especificaciones)

### 8.1 Card

```
Padding:    --space-4 (16 px) en mobile, --space-6 (24 px) en desktop
Radius:     --radius-lg (14 px)
Background: #FFFFFF (light) / --primary-900 (dark)
Border:     1 px solid --neutral-200 (opcional, alternativa a sombra)
Elevation:  --elev-1
Gap interno: --space-3 entre header y contenido
```

**Variantes:**
- **KPI card**: número grande (`--font-display-md`), label arriba (`--font-caption` uppercase, `--neutral-500`), delta debajo (verde con flecha ↑ o ámbar con ↓).
- **Chart card**: header con título + acciones (filtro, expandir), chart con altura mínima 240 px.
- **Table card**: sin padding lateral en la tabla (la tabla extiende edge-to-edge), padding solo en header y footer.

### 8.2 Botón

| Variante | Background | Text | Border | Hover | Uso |
|---|---|---|---|---|---|
| **Primary** | `--primary-800` | `#FFF` | none | `--primary-900` | CTA principal (1 por pantalla idealmente) |
| **Secondary** | `#FFF` | `--primary-800` | 1px `--primary-300` | `--primary-50` bg | Acciones secundarias |
| **Tertiary** | transparent | `--primary-700` | none | `--primary-50` bg | Acciones terciarias, texto-link |
| **Destructive** | `--error-500` | `#FFF` | none | `--error-700` | Eliminar, destruir |
| **Ghost** | transparent | `--neutral-700` | none | `--neutral-100` bg | Iconos en toolbar |

**Tamaños**:
- `sm`: altura 32 px, padding `--space-3 --space-4`, fuente 13 px.
- `md` (default): altura 40 px, padding `--space-3 --space-5`, fuente 14 px.
- `lg`: altura 48 px, padding `--space-4 --space-6`, fuente 16 px.

**Estados**: hover, focus (ring de 2 px `--accent-500` con offset 2 px), active (translate-y 1 px), disabled (opacity 0.5, cursor not-allowed), loading (spinner reemplaza icono).

### 8.3 Input

```
Altura:     40 px (md)
Padding:    --space-3 --space-4
Radius:     --radius-sm (8 px)
Border:     1 px solid --neutral-300
Focus:      border --primary-800 + ring 3 px rgba(30, 58, 138, 0.15)
Error:      border --error-500 + ring 3 px rgba(239, 68, 68, 0.15)
```

Acompañado siempre de `<label>` arriba (no placeholder-as-label) y `<helper-text>` abajo (que se transforma en `error-text` con icono `alert-circle`).

### 8.4 Badge / Chip de estado

```
Padding:    2px 10px
Radius:     --radius-full
Fuente:     --font-caption, peso 500
Altura:     22 px
```

Combinaciones (ver §2.4).

### 8.5 Tabla

```
Header:     --neutral-100 background, uppercase, font-caption, --neutral-500 color
Filas:      altura 56 px (cómoda, no apretada)
Hover:      --primary-50 background
Borders:    sólo bottom, 1 px --neutral-200
Padding X:  --space-4
Padding Y:  --space-3
```

**Reglas:**
- Columnas numéricas alineadas a la derecha + tabular-nums.
- Columnas de fecha siempre formato corto (`26 oct 2023`), nunca `2023-10-26 14:35:42`.
- Acciones (3-dots, ver, editar) en columna fija a la derecha con `--space-2` de padding.
- Paginación inferior: `Página X / Y` + flechas `« ‹ › »`.
- Empty state: ilustración + texto + CTA.

### 8.6 Charts

- **Bar chart**: barras con `--radius-xs` arriba, gap entre grupos = ancho de barra × 0.5, gap entre barras del mismo grupo = ancho × 0.15. Colores: `--primary-900`, `--primary-500`, `--accent-500`, `--accent-300` (de oscuro a claro = de Q1 a Q4, o viceversa).
- **Donut chart**: stroke-width = 30% del radio. Colores `--primary-800` (completada), `--accent-500` (pendiente), `--neutral-400` (vencida). Centro con número grande y label.
- **Sparkline**: stroke `--accent-500`, 2 px, fill con gradient hacia abajo (opacity 0.3 → 0). Sin ejes.
- **Tooltips**: fondo `--primary-900`, texto blanco, radius `--radius-sm`, padding `--space-3`, sombra `--elev-2`.

---

## 9. Layout y Grid

### 9.1 Breakpoints

| Token | Min-width | Layout |
|---|---|---|
| `xs` | 0 | Mobile compact (1 col) |
| `sm` | 640 px | Mobile largo / phablet |
| `md` | 768 px | Tablet portrait |
| `lg` | 1024 px | Tablet landscape / laptop chico |
| `xl` | 1280 px | Desktop estándar |
| `2xl` | 1536 px | Desktop grande |

### 9.2 Grid de página (desktop)

- **Sidebar**: ancho fijo 240 px, `--primary-900` background, colapsable a 72 px (solo iconos) en `lg` y abajo.
- **Topbar**: alto 64 px, fondo blanco, borde inferior 1 px `--neutral-200`.
- **Content**: padding `--space-8` lateral en `xl+`, `--space-6` en `lg`, `--space-4` en `md`.
- **Max-width**: 1440 px centrado en pantallas `> 2xl`.

### 9.3 Grid de KPIs

Grid de 4 columnas en `xl`, 2 columnas en `md`, 1 columna en `xs`. Gap `--space-5` (20 px).

### 9.4 Grid de mobile

- 1 columna por defecto, `--space-4` de padding lateral.
- KPI cards en grid 2x2 (4 cards) o 1x3 (3 cards verticales si son críticos).
- Bottom navigation: 5 ítems máximo, alto 64 px + safe-area-inset-bottom.

---

## 10. Motion / Animación

| Categoría | Duración | Easing | Uso |
|---|---|---|---|
| **Micro** | 150 ms | `ease-out` (cubic-bezier(0, 0, 0.2, 1)) | Hover, focus, change of state |
| **Standard** | 250 ms | `ease-in-out` | Apertura de menú, fade in |
| **Emphasis** | 350 ms | `cubic-bezier(0.4, 0, 0.2, 1)` | Modales, sheets |
| **Page transition** | 200 ms | `ease-out` | Cambio de ruta (fade + 4 px slide-up) |

**Reglas:**
1. Nunca > 400 ms en interacciones síncronas. Frustra al usuario.
2. `prefers-reduced-motion`: respetar siempre. Reducir a 0 ms o 50 ms.
3. **Sin** animaciones decorativas en datos críticos (números de KPI). Animar el cambio de estado, no el fondo.
4. Skeleton loaders para esperas > 200 ms; spinners solo > 1 s.

---

## 11. Accesibilidad

Compromiso: **WCAG 2.2 AA en MVP, AAA donde sea factible.**

### Checklist no negociable

- [ ] Todo elemento interactivo tiene `:focus-visible` con ring de 2 px `--accent-500`.
- [ ] Todo input tiene `<label>` asociado (for/id).
- [ ] Todo icono-botón tiene `aria-label`.
- [ ] Contraste ≥ 4.5:1 en texto, ≥ 3:1 en componentes UI.
- [ ] Navegación 100% por teclado (Tab, Shift-Tab, Enter, Esc, flechas en menús).
- [ ] Estados (loading, error, success) anunciados vía `role="status"` o `aria-live`.
- [ ] Tablas con `<th scope>` y captions.
- [ ] No depender solo del color para transmitir información (los badges combinan color + icono + texto).
- [ ] Targets táctiles ≥ 44×44 px en mobile (Apple HIG / WCAG 2.5.5).
- [ ] Idioma del documento declarado (`<html lang="es-CL">`).
- [ ] Imágenes con `alt` significativo (o `alt=""` si decorativo).

---

## 12. Internacionalización

- **Idioma primario**: español (es-CL).
- **Idiomas planeados**: inglés (en-US) en fase 2.
- **Formato de fecha**: `26 oct 2023` (corto), `26 de octubre de 2023` (largo). Nunca `MM/DD/YYYY` ambiguo.
- **Formato de número**: separador de miles `.`, decimal `,` (1.452,30). Activar `Intl.NumberFormat('es-CL')`.
- **Moneda** (futuro): `$1.452.300` (CLP) o configurable por sucursal.
- **Texto**: español neutro, evitar regionalismos. Tono cordial pero profesional ("Bienvenida, Jane" mejor que "¡Hola, Jane! 🎉").

---

## 13. Componentes específicos del dominio

### 13.1 Score visual de auditoría

Componente clave. Aparece en cards de sucursal, detalle de auditoría, listas.

```
[ Score grande: 91.5 / 100 ]
[ Barra horizontal: gradient verde→ámbar→rojo según rango ]
[ Delta: ↑ 3.2% vs último mes (verde) o ↓ 1.5% (ámbar) ]
```

Rangos:
- 90–100: verde (`--success-500`), label "Excelente".
- 75–89: cyan (`--accent-500`), label "Bueno".
- 60–74: ámbar (`--warning-500`), label "Mejorable".
- < 60: gris (`--neutral-500`), label "Crítico". *(No rojo: ver §2.4 nota.)*

### 13.2 Avatar de auditor

- Tamaño default 32 px (lista), 48 px (detalle), 64 px (perfil).
- Foto si existe; fallback a iniciales sobre fondo `--primary-200` con texto `--primary-800`.
- Indicador de estado (online/offline) opcional como dot 8 px en esquina inferior derecha.

### 13.3 Timeline de auditorías

Lista vertical con línea conectora 2 px `--neutral-200`, puntos de 12 px coloreados según estado, fecha a la izquierda en `--font-mono-md`, contenido a la derecha en card.

### 13.4 Mapa de regiones (futuro)

Choropleth de Chile con regiones coloreadas por compliance score. Interactivo: hover muestra tooltip con nombre + score + nº sucursales.

---

## 14. Tokens en código

### 14.1 CSS / Tailwind

```css
:root {
  /* Primary */
  --primary-50:  #F0F4F8;
  --primary-800: #1E3A8A;
  --primary-900: #0A2540;
  /* Accent */
  --accent-500:  #06B6D4;
  --accent-700:  #0E7490;
  /* Semantic */
  --success-500: #10B981;
  --warning-500: #F59E0B;
  --error-500:   #EF4444;
  --info-500:    #0EA5E9;
  /* Neutral */
  --neutral-50:  #F8FAFC;
  --neutral-700: #334155;
  --neutral-900: #0F172A;
  /* Spacing */
  --space-1: 4px;  --space-2: 8px;  --space-3: 12px;
  --space-4: 16px; --space-6: 24px; --space-8: 32px;
  /* Radius */
  --radius-sm: 8px; --radius-lg: 14px; --radius-full: 9999px;
  /* Elevation */
  --elev-1: 0 1px 2px rgba(15,23,42,.04), 0 1px 3px rgba(15,23,42,.06);
  --elev-2: 0 4px 6px rgba(15,23,42,.05), 0 10px 15px rgba(15,23,42,.08);
  /* Type */
  --font-sans: 'Inter', system-ui, sans-serif;
  --font-mono: 'JetBrains Mono', ui-monospace, monospace;
}
```

### 14.2 Flutter (ThemeData + ThemeExtension)

```dart
class AppColors extends ThemeExtension<AppColors> {
  final Color primary900;       // 0xFF0A2540
  final Color primary800;       // 0xFF1E3A8A
  final Color accent500;        // 0xFF06B6D4
  final Color success500;       // 0xFF10B981
  final Color warning500;       // 0xFFF59E0B
  final Color error500;         // 0xFFEF4444
  final Color neutralBackground;// 0xFFF8FAFC

  // ... copyWith / lerp ...
}

final auditChainTheme = ThemeData(
  colorScheme: ColorScheme.light(
    primary: const Color(0xFF1E3A8A),
    secondary: const Color(0xFF06B6D4),
    error: const Color(0xFFEF4444),
    surface: Colors.white,
    background: const Color(0xFFF8FAFC),
  ),
  fontFamily: 'Inter',
  extensions: [/* AppColors(...) */],
);
```

---

## 15. Do / Don't visual

| ✅ Do | ❌ Don't |
|---|---|
| Usar `--primary-800` para CTA principal | Usar `--accent-500` puro como fondo de botón con texto blanco |
| 1 CTA primary por pantalla | 3 botones primary compitiendo |
| Iconos + texto en navegación | Solo iconos sin tooltip |
| Badge gris para "vencida" | Badge rojo intenso para "vencida" |
| Skeleton de 200–800 ms | Spinners de pantalla completa para datos rápidos |
| Espaciado múltiplo de 8 | "Pixel-pushing" libre |
| Inter en todo UI | Mezclar Inter + Roboto + Open Sans |
| Charts con 3–4 colores máximo | Charts arcoíris de 12 colores |
| Datos numéricos en JetBrains Mono | Datos numéricos en Inter en tablas alineadas |

---

## 16. Referencias e inspiración

- **Material 3 (Google)**: base para componentes Flutter, sistema de elevación.
- **Stripe Dashboard**: jerarquía de datos, espaciado, tono profesional.
- **Linear**: motion, microinteracciones, focus states.
- **Vercel Dashboard**: paleta neutra, uso de monoespaciada para identificadores.
- **Atlassian Design System**: documentación de tokens, accesibilidad.
- **Refactoring UI** (Adam Wathan / Steve Schoger): principios de jerarquía visual, color y tipografía.

---

## 17. Versionado y gobernanza

- Este documento vive en `docs/design/DESIGN_PROPOSAL.md`.
- **Owner**: equipo de diseño. PRs sobre cambios de tokens requieren approval de design-lead + frontend-lead.
- Cambios mayores (paleta, tipografía) → versión semver `MAJOR.MINOR.PATCH`. Versión actual: **`1.0.0`**.
- Tokens publicados en `packages/design-tokens/` (futuro), consumibles por web (CSS), Flutter (Dart) e iOS/Android nativo.
- Storybook (web) y Widgetbook (Flutter) como galería viva de componentes.
