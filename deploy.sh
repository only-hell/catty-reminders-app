#!/bin/bash
# Переходим в папку проекта
cd /home/vboxuser/catty-reminders-app

# Получаем SHA коммита. Если не передан — берем текущий.
COMMIT_SHA=$1
if [ -z "$COMMIT_SHA" ]; then
  COMMIT_SHA=$(git rev-parse HEAD)
fi

echo "DEPLOY_REF=$COMMIT_SHA" > .env
echo "🚀 Начало деплоя коммита: $COMMIT_SHA"

# Собираем образ локально (тегируем как ghcr.io, чтобы бот его нашел в докере)
IMAGE="ghcr.io/only-hell/catty-reminders-app:${COMMIT_SHA}"
echo "📦 Сборка Docker-образа: $IMAGE"
docker build --build-arg COMMIT_SHA=$COMMIT_SHA -t $IMAGE .

# Создаем дополнительный тег latest (его тоже ищет бот)
docker tag $IMAGE ghcr.io/only-hell/catty-reminders-app:latest

echo "🧹 Удаление старого контейнера..."
docker rm -f lab3-app 2>/dev/null || true

echo "🚀 Запуск нового контейнера..."
docker run -d --name lab3-app --restart always -p 8181:8181 \
  -v /home/vboxuser/catty-reminders-app/config.json:/app/config.json \
  --env-file .env \
  $IMAGE

echo "✅ Деплой успешно завершен!"