# 🚀 AWS Login Service - CLONE AND GO DEPLOYMENT

## ✅ Pre-configured Deployment Information

This repository is **100% ready for deployment**. All configuration files are set up for:

- **Backend Domain**: `securitytdseback.duckdns.org`
- **Frontend Domain**: `securitytdse.duckdns.org`
- **Architecture**: Two separate EC2 instances (one for frontend, one for backend)

## 📋 What's Already Configured

✅ Backend Apache reverse proxy with domain `securitytdseback.duckdns.org`
✅ Frontend Apache server with domain `securitytdse.duckdns.org`  
✅ CORS configured to allow frontend → backend communication  
✅ Production-ready database password and JWT secret  
✅ TLS/HTTPS configuration for both servers  
✅ Docker Compose files ready for both services  
✅ Security headers and best practices implemented

---

## 🏗️ Deployment Architecture

```
Internet (HTTPS)
    │
    ├─► EC2 Instance 1: Frontend (securitytdse.duckdns.org:443)
    │   • Apache serving HTML/CSS/JS over HTTPS
    │   • Let's Encrypt TLS certificate
    │   • Static file hosting
    │
    └─► EC2 Instance 2: Backend (securitytdseback.duckdns.org:443)
        • Apache: TLS termination + reverse proxy (port 443 → 8080)
        • Spring Boot: RESTful API (port 8080)
        • PostgreSQL: Database with hashed passwords
        • Let's Encrypt TLS certificate
```

---

## 🚀 Quick Deployment Steps

### Prerequisites

1. **Two EC2 Instances** (Amazon Linux 2023):
   - Instance 1: t2.micro (Frontend)
   - Instance 2: t2.small (Backend)
   
2. **DNS Records** (DuckDNS or similar):
   - `securitytdse.duckdns.org` → Frontend EC2 Public IP
   - `securitytdseback.duckdns.org` → Backend EC2 Public IP

3. **Security Groups** (both instances):
   - Port 22 (SSH) - Your IP only
   - Port 80 (HTTP) - 0.0.0.0/0
   - Port 443 (HTTPS) - 0.0.0.0/0

---

## 📦 BACKEND DEPLOYMENT (EC2 Instance 2)

### 1. SSH into Backend Server

```bash
ssh -i your-key.pem ec2-user@<BACKEND_EC2_IP>
```

### 2. Install Dependencies

```bash
# Update system
sudo yum update -y

# Install Docker
sudo yum install -y docker
sudo systemctl start docker
sudo systemctl enable docker
sudo usermod -aG docker ec2-user

# Install Docker Compose
sudo curl -L "https://github.com/docker/compose/releases/latest/download/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose
sudo chmod +x /usr/local/bin/docker-compose

# Install Certbot
sudo yum install -y certbot

# Logout and login to refresh Docker group
exit
ssh -i your-key.pem ec2-user@<BACKEND_EC2_IP>
```

### 3. Get SSL Certificate

```bash
# Stop Apache if running (port 80 must be free)
sudo systemctl stop httpd 2>/dev/null || true

# Get certificate
sudo certbot certonly --standalone -d securitytdseback.duckdns.org

# Verify certificates exist
sudo ls -la /etc/letsencrypt/live/securitytdseback.duckdns.org/
```

### 4. Clone and Deploy

```bash
# Clone repository
git clone https://github.com/YOUR_USERNAME/AWS_Login_Service-TDSE.git
cd AWS_Login_Service-TDSE/back

# Everything is already configured! Just start the services:
docker compose up -d --build

# Check logs
docker compose logs -f
```

### 5. Verify Backend

```bash
# Wait ~30 seconds for services to start, then test:
curl https://securitytdseback.duckdns.org/actuator/health

# Expected output: {"status":"UP"}
```

### 6. Setup Auto-Renewal for Certificates

```bash
sudo crontab -e
```

Add this line:
```
0 0,12 * * * certbot renew --quiet && docker compose -f /home/ec2-user/AWS_Login_Service-TDSE/back/docker-compose.yml restart apache
```

---

## 🎨 FRONTEND DEPLOYMENT (EC2 Instance 1)

### 1. SSH into Frontend Server

```bash
ssh -i your-key.pem ec2-user@<FRONTEND_EC2_IP>
```

### 2. Install Dependencies (Same as Backend)

```bash
# Update system
sudo yum update -y

# Install Docker
sudo yum install -y docker
sudo systemctl start docker
sudo systemctl enable docker
sudo usermod -aG docker ec2-user

# Install Docker Compose
sudo curl -L "https://github.com/docker/compose/releases/latest/download/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose
sudo chmod +x /usr/local/bin/docker-compose

# Install Certbot
sudo yum install -y certbot

# Logout and login
exit
ssh -i your-key.pem ec2-user@<FRONTEND_EC2_IP>
```

### 3. Get SSL Certificate

```bash
# Stop Apache if running
sudo systemctl stop httpd 2>/dev/null || true

# Get certificate
sudo certbot certonly --standalone -d securitytdse.duckdns.org

# Verify
sudo ls -la /etc/letsencrypt/live/securitytdse.duckdns.org/
```

### 4. Clone and Deploy

```bash
# Clone repository
git clone https://github.com/YOUR_USERNAME/AWS_Login_Service-TDSE.git
cd AWS_Login_Service-TDSE/front

# Everything is pre-configured! Start the service:
docker compose up -d

# Check logs
docker compose logs -f
```

### 5. Verify Frontend

Open in browser: `https://securitytdse.duckdns.org`

You should see the login page with a 🔒 lock icon!

### 6. Setup Auto-Renewal

```bash
sudo crontab -e
```

Add this line:
```
0 0,12 * * * certbot renew --quiet && docker compose -f /home/ec2-user/AWS_Login_Service-TDSE/front/docker-compose.yml restart apache-frontend
```

---

## 🧪 COMPLETE INTEGRATION TEST

1. **Open Frontend**: `https://securitytdse.duckdns.org`
2. **Register User**:
   - Click "Register" tab
   - Username: `testuser`
   - Email: `test@test.com`
   - Password: `TestPass123`
   - Click "Register"
3. **Login**:
   - Click "Login" tab
   - Enter credentials
   - Click "Login"
4. **Verify Dashboard**:
   - Should redirect to dashboard
   - Shows username and email
   - Click "Call /api/auth/me" to test API
5. **Check Browser Console** (F12):
   - Should have NO CORS errors
   - Should have NO certificate warnings
   - All requests should use HTTPS

---

## 🔒 Security Features Implemented

✅ **TLS/HTTPS Encryption**
   - Let's Encrypt certificates on both servers
   - Modern TLS protocols (TLSv1.2+)
   - Strong cipher suites
   - HTTP → HTTPS automatic redirect

✅ **Authentication & Authorization**
   - JWT token-based authentication
   - Passwords hashed with BCrypt (strength 10)
   - Secure session management

✅ **Security Headers**
   - X-Frame-Options: DENY (clickjacking protection)
   - X-Content-Type-Options: nosniff
   - X-XSS-Protection: enabled
   - Strict-Transport-Security (HSTS)
   - Content-Security-Policy (CSP)

✅ **Infrastructure Security**
   - PostgreSQL not exposed to internet (Docker network only)
   - Apache reverse proxy (backend not directly accessible)
   - Rate limiting on auth endpoints
   - CORS configured for frontend domain only

---

## 📁 Configuration Files Reference

### Backend (`back/`)
- `docker-compose.yml` - ✅ Apache uncommented and configured
- `.env` - ✅ Production credentials set
- `apache/httpd.conf` - ✅ Domain: `securitytdseback.duckdns.org`

### Frontend (`front/`)
- `docker-compose.yml` - ✅ Created with Apache configuration
- `apache-frontend.conf` - ✅ Domain: `securitytdse.duckdns.org`
- `app.js` - ✅ Backend URL: `https://securitytdseback.duckdns.org`
- `dashboard.js` - ✅ Backend URL: `https://securitytdseback.duckdns.org`

---

## 🐛 Troubleshooting

### Backend not responding

```bash
# Check if containers are running
cd ~/AWS_Login_Service-TDSE/back
docker compose ps

# Check logs
docker compose logs login-service
docker compose logs apache
docker compose logs postgres

# Restart services
docker compose restart
```

### Frontend not loading

```bash
cd ~/AWS_Login_Service-TDSE/front
docker compose ps
docker compose logs apache-frontend
docker compose restart
```

### CORS Errors

```bash
# Verify backend .env has correct CORS setting
cd ~/AWS_Login_Service-TDSE/back
cat .env | grep CORS

# Should show: CORS_ALLOWED_ORIGINS=https://securitytdse.duckdns.org
```

### Certificate Issues

```bash
# Check certificates exist
sudo certbot certificates

# Renew certificates manually
sudo certbot renew --force-renewal

# Restart Docker containers after renewal
docker compose restart
```

### DNS Not Resolving

```bash
# Check DNS from EC2 instance
nslookup securitytdse.duckdns.org
nslookup securitytdseback.duckdns.org

# Update DuckDNS IP if needed (visit DuckDNS website)
```

---

## 📊 Workshop Rubric Compliance

### ✅ Class Work (50%)

- [x] Apache server serving HTML+JS client over TLS
- [x] Spring Framework backend with RESTful APIs over TLS
- [x] Login security with hashed passwords (BCrypt)
- [x] TLS configuration on both servers
- [x] Let's Encrypt certificates generated and installed
- [x] Code submitted to GitHub with documentation

### ✅ Homework (50%)

- [x] Architecture design (see ARCHITECTURE.md)
- [x] Security implementation (TLS, JWT, password hashing)
- [x] Deployment instructions (this file)
- [x] All deliverables in repository

---

## 📝 Important Notes

1. **No Changes Needed**: All configuration files are pre-set with your domains
2. **Just Clone and Deploy**: Follow the deployment steps above
3. **Certificates Required**: You must run `certbot` before starting Docker
4. **Port 80 Must Be Free**: Stop any existing web servers before running `certbot`
5. **DNS Must Resolve**: Point your DuckDNS domains to EC2 IPs before getting certificates

---

## 🎓 What You'll Demonstrate

After deployment, you can show:

1. ✅ Two EC2 instances running (AWS Console screenshot)
2. ✅ HTTPS working on both domains (browser lock icon 🔒)
3. ✅ User registration and login flow
4. ✅ JWT authentication working
5. ✅ Passwords stored as BCrypt hashes (check database)
6. ✅ Let's Encrypt certificates (valid until ~3 months)
7. ✅ No CORS errors in browser console
8. ✅ Security headers present (check browser DevTools)

---

## 🆘 Support

If you encounter issues:

1. Check the troubleshooting section above
2. Verify DNS is pointing to correct IPs
3. Ensure security groups allow ports 80, 443
4. Check Docker logs for errors
5. Verify certificates were issued successfully

---

## 📚 Additional Documentation

- `ARCHITECTURE.md` - Detailed system architecture
- `AWS_DEPLOYMENT.md` - Step-by-step AWS deployment guide
- `DEPLOYMENT_CHECKLIST.md` - Complete deployment checklist
- `QUICK_START.md` - Local development setup

---

**🎉 You're all set! Just clone, run certbot, and start Docker Compose!**
