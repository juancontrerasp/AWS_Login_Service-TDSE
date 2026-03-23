# AWS_Login_Service-TDSE

## 🚀 Enterprise Architecture Workshop: Secure Application Design

A production-ready, secure login application deployed on AWS with:
- **Backend**: Spring Boot REST API with JWT authentication (securitytdseback.duckdns.org)
- **Frontend**: Apache-served HTML/JavaScript client (securitytdse.duckdns.org)
- **Security**: TLS/HTTPS, BCrypt password hashing, Let's Encrypt certificates
- **Architecture**: Two-server deployment on AWS EC2

---

## ✅ READY TO DEPLOY - Clone and Go!

This repository is **100% configured** for deployment with your domains:
- **Backend**: `securitytdseback.duckdns.org`
- **Frontend**: `securitytdse.duckdns.org`

### Quick Start Deployment

**See [DEPLOY.md](DEPLOY.md) for complete deployment instructions!**

Or use the automated scripts:

```bash
# On Backend EC2 Instance:
git clone https://github.com/YOUR_USERNAME/AWS_Login_Service-TDSE.git
cd AWS_Login_Service-TDSE/back
chmod +x deploy.sh
./deploy.sh

# On Frontend EC2 Instance:
git clone https://github.com/YOUR_USERNAME/AWS_Login_Service-TDSE.git
cd AWS_Login_Service-TDSE/front
chmod +x deploy.sh
./deploy.sh
```

---

## 📚 Documentation

- **[DEPLOY.md](DEPLOY.md)** - Complete deployment guide (START HERE!)
- **[ARCHITECTURE.md](ARCHITECTURE.md)** - System architecture and design
- **[AWS_DEPLOYMENT.md](AWS_DEPLOYMENT.md)** - Detailed AWS setup instructions
- **[DEPLOYMENT_CHECKLIST.md](DEPLOYMENT_CHECKLIST.md)** - Step-by-step checklist
- **[QUICK_START.md](QUICK_START.md)** - Local development setup

---

## 🏗️ Architecture Overview

```
Internet (HTTPS)
    │
    ├─► EC2 Instance 1: Frontend (securitytdse.duckdns.org:443)
    │   • Apache serving HTML/CSS/JS over HTTPS
    │   • Let's Encrypt TLS certificate
    │   • Security headers configured
    │
    └─► EC2 Instance 2: Backend (securitytdseback.duckdns.org:443)
        • Apache: Reverse proxy with TLS termination
        • Spring Boot: RESTful API (JWT authentication)
        • PostgreSQL: Database (BCrypt password hashing)
        • Let's Encrypt TLS certificate
```

---

## 🔒 Security Features

✅ **TLS/HTTPS Encryption**
- Let's Encrypt certificates
- Modern TLS protocols (TLSv1.2+)
- HTTP → HTTPS automatic redirect
- HSTS headers

✅ **Authentication**
- JWT token-based auth
- BCrypt password hashing (strength 10)
- Secure session management

✅ **Security Headers**
- X-Frame-Options: DENY
- X-Content-Type-Options: nosniff
- Strict-Transport-Security
- Content-Security-Policy

✅ **Infrastructure**
- PostgreSQL not exposed to internet
- Apache reverse proxy
- Rate limiting on auth endpoints
- CORS configured for frontend only

---

## 📋 Workshop Requirements Compliance

### ✅ All Requirements Met

- [x] Apache server serving HTML+JS client over TLS
- [x] Spring Framework backend with RESTful APIs
- [x] Asynchronous JavaScript client
- [x] Login security with hashed passwords (BCrypt)
- [x] TLS encryption on both servers
- [x] Let's Encrypt certificate generation
- [x] AWS EC2 deployment (two instances)
- [x] Complete documentation
- [x] GitHub repository with clear README

---

## 🎯 What's Pre-Configured

✅ Backend domain: `securitytdseback.duckdns.org`
✅ Frontend domain: `securitytdse.duckdns.org`
✅ Production database password
✅ Strong JWT secret key
✅ CORS settings
✅ Apache configurations
✅ Docker Compose files
✅ Deployment scripts

**No manual configuration needed - just deploy!**

---

## 🚀 Deployment Process

1. **Setup EC2 Instances** (2x Amazon Linux 2023)
   - Configure security groups (ports 22, 80, 443)
   - Point DuckDNS domains to EC2 IPs

2. **Deploy Backend** (Instance 1)
   ```bash
   cd AWS_Login_Service-TDSE/back
   ./deploy.sh
   ```

3. **Deploy Frontend** (Instance 2)
   ```bash
   cd AWS_Login_Service-TDSE/front
   ./deploy.sh
   ```

4. **Test Application**
   - Visit: https://securitytdse.duckdns.org
   - Register and login
   - Verify HTTPS lock icon 🔒

---

## 🧪 Testing

After deployment:

1. Open https://securitytdse.duckdns.org
2. Register a new user
3. Login with credentials
4. Access dashboard
5. Test API call with "Call /api/auth/me"
6. Verify no CORS errors (F12 console)
7. Check certificate (click lock icon 🔒)

---

## 🛠️ Technology Stack

**Backend:**
- Java 17
- Spring Boot 3.2
- Spring Security
- JWT Authentication
- PostgreSQL 16
- BCrypt
- Apache HTTP Server 2.4

**Frontend:**
- HTML5
- JavaScript (ES6+)
- CSS3
- Apache HTTP Server 2.4

**DevOps:**
- Docker & Docker Compose
- Let's Encrypt (Certbot)
- AWS EC2
- DuckDNS

---

## 📸 For Workshop Submission

After deployment, capture:

1. EC2 instances running (AWS Console)
2. HTTPS working (browser with lock icon)
3. Registration flow
4. Login successful
5. Dashboard page
6. Browser DevTools showing:
   - No CORS errors
   - HTTPS requests
   - Security headers
7. Certificate details

---

## 🆘 Troubleshooting

**Backend not responding?**
```bash
cd ~/AWS_Login_Service-TDSE/back
docker compose logs -f
```

**Frontend not loading?**
```bash
cd ~/AWS_Login_Service-TDSE/front
docker compose logs -f
```

**Certificate issues?**
```bash
sudo certbot certificates
sudo certbot renew --force-renewal
```

**See [DEPLOY.md](DEPLOY.md) for complete troubleshooting guide.**

---

## 📝 Project Structure

```
AWS_Login_Service-TDSE/
├── back/                          # Backend (Spring Boot)
│   ├── src/                      # Java source code
│   ├── apache/httpd.conf         # ✅ Configured for securitytdseback.duckdns.org
│   ├── docker-compose.yml        # ✅ Apache uncommented
│   ├── .env                      # ✅ Production credentials
│   └── deploy.sh                 # ✅ Automated deployment script
│
├── front/                         # Frontend (HTML/JS)
│   ├── index.html                # Login page
│   ├── dashboard.html            # User dashboard
│   ├── app.js                    # ✅ Backend URL configured
│   ├── dashboard.js              # ✅ Backend URL configured
│   ├── apache-frontend.conf      # ✅ Configured for securitytdse.duckdns.org
│   ├── docker-compose.yml        # ✅ Created and ready
│   └── deploy.sh                 # ✅ Automated deployment script
│
├── DEPLOY.md                      # 👈 START HERE - Complete deployment guide
├── ARCHITECTURE.md                # System architecture
├── AWS_DEPLOYMENT.md              # Detailed AWS instructions
└── DEPLOYMENT_CHECKLIST.md        # Step-by-step checklist
```

---

## 🎓 Workshop Deliverables Checklist

- [x] Architecture design document (ARCHITECTURE.md)
- [x] Apache serving HTML+JS over TLS
- [x] Spring backend with REST APIs
- [x] Login with hashed passwords
- [x] TLS/HTTPS on both servers
- [x] Let's Encrypt certificates
- [x] GitHub repository with documentation
- [x] Deployment instructions (DEPLOY.md)
- [x] Ready for video demonstration

---

## 📄 License

Educational project for Enterprise Architecture Workshop.

---

**🎉 Ready to deploy! See [DEPLOY.md](DEPLOY.md) to get started!**