#!/bin/bash
set -euo pipefail

GIT_REF="${1:-lab2}"
APP_DIR="$HOME/catty-reminders-app"

echo "==> Deploying ref: $GIT_REF"
cd "$APP_DIR"

echo "==> Fetching latest"
git fetch --all --tags --prune

echo "==> Checking out $GIT_REF"
git checkout -f "$GIT_REF"

# Если это ветка — подтянем обновления
if git symbolic-ref -q HEAD > /dev/null; then
  git pull --ff-only
fi

echo "==> Installing dependencies"
python3 -m pip install --user -r requirements.txt

echo "==> Restarting service"
sudo systemctl restart catty-app

echo "==> Waiting for app to come up"
for i in $(seq 1 20); do
  if curl -fsS http://127.0.0.1:8181/login > /dev/null; then
    echo "==> Deploy successful"
    exit 0
  fi
  sleep 1
done

echo "==> App did not respond after restart"
sudo systemctl status catty-app --no-pager
exit 1