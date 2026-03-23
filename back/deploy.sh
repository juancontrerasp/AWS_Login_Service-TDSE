#!/bin/bash
# ========================================
# Backend Deployment Script
# Domain: securitytdseback.duckdns.org
# ========================================

set -e  # Exit on any error

echo "🚀 Starting Backend Deployment..."
echo "================================="

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Check if running as ec2-user or with proper permissions
if [[ $EUID -eq 0 ]]; then
   echo -e "${YELLOW}Warning: Running as root. Consider running as ec2-user.${NC}"
fi

# Step 1: Update system
echo -e "\n${GREEN}[1/8]${NC} Updating system packages..."
sudo yum update -y

# Step 2: Install Docker
echo -e "\n${GREEN}[2/8]${NC} Installing Docker..."
if ! command -v docker &> /dev/null; then
    sudo yum install -y docker
    sudo systemctl start docker
    sudo systemctl enable docker
    sudo usermod -aG docker $USER
    echo -e "${YELLOW}Docker installed. You may need to logout and login for group changes.${NC}"
else
    echo "Docker already installed ✓"
fi

# Step 3: Install Docker Compose
echo -e "\n${GREEN}[3/8]${NC} Installing Docker Compose..."
if ! command -v docker-compose &> /dev/null; then
    sudo curl -L "https://github.com/docker/compose/releases/latest/download/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose
    sudo chmod +x /usr/local/bin/docker-compose
    echo "Docker Compose installed ✓"
else
    echo "Docker Compose already installed ✓"
fi

# Step 4: Install Certbot
echo -e "\n${GREEN}[4/8]${NC} Installing Certbot..."
if ! command -v certbot &> /dev/null; then
    sudo yum install -y certbot
    echo "Certbot installed ✓"
else
    echo "Certbot already installed ✓"
fi

# Step 5: Get SSL Certificate
echo -e "\n${GREEN}[5/8]${NC} Getting SSL Certificate..."
if [ ! -d "/etc/letsencrypt/live/securitytdseback.duckdns.org" ]; then
    echo "Stopping any service on port 80..."
    sudo systemctl stop httpd 2>/dev/null || true
    sudo fuser -k 80/tcp 2>/dev/null || true
    
    echo "Requesting certificate for securitytdseback.duckdns.org..."
    sudo certbot certonly --standalone -d securitytdseback.duckdns.org --non-interactive --agree-tos --email admin@securitytdseback.duckdns.org
    
    if [ -d "/etc/letsencrypt/live/securitytdseback.duckdns.org" ]; then
        echo -e "${GREEN}Certificate obtained successfully! ✓${NC}"
    else
        echo -e "${RED}Failed to obtain certificate. Check your DNS settings.${NC}"
        exit 1
    fi
else
    echo "Certificate already exists ✓"
    sudo certbot certificates
fi

# Step 6: Verify configuration
echo -e "\n${GREEN}[6/8]${NC} Verifying configuration..."

# Setup .env from .env.production if .env doesn't exist
if [ ! -f ".env" ]; then
    if [ -f ".env.production" ]; then
        echo "Copying .env.production to .env..."
        cp .env.production .env
        echo ".env created from .env.production ✓"
    else
        echo -e "${RED}ERROR: Neither .env nor .env.production found!${NC}"
        echo "Please ensure the repository includes .env.production"
        exit 1
    fi
else
    echo ".env already exists ✓"
fi

if [ ! -f "apache/httpd.conf" ]; then
    echo -e "${RED}ERROR: apache/httpd.conf not found!${NC}"
    exit 1
fi

if [ ! -f "docker-compose.yml" ]; then
    echo -e "${RED}ERROR: docker-compose.yml not found!${NC}"
    exit 1
fi

echo "Configuration files verified ✓"

# Step 7: Deploy with Docker Compose
echo -e "\n${GREEN}[7/8]${NC} Starting Docker Compose services..."
docker compose down 2>/dev/null || true
docker compose up -d --build

echo "Waiting for services to start..."
sleep 10

# Step 8: Verify deployment
echo -e "\n${GREEN}[8/8]${NC} Verifying deployment..."
docker compose ps

echo -e "\nChecking service health..."
max_attempts=12
attempt=1
while [ $attempt -le $max_attempts ]; do
    echo -e "Attempt $attempt/$max_attempts..."
    if curl -k -s https://securitytdseback.duckdns.org/actuator/health | grep -q "UP"; then
        echo -e "${GREEN}✓ Backend is healthy and responding!${NC}"
        break
    fi
    if [ $attempt -eq $max_attempts ]; then
        echo -e "${YELLOW}Warning: Backend health check timeout. Check logs:${NC}"
        echo "  docker compose logs -f"
        break
    fi
    sleep 5
    ((attempt++))
done

# Setup auto-renewal
echo -e "\n${GREEN}Setting up automatic certificate renewal...${NC}"
CRON_JOB="0 0,12 * * * certbot renew --quiet && docker compose -f $(pwd)/docker-compose.yml restart apache"
(crontab -l 2>/dev/null | grep -v "certbot renew"; echo "$CRON_JOB") | crontab -
echo "Certificate auto-renewal configured ✓"

# Final status
echo -e "\n${GREEN}=================================${NC}"
echo -e "${GREEN}🎉 Backend Deployment Complete!${NC}"
echo -e "${GREEN}=================================${NC}"
echo ""
echo "Backend URL: https://securitytdseback.duckdns.org"
echo "Health Check: https://securitytdseback.duckdns.org/actuator/health"
echo "Swagger UI: https://securitytdseback.duckdns.org/swagger-ui/index.html"
echo ""
echo "View logs with: docker compose logs -f"
echo "Stop services: docker compose down"
echo ""
echo -e "${YELLOW}Next: Deploy the frontend on the other EC2 instance${NC}"
