# App Móvil — AuditChain

Aplicación Android para auditores en terreno. Desarrollada en Flutter.

---

## Pantallas

| Pantalla | Descripción |
|---------|-------------|
| Login | Autenticación con email y contraseña, JWT almacenado localmente |
| Dashboard | KPIs del auditor, gráfico de estado, próximas auditorías |
| Historial | Lista de auditorías con filtros por estado |
| Nueva Auditoría | Wizard de 4 pasos: sucursal → fecha/auditor → checklist → confirmación |
| Evidencias | Galería de evidencias con toggle lista/grid |
| Reporte | Detalle completo de una auditoría con puntaje y checklist |

---

## Obtener el APK

El APK se compila automáticamente en cada push mediante GitHub Actions.

1. Ir a la pestaña **Actions** del repositorio en GitHub
2. Seleccionar el último workflow completado
3. Descargar el artefacto `apk-debug`
4. Instalar en el dispositivo (requiere habilitar "fuentes desconocidas")

---

## Ejecutar en local

```bash
cd auditchain/mobile
flutter pub get

# Emulador
flutter run

# Dispositivo físico (reemplazar IP por la de la máquina que corre el backend)
flutter run --dart-define=API_URL=http://192.168.1.X:8000/api
```

El backend debe estar corriendo antes de ejecutar la app.

---

## Estructura

```
mobile/lib/
├── main.dart
├── core/
│   ├── network/
│   │   ├── dio_client.dart     # Cliente HTTP + gestión de JWT
│   │   └── api_routes.dart     # URLs de la API
│   └── router/
│       └── app_router.dart     # Rutas nombradas
├── features/
│   ├── auth/                   # Login
│   ├── dashboard/              # Pantalla principal del auditor
│   ├── auditorias/             # Historial, nueva auditoría y reporte
│   ├── evidencias/             # Galería de evidencias
│   └── profile/                # Perfil y configuración
└── shared/
    ├── models/
    ├── utils/
    └── widgets/                # Bottom nav
```

---

## Navegación

Bottom nav de 4 tabs con `IndexedStack` para mantener estado entre pantallas:

| Tab | Pantalla |
|----|---------|
| Home | Dashboard del auditor |
| Audits | Historial de auditorías |
| Nueva | Nueva auditoría (wizard) |
| Perfil | Perfil, preferencias y cerrar sesión |

---

## Diseño

- Colores: azul marino `#1E3A8A`, fondo oscuro `#0A2540`, cian `#06B6D4`
- Tipografía: Inter (texto), JetBrains Mono (puntajes)
- Logo de AuditChain en pantalla de login
- `android:usesCleartextTraffic="true"` habilitado para HTTP local (demo)
