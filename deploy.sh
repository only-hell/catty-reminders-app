#!/bin/bash
cd /home/vboxuser/catty-reminders-app

COMMIT_SHA=$1
if [ -z "$COMMIT_SHA" ]; then
  COMMIT_SHA=$(git rev-parse HEAD)
fi
echo "DEPLOY_REF=$COMMIT_SHA" > .env

# Собираем образ локально прямо сейчас, и даем ему нужное имя!
IMAGE="ghcr.io/only-hell/catty-reminders-app:${COMMIT_SHA}"
echo "🚀 Building image locally as $IMAGE..."
docker build --build-arg COMMIT_SHA=$COMMIT_SHA -t $IMAGE .

# Даем образу еще один тег, который иногда ищет бот
docker tag $IMAGE ghcr.io/only-hell/catty-reminders-app:latest

# Удаляем старый контейнер
docker rm -f lab3-app 2>/dev/null || true

# Запускаем новый
echo "🚀 Starting container..."
docker run -d --name lab3-app --restart always -p 8181:8181 \
  -v /home/vboxuser/catty-reminders-app/config.json:/app/config.json \
  --env-file .env \
  $IMAGE
