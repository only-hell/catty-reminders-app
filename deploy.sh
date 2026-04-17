#!/bin/bash
set -e
cd /home/vboxuser/catty-reminders-app

COMMIT_SHA=$1
GITHUB_ACTOR=$2
GITHUB_TOKEN=$3

if [ -z "$COMMIT_SHA" ]; then
  COMMIT_SHA=$(git rev-parse HEAD)
fi

echo "DEPLOY_REF=$COMMIT_SHA" > .env
IMAGE="ghcr.io/only-hell/catty-reminders-app:${COMMIT_SHA}"

echo "🔐 Logging in to GHCR..."
echo "$GITHUB_TOKEN" | docker login ghcr.io -u "$GITHUB_ACTOR" --password-stdin

echo "📦 Pulling image..."
docker pull $IMAGE

echo "🧹 Cleaning up port 8181..."
docker rm -f lab3-app 2>/dev/null || true
sudo fuser -k 8181/tcp 2>/dev/null || true

echo "🚀 Running container..."
docker run -d --name lab3-app --restart always -p 8181:8181 --env-file .env $IMAGE

echo "✅ Success!"