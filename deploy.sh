#!/bin/bash
cd /home/vboxuser/catty-reminders-app

COMMIT_SHA=$1
if [ -z "$COMMIT_SHA" ]; then
  COMMIT_SHA=$(git rev-parse HEAD)
fi

echo "DEPLOY_REF=$COMMIT_SHA" > .env

# Собираем образ локально с тегом, который ждет бот
IMAGE="ghcr.io/only-hell/catty-reminders-app:${COMMIT_SHA}"
echo "🚀 Building image locally: $IMAGE"
docker build --build-arg COMMIT_SHA=$COMMIT_SHA -t $IMAGE .
docker tag $IMAGE ghcr.io/only-hell/catty-reminders-app:latest

# Полная очистка порта 8181
echo "🧹 Cleaning up..."
docker rm -f lab3-app 2>/dev/null || true
sudo fuser -k 8181/tcp 2>/dev/null || true

# Запуск
echo "🚀 Starting container..."
docker run -d --name lab3-app --restart always -p 8181:8181 --env-file .env $IMAGE