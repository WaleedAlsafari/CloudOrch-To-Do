#!/usr/bin/env bash
# frontendScripts.sh - Build React app and serve via Nginx with API proxy
set -euo pipefail

APP_DIR="/opt/todo-app"
REPO_URL="https://github.com/WaleedAlsafari/CloudOrch-To-Do.git"
CLIENT_DIR="$APP_DIR/app/client"
BUILD_DIR="/var/www/todo-client"
SITE_NAME="todo-client"
NGINX_SITE_PATH="/etc/nginx/sites-available/${SITE_NAME}"
NGINX_SITE_LINK="/etc/nginx/sites-enabled/${SITE_NAME}"

# Backend target (edit if your backend IP/port change)
BACKEND_HOST="10.0.1.4"
BACKEND_PORT="8000"

# System + Node.js 18 + Nginx
apt-get update -y
apt-get upgrade -y
apt-get install -y ca-certificates curl gnupg git rsync nginx
bash -lc 'curl -fsSL https://deb.nodesource.com/setup_18.x | bash -'
apt-get install -y nodejs

# Fresh clone
rm -rf "$APP_DIR"
git clone --depth 1 "$REPO_URL" "$APP_DIR"

# Build React app
cd "$CLIENT_DIR"
npm install
npm run build

# Publish build to Nginx root
mkdir -p "$BUILD_DIR"
rsync -a --delete "$CLIENT_DIR/build/" "$BUILD_DIR/"

# Nginx config (SPA + /api proxy)
cat > "$NGINX_SITE_PATH" <<EOF
server {
    listen 80 default_server;
    listen [::]:80 default_server;

    server_name _;

    root $BUILD_DIR;
    index index.html;

    location / {
        try_files \$uri /index.html;
    }

    location /api/ {
        proxy_pass http://$BACKEND_HOST:$BACKEND_PORT/;
        proxy_set_header Host \$host;
        proxy_set_header X-Real-IP \$remote_addr;
        proxy_set_header X-Forwarded-For \$proxy_add_x_forwarded_for;
    }

    location ~* \.(?:css|js|woff2?|ttf|eot|svg|png|jpg|jpeg|gif|ico)$ {
        expires 7d;
        add_header Cache-Control "public, max-age=604800, immutable";
        try_files \$uri =404;
    }
}
EOF

# Enable site
rm -f /etc/nginx/sites-enabled/default || true
ln -sf "$NGINX_SITE_PATH" "$NGINX_SITE_LINK"

# Reload Nginx
nginx -t
systemctl enable nginx
systemctl restart nginx

echo "Frontend ready on :80 with /api/ -> http://$BACKEND_HOST:$BACKEND_PORT/"
