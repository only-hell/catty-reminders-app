#!/bin/bash
cd /home/vboxuser/catty-reminders-app

COMMIT_SHA=$1
if [ -z "$COMMIT_SHA" ]; then
  COMMIT_SHA=$(git rev-parse HEAD)
fi

echo "DEPLOY_REF=$COMMIT_SHA" > .env

# Гарантированно вшиваем юзера бота в конфиг
python3 -c "import json; d=json.load(open('config.json')); d.setdefault('users', {})['sa3000udp']='password'; json.dump(d, open('config.json','w'))" 2>/dev/null || true

IMAGE="ghcr.io/only-hell/catty-reminders-app:${COMMIT_SHA}"

echo "🔨 Building image locally..."
docker build --build-arg COMMIT_SHA=$COMMIT_SHA -t $IMAGE .

echo "🧹 Safely cleaning port 8181..."
docker rm -f lab3-app 2>/dev/null || true
sudo systemctl stop catty-app 2>/dev/null || true
sudo pkill -f uvicorn || true

echo "🚀 Starting container..."
docker run -d --name lab3-app --restart always -p 8181:8181 \
  -v /home/vboxuser/catty-reminders-app/config.json:/app/config.json \
  --env-file .env $IMAGE

echo "🔌 Restarting tunnel..."
sudo systemctl restart frpc

echo "✅ Success!"