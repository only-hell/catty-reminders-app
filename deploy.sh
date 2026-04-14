#!/bin/bash
cd /home/vboxuser/catty-reminders-app

COMMIT_SHA=$1
if[ -z "$COMMIT_SHA" ]; then
  COMMIT_SHA=$(git rev-parse HEAD)
fi
echo "DEPLOY_REF=$COMMIT_SHA" > .env

IMAGE="ghcr.io/only-hell/catty-reminders-app:${COMMIT_SHA}"
echo "🚀 Pulling image: $IMAGE"
docker pull $IMAGE

# Убиваем старый контейнер
docker rm -f lab3-app 2>/dev/null || true

# Запускаем новый, пробрасывая файл config.json внутрь
echo "🚀 Starting container..."
docker run -d --name lab3-app --restart always -p 8181:8181 \
  -v /home/vboxuser/catty-reminders-app/config.json:/app/config.json \
  --env-file .env \
  $IMAGE
