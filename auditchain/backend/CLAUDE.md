# CLAUDE.md — Backend (auditchain/backend/)

> Contexto específico para Claude Code trabajando en el backend FastAPI.
> Lee también: docs/AGENT_FASTAPI.md (arquitectura completa y ejemplos de código).

---

## Arquitectura de archivos

```
backend/
├── CLAUDE.md                  ← estás aquí
├── Dockerfile
├── pyproject.toml             ← dependencias con uv
├── .env                       ← NO commitear
└── app/
    ├── main.py                ← FastAPI factory + lifespan + CORS + routers
    ├── core/
    │   ├── config.py          ← pydantic_settings, get_settings()
    │   ├── database.py        ← AsyncEngine, AsyncSession, get_db()
    │   ├── security.py        ← JWT RS256, bcrypt
    │   ├── exceptions.py      ← excepciones de dominio
    │   ├── logging.py         ← structlog
    │   └── middleware.py      ← request_id, timing
    ├── api/
    │   ├── deps.py            ← get_current_user, require_role
    │   └── v1/
    │       ├── router.py      ← incluye todos los routers
    │       ├── auth.py        ← /auth/login, /auth/refresh
    │       ├── usuarios.py
    │       ├── sucursales.py
    │       ├── auditores.py
    │       └── auditorias.py
    ├── schemas/               ← Pydantic v2 (Base/Create/Update/Out por entidad)
    ├── models/                ← SQLAlchemy ORM (un archivo por entidad)
    ├── repositories/          ← acceso a DB (base.py + específicos)
    └── services/              ← lógica de negocio
```

---

## Comandos de desarrollo

```bash
# Instalar dependencias (desde backend/)
uv sync

# Correr en desarrollo (con recarga automática)
uv run uvicorn app.main:app --reload --port 8000

# Correr tests
uv run pytest -v

# Correr tests con cobertura
uv run pytest --cov=app --cov-report=term-missing

# Verificar tipos y estilo
uv run ruff check app/
uv run mypy app/

# Generar migración Alembic
uv run alembic revision --autogenerate -m "descripción"

# Aplicar migraciones
uv run alembic upgrade head

# Revertir última migración
uv run alembic downgrade -1
```

---

## Dependencias principales (pyproject.toml)

```toml
[project]
name = "auditchain-backend"
version = "0.1.0"
requires-python = ">=3.12"

dependencies = [
    "fastapi>=0.115.0",
    "uvicorn[standard]>=0.30.0",
    "sqlalchemy>=2.0.0",
    "asyncpg>=0.29.0",
    "pydantic>=2.7.0",
    "pydantic-settings>=2.3.0",
    "alembic>=1.13.0",
    "python-jose[cryptography]>=3.3.0",
    "passlib[bcrypt]>=1.7.4",
    "structlog>=24.0.0",
]

[project.optional-dependencies]
dev = [
    "pytest>=8.0.0",
    "pytest-asyncio>=0.23.0",
    "pytest-cov>=5.0.0",
    "httpx>=0.27.0",
    "ruff>=0.4.0",
    "mypy>=1.10.0",
]
```

---

## Reglas de esta capa — NO negociables

1. Todo I/O es `async/await`. Nunca bloquear el event loop.
2. Los endpoints retornan schemas Pydantic, nunca modelos ORM directos.
3. La lógica de negocio va en `services/`, nunca en los routers.
4. Los routers solo llaman a services. Los services llaman a repositories.
5. Config siempre desde `get_settings()`. Nunca hardcodear strings de conexión.
6. Excepciones de dominio en `core/exceptions.py`, mapeadas a HTTP en `api/errors.py`.
7. Todo endpoint nuevo tiene al menos un test en `tests/`.
8. Sin `except Exception` silencioso — siempre loggear y re-raise.

---

## Convenciones de código

```python
# Nombre de archivos: snake_case
# Nombre de clases: PascalCase
# Nombre de funciones/variables: snake_case
# Nombre de constantes: UPPER_SNAKE_CASE

# Router pattern
@router.get("/{id}", response_model=SucursalOut)
async def get_sucursal(
    id: UUID,
    db: AsyncSession = Depends(get_db),
    current_user: Usuario = Depends(get_current_user),
) -> SucursalOut:
    return await sucursal_service.get_by_id(db, id)

# Service pattern
async def get_by_id(db: AsyncSession, id: UUID) -> SucursalOut:
    sucursal = await sucursal_repo.get(db, id)
    if not sucursal:
        raise SucursalNotFoundError(id)
    return SucursalOut.model_validate(sucursal)
```

---

## Qué verificar antes de hacer commit

```bash
uv run ruff check app/          # sin errores de linting
uv run mypy app/                # sin errores de tipos
uv run pytest -v                # todos los tests pasan
# Probar manualmente en http://localhost:8000/docs
```

---

## Referencia rápida de specs

- Arquitectura completa: `docs/AGENT_FASTAPI.md`
- Schema de DB y naming: `docs/AGENT_POSTGRES.md`
- Checklist de PR: `docs/AGENT_REVIEW.md`
