#!/bin/bash
echo "🚀 Начинаем деплой Докер-контейнера..."

# 1. Скачиваем свежий образ с Гитхаба (тег lab3)
docker pull ghcr.io/only-hell/catty-reminders-app:lab3

# 2. Останавливаем и удаляем старый контейнер (если он есть)
docker rm -f my-catty-container || true

# 3. Запускаем новый контейнер (с флагом --restart always, как просили в задании)
docker run -d -p 8182:8181 --restart always --name my-catty-container ghcr.io/only-hell/catty-reminders-app:lab3

echo "✅ Деплой успешно завершен!"
