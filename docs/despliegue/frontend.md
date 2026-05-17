# Panel Web — AuditChain

Panel administrativo web para gestión de auditorías. Desarrollado en Flutter Web.

---

## Pantallas

| Módulo | Descripción |
|-------|-------------|
| Dashboard | KPIs generales, gráficos de estado y resumen de auditorías |
| Sucursales | Lista de sucursales con puntaje promedio y estado |
| Auditores | Gestión del equipo de auditores |
| Auditorías | Historial completo con filtros por estado |
| Usuarios | Administración de cuentas del sistema |
| Reportes | Exportación de datos en CSV |

---

## Ejecutar con Docker (recomendado)

```bash
cd auditchain
docker-compose up --build
```

Panel disponible en: `http://localhost:3000`

---

## Ejecutar en local

```bash
cd auditchain/frontend
flutter pub get
flutter run -d chrome
```

La URL del backend se configura en `lib/services/api_service.dart`.  
Por defecto apunta a `http://localhost:8000/api`.

---

## Estructura

```
frontend/lib/
├── main.dart
├── app.dart
├── models/
├── services/
├── screens/
│   ├── home_screen.dart       # Sidebar + navegación principal
│   ├── dashboard_screen.dart
│   ├── sucursales_screen.dart
│   ├── auditores_screen.dart
│   ├── auditorias_screen.dart
│   ├── usuarios_screen.dart
│   └── reportes_screen.dart
└── widgets/
```

---

## Diseño

- Colores: azul marino `#1E3A8A`, fondo oscuro `#0A2540`, cian `#06B6D4`
- Tipografía: Inter (texto), JetBrains Mono (valores numéricos)
- Layout: sidebar fijo en desktop, bottom nav en pantallas pequeñas
- Logo de AuditChain integrado en la barra lateral
