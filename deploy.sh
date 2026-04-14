#!/bin/bash
cd /home/vboxuser/catty-reminders-app

COMMIT_SHA=$1
if[ -z "$COMMIT_SHA" ]; then
  COMMIT_SHA=$(git rev-parse HEAD)
fi
echo "DEPLOY_REF=$COMMIT_SHA" > .env

IMAGE="ghcr.io/only-hell/catty-reminders-app:${COMMIT_SHA}"
echo "🚀 Waiting for image $IMAGE to be published in GHCR..."

# Умный цикл: пытаемся скачать образ раз в 15 секунд (максимум 5 минут)
for i in {1..20}; do
  if docker pull $IMAGE; then
    echo "✅ Image pulled successfully!"
    break
  fi
  echo "⏳ Image not found yet, waiting 15 seconds... ($i/20)"
  sleep 15
done

# Удаляем старый контейнер
docker rm -f lab3-app 2>/dev/null || true

# Запускаем новый
echo "🚀 Starting container..."
docker run -d --name lab3-app --restart always -p 8181:8181 \
  -v /home/vboxuser/catty-reminders-app/config.json:/app/config.json \
  --env-file .env \
  $IMAGE