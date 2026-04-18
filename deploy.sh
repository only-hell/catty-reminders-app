#!/bin/bash
set -e

IMAGE="$IMAGE_NAME:$RELEASE_HASH"

echo "🚀 Deploying $IMAGE to $DEPLOY_HOST:$DEPLOY_PORT"

ssh -p $DEPLOY_PORT \
    -o StrictHostKeyChecking=no \
    -o ServerAliveInterval=30 \
    $DEPLOY_USER@$DEPLOY_HOST << EOF
set -e

echo "$DOCKER_TOKEN" | docker login ghcr.io -u "$GITHUB_ACTOR" --password-stdin

echo "📦 Pulling image: $IMAGE"
docker pull $IMAGE

echo "🧹 Stopping old container..."
docker stop lab3-app 2>/dev/null || true
docker rm lab3-app 2>/dev/null || true

echo "🚀 Starting new container..."
docker run -d \
  -p 8181:8181 \
  --name lab3-app \
  --restart unless-stopped \
  -e DEPLOY_REF=$RELEASE_HASH \
  $IMAGE

sleep 4

if docker ps | grep -q lab3-app; then
  echo "✅ Deployment successful!"
else
  echo "❌ Container failed to start"
  docker logs lab3-app
  exit 1
fi

echo "🔌 Restarting FRP tunnel..."
sudo systemctl restart frpc || true
EOF