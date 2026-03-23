# 🚀 Running the Application - Complete Guide

This guide covers all the ways to run your secure login service application with database and everything working properly.

---

## 📋 Prerequisites

Before running the application, ensure you have:
- **Docker** and **Docker Compose** installed
- **Java 17+** (only if running without Docker)
- **Maven 3.8+** (only if running without Docker)
- **PostgreSQL 16** (only if running without Docker)

---

## ⚡ Method 1: Docker Compose (RECOMMENDED)

This is the **easiest and most reliable** method. Docker Compose will start everything: PostgreSQL database, Spring Boot app, and Apache reverse proxy.

### Step 1: Create Your Environment File

```bash
cd /home/minin/storage/Uni/TDSE/AWS_Login_Service-TDSE/back

# Copy the example .env file (if you haven't already)
cp .env.example .env

# Edit the .env file with your values
nano .env
```

**Your `.env` file should look like this:**

```env
# Database
DB_NAME=logindb
DB_USER=loginuser
DB_PASSWORD=MySecurePassword123!

# JWT — must be at least 256 bits (32+ chars)
JWT_SECRET=ThisIsAVerySecretKeyForJWTTokenGeneration1234567890
JWT_EXPIRATION_MS=86400000

# CORS — comma-separated list of allowed frontend origins
CORS_ALLOWED_ORIGINS=http://localhost:3000,http://localhost:80
```

### Step 2: Start All Services

```bash
# Build and start everything in detached mode
docker compose up -d --build

# Watch the logs (optional)
docker compose logs -f
```

### Step 3: Verify Everything is Running

```bash
# Check container status (all should be "Up")
docker compose ps

# You should see:
# - login_postgres (PostgreSQL database)
# - login_service (Spring Boot app)
# - login_apache (Apache reverse proxy)
```

### Step 4: Test the API

```bash
# Health check
curl http://localhost:8080/actuator/health

# Swagger UI (API Documentation)
# Open in browser: http://localhost:8080/swagger-ui.html

# Register a new user
curl -X POST http://localhost:8080/api/auth/register \
  -H "Content-Type: application/json" \
  -d '{"username":"testuser","email":"test@example.com","password":"Password123"}'

# Login
curl -X POST http://localhost:8080/api/auth/login \
  -H "Content-Type: application/json" \
  -d '{"username":"testuser","password":"Password123"}'

# This returns a JWT token like:
# {"token":"eyJhbGciOiJIUzI1NiJ9...","tokenType":"Bearer","username":"testuser","email":"test@example.com"}

# Test authenticated endpoint (replace YOUR_TOKEN with the actual token)
curl http://localhost:8080/api/auth/me \
  -H "Authorization: Bearer YOUR_TOKEN"
```

### Useful Docker Compose Commands

```bash
# Stop all services
docker compose down

# Stop and remove volumes (deletes database data!)
docker compose down -v

# Restart a specific service
docker compose restart login-service

# View logs for a specific service
docker compose logs -f login-service

# Rebuild and restart
docker compose up -d --build --force-recreate
```

---

## 🖥️ Method 2: Local Development (Without Docker)

If you prefer to run the Spring Boot app directly on your machine for development.

### Step 1: Start PostgreSQL Database

You can use Docker just for the database:

```bash
docker run -d \
  --name login_postgres \
  -e POSTGRES_DB=logindb \
  -e POSTGRES_USER=loginuser \
  -e POSTGRES_PASSWORD=MySecurePassword123! \
  -p 5432:5432 \
  postgres:16-alpine
```

Or install PostgreSQL natively and create the database:

```sql
CREATE DATABASE logindb;
CREATE USER loginuser WITH PASSWORD 'MySecurePassword123!';
GRANT ALL PRIVILEGES ON DATABASE logindb TO loginuser;
```

### Step 2: Set Environment Variables

```bash
export DB_URL=jdbc:postgresql://localhost:5432/logindb
export DB_USER=loginuser
export DB_PASSWORD=MySecurePassword123!
export JWT_SECRET=ThisIsAVerySecretKeyForJWTTokenGeneration1234567890
export JWT_EXPIRATION_MS=86400000
export CORS_ALLOWED_ORIGINS=http://localhost:3000
```

### Step 3: Run the Spring Boot Application

```bash
cd /home/minin/storage/Uni/TDSE/AWS_Login_Service-TDSE/back

# Option A: Using Maven wrapper
./mvnw clean spring-boot:run

# Option B: Build JAR and run
./mvnw clean package -DskipTests
java -jar target/login-service-1.0.0.jar
```

### Step 4: Access the Application

- **API**: http://localhost:8080
- **Swagger UI**: http://localhost:8080/swagger-ui.html
- **Health Check**: http://localhost:8080/actuator/health

---

## 🌐 Method 3: AWS EC2 Deployment (Production)

For deploying to AWS with HTTPS using Let's Encrypt certificates.

### Prerequisites on EC2

1. **EC2 instance** with Amazon Linux 2023 or Ubuntu
2. **Docker and Docker Compose** installed
3. **Domain name** pointed to your EC2 public IP
4. **Security Group** with ports 80 and 443 open
5. **Let's Encrypt certificate** already issued

### Step 1: SSH into EC2

```bash
ssh -i your-key.pem ec2-user@YOUR_EC2_PUBLIC_IP
```

### Step 2: Install Docker and Docker Compose (if not installed)

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
ssh -i your-key.pem ec2-user@YOUR_EC2_PUBLIC_IP
```

### Step 3: Get Let's Encrypt Certificate (if not done)

```bash
# Install Certbot
sudo yum install -y certbot

# Get certificate (replace with your domain)
sudo certbot certonly --standalone -d api.yourdomain.com

# Certificates will be in: /etc/letsencrypt/live/api.yourdomain.com/
```

### Step 4: Clone and Configure Your Project

```bash
# Clone your repository
git clone https://github.com/YOUR_USERNAME/AWS_Login_Service-TDSE.git
cd AWS_Login_Service-TDSE/back

# Create .env file
nano .env
```

**Production `.env` example:**

```env
DB_NAME=logindb
DB_USER=loginuser
DB_PASSWORD=VeryStrongProductionPassword987!
JWT_SECRET=SuperSecretProductionKeyMinimum32CharactersLong123456
JWT_EXPIRATION_MS=86400000
CORS_ALLOWED_ORIGINS=https://yourdomain.com,https://www.yourdomain.com
```

### Step 5: Update Apache Configuration with Your Domain

```bash
# Replace YOUR_DOMAIN with your actual domain in httpd.conf
sed -i 's/YOUR_DOMAIN/api.yourdomain.com/g' apache/httpd.conf

# Verify the changes
grep ServerName apache/httpd.conf
```

### Step 6: Deploy with Docker Compose

```bash
# Start all services
docker compose up -d --build

# Check logs
docker compose logs -f

# Verify all containers are running
docker compose ps
```

### Step 7: Test Your Production API

```bash
# Health check
curl https://api.yourdomain.com/actuator/health

# Swagger UI (if you want to expose it)
# https://api.yourdomain.com/swagger-ui.html

# Test registration
curl -X POST https://api.yourdomain.com/api/auth/register \
  -H "Content-Type: application/json" \
  -d '{"username":"produser","email":"prod@example.com","password":"SecurePass123"}'
```

### Step 8: Set Up Auto-Renewal for Let's Encrypt

```bash
# Add cron job for certificate renewal
sudo crontab -e

# Add this line (runs twice daily):
0 0,12 * * * certbot renew --quiet && docker compose -f /home/ec2-user/AWS_Login_Service-TDSE/back/docker-compose.yml restart apache
```

---

## 📊 Accessing Swagger UI

Once your application is running, you can access the **interactive API documentation**:

### Local Development
- **URL**: http://localhost:8080/swagger-ui.html
- **API Docs JSON**: http://localhost:8080/v3/api-docs

### Production (AWS)
- **URL**: https://api.yourdomain.com/swagger-ui.html
- **API Docs JSON**: https://api.yourdomain.com/v3/api-docs

### Using Swagger UI

1. **Open Swagger UI** in your browser
2. **Register a user** via the `POST /api/auth/register` endpoint
3. **Login** via the `POST /api/auth/login` endpoint → copy the JWT token
4. **Click "Authorize"** button (🔓 icon) at the top
5. **Paste your token** in the format: `Bearer YOUR_JWT_TOKEN`
6. **Test protected endpoints** like `GET /api/auth/me`

---

## 🐛 Troubleshooting

### Database Connection Issues

```bash
# Check if PostgreSQL is running
docker compose ps postgres

# View PostgreSQL logs
docker compose logs postgres

# Connect to database manually
docker exec -it login_postgres psql -U loginuser -d logindb
```

### Application Won't Start

```bash
# Check application logs
docker compose logs login-service

# Common issues:
# 1. Missing environment variables → check .env file
# 2. Database not ready → wait a few seconds and retry
# 3. Port already in use → stop other services on port 8080
```

### Apache/HTTPS Issues

```bash
# Check Apache logs
docker compose logs apache

# Verify certificate paths
ls -la /etc/letsencrypt/live/YOUR_DOMAIN/

# Test Apache configuration
docker compose exec apache httpd -t
```

### Clean Restart

```bash
# Stop everything and remove volumes
docker compose down -v

# Remove old images
docker compose down --rmi all -v

# Fresh start
docker compose up -d --build
```

---

## 🎯 Quick Start Summary

**For Local Testing:**
```bash
cd /home/minin/storage/Uni/TDSE/AWS_Login_Service-TDSE/back
cp .env.example .env
nano .env  # Fill in your values
docker compose up -d --build
# Open http://localhost:8080/swagger-ui.html
```

**For AWS Production:**
```bash
# On EC2:
git clone YOUR_REPO
cd AWS_Login_Service-TDSE/back
nano .env  # Production values
sed -i 's/YOUR_DOMAIN/api.yourdomain.com/g' apache/httpd.conf
docker compose up -d --build
# Open https://api.yourdomain.com/swagger-ui.html
```

---

## 📞 Support

If you encounter issues:
1. Check the logs: `docker compose logs -f`
2. Verify .env file has all required variables
3. Ensure ports 80, 443, 8080 are available
4. Check Docker and Docker Compose versions

Good luck! 🚀
