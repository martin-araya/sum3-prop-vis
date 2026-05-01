# 🎨 AGENT.md — Frontend Flutter Web (AuditChain)

> Guía operativa para asistentes de IA y desarrolladores trabajando sobre el frontend Flutter Web del proyecto **AuditChain**. Define arquitectura, convenciones, rendimiento, accesibilidad y criterios de calidad.

---

## 1. Contexto del Proyecto

- **Stack:** Flutter 3.22+ (canal `stable`), Dart 3.4+, Material 3.
- **Target:** Flutter Web (desktop-first, responsive a tablet/móvil).
- **Backend:** FastAPI sobre `http://localhost:8000` (en desarrollo).
- **Audiencia:** administradores y auditores de redes de franquicias.
- **Idioma base:** español (es-CL) con i18n preparado para inglés.
- **Tono visual:** profesional, denso en datos, "enterprise-grade" Material 3.

---

## 2. Filosofía de Trabajo

1. **Componer antes que heredar.** Widgets pequeños y reutilizables; nunca pasar de ~200 líneas en un `build`.
2. **Inmutabilidad por defecto.** `const` donde se pueda, `final` siempre que sea posible, `freezed` para modelos.
3. **Separación estricta UI ↔ estado ↔ datos.** Ninguna llamada HTTP en widgets, nunca.
4. **Tipos fuertes.** Prohibido `dynamic` salvo en parsing controlado. Sin `as` sin chequeo previo.
5. **Performance es feature.** Todo cambio que genere rebuilds innecesarios o jank se considera un bug.
6. **Accesibilidad no es opcional.** Cada widget interactivo tiene `Semantics` o un equivalente.

---

## 3. Arquitectura — Clean Architecture + Feature-First

```text
lib/
├── main.dart
├── app/
│   ├── app.dart                  # MaterialApp.router, theme, locale
│   ├── router/
│   │   └── app_router.dart       # go_router config (rutas tipadas)
│   ├── theme/
│   │   ├── app_theme.dart        # ThemeData light/dark
│   │   ├── app_colors.dart       # ColorScheme tokens
│   │   ├── app_typography.dart   # TextTheme tokens
│   │   └── app_spacing.dart      # 4/8/12/16/24/32/48
│   └── di/
│       └── providers.dart        # Riverpod providers globales
├── core/
│   ├── network/
│   │   ├── dio_client.dart       # Instancia Dio + interceptores
│   │   ├── api_exception.dart
│   │   └── interceptors/         # auth, logging, retry
│   ├── storage/
│   │   └── secure_storage.dart   # flutter_secure_storage wrapper
│   ├── error/
│   │   ├── failure.dart          # sealed class Failure
│   │   └── error_mapper.dart
│   ├── utils/
│   │   ├── result.dart           # Result<T, Failure>
│   │   ├── formatters.dart
│   │   └── validators.dart
│   └── constants/
│       ├── api_paths.dart
│       └── app_constants.dart
├── features/
│   ├── auth/
│   │   ├── data/
│   │   │   ├── datasources/
│   │   │   ├── models/           # DTO + freezed + json_serializable
│   │   │   └── repositories/
│   │   ├── domain/
│   │   │   ├── entities/
│   │   │   ├── repositories/     # Abstracción (interface)
│   │   │   └── usecases/
│   │   └── presentation/
│   │       ├── controllers/      # Riverpod Notifiers
│   │       ├── pages/
│   │       └── widgets/
│   ├── dashboard/
│   ├── branches/
│   ├── auditors/
│   └── audits/
├── shared/
│   ├── widgets/                  # Botones, inputs, cards reutilizables
│   ├── layouts/                  # AppShell, MasterDetail, Responsive
│   └── extensions/
└── l10n/
    ├── app_en.arb
    └── app_es.arb
```

**Regla de oro:** `presentation` puede importar `domain`. `domain` no puede importar `presentation` ni `data`. `data` implementa interfaces de `domain`.

---

## 4. Gestión de Estado — Riverpod 2.x (recomendado)

**Por qué Riverpod y no BLoC ni Provider clásico:**
- Type-safe en compile time, sin `BuildContext` para acceder.
- `AsyncNotifier`/`Notifier` resuelven loading/error/data nativamente.
- Code-gen (`riverpod_generator`) elimina boilerplate.
- Disposal automático con `autoDispose`.

### Patrón estándar para datos remotos

```dart
@riverpod
class BranchesController extends _$BranchesController {
  @override
  Future<List<Branch>> build() async {
    return ref.watch(branchRepositoryProvider).getAll();
  }

  Future<void> refresh() async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(
      () => ref.read(branchRepositoryProvider).getAll(),
    );
  }
}
```

### Reglas
- `ref.watch` en `build`, `ref.read` en callbacks.
- Estado UI efímero (controllers de TextField, expansion state) → `useState` con `flutter_hooks` o `StatefulWidget` local.
- Estado compartido entre features → provider en `app/di/providers.dart`.
- Side-effects (snackbars, navigation) → `ref.listen` dentro del widget.

---

## 5. Routing — `go_router` con rutas tipadas

```dart
@TypedGoRoute<DashboardRoute>(path: '/dashboard')
class DashboardRoute extends GoRouteData {
  const DashboardRoute();
  @override
  Widget build(BuildContext context, GoRouterState state) =>
      const DashboardPage();
}
```

- Shell route para layout persistente (sidebar + topbar).
- Redirects centralizados según `authStateProvider`.
- Deep-linking obligatorio para todas las pantallas (importante en web).
- Nunca `Navigator.push` directo — siempre `context.go(...)` o `context.push(...)` con la ruta tipada.

---

## 6. Cliente HTTP — Dio + Interceptores

```dart
final dio = Dio(BaseOptions(
  baseUrl: AppConstants.apiBaseUrl,
  connectTimeout: const Duration(seconds: 10),
  receiveTimeout: const Duration(seconds: 15),
  headers: {'Content-Type': 'application/json'},
))
  ..interceptors.addAll([
    AuthInterceptor(ref),       // inyecta Bearer token
    RetryInterceptor(maxRetries: 2, retryableStatusCodes: {502, 503, 504}),
    LoggingInterceptor(),       // solo en kDebugMode
  ]);
```

- **Repositorios** retornan `Result<T, Failure>` o lanzan `ApiException` mapeada.
- Cancelación con `CancelToken` en cada request, cancelar en `dispose`.
- Cache HTTP de respuestas estáticas con `dio_cache_interceptor` (e.g., catálogos).
- Nunca exponer `Response<dynamic>` fuera de la capa data.

---

## 7. Material 3 y Theming

- `useMaterial3: true` siempre.
- `ColorScheme.fromSeed(seedColor: AppColors.brandPrimary, brightness: ...)` como base, sobreescribir tokens críticos.
- `ThemeExtension` para tokens custom (e.g., colores de estado de auditoría: completed/pending/overdue).
- Tema oscuro paritario con el claro desde el día uno.
- Componentes con `M3` por defecto: `FilledButton`, `NavigationDrawer`, `NavigationRail`, `SegmentedButton`.

```dart
extension AuditStatusColors on ColorScheme {
  Color get statusCompleted => brightness == Brightness.light
      ? const Color(0xFF10B981) : const Color(0xFF34D399);
  Color get statusPending   => const Color(0xFFF59E0B);
  Color get statusOverdue   => const Color(0xFF94A3B8);
}
```

---

## 8. Diseño Responsive (web-first, mobile-friendly)

Breakpoints (en `app_spacing.dart`):

| Nombre   | Min width | Layout                                           |
|----------|-----------|--------------------------------------------------|
| compact  | 0         | Bottom NavigationBar, drawer modal, 1 columna    |
| medium   | 600       | NavigationRail colapsado, 2 columnas             |
| expanded | 840       | NavigationRail expandido, 3 columnas             |
| large    | 1200      | Sidebar permanente + master-detail, 12-col grid  |

- Usar `LayoutBuilder` o `MediaQuery.sizeOf(context)` (más performante que `MediaQuery.of`).
- Helper `context.isCompact` / `context.isExpanded` vía extensión.
- Imágenes responsivas con `fit: BoxFit.cover` y aspect ratios fijos.
- Tablas → en compact pasan a `ListView` de `Card`s.

---

## 9. Performance — Reglas No Negociables

### Rebuilds
- `const` constructors en todo widget que no dependa de estado: 80%+ del árbol.
- `Selector` / `select` de Riverpod para escuchar solo el slice necesario.
- Extraer subtree estáticos como variables `const` o widgets separados.
- `RepaintBoundary` alrededor de listas con animaciones o widgets costosos.

### Listas
- **Siempre** `ListView.builder` / `GridView.builder`. Nunca `ListView(children: [...])` con N>20.
- `itemExtent` fijo cuando se conoce → habilita scroll instantáneo.
- `cacheExtent` ajustado para minimizar rebuilds en scroll rápido.
- Paginación server-side con `infinite_scroll_pagination` package.

### Imágenes
- `cached_network_image` con `memCacheWidth` proporcional al device pixel ratio.
- Avatares usan `CircleAvatar` con imagen placeholder por iniciales.
- SVG vía `flutter_svg` con `SvgPicture.asset` (cache automático).

### Web-específico
- Compilar con `--web-renderer canvaskit` para apps con muchos charts; `html` si priorizamos peso.
- `flutter build web --release --tree-shake-icons --source-maps=false`.
- Lazy-load de fuentes: `<link rel="preload">` en `web/index.html` para fuente principal.
- Service worker con estrategia `stale-while-revalidate` para assets.
- Code splitting por feature con `deferred as` cuando una feature pese >300KB.

```dart
import 'package:auditchain/features/audits/audits.dart' deferred as audits;

Future<void> openAudits() async {
  await audits.loadLibrary();
  // navegar
}
```

### Frame budget
- 16ms por frame (60fps). Con `flutter run --profile` y DevTools, identificar jank > 16ms.
- Animaciones costosas → `AnimatedBuilder` con `Listenable` específico, no `setState`.

---

## 10. Charts (Dashboard)

- Librería recomendada: **`fl_chart`** (mantenida, customizable, performante).
- Datos siempre vienen de un controller; el widget chart es puro (stateless).
- Animaciones de entrada deshabilitadas si hay >50 puntos.
- Tooltips accesibles vía `Semantics(label: ...)`.

---

## 11. Forms y Validación

- `flutter_hook_form` o controllers manuales con `freezed` para state del form.
- Validación cliente + servidor (nunca confiar solo en cliente).
- Errores por campo desde el backend → mapear `422` a `Map<String, String>`.
- `AutovalidateMode.onUserInteraction`, no `always`.

---

## 12. Accesibilidad (a11y)

- Contraste mínimo **WCAG AA** (4.5:1 texto, 3:1 elementos UI).
- `Semantics(label, hint, button: true)` en cada widget táctil custom.
- Tamaños táctiles ≥ 48x48 lógicos.
- Focus visible en navegación por teclado (web).
- Atajos de teclado en operaciones frecuentes (`Cmd/Ctrl+K` → buscar).
- `MediaQuery.textScalerOf(context)` respetado, hasta 2.0x sin romper layout.

---

## 13. Internacionalización

- `flutter_localizations` + `intl` + ARB files.
- Generación con `flutter gen-l10n` (configurado en `l10n.yaml`).
- Nunca hardcodear strings en widgets — siempre `AppLocalizations.of(context).key`.
- Formato de fechas/números con `intl.DateFormat` y locale activo.

---

## 14. Testing

| Tipo        | Cobertura objetivo | Herramienta                      |
|-------------|--------------------|----------------------------------|
| Unit        | 80% de domain/data | `test`, `mocktail`               |
| Widget      | flujos críticos    | `flutter_test`                   |
| Golden      | componentes UI     | `golden_toolkit` o `alchemist`   |
| Integration | E2E happy path     | `integration_test` + `patrol`    |

- Tests corren en CI en cada PR.
- Mocks via `mocktail` (no `mockito` por code-gen overhead).
- Goldens regenerados solo con flag explícito `--update-goldens`.

---

## 15. Convenciones de Código

- `analysis_options.yaml` con `flutter_lints` + reglas extra:
  - `prefer_const_constructors`, `prefer_const_literals_to_create_immutables`
  - `avoid_dynamic_calls`, `require_trailing_commas`
  - `unawaited_futures`, `discarded_futures`
- `dart format -l 100`.
- Nombres: `UpperCamel` clases, `lowerCamel` métodos/vars, `snake_case` archivos.
- Un widget público por archivo. Privados con `_` en el mismo archivo.
- Comentarios `///` para API pública; `//` para notas.
- TODOs siempre con autor: `// TODO(martin): ...`.

---

## 16. Build & Deploy

```bash
# Dev
flutter run -d chrome --web-port=3000

# Producción
flutter build web --release \
  --web-renderer canvaskit \
  --tree-shake-icons \
  --dart-define=API_BASE_URL=https://api.auditchain.com
```

- Variables sensibles vía `--dart-define` (nunca en código).
- Dockerfile multi-stage: build con SDK, sirve con `nginx:alpine`.
- Headers en nginx: `Cache-Control` largo para assets hasheados, `no-cache` para `index.html`.

---

## 17. Checklist de PR (Frontend)

- [ ] No hay `print` ni `debugPrint` salvo detrás de `kDebugMode`.
- [ ] Widgets nuevos tienen `const` donde aplica.
- [ ] No hay nuevos `setState` en listas — se usa Notifier.
- [ ] Strings nuevos están en `app_es.arb` y `app_en.arb`.
- [ ] Tests unitarios o widget para la lógica añadida.
- [ ] `flutter analyze` sin warnings.
- [ ] Probado en compact, medium y expanded.
- [ ] Probado con tema claro y oscuro.
- [ ] Sin imports relativos cruzando features (usar package imports).

---

## 18. Anti-patrones — NO hacer

- ❌ `FutureBuilder` o `StreamBuilder` con función inline en `build` (se reconstruye el future en cada rebuild).
- ❌ `setState` en pantallas con datos remotos.
- ❌ Acceder a `BuildContext` después de un `await` sin `if (!mounted) return`.
- ❌ Usar `MediaQuery.of(context)` para una sola propiedad — usar `MediaQuery.sizeOf` etc.
- ❌ `Container` cuando `SizedBox`, `Padding` o `DecoratedBox` alcanzan.
- ❌ `Opacity` para animar — usar `FadeTransition`/`AnimatedOpacity`.
- ❌ Listas sin key cuando los items se pueden reordenar.
- ❌ Cargar fuentes desde la red en runtime — incluir en `pubspec.yaml`.

---

## 19. Dependencias Recomendadas (versionar con caret)

```yaml
dependencies:
  flutter_riverpod: ^2.5.0
  riverpod_annotation: ^2.3.0
  go_router: ^14.0.0
  dio: ^5.4.0
  freezed_annotation: ^2.4.0
  json_annotation: ^4.8.0
  intl: ^0.19.0
  flutter_secure_storage: ^9.2.0
  cached_network_image: ^3.3.0
  fl_chart: ^0.68.0
  flutter_svg: ^2.0.0
  flutter_hooks: ^0.20.0
  hooks_riverpod: ^2.5.0

dev_dependencies:
  build_runner: ^2.4.0
  riverpod_generator: ^2.4.0
  freezed: ^2.5.0
  json_serializable: ^6.8.0
  mocktail: ^1.0.0
  golden_toolkit: ^0.15.0
  flutter_lints: ^4.0.0
```

---

## 20. Referencias Permanentes

- Material 3: https://m3.material.io
- Flutter perf best practices: https://docs.flutter.dev/perf/best-practices
- Riverpod docs: https://riverpod.dev
- WCAG 2.2: https://www.w3.org/WAI/WCAG22/quickref/
