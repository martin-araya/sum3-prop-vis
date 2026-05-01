# 🐘 AGENT.md — PostgreSQL 16 (AuditChain)

> Guía operativa para el diseño, optimización, mantenimiento y seguridad de la base de datos PostgreSQL 16 que soporta **AuditChain**.

---

## 1. Contexto

- **Motor:** PostgreSQL 16.x (oficial, no fork salvo razón explícita).
- **Charset/Locale:** `UTF8`, `lc_collate=es_CL.UTF-8` para ordenamientos correctos en español.
- **Schema principal:** `auditchain` (no usar `public` para datos del dominio).
- **Migraciones:** Alembic (definido por el backend); este documento describe el modelo objetivo y las prácticas que cualquier migración debe respetar.
- **Workload esperado:** OLTP mixto (lecturas frecuentes para dashboard, escrituras moderadas en auditorías).

---

## 2. Filosofía de Trabajo

1. **El schema es la fuente de verdad.** Constraints en DB, no solo en aplicación.
2. **Integridad sobre conveniencia.** Foreign keys, checks, not-nulls, unique siempre que tengan sentido.
3. **Los índices son código.** Cada índice debe justificarse con una query real.
4. **`EXPLAIN ANALYZE` es obligatorio** antes de aprobar queries que toquen tablas grandes.
5. **Migraciones reversibles** salvo decisión explícita y documentada.
6. **Sin lógica de negocio compleja en triggers** — solo invariantes y derivaciones simples.

---

## 3. Convenciones de Naming

| Objeto                | Convención                                  | Ejemplo                                  |
|-----------------------|---------------------------------------------|------------------------------------------|
| Tabla                 | snake_case, **plural**, español             | `sucursales`, `auditorias`               |
| Columna               | snake_case, singular                        | `puntaje_promedio`, `creado_en`          |
| PK                    | `pk_<tabla>`                                | `pk_auditorias`                          |
| FK                    | `fk_<tabla>_<col>_<tabla_referida>`         | `fk_auditorias_sucursal_id_sucursales`   |
| Unique                | `uq_<tabla>_<col>`                          | `uq_usuarios_email`                      |
| Check                 | `ck_<tabla>_<descripcion>`                  | `ck_auditorias_puntaje_rango`            |
| Index                 | `ix_<tabla>_<col>` o `ix_<tabla>_<purpose>` | `ix_auditorias_sucursal_fecha`           |
| Trigger               | `trg_<tabla>_<evento>`                      | `trg_auditorias_actualizar_promedio`     |
| Función               | `fn_<dominio>_<accion>`                     | `fn_sucursal_recalcular_promedio`        |
| Vista                 | `vw_<descripcion>`                          | `vw_dashboard_metricas`                  |
| Vista materializada   | `mvw_<descripcion>`                         | `mvw_compliance_por_region`              |
| Enum (tipo)           | `enum_<dominio>`                            | `enum_estado_auditoria`                  |

- **Sin abreviaciones crípticas.** `usr` y `aud` están prohibidos. `usuario`, `auditoria`.
- **Sin prefijos `tbl_`** ni similares.

---

## 4. Schema Base — Modelo Objetivo

```sql
CREATE SCHEMA IF NOT EXISTS auditchain;
SET search_path TO auditchain, public;

CREATE EXTENSION IF NOT EXISTS pgcrypto;       -- gen_random_uuid()
CREATE EXTENSION IF NOT EXISTS citext;         -- emails case-insensitive
CREATE EXTENSION IF NOT EXISTS pg_trgm;        -- búsqueda fuzzy
CREATE EXTENSION IF NOT EXISTS unaccent;       -- búsqueda sin tildes

-- ENUMs
CREATE TYPE enum_rol_usuario AS ENUM ('admin', 'auditor');
CREATE TYPE enum_estado_auditoria AS ENUM ('pendiente', 'completada', 'con_observaciones');

-- USUARIOS
CREATE TABLE usuarios (
    id              uuid PRIMARY KEY DEFAULT gen_random_uuid(),
    nombre          varchar(120) NOT NULL,
    email           citext NOT NULL,
    password_hash   varchar(255) NOT NULL,
    rol             enum_rol_usuario NOT NULL,
    activo          boolean NOT NULL DEFAULT true,
    creado_en       timestamptz NOT NULL DEFAULT now(),
    actualizado_en  timestamptz NOT NULL DEFAULT now(),
    CONSTRAINT uq_usuarios_email UNIQUE (email),
    CONSTRAINT ck_usuarios_nombre_no_vacio CHECK (length(trim(nombre)) > 0)
);

-- SUCURSALES
CREATE TABLE sucursales (
    id                uuid PRIMARY KEY DEFAULT gen_random_uuid(),
    nombre            varchar(120) NOT NULL,
    region            varchar(50) NOT NULL,
    direccion         varchar(255),
    puntaje_promedio  numeric(5,2),
    activa            boolean NOT NULL DEFAULT true,
    creado_en         timestamptz NOT NULL DEFAULT now(),
    actualizado_en    timestamptz NOT NULL DEFAULT now(),
    CONSTRAINT ck_sucursales_puntaje_rango
      CHECK (puntaje_promedio IS NULL OR puntaje_promedio BETWEEN 0 AND 100)
);

-- AUDITORES
CREATE TABLE auditores (
    id          uuid PRIMARY KEY DEFAULT gen_random_uuid(),
    nombre      varchar(120) NOT NULL,
    email       citext NOT NULL,
    region      varchar(50) NOT NULL,
    usuario_id  uuid,
    activo      boolean NOT NULL DEFAULT true,
    creado_en   timestamptz NOT NULL DEFAULT now(),
    actualizado_en timestamptz NOT NULL DEFAULT now(),
    CONSTRAINT uq_auditores_email UNIQUE (email),
    CONSTRAINT fk_auditores_usuario_id_usuarios
      FOREIGN KEY (usuario_id) REFERENCES usuarios(id) ON DELETE SET NULL
);

-- AUDITORIAS
CREATE TABLE auditorias (
    id           uuid PRIMARY KEY DEFAULT gen_random_uuid(),
    sucursal_id  uuid NOT NULL,
    auditor_id   uuid NOT NULL,
    fecha        date NOT NULL,
    puntaje      smallint,
    estado       enum_estado_auditoria NOT NULL DEFAULT 'pendiente',
    observaciones text,
    creado_en    timestamptz NOT NULL DEFAULT now(),
    actualizado_en timestamptz NOT NULL DEFAULT now(),
    CONSTRAINT fk_auditorias_sucursal_id_sucursales
      FOREIGN KEY (sucursal_id) REFERENCES sucursales(id) ON DELETE RESTRICT,
    CONSTRAINT fk_auditorias_auditor_id_auditores
      FOREIGN KEY (auditor_id) REFERENCES auditores(id) ON DELETE RESTRICT,
    CONSTRAINT ck_auditorias_puntaje_rango
      CHECK (puntaje IS NULL OR puntaje BETWEEN 0 AND 100),
    CONSTRAINT ck_auditorias_estado_puntaje
      CHECK (
        (estado = 'pendiente' AND puntaje IS NULL) OR
        (estado IN ('completada','con_observaciones') AND puntaje IS NOT NULL)
      )
);
```

### Decisiones de tipos
- **`uuid`** en lugar de `bigserial`: distribución segura, no enumerable. Generado en DB, no en app.
- **`citext`** para emails: comparación case-insensitive sin `LOWER()` en cada query.
- **`timestamptz`** siempre, nunca `timestamp` "naive". UTC en DB, conversión en presentación.
- **`numeric(5,2)`** para puntajes promedios; **`smallint`** para puntajes individuales (0–100).
- **`enum`** para estados: type-safe, eficiente, evita strings mágicos.

---

## 5. Índices — Estrategia

### Reglas
1. Cada FK tiene su índice (PostgreSQL **no** los crea automáticamente).
2. Para queries de listado con filtros, índices compuestos siguiendo el orden **ESR** (Equality, Sort, Range).
3. Índices parciales cuando una condición filtra >70% de las filas.
4. `INCLUDE` para covering indexes en lecturas heavy.
5. Antes de crear, validar con `EXPLAIN ANALYZE` que el planner los usa.

### Índices del dominio

```sql
-- Búsqueda y filtros frecuentes
CREATE INDEX ix_sucursales_region          ON sucursales (region);
CREATE INDEX ix_sucursales_activa_region   ON sucursales (region) WHERE activa = true;
CREATE INDEX ix_auditores_region           ON auditores (region);
CREATE INDEX ix_auditores_usuario_id       ON auditores (usuario_id);

-- Auditorías: la query más caliente filtra por sucursal y ordena por fecha
CREATE INDEX ix_auditorias_sucursal_fecha
  ON auditorias (sucursal_id, fecha DESC);

CREATE INDEX ix_auditorias_auditor_fecha
  ON auditorias (auditor_id, fecha DESC);

-- Filtros por estado: índice parcial (la mayoría son completadas)
CREATE INDEX ix_auditorias_pendientes
  ON auditorias (creado_en DESC) WHERE estado = 'pendiente';

-- Para dashboard: agregaciones por rango de fecha
CREATE INDEX ix_auditorias_fecha
  ON auditorias (fecha);

-- Búsqueda por nombre (trigram)
CREATE INDEX ix_sucursales_nombre_trgm
  ON sucursales USING gin (nombre gin_trgm_ops);
```

### Mantenimiento de índices
- `pg_stat_user_indexes`: revisar trimestralmente índices con `idx_scan = 0` y eliminarlos.
- `REINDEX CONCURRENTLY` cuando un índice se hincha (>30% bloat).
- Monitorear `pg_stat_user_tables.n_dead_tup` y ajustar `autovacuum`.

---

## 6. Triggers y Funciones

### Trigger: actualizar `actualizado_en` automáticamente

```sql
CREATE OR REPLACE FUNCTION fn_set_actualizado_en()
RETURNS trigger LANGUAGE plpgsql AS $$
BEGIN
  NEW.actualizado_en := now();
  RETURN NEW;
END $$;

DO $$
DECLARE t text;
BEGIN
  FOR t IN SELECT unnest(ARRAY['usuarios','sucursales','auditores','auditorias']) LOOP
    EXECUTE format(
      'CREATE TRIGGER trg_%1$s_actualizado_en
       BEFORE UPDATE ON %1$s
       FOR EACH ROW EXECUTE FUNCTION fn_set_actualizado_en()', t);
  END LOOP;
END $$;
```

### Trigger: recálculo automático del `puntaje_promedio`

```sql
CREATE OR REPLACE FUNCTION fn_sucursal_recalcular_promedio()
RETURNS trigger LANGUAGE plpgsql AS $$
DECLARE
  v_sucursal uuid;
BEGIN
  v_sucursal := COALESCE(NEW.sucursal_id, OLD.sucursal_id);
  UPDATE sucursales s
     SET puntaje_promedio = (
       SELECT round(avg(puntaje)::numeric, 2)
       FROM auditorias
       WHERE sucursal_id = v_sucursal
         AND puntaje IS NOT NULL
     )
   WHERE s.id = v_sucursal;
  RETURN NULL; -- AFTER trigger
END $$;

CREATE TRIGGER trg_auditorias_recalcular_promedio
  AFTER INSERT OR UPDATE OF puntaje OR DELETE ON auditorias
  FOR EACH ROW EXECUTE FUNCTION fn_sucursal_recalcular_promedio();
```

### Reglas para triggers
- Idempotentes: ejecutarlos dos veces no debe romper nada.
- Sin acceso a tablas externas en triggers `BEFORE` (riesgo de deadlock).
- Loggear cambios sensibles en `auditorias_changelog` si la auditoría regulatoria lo requiere.
- Documentar el trigger en un comentario `COMMENT ON FUNCTION`.

---

## 7. Vistas y Vistas Materializadas

### Vista normal: `vw_dashboard_metricas`

```sql
CREATE OR REPLACE VIEW vw_dashboard_metricas AS
SELECT
  count(*)                                          AS total_auditorias,
  count(*) FILTER (WHERE estado = 'pendiente')      AS pendientes,
  count(*) FILTER (WHERE estado = 'completada')     AS completadas,
  count(*) FILTER (WHERE estado = 'con_observaciones') AS con_observaciones,
  round(avg(puntaje) FILTER (WHERE puntaje IS NOT NULL)::numeric, 1) AS compliance_global,
  count(DISTINCT auditor_id)                        AS auditores_activos
FROM auditorias
WHERE creado_en >= now() - interval '90 days';
```

### Vista materializada: agregados pesados

```sql
CREATE MATERIALIZED VIEW mvw_compliance_por_region AS
SELECT
  s.region,
  date_trunc('quarter', a.fecha) AS trimestre,
  count(*)                       AS total,
  round(avg(a.puntaje)::numeric, 2) AS promedio
FROM auditorias a
JOIN sucursales s ON s.id = a.sucursal_id
WHERE a.puntaje IS NOT NULL
GROUP BY 1, 2
WITH NO DATA;

CREATE UNIQUE INDEX uq_mvw_compliance_region_trimestre
  ON mvw_compliance_por_region (region, trimestre);

-- Refresh concurrente (no bloquea lecturas)
REFRESH MATERIALIZED VIEW CONCURRENTLY mvw_compliance_por_region;
```

- Refresh programado vía `pg_cron` o job del backend cada 15-60 min según necesidad.
- Siempre con índice único para permitir `CONCURRENTLY`.

---

## 8. Performance — Configuración del Servidor

Valores base para una instancia con 4 vCPU / 16 GB RAM:

```conf
# postgresql.conf — ajustar a tu hardware
shared_buffers = 4GB                 # ~25% de la RAM
effective_cache_size = 12GB          # ~75% de la RAM
work_mem = 32MB                      # por operación de sort/hash
maintenance_work_mem = 1GB           # vacuum, create index
wal_buffers = 16MB
checkpoint_completion_target = 0.9
random_page_cost = 1.1               # para SSD
effective_io_concurrency = 200       # SSD
max_connections = 100                # más arriba → usar pgbouncer
default_statistics_target = 100      # 200-500 para columnas con muchos distinct values
jit = off                            # OLTP típico: JIT da poco beneficio
log_min_duration_statement = 500ms
log_lock_waits = on
log_temp_files = 0
```

- **Connection pooler** obligatorio en producción: `pgbouncer` en modo `transaction`.
- Backups frecuentes: `pg_basebackup` + WAL archiving (`pg_receivewal`).
- Monitoreo: `pg_stat_statements`, `pg_stat_activity`, `pg_stat_replication`.

---

## 9. Optimización de Queries

### Reglas de oro
1. **`EXPLAIN (ANALYZE, BUFFERS)`** antes de aprobar cualquier query nueva sobre una tabla con >100k filas.
2. Evitar `SELECT *` en producción — listar columnas explícitamente.
3. `LIMIT` siempre en endpoints de listado.
4. `EXISTS` sobre `IN (SELECT ...)` cuando el subquery devuelve muchas filas.
5. `WHERE EXISTS` sobre `JOIN ... GROUP BY ... HAVING` para filtros de existencia.
6. `OFFSET` grande (>10k) → usar paginación por keyset (cursor con `WHERE id > :last_id`).
7. Funciones sobre columnas indexadas rompen el índice (`WHERE lower(email) = ...`) → guardar normalizado o usar `citext`/expression index.

### Ejemplo: query del dashboard optimizada

```sql
-- Una sola pasada por la tabla
SELECT
  count(*)                                          AS total,
  count(*) FILTER (WHERE estado = 'pendiente')      AS pendientes,
  round(avg(puntaje) FILTER (WHERE puntaje IS NOT NULL)::numeric, 1) AS compliance,
  count(DISTINCT auditor_id) FILTER (WHERE fecha >= current_date - 30) AS auditores_30d
FROM auditorias;
```

### Paginación por keyset

```sql
SELECT id, fecha, puntaje
FROM auditorias
WHERE (fecha, id) < (:last_fecha, :last_id)
ORDER BY fecha DESC, id DESC
LIMIT 50;
```

---

## 10. Seguridad

### Roles y privilegios
- **Principle of Least Privilege.** Crear roles específicos por función:

```sql
-- Rol que la app usa (lectura/escritura sobre el dominio)
CREATE ROLE app_auditchain LOGIN PASSWORD '<rotate>';
GRANT USAGE ON SCHEMA auditchain TO app_auditchain;
GRANT SELECT, INSERT, UPDATE, DELETE ON ALL TABLES IN SCHEMA auditchain TO app_auditchain;
GRANT USAGE ON ALL SEQUENCES IN SCHEMA auditchain TO app_auditchain;
ALTER DEFAULT PRIVILEGES IN SCHEMA auditchain
  GRANT SELECT, INSERT, UPDATE, DELETE ON TABLES TO app_auditchain;

-- Rol read-only para BI / reporting
CREATE ROLE app_readonly LOGIN PASSWORD '<rotate>';
GRANT USAGE ON SCHEMA auditchain TO app_readonly;
GRANT SELECT ON ALL TABLES IN SCHEMA auditchain TO app_readonly;

-- Owner / migraciones (separado de app)
CREATE ROLE auditchain_owner NOLOGIN;
ALTER SCHEMA auditchain OWNER TO auditchain_owner;
```

- La app NUNCA se conecta como `postgres` ni como owner.
- Migraciones corren como `auditchain_owner`.
- Passwords rotables, almacenados en secret manager.

### Row-Level Security (futuro)
Cuando se introduzca multi-tenancy o restricción por región del auditor:

```sql
ALTER TABLE auditorias ENABLE ROW LEVEL SECURITY;
CREATE POLICY auditor_ve_su_region ON auditorias
  USING (
    auditor_id IN (SELECT id FROM auditores
                   WHERE usuario_id = current_setting('app.current_user_id')::uuid)
    OR current_setting('app.current_role') = 'admin'
  );
```

### Encriptación
- **At rest:** filesystem (LUKS) o cloud provider managed.
- **In transit:** `ssl=on`, certificados válidos. Conexiones de la app con `sslmode=require` mínimo, `verify-full` en prod.
- Datos especialmente sensibles (no es nuestro caso actual): `pgp_sym_encrypt` de `pgcrypto`.

### Logging y auditoría
- `log_statement = 'ddl'` para registrar cambios de schema.
- Para auditoría regulatoria de cambios de datos: `pgaudit` extension.
- Nunca loggear `password_hash` ni tokens.

---

## 11. Backup y Recuperación

### Estrategia
- **Backups completos:** `pg_basebackup` diario.
- **WAL archiving:** continuo a object storage (S3/MinIO) con `pg_receivewal`.
- **Retención:** 7 días incrementales, 4 semanales, 12 mensuales.
- **PITR (Point-in-Time Recovery):** posible al segundo dentro de la ventana de retención.
- **Pruebas de restore:** mensual contra entorno staging. Backup que no se restaura no es backup.

### Comando ejemplo

```bash
pg_basebackup -h primary -D /backups/$(date +%F) -F tar -z -P -X fetch
```

### Logical backups complementarios
- `pg_dump` por schema para portabilidad y restores parciales.
- Útil para clonar ambiente de desarrollo desde subset.

---

## 12. Replicación y Alta Disponibilidad

- **Streaming replication** con réplica hot-standby para failover.
- Lecturas pesadas (reportes, BI) → réplica.
- `synchronous_commit = on` con al menos una réplica síncrona en datos críticos.
- Failover automático con `Patroni` + `etcd` o servicio managed (RDS, Cloud SQL).

---

## 13. Mantenimiento Periódico

| Tarea                              | Frecuencia              | Comando / Acción                           |
|------------------------------------|-------------------------|--------------------------------------------|
| `VACUUM ANALYZE` (autovacuum)      | Continuo                | Ajustar thresholds en tablas calientes     |
| `VACUUM FULL`                      | Solo bajo demanda       | Bloquea tabla; usar `pg_repack`            |
| `REINDEX CONCURRENTLY`             | Trimestral o por bloat  | Sobre índices con bloat >30%               |
| `ANALYZE` post-load masivo         | Inmediato               | Después de imports grandes                 |
| Revisión de slow queries           | Semanal                 | `pg_stat_statements`                        |
| Revisión índices no usados         | Trimestral              | `pg_stat_user_indexes WHERE idx_scan = 0` |
| Verificación de backups            | Semanal                 | Restore en staging                          |
| Actualización menor (16.x → 16.y)  | Cuando sale, en staging | Downtime mínimo                             |

---

## 14. Observabilidad

Métricas mínimas exportadas (Prometheus + `postgres_exporter`):

- Conexiones activas / max_connections
- Cache hit ratio (`> 99%` deseable)
- Replication lag
- Bloat de índices y tablas
- Slow queries por minuto
- Tiempo medio por query desde `pg_stat_statements`
- WAL generation rate

Dashboard Grafana estándar para `postgres_exporter` cubre el 90%.

---

## 15. Migraciones — Reglas

1. **Una migración = un cambio lógico.** No mezclar refactor de schema con backfill grande.
2. **Migraciones de schema y de datos separadas.** Más fácil de revertir y razonar.
3. **Cambios destructivos en dos pasos:**
   - PR 1: agregar columna nueva, backfill, código usa ambas.
   - PR 2 (siguiente release): eliminar columna antigua.
4. **`ALTER TABLE ADD COLUMN ... DEFAULT ...`** en PG 11+ es instantáneo si el default es constante. Validar.
5. **`CREATE INDEX CONCURRENTLY`** siempre en producción. Nunca bloquear la tabla.
6. **`ALTER TABLE ... ADD CONSTRAINT NOT VALID` + `VALIDATE CONSTRAINT`** para no bloquear en validación.
7. **Locks largos prohibidos** en horario productivo. Usar `lock_timeout` + retry.
8. **Reversibilidad:** toda migración tiene `downgrade()` salvo decisión documentada.

---

## 16. Checklist de PR (Database)

- [ ] Tabla nueva tiene PK, `creado_en`, `actualizado_en` y trigger correspondiente.
- [ ] Cada FK tiene su índice de soporte.
- [ ] Constraints (NOT NULL, CHECK, UNIQUE) están donde deben.
- [ ] Naming sigue las convenciones del documento.
- [ ] `EXPLAIN ANALYZE` adjunto para queries nuevas sobre tablas grandes.
- [ ] La migración corre sin downtime (CONCURRENTLY donde aplica).
- [ ] Migración tiene `downgrade()` o se documenta por qué no.
- [ ] Tests del repositorio cubren el cambio.
- [ ] No hay `SELECT *` en código que llame esta tabla.
- [ ] Cambio probado contra dataset realista (~100k+ filas) si afecta performance.

---

## 17. Anti-patrones — NO hacer

- ❌ `varchar(n)` arbitrario sin justificación; preferir `text` cuando no hay límite real (no hay penalización en PG).
- ❌ `serial`/`bigserial` para nuevas tablas — usar `uuid` o `bigint GENERATED ALWAYS AS IDENTITY`.
- ❌ FK sin índice.
- ❌ `ON DELETE CASCADE` en datos importantes — preferir `RESTRICT` y borrado lógico.
- ❌ Borrado físico de datos auditables — usar campo `eliminado_en timestamptz`.
- ❌ Trigger que llama a otro servicio (HTTP, etc.).
- ❌ `TRUNCATE` en tablas con FKs sin pensar en el cascade.
- ❌ `OFFSET 100000` en paginación.
- ❌ Función `IMMUTABLE` que en realidad no lo es (rompe índices funcionales).
- ❌ `pg_dump` sin `--no-owner` cuando se restaura en otro entorno.
- ❌ Concatenar SQL con valores del usuario — siempre parametrizado.

---

## 18. Lógica de Negocio Específica del Dominio

| Regla                                                             | Implementación                                                |
|-------------------------------------------------------------------|---------------------------------------------------------------|
| `puntaje_promedio` se recalcula al insertar/actualizar/borrar     | Trigger `trg_auditorias_recalcular_promedio`                  |
| Una auditoría `pendiente` no puede tener puntaje                  | `CHECK (ck_auditorias_estado_puntaje)`                        |
| No se puede eliminar una sucursal con auditorías                  | `FK ON DELETE RESTRICT`                                       |
| Email único por usuario (case-insensitive)                        | `citext` + `UNIQUE`                                           |
| Solo admins pueden crear sucursales                               | Validado en backend (no en DB para flexibilidad)              |
| Auditor solo ve auditorías de su región (futuro)                  | RLS opcional, hoy en backend                                  |

---

## 19. Health Check SQL (para monitoreo)

```sql
SELECT 1 AS ok,
       pg_is_in_recovery() AS is_replica,
       pg_database_size(current_database()) AS db_size_bytes,
       (SELECT count(*) FROM pg_stat_activity WHERE state = 'active') AS conexiones_activas;
```

---

## 20. Referencias Permanentes

- PG 16 docs: https://www.postgresql.org/docs/16/
- Use The Index, Luke!: https://use-the-index-luke.com
- PostgreSQL Wiki — Don't Do This: https://wiki.postgresql.org/wiki/Don%27t_Do_This
- pgbouncer: https://www.pgbouncer.org
- pgaudit: https://github.com/pgaudit/pgaudit
