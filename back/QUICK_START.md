# 🎯 Quick Reference Card

## Start Application (Docker Compose)
```bash
cd /home/minin/storage/Uni/TDSE/AWS_Login_Service-TDSE/back
docker compose up -d --build
```

## Access Points
- **API Base**: http://localhost:8080
- **Swagger UI**: http://localhost:8080/swagger-ui.html
- **API Docs**: http://localhost:8080/v3/api-docs
- **Health Check**: http://localhost:8080/actuator/health

## Quick Test Commands

### 1. Register User
```bash
curl -X POST http://localhost:8080/api/auth/register \
  -H "Content-Type: application/json" \
  -d '{"username":"demo","email":"demo@example.com","password":"Demo123!"}'
```

### 2. Login (Get JWT Token)
```bash
curl -X POST http://localhost:8080/api/auth/login \
  -H "Content-Type: application/json" \
  -d '{"username":"demo","password":"Demo123!"}'
```

### 3. Access Protected Endpoint
```bash
# Replace TOKEN with the actual token from login response
curl http://localhost:8080/api/auth/me \
  -H "Authorization: Bearer TOKEN"
```

## Useful Commands
```bash
# View logs
docker compose logs -f

# Stop application
docker compose down

# Restart clean (removes database!)
docker compose down -v && docker compose up -d --build

# Check status
docker compose ps
```

## Environment Variables (.env)
```env
DB_PASSWORD=strongpassword101
JWT_SECRET=lkV5Il7OATrJb32/pR6LjLK++SgJylmshSDGAmYwzFc=
CORS_ALLOWED_ORIGINS=http://localhost:3000
```

## Swagger UI Authentication
1. Open: http://localhost:8080/swagger-ui.html
2. Login via `/api/auth/login` endpoint
3. Copy the `token` from response
4. Click "Authorize" button (🔓)
5. Enter: `Bearer YOUR_TOKEN`
6. Click "Authorize"
7. Now you can test protected endpoints!
