#!/bin/bash
set -e

DEPLOY_DIR="$HOME/todolist"
DOMAIN="todolist.norugroup.com"
BACKEND_PORT=5671
FRONTEND_PORT=5672

echo "=== Deploy update ==="

cd "$DEPLOY_DIR"
git checkout -- frontend/package-lock.json backend/package-lock.json 2>/dev/null || true
git pull

cd "$DEPLOY_DIR/backend"
npm install --omit=dev

cd "$DEPLOY_DIR/frontend"
npm install
npm run build

pm2 restart todo-backend
pm2 restart todo-frontend

echo ""
echo "=== Deploy selesai ==="
echo "Website: http://$DOMAIN:$FRONTEND_PORT"
