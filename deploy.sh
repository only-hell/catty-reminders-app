#!/bin/bash
# Забираем тег из аргумента или используем дефолт
IMAGE_TAG=${1:-lab4-clean}

echo "Starting deployment for tag: $IMAGE_TAG"

# Останавливаем старье, если оно есть
docker compose down

# Поднимаем новые контейнеры
docker compose up -d

echo "Deployment finished!"
docker ps
