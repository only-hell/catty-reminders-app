#!/bin/bash
export IMAGE_TAG=${1:-lab4-clean}
docker compose down
docker compose up -d
