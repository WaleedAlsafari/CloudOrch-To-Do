#!/usr/bin/env bash
set -euo pipefail

APP_DIR="/opt/todo-app"
SERVER_DIR="$APP_DIR/app/server"
SERVICE_NAME="todo-backend.service"

# System + Node.js 18 + tools
apt-get update -y
apt-get upgrade -y
apt-get install -y ca-certificates curl gnupg git
bash -lc 'curl -fsSL https://deb.nodesource.com/setup_18.x | bash -'
apt-get install -y nodejs

# Fresh clone (keep it simple)
rm -rf "$APP_DIR"
git clone --depth 1 "https://github.com/WaleedAlsafari/CloudOrch-To-Do.git" "$APP_DIR"

# .env for backend
mkdir -p "$SERVER_DIR"
cat > "$SERVER_DIR/.env" <<'EOF'
DB_HOST=10.0.2.4
DB_PORT=5432
DB_USER=admin
DB_PASSWORD=Admin123@
DB_NAME=todoapp
EOF
chmod 600 "$SERVER_DIR/.env"

# Install deps
cd "$SERVER_DIR"
npm install

# start wrapper
cat > "$SERVER_DIR/start-backend.sh" <<'EOF'
#!/usr/bin/env bash
set -euo pipefail
cd "$(dirname "$0")"
exec npm run server
EOF
chmod +x "$SERVER_DIR/start-backend.sh"

# systemd unit
cat > "/etc/systemd/system/$SERVICE_NAME" <<EOF
[Unit]
Description=ToDo Backend Service
After=network-online.target

[Service]
WorkingDirectory=$SERVER_DIR
EnvironmentFile=$SERVER_DIR/.env
ExecStart=$SERVER_DIR/start-backend.sh
Restart=always
RestartSec=5

[Install]
WantedBy=multi-user.target
EOF

systemctl daemon-reload
systemctl enable "$SERVICE_NAME"
systemctl restart "$SERVICE_NAME"
