# Login Service

Secure login microservice built with Spring Boot 3 + Spring Security + PostgreSQL.  
Passwords are stored as **BCrypt hashes** (cost factor 12). Auth is stateless via **JWT**.  
HTTPS is terminated by **Nginx** using **Let's Encrypt** certificates already on your EC2.

---

## Architecture

```
Internet
   │  HTTPS (443)
   ▼
[Apache httpd]  ──── terminates TLS, rate-limits /api/auth/
   │  HTTP (internal Docker network)
   ▼
[Spring Boot :8080]  ──── JWT auth, BCrypt password hashing
   │
   ▼
[PostgreSQL :5432]  ──── stores users + hashed passwords
```

All secrets come from environment variables — never baked into the image (12-Factor III).

---

## Project Structure

```
login-service/
├── src/main/java/com/secure/login/
│   ├── LoginServiceApplication.java
│   ├── config/
│   │   ├── SecurityConfig.java        # Spring Security + CORS + JWT filter chain
│   │   └── GlobalExceptionHandler.java
│   ├── controller/
│   │   └── AuthController.java        # POST /api/auth/register, /login, GET /me
│   ├── dto/
│   │   └── Dtos.java                  # Records for request/response
│   ├── model/
│   │   └── User.java                  # JPA entity
│   ├── repository/
│   │   └── UserRepository.java
│   ├── security/
│   │   ├── JwtUtils.java              # Token generation + validation
│   │   ├── JwtAuthFilter.java         # Per-request JWT extraction
│   │   └── UserDetailsServiceImpl.java
│   └── service/
│       └── AuthService.java           # Register + Login business logic
├── src/main/resources/
│   └── application.properties         # All values from ${ENV_VARS}
├── apache/
│   └── httpd.conf                     # TLS termination + rate limiting
├── Dockerfile                         # Multi-stage build
├── docker-compose.yml
├── .env.example
└── .gitignore
```

---

## API Endpoints

| Method | Path | Auth | Description |
|--------|------|------|-------------|
| POST | `/api/auth/register` | Public | Register new user |
| POST | `/api/auth/login` | Public | Login, receive JWT |
| GET | `/api/auth/me` | Bearer JWT | Get current user info |

### Register
```bash
curl -X POST https://YOUR_DOMAIN/api/auth/register \
  -H "Content-Type: application/json" \
  -d '{"username":"juan","email":"juan@example.com","password":"SecurePass123"}'
```

### Login
```bash
curl -X POST https://YOUR_DOMAIN/api/auth/login \
  -H "Content-Type: application/json" \
  -d '{"username":"juan","password":"SecurePass123"}'
# Returns: { "token": "eyJ...", "tokenType": "Bearer", "username": "juan", "email": "..." }
```

### Authenticated Request
```bash
curl https://YOUR_DOMAIN/api/auth/me \
  -H "Authorization: Bearer eyJ..."
```

---

## Local Development

```bash
# 1. Clone and enter
git clone <your-repo>
cd login-service

# 2. Create your .env
cp .env.example .env
# Edit .env with real values

# 3. Start everything
docker compose up --build

# App runs at http://localhost:8080 (no TLS locally — Nginx handles that on EC2)
```

---

## AWS EC2 Deployment

### Prerequisites
- EC2 instance with Docker + Docker Compose installed
- Domain pointed at your EC2 public IP
- Let's Encrypt certificate already issued via Certbot (you mentioned this is done)

### Steps

**1. SSH into your EC2 instance**
```bash
ssh -i your-key.pem ec2-user@YOUR_EC2_IP
```

**2. Clone your repo**
```bash
git clone <your-repo>
cd login-service
```

**3. Create your .env**
```bash
cp .env.example .env
nano .env   # Fill in real values
```

**4. Update httpd.conf with your domain**
```bash
# Replace every occurrence of YOUR_DOMAIN
sed -i 's/YOUR_DOMAIN/api.yourdomain.com/g' apache/httpd.conf
```

**5. Verify Certbot cert path**
```bash
# Should exist — you said the cert is already issued
ls /etc/letsencrypt/live/YOUR_DOMAIN/
# fullchain.pem  privkey.pem
```

**6. Open EC2 Security Group ports**  
In the AWS Console → EC2 → Security Groups → Inbound Rules:
- Port 80 (HTTP) — for redirect
- Port 443 (HTTPS) — for traffic

**7. Deploy**
```bash
docker compose up -d --build
```

**8. Verify**
```bash
docker compose ps          # all containers should be Up
docker compose logs -f     # watch logs
curl https://YOUR_DOMAIN/actuator/health
```

---

## Security Decisions

| Decision | Reason |
|----------|--------|
| BCrypt cost 12 | Strong enough to resist brute force; ~300ms per hash |
| Stateless JWT | No server-side sessions — scales across multiple instances |
| HTTPS via Nginx | TLS terminated at the edge; app never sees plain text from outside |
| Secrets via ENV | 12-Factor App principle III — no secrets in code or Docker image |
| Rate limiting on `/api/auth/` | 10 req/min per IP — slows credential stuffing |
| Non-root Docker user | Limits blast radius if the container is compromised |
| Generic auth error messages | Never reveal whether username or password was wrong |
| CORS allowlist | Only your frontend origin can make credentialed requests |

---

## Connecting Your Frontend

Set the base URL in your frontend to `https://YOUR_DOMAIN`.

On login success, store the JWT (prefer `httpOnly` cookie or in-memory state — avoid `localStorage`).  
Send it on every protected request:

```js
// Example fetch
fetch('https://YOUR_DOMAIN/api/auth/me', {
  headers: { 'Authorization': `Bearer ${token}` }
});
```

The CORS config already allows credentials from `CORS_ALLOWED_ORIGINS`.  
When your frontend is deployed on its own EC2/instance, just add its domain to `.env`:

```
CORS_ALLOWED_ORIGINS=https://your-frontend.com
```

Then restart: `docker compose up -d`.

---

## Future Extensions (when ready)

- Add `RefreshToken` entity + `/api/auth/refresh` endpoint
- Add `ADMIN` role + admin-only endpoints using `@PreAuthorize("hasRole('ADMIN')")`
- Add Spring Actuator metrics + Prometheus scraping
- Add mutual TLS (mTLS) between services if you add a second backend (as shown in the PDF challenge)
