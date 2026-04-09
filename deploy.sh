#!/bin/bash
# Если передан аргумент (SHA коммита), используем его. Иначе по умолчанию lab3.
TAG=${1:-lab3}
IMAGE="ghcr.io/only-hell/catty-reminders-app"

echo "🚀 Начинаем деплой Докер-контейнера с тегом $TAG..."

docker pull $IMAGE:$TAG
docker rm -f my-catty-container || true

# Пробрасываем SHA как переменную окружения, чтобы сайт знал свою версию
docker run -d -p 8182:8181 --restart always -e DEPLOY_REF=$TAG -e COMMIT_SHA=$TAG --name my-catty-container $IMAGE:$TAG

echo "✅ Деплой успешно завершен!"
