# ── ETAPA 1: Compilar Flutter Web ─────────────────────────────────────────────
FROM ghcr.io/cirruslabs/flutter:stable AS build

WORKDIR /app

# Copiar archivos del proyecto
COPY pubspec.yaml pubspec.lock* ./
RUN flutter pub get

COPY . .

# Compilar para web apuntando al backend Docker
RUN flutter build web --release \
    --dart-define=API_URL=http://localhost:8000/api \
    --dart-define=FLUTTER_WEB_USE_SKIA=true

# ── ETAPA 2: Servir con Nginx ──────────────────────────────────────────────────
FROM nginx:alpine

# Copiar build generado
COPY --from=build /app/build/web /usr/share/nginx/html

# Configuración nginx para Flutter Web (manejo de rutas)
RUN echo 'server { \
    listen 80; \
    location / { \
        root /usr/share/nginx/html; \
        index index.html; \
        try_files $uri $uri/ /index.html; \
    } \
    add_header Access-Control-Allow-Origin *; \
}' > /etc/nginx/conf.d/default.conf

EXPOSE 80
