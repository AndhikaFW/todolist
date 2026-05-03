#!/bin/bash
set -e

REPO="https://github.com/AndhikaFW/todolist.git"
DEPLOY_DIR="/var/www/todolist"
DOMAIN="todolist.norugroup.com"
DB_NAME="tutam_todos"
DB_USER="postgres"
BACKEND_PORT=5671
FRONTEND_PORT=5672

echo "=== Setup awal server ==="

if [ -d "$DEPLOY_DIR/.git" ]; then
  echo "--- Update repo ---"
  cd "$DEPLOY_DIR"
  git checkout -- frontend/package-lock.json backend/package-lock.json 2>/dev/null || true
  git pull
else
  echo "--- Clone repo ---"
  git clone "$REPO" "$DEPLOY_DIR"
  cd "$DEPLOY_DIR"
fi

if [ ! -f "$DEPLOY_DIR/backend/.env" ]; then
  cat > "$DEPLOY_DIR/backend/.env" <<EOF
DB_HOST=localhost
DB_PORT=5432
DB_USER=$DB_USER
DB_PASSWORD=
DB_NAME=$DB_NAME
PORT=$BACKEND_PORT
EOF
  echo ""
  echo "File .env dibuat. Isi DB_PASSWORD terlebih dahulu:"
  echo "  nano $DEPLOY_DIR/backend/.env"
  echo "Lalu jalankan script ini lagi."
  exit 0
fi

echo "--- Setup database PostgreSQL ---"
sudo -u postgres psql -tc "SELECT 1 FROM pg_database WHERE datname = '$DB_NAME'" \
  | grep -q 1 || sudo -u postgres psql -c "CREATE DATABASE $DB_NAME;"

sudo -u postgres psql -d "$DB_NAME" -c "
CREATE TABLE IF NOT EXISTS todos (
    id          SERIAL          PRIMARY KEY,
    title       VARCHAR(255)    NOT NULL,
    description TEXT,
    completed   BOOLEAN         NOT NULL DEFAULT FALSE,
    created_at  TIMESTAMPTZ     NOT NULL DEFAULT NOW()
);
CREATE INDEX IF NOT EXISTS idx_todos_created_at ON todos (created_at DESC);
"

echo "--- Install backend dependencies ---"
cd "$DEPLOY_DIR/backend"
npm install --omit=dev

echo "--- Build frontend ---"
cd "$DEPLOY_DIR/frontend"
npm install
NEXT_PUBLIC_API_URL="http://$DOMAIN:$BACKEND_PORT/api" npm run build

echo "--- Setup PM2 ---"
cd "$DEPLOY_DIR/backend"
pm2 delete todo-backend 2>/dev/null || true
pm2 start server.js --name todo-backend

cd "$DEPLOY_DIR/frontend"
pm2 delete todo-frontend 2>/dev/null || true
pm2 start npm --name todo-frontend -- run start

pm2 save
pm2 startup | tail -1 | bash 2>/dev/null || true

echo ""
echo "=== Setup selesai ==="
echo "Website: http://$DOMAIN:$FRONTEND_PORT"
