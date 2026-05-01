# AuditChain — Sistema de Auditoría para Franquicias

## Requisitos
- Docker Desktop instalado y corriendo

## Cómo ejecutar el proyecto

### 1. Abrir una terminal en esta carpeta

### 2. Ejecutar el siguiente comando:
```
docker-compose up --build
```

La primera vez tarda ~5 minutos porque compila Flutter Web.
Las siguientes veces sin `--build` es mucho más rápido.

Esperar a que aparezca:
```
auditchain_backend | INFO: Application startup complete.
```

### 3. Abrir en el navegador:
- **Frontend Flutter Web:** http://localhost:3000
- **API Backend:**          http://localhost:8000
- **Documentación API:**    http://localhost:8000/docs

## Estructura del proyecto
```
auditchain/
├── docker-compose.yml      ← Levanta todo con un comando
├── db/
│   └── init.sql            ← Base de datos PostgreSQL
├── backend/
│   ├── main.py             ← API FastAPI
│   ├── models.py           ← Modelos
│   ├── schemas.py          ← Validaciones
│   ├── database.py         ← Conexión BD
│   ├── routers/            ← CRUD por entidad
│   └── Dockerfile
└── frontend/               ← Flutter Web
    ├── lib/
    │   ├── main.dart
    │   ├── models/
    │   ├── services/
    │   ├── screens/
    │   └── widgets/
    └── Dockerfile          ← Compila Flutter y sirve con Nginx
```

## Arquitectura
- **Capa de datos:** PostgreSQL 16
- **Capa de negocio:** FastAPI + Python (API REST)
- **Capa de presentación:** Flutter Web
- **Patrón:** N-Capas + MVC

## Detener el proyecto
```
docker-compose down
```

