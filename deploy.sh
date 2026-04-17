#!/bin/bash
cd /home/vboxuser/catty-reminders-app

COMMIT_SHA=$1
GITHUB_ACTOR=$2
GITHUB_TOKEN=$3

if [ -z "$COMMIT_SHA" ]; then
  COMMIT_SHA=$(git rev-parse HEAD)
fi

echo "DEPLOY_REF=$COMMIT_SHA" > .env
IMAGE="ghcr.io/only-hell/catty-reminders-app:${COMMIT_SHA}"

if [ -n "$GITHUB_TOKEN" ]; then
    echo "🔐 Авторизация в GHCR..."
    echo "$GITHUB_TOKEN" | docker login ghcr.io -u "$GITHUB_ACTOR" --password-stdin
fi

echo "🚀 Скачивание образа..."
docker pull $IMAGE

echo "🧹 Удаление старого контейнера..."
docker rm -f lab3-app 2>/dev/null || true

echo "🚀 Запуск нового контейнера..."
docker run -d --name lab3-app --restart always -p 8181:8181 \
  -v /home/vboxuser/catty-reminders-app/config.json:/app/config.json \
  --env-file .env \
  $IMAGE

echo "✅ Деплой успешно завершен!"