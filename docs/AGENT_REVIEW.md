# 🔎 AGENT.md — Revisión de Diseño y Comportamiento (AuditChain)

> Este AGENT.md describe el comportamiento esperado de un **agente revisor** (humano o IA) que evalúa cualquier entrega, PR o propuesta de AuditChain contra los cinco entregables previos: AGENT_FLUTTER, AGENT_FASTAPI, AGENT_POSTGRES, MOCKUPS_INTEGRATION y DESIGN_PROPOSAL. Es el **quality gate** previo al merge a `main`.

---

## 1. Misión del revisor

> "Aprobar solo lo que un usuario real (admin, supervisor o auditor) puede usar mañana sin sorpresas, sin regresiones y sin deuda técnica oculta."

El revisor:
1. **Bloquea** PRs que violen reglas no negociables (seguridad, accesibilidad AA, performance crítica, integridad de datos).
2. **Solicita cambios** en violaciones de convenciones o anti-patterns documentados.
3. **Comenta sin bloquear** sugerencias de mejora opcionales (con tag `nit:` o `suggestion:`).
4. **Aprueba** cuando todo el checklist de su área pasa.

**Tres niveles de severidad:**

| Nivel | Significado | Acción |
|---|---|---|
| 🔴 **Blocker** | Viola regla no negociable | Bloquea merge. PR no avanza. |
| 🟠 **Major** | Anti-pattern documentado o convención violada | Solicita cambios. |
| 🟡 **Minor / nit** | Mejora opcional o estilo subjetivo | Comenta sin bloquear. |

---

## 2. Tipo de PR y revisión que aplica

| Tipo de PR | Áreas a revisar |
|---|---|
| `feature/*` | Frontend + Backend + DB + Diseño + UX + Tests + Docs |
| `fix/*` | Área del bug + tests de regresión |
| `chore/*` | Dependencias, CI, build → Performance + Seguridad |
| `refactor/*` | Mantener tests verdes, sin cambio de comportamiento |
| `docs/*` | Coherencia con AGENT.md y DESIGN_PROPOSAL.md |
| `db/migration/*` | DBA + Backend lead obligatorios |

---

## 3. Checklist de revisión Frontend (Flutter Web / Mobile)

> Referencia: `AGENT_FLUTTER.md`. Aplica a `auditchain/frontend/`.

### 3.1 Arquitectura y estructura
- [ ] El código nuevo respeta la estructura **feature-first** (`features/<dominio>/{data,domain,presentation}`).
- [ ] **No hay lógica de negocio en widgets** (todo en use cases o en notifiers Riverpod).
- [ ] Los modelos de la capa `data` no se filtran a `presentation` (existe mapping a entidades de dominio).
- [ ] Los providers de Riverpod están con scope correcto (`autoDispose` por defecto, sin globales innecesarios).

### 3.2 Estado y reactividad
- [ ] El estado se modela con `AsyncValue<T>` o sealed classes (loading / data / error / empty). **No bool flags sueltos** (`isLoading`, `hasError`).
- [ ] Loading, empty, error states están todos cubiertos en cada pantalla. 🔴 **Blocker** si falta error state.
- [ ] No hay `setState` en widgets que vivan dentro de features (solo permitido en widgets de presentación puramente locales).

### 3.3 Routing
- [ ] Rutas declaradas en `go_router` con tipado fuerte.
- [ ] Deep links contemplados (`/auditorias/:id`, `/sucursales/:slug`).
- [ ] Guards de autenticación funcionan (test que lo verifique).

### 3.4 Performance
- [ ] **Listas largas** usan `ListView.builder` o `SliverList` (nunca `ListView(children: [...])` con 50+ items). 🟠 **Major**.
- [ ] Widgets pesados usan `const` cuando es posible.
- [ ] Animaciones complejas envueltas en `RepaintBoundary` cuando aplique.
- [ ] Imágenes con `cached_network_image` y placeholders.
- [ ] Fotos de evidencia se comprimen en cliente antes de upload.
- [ ] **Lighthouse** (web) ≥ 90 en Performance y ≥ 95 en Accessibility para el bundle de producción.
- [ ] Bundle inicial < 300 KB gzip.

### 3.5 UI / Material 3 y Theme
- [ ] No hay colores hardcoded como `Color(0xFF...)` fuera del `ThemeExtension`. 🟠 **Major**.
- [ ] No hay `TextStyle(fontSize: ...)` literal: usar `Theme.of(context).textTheme.*`.
- [ ] No hay `EdgeInsets.all(13)` arbitrario: usar tokens de spacing (`AppSpacing.md`, etc.).
- [ ] El componente cumple los specs del `DESIGN_PROPOSAL.md` (paddings, radius, sombras, fuentes).

### 3.6 Accesibilidad
- [ ] Todo `IconButton` tiene `tooltip:` y `Semantics(label: ...)`.
- [ ] Targets táctiles ≥ 44×44 px (Material 3 default 48 px).
- [ ] Contraste validado contra el `DESIGN_PROPOSAL.md` §2.6.
- [ ] Test ejecutado con TalkBack/VoiceOver en al menos un flujo crítico.
- [ ] `prefers-reduced-motion` respetado en animaciones.

### 3.7 Testing
- [ ] **Unit tests** para use cases y notifiers (cobertura ≥ 80% en lógica).
- [ ] **Widget tests** para componentes con lógica condicional (loading/error/data).
- [ ] **Golden tests** para componentes visuales clave (KPI card, badge, score visual).
- [ ] **Integration test** end-to-end del flujo de captura de auditoría.

### 3.8 i18n
- [ ] **Cero strings hardcoded** en español dentro del código. Todos en archivos ARB. 🟠 **Major**.
- [ ] Fechas formateadas con `intl` (`DateFormat.yMMMd('es_CL')`), no concatenación manual.
- [ ] Números formateados con `NumberFormat('#,##0', 'es_CL')`.

### 3.9 Estado offline (mobile)
- [ ] Las nuevas pantallas que escriben datos funcionan offline (probado con airplane mode).
- [ ] Cola de sync no se rompe ante datos malformados.
- [ ] Indicador visual de items pendientes presente.

---

## 4. Checklist de revisión Backend (FastAPI)

> Referencia: `AGENT_FASTAPI.md`. Aplica a `auditchain/backend/`.

### 4.1 Estructura por capas
- [ ] El código respeta `Router → Service → Repository → Model`. 🔴 **Blocker** si un router accede a SQLAlchemy directamente.
- [ ] Los esquemas Pydantic están separados por intención (`Create`, `Update`, `Read`).
- [ ] Errores del dominio se mapean a `DomainError` y producen HTTPExceptions consistentes.

### 4.2 Asincronía
- [ ] **Cero I/O síncrono dentro de async** (no `requests`, no `time.sleep`, no `psycopg2` sync). 🔴 **Blocker**.
- [ ] Llamadas a I/O usan clientes async (`httpx.AsyncClient`, `asyncpg`/SQLAlchemy async).
- [ ] CPU-bound work se envía a `run_in_executor` o a workers `arq`.

### 4.3 Pydantic / Validación
- [ ] Todos los inputs tienen un schema Pydantic v2.
- [ ] No se exponen modelos SQLAlchemy directamente (solo schemas Read). 🔴 **Blocker**.
- [ ] Validaciones de dominio en `@field_validator` o en services, no en routers.

### 4.4 Base de datos / SQLAlchemy
- [ ] Sesión con `lazy="raise"` para detectar N+1.
- [ ] Queries con joins explícitos cuando aplica.
- [ ] No `select(*)` ni serializaciones masivas sin paginación.
- [ ] Las consultas de dashboard se agrupan en **un solo query** o materialized view.

### 4.5 Seguridad
- [ ] JWT firmado con RS256 (no HS256 en prod). 🔴 **Blocker**.
- [ ] Passwords con `argon2id` (nunca bcrypt sin justificación documentada).
- [ ] Endpoint protegido = decorado con `Depends(require_role(...))`.
- [ ] **Rate limiting** activo en endpoints de login y POST.
- [ ] CORS restrictivo (solo dominios conocidos en prod).
- [ ] Sin secretos en código o logs. Vars de entorno via `pydantic_settings`.
- [ ] SQL injection: solo via ORM o parámetros bind. **Cero `f"SELECT ... {var}"`**. 🔴 **Blocker**.

### 4.6 Performance
- [ ] Endpoint de dashboard responde p95 < 300 ms con dataset realista.
- [ ] Queries pesadas tienen índices verificados (`EXPLAIN ANALYZE` adjunto en PR).
- [ ] Caching con redis en endpoints idempotentes con TTL razonable.
- [ ] Workers `arq` para emails, reportes PDF, notificaciones (no bloquear request).

### 4.7 Errores y observabilidad
- [ ] Logs en `structlog` con `request_id`, `user_id`, `latency_ms`.
- [ ] Errores 5xx capturados por Sentry o equivalente.
- [ ] Endpoints documentados con OpenAPI (descriptions, examples, response models).

### 4.8 Testing
- [ ] **Unit tests** para services con mocks de repos.
- [ ] **Integration tests** con `testcontainers` levantando Postgres real.
- [ ] **Contract tests** entre frontend y backend (Pact opcional, schemas OpenAPI mínimo).
- [ ] Cobertura ≥ 85% en services y routers.

### 4.9 Migraciones (Alembic)
- [ ] Toda migración acompañada de rollback testeado.
- [ ] Cambios destructivos en **dos pasos** (deploy nullable → backfill → deploy not null).
- [ ] Índices grandes con `CREATE INDEX CONCURRENTLY` (sin bloquear tabla en prod). 🔴 **Blocker**.

---

## 5. Checklist de revisión Database (PostgreSQL 16)

> Referencia: `AGENT_POSTGRES.md`. Aplica a `auditchain/db/`.

### 5.1 Schema y naming
- [ ] Tablas en plural (`auditorias`), columnas en singular (`fecha`).
- [ ] Restricciones nombradas explícitamente (`pk_`, `fk_`, `uq_`, `ck_`, `ix_`, `trg_`, `fn_`, `vw_`).
- [ ] FKs declaradas con `ON DELETE` explícito (`RESTRICT`, `SET NULL` o `CASCADE`).
- [ ] Tipos: `uuid` con `gen_random_uuid()` (pgcrypto), `citext` para emails, `timestamptz` siempre (nunca `timestamp` sin tz). 🔴 **Blocker** si se usa `timestamp without time zone`.

### 5.2 Integridad
- [ ] CHECK constraints para enums informales (`estado IN ('pendiente','completada','con_observaciones','vencida')`) **o** uso de `ENUM` real.
- [ ] No hay tablas sin PK. 🔴 **Blocker**.
- [ ] No hay datos críticos sin `NOT NULL` y `DEFAULT` apropiados.

### 5.3 Índices
- [ ] Cada FK tiene índice (Postgres no lo crea automático).
- [ ] Índices compuestos en orden ESR (Equality, Sort, Range).
- [ ] Índices parciales donde tiene sentido (`WHERE estado = 'pendiente'`).
- [ ] Trigram (`pg_trgm`) en búsquedas LIKE de texto.
- [ ] No hay índices duplicados o redundantes (verificar con `pg_stat_user_indexes`).

### 5.4 Triggers / lógica en DB
- [ ] Trigger `fn_set_actualizado_en` aplicado a toda tabla con `actualizado_en`.
- [ ] Trigger `fn_sucursal_recalcular_promedio` testeado con INSERT/UPDATE/DELETE en `auditorias`.
- [ ] **Sin lógica de negocio compleja en triggers** (mantener simple, predecible).

### 5.5 Migraciones
- [ ] Cada migración up tiene su down.
- [ ] Sin DROP COLUMN en una sola migración (dos pasos).
- [ ] Datos críticos backfilleados antes de añadir constraints NOT NULL.
- [ ] **Migración revisada por DBA o backend lead** antes de merge.

### 5.6 Performance
- [ ] EXPLAIN ANALYZE adjunto al PR para queries nuevas o modificadas.
- [ ] Queries del dashboard ejecutan en < 100 ms con dataset de 100k auditorías.
- [ ] Materialized views refrescadas con `REFRESH CONCURRENTLY` (no bloquean).
- [ ] `pg_stat_statements` revisado periódicamente para detectar queries lentas.

### 5.7 Seguridad
- [ ] Roles separados: `auditchain_owner` (DDL), `app_auditchain` (DML), `app_readonly` (SELECT).
- [ ] Aplicación se conecta con `app_auditchain`, **nunca con superuser**. 🔴 **Blocker**.
- [ ] Backups automáticos configurados (pg_basebackup + WAL archiving).
- [ ] PITR validado al menos 1× por trimestre.

### 5.8 Convenciones
- [ ] Comentarios en tablas y columnas críticas (`COMMENT ON COLUMN ... IS '...'`).
- [ ] Locale `es_CL.UTF-8` en cluster.
- [ ] Encoding UTF-8.

---

## 6. Checklist de revisión de Diseño (visual / UI)

> Referencia: `DESIGN_PROPOSAL.md` y `MOCKUPS_INTEGRATION.md`.

### 6.1 Tokens
- [ ] **Cero colores fuera de la paleta**. Todo color usa un token. 🟠 **Major**.
- [ ] Spacing con tokens (`--space-*`). No hay `padding: 13px` arbitrarios.
- [ ] Border radius con tokens (`--radius-*`). Default `--radius-lg` (14 px) en cards.
- [ ] Sombras del set definido (`--elev-1`, `--elev-2`, `--elev-3`). Sin sombras inventadas.

### 6.2 Tipografía
- [ ] Solo Inter + JetBrains Mono. Cualquier otra fuente → 🔴 **Blocker**.
- [ ] Tamaños del set tipográfico (no `font-size: 15px`).
- [ ] Pesos del set (400 / 500 / 600 / 700). No 350 ni 650.
- [ ] Numerales en tablas con `font-feature-settings: "tnum"`.

### 6.3 Componentes
- [ ] Botón primary respeta variante `--primary-800` con texto blanco.
- [ ] Badges de estado usan combinaciones del §2.4 del DESIGN_PROPOSAL.
- [ ] Inputs con label arriba (no placeholder-as-label). 🟠 **Major**.
- [ ] Estados (focus, hover, active, disabled, loading) implementados.

### 6.4 Layout y jerarquía
- [ ] Una pantalla = un CTA primary (idealmente). Excepciones justificadas.
- [ ] Jerarquía visual clara (no más de 3 tamaños tipográficos por pantalla).
- [ ] Espacios respiran: padding interno generoso en cards, espacios entre secciones.
- [ ] Grid alineado: elementos comparten baseline cuando aplica.

### 6.5 Iconografía
- [ ] Solo iconos del set Lucide.
- [ ] Tamaños 16 / 20 / 24 px.
- [ ] Nunca un icono solo sin label/tooltip (ya cubierto en a11y).

### 6.6 Mobile / responsive
- [ ] Funciona en 360 px de ancho (smartphone chico).
- [ ] Funciona en 768 px (tablet).
- [ ] Funciona en 1440 px (desktop estándar).
- [ ] Bottom nav presente en mobile, sidebar en desktop.
- [ ] Tabla web → cards mobile (no scroll horizontal). 🟠 **Major** si hay scroll horizontal.

### 6.7 Localización
- [ ] 100% en español es-CL.
- [ ] Fechas formato `26 oct 2023` (no `Oct 26, 2023`).
- [ ] Números `1.452,30` (no `1,452.30`).

---

## 7. Checklist de revisión de Comportamiento / UX

### 7.1 Estados de la pantalla
- [ ] **Loading**: skeleton para esperas > 200 ms. Spinner solo > 1 s.
- [ ] **Empty**: ilustración + texto explicativo + CTA. No "No hay datos." pelado.
- [ ] **Error**: mensaje humano + acción recuperable ("Reintentar", "Volver"). Nunca stack trace al usuario.
- [ ] **Success**: snackbar / toast / inline confirmation. Auto-dismiss 3–5 s.

### 7.2 Feedback inmediato
- [ ] Click en botón primary → estado pressed visible.
- [ ] Submit de formulario → botón muestra loading + se deshabilita.
- [ ] Acciones destructivas → confirmación modal con texto explícito.

### 7.3 Optimistic updates
- [ ] Likes, marcas, toggles: se actualizan en UI **antes** de la respuesta del servidor.
- [ ] Si la respuesta falla, se revierte con feedback claro.

### 7.4 Validación de formularios
- [ ] Validación inline al perder foco (no solo al submit).
- [ ] Errores en rojo con icono `alert-circle` + mensaje en lenguaje natural.
- [ ] Campos requeridos marcados con asterisco.
- [ ] Botón submit deshabilitado hasta que el form sea válido.

### 7.5 Microinteracciones
- [ ] Transiciones 150–350 ms (ver `DESIGN_PROPOSAL.md` §10).
- [ ] `prefers-reduced-motion` respetado.
- [ ] Hover states en web. Pressed states en mobile.

### 7.6 Datos y formatos
- [ ] Números grandes: separadores de miles. Decimales coherentes (siempre 1 o siempre 2, no mezclar).
- [ ] Fechas: relativas para recientes ("hace 2 h", "ayer"), absolutas para > 7 días.
- [ ] Strings largos: truncar con `ellipsis` + `title` accesible.

---

## 8. Checklist de revisión de Performance

| Métrica | Target | Cómo medir |
|---|---|---|
| Lighthouse Performance (web) | ≥ 90 | CI con Lighthouse CI |
| Lighthouse Accessibility (web) | ≥ 95 | CI con Lighthouse CI |
| Bundle inicial (web) | < 300 KB gzip | `flutter build web --release` + bundle analyzer |
| API p95 dashboard | < 300 ms | k6 o locust + Datadog |
| API p95 endpoints CRUD | < 150 ms | k6 |
| DB query p95 | < 50 ms | `pg_stat_statements` |
| Mobile cold start | < 2.0 s | Flutter DevTools |
| Mobile FPS en scroll | ≥ 58 | Flutter DevTools profile mode |
| App size (Android) | < 40 MB | apk inspector |

🔴 **Blocker** si una métrica regresiona > 20% en un PR sin justificación.

---

## 9. Checklist de revisión de Seguridad (OWASP top 10 abreviado)

| Riesgo | Mitigación verificada en PR |
|---|---|
| **Broken Access Control** | Cada endpoint protegido tiene test que verifica rol no autorizado → 403. |
| **Cryptographic Failures** | TLS 1.2+ obligatorio. Passwords argon2id. JWT RS256. |
| **Injection** | ORM parametrizado. Cero SQL concatenado. Pydantic valida inputs. |
| **Insecure Design** | Threat modeling para features sensibles (auditorías financieras, exports). |
| **Security Misconfiguration** | CORS estricto. Headers (`X-Content-Type-Options`, `Strict-Transport-Security`, `Content-Security-Policy`). |
| **Vulnerable Components** | `pip-audit` y `dart pub outdated --mode=null-safety` corren en CI. |
| **Identification Failures** | Rate limit en login. 2FA roadmapped. Lockout tras N intentos fallidos. |
| **Software & Data Integrity** | Lockfiles versionados (`poetry.lock`, `pubspec.lock`). Hashes verificados en CI. |
| **Logging Failures** | Logs estructurados con `request_id`. Sentry para errores. Sin PII en logs. |
| **SSRF** | Validar URLs externas. No fetch arbitrario desde input de usuario. |

🔴 **Blocker** ante cualquier fallo de seguridad detectado por escáneres en CI (`bandit`, `pip-audit`, `npm audit`, `dart pub audit`).

---

## 10. Automatización de checks (CI obligatorio)

```yaml
# .github/workflows/ci.yml (esquema)

jobs:
  frontend-flutter:
    - flutter analyze            # lint estático
    - flutter test --coverage    # unit + widget tests
    - flutter test integration_test/   # e2e
    - dart format --set-exit-if-changed .
    - flutter build web --release
    - lhci autorun               # Lighthouse CI

  backend-fastapi:
    - ruff check .
    - ruff format --check .
    - mypy --strict app/
    - pytest --cov=app --cov-fail-under=85
    - bandit -r app/
    - pip-audit

  database:
    - alembic upgrade head        # contra DB efímera
    - alembic downgrade -1
    - alembic upgrade head
    - sqlfluff lint db/migrations/

  security:
    - trivy scan (imágenes Docker)
    - gitleaks (secretos en commits)

  contract:
    - openapi-diff (breaking changes en API)
    - schemathesis (fuzz testing del OpenAPI)
```

🔴 **Blocker** si cualquier job de CI falla.

---

## 11. Proceso de revisión humana

### 11.1 Asignación
- **PR pequeño** (< 200 LOC): 1 reviewer del área.
- **PR mediano** (200–800 LOC): 2 reviewers (1 del área + 1 cross-area).
- **PR grande** (> 800 LOC): se solicita partir el PR. Si no es posible, 3 reviewers obligatorios + tech lead.

### 11.2 Tiempos
- Asignación: dentro de 4 horas hábiles.
- Primera respuesta: dentro de 1 día hábil.
- Re-review tras cambios: dentro de 4 horas hábiles.
- 🚫 **No mergear** PRs que lleven > 5 días hábiles sin actividad: cerrar o partir.

### 11.3 Estilo de comentarios
- Constructivo, específico, accionable.
- Citar la regla violada (`AGENT_FLUTTER.md §4.2`).
- Distinguir `nit:` / `suggestion:` / `change requested:` / `blocker:`.
- Aprobar con "LGTM" solo cuando todo el checklist pasó.

---

## 12. Plantilla de PR

```markdown
## ¿Qué cambia?
<!-- Descripción concisa del cambio en lenguaje de producto -->

## ¿Por qué?
<!-- Link a issue, ticket, decisión de producto -->

## Áreas afectadas
- [ ] Frontend (Flutter)
- [ ] Backend (FastAPI)
- [ ] Database (Postgres)
- [ ] Diseño / UX
- [ ] Documentación

## Checklist del autor
- [ ] He leído el AGENT.md correspondiente.
- [ ] Hay tests unitarios / de integración para el cambio.
- [ ] He probado en mobile (si aplica).
- [ ] He probado offline (si aplica).
- [ ] He validado contraste y accesibilidad.
- [ ] Hay migración de DB con rollback (si aplica).
- [ ] He medido performance (si aplica) y adjunto resultado.
- [ ] He actualizado documentación si cambió la API o el modelo.

## Capturas / Videos
<!-- Antes / después para cambios visuales -->

## Notas para el revisor
<!-- Áreas de mayor riesgo, decisiones controvertidas, etc. -->
```

---

## 13. Plantilla de revisión

```markdown
### Revisión por @reviewer ✓ / ✗

**Áreas revisadas:** [Frontend | Backend | DB | Diseño | UX]

**Resumen:** <una frase>

**🔴 Blockers**
- [ ] <ninguno> | <descripción + ubicación + regla violada>

**🟠 Major**
- [ ] <descripción + ubicación + sugerencia>

**🟡 Minor / nits**
- nit: <comentario opcional>

**Verificaciones manuales realizadas:**
- [ ] Probé el flujo X en mobile.
- [ ] Levanté la migración local y rollback.
- [ ] Validé contraste con axe / Stark.

**Veredicto:** Aprobado / Cambios solicitados / Rechazado
```

---

## 14. Anti-patterns que el revisor debe cazar siempre

### Frontend
- `setState` en widgets pegados a una feature compleja → debe ser provider.
- `Color(0xFF1E3A8A)` literal → debe usar token del theme.
- Widget con > 300 líneas → debe partirse.
- `FutureBuilder` con `setState` mezclado.
- Strings de UI hardcoded en español.

### Backend
- Endpoint que hace 3+ queries N+1 → join o aggregation.
- `@app.get("/...")` sin `response_model`.
- Pydantic con `Optional[X]` en lugar de `X | None` (Python 3.12).
- `try / except: pass` que oculta errores.
- Función async que llama a `requests.get(...)`.

### DB
- Migración que hace `ALTER TABLE ... DROP COLUMN ... CASCADE` en producción.
- Trigger que llama a otro trigger en cadena (riesgo de loops).
- Índice creado sin `CONCURRENTLY` en tabla > 100k filas.
- `SELECT *` en código de producción.

### Diseño
- Más de 4 colores en un chart.
- Texto en gris claro sobre fondo blanco con contraste < 4.5:1.
- Modal de pantalla completa para una decisión binaria (debería ser confirmación inline).
- 7 botones primary en una pantalla.

---

## 15. Definition of Done (DoD)

Una feature está **terminada** cuando:

1. ✅ Código mergeado a `main` tras pasar todos los checks de CI.
2. ✅ Tests unitarios + integración + e2e pasando con cobertura ≥ target.
3. ✅ Documentación actualizada (AGENT.md, README, docs API).
4. ✅ Migración aplicada en staging y validada por QA.
5. ✅ Performance medido y dentro de targets.
6. ✅ Revisión accesible (axe + manual) sin issues 🔴/🟠.
7. ✅ Probado en al menos 2 dispositivos mobile (iOS + Android) y 2 navegadores web (Chrome + Safari).
8. ✅ Probado offline en mobile (cuando aplica).
9. ✅ Owner de producto valida el comportamiento.
10. ✅ Release notes incluyen la feature.

---

## 16. Escalación

- **Desacuerdo entre reviewer y autor**: tech lead del área media. Si persiste, decisión arquitectónica con CTO/lead.
- **Hotfix urgente** (P0): proceso abreviado (1 reviewer + checklist mínimo de seguridad), pero **post-mortem obligatorio** dentro de 48 h.
- **Cambio de regla**: si el revisor considera que una regla del AGENT.md ya no aplica, se abre un PR sobre el AGENT.md correspondiente con justificación. Cambios al sistema de diseño requieren versión semver.

---

## 17. Métricas del proceso de revisión

El equipo trackea (mensual):

| Métrica | Target |
|---|---|
| Tiempo medio de primera revisión | < 8 h hábiles |
| % de PRs mergeados al primer round | ≥ 50% |
| % de PRs con cobertura de tests | 100% |
| Bugs encontrados post-merge atribuibles a falta de revisión | < 5% |
| Satisfacción del equipo con el proceso (encuesta trimestral) | ≥ 4 / 5 |

---

## 18. Referencias

- `AGENT_FLUTTER.md`: convenciones frontend.
- `AGENT_FASTAPI.md`: convenciones backend.
- `AGENT_POSTGRES.md`: convenciones de base de datos.
- `DESIGN_PROPOSAL.md`: sistema de diseño y tokens.
- `MOCKUPS_INTEGRATION.md`: estrategia visual web ↔ mobile.
- [Conventional Commits](https://www.conventionalcommits.org)
- [WCAG 2.2](https://www.w3.org/TR/WCAG22/)
- [OWASP Top 10](https://owasp.org/www-project-top-ten/)
- [Material Design 3](https://m3.material.io)

---

> **Recordatorio final.** El revisor es el último filtro antes de que el código toque a un usuario real. Su trabajo no es ser obstruccionista, sino **proteger** —al usuario, al equipo y al producto—. Una revisión rigurosa hoy es 10 horas menos de debugging la próxima semana.
