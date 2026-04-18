#!/bin/bash
set -euo pipefail # Строгий режим: падать при ошибках

# Константы
APP_NAME="catty-reminders-app"
CONTAINER_NAME="lab3-app"
HOST_PORT=8181
GUEST_PORT=8181
PROJECT_DIR="/home/vboxuser/catty-reminders-app"

cd "$PROJECT_DIR"

# Определяем SHA коммита
VERSION=${1:-$(git rev-parse --short HEAD)}
IMAGE_TAG="ghcr.io/only-hell/${APP_NAME}:${VERSION}"

echo "--- 🛠 Starting Deployment: ${VERSION} ---"

# Функция очистки
cleanup_runtime() {
    echo "🧹 Cleaning up port ${HOST_PORT} and old containers..."
    docker rm -f "$CONTAINER_NAME" 2>/dev/null || true
    sudo fuser -k "${HOST_PORT}/tcp" 2>/dev/null || true
}

# Функция сборки
build_image() {
    echo "🏗 Building local Docker image: ${IMAGE_TAG}"
    docker build --build-arg COMMIT_SHA="${VERSION}" -t "${IMAGE_TAG}" .
    docker tag "${IMAGE_TAG}" "ghcr.io/only-hell/${APP_NAME}:latest"
}

# Функция запуска
run_container() {
    echo "🚀 Launching container..."
    docker run -d \
        --name "$CONTAINER_NAME" \
        --restart always \
        -p "${HOST_PORT}:${GUEST_PORT}" \
        -v "${PROJECT_DIR}/config.json:/app/config.json" \
        -e DEPLOY_REF="${VERSION}" \
        "${IMAGE_TAG}"
}

# Основной процесс
cleanup_runtime
build_image
run_container

echo "✅ Deployment finished successfully!"