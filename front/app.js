// API Configuration
const API_BASE_URL = 'http://localhost:8080';

// Tab switching functionality
function showTab(tabName) {
    // Hide all tab contents
    document.querySelectorAll('.tab-content').forEach(content => {
        content.classList.remove('active');
    });
    
    // Deactivate all tab buttons
    document.querySelectorAll('.tab-button').forEach(button => {
        button.classList.remove('active');
    });
    
    // Show selected tab
    if (tabName === 'login') {
        document.getElementById('loginForm').classList.add('active');
        document.querySelectorAll('.tab-button')[0].classList.add('active');
    } else {
        document.getElementById('registerForm').classList.add('active');
        document.querySelectorAll('.tab-button')[1].classList.add('active');
    }
}

// Show message (success or error)
function showMessage(elementId, message, isSuccess) {
    const messageEl = document.getElementById(elementId);
    messageEl.textContent = message;
    messageEl.className = `message show ${isSuccess ? 'success' : 'error'}`;
}

// Hide message
function hideMessage(elementId) {
    const messageEl = document.getElementById(elementId);
    messageEl.classList.remove('show');
}

// Set button loading state
function setButtonLoading(button, loading) {
    if (loading) {
        button.disabled = true;
        button.classList.add('loading');
        button.dataset.originalText = button.textContent;
        button.textContent = 'Loading';
    } else {
        button.disabled = false;
        button.classList.remove('loading');
        if (button.dataset.originalText) {
            button.textContent = button.dataset.originalText;
        }
    }
}

// Register Form Handler
document.getElementById('registerForm').addEventListener('submit', async (e) => {
    e.preventDefault();
    hideMessage('registerMessage');
    
    const submitBtn = e.target.querySelector('button[type="submit"]');
    const username = document.getElementById('registerUsername').value.trim();
    const email = document.getElementById('registerEmail').value.trim();
    const password = document.getElementById('registerPassword').value;
    
    // Client-side validation
    if (password.length < 8) {
        showMessage('registerMessage', 'Password must be at least 8 characters long', false);
        return;
    }
    
    setButtonLoading(submitBtn, true);
    
    try {
        console.log('Attempting registration to:', `${API_BASE_URL}/api/auth/register`);
        
        const response = await fetch(`${API_BASE_URL}/api/auth/register`, {
            method: 'POST',
            headers: {
                'Content-Type': 'application/json',
            },
            mode: 'cors',
            body: JSON.stringify({ username, email, password })
        });
        
        const data = await response.json();
        console.log('Registration response:', response.status, data);
        
        if (response.ok) {
            showMessage('registerMessage', '✓ Registration successful! You can now login.', true);
            // Clear form
            document.getElementById('registerForm').reset();
            // Switch to login tab after 1.5 seconds
            setTimeout(() => showTab('login'), 1500);
        } else {
            const errorMsg = data.message || data.error || 'Registration failed. Please try again.';
            showMessage('registerMessage', errorMsg, false);
        }
    } catch (error) {
        console.error('Registration error:', error);
        showMessage('registerMessage', 
            `Cannot connect to backend at ${API_BASE_URL}. Make sure the backend is running (docker compose up -d)`, 
            false);
    } finally {
        setButtonLoading(submitBtn, false);
    }
});

// Login Form Handler
document.getElementById('loginForm').addEventListener('submit', async (e) => {
    e.preventDefault();
    hideMessage('loginMessage');
    
    const submitBtn = e.target.querySelector('button[type="submit"]');
    const username = document.getElementById('loginUsername').value.trim();
    const password = document.getElementById('loginPassword').value;
    
    setButtonLoading(submitBtn, true);
    
    try {
        console.log('Attempting login to:', `${API_BASE_URL}/api/auth/login`);
        
        const response = await fetch(`${API_BASE_URL}/api/auth/login`, {
            method: 'POST',
            headers: {
                'Content-Type': 'application/json',
            },
            mode: 'cors',
            body: JSON.stringify({ username, password })
        });
        
        const data = await response.json();
        console.log('Login response:', response.status, data);
        
        if (response.ok && data.token) {
            // Store JWT token and user info
            localStorage.setItem('token', data.token);
            localStorage.setItem('username', data.username);
            localStorage.setItem('email', data.email);
            
            showMessage('loginMessage', '✓ Login successful! Redirecting...', true);
            
            // Redirect to dashboard
            setTimeout(() => {
                window.location.href = 'dashboard.html';
            }, 800);
        } else {
            const errorMsg = data.message || 'Invalid username or password';
            showMessage('loginMessage', errorMsg, false);
        }
    } catch (error) {
        console.error('Login error:', error);
        showMessage('loginMessage', 
            `Cannot connect to backend at ${API_BASE_URL}. Make sure the backend is running (docker compose up -d)`, 
            false);
    } finally {
        setButtonLoading(submitBtn, false);
    }
});

// Check if already logged in
window.addEventListener('DOMContentLoaded', () => {
    const token = localStorage.getItem('token');
    if (token) {
        // Already logged in, redirect to dashboard
        window.location.href = 'dashboard.html';
    }
    
    // Log API endpoint for debugging
    console.log('Frontend ready. API endpoint:', API_BASE_URL);
    console.log('Testing connection to backend...');
    
    // Test backend connection
    fetch(`${API_BASE_URL}/swagger-ui/index.html`)
        .then(r => console.log('✓ Backend is reachable'))
        .catch(e => console.error('✗ Backend is NOT reachable. Make sure to run: cd back && docker compose up -d'));
});
