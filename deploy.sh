#!/bin/bash
export IMAGE_TAG=${1:-lab4-clean}
echo "Deploying version: $IMAGE_TAG"
docker compose down
docker compose up -d
