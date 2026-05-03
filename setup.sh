#!/bin/bash
set -e

REPO="https://github.com/AndhikaFW/todolist.git"
DEPLOY_DIR="$HOME/homework/todolist"
DOMAIN="todolist.norugroup.com"
DB_NAME="tutam_todos"
DB_USER="postgres"
BACKEND_PORT=5671
FRONTEND_PORT=5672
CURRENT_USER=$(logname 2>/dev/null || whoami)

echo "=== Setup awal server ==="

mkdir -p "$DEPLOY_DIR"

# Clone atau update repo
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

# Buat .env backend jika belum ada
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

# Setup database PostgreSQL (butuh sudo)
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

# Install backend dependencies
echo "--- Install backend dependencies ---"
cd "$DEPLOY_DIR/backend"
npm install --omit=dev

# Build frontend
echo "--- Build frontend ---"
cd "$DEPLOY_DIR/frontend"
npm install
npm run build

# Setup PM2 (tanpa sudo)
echo "--- Setup PM2 ---"
cd "$DEPLOY_DIR/backend"
pm2 delete todo-backend 2>/dev/null || true
pm2 start server.js --name todo-backend

cd "$DEPLOY_DIR/frontend"
pm2 delete todo-frontend 2>/dev/null || true
pm2 start npm --name todo-frontend -- run start -- -H 0.0.0.0

pm2 save

# Setup PM2 startup (bagian ini butuh sudo sekali)
echo ""
echo "--- Setup PM2 startup ---"
pm2 startup | grep "sudo" | bash || true

echo ""
echo "=== Setup selesai ==="
echo "Website: http://$DOMAIN:$FRONTEND_PORT"
