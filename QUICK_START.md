# 🎯 Quick Start Guide - Complete Application

## 🚀 Start Everything

```bash
# 1. Start Backend (from back/ directory)
cd back
docker compose up -d

# 2. Start Frontend (from front/ directory)
cd ../front
python3 server.py
```

## 📍 Access Points

- **Frontend**: http://localhost:3000 ⭐ **(Start here!)**
- **Backend API**: http://localhost:8080
- **Swagger UI**: http://localhost:8080/swagger-ui/index.html

## ✅ Usage Flow

### 1. Register
1. Open http://localhost:3000
2. Click "Register" tab
3. Enter:
   - Username: `yourname`
   - Email: `your@email.com`
   - Password: `YourPass123`
4. Click "Register"

### 2. Login
1. Click "Login" tab
2. Enter username & password
3. Click "Login"
4. ✨ Redirected to dashboard

### 3. Dashboard
- See: **"Nice, you're in!"**
- View: Your username & email
- Test: Click "Call /api/auth/me"
- Logout: Click "Logout"

## 🛠️ Stop Everything

```bash
# Stop Frontend
# Press Ctrl+C in the terminal running server.py

# Stop Backend
cd back
docker compose down
```

## 📊 Architecture Summary

```
Frontend (Port 3000)          Backend (Port 8080)
┌──────────────────┐         ┌──────────────────┐
│                  │         │                  │
│  • index.html    │────────>│  Spring Boot     │
│  • dashboard.html│  Async  │  + JWT Auth      │
│  • JavaScript    │  Fetch  │  + BCrypt        │
│                  │<────────│  + Swagger       │
└──────────────────┘   JSON  └──────────────────┘
                                      │
                                      ▼
                              ┌──────────────────┐
                              │   PostgreSQL     │
                              └──────────────────┘
```

## 🎊 You're Done!

Open http://localhost:3000 and enjoy your secure login app!
