# ================= BUILD STAGE =================
FROM instrumentisto/flutter:3.35.2 AS build

WORKDIR /app

# Кеш зависимостей
COPY pubspec.yaml pubspec.lock* ./
RUN flutter pub get

# Код
COPY . .

# На всякий случай (если web уже есть — не ломает)
RUN flutter create . --platforms web

# КРИТИЧНО: отключаем wasm dry run
RUN flutter build web --release --no-wasm-dry-run

# ================= RUNTIME STAGE =================
FROM python:3.9-slim

WORKDIR /app
COPY --from=build /app/build/web /app

EXPOSE 8080
CMD ["python3", "-m", "http.server", "8080", "--directory", "/app"]
