# ✅ Deployment Checklist - AWS HTTPS Setup

Use this checklist to ensure everything is properly configured for AWS deployment.

---

## 📋 Pre-Deployment

### Domain & DNS
- [ ] Have two domain names (or subdomains) ready
  - [ ] `frontend.yourdomain.com`
  - [ ] `api.yourdomain.com`
- [ ] Access to DNS management console
- [ ] Know your DNS provider (Route 53, Cloudflare, GoDaddy, etc.)

### AWS Account
- [ ] AWS account created and verified
- [ ] IAM user with EC2 permissions (or root account)
- [ ] SSH key pair created (.pem file downloaded)
- [ ] Know your preferred AWS region

### Local Preparation
- [ ] Code committed to GitHub repository
- [ ] All sensitive data in `.env` (not in code)
- [ ] Docker tested locally
- [ ] Application works on `localhost`

---

## 🖥️ Server 1: Frontend Server

### EC2 Instance
- [ ] Instance launched (t2.micro, Amazon Linux 2023)
- [ ] Security group configured:
  - [ ] Port 22 (SSH) from your IP
  - [ ] Port 80 (HTTP) from anywhere
  - [ ] Port 443 (HTTPS) from anywhere
- [ ] Public IP noted: `___.___.___.___`
- [ ] Can SSH into instance

### DNS Configuration
- [ ] A record created: `frontend.yourdomain.com` → Server 1 IP
- [ ] DNS propagated (can ping domain)
- [ ] Domain resolves to correct IP

### Software Installation
- [ ] Docker installed and running
- [ ] Docker Compose installed
- [ ] Certbot installed
- [ ] Git installed

### SSL Certificate
- [ ] Ran: `sudo certbot certonly --standalone -d frontend.yourdomain.com`
- [ ] Certificate obtained successfully
- [ ] Certificate files exist:
  - [ ] `/etc/letsencrypt/live/frontend.yourdomain.com/fullchain.pem`
  - [ ] `/etc/letsencrypt/live/frontend.yourdomain.com/privkey.pem`

### Application Deployment
- [ ] Repository cloned
- [ ] `app.js` updated with backend URL
- [ ] `dashboard.js` updated with backend URL
- [ ] `apache-frontend.conf` updated with correct domain
- [ ] Docker Compose started: `docker compose up -d`
- [ ] Container running: `docker compose ps`

### Testing
- [ ] Can access: `http://frontend.yourdomain.com`
- [ ] Redirects to HTTPS automatically
- [ ] Can access: `https://frontend.yourdomain.com`
- [ ] Browser shows lock icon 🔒
- [ ] No certificate warnings
- [ ] Login page loads correctly
- [ ] No console errors (F12)

---

## 🔧 Server 2: Backend Server

### EC2 Instance
- [ ] Instance launched (t2.small, Amazon Linux 2023)
- [ ] Security group configured:
  - [ ] Port 22 (SSH) from your IP
  - [ ] Port 80 (HTTP) from anywhere
  - [ ] Port 443 (HTTPS) from anywhere
- [ ] Public IP noted: `___.___.___.___`
- [ ] Can SSH into instance

### DNS Configuration
- [ ] A record created: `api.yourdomain.com` → Server 2 IP
- [ ] DNS propagated (can ping domain)
- [ ] Domain resolves to correct IP

### Software Installation
- [ ] Docker installed and running
- [ ] Docker Compose installed
- [ ] Certbot installed
- [ ] Git installed

### SSL Certificate
- [ ] Ran: `sudo certbot certonly --standalone -d api.yourdomain.com`
- [ ] Certificate obtained successfully
- [ ] Certificate files exist:
  - [ ] `/etc/letsencrypt/live/api.yourdomain.com/fullchain.pem`
  - [ ] `/etc/letsencrypt/live/api.yourdomain.com/privkey.pem`

### Application Configuration
- [ ] Repository cloned
- [ ] `.env` file created with production values:
  - [ ] Strong `DB_PASSWORD` set
  - [ ] Random `JWT_SECRET` set (64+ chars)
  - [ ] `CORS_ALLOWED_ORIGINS` set to frontend domain
- [ ] `apache/httpd.conf` updated with correct domain
- [ ] Apache service uncommented in `docker-compose.yml`

### Application Deployment
- [ ] Docker Compose started: `docker compose up -d --build`
- [ ] All containers running:
  - [ ] `login_postgres` (healthy)
  - [ ] `login_service` (up)
  - [ ] `login_apache` (up)
- [ ] Check logs: `docker compose logs -f`
- [ ] No errors in logs

### Testing
- [ ] Can access: `http://api.yourdomain.com/actuator/health`
- [ ] Redirects to HTTPS automatically
- [ ] Can access: `https://api.yourdomain.com/actuator/health`
- [ ] Returns: `{"status":"UP"}` or similar
- [ ] Browser shows lock icon 🔒
- [ ] Swagger UI accessible (optional): `https://api.yourdomain.com/swagger-ui/index.html`

---

## 🔗 Integration Testing

### Complete Flow
- [ ] Open: `https://frontend.yourdomain.com`
- [ ] No CORS errors in console
- [ ] Click "Register" tab
- [ ] Register new user:
  - Username: testuser
  - Email: test@test.com
  - Password: TestPass123
- [ ] See success message
- [ ] Click "Login" tab
- [ ] Login with credentials
- [ ] Redirected to dashboard
- [ ] Dashboard shows:
  - [ ] "Nice, you're in!"
  - [ ] Username displayed
  - [ ] Email displayed
- [ ] Click "Call /api/auth/me" button
- [ ] API response shown
- [ ] Click "Logout"
- [ ] Redirected to login page

### Browser Testing
- [ ] Tested in Chrome
- [ ] Tested in Firefox
- [ ] Tested on mobile (optional)
- [ ] No console errors
- [ ] All HTTPS connections secure

---

## 🔄 SSL Auto-Renewal

### Frontend Server
- [ ] Opened crontab: `sudo crontab -e`
- [ ] Added renewal line:
  ```
  0 0,12 * * * certbot renew --quiet && docker compose -f /home/ec2-user/AWS_Login_Service-TDSE/front/docker-compose.yml restart apache-frontend
  ```
- [ ] Cron job saved

### Backend Server
- [ ] Opened crontab: `sudo crontab -e`
- [ ] Added renewal line:
  ```
  0 0,12 * * * certbot renew --quiet && docker compose -f /home/ec2-user/AWS_Login_Service-TDSE/back/docker-compose.yml restart apache
  ```
- [ ] Cron job saved

---

## 📸 Documentation

### Screenshots Taken
- [ ] EC2 instances list (both running)
- [ ] Security group inbound rules
- [ ] DNS configuration
- [ ] Certbot certificate issuance
- [ ] Frontend login page (with HTTPS)
- [ ] Successful registration
- [ ] Successful login
- [ ] Dashboard page
- [ ] Browser showing HTTPS lock icon
- [ ] Developer console (F12) showing no errors
- [ ] Swagger UI (optional)
- [ ] Docker containers running (`docker compose ps`)

### Code Repository
- [ ] All code committed to GitHub
- [ ] README.md updated
- [ ] AWS_DEPLOYMENT.md included
- [ ] ARCHITECTURE.md included
- [ ] `.env.example` included (not actual .env)
- [ ] Screenshots added to repo (optional)

### Video Recording
- [ ] SSH into both servers shown
- [ ] `docker compose ps` output shown
- [ ] Navigate to `https://frontend.yourdomain.com`
- [ ] Register and login demonstrated
- [ ] Dashboard shown
- [ ] Explained security features:
  - [ ] TLS/HTTPS encryption
  - [ ] JWT authentication
  - [ ] BCrypt password hashing
  - [ ] Let's Encrypt certificates
- [ ] Video uploaded/submitted

---

## 🎓 Workshop Deliverables

### Class Work (50%)
- [ ] Participated in discussions
- [ ] Completed hands-on exercises
- [ ] Contributed to architecture design
- [ ] Deployed to AWS successfully
- [ ] Configured TLS on both servers
- [ ] Generated Let's Encrypt certificates
- [ ] Submitted code to GitHub

### Homework (50%)
- [ ] Architecture design document completed
- [ ] Outlines Apache/Spring/Client relationship
- [ ] Demonstrates understanding of security
- [ ] Working application submitted
- [ ] TLS configured on both servers
- [ ] Login with hashed passwords works
- [ ] Let's Encrypt certificates installed
- [ ] GitHub repository complete with:
  - [ ] All source code
  - [ ] Deployment instructions
  - [ ] Architecture overview
  - [ ] Screenshots
- [ ] Video demonstration submitted

---

## ✅ Final Verification

Run through this final check:

```bash
# On Frontend Server
curl -I https://frontend.yourdomain.com
# Should return: HTTP/2 200

# On Backend Server
curl https://api.yourdomain.com/actuator/health
# Should return: {"status":"UP"} or similar

# From your browser
# Visit: https://frontend.yourdomain.com
# Register, login, check dashboard
# Verify HTTPS lock icon
```

**If all checks pass, you're ready to submit!** 🎉

---

## 📞 Support Checklist

If something doesn't work:

1. **Check DNS**:
   ```bash
   nslookup frontend.yourdomain.com
   nslookup api.yourdomain.com
   ```

2. **Check Certificates**:
   ```bash
   sudo certbot certificates
   ```

3. **Check Docker**:
   ```bash
   docker compose ps
   docker compose logs -f
   ```

4. **Check Security Groups**:
   - Verify ports 80, 443 are open

5. **Check CORS**:
   - Verify `.env` has correct frontend domain

6. **Check Logs**:
   ```bash
   docker compose logs login-service
   docker compose logs apache
   ```

---

**Good luck with your deployment!** 🚀
