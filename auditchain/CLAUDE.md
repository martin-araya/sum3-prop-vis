# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

> Leído automáticamente en cada sesión. Contexto específico del directorio `auditchain/`.
> El contexto global del repo está en `../CLAUDE.md`.
> Detalles de cada capa en `backend/CLAUDE.md`, `frontend/CLAUDE.md`, `db/CLAUDE.md`.

---

## Docker — levantar todo junto

```bash
# Desde auditchain/ — primera vez (o tras cambios en Dockerfile / init.sql)
docker-compose up --build

# Siguientes veces
docker-compose up

# Ver logs en tiempo real de un servicio
docker-compose logs -f backend

# Reconstruir solo el backend (ej. tras cambiar dependencias)
docker-compose up --build backend

# Limpiar todo incluyendo volumen de DB
docker-compose down -v
```

URLs expuestas:
- Frontend (Flutter Web): http://localhost:3000
- API (FastAPI):           http://localhost:8000
- Swagger UI:              http://localhost:8000/docs
- DB (acceso externo):     localhost:5433 (host) → 5432 (container)

---

## Prerequisito: crear `backend/.env`

Antes del primer `docker-compose up` hay que crear `backend/.env` desde el ejemplo:

```bash
cp backend/.env.example backend/.env
```

Luego rellenar `SECRET_KEY` y `PUBLIC_KEY` con un par RS256:

```bash
openssl genrsa -out private.pem 2048
openssl rsa -in private.pem -pubout -out public.pem
# Copiar el contenido al .env reemplazando saltos de línea con \n
```

`backend/.env` **no se commitea** (está en `.gitignore`).

---

## Arquitectura Docker

```
docker-compose.yml
├── db          postgres:16-alpine · init.sql + seed.sql auto-ejecutados
├── backend     python:3.12-slim + uv · uvicorn app.main:app :8000
└── frontend    flutter:stable → build web → nginx:alpine :80 (→ host :3000)
```

**Proxy de nginx** (dentro del contenedor `frontend`):
- `GET /api/*` → proxy a `http://backend:8000` (Docker DNS interno)
- Todo lo demás → SPA Flutter (`/usr/share/nginx/html`, `try_files … /index.html`)

El Flutter web se compila con `--dart-define=API_URL=/api`, por lo que todas las llamadas HTTP van a rutas relativas `/api/v1/...` y el proxy las redirige al backend sin exponer el puerto 8000 al browser.

---

## Rutas de la API

Todas las rutas de negocio tienen prefijo `/api/v1`:

| Recurso | Prefijo |
|---|---|
| Auth | `/api/v1/auth` |
| Usuarios | `/api/v1/usuarios` |
| Sucursales | `/api/v1/sucursales` |
| Auditores | `/api/v1/auditores` |
| Auditorías | `/api/v1/auditorias` |

Health check sin prefijo: `GET /health`

---

## Decisiones de diseño no obvias

- **`postgresql+asyncpg://`** en `DATABASE_URL` — SQLAlchemy 2.0 async requiere este driver; `postgresql://` usa psycopg2 síncrono y rompe el event loop de FastAPI.
- **Puerto 5433** en el host para la DB — evita conflicto si hay un PostgreSQL local en 5432.
- **`env_file: ./backend/.env`** en docker-compose sobrescrito por `environment:` — permite tener las claves RS256 en `.env` local mientras que `DATABASE_URL` se fuerza al valor correcto para Docker (host `db`, no `localhost`).
- **Volumen `./backend:/app`** en modo dev — permite hot-reload con `--reload`; en producción se eliminaría este volumen.
