#!/bin/bash
# ========================================
# NGINX BACKEND DEPLOY (FIXED)
# Handles existing certificates correctly
# ========================================

set -e

echo "🚀 Deploying Backend with Nginx"
echo "================================"

GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

DOMAIN="securitytdseback.duckdns.org"
CERT_PATH="/etc/letsencrypt/live/${DOMAIN}"

# Check if certificate exists
echo "Checking SSL certificate..."
if [ -d "${CERT_PATH}" ]; then
    echo -e "${GREEN}✓ Certificate exists for ${DOMAIN}${NC}"
    sudo ls -la ${CERT_PATH}
else
    echo "Certificate not found. Getting one now..."
    docker compose down 2>/dev/null || true
    sudo systemctl stop httpd 2>/dev/null || true
    sudo certbot certonly --standalone -d ${DOMAIN} --non-interactive --agree-tos --email admin@${DOMAIN}
fi

# Setup .env
echo "Setting up environment..."
if [ ! -f ".env" ]; then
    if [ -f ".env.production" ]; then
        cp .env.production .env
        echo -e "${GREEN}✓ Created .env from .env.production${NC}"
    fi
fi

# Stop old services
echo "Stopping old services..."
docker compose down 2>/dev/null || true
docker compose -f docker-compose-nginx.yml down 2>/dev/null || true

# Start with Nginx
echo "Starting services with Nginx..."
docker compose -f docker-compose-nginx.yml up -d --build

echo ""
echo "Waiting for services to start..."
sleep 15

# Check status
echo ""
echo "Checking containers..."
docker compose -f docker-compose-nginx.yml ps

echo ""
echo "Testing backend..."
sleep 5

if curl -k -s https://localhost/actuator/health 2>/dev/null | grep -q "UP"; then
    echo -e "${GREEN}✓✓✓ Backend is LIVE!${NC}"
elif curl -k -s https://${DOMAIN}/actuator/health 2>/dev/null | grep -q "UP"; then
    echo -e "${GREEN}✓✓✓ Backend is LIVE!${NC}"
else
    echo -e "${YELLOW}Service started. Checking logs...${NC}"
    docker compose -f docker-compose-nginx.yml logs --tail=30
fi

echo ""
echo -e "${GREEN}================================${NC}"
echo -e "${GREEN}✓ DEPLOYMENT COMPLETE${NC}"
echo -e "${GREEN}================================${NC}"
echo ""
echo "Backend: https://${DOMAIN}"
echo "Health: https://${DOMAIN}/actuator/health"
echo "Swagger: https://${DOMAIN}/swagger-ui/index.html"
echo ""
echo "View logs: docker compose -f docker-compose-nginx.yml logs -f"
echo "Restart: docker compose -f docker-compose-nginx.yml restart"
echo ""
