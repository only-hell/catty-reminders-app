#!/bin/bash
set -e

COMMIT_SHA=${1:-$(git rev-parse HEAD)}
export DEPLOY_REF=$COMMIT_SHA
export IMAGE=ghcr.io/only-hell/catty-reminders-app:$COMMIT_SHA

echo "🚀 Deploying with SHA: $DEPLOY_REF"
echo "📦 Image: $IMAGE"

docker compose down || true
docker compose pull
docker compose up -d

echo "⏳ Waiting for app startup..."
sleep 10
docker compose ps
