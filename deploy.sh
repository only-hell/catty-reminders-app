#!/bin/bash
set -e

DEPLOY_SHA=$1
if [ -z "$DEPLOY_SHA" ]; then
  echo "Error: SHA not provided"; exit 1
fi

IMAGE="ghcr.io/only-hell/catty-reminders-app:${DEPLOY_SHA}"
echo "Deploying SHA: ${DEPLOY_SHA}"
echo "Image: ${IMAGE}"

cd ~/catty-reminders-app

echo "${GHCR_TOKEN}" | docker login ghcr.io -u "${GHCR_USER}" --password-stdin

sed -i "s|^IMAGE=.*|IMAGE=${IMAGE}|" .env
sed -i "s|^DEPLOY_REF=.*|DEPLOY_REF=${DEPLOY_SHA}|" .env

docker pull "${IMAGE}"
docker compose down --remove-orphans
docker compose up -d

echo "✅ Deploy finished"
docker compose ps
