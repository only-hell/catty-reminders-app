#!/bin/bash
cd /home/vboxuser/catty-reminders-app

COMMIT_SHA=$1
if [ -z "$COMMIT_SHA" ]; then
  COMMIT_SHA=$(git rev-parse HEAD)
fi

echo "DEPLOY_REF=$COMMIT_SHA" > .env
IMAGE="ghcr.io/only-hell/catty-reminders-app:${COMMIT_SHA}"

echo "🚀 Pulling image from GHCR..."
# Цикл скачивания: ждем, пока GitHub дособирает образ в облаке
for i in {1..15}; do
  if docker pull $IMAGE; then
    echo "✅ Image pulled successfully!"
    break
  fi
  echo "⏳ Waiting for GHCR... ($i/15)"
  sleep 10
done

echo "🧹 Removing old container..."
docker rm -f lab3-app 2>/dev/null || true

echo "🚀 Starting new container..."
docker run -d --name lab3-app --restart always -p 8181:8181 \
  -v /home/vboxuser/catty-reminders-app/config.json:/app/config.json \
  --env-file .env \
  $IMAGE