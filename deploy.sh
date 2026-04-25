#!/usr/bin/env bash
set -euo pipefail

REF="${1:-}"
APP_DIR="$HOME/catty-reminders-app"
VENV="$APP_DIR/.venv"

cd "$APP_DIR"

echo "==> Fetch all refs"
git fetch --all --tags --prune --force

if [ -n "$REF" ]; then
  echo "==> Checkout ref: $REF"
  if git rev-parse --verify "refs/tags/$REF" >/dev/null 2>&1; then
    git checkout -f "refs/tags/$REF"
  elif git rev-parse --verify "$REF" >/dev/null 2>&1; then
    git checkout -f "$REF"
  else
    git checkout -f "origin/$REF"
  fi
fi

echo "==> Resolve deployed SHA"
DEPLOY_SHA="$(git rev-parse HEAD)"
echo "    HEAD = $DEPLOY_SHA"

echo "==> Ensure venv"
if [ ! -x "$VENV/bin/python" ]; then
  python3 -m venv "$VENV"
fi
"$VENV/bin/pip" install --upgrade pip >/dev/null
"$VENV/bin/pip" install -r requirements.txt

echo "==> Write .env with DEPLOY_REF"
echo "DEPLOY_REF=$DEPLOY_SHA" > "$APP_DIR/.env"

echo "==> Restart service"
sudo /usr/bin/systemctl restart catty-app

echo "==> Healthcheck"
for i in 1 2 3 4 5 6 7 8 9 10 11 12 13 14 15; do
  if curl -fsS http://127.0.0.1:8181/login >/dev/null; then
    echo "    OK on try $i"
    break
  fi
  echo "    waiting... ($i)"
  sleep 2
done

echo "==> Verify deployref in HTML"
HTML_REF="$(curl -fsS http://127.0.0.1:8181/login | grep -oE 'name="deployref" content="[^"]+"' | sed -E 's/.*content="([^"]+)".*/\1/')"
echo "    HTML deployref = $HTML_REF"
if [ "$HTML_REF" != "$DEPLOY_SHA" ]; then
  echo "ERROR: deployref mismatch (expected $DEPLOY_SHA, got $HTML_REF)" >&2
  exit 1
fi

echo "==> Deploy OK"
