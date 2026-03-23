#!/bin/bash
# ========================================
# Pre-Deployment Verification Script
# Run this to verify everything is ready
# ========================================

echo "🔍 AWS Login Service - Deployment Readiness Check"
echo "=================================================="
echo ""

ERRORS=0
WARNINGS=0

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Helper functions
check_pass() {
    echo -e "${GREEN}✓${NC} $1"
}

check_fail() {
    echo -e "${RED}✗${NC} $1"
    ((ERRORS++))
}

check_warn() {
    echo -e "${YELLOW}⚠${NC} $1"
    ((WARNINGS++))
}

check_info() {
    echo -e "${BLUE}ℹ${NC} $1"
}

# Backend Checks
echo -e "\n${BLUE}=== BACKEND CONFIGURATION ===${NC}"

if [ -f "back/.env" ]; then
    check_pass "backend/.env exists"
    
    # Check for production values
    if grep -q "securitytdse.duckdns.org" back/.env; then
        check_pass "CORS configured for frontend domain"
    else
        check_warn "CORS might need verification in .env"
    fi
    
    if grep -q "DB_PASSWORD=.*" back/.env; then
        check_pass "Database password is set"
    else
        check_fail "Database password not set in .env"
    fi
    
    if grep -q "JWT_SECRET=.*" back/.env; then
        JWT_LEN=$(grep "JWT_SECRET=" back/.env | cut -d'=' -f2 | wc -c)
        if [ $JWT_LEN -gt 32 ]; then
            check_pass "JWT secret is strong (length: $JWT_LEN)"
        else
            check_fail "JWT secret too short (minimum 32 chars)"
        fi
    else
        check_fail "JWT secret not set in .env"
    fi
else
    check_fail "back/.env not found"
fi

if [ -f "back/docker-compose.yml" ]; then
    check_pass "backend/docker-compose.yml exists"
    
    # Check if Apache is uncommented
    if grep -q "^  apache:" back/docker-compose.yml; then
        check_pass "Apache service is uncommented"
    else
        check_fail "Apache service is still commented out"
    fi
else
    check_fail "back/docker-compose.yml not found"
fi

if [ -f "back/apache/httpd.conf" ]; then
    check_pass "backend/apache/httpd.conf exists"
    
    if grep -q "securitytdseback.duckdns.org" back/apache/httpd.conf; then
        check_pass "Backend domain configured correctly"
    else
        check_fail "Backend domain not configured (should be securitytdseback.duckdns.org)"
    fi
else
    check_fail "back/apache/httpd.conf not found"
fi

if [ -f "back/deploy.sh" ] && [ -x "back/deploy.sh" ]; then
    check_pass "Backend deployment script is executable"
else
    check_warn "Backend deployment script missing or not executable"
fi

# Frontend Checks
echo -e "\n${BLUE}=== FRONTEND CONFIGURATION ===${NC}"

if [ -f "front/docker-compose.yml" ]; then
    check_pass "frontend/docker-compose.yml exists"
else
    check_fail "front/docker-compose.yml not found"
fi

if [ -f "front/apache-frontend.conf" ]; then
    check_pass "frontend/apache-frontend.conf exists"
    
    if grep -q "securitytdse.duckdns.org" front/apache-frontend.conf; then
        check_pass "Frontend domain configured correctly"
    else
        check_fail "Frontend domain not configured (should be securitytdse.duckdns.org)"
    fi
    
    if grep -q "securitytdseback.duckdns.org" front/apache-frontend.conf; then
        check_pass "Backend domain referenced in CSP"
    else
        check_warn "Backend domain not in Content-Security-Policy"
    fi
else
    check_fail "front/apache-frontend.conf not found"
fi

if [ -f "front/app.js" ]; then
    check_pass "frontend/app.js exists"
    
    if grep -q "https://securitytdseback.duckdns.org" front/app.js; then
        check_pass "app.js configured with correct backend URL"
    else
        check_fail "app.js still using localhost or wrong backend URL"
    fi
else
    check_fail "front/app.js not found"
fi

if [ -f "front/dashboard.js" ]; then
    check_pass "frontend/dashboard.js exists"
    
    if grep -q "https://securitytdseback.duckdns.org" front/dashboard.js; then
        check_pass "dashboard.js configured with correct backend URL"
    else
        check_fail "dashboard.js still using localhost or wrong backend URL"
    fi
else
    check_fail "front/dashboard.js not found"
fi

if [ -f "front/deploy.sh" ] && [ -x "front/deploy.sh" ]; then
    check_pass "Frontend deployment script is executable"
else
    check_warn "Frontend deployment script missing or not executable"
fi

# HTML files
if [ -f "front/index.html" ]; then
    check_pass "frontend/index.html exists"
else
    check_fail "front/index.html not found"
fi

if [ -f "front/dashboard.html" ]; then
    check_pass "frontend/dashboard.html exists"
else
    check_fail "front/dashboard.html not found"
fi

# Documentation Checks
echo -e "\n${BLUE}=== DOCUMENTATION ===${NC}"

if [ -f "README.md" ]; then
    check_pass "README.md exists"
else
    check_warn "README.md not found"
fi

if [ -f "DEPLOY.md" ]; then
    check_pass "DEPLOY.md exists"
else
    check_warn "DEPLOY.md not found"
fi

if [ -f "ARCHITECTURE.md" ]; then
    check_pass "ARCHITECTURE.md exists"
else
    check_warn "ARCHITECTURE.md not found"
fi

# Check for placeholder values
echo -e "\n${BLUE}=== PLACEHOLDER CHECK ===${NC}"

PLACEHOLDERS=$(grep -r "YOUR_DOMAIN\|YOUR_FRONTEND\|YOUR_BACKEND\|localhost:8080" --include="*.conf" --include="*.js" --include="*.yml" back/ front/ 2>/dev/null | grep -v "localhost:8080.*connect-src" | grep -v ".git" || true)

if [ -z "$PLACEHOLDERS" ]; then
    check_pass "No placeholder domains found"
else
    check_warn "Potential placeholders found:"
    echo "$PLACEHOLDERS" | while read line; do
        echo "    $line"
    done
fi

# Final Summary
echo -e "\n${BLUE}=== SUMMARY ===${NC}"
echo "=================================================="

if [ $ERRORS -eq 0 ] && [ $WARNINGS -eq 0 ]; then
    echo -e "${GREEN}✓ ALL CHECKS PASSED!${NC}"
    echo ""
    echo "Your application is ready for deployment! 🚀"
    echo ""
    echo "Next steps:"
    echo "  1. Commit and push to GitHub"
    echo "  2. Point DuckDNS domains to your EC2 IPs"
    echo "  3. Run deploy.sh on each EC2 instance"
    echo ""
    echo "See DEPLOY.md for detailed instructions."
elif [ $ERRORS -eq 0 ]; then
    echo -e "${YELLOW}⚠ $WARNINGS warning(s) found${NC}"
    echo "You can proceed, but review the warnings above."
else
    echo -e "${RED}✗ $ERRORS error(s) found${NC}"
    if [ $WARNINGS -gt 0 ]; then
        echo -e "${YELLOW}⚠ $WARNINGS warning(s) found${NC}"
    fi
    echo ""
    echo "Please fix the errors above before deploying."
    exit 1
fi

echo "=================================================="
