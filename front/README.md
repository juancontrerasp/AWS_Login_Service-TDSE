# 🎨 Frontend - Secure Login Application

Simple, clean frontend for the secure login service.

## 📁 Files

- `index.html` - Login & Registration page
- `dashboard.html` - User dashboard (after login)
- `styles.css` - Styling for all pages
- `app.js` - Login/Register functionality
- `dashboard.js` - Dashboard functionality
- `server.py` - Simple Python HTTP server

## 🚀 Quick Start

### Option 1: Python HTTP Server (Recommended)

```bash
# From the front/ directory
python3 server.py
```

Then open: http://localhost:3000

### Option 2: Any HTTP Server

```bash
# Using Python
python3 -m http.server 3000

# Using Node.js (if installed)
npx serve -p 3000

# Using PHP (if installed)
php -S localhost:3000
```

## 🔗 Architecture

```
┌─────────────────┐         HTTPS (Production)      ┌──────────────────┐
│                 │         HTTP (Development)        │                  │
│  Frontend       │────────────────────────────────>│  Backend API     │
│  (Port 3000)    │         Async Fetch Requests     │  (Port 8080)     │
│                 │<────────────────────────────────│                  │
└─────────────────┘         JSON + JWT               └──────────────────┘
  - index.html                                         - Spring Boot
  - dashboard.html                                     - PostgreSQL
  - JavaScript (Async)                                 - JWT Auth
                                                       - BCrypt Hashing
```

## 🎯 Features

### Login Page (`index.html`)
- ✅ Login form
- ✅ Registration form
- ✅ Tab switching between login/register
- ✅ Async API calls (fetch)
- ✅ Error handling
- ✅ Success messages

### Dashboard (`dashboard.html`)
- ✅ Welcome message with username
- ✅ User avatar with initial
- ✅ Display user information
- ✅ Logout functionality
- ✅ Test protected API endpoint
- ✅ JWT token management

## 🔐 Security Features

- **Async Communication**: All API calls use async fetch
- **JWT Storage**: Token stored in localStorage
- **CORS Configured**: Backend allows requests from frontend
- **TLS Ready**: Works with HTTPS in production
- **Auto-redirect**: Redirects to login if not authenticated

## 🧪 Testing the Frontend

1. **Start Backend** (if not running):
   ```bash
   cd ../back
   docker compose up -d
   ```

2. **Start Frontend**:
   ```bash
   python3 server.py
   ```

3. **Open Browser**: http://localhost:3000

4. **Register a User**:
   - Click "Register" tab
   - Fill in username, email, password
   - Click "Register"

5. **Login**:
   - Click "Login" tab
   - Enter credentials
   - Click "Login"

6. **Dashboard**:
   - See welcome message
   - View your user info
   - Test the API endpoint
   - Logout when done

## 📝 API Endpoints Used

| Endpoint | Method | Purpose |
|----------|--------|---------|
| `/api/auth/register` | POST | Create new user |
| `/api/auth/login` | POST | Authenticate & get JWT |
| `/api/auth/me` | GET | Get current user info (protected) |

## 🎨 Styling

- Modern gradient background
- Card-based layout
- Responsive design
- Smooth animations
- Clean, professional look

## 🔧 Customization

### Change API URL

Edit `app.js` and `dashboard.js`:
```javascript
const API_BASE_URL = 'http://localhost:8080';  // Change this
```

### Change Frontend Port

Edit `server.py`:
```python
PORT = 3000  # Change this
```

### Styling

Edit `styles.css` to customize colors, fonts, spacing, etc.

## 🌐 Production Deployment

For production, serve these files through Apache with TLS:

1. Copy files to `/var/www/html/`
2. Update `API_BASE_URL` to your production domain
3. Configure Apache to serve static files
4. Enable HTTPS with Let's Encrypt

## 📱 Browser Compatibility

- ✅ Chrome/Edge (recommended)
- ✅ Firefox
- ✅ Safari
- ✅ Modern mobile browsers

## 🐛 Troubleshooting

### CORS Errors?
Make sure backend `.env` has:
```env
CORS_ALLOWED_ORIGINS=http://localhost:3000,http://localhost:8080
```

### Can't Connect to Backend?
Verify backend is running:
```bash
curl http://localhost:8080/swagger-ui/index.html
```

### Login Not Working?
Check browser console (F12) for errors.

---

Made with ❤️ for TDSE Workshop
