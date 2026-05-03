#!/bin/bash
set -e

DEPLOY_DIR="/var/www/todolist"
DOMAIN="todolist.norugroup.com"
BACKEND_PORT=5671
FRONTEND_PORT=5672

echo "=== Deploy update ==="

cd "$DEPLOY_DIR"
git pull

cd "$DEPLOY_DIR/backend"
npm install --omit=dev

cd "$DEPLOY_DIR/frontend"
npm install
NEXT_PUBLIC_API_URL="http://$DOMAIN:$BACKEND_PORT/api" npm run build

pm2 restart todo-backend
pm2 restart todo-frontend

echo ""
echo "=== Deploy selesai ==="
echo "Website: http://$DOMAIN:$FRONTEND_PORT"
