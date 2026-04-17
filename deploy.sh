#!/bin/bash
cd /home/vboxuser/catty-reminders-app
COMMIT_SHA=$1
if [ -z "$COMMIT_SHA" ]; then COMMIT_SHA=$(git rev-parse HEAD); fi

# ВАЖНО: Тегируем образ ТАК, как его ищет бот в системе
IMAGE="ghcr.io/only-hell/catty-reminders-app:${COMMIT_SHA}"

echo "🔨 Local build for commit $COMMIT_SHA"
docker build --build-arg COMMIT_SHA=$COMMIT_SHA -t $IMAGE .
docker tag $IMAGE ghcr.io/only-hell/catty-reminders-app:latest

echo "🧹 Cleanup port 8181"
docker rm -f lab3-app 2>/dev/null || true
sudo fuser -k 8181/tcp 2>/dev/null || true

echo "🚀 Starting"
docker run -d --name lab3-app --restart always -p 8181:8181 \
  -v /home/vboxuser/catty-reminders-app/config.json:/app/config.json \
  -e DEPLOY_REF=$COMMIT_SHA $IMAGE