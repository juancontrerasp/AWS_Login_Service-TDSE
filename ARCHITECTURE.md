# 🏛️ Architecture Design Document
## Secure Login Application - TDSE Workshop

**Version**: 1.0  
**Date**: March 2026  
**Author**: Enterprise Architecture Workshop Team

---

## 1. Executive Summary

This document outlines the architecture of a secure, scalable login application deployed on AWS infrastructure. The system implements industry best practices for security, including TLS encryption, JWT authentication, and BCrypt password hashing.

### Key Features
- **Two-tier architecture** (Frontend + Backend)
- **TLS/HTTPS encryption** on all communication
- **Stateless JWT authentication**
- **BCrypt password hashing** (cost factor 12)
- **Containerized deployment** with Docker
- **AWS cloud infrastructure**

---

## 2. System Architecture

### 2.1 High-Level Architecture

```
┌─────────────────────────────────────────────────────────────┐
│                         Internet                             │
│                      (HTTPS/TLS)                            │
└─────────────────┬───────────────────────┬───────────────────┘
                  │                       │
                  │ HTTPS:443             │ HTTPS:443
                  ▼                       ▼
      ┌───────────────────────┐  ┌───────────────────────┐
      │   Server 1             │  │   Server 2            │
      │   Frontend Server      │  │   Backend Server      │
      │                        │  │                       │
      │  ┌──────────────────┐  │  │  ┌─────────────────┐ │
      │  │ Apache HTTP      │  │  │  │ Apache (Proxy)  │ │
      │  │ Port 443 (HTTPS) │  │  │  │ Port 443 (HTTPS)│ │
      │  │                  │  │  │  │                 │ │
      │  │ Static Files:    │  │  │  └────────┬────────┘ │
      │  │ • index.html     │  │  │           │ HTTP:8080│
      │  │ • dashboard.html │  │  │           ▼          │
      │  │ • styles.css     │  │  │  ┌─────────────────┐ │
      │  │ • app.js         │  │  │  │ Spring Boot     │ │
      │  │ • dashboard.js   │  │  │  │ Port 8080       │ │
      │  └──────────────────┘  │  │  │                 │ │
      │                        │  │  │ • RESTful API   │ │
      │  Let's Encrypt Cert    │  │  │ • JWT Auth      │ │
      │  frontend.domain.com   │  │  │ • Security      │ │
      └────────────────────────┘  │  └────────┬────────┘ │
                                  │           │ JDBC     │
                                  │           ▼          │
                                  │  ┌─────────────────┐ │
                                  │  │ PostgreSQL DB   │ │
                                  │  │ Port 5432       │ │
                                  │  │                 │ │
                                  │  │ • User data     │ │
                                  │  │ • Hashed pwd    │ │
                                  │  └─────────────────┘ │
                                  │                       │
                                  │  Let's Encrypt Cert   │
                                  │  api.domain.com       │
                                  └───────────────────────┘
```

### 2.2 Component Descriptions

#### Server 1: Frontend (Apache + Static Files)
**Purpose**: Serve client-side application over HTTPS

**Components**:
- **Apache HTTP Server 2.4**: Web server for static content
- **HTML/CSS/JavaScript**: Asynchronous single-page application
- **Let's Encrypt Certificate**: TLS/SSL encryption

**Responsibilities**:
- Serve static files (HTML, CSS, JS)
- TLS termination for client connections
- Security headers (HSTS, CSP, X-Frame-Options)
- HTTP to HTTPS redirection

#### Server 2: Backend (Spring Boot + PostgreSQL)
**Purpose**: Handle business logic, authentication, and data storage

**Components**:
- **Apache HTTP Server**: Reverse proxy + TLS termination
- **Spring Boot 3.2**: Java application framework
- **Spring Security**: Authentication & authorization
- **PostgreSQL 16**: Relational database
- **Let's Encrypt Certificate**: TLS/SSL encryption

**Responsibilities**:
- RESTful API endpoints
- JWT token generation and validation
- Password hashing with BCrypt
- User data persistence
- API request validation
- CORS configuration

---

## 3. Security Architecture

### 3.1 Transport Layer Security (TLS)

**Frontend Server**:
```
Client → HTTPS (TLS 1.2/1.3) → Apache → Static Files
Certificate: Let's Encrypt (frontend.domain.com)
```

**Backend Server**:
```
Client → HTTPS (TLS 1.2/1.3) → Apache → HTTP (internal) → Spring Boot
Certificate: Let's Encrypt (api.domain.com)
```

**Security Measures**:
- TLS 1.2 and 1.3 only (disabled SSLv3, TLSv1.0, TLSv1.1)
- Strong cipher suites (ECDHE, AES-GCM)
- HSTS header (max-age: 1 year)
- Certificate auto-renewal via Certbot

### 3.2 Authentication Flow

```
1. User Registration:
   Client → POST /api/auth/register
   {username, email, password} → BCrypt Hash → Database

2. User Login:
   Client → POST /api/auth/login
   {username, password} → Verify BCrypt → Generate JWT → Return Token

3. Authenticated Request:
   Client → GET /api/auth/me
   Header: Authorization: Bearer <JWT>
   → Validate JWT → Return User Data
```

**JWT Structure**:
```json
{
  "header": {
    "alg": "HS256",
    "typ": "JWT"
  },
  "payload": {
    "sub": "username",
    "iat": 1234567890,
    "exp": 1234654290
  },
  "signature": "..."
}
```

### 3.3 Password Security

**BCrypt Parameters**:
- Algorithm: BCrypt
- Cost Factor: 12
- Salt: Auto-generated per password
- Hash Storage: 60-character string in database

**Example**:
```
Plain: "Password123"
Hash: "$2a$12$N0YN8zBz8oi/.../hash..."
```

### 3.4 CORS Configuration

**Allowed Origins**:
- Production: `https://frontend.yourdomain.com`
- Development: `http://localhost:3000`

**Allowed Methods**: GET, POST, PUT, DELETE, OPTIONS  
**Allowed Headers**: Authorization, Content-Type, Accept  
**Credentials**: Allowed

### 3.5 Security Headers

**Frontend (Apache)**:
```
X-Frame-Options: DENY
X-Content-Type-Options: nosniff
X-XSS-Protection: 1; mode=block
Strict-Transport-Security: max-age=31536000
Content-Security-Policy: default-src 'self'; ...
```

---

## 4. Data Architecture

### 4.1 Database Schema

```sql
CREATE TABLE users (
    id BIGSERIAL PRIMARY KEY,
    username VARCHAR(50) UNIQUE NOT NULL,
    email VARCHAR(100) UNIQUE NOT NULL,
    password VARCHAR(100) NOT NULL,  -- BCrypt hash
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE INDEX idx_username ON users(username);
CREATE INDEX idx_email ON users(email);
```

### 4.2 Data Flow

```
Registration:
  Frontend Form → JSON → HTTPS → Spring Boot → BCrypt Hash → PostgreSQL

Login:
  Frontend Form → JSON → HTTPS → Spring Boot → Verify Hash → Generate JWT
  
Authenticated Request:
  Frontend → HTTPS + JWT → Spring Boot → Validate JWT → Query DB → Response
```

---

## 5. Deployment Architecture

### 5.1 AWS Infrastructure

**EC2 Instances**:
- **Server 1**: t2.micro (1 vCPU, 1 GB RAM) - Frontend
- **Server 2**: t2.small (1 vCPU, 2 GB RAM) - Backend + DB

**Security Groups**:
```
Frontend SG:
  Inbound: 22 (SSH), 80 (HTTP), 443 (HTTPS)
  Outbound: All

Backend SG:
  Inbound: 22 (SSH), 80 (HTTP), 443 (HTTPS)
  Outbound: All
```

**Networking**:
- VPC: Default or custom
- Public subnets for both instances
- Elastic IPs (optional, for static addressing)

### 5.2 Container Architecture

**Frontend Server**:
```yaml
services:
  apache:
    image: httpd:2.4-alpine
    ports: [80:80, 443:443]
    volumes:
      - ./front:/var/www/html
      - /etc/letsencrypt:/etc/letsencrypt
```

**Backend Server**:
```yaml
services:
  postgres:
    image: postgres:16-alpine
    
  spring-boot:
    build: .
    ports: [8080:8080]
    depends_on: [postgres]
    
  apache:
    image: httpd:2.4-alpine
    ports: [80:80, 443:443]
    depends_on: [spring-boot]
```

---

## 6. API Design

### 6.1 Endpoints

| Endpoint | Method | Auth | Description |
|----------|--------|------|-------------|
| `/api/auth/register` | POST | Public | Register new user |
| `/api/auth/login` | POST | Public | Login & get JWT |
| `/api/auth/me` | GET | JWT | Get current user |

### 6.2 Request/Response Examples

**Register**:
```http
POST /api/auth/register
Content-Type: application/json

{
  "username": "john",
  "email": "john@example.com",
  "password": "SecurePass123"
}

Response: 200 OK
{
  "message": "User registered successfully."
}
```

**Login**:
```http
POST /api/auth/login
Content-Type: application/json

{
  "username": "john",
  "password": "SecurePass123"
}

Response: 200 OK
{
  "token": "eyJhbGciOiJIUzI1NiJ9...",
  "tokenType": "Bearer",
  "username": "john",
  "email": "john@example.com"
}
```

---

## 7. Scalability & Performance

### 7.1 Current Capacity
- **Frontend**: Can handle ~1000 concurrent users
- **Backend**: Can handle ~500 requests/second
- **Database**: Suitable for ~10,000 users

### 7.2 Future Scaling Options
1. **Horizontal Scaling**: Add more EC2 instances + load balancer
2. **Database**: Migrate to RDS for managed PostgreSQL
3. **Caching**: Add Redis for session storage
4. **CDN**: Use CloudFront for static assets

---

## 8. Monitoring & Maintenance

### 8.1 Logging
- **Apache**: Access logs + error logs
- **Spring Boot**: Application logs (INFO level)
- **PostgreSQL**: Query logs (disabled by default)

### 8.2 Backup Strategy
- **Database**: Daily automated backups
- **Application Code**: Git repository
- **SSL Certificates**: Auto-renewal via Certbot

### 8.3 Updates
- **SSL Certificates**: Auto-renewed every 60 days
- **Docker Images**: Manual updates quarterly
- **Dependencies**: Security patches monthly

---

## 9. Compliance & Best Practices

### 9.1 Security Standards
- ✅ OWASP Top 10 addressed
- ✅ GDPR considerations (secure password storage)
- ✅ PCI DSS Level 1 compatible (TLS 1.2+)

### 9.2 Best Practices Implemented
- ✅ Principle of Least Privilege
- ✅ Defense in Depth
- ✅ Secure by Default
- ✅ Fail Securely
- ✅ Don't Trust User Input

---

## 10. Conclusion

This architecture provides a secure, scalable foundation for a login application with industry-standard security practices. The two-tier design separates concerns, improves maintainability, and follows cloud-native principles.

**Key Achievements**:
- End-to-end encryption with TLS
- Stateless authentication with JWT
- Secure password storage with BCrypt
- Containerized deployment
- Auto-renewable SSL certificates
- Comprehensive documentation

---

## Appendix A: Technology Stack

| Layer | Technology | Version |
|-------|------------|---------|
| Frontend | HTML/CSS/JavaScript | ES6+ |
| Web Server | Apache HTTP | 2.4 |
| Backend | Spring Boot | 3.2.3 |
| Security | Spring Security | 6.x |
| Database | PostgreSQL | 16 |
| Containerization | Docker | Latest |
| Orchestration | Docker Compose | Latest |
| SSL | Let's Encrypt | Latest |
| Cloud | AWS EC2 | Amazon Linux 2023 |

## Appendix B: References

- [OWASP Secure Coding Practices](https://owasp.org/)
- [Spring Security Documentation](https://spring.io/projects/spring-security)
- [Let's Encrypt Best Practices](https://letsencrypt.org/)
- [AWS EC2 Security Best Practices](https://docs.aws.amazon.com/AWSEC2/latest/UserGuide/ec2-security.html)
