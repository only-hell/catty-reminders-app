#!/bin/bash
COMMIT_SHA=$1
# Собираем образ прямо тут, на виртуалке. Нам плевать на GHCR и пароли!
IMAGE="ghcr.io/only-hell/catty-reminders-app:${COMMIT_SHA}"

echo "🚀 Building image locally..."
docker build --build-arg COMMIT_SHA=$COMMIT_SHA -t $IMAGE .
docker tag $IMAGE ghcr.io/only-hell/catty-reminders-app:latest

echo "🧹 Clearing port 8181..."
docker rm -f lab3-app 2>/dev/null || true
sudo fuser -k 8181/tcp 2>/dev/null || true

echo "🚀 Starting container..."
docker run -d --name lab3-app --restart always -p 8181:8181 -e DEPLOY_REF=$COMMIT_SHA $IMAGE

echo "✅ Lab 3 deployed successfully"