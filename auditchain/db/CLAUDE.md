# CLAUDE.md — Base de datos (auditchain/db/)

> Contexto específico para Claude Code trabajando en PostgreSQL.
> Lee también: docs/AGENT_POSTGRES.md (spec completa con ejemplos SQL).

---

## Archivos en esta carpeta

```
db/
├── CLAUDE.md       ← estás aquí
├── init.sql        ← schema completo (se ejecuta al crear el contenedor)
└── seed.sql        ← datos de prueba: 3 usuarios, 5 sucursales, 3 auditores, ~10 auditorías
```

---

## Comandos útiles

```bash
# Conectar a la DB desde Docker (desde auditchain/)
docker-compose exec db psql -U postgres -d auditchain_db

# Conectar desde el host (puerto mapeado: 5433 → 5432 en contenedor)
psql -h localhost -p 5433 -U postgres -d auditchain_db

# Cargar seed data después de levantar la DB
docker-compose exec -T db psql -U postgres -d auditchain_db < db/seed.sql

# Ejecutar un script SQL
docker-compose exec -T db psql -U postgres -d auditchain_db < db/init.sql

# Ver todas las tablas del schema auditchain
\dt auditchain.*

# Ver la definición de una tabla
\d auditchain.auditorias

# Ver todos los ENUMs
SELECT typname, enumlabel FROM pg_enum JOIN pg_type ON pg_enum.enumtypid = pg_type.oid;

# Resetear la DB completa (CUIDADO: borra todo)
docker-compose down -v && docker-compose up db

# Backup de la DB
docker-compose exec db pg_dump -U postgres auditchain_db > backup.sql
```

---

## Convenciones SQL — NO negociables

```sql
-- Schema
CREATE SCHEMA auditchain;
SET search_path TO auditchain;

-- Extensiones (siempre antes de las tablas)
CREATE EXTENSION IF NOT EXISTS pgcrypto;   -- gen_random_uuid()
CREATE EXTENSION IF NOT EXISTS citext;     -- email case-insensitive
CREATE EXTENSION IF NOT EXISTS pg_trgm;   -- búsqueda fuzzy
CREATE EXTENSION IF NOT EXISTS unaccent;  -- búsqueda sin tildes

-- ENUMs nativos (nunca varchar + CHECK)
CREATE TYPE auditchain.enum_rol_usuario AS ENUM ('admin', 'auditor');
CREATE TYPE auditchain.enum_estado_auditoria AS ENUM (
    'pendiente', 'completada', 'con_observaciones', 'vencida'
);

-- Naming de constraints (obligatorio, nunca dejar sin nombre)
CONSTRAINT pk_tabla            PRIMARY KEY (id)
CONSTRAINT fk_tabla_col_tabla2 FOREIGN KEY (col) REFERENCES tabla2(id)
CONSTRAINT ck_tabla_descripcion CHECK (condicion)
CONSTRAINT uq_tabla_col        UNIQUE (col)
CREATE INDEX ix_tabla_col ON auditchain.tabla(col);

-- PKs
id UUID DEFAULT gen_random_uuid() NOT NULL

-- Timestamps (en español, siempre timestamptz)
creado_en      TIMESTAMPTZ NOT NULL DEFAULT now()
actualizado_en TIMESTAMPTZ NOT NULL DEFAULT now()

-- Email (siempre CITEXT, no VARCHAR)
email CITEXT NOT NULL
```

---

## Tablas del schema auditchain

Orden de creación (respeta FKs):

1. `auditchain.usuarios` — id, nombre, email (citext), password_hash, rol (enum), activo, creado_en, actualizado_en
2. `auditchain.sucursales` — id, nombre, region, direccion, puntaje_promedio, activo, creado_en, actualizado_en
3. `auditchain.auditores` — id, usuario_id (FK→usuarios), nombre, email (citext), region, activo, creado_en, actualizado_en
4. `auditchain.auditorias` — id, sucursal_id (FK→sucursales), auditor_id (FK→auditores), fecha, puntaje (0-100), estado (enum), observaciones, creado_en, actualizado_en

---

## Funciones y triggers requeridos

```sql
-- Trigger: recalcular puntaje_promedio en sucursales
-- Se dispara: AFTER INSERT, UPDATE, DELETE ON auditchain.auditorias
-- Usar COALESCE(NEW.sucursal_id, OLD.sucursal_id): en DELETE solo existe OLD
-- Actualiza: sucursales.puntaje_promedio = AVG(puntaje) WHERE sucursal_id = COALESCE(NEW.sucursal_id, OLD.sucursal_id)

-- Trigger: actualizar actualizado_en automáticamente
-- Se dispara: BEFORE UPDATE en todas las tablas
-- Actualiza: actualizado_en = now()
```

---

## Reglas de esta capa

1. Nunca modificar `init.sql` sin actualizar también los modelos SQLAlchemy del backend.
2. Toda nueva columna necesita: nombre en español, tipo explícito, constraint de NOT NULL o DEFAULT.
3. Nunca `VARCHAR` para emails — siempre `CITEXT`.
4. Nunca `VARCHAR + CHECK` para estados — siempre `ENUM` nativo.
5. Todo cambio de schema en producción → nueva migración Alembic, nunca ALTER TABLE manual.
6. Probar el `init.sql` completo con un `docker-compose down -v && docker-compose up db` antes de hacer commit.

---

## Verificar que el schema está correcto

```sql
-- Ejecutar después de crear el schema:
SELECT table_name FROM information_schema.tables
WHERE table_schema = 'auditchain' ORDER BY table_name;
-- Debe mostrar: auditorias, auditores, sucursales, usuarios

SELECT typname FROM pg_type
WHERE typnamespace = (SELECT oid FROM pg_namespace WHERE nspname = 'auditchain');
-- Debe mostrar los ENUMs creados

SELECT extname FROM pg_extension;
-- Debe incluir: pgcrypto, citext, pg_trgm, unaccent
```

---

## Referencia rápida de specs

- Spec completa con ejemplos: `docs/AGENT_POSTGRES.md`
- Cómo los modelos SQLAlchemy mapean este schema: `auditchain/backend/CLAUDE.md`
