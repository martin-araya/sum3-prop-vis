# CLAUDE.md — AuditChain (raíz del repo)

> Leído automáticamente por Claude Code en cada sesión.
> Los detalles de cada capa están en auditchain/backend/CLAUDE.md,
> auditchain/frontend/CLAUDE.md y auditchain/db/CLAUDE.md.

---

## Qué es este proyecto

Sistema de auditoría para redes de franquicias. Dos superficies:
- **Web dashboard** → administrador/supervisor → desktop (1366–1920px)
- **App móvil** → auditor de terreno → smartphone

Cuatro entidades de dominio: `Usuarios` → `Sucursales` ← `Auditorías` → `Auditores`

---

## Estructura del repo

```
sum3-prop-vis-develop/
├── CLAUDE.md                  ← estás aquí (contexto global)
├── docs/                      ← specs de referencia, NO editar
│   ├── AGENT_FASTAPI.md
│   ├── AGENT_POSTGRES.md
│   ├── AGENT_FLUTTER.md
│   ├── AGENT_REVIEW.md
│   └── DESIGN_PROPOSAL.md
└── auditchain/
    ├── backend/               ← FastAPI + Python 3.12
    │   └── CLAUDE.md
    ├── frontend/              ← Flutter 3.22+ Web + Mobile
    │   └── CLAUDE.md
    ├── db/                    ← PostgreSQL 16
    │   └── CLAUDE.md
    └── docker-compose.yml
```

---

## Stack tecnológico

| Capa | Tecnología | Puerto |
|---|---|---|
| Base de datos | PostgreSQL 16, schema `auditchain` | 5432 |
| Backend | FastAPI 0.115+, Python 3.12, SQLAlchemy 2.0 async | 8000 |
| Frontend | Flutter 3.22+, Dart 3.4+, Material 3, nginx | 3000 |

---

## Comandos de Docker (ejecutar desde auditchain/)

```bash
# Primera vez
docker-compose up --build

# Siguientes veces
docker-compose up

# Solo la DB (para desarrollo del backend sin Docker completo)
docker-compose up db

# Ver logs de un servicio
docker-compose logs -f backend

# Detener todo y limpiar volúmenes
docker-compose down -v

# Reconstruir solo un servicio
docker-compose up --build backend
```

## URLs en desarrollo

- Frontend:  http://localhost:3000
- API:       http://localhost:8000
- Swagger:   http://localhost:8000/docs
- DB:        localhost:5432 · user=postgres · pass=postgres

---

## Variables de entorno

Crear `auditchain/.env` (NO commitear, está en .gitignore):

```env
DATABASE_URL=postgresql+asyncpg://postgres:postgres@db:5432/auditchain_db
SECRET_KEY=<clave privada RS256 en una línea>
PUBLIC_KEY=<clave pública RS256 en una línea>
ALGORITHM=RS256
ACCESS_TOKEN_EXPIRE_MINUTES=30
REFRESH_TOKEN_EXPIRE_DAYS=7
ENVIRONMENT=development
```

Generar par de claves RS256 (ejecutar una sola vez):
```bash
openssl genrsa -out private.pem 2048
openssl rsa -in private.pem -pubout -out public.pem
# Copiar contenido al .env (reemplazar saltos de línea con \n)
```

---

## Reglas globales — aplican a todas las capas

1. **Idioma del código:** inglés (variables, funciones, clases, métodos)
2. **Idioma del dominio:** español (tablas, columnas, entidades, UI)
3. **Commits semánticos:** `feat(backend): add JWT auth`, `fix(db): enum migration`
4. **Ramas:** `feat/nombre` desde `develop` → PR → `develop` → merge a `main` solo en releases
5. **Archivos prohibidos en git:** `.env`, `*.pem`, `build/`, `__pycache__/`, `.dart_tool/`, `*.pyc`

---

## Flujo de trabajo por capa

Antes de tocar cualquier archivo:
1. Leer el `CLAUDE.md` de la subcarpeta correspondiente
2. Leer el `docs/AGENT_*.md` relevante
3. Verificar que la capa anterior funciona (DB antes de backend, backend antes de frontend)
4. Correr el verificador de esa capa antes de hacer commit

Orden obligatorio de construcción:
```
DB (init.sql) → Backend (FastAPI) → Frontend (Flutter) → Docker Compose
```

---

## Checklist de calidad

Antes de cualquier merge, leer `docs/AGENT_REVIEW.md` completo.
Sin esa revisión, no hacer merge a develop ni a main.
