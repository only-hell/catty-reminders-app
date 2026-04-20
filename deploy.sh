#!/bin/bash
set -e

COMMIT_SHA=${1:-$(git rev-parse HEAD)}

if [ ${#COMMIT_SHA} -lt 40 ]; then
    COMMIT_SHA=$(git rev-parse $COMMIT_SHA)
fi

export DEPLOY_REF=$COMMIT_SHA
export IMAGE=ghcr.io/only-hell/catty-reminders-app:$COMMIT_SHA

echo "Deploying with SHA: $DEPLOY_REF"
echo "Image: $IMAGE"

sed -i "s|^DEPLOY_REF=.*|DEPLOY_REF=$COMMIT_SHA|" .env
sed -i "s|^IMAGE=.*|IMAGE=$IMAGE|" .env

docker compose down || true
docker compose pull
docker compose up -d

echo "Waiting for app startup..."
sleep 10
docker compose ps
