#!/bin/bash
set -e

DEPLOY_SHA=$1

if [ -z "$DEPLOY_SHA" ]; then
  echo "Error: SHA not provided"
  exit 1
fi

export IMAGE="ghcr.io/only-hell/catty-reminders-app:${DEPLOY_SHA}"
export DEPLOY_REF="${DEPLOY_SHA}"

echo "Deploying with SHA: ${DEPLOY_SHA}"
echo "Image: ${IMAGE}"

# Login to GHCR
echo "${GHCR_TOKEN}" | docker login ghcr.io -u "${GHCR_USER}" --password-stdin

# Deploy
docker compose down
docker compose pull
docker compose up -d
