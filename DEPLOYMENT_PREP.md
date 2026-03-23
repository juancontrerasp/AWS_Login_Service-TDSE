# 📝 Pre-Deployment Preparation

Before deploying to AWS, you need to update placeholder values in configuration files.

## Files to Update

### 1️⃣ Frontend Apache Config

**File**: `front/apache-frontend.conf`

**Placeholders to replace**:
- `YOUR_FRONTEND_DOMAIN` → Replace with your actual domain (e.g., `frontend.yourdomain.com`)
- `YOUR_BACKEND_DOMAIN` → Replace with your backend domain (e.g., `api.yourdomain.com`)

**Lines to change** (6 occurrences):
```bash
Line 1:  ServerName YOUR_FRONTEND_DOMAIN
Line 19: connect-src 'self' https://YOUR_BACKEND_DOMAIN ...
Line 23: ServerName YOUR_FRONTEND_DOMAIN
Line 41: ServerName YOUR_FRONTEND_DOMAIN
Line 46: SSLCertificateFile /etc/letsencrypt/live/YOUR_FRONTEND_DOMAIN/fullchain.pem
Line 47: SSLCertificateKeyFile /etc/letsencrypt/live/YOUR_FRONTEND_DOMAIN/privkey.pem
```

**How to do it**:
```bash
cd front
# Option 1: Use sed (quick)
sed -i 's/YOUR_FRONTEND_DOMAIN/frontend.yourdomain.com/g' apache-frontend.conf
sed -i 's/YOUR_BACKEND_DOMAIN/api.yourdomain.com/g' apache-frontend.conf

# Option 2: Manual edit
nano apache-frontend.conf
# Then find/replace manually
```

---

### 2️⃣ Backend Apache Config

**File**: `back/apache/httpd.conf`

**Placeholder to replace**:
- `YOUR_DOMAIN` → Replace with your backend domain (e.g., `api.yourdomain.com`)

**How to do it**:
```bash
cd back/apache
sed -i 's/YOUR_DOMAIN/api.yourdomain.com/g' httpd.conf
```

---

### 3️⃣ Frontend JavaScript

**File**: `front/app.js` and `front/dashboard.js`

**Line to change**:
```javascript
const API_BASE_URL = 'http://localhost:8080';
```

**Change to**:
```javascript
const API_BASE_URL = 'https://api.yourdomain.com';
```

**How to do it**:
```bash
cd front
sed -i "s|http://localhost:8080|https://api.yourdomain.com|g" app.js
sed -i "s|http://localhost:8080|https://api.yourdomain.com|g" dashboard.js
```

---

### 4️⃣ Backend Environment Variables

**File**: `back/.env`

**Line to change**:
```
CORS_ALLOWED_ORIGINS=http://localhost:3000,http://localhost:8080
```

**Change to**:
```
CORS_ALLOWED_ORIGINS=https://frontend.yourdomain.com
```

**How to do it**:
```bash
cd back
nano .env
# Edit the CORS_ALLOWED_ORIGINS line
```

---

## Quick Update Script

Save this as `update-domains.sh` and run it:

```bash
#!/bin/bash

# Replace these with your actual domains
FRONTEND_DOMAIN="frontend.yourdomain.com"
BACKEND_DOMAIN="api.yourdomain.com"

echo "Updating configuration files with domains:"
echo "  Frontend: $FRONTEND_DOMAIN"
echo "  Backend:  $BACKEND_DOMAIN"

# Update frontend Apache config
sed -i "s/YOUR_FRONTEND_DOMAIN/$FRONTEND_DOMAIN/g" front/apache-frontend.conf
sed -i "s/YOUR_BACKEND_DOMAIN/$BACKEND_DOMAIN/g" front/apache-frontend.conf

# Update backend Apache config
sed -i "s/YOUR_DOMAIN/$BACKEND_DOMAIN/g" back/apache/httpd.conf

# Update frontend JavaScript
sed -i "s|http://localhost:8080|https://$BACKEND_DOMAIN|g" front/app.js
sed -i "s|http://localhost:8080|https://$BACKEND_DOMAIN|g" front/dashboard.js

# Update backend CORS
sed -i "s|http://localhost:3000,http://localhost:8080|https://$FRONTEND_DOMAIN|g" back/.env

echo "✅ Done! Don't forget to commit these changes:"
echo "   git add ."
echo "   git commit -m 'Update domains for AWS deployment'"
echo "   git push"
```

**Usage**:
```bash
# Edit the script to set your domains
nano update-domains.sh

# Make it executable
chmod +x update-domains.sh

# Run it
./update-domains.sh
```

---

## ✅ Checklist

Before deploying:

- [ ] Updated `front/apache-frontend.conf` with domain names
- [ ] Updated `back/apache/httpd.conf` with domain name
- [ ] Updated `front/app.js` API URL to HTTPS backend
- [ ] Updated `front/dashboard.js` API URL to HTTPS backend
- [ ] Updated `back/.env` CORS settings
- [ ] Committed all changes to Git
- [ ] Pushed to GitHub

**IMPORTANT**: Do these updates BEFORE deploying to AWS, so when you clone the repo on the EC2 instances, the configuration is already correct!

---

## 🚀 After Updating

1. Commit changes:
   ```bash
   git add .
   git commit -m "Configure domains for AWS deployment"
   git push
   ```

2. Now you're ready to follow `AWS_DEPLOYMENT.md`!
