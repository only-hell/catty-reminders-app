#!/bin/bash
cd /home/vboxuser/catty-reminders-app

COMMIT_SHA=$1
if [ -z "$COMMIT_SHA" ]; then
  COMMIT_SHA=$(git rev-parse HEAD)
fi

echo "DEPLOY_REF=$COMMIT_SHA" > .env
echo "🚀 Деплой коммита: $COMMIT_SHA (Lab 2)"

# Перезапускаем системную службу
sudo systemctl restart catty-app

echo "✅ Деплой успешно завершен!"
