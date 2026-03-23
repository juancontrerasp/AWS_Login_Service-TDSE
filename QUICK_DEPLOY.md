# 🎯 QUICK DEPLOYMENT REFERENCE CARD

## 📝 Your Domains
- Frontend: `securitytdse.duckdns.org`
- Backend:  `securitytdseback.duckdns.org`

## 🚀 One-Command Deployment

### Backend EC2 Instance:
```bash
git clone https://github.com/YOUR_USERNAME/AWS_Login_Service-TDSE.git
cd AWS_Login_Service-TDSE/back
./deploy.sh
```

### Frontend EC2 Instance:
```bash
git clone https://github.com/YOUR_USERNAME/AWS_Login_Service-TDSE.git
cd AWS_Login_Service-TDSE/front
./deploy.sh
```

## 📋 Prerequisites Checklist

### Before Deployment:
- [ ] 2 EC2 instances (Amazon Linux 2023)
- [ ] Security groups: ports 22, 80, 443 open
- [ ] DuckDNS A records pointing to EC2 IPs:
  - `securitytdse.duckdns.org` → Frontend EC2 IP
  - `securitytdseback.duckdns.org` → Backend EC2 IP
- [ ] DNS propagated (test with `nslookup`)
- [ ] Code pushed to GitHub

## 🔍 Verification

### Test Backend:
```bash
curl https://securitytdseback.duckdns.org/actuator/health
# Expected: {"status":"UP"}
```

### Test Frontend:
Open browser: `https://securitytdse.duckdns.org`
- Should show login page
- Should have 🔒 lock icon
- No certificate warnings

### Complete Flow:
1. Open `https://securitytdse.duckdns.org`
2. Register: username, email, password (8+ chars)
3. Login with credentials
4. Verify dashboard shows user info
5. Click "Call /api/auth/me" - should work
6. Check browser console (F12) - NO CORS errors

## 🐛 Quick Troubleshooting

### Backend Issues:
```bash
cd ~/AWS_Login_Service-TDSE/back
docker compose logs -f
docker compose ps
docker compose restart
```

### Frontend Issues:
```bash
cd ~/AWS_Login_Service-TDSE/front
docker compose logs -f
docker compose ps
docker compose restart
```

### Certificate Issues:
```bash
sudo certbot certificates
sudo certbot renew --force-renewal
docker compose restart
```

### DNS Issues:
```bash
nslookup securitytdse.duckdns.org
nslookup securitytdseback.duckdns.org
# Update DuckDNS if needed
```

## 📊 What's Pre-Configured

✅ Backend domain: `securitytdseback.duckdns.org`
✅ Frontend domain: `securitytdse.duckdns.org`
✅ Database password: `SecureTDSE2026!PostgresPass`
✅ JWT secret: 64+ character random string
✅ CORS: `https://securitytdse.duckdns.org`
✅ Apache configs: both servers
✅ Docker Compose: ready to go
✅ TLS/HTTPS: configured for Let's Encrypt

## 🎬 Recording Demonstration

Show in video:
1. SSH into both EC2 instances
2. `docker compose ps` showing all containers running
3. Browser: `https://securitytdse.duckdns.org`
4. Register new user
5. Login successfully
6. Dashboard with user info
7. API test working
8. Browser showing 🔒 HTTPS lock icon
9. DevTools (F12) - no errors, HTTPS requests
10. Explain security: TLS, JWT, BCrypt, headers

## 📸 Screenshots Needed

1. AWS Console - both EC2 instances running
2. Security group rules (ports 22, 80, 443)
3. DuckDNS configuration
4. Certbot success message
5. Frontend login page (with 🔒)
6. Registration success
7. Login success
8. Dashboard page
9. Browser lock icon detail
10. DevTools console (no CORS errors)
11. `docker compose ps` output (both servers)

## ⚙️ Configuration File Locations

### Backend:
- `back/.env` - credentials (don't commit!)
- `back/docker-compose.yml` - Apache uncommented
- `back/apache/httpd.conf` - domain configured

### Frontend:
- `front/docker-compose.yml` - created and ready
- `front/apache-frontend.conf` - domain configured
- `front/app.js` - backend URL set
- `front/dashboard.js` - backend URL set

## 🔐 Security Features to Mention

1. **TLS/HTTPS**: Let's Encrypt certificates, TLSv1.2+
2. **Authentication**: JWT tokens, 24-hour expiration
3. **Passwords**: BCrypt hashing (strength 10)
4. **Headers**: HSTS, CSP, X-Frame-Options, etc.
5. **Infrastructure**: PostgreSQL not exposed, Apache proxy
6. **CORS**: Limited to frontend domain only
7. **Rate Limiting**: Auth endpoints limited

## 📞 Support

If stuck, check:
1. `DEPLOY.md` - complete guide
2. `AWS_DEPLOYMENT.md` - detailed AWS steps
3. `DEPLOYMENT_CHECKLIST.md` - step-by-step
4. Logs: `docker compose logs -f`

## 🎯 Workshop Rubric

### Class Work (50%):
- [x] Apache serving client over TLS
- [x] Spring backend over TLS
- [x] Login with hashed passwords
- [x] Let's Encrypt certificates
- [x] GitHub repository

### Homework (50%):
- [x] Architecture document
- [x] Security implementation
- [x] Working application
- [x] Documentation + screenshots
- [ ] Video demonstration

---

**Everything is ready! Just clone, deploy, and demonstrate!** 🎉
