#!/bin/bash
set -euxo pipefail

# --- Update system and install Nginx ---
apt-get update -y
apt-get install -y nginx software-properties-common

# --- Install Certbot ---
add-apt-repository universe -y
apt-get install -y certbot python3-certbot-nginx

# --- Enable and start Nginx ---
systemctl enable nginx
systemctl start nginx

# --- Backup default config ---
mv /etc/nginx/sites-available/default /etc/nginx/sites-available/default.bak || true

# --- Create reverse proxy config ---
cat > /etc/nginx/sites-available/default << 'EOF'
server {
    listen 80;
    server_name api-portal.livingwayapostolics.org;

    location / {
        proxy_pass http://<K8S_NODE_PRIVATE_IP>:<NODEPORT>;
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto $scheme;
    }
}
EOF

# --- Test Nginx config and restart ---
nginx -t
systemctl restart nginx

# --- Allow HTTP traffic in UFW (optional, safe default) ---
ufw allow 'Nginx Full'
ufw --force enable

# --- Obtain SSL certificate from Let's Encrypt ---
certbot --nginx --non-interactive --agree-tos -m hostingblastoise@gmail.com -d api-portal.livingwayapostolics.org

# --- Reload Nginx to apply SSL ---
systemctl reload nginx