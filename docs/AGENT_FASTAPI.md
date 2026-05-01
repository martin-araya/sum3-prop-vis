# ⚙️ AGENT.md — Backend FastAPI (AuditChain)

> Guía operativa para el backend del proyecto **AuditChain**: arquitectura, patrones, rendimiento, seguridad y convenciones que deben seguirse en cada cambio de código.

---

## 1. Contexto del Proyecto

- **Stack:** Python 3.12+, FastAPI 0.115+, SQLAlchemy 2.0 (async), Pydantic v2, Alembic, PostgreSQL 16.
- **Servidor ASGI:** `uvicorn` en dev, `gunicorn` con `uvicorn.workers.UvicornWorker` en producción.
- **Gestor de paquetes:** `uv` (preferido) o `poetry`. Nunca `pip install` directo en producción.
- **Idioma del dominio:** español (entidades en español: `Sucursal`, `Auditor`, `Auditoria`).
- **Idioma del código:** inglés (clases, métodos, variables); SOLO los modelos de dominio mantienen nombres en español por consistencia con DB.
- **Auth:** JWT (RS256) con refresh tokens; roles: `admin`, `auditor`.

---

## 2. Filosofía de Trabajo

1. **Async-first.** Cada handler, cada acceso a I/O, asíncrono. Bloquear el event loop es un bug.
2. **Capas explícitas.** Router → Service → Repository → Model. Cada capa tiene una sola responsabilidad.
3. **Schemas ≠ Models.** Pydantic para fronteras; SQLAlchemy para persistencia. Nunca devolver un modelo ORM directo desde un endpoint.
4. **Validación en la frontera.** Pydantic valida entrada y salida. Si pasa la frontera, está limpio.
5. **Errores tipados.** Excepciones de dominio explícitas mapeadas a HTTP, nunca `except Exception` silencioso.
6. **Observabilidad por defecto.** Logs estructurados, métricas y tracing desde el día uno.
7. **Tests acompañan al PR.** Sin tests ≈ sin merge.

---

## 3. Arquitectura — Capas + Bounded Contexts

```text
backend/
├── app/
│   ├── main.py                      # FastAPI app factory
│   ├── core/
│   │   ├── config.py                # Settings (pydantic_settings)
│   │   ├── security.py              # JWT, password hashing
│   │   ├── database.py              # AsyncEngine, AsyncSession factory
│   │   ├── logging.py               # structlog config
│   │   ├── exceptions.py            # Domain exceptions
│   │   └── middleware.py            # request_id, timing, CORS
│   ├── api/
│   │   ├── deps.py                  # Dependencias compartidas
│   │   ├── errors.py                # Exception handlers
│   │   └── v1/
│   │       ├── router.py            # Agrega los routers
│   │       ├── auth.py
│   │       ├── usuarios.py
│   │       ├── sucursales.py
│   │       ├── auditores.py
│   │       └── auditorias.py
│   ├── schemas/                     # Pydantic v2
│   │   ├── base.py
│   │   ├── auth.py
│   │   ├── usuario.py
│   │   ├── sucursal.py
│   │   ├── auditor.py
│   │   ├── auditoria.py
│   │   └── pagination.py
│   ├── models/                      # SQLAlchemy ORM
│   │   ├── base.py
│   │   ├── usuario.py
│   │   ├── sucursal.py
│   │   ├── auditor.py
│   │   └── auditoria.py
│   ├── repositories/                # Acceso a DB
│   │   ├── base.py                  # CRUD genérico
│   │   ├── usuario_repo.py
│   │   ├── sucursal_repo.py
│   │   ├── auditor_repo.py
│   │   └── auditoria_repo.py
│   ├── services/                    # Lógica de negocio
│   │   ├── auth_service.py
│   │   ├── sucursal_service.py
│   │   └── auditoria_service.py
│   ├── workers/                     # Tareas async (opcional)
│   │   └── tasks.py                 # arq / dramatiq / celery
│   └── utils/
│       ├── pagination.py
│       └── validators.py
├── alembic/
│   ├── env.py
│   └── versions/
├── tests/
│   ├── conftest.py
│   ├── unit/
│   ├── integration/
│   └── e2e/
├── pyproject.toml
├── alembic.ini
├── Dockerfile
└── docker-compose.yml
```

**Reglas de dependencias entre capas:**

```text
api  →  services  →  repositories  →  models
       ↓
    schemas (todas las capas pueden leer schemas)
```

- `api/` no llama a repositorios directamente.
- `services/` no devuelve modelos ORM al exterior; devuelve schemas o entidades planas.
- `repositories/` no contienen lógica de negocio.

---

## 4. Configuración — `pydantic_settings`

```python
class Settings(BaseSettings):
    model_config = SettingsConfigDict(
        env_file=".env", env_file_encoding="utf-8", extra="ignore"
    )
    APP_ENV: Literal["dev", "staging", "prod"] = "dev"
    DEBUG: bool = False

    DATABASE_URL: PostgresDsn
    DB_POOL_SIZE: int = 20
    DB_MAX_OVERFLOW: int = 10
    DB_POOL_TIMEOUT: int = 30
    DB_POOL_RECYCLE: int = 1800

    JWT_PRIVATE_KEY: SecretStr
    JWT_PUBLIC_KEY: str
    JWT_ALGORITHM: Literal["RS256"] = "RS256"
    JWT_ACCESS_EXPIRE_MIN: int = 15
    JWT_REFRESH_EXPIRE_DAYS: int = 7

    CORS_ORIGINS: list[AnyHttpUrl] = []
    REDIS_URL: RedisDsn | None = None
    LOG_LEVEL: str = "INFO"

@lru_cache
def get_settings() -> Settings:
    return Settings()
```

- Secretos **nunca** hardcoded ni en repo. `.env` solo en local; producción usa secret manager.
- `Settings` es singleton vía `lru_cache`.

---

## 5. App Factory + Lifespan

```python
@asynccontextmanager
async def lifespan(app: FastAPI):
    # startup
    await init_db_pool()
    await connect_redis()
    yield
    # shutdown
    await dispose_db_pool()
    await disconnect_redis()

def create_app() -> FastAPI:
    settings = get_settings()
    app = FastAPI(
        title="AuditChain API",
        version="1.0.0",
        lifespan=lifespan,
        docs_url="/docs" if settings.DEBUG else None,
        redoc_url=None,
        openapi_url="/openapi.json" if settings.DEBUG else None,
        default_response_class=ORJSONResponse,
    )
    register_middleware(app)
    register_exception_handlers(app)
    app.include_router(api_v1_router, prefix="/api/v1")
    return app

app = create_app()
```

- `ORJSONResponse` (vía `orjson`) por defecto: 2-3x más rápido que JSON estándar.
- Docs deshabilitadas en producción salvo decisión explícita.

---

## 6. Base de Datos — SQLAlchemy 2.0 Async

```python
engine = create_async_engine(
    str(settings.DATABASE_URL),
    pool_size=settings.DB_POOL_SIZE,
    max_overflow=settings.DB_MAX_OVERFLOW,
    pool_timeout=settings.DB_POOL_TIMEOUT,
    pool_recycle=settings.DB_POOL_RECYCLE,
    pool_pre_ping=True,        # detecta conexiones muertas
    echo=settings.DEBUG,
)

AsyncSessionFactory = async_sessionmaker(
    engine, class_=AsyncSession, expire_on_commit=False, autoflush=False,
)

async def get_session() -> AsyncIterator[AsyncSession]:
    async with AsyncSessionFactory() as session:
        try:
            yield session
            await session.commit()
        except Exception:
            await session.rollback()
            raise
```

### Modelos — estilo declarativo 2.0

```python
class Base(DeclarativeBase):
    metadata = MetaData(naming_convention={
        "ix": "ix_%(column_0_label)s",
        "uq": "uq_%(table_name)s_%(column_0_name)s",
        "fk": "fk_%(table_name)s_%(column_0_name)s_%(referred_table_name)s",
        "pk": "pk_%(table_name)s",
        "ck": "ck_%(table_name)s_%(constraint_name)s",
    })

class Sucursal(Base):
    __tablename__ = "sucursales"
    id: Mapped[UUID] = mapped_column(primary_key=True, server_default=func.gen_random_uuid())
    nombre: Mapped[str] = mapped_column(String(120), nullable=False)
    region: Mapped[str] = mapped_column(String(50), index=True)
    puntaje_promedio: Mapped[Decimal | None] = mapped_column(Numeric(5, 2))
    creado_en: Mapped[datetime] = mapped_column(server_default=func.now())
    actualizado_en: Mapped[datetime] = mapped_column(server_default=func.now(), onupdate=func.now())

    auditorias: Mapped[list["Auditoria"]] = relationship(back_populates="sucursal", lazy="raise")
```

- `lazy="raise"` por defecto en relaciones — fuerza el uso explícito de `selectinload`/`joinedload`. Evita N+1 silencioso.
- Tipos `Mapped[...]` siempre. No usar el estilo viejo `Column(...)`.
- IDs UUID v4 generados en DB (`gen_random_uuid()`).

### Repositorios

```python
class BaseRepository[T: Base]:
    model: type[T]

    def __init__(self, session: AsyncSession):
        self.session = session

    async def get(self, id: UUID) -> T | None:
        return await self.session.get(self.model, id)

    async def list(self, *, limit: int, offset: int, **filters) -> list[T]:
        stmt = select(self.model).filter_by(**filters).limit(limit).offset(offset)
        result = await self.session.execute(stmt)
        return list(result.scalars().all())

    async def add(self, instance: T) -> T:
        self.session.add(instance)
        await self.session.flush()
        return instance
```

- Sin `select(*)` salvo en repos genéricos; preferir `select(Model.col1, Model.col2)` cuando sirve.
- Eager loading explícito: `selectinload(Sucursal.auditorias)`.

---

## 7. Schemas — Pydantic v2

```python
class SucursalBase(BaseModel):
    model_config = ConfigDict(from_attributes=True, str_strip_whitespace=True)
    nombre: Annotated[str, Field(min_length=2, max_length=120)]
    region: Annotated[str, Field(min_length=2, max_length=50)]

class SucursalCreate(SucursalBase): pass

class SucursalUpdate(BaseModel):
    nombre: Annotated[str | None, Field(default=None, min_length=2, max_length=120)]
    region: Annotated[str | None, Field(default=None, min_length=2, max_length=50)]

class SucursalRead(SucursalBase):
    id: UUID
    puntaje_promedio: Decimal | None
    creado_en: datetime
```

- **Tres schemas por entidad:** `Create`, `Update` (todos los campos opcionales), `Read`.
- Validadores custom con `@field_validator` o `@model_validator(mode="after")`.
- `Annotated[..., Field(...)]` en lugar de `Field(...)` en default — más limpio con tipo.
- **NUNCA** mezclar Schema de input y output en un mismo modelo.

---

## 8. Routers — Convenciones

```python
router = APIRouter(prefix="/sucursales", tags=["sucursales"])

@router.get("", response_model=Page[SucursalRead])
async def list_sucursales(
    pagination: PaginationParams = Depends(),
    region: str | None = None,
    service: SucursalService = Depends(get_sucursal_service),
    _: User = Depends(require_roles("admin", "auditor")),
) -> Page[SucursalRead]:
    return await service.list(pagination, region=region)

@router.post("", response_model=SucursalRead, status_code=201)
async def create_sucursal(
    payload: SucursalCreate,
    service: SucursalService = Depends(get_sucursal_service),
    _: User = Depends(require_roles("admin")),
) -> SucursalRead:
    return await service.create(payload)
```

- Un router por entidad, prefix definido en el router.
- `response_model` siempre.
- `status_code` explícito en `POST` (201), `DELETE` (204).
- Verbos REST: `GET`, `POST`, `PATCH` (no `PUT` salvo replace), `DELETE`.
- Paginación uniforme: `?limit=&offset=` o cursor; nunca mezclar.

---

## 9. Autenticación y Autorización

### JWT (RS256)
- Access token: 15 min. Refresh token: 7 días, almacenado server-side (Redis) revocable.
- Claims: `sub` (user id), `role`, `iat`, `exp`, `jti` (para revocación).
- `python-jose[cryptography]` o `pyjwt[crypto]`.

### Password
- `passlib[argon2]` — argon2id, no bcrypt para nuevos sistemas.
- `time_cost=3, memory_cost=64MB, parallelism=4` como base.

### Dependencias
```python
async def get_current_user(
    credentials: HTTPAuthorizationCredentials = Depends(bearer_scheme),
    session: AsyncSession = Depends(get_session),
) -> User:
    ...

def require_roles(*roles: str):
    async def dep(user: User = Depends(get_current_user)) -> User:
        if user.rol not in roles:
            raise HTTPException(403, "Forbidden")
        return user
    return dep
```

### CORS
- Origins explícitos por env. Nunca `["*"]` con credentials.
- `allow_credentials=True` solo si se usan cookies (no si todo es Bearer).

### Otras prácticas
- Rate limiting con `slowapi` o reverse proxy (`nginx`/`traefik`).
- Headers de seguridad: `X-Content-Type-Options`, `X-Frame-Options`, `Strict-Transport-Security`, `Content-Security-Policy`.
- Idempotency keys en `POST`s sensibles (creación de auditorías).

---

## 10. Manejo de Errores

```python
class DomainError(Exception):
    code: str = "domain_error"
    status: int = 400
    def __init__(self, message: str, **ctx): ...

class NotFound(DomainError):
    code = "not_found"; status = 404

class Conflict(DomainError):
    code = "conflict"; status = 409

@app.exception_handler(DomainError)
async def domain_handler(_: Request, exc: DomainError):
    return ORJSONResponse(
        status_code=exc.status,
        content={"error": {"code": exc.code, "message": str(exc), "context": exc.ctx}},
    )
```

- Errores de validación de Pydantic ya devuelven 422; mapear `detail` a un formato unificado.
- **Nunca** `print(e)` en handler — usar `logger.exception(...)`.
- Trazas completas solo en logs; respuesta al cliente con `code` + `message` legible.

---

## 11. Performance

### Async correcto
- I/O **siempre** `await`. Una función `async` que llama a `requests.get(...)` bloquea TODO el worker.
- Para CPU-bound: `await asyncio.to_thread(...)` o `ProcessPoolExecutor`.
- Para HTTP externo: `httpx.AsyncClient` reusado vía dependencia (no crear cliente por request).

### Conexiones
- Pool dimensionado: `pool_size = workers * concurrent_requests / target_db_connections`.
- `pool_pre_ping=True` para entornos con balanceadores que cierran conexiones.
- Para read-heavy, considerar `read_engine` separado apuntando a réplica.

### Serialización
- `orjson` (~3x más rápido que `json` stdlib).
- En endpoints con payloads grandes, paginar o usar streaming (`StreamingResponse`).

### Caching
- Redis para:
  - Catálogos casi-estáticos (regiones, roles)
  - Resultados de dashboard agregados (TTL 60-300s)
  - Tokens revocados (jti)
- Patrón `cache-aside`: leer cache → si miss, leer DB y poblar cache.
- Invalidación explícita en mutaciones (`POST`/`PATCH`/`DELETE`).

### Background jobs
- `arq` (Redis-based, async-native) para tareas como cálculo masivo de puntajes, notificaciones email, exports.
- Nunca hacer `BackgroundTasks` para algo que dura >5s.

### Endpoint de dashboard
- **Una sola query agregada** con `GROUP BY` y `FILTER (WHERE ...)`, no N queries por métrica.
- Resultado cacheado.

```python
# Bien
SELECT
  COUNT(*) AS total,
  COUNT(*) FILTER (WHERE estado = 'pendiente') AS pendientes,
  AVG(puntaje) AS promedio
FROM auditorias
WHERE creado_en >= now() - interval '30 days';
```

---

## 12. Logging y Observabilidad

- **Logger:** `structlog` con render JSON en producción, color en dev.
- **Correlation ID:** middleware que genera `request_id` (uuid4) y lo propaga en logs.
- **Métricas:** `prometheus-fastapi-instrumentator` expone `/metrics`.
- **Tracing:** OpenTelemetry con exporter OTLP cuando haya plataforma (Jaeger/Tempo/Datadog).
- **Logs prohibidos:** passwords, tokens, payloads completos con datos personales.

```python
logger = structlog.get_logger()
logger.info("auditoria.created", auditoria_id=str(a.id), sucursal_id=str(a.sucursal_id))
```

---

## 13. Migrations — Alembic

- `alembic revision --autogenerate -m "<descriptive>"` y **revisar manualmente** antes de aplicar.
- Migraciones de datos en archivos separados de migraciones de schema.
- Cambios destructivos en dos pasos: agregar columna nueva → backfill → eliminar antigua.
- Naming: `2026_04_30_1530-add_estado_auditoria_index.py`.
- Nunca editar una migración ya aplicada en otro entorno; crear una nueva.

---

## 14. Testing

| Tipo        | Carpeta              | Herramientas                        |
|-------------|----------------------|-------------------------------------|
| Unit        | `tests/unit/`        | `pytest`, `pytest-asyncio`          |
| Integration | `tests/integration/` | `pytest`, `testcontainers` (postgres)|
| E2E         | `tests/e2e/`         | `httpx.AsyncClient` contra app real |

```python
@pytest.fixture
async def client(app):
    async with AsyncClient(transport=ASGITransport(app=app), base_url="http://test") as c:
        yield c
```

- Cada test crea su transacción y la revierte (no `truncate` global).
- Factory pattern para crear modelos: `factory_boy` o helpers manuales.
- Cobertura objetivo: 80% global, 95% en `services/` y `core/security`.
- `pytest -n auto` con `pytest-xdist`.

---

## 15. Estilo de Código

- **Linter/formatter:** `ruff` (formato + lint + isort en uno).
- **Type checker:** `mypy --strict` en `app/`. Cero `# type: ignore` salvo justificado.
- **Pre-commit:** ruff, mypy, alembic check, tests rápidos.
- **Naming:**
  - Funciones/vars: `snake_case`.
  - Clases: `PascalCase`.
  - Constantes: `UPPER_SNAKE`.
  - Privados: `_prefix`.
- **Imports:** ordenados (`stdlib`, `third-party`, `first-party`); absolutos siempre dentro de `app/`.
- **Docstrings:** Google-style en clases y funciones públicas.

---

## 16. Dockerfile (multi-stage)

```dockerfile
FROM python:3.12-slim AS builder
ENV PYTHONDONTWRITEBYTECODE=1 PYTHONUNBUFFERED=1
WORKDIR /app
RUN pip install --no-cache-dir uv
COPY pyproject.toml uv.lock ./
RUN uv sync --frozen --no-dev

FROM python:3.12-slim
WORKDIR /app
RUN useradd --create-home --shell /bin/bash app
COPY --from=builder /app/.venv /app/.venv
COPY --chown=app:app . .
ENV PATH="/app/.venv/bin:$PATH"
USER app
EXPOSE 8000
CMD ["gunicorn", "app.main:app", \
     "-k", "uvicorn.workers.UvicornWorker", \
     "-w", "4", "-b", "0.0.0.0:8000", \
     "--access-logfile", "-", "--error-logfile", "-"]
```

- Imagen final < 200MB.
- Workers = `2 * cores + 1` como punto de partida.
- `--preload` solo si la app es read-heavy y no usa fork-unsafe state.

---

## 17. Checklist de PR (Backend)

- [ ] Endpoint nuevo tiene `response_model` y schemas separados Create/Update/Read.
- [ ] Nueva query no genera N+1 (probar con `echo=True` o logs SQL).
- [ ] Migración Alembic incluida si hay cambio de schema.
- [ ] Tests cubren happy path + 1 error case mínimo.
- [ ] No hay `time.sleep` ni I/O síncrono en código async.
- [ ] Endpoint sensible tiene `Depends(require_roles(...))`.
- [ ] Logs nuevos no exponen información sensible.
- [ ] `mypy --strict` pasa.
- [ ] `ruff check && ruff format --check` pasa.
- [ ] OpenAPI generado se ve bien en `/docs`.

---

## 18. Anti-patrones — NO hacer

- ❌ `def` (síncrono) en un endpoint async — bloquea el loop.
- ❌ `Session` de SQLAlchemy síncrono mezclado con async.
- ❌ Devolver objetos ORM directamente desde el endpoint.
- ❌ `try: ... except: pass` sin log.
- ❌ Crear `httpx.AsyncClient()` por request — reusar en lifespan.
- ❌ Lógica de negocio en `repositories/`.
- ❌ Cargar relaciones con `lazy="select"` por defecto (N+1 garantizado).
- ❌ Concatenar SQL: usar siempre parámetros (`text(":id")`).
- ❌ `assert` para validación (los `assert` se eliminan con `python -O`).
- ❌ Variables globales mutables fuera de `lifespan`.

---

## 19. Dependencias Principales (`pyproject.toml`)

```toml
[project]
dependencies = [
  "fastapi>=0.115",
  "uvicorn[standard]>=0.30",
  "gunicorn>=22",
  "sqlalchemy[asyncio]>=2.0",
  "asyncpg>=0.29",
  "alembic>=1.13",
  "pydantic>=2.7",
  "pydantic-settings>=2.3",
  "passlib[argon2]>=1.7",
  "python-jose[cryptography]>=3.3",
  "orjson>=3.10",
  "httpx>=0.27",
  "structlog>=24",
  "redis>=5.0",
  "arq>=0.26",
  "prometheus-fastapi-instrumentator>=7.0",
]

[tool.ruff]
line-length = 100
target-version = "py312"

[tool.mypy]
python_version = "3.12"
strict = true
plugins = ["pydantic.mypy"]
```

---

## 20. Referencias Permanentes

- FastAPI: https://fastapi.tiangolo.com
- SQLAlchemy 2.0: https://docs.sqlalchemy.org/en/20/
- Pydantic v2: https://docs.pydantic.dev/latest/
- OWASP API Security Top 10: https://owasp.org/API-Security/
- 12-Factor App: https://12factor.net
