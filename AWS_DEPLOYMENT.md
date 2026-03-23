# 🚀 AWS Deployment Guide - Complete HTTPS Setup

This guide shows you how to deploy your secure login application to AWS with HTTPS on both servers.

## 📋 Prerequisites

Before starting, you need:
1. **AWS Account** with EC2 access
2. **Two domain names** (or subdomains):
   - `frontend.yourdomain.com` (for Apache serving HTML/JS)
   - `api.yourdomain.com` (for Spring backend)
3. **SSH key pair** for EC2 access
4. **Basic Linux knowledge**

---

## 🏗️ Architecture Overview

```
Internet (HTTPS)
    │
    ├─► Server 1: Apache (frontend.yourdomain.com:443)
    │   • Serves HTML/CSS/JS over HTTPS
    │   • Let's Encrypt certificate
    │   • Static file hosting
    │
    └─► Server 2: Spring + Apache (api.yourdomain.com:443)
        • Apache: TLS termination + reverse proxy
        • Spring Boot: Backend API (internal :8080)
        • PostgreSQL: Database
        • Let's Encrypt certificate
```

---

## 🎯 Deployment Options

### Option A: Two Separate EC2 Instances (Recommended for Workshop)
- **Server 1**: Frontend only (Apache serving static files)
- **Server 2**: Backend (Spring + PostgreSQL + Apache proxy)
- **Benefit**: Clear separation, easier to understand

### Option B: Single EC2 Instance (Cost-Effective)
- One server running both frontend and backend
- **Benefit**: Lower cost, simpler infrastructure

**This guide covers Option A (two servers).**

---

## 📝 Step-by-Step Deployment

### Phase 1: Setup Domain Names

1. **Get Domain Names**:
   ```
   frontend.yourdomain.com  → Will point to Server 1
   api.yourdomain.com       → Will point to Server 2
   ```

2. **Configure DNS** (do this later after getting EC2 IPs):
   - Create A records pointing to your EC2 public IPs
   - Wait for DNS propagation (5-30 minutes)

---

### Phase 2: Launch EC2 Instances

#### Server 1: Frontend Server

1. **Launch EC2 Instance**:
   - AMI: Amazon Linux 2023
   - Instance type: t2.micro (free tier)
   - Storage: 8 GB
   - Key pair: Create or use existing

2. **Security Group Settings**:
   ```
   Inbound Rules:
   - SSH (22): Your IP
   - HTTP (80): 0.0.0.0/0 (for Let's Encrypt)
   - HTTPS (443): 0.0.0.0/0
   ```

3. **Note the Public IP**: You'll need this for DNS

#### Server 2: Backend Server

1. **Launch EC2 Instance**:
   - AMI: Amazon Linux 2023
   - Instance type: t2.small (or t2.micro)
   - Storage: 10 GB
   - Key pair: Same as above

2. **Security Group Settings**:
   ```
   Inbound Rules:
   - SSH (22): Your IP
   - HTTP (80): 0.0.0.0/0 (for Let's Encrypt)
   - HTTPS (443): 0.0.0.0/0
   ```

3. **Note the Public IP**: You'll need this for DNS

---

### Phase 3: Configure DNS

In your domain registrar/DNS provider:

```
Type: A Record
Name: frontend
Value: <Server 1 Public IP>
TTL: 300

Type: A Record
Name: api
Value: <Server 2 Public IP>
TTL: 300
```

**Wait 5-30 minutes for DNS propagation.**

Test with: `ping frontend.yourdomain.com`

---

### Phase 4: Deploy Server 1 (Frontend)

#### 1. SSH into Server 1

```bash
ssh -i your-key.pem ec2-user@<SERVER_1_IP>
```

#### 2. Install Docker & Docker Compose

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

# Re-login to apply group changes
exit
ssh -i your-key.pem ec2-user@<SERVER_1_IP>
```

#### 3. Install Certbot (Let's Encrypt)

```bash
sudo yum install -y certbot
```

#### 4. Get SSL Certificate

```bash
sudo certbot certonly --standalone -d frontend.yourdomain.com
```

Follow prompts. Certificates will be in:
`/etc/letsencrypt/live/frontend.yourdomain.com/`

#### 5. Clone Your Repository

```bash
git clone https://github.com/YOUR_USERNAME/AWS_Login_Service-TDSE.git
cd AWS_Login_Service-TDSE/front
```

#### 6. Update Frontend Configuration

Edit `app.js` and `dashboard.js`:
```bash
nano app.js
```

Change:
```javascript
const API_BASE_URL = 'https://api.yourdomain.com';  // Use your backend domain
```

Do the same for `dashboard.js`.

#### 7. Create docker-compose.yml for Frontend

```bash
nano docker-compose.yml
```

```yaml
services:
  apache-frontend:
    image: httpd:2.4-alpine
    container_name: frontend_apache
    restart: unless-stopped
    ports:
      - "80:80"
      - "443:443"
    volumes:
      - ./:/usr/local/apache2/htdocs/:ro
      - ./apache-frontend.conf:/usr/local/apache2/conf/httpd.conf:ro
      - /etc/letsencrypt:/etc/letsencrypt:ro
      - /var/lib/letsencrypt:/var/lib/letsencrypt:ro
```

#### 8. Update Apache Config

The file `apache-frontend.conf` is already in your `front/` directory.
Edit it to replace the placeholder domains:

```bash
nano apache-frontend.conf
```

Replace:
- `YOUR_FRONTEND_DOMAIN` → `frontend.yourdomain.com`
- `YOUR_BACKEND_DOMAIN` → `api.yourdomain.com`

**This file is already created for you!** Just update the domain names.

#### 9. Start Frontend Server

```bash
docker compose up -d
docker compose logs -f
```

#### 10. Test Frontend

Visit: `https://frontend.yourdomain.com`

You should see the login page with HTTPS! 🎉

---

### Phase 5: Deploy Server 2 (Backend)

#### 1. SSH into Server 2

```bash
ssh -i your-key.pem ec2-user@<SERVER_2_IP>
```

#### 2. Install Docker & Docker Compose (same as Server 1)

```bash
sudo yum update -y
sudo yum install -y docker
sudo systemctl start docker
sudo systemctl enable docker
sudo usermod -aG docker ec2-user

sudo curl -L "https://github.com/docker/compose/releases/latest/download/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose
sudo chmod +x /usr/local/bin/docker-compose

exit
ssh -i your-key.pem ec2-user@<SERVER_2_IP>
```

#### 3. Install Certbot

```bash
sudo yum install -y certbot
```

#### 4. Get SSL Certificate

```bash
sudo certbot certonly --standalone -d api.yourdomain.com
```

Certificates in: `/etc/letsencrypt/live/api.yourdomain.com/`

#### 5. Clone Repository

```bash
git clone https://github.com/YOUR_USERNAME/AWS_Login_Service-TDSE.git
cd AWS_Login_Service-TDSE/back
```

#### 6. Configure Environment

```bash
nano .env
```

```env
# Database
DB_NAME=logindb
DB_USER=loginuser
DB_PASSWORD=CHANGE_TO_STRONG_PASSWORD

# JWT
JWT_SECRET=CHANGE_TO_RANDOM_64_CHAR_STRING
JWT_EXPIRATION_MS=86400000

# CORS
CORS_ALLOWED_ORIGINS=https://frontend.yourdomain.com
```

#### 7. Update Apache Config

```bash
nano apache/httpd.conf
```

Replace all instances of `YOUR_DOMAIN` with `api.yourdomain.com`:
```bash
sed -i 's/YOUR_DOMAIN/api.yourdomain.com/g' apache/httpd.conf
```

#### 8. Uncomment Apache in docker-compose.yml

Edit `docker-compose.yml` and uncomment the apache service (remove the # symbols).

#### 9. Start Backend

```bash
docker compose up -d --build
docker compose logs -f
```

#### 10. Test Backend

```bash
# Test health endpoint
curl https://api.yourdomain.com/actuator/health

# Test Swagger (optional)
curl https://api.yourdomain.com/swagger-ui/index.html
```

---

### Phase 6: Test the Complete Application

1. **Open**: `https://frontend.yourdomain.com`
2. **Register**: Create a new user
3. **Login**: Test authentication
4. **Dashboard**: Verify user info displays
5. **Check HTTPS**: Look for the lock icon 🔒 in browser

**Check browser console (F12) for any errors.**

---

## 🔄 Auto-Renewal of SSL Certificates

On **both servers**, set up auto-renewal:

```bash
# Add to crontab
sudo crontab -e
```

Add this line:
```
0 0,12 * * * certbot renew --quiet && docker compose -f /home/ec2-user/AWS_Login_Service-TDSE/back/docker-compose.yml restart apache
```

(Adjust path for frontend server)

---

## 🐛 Troubleshooting

### Frontend not loading?
```bash
# Check Apache logs
docker compose logs apache-frontend

# Verify DNS
nslookup frontend.yourdomain.com

# Check certificate
sudo certbot certificates
```

### Backend API not working?
```bash
# Check all containers
docker compose ps

# Check logs
docker compose logs login-service
docker compose logs apache

# Test direct to Spring (internal)
curl http://localhost:8080/actuator/health
```

### CORS errors?
- Verify `.env` has correct `CORS_ALLOWED_ORIGINS`
- Restart backend: `docker compose restart login-service`

---

## 📊 Final Checklist

- [ ] Both domains pointing to correct IPs
- [ ] DNS propagated (can ping both domains)
- [ ] SSL certificates obtained on both servers
- [ ] Frontend loads at `https://frontend.yourdomain.com`
- [ ] Backend API works at `https://api.yourdomain.com`
- [ ] Can register a user
- [ ] Can login
- [ ] Dashboard shows user info
- [ ] Browser shows lock icon (HTTPS working)
- [ ] Auto-renewal cron jobs configured

---

## 📸 For Your Report

**Take screenshots of:**
1. EC2 instances running
2. DNS configuration
3. SSL certificate issuance
4. Frontend login page (with HTTPS lock)
5. Successful login
6. Dashboard showing user info
7. Browser developer tools showing HTTPS
8. Swagger UI (optional)

---

## 🎥 Video Demonstration

Record a video showing:
1. SSH into both servers
2. Show `docker compose ps` on both
3. Navigate to frontend URL
4. Register and login
5. Show user dashboard
6. Explain security features (TLS, JWT, BCrypt)

---

**Congratulations! Your application is now securely deployed on AWS with HTTPS! 🎉**
