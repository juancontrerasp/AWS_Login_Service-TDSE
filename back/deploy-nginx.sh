#!/bin/bash
# ========================================
# ULTIMATE SIMPLE BACKEND DEPLOY
# Spring Boot = HTTP only (port 8080)
# Nginx = Handles HTTPS (port 443)
# NO SPRING SSL BULLSHIT!
# ========================================

set -e

echo "🚀 ULTIMATE SIMPLE Backend Deployment"
echo "======================================"
echo "Spring Boot: HTTP only (8080)"
echo "Nginx: Handles HTTPS (443)"
echo "======================================"
echo ""

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

DOMAIN="securitytdseback.duckdns.org"

# Step 1: Update system
echo -e "\n${GREEN}[1/7]${NC} Updating system..."
sudo yum update -y

# Step 2: Install Docker
echo -e "\n${GREEN}[2/7]${NC} Installing Docker..."
if ! command -v docker &> /dev/null; then
    sudo yum install -y docker
    sudo systemctl start docker
    sudo systemctl enable docker
    sudo usermod -aG docker $USER
fi

# Step 3: Install Docker Compose
echo -e "\n${GREEN}[3/7]${NC} Installing Docker Compose..."
if ! command -v docker-compose &> /dev/null; then
    sudo curl -L "https://github.com/docker/compose/releases/latest/download/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose
    sudo chmod +x /usr/local/bin/docker-compose
fi

# Step 4: Install Certbot
echo -e "\n${GREEN}[4/7]${NC} Installing Certbot..."
if ! command -v certbot &> /dev/null; then
    sudo yum install -y certbot
fi

# Step 5: Get SSL Certificate
echo -e "\n${GREEN}[5/7]${NC} Getting SSL Certificate..."
if [ ! -d "/etc/letsencrypt/live/${DOMAIN}" ]; then
    echo "Stopping services on port 80..."
    docker compose down 2>/dev/null || true
    sudo systemctl stop httpd 2>/dev/null || true
    sudo fuser -k 80/tcp 2>/dev/null || true
    
    echo "Requesting certificate..."
    sudo certbot certonly --standalone -d ${DOMAIN} --non-interactive --agree-tos --email admin@${DOMAIN}
    
    if [ ! -d "/etc/letsencrypt/live/${DOMAIN}" ]; then
        echo -e "${RED}Certificate failed. Check DNS!${NC}"
        exit 1
    fi
fi

# Step 6: Setup .env
echo -e "\n${GREEN}[6/7]${NC} Setting up environment..."
if [ ! -f ".env" ]; then
    if [ -f ".env.production" ]; then
        cp .env.production .env
    fi
fi

# Step 7: Deploy with Nginx
echo -e "\n${GREEN}[7/7]${NC} Deploying with Nginx..."

# Use the nginx docker-compose
docker compose -f docker-compose-nginx.yml down 2>/dev/null || true
docker compose -f docker-compose-nginx.yml up -d --build

echo ""
echo "Waiting for services..."
sleep 15

# Test
echo ""
echo "Testing backend..."
if curl -k -s https://${DOMAIN}/actuator/health | grep -q "UP"; then
    echo -e "${GREEN}✓✓✓ SUCCESS! Backend is live!${NC}"
    echo ""
    echo "Backend URL: https://${DOMAIN}"
    echo "Health: https://${DOMAIN}/actuator/health"
    echo "Swagger: https://${DOMAIN}/swagger-ui/index.html"
else
    echo -e "${YELLOW}Service started but health check pending...${NC}"
    echo "Check logs: docker compose -f docker-compose-nginx.yml logs -f"
fi

# Auto-renewal
echo ""
echo "Setting up auto-renewal..."
CRON_JOB="0 0,12 * * * certbot renew --quiet && docker compose -f $(pwd)/docker-compose-nginx.yml restart nginx"
(sudo crontab -l 2>/dev/null | grep -v "certbot renew"; echo "$CRON_JOB") | sudo crontab -

echo ""
echo -e "${GREEN}========================================${NC}"
echo -e "${GREEN}✓ DEPLOYED! (Spring=HTTP, Nginx=HTTPS)${NC}"
echo -e "${GREEN}========================================${NC}"
echo ""
echo "View logs: docker compose -f docker-compose-nginx.yml logs -f"
