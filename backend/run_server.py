# backend/run_server.py
from waitress import serve
from app import app
import os

if __name__ == '__main__':
    # Get the port from environment or default to 5000
    port = int(os.environ.get('PORT', 5000))
    
    # Configure CORS to be more permissive for development
    app.config['CORS_ORIGINS'] = ['*']
    
    print(f"Starting server on http://0.0.0.0:{port}")
    print("Backend will be accessible from:")
    print(f"  - http://localhost:{port}")
    print(f"  - http://192.168.0.136:{port}")
    print("  - Any device on your network")
    print("-" * 50)
    
    # Serve with Waitress
    serve(
        app, 
        host='0.0.0.0', 
        port=port,
        threads=4,
        connection_limit=1000,
        cleanup_interval=30,
        channel_timeout=120
    )