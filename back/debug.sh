#!/bin/bash
# ========================================
# BACKEND DEBUGGING SCRIPT
# Run this to see what's actually wrong
# ========================================

echo "🔍 Debugging Backend Issues..."
echo "======================================"
echo ""

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

# Check if we're in the right directory
if [ ! -f "docker-compose.yml" ]; then
    echo -e "${RED}ERROR: Run this from the back/ directory!${NC}"
    exit 1
fi

echo -e "${BLUE}=== Docker Status ===${NC}"
docker compose ps
echo ""

echo -e "${BLUE}=== Checking which containers are running ===${NC}"
POSTGRES_STATUS=$(docker compose ps postgres 2>/dev/null | grep -q "Up" && echo "RUNNING" || echo "NOT RUNNING")
SERVICE_STATUS=$(docker compose ps login-service 2>/dev/null | grep -q "Up" && echo "RUNNING" || echo "CRASHED/NOT RUNNING")

echo "PostgreSQL: $POSTGRES_STATUS"
echo "Spring Boot: $SERVICE_STATUS"
echo ""

if [ "$SERVICE_STATUS" != "RUNNING" ]; then
    echo -e "${RED}🚨 Spring Boot service is NOT running!${NC}"
    echo ""
    echo -e "${YELLOW}Let's check the logs to see why it crashed:${NC}"
    echo "=========================================="
    docker compose logs --tail=100 login-service
    echo "=========================================="
    echo ""
    
    echo -e "${YELLOW}Common Issues and Solutions:${NC}"
    echo ""
    echo "1. SSL/Certificate Error?"
    echo "   → Use the HTTP-only version (see SIMPLE_BACKEND.md)"
    echo ""
    echo "2. Database connection error?"
    echo "   → Check PostgreSQL is running: docker compose logs postgres"
    echo ""
    echo "3. Port already in use?"
    echo "   → Check: sudo lsof -i :8080"
    echo ""
    echo "4. Out of memory?"
    echo "   → Try: docker compose down && docker compose up -d --build"
    echo ""
else
    echo -e "${GREEN}✓ Spring Boot is running!${NC}"
    echo ""
    echo "Testing endpoints..."
    
    # Test HTTP
    if curl -s http://localhost:8080/actuator/health &>/dev/null; then
        echo -e "${GREEN}✓ HTTP (port 8080) works!${NC}"
        curl -s http://localhost:8080/actuator/health | head -5
    else
        echo -e "${RED}✗ HTTP (port 8080) not responding${NC}"
    fi
    
    echo ""
    
    # Test HTTPS
    if curl -k -s https://localhost:8443/actuator/health &>/dev/null; then
        echo -e "${GREEN}✓ HTTPS (port 8443) works!${NC}"
        curl -k -s https://localhost:8443/actuator/health | head -5
    else
        echo -e "${YELLOW}⚠ HTTPS (port 8443) not responding (might not be configured)${NC}"
    fi
fi

echo ""
echo -e "${BLUE}=== Recent Logs (last 20 lines) ===${NC}"
docker compose logs --tail=20 login-service

echo ""
echo -e "${BLUE}=== Environment Check ===${NC}"
if [ -f ".env" ]; then
    echo -e "${GREEN}✓ .env file exists${NC}"
    echo "Database: $(grep DB_NAME .env || echo 'NOT SET')"
    echo "CORS: $(grep CORS_ALLOWED_ORIGINS .env || echo 'NOT SET')"
else
    echo -e "${RED}✗ .env file missing!${NC}"
fi

echo ""
echo -e "${BLUE}=== Quick Fixes ===${NC}"
echo ""
echo "1. View full logs:"
echo "   docker compose logs -f login-service"
echo ""
echo "2. Restart everything:"
echo "   docker compose down && docker compose up -d --build"
echo ""
echo "3. Use HTTP-only version (SIMPLEST - RECOMMENDED):"
echo "   ./deploy-http-only.sh"
echo ""
echo "4. Check database:"
echo "   docker compose logs postgres"
echo ""
