# Despliegue del Sistema — AuditChain

## Requisitos

- Docker Desktop instalado y corriendo

---

## Levantar todo el sistema

```bash
cd auditchain
docker-compose up --build
```

La primera vez tarda ~5 minutos porque compila Flutter Web.  
Las siguientes veces sin `--build` es más rápido.

Esperar hasta ver:
```
auditchain_backend | INFO: Application startup complete.
```

### URLs

| Servicio | URL |
|---------|-----|
| Panel web (Flutter) | http://localhost:3000 |
| API backend | http://localhost:8000 |
| Documentación Swagger | http://localhost:8000/docs |

### Credenciales de prueba

| Email | Contraseña | Rol |
|------|-----------|-----|
| admin@auditchain.cl | Admin1234 | Administrador |
| auditor@auditchain.cl | Auditor1234 | Auditor |

---

## Detener el sistema

```bash
docker-compose down
```

Para limpiar la base de datos también (reinicia desde cero):

```bash
docker-compose down -v
```

---

## Arquitectura del despliegue

```
[Flutter Web]  ──┐
                 ├── REST API ──> [FastAPI] ──> [PostgreSQL]
[Flutter APK]  ──┘
```

- nginx actúa como reverse proxy: `/api` → backend, `/` → web
- El backend siembra datos automáticamente al arrancar (`seed.py`)
- La base de datos se inicializa con `db/init.sql` en el primer arranque

---

## Estructura de contenedores

| Contenedor | Imagen | Puerto |
|-----------|-------|--------|
| auditchain_db | postgres:16 | 5432 |
| auditchain_backend | python:3.11 | 8000 |
| auditchain_frontend | nginx | 3000 |
