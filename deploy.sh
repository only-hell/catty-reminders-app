#!/bin/bash
export IMAGE_TAG=${1:-lab4-clean}
echo "Deploying image with tag: $IMAGE_TAG"
docker compose down
docker compose up -d
