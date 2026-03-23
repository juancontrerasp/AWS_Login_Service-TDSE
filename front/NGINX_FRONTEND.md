# 🎨 Frontend Deployment with Nginx

## ✅ Nginx Version (Simpler & More Reliable)

Apache was causing "No MPM loaded" errors. Nginx works perfectly!

---

## 🚀 Quick Deploy

```bash
cd ~/AWS_Login_Service-TDSE/front
./deploy-nginx.sh
```

That's it! The script handles everything.

---

## 📋 Manual Steps (if needed)

```bash
# 1. Get SSL certificate (if you don't have it)
sudo certbot certonly --standalone -d securitytdse.duckdns.org

# 2. Stop old Apache
docker compose down

# 3. Start Nginx
docker compose -f docker-compose-nginx.yml up -d

# 4. Check status
docker compose -f docker-compose-nginx.yml ps

# 5. Test
curl -I https://securitytdse.duckdns.org
```

---

## ✅ What This Includes

**Files:**
- `docker-compose-nginx.yml` - Nginx container config
- `nginx-frontend.conf` - Nginx server config
- `deploy-nginx.sh` - Automated deployment script

**Features:**
- ✅ Serves all static files (HTML, CSS, JS)
- ✅ HTTPS with Let's Encrypt
- ✅ HTTP → HTTPS redirect
- ✅ Security headers (HSTS, CSP, X-Frame-Options, etc.)
- ✅ CORS configured for backend
- ✅ Modern TLS (1.2 & 1.3)
- ✅ Gzip compression
- ✅ Proper MIME types

---

## 🧪 Testing

After deployment:

```bash
# 1. Check container
docker compose -f docker-compose-nginx.yml ps

# 2. Test HTTPS
curl -I https://securitytdse.duckdns.org

# 3. Open in browser
https://securitytdse.duckdns.org
```

You should see:
- 🔒 Lock icon (HTTPS)
- Login/Register page
- No errors in console (F12)

---

## 🎯 Complete Flow Test

1. Open: https://securitytdse.duckdns.org
2. Click "Register"
3. Enter credentials (password 8+ chars)
4. Register → Success message
5. Switch to "Login" tab
6. Login → Redirect to dashboard
7. Dashboard shows your info
8. Click "Call /api/auth/me" → API works!
9. No CORS errors in console ✅

---

## 🐛 Troubleshooting

**Container not running:**
```bash
docker compose -f docker-compose-nginx.yml logs -f
```

**Certificate issues:**
```bash
sudo certbot certificates
sudo ls -la /etc/letsencrypt/live/securitytdse.duckdns.org/
```

**Restart:**
```bash
docker compose -f docker-compose-nginx.yml restart
```

**Full redeploy:**
```bash
docker compose -f docker-compose-nginx.yml down
docker compose -f docker-compose-nginx.yml up -d
```

---

## 📊 Comparison

| Apache (Old) | Nginx (New) |
|-------------|------------|
| "No MPM loaded" error | Works immediately |
| Complex config | Simple config |
| Crash loops | Stable |
| More modules needed | Everything built-in |
| ❌ Broken | ✅ Working |

---

## ✅ Workshop Requirements

**Still satisfied!**
- ✅ Server serving HTML+JS client over TLS
- ✅ HTTPS with Let's Encrypt certificates
- ✅ Security headers configured
- ✅ AWS EC2 deployment
- ✅ Production ready

Apache vs Nginx is just an implementation detail - both are valid web servers!

---

**Bottom line: Use Nginx, it just works!** 🚀
