#!/bin/bash
# =============================================================
# deploy-tencent.sh
# Script deploy otomatis ke Tencent Cloud VPS (CVM/Lighthouse)
# Jalankan dari komputer/laptop lokal kamu
# =============================================================

# ── KONFIGURASI — edit bagian ini ─────────────────────────────
SERVER_IP="your.tencent.server.ip"
SERVER_USER="root"              # atau ubuntu / lighthouse
SSH_KEY="~/.ssh/id_rsa"         # path SSH key kamu
REMOTE_DIR="/var/www/asyura-quality-tracker"
DOMAIN="your-domain.com"
# ──────────────────────────────────────────────────────────────

set -e
echo ""
echo "╔══════════════════════════════════════════╗"
echo "║   Asyura Quality Tracker — Deploying...  ║"
echo "╚══════════════════════════════════════════╝"
echo ""

# 1. Upload files
echo "📤 Upload files ke server..."
ssh -i $SSH_KEY $SERVER_USER@$SERVER_IP "mkdir -p $REMOTE_DIR"
scp -i $SSH_KEY index.html        $SERVER_USER@$SERVER_IP:$REMOTE_DIR/
scp -i $SSH_KEY nginx.conf        $SERVER_USER@$SERVER_IP:/tmp/asyura-nginx.conf

# 2. Setup Nginx di server
echo "⚙️  Setup Nginx di server..."
ssh -i $SSH_KEY $SERVER_USER@$SERVER_IP << ENDSSH
  if ! command -v nginx &> /dev/null; then
    echo "Installing Nginx..."
    apt update -q && apt install -y nginx
  fi

  cp /tmp/asyura-nginx.conf /etc/nginx/sites-available/asyura-quality-tracker

  if [ ! -L /etc/nginx/sites-enabled/asyura-quality-tracker ]; then
    ln -s /etc/nginx/sites-available/asyura-quality-tracker \
          /etc/nginx/sites-enabled/asyura-quality-tracker
  fi

  rm -f /etc/nginx/sites-enabled/default
  chown -R www-data:www-data $REMOTE_DIR
  chmod -R 755 $REMOTE_DIR

  nginx -t && systemctl reload nginx
  echo "Nginx OK!"
ENDSSH

echo ""
echo "✅ Deploy selesai!"
echo "   Akses: http://$SERVER_IP"
echo ""
echo "─── SSL gratis dengan Let's Encrypt ───────────────"
echo "   Jalankan di server:"
echo "   apt install certbot python3-certbot-nginx -y"
echo "   certbot --nginx -d $DOMAIN -d www.$DOMAIN"
echo "────────────────────────────────────────────────────"
echo ""
