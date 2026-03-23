#!/bin/bash
# ========================================
# Backend Deployment Script (SIMPLIFIED - No Apache!)
# Domain: securitytdseback.duckdns.org
# Uses Spring Boot native HTTPS support
# ========================================

set -e  # Exit on any error

echo "🚀 Starting SIMPLIFIED Backend Deployment (No Apache)..."
echo "========================================================="

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

DOMAIN="securitytdseback.duckdns.org"
CERT_PATH="/etc/letsencrypt/live/${DOMAIN}"
KEYSTORE_PASSWORD="SecureTDSE2026KeyStore"

# Check if running as ec2-user or with proper permissions
if [[ $EUID -eq 0 ]]; then
   echo -e "${YELLOW}Warning: Running as root. Consider running as ec2-user.${NC}"
fi

# Step 1: Update system
echo -e "\n${GREEN}[1/9]${NC} Updating system packages..."
sudo yum update -y

# Step 2: Install Docker
echo -e "\n${GREEN}[2/9]${NC} Installing Docker..."
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
echo -e "\n${GREEN}[3/9]${NC} Installing Docker Compose..."
if ! command -v docker-compose &> /dev/null; then
    sudo curl -L "https://github.com/docker/compose/releases/latest/download/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose
    sudo chmod +x /usr/local/bin/docker-compose
    echo "Docker Compose installed ✓"
else
    echo "Docker Compose already installed ✓"
fi

# Step 4: Install Certbot
echo -e "\n${GREEN}[4/9]${NC} Installing Certbot..."
if ! command -v certbot &> /dev/null; then
    sudo yum install -y certbot
    echo "Certbot installed ✓"
else
    echo "Certbot already installed ✓"
fi

# Step 5: Get SSL Certificate
echo -e "\n${GREEN}[5/9]${NC} Getting SSL Certificate..."
if [ ! -d "${CERT_PATH}" ]; then
    echo "Stopping any service on port 80..."
    sudo systemctl stop httpd 2>/dev/null || true
    sudo fuser -k 80/tcp 2>/dev/null || true
    
    echo "Requesting certificate for ${DOMAIN}..."
    sudo certbot certonly --standalone -d ${DOMAIN} --non-interactive --agree-tos --email admin@${DOMAIN}
    
    if [ -d "${CERT_PATH}" ]; then
        echo -e "${GREEN}Certificate obtained successfully! ✓${NC}"
    else
        echo -e "${RED}Failed to obtain certificate. Check your DNS settings.${NC}"
        exit 1
    fi
else
    echo "Certificate already exists ✓"
    sudo certbot certificates
fi

# Step 6: Convert PEM to PKCS12 Keystore for Spring Boot
echo -e "\n${GREEN}[6/9]${NC} Converting certificate to PKCS12 format for Spring Boot..."

# Install OpenSSL if not present
if ! command -v openssl &> /dev/null; then
    sudo yum install -y openssl
fi

KEYSTORE_PATH="${CERT_PATH}/keystore.p12"

if [ ! -f "${KEYSTORE_PATH}" ]; then
    echo "Creating PKCS12 keystore..."
    sudo openssl pkcs12 -export \
        -in ${CERT_PATH}/fullchain.pem \
        -inkey ${CERT_PATH}/privkey.pem \
        -out ${KEYSTORE_PATH} \
        -name tomcat \
        -passout pass:${KEYSTORE_PASSWORD}
    
    sudo chmod 644 ${KEYSTORE_PATH}
    echo -e "${GREEN}Keystore created successfully! ✓${NC}"
else
    echo "Keystore already exists ✓"
fi

# Step 7: Setup .env from .env.production
echo -e "\n${GREEN}[7/9]${NC} Configuring environment..."
if [ ! -f ".env" ]; then
    if [ -f ".env.production" ]; then
        echo "Copying .env.production to .env..."
        cp .env.production .env
        echo ".env created from .env.production ✓"
    else
        echo -e "${RED}ERROR: Neither .env nor .env.production found!${NC}"
        exit 1
    fi
else
    echo ".env already exists ✓"
fi

# Verify configuration files
if [ ! -f "docker-compose.yml" ]; then
    echo -e "${RED}ERROR: docker-compose.yml not found!${NC}"
    exit 1
fi

echo "Configuration files verified ✓"

# Step 8: Deploy with Docker Compose
echo -e "\n${GREEN}[8/9]${NC} Starting Docker Compose services..."
docker compose down 2>/dev/null || true
docker compose up -d --build

echo "Waiting for services to start..."
sleep 15

# Step 9: Verify deployment
echo -e "\n${GREEN}[9/9]${NC} Verifying deployment..."
docker compose ps

echo -e "\nChecking service health..."
max_attempts=15
attempt=1
while [ $attempt -le $max_attempts ]; do
    echo -e "Attempt $attempt/$max_attempts..."
    
    # Try HTTPS first
    if curl -k -s https://localhost:443/actuator/health | grep -q "UP"; then
        echo -e "${GREEN}✓ Backend is healthy and responding on HTTPS!${NC}"
        break
    fi
    
    # Try by domain
    if curl -k -s https://${DOMAIN}/actuator/health | grep -q "UP"; then
        echo -e "${GREEN}✓ Backend is healthy and responding!${NC}"
        break
    fi
    
    if [ $attempt -eq $max_attempts ]; then
        echo -e "${YELLOW}Warning: Backend health check timeout. Check logs:${NC}"
        echo "  docker compose logs -f login-service"
        break
    fi
    sleep 5
    ((attempt++))
done

# Setup auto-renewal with keystore regeneration
echo -e "\n${GREEN}Setting up automatic certificate renewal...${NC}"
RENEWAL_SCRIPT="/usr/local/bin/renew-spring-cert.sh"

# Create renewal script
sudo tee ${RENEWAL_SCRIPT} > /dev/null <<EOF
#!/bin/bash
certbot renew --quiet
if [ -f "${CERT_PATH}/fullchain.pem" ]; then
    openssl pkcs12 -export \\
        -in ${CERT_PATH}/fullchain.pem \\
        -inkey ${CERT_PATH}/privkey.pem \\
        -out ${KEYSTORE_PATH} \\
        -name tomcat \\
        -passout pass:${KEYSTORE_PASSWORD}
    chmod 644 ${KEYSTORE_PATH}
    docker compose -f $(pwd)/docker-compose.yml restart login-service
fi
EOF

sudo chmod +x ${RENEWAL_SCRIPT}

CRON_JOB="0 0,12 * * * ${RENEWAL_SCRIPT}"
(sudo crontab -l 2>/dev/null | grep -v "renew-spring-cert"; echo "$CRON_JOB") | sudo crontab -
echo "Certificate auto-renewal configured ✓"

# Final status
echo -e "\n${GREEN}==========================================${NC}"
echo -e "${GREEN}🎉 Backend Deployment Complete! (No Apache needed!)${NC}"
echo -e "${GREEN}==========================================${NC}"
echo ""
echo "Backend URL: https://${DOMAIN}"
echo "Health Check: https://${DOMAIN}/actuator/health"
echo "Swagger UI: https://${DOMAIN}/swagger-ui/index.html"
echo ""
echo "Test with: curl -k https://${DOMAIN}/actuator/health"
echo ""
echo "View logs: docker compose logs -f login-service"
echo "Stop services: docker compose down"
echo ""
echo -e "${GREEN}✅ Spring Boot is handling HTTPS directly - no Apache complexity!${NC}"
