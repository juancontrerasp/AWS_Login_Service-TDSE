#!/bin/bash
# ========================================
# Frontend Deployment Script (Nginx)
# Domain: securitytdse.duckdns.org
# Simple and reliable!
# ========================================

set -e

echo "🚀 Deploying Frontend with Nginx"
echo "================================="

GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

DOMAIN="securitytdse.duckdns.org"
CERT_PATH="/etc/letsencrypt/live/${DOMAIN}"

# Step 1: Install Docker
echo -e "\n${GREEN}[1/5]${NC} Installing Docker..."
if ! command -v docker &> /dev/null; then
    sudo yum install -y docker
    sudo systemctl start docker
    sudo systemctl enable docker
    sudo usermod -aG docker $USER
    echo -e "${YELLOW}Docker installed. May need to re-login.${NC}"
else
    echo "✓ Docker already installed"
fi

# Step 2: Install Docker Compose
echo -e "\n${GREEN}[2/5]${NC} Installing Docker Compose..."
if ! command -v docker-compose &> /dev/null; then
    sudo curl -L "https://github.com/docker/compose/releases/latest/download/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose
    sudo chmod +x /usr/local/bin/docker-compose
    echo "✓ Docker Compose installed"
else
    echo "✓ Docker Compose already installed"
fi

# Step 3: Install Certbot
echo -e "\n${GREEN}[3/5]${NC} Installing Certbot..."
if ! command -v certbot &> /dev/null; then
    sudo yum install -y certbot
    echo "✓ Certbot installed"
else
    echo "✓ Certbot already installed"
fi

# Step 4: Get SSL Certificate
echo -e "\n${GREEN}[4/5]${NC} Getting SSL Certificate..."
if [ -d "${CERT_PATH}" ]; then
    echo "✓ Certificate already exists for ${DOMAIN}"
    sudo ls -la ${CERT_PATH}
else
    echo "Getting new certificate..."
    docker compose down 2>/dev/null || true
    sudo systemctl stop httpd 2>/dev/null || true
    sudo fuser -k 80/tcp 2>/dev/null || true
    
    sudo certbot certonly --standalone -d ${DOMAIN} --non-interactive --agree-tos --email admin@${DOMAIN}
    
    if [ -d "${CERT_PATH}" ]; then
        echo -e "${GREEN}✓ Certificate obtained!${NC}"
    else
        echo "Warning: Certificate might not be obtained. Check DNS."
    fi
fi

# Step 5: Deploy with Nginx
echo -e "\n${GREEN}[5/5]${NC} Starting Nginx frontend..."

# Stop any old services
docker compose down 2>/dev/null || true
docker compose -f docker-compose-nginx.yml down 2>/dev/null || true

# Start Nginx
docker compose -f docker-compose-nginx.yml up -d

echo ""
echo "Waiting for Nginx to start..."
sleep 10

# Check status
docker compose -f docker-compose-nginx.yml ps

echo ""
echo "Testing frontend..."
if curl -k -s -I https://localhost 2>/dev/null | grep -q "200\|301\|302"; then
    echo -e "${GREEN}✓ Frontend is responding!${NC}"
elif curl -k -s -I https://${DOMAIN} 2>/dev/null | grep -q "200\|301\|302"; then
    echo -e "${GREEN}✓ Frontend is responding!${NC}"
else
    echo -e "${YELLOW}Service started. Check logs if needed:${NC}"
    echo "  docker compose -f docker-compose-nginx.yml logs -f"
fi

# Setup auto-renewal
echo ""
echo "Setting up certificate auto-renewal..."
CRON_JOB="0 0,12 * * * certbot renew --quiet && docker compose -f $(pwd)/docker-compose-nginx.yml restart nginx-frontend"
(sudo crontab -l 2>/dev/null | grep -v "certbot renew"; echo "$CRON_JOB") | sudo crontab -
echo "✓ Auto-renewal configured"

echo ""
echo -e "${GREEN}================================${NC}"
echo -e "${GREEN}✓ Frontend Deployed!${NC}"
echo -e "${GREEN}================================${NC}"
echo ""
echo "Frontend URL: https://${DOMAIN}"
echo ""
echo "Open in browser: https://${DOMAIN}"
echo "View logs: docker compose -f docker-compose-nginx.yml logs -f"
echo "Restart: docker compose -f docker-compose-nginx.yml restart"
echo ""
echo -e "${GREEN}🎉 All done! Test it in your browser!${NC}"
