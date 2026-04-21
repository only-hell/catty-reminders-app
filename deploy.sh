#!/bin/bash
set -e

SHA=$1
if [ -z "$SHA" ]; then
  echo "Usage: $0 <sha>"
  exit 1
fi

REPO_OWNER=$(echo "$GITHUB_REPOSITORY_OWNER" 2>/dev/null || echo "only-hell")
IMAGE="ghcr.io/only-hell/catty-reminders-app:${SHA}"

echo "Deploying with SHA: $SHA"
echo "Image: $IMAGE"

# Логин в ghcr.io если переданы credentials
if [ -n "$GHCR_TOKEN" ] && [ -n "$GHCR_USER" ]; then
  echo "$GHCR_TOKEN" | docker login ghcr.io -u "$GHCR_USER" --password-stdin
fi

# Обновляем .env
sed -i "s|^DEPLOY_REF=.*|DEPLOY_REF=${SHA}|" .env
sed -i "s|^IMAGE=.*|IMAGE=${IMAGE}|" .env

# Деплой
docker compose pull
docker compose up -d --remove-orphans
