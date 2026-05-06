<div align="center">

# 🔗 AuditChain

### Sistema de Auditorías Digitales

*Gestiona, supervisa y ejecuta auditorías de forma eficiente desde cualquier lugar*

[![Estado](https://img.shields.io/badge/Estado-En%20Desarrollo-yellow?style=for-the-badge)]()
[![Flutter](https://img.shields.io/badge/Flutter-3.x-02569B?style=for-the-badge&logo=flutter&logoColor=white)]()
[![FastAPI](https://img.shields.io/badge/FastAPI-0.100+-009688?style=for-the-badge&logo=fastapi&logoColor=white)]()
[![PostgreSQL](https://img.shields.io/badge/PostgreSQL-15-4169E1?style=for-the-badge&logo=postgresql&logoColor=white)]()

[🔗 Ver Repositorio](https://github.com/martin-araya/sum3-prop-vis) · [📋 Reportar Bug](https://github.com/martin-araya/sum3-prop-vis/issues) · [💡 Solicitar Feature](https://github.com/martin-araya/sum3-prop-vis/issues)

</div>

---

## 📌 Tabla de Contenidos

- [Descripción](#-descripción)
- [Características](#-características)
- [Arquitectura del Sistema](#-arquitectura-del-sistema)
- [Tecnologías](#-tecnologías)
- [Instalación](#-instalación)
- [Uso](#-uso)
- [Estructura del Proyecto](#-estructura-del-proyecto)
- [Equipo](#-equipo)

---

## 📖 Descripción

**AuditChain** es una plataforma de auditoría digital integral que centraliza la gestión, supervisión y ejecución de auditorías organizacionales. La solución combina una aplicación web para administración y análisis con una app móvil para trabajo en terreno, conectadas a través de un backend robusto.

> **Objetivo:** Modernizar el proceso de auditoría reemplazando flujos manuales y en papel por una solución tecnológica que mejore la trazabilidad, el control y la eficiencia operacional de las organizaciones.

---

## ✨ Características

| Módulo | Descripción |
|---|---|
| 🖥️ **Panel Web** | Administración centralizada, visualización de métricas y reportes en tiempo real |
| 📱 **App Móvil** | Ejecución de auditorías en terreno con soporte offline |
| 🔗 **API REST** | Backend desacoplado que conecta todos los componentes de forma segura |
| 📊 **Reportería** | Generación automática de informes y seguimiento de hallazgos |
| 🔒 **Control de Acceso** | Roles diferenciados para auditores, supervisores y administradores |

---

## 🏗️ Arquitectura del Sistema

```
┌─────────────────────────────────────────────────────┐
│                   CLIENTES                           │
│                                                      │
│   ┌──────────────┐         ┌───────────────────┐    │
│   │  Web Admin   │         │   App Móvil       │    │
│   │  (Dashboard) │         │   (Flutter)       │    │
│   └──────┬───────┘         └────────┬──────────┘    │
│          │                          │               │
└──────────┼──────────────────────────┼───────────────┘
           │         REST API         │
┌──────────▼──────────────────────────▼───────────────┐
│                  BACKEND                             │
│              FastAPI + Python                        │
│                                                      │
│   ┌──────────────────────────────────────────────┐  │
│   │               PostgreSQL                     │  │
│   └──────────────────────────────────────────────┘  │
└─────────────────────────────────────────────────────┘
```

### Responsabilidades por capa

- **Web (Administración):** Creación de auditorías, asignación de auditores, visualización de resultados y generación de reportes.
- **Mobile (Terreno):** Ejecución de checklists, captura de evidencia fotográfica y registro de hallazgos en campo.
- **Backend (API):** Autenticación, lógica de negocio, sincronización de datos y exposición de endpoints REST.
- **Base de Datos:** Persistencia de auditorías, usuarios, hallazgos y evidencias.

---

## 🛠️ Tecnologías

### Frontend / Mobile

- **[Flutter](https://flutter.dev/)** — Framework multiplataforma para la aplicación móvil (iOS & Android)

### Backend

- **[FastAPI](https://fastapi.tiangolo.com/)** — Framework web moderno y de alto rendimiento para Python
- **[Python 3.11+](https://www.python.org/)** — Lenguaje base del servidor

### Base de Datos

- **[PostgreSQL 15](https://www.postgresql.org/)** — Sistema de gestión de base de datos relacional

### Herramientas

- **[Docker](https://www.docker.com/)** *(recomendado)* — Contenedores para ambiente de desarrollo consistente
- **[Uvicorn](https://www.uvicorn.org/)** — Servidor ASGI para FastAPI

---

## 🚀 Instalación

### Prerrequisitos

- Python 3.11+
- Flutter SDK 3.x
- PostgreSQL 15
- Git

### 1. Clonar el repositorio

```bash
git clone https://github.com/martin-araya/sum3-prop-vis.git
cd sum3-prop-vis
```

### 2. Configurar el Backend

```bash
# Acceder al directorio del backend
cd backend

# Crear entorno virtual
python -m venv venv
source venv/bin/activate  # En Windows: venv\Scripts\activate

# Instalar dependencias
pip install -r requirements.txt

# Configurar variables de entorno
cp .env.example .env
# Editar .env con tus credenciales de base de datos
```

### 3. Configurar la Base de Datos

```bash
# Crear la base de datos
createdb auditchain_db

# Ejecutar migraciones
alembic upgrade head
```

### 4. Iniciar el Backend

```bash
uvicorn main:app --reload
# API disponible en: http://localhost:8000
# Documentación: http://localhost:8000/docs
```

### 5. Configurar la App Móvil

```bash
cd ../mobile

# Instalar dependencias
flutter pub get

# Ejecutar en emulador o dispositivo
flutter run
```

---

## 💻 Uso

### Acceder a la documentación de la API

Una vez iniciado el servidor, la documentación interactiva estará disponible en:

```
http://localhost:8000/docs       → Swagger UI
http://localhost:8000/redoc      → ReDoc
```

### Flujo principal

1. El **administrador** crea una nueva auditoría desde el panel web y asigna auditores.
2. El **auditor** recibe la asignación en su app móvil y ejecuta los checklists en terreno.
3. Los hallazgos se sincronizan automáticamente con el backend.
4. El **supervisor** revisa resultados y genera reportes desde el panel web.

---

## 📁 Estructura del Proyecto

```
sum3-prop-vis/
├── backend/                # Servidor FastAPI
│   ├── app/
│   │   ├── api/            # Endpoints REST
│   │   ├── models/         # Modelos de base de datos
│   │   ├── schemas/        # Esquemas Pydantic
│   │   └── services/       # Lógica de negocio
│   ├── alembic/            # Migraciones de BD
│   ├── requirements.txt
│   └── main.py
├── mobile/                 # Aplicación Flutter
│   ├── lib/
│   │   ├── screens/        # Pantallas de la app
│   │   ├── widgets/        # Componentes reutilizables
│   │   └── services/       # Comunicación con API
│   └── pubspec.yaml
├── web/                    # Panel de administración web
└── README.md
```

---

## 👥 Equipo

Desarrollado como propuesta de proyecto por:

| Nombre | GitHub |
|---|---|
| **Martin Araya Espinoza** | [@martin-araya](https://github.com/martin-araya) |
| **Yerko Barrera Pantoja** | — |
| **Karol Bermudez Rojas** | — |
| **Bruno Fernandez Pastor** | — |

---

<div align="center">

**AuditChain** · Desarrollado con ❤️ en Chile

</div>
