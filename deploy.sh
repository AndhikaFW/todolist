#!/bin/bash
set -e

DEPLOY_DIR="/var/www/todolist"
DOMAIN="todolist.norugroup.com"

echo "=== Deploy update ==="

cd "$DEPLOY_DIR"
git pull

cd "$DEPLOY_DIR/backend"
npm install --omit=dev

cd "$DEPLOY_DIR/frontend"
npm install
VITE_API_URL="http://$DOMAIN/api" npm run build

pm2 restart todo-backend

echo ""
echo "=== Deploy selesai ==="
echo "Website: http://$DOMAIN"
