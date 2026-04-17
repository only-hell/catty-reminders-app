#!/bin/bash
COMMIT_SHA=$1
if [ -z "$COMMIT_SHA" ]; then
  COMMIT_SHA=$(git rev-parse HEAD)
fi

echo "DEPLOY_REF=$COMMIT_SHA" > .env
IMAGE="ghcr.io/only-hell/catty-reminders-app:${COMMIT_SHA}"

echo "🔨 Building image locally..."
docker build --build-arg COMMIT_SHA=$COMMIT_SHA -t $IMAGE .
docker tag $IMAGE ghcr.io/only-hell/catty-reminders-app:latest

echo "🧹 Clearing port 8181 and old containers..."
docker rm -f lab3-app 2>/dev/null || true
sudo fuser -k 8181/tcp 2>/dev/null || true

echo "🚀 Starting container..."
docker run -d --name lab3-app --restart always -p 8181:8181 \
  -v /home/vboxuser/catty-reminders-app/config.json:/app/config.json \
  --env-file .env $IMAGE

echo "✅ Success! Version $COMMIT_SHA is live."