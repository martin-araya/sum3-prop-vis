# Backend — AuditChain

API REST construida con FastAPI. Maneja autenticación JWT y expone endpoints para todos los recursos del sistema.

---

## Tecnologías

| Paquete | Uso |
|--------|-----|
| FastAPI | Framework web asincrónico |
| SQLAlchemy | ORM para PostgreSQL |
| python-jose | Generación y validación de JWT |
| Pydantic | Validación de datos y schemas |
| hashlib SHA-256 | Hashing de contraseñas |

---

## Ejecutar en local (sin Docker)

```bash
cd auditchain/backend
pip install -r requirements.txt

uvicorn main:app --reload --port 8000
```

Requiere PostgreSQL corriendo con las variables configuradas en `docker-compose.yml`.

---

## Endpoints

### Autenticación

| Método | Ruta | Descripción |
|-------|------|-------------|
| POST | `/api/auth/login` | Login, retorna token JWT |
| GET | `/api/auth/me` | Datos del usuario autenticado |

### Recursos

| Recurso | Ruta base |
|--------|----------|
| Usuarios | `/api/usuarios` |
| Sucursales | `/api/sucursales` |
| Auditores | `/api/auditores` |
| Auditorías | `/api/auditorias` |

Documentación interactiva: `http://localhost:8000/docs`

---

## Estructura

```
backend/
├── main.py         # App FastAPI + lifespan (seed automático)
├── models.py       # Modelos SQLAlchemy
├── schemas.py      # Schemas Pydantic
├── database.py     # Conexión a PostgreSQL
├── seed.py         # Datos de prueba (se ejecuta al arrancar)
├── routers/
│   ├── auth.py
│   ├── usuarios.py
│   ├── sucursales.py
│   ├── auditores.py
│   └── auditorias.py
└── Dockerfile
```

---

## Autenticación

El login retorna un token JWT con expiración de 24 horas.  
El token incluye `id`, `email`, `nombre` y `rol` del usuario.

Para autenticar requests incluir el header:
```
Authorization: Bearer <token>
```

---

## Seed automático

Al arrancar, `seed.py` verifica si la base de datos está vacía. Si lo está, crea:

- 2 usuarios (admin + auditor)
- 4 sucursales
- 1 registro de auditor

Esto garantiza que la demo siempre tenga datos funcionales desde el primer arranque.
