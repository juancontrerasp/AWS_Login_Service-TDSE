#!/usr/bin/env python3
"""
Simple HTTP server to serve the frontend application.
Run this script to test the frontend locally.
"""

import http.server
import socketserver
import os

PORT = 3000
DIRECTORY = os.path.dirname(os.path.abspath(__file__))

class MyHTTPRequestHandler(http.server.SimpleHTTPRequestHandler):
    def __init__(self, *args, **kwargs):
        super().__init__(*args, directory=DIRECTORY, **kwargs)
    
    def end_headers(self):
        # Add CORS headers to allow requests from frontend to backend
        self.send_header('Access-Control-Allow-Origin', '*')
        self.send_header('Access-Control-Allow-Methods', 'GET, POST, OPTIONS')
        self.send_header('Access-Control-Allow-Headers', 'Content-Type, Authorization')
        super().end_headers()

if __name__ == '__main__':
    Handler = MyHTTPRequestHandler
    
    with socketserver.TCPServer(("", PORT), Handler) as httpd:
        print(f"""
╔════════════════════════════════════════════════════════════════╗
║              🌐 Frontend Server Started                       ║
╚════════════════════════════════════════════════════════════════╝

📍 Frontend URL:  http://localhost:{PORT}
🔗 Backend API:   http://localhost:8080

📄 Pages:
   • Login:       http://localhost:{PORT}/index.html
   • Dashboard:   http://localhost:{PORT}/dashboard.html

Press Ctrl+C to stop the server...
        """)
        
        try:
            httpd.serve_forever()
        except KeyboardInterrupt:
            print("\n\n🛑 Server stopped.")
