// API Configuration
const API_BASE_URL = 'http://localhost:8080';

// Check authentication
function checkAuth() {
    const token = localStorage.getItem('token');
    if (!token) {
        // Not logged in, redirect to login page
        window.location.href = 'index.html';
        return null;
    }
    return token;
}

// Load user information
function loadUserInfo() {
    const username = localStorage.getItem('username');
    const email = localStorage.getItem('email');
    
    if (username) {
        // Set user initial (first letter of username)
        document.getElementById('userInitial').textContent = username.charAt(0).toUpperCase();
        document.getElementById('userName').textContent = username;
        document.getElementById('usernameDisplay').textContent = username;
    }
    
    if (email) {
        document.getElementById('userEmail').textContent = email;
        document.getElementById('emailDisplay').textContent = email;
    }
}

// Logout function
function logout() {
    // Clear all stored data
    localStorage.removeItem('token');
    localStorage.removeItem('username');
    localStorage.removeItem('email');
    
    // Redirect to login page
    window.location.href = 'index.html';
}

// Test protected API endpoint
async function testProtectedAPI() {
    const token = checkAuth();
    if (!token) return;
    
    const apiResponse = document.getElementById('apiResponse');
    apiResponse.textContent = 'Loading...';
    apiResponse.classList.add('show');
    
    try {
        const response = await fetch(`${API_BASE_URL}/api/auth/me`, {
            method: 'GET',
            headers: {
                'Authorization': `Bearer ${token}`,
                'Content-Type': 'application/json'
            }
        });
        
        const data = await response.json();
        
        if (response.ok) {
            // Format JSON response
            apiResponse.textContent = JSON.stringify(data, null, 2);
        } else {
            apiResponse.textContent = `Error: ${response.status}\n${JSON.stringify(data, null, 2)}`;
            
            // If token is invalid, logout
            if (response.status === 401) {
                alert('Session expired. Please login again.');
                logout();
            }
        }
    } catch (error) {
        console.error('API test error:', error);
        apiResponse.textContent = `Network Error: ${error.message}`;
    }
}

// Initialize dashboard
window.addEventListener('DOMContentLoaded', () => {
    // Check if user is authenticated
    checkAuth();
    
    // Load user information
    loadUserInfo();
    
    // Add logout button handler
    document.getElementById('logoutBtn').addEventListener('click', logout);
    
    // Add API test button handler
    document.getElementById('testApiBtn').addEventListener('click', testProtectedAPI);
});
