#!/bin/bash
set -e

REPO="https://github.com/AndhikaFW/todolist.git"
DEPLOY_DIR="/var/www/todolist"
DOMAIN="todolist.norugroup.com"
DB_NAME="tutam_todos"
DB_USER="postgres"
BACKEND_PORT=5000

echo "=== Setup awal server ==="

# Clone atau update repo
if [ -d "$DEPLOY_DIR/.git" ]; then
  echo "--- Update repo ---"
  cd "$DEPLOY_DIR"
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

# Setup database PostgreSQL
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
VITE_API_URL="http://$DOMAIN/api" npm run build

# Setup PM2
echo "--- Setup PM2 ---"
cd "$DEPLOY_DIR/backend"
pm2 delete todo-backend 2>/dev/null || true
pm2 start server.js --name todo-backend
pm2 save
pm2 startup | tail -1 | bash 2>/dev/null || true

# Setup Nginx
echo "--- Setup Nginx ---"
cat > /etc/nginx/sites-available/todolist <<EOF
server {
    listen 80;
    server_name $DOMAIN;

    root $DEPLOY_DIR/frontend/dist;
    index index.html;

    location / {
        try_files \$uri \$uri/ /index.html;
    }

    location /api {
        proxy_pass http://localhost:$BACKEND_PORT;
        proxy_http_version 1.1;
        proxy_set_header Host \$host;
        proxy_set_header X-Real-IP \$remote_addr;
    }
}
EOF

ln -sf /etc/nginx/sites-available/todolist /etc/nginx/sites-enabled/todolist
nginx -t && systemctl reload nginx

echo ""
echo "=== Setup selesai ==="
echo "Website: http://$DOMAIN"
