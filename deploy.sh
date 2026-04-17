#!/bin/bash
cd /home/vboxuser/catty-reminders-app

COMMIT_SHA=$1
if [ -z "$COMMIT_SHA" ]; then
  COMMIT_SHA=$(git rev-parse HEAD)
fi

echo "DEPLOY_REF=$COMMIT_SHA" > .env

# Собираем образ прямо на месте. Бот увидит его в списке docker images.
IMAGE="ghcr.io/only-hell/catty-reminders-app:${COMMIT_SHA}"
docker build --build-arg COMMIT_SHA=$COMMIT_SHA -t $IMAGE .
docker tag $IMAGE ghcr.io/only-hell/catty-reminders-app:latest

# Перезапуск контейнера
docker rm -f lab3-app 2>/dev/null || true
docker run -d --name lab3-app --restart always -p 8181:8181 --env-file .env $IMAGE