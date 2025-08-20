#!/usr/bin/env python3
"""
Connect & Contribute Backend Server Startup Script

This script starts the Flask backend server with proper configuration.
Use this script to easily start the backend server from the command line.

Usage:
    python start_server.py
    or
    python3 start_server.py
"""

import os
import sys
import subprocess
from pathlib import Path

def check_python_version():
    """Check if Python version is compatible"""
    if sys.version_info < (3, 8):
        print("Error: Python 3.8 or higher is required")
        print(f"Current version: {sys.version}")
        sys.exit(1)
    print(f"✓ Python version: {sys.version}")

def check_requirements():
    """Check if requirements.txt exists and install dependencies"""
    requirements_path = Path("requirements.txt")
    if not requirements_path.exists():
        print("Error: requirements.txt not found")
        print("Make sure you're running this script from the backend directory")
        sys.exit(1)
    
    print("✓ Found requirements.txt")
    
    # Check if Flask is installed
    try:
        import flask
        print(f"✓ Flask is installed (version: {flask.__version__})")
    except ImportError:
        print("Installing dependencies from requirements.txt...")
        try:
            subprocess.check_call([sys.executable, "-m", "pip", "install", "-r", "requirements.txt"])
            print("✓ Dependencies installed successfully")
        except subprocess.CalledProcessError as e:
            print(f"Error installing dependencies: {e}")
            print("Please install dependencies manually: pip install -r requirements.txt")
            sys.exit(1)

def start_server():
    """Start the Flask server"""
    print("\n" + "="*50)
    print("Starting Connect & Contribute Backend Server")
    print("="*50)
    
    # Set environment variables
    os.environ['FLASK_APP'] = 'app.py'
    os.environ['FLASK_ENV'] = 'development'
    os.environ['FLASK_DEBUG'] = '1'
    
    print("Server Configuration:")
    print("- Host: 0.0.0.0 (accessible from all network interfaces)")
    print("- Port: 5000")
    print("- Debug Mode: Enabled")
    print("- Auto-reload: Enabled")
    print("\nAPI Endpoints will be available at:")
    print("- Local: http://localhost:5000/api")
    print("- Network: http://[your-ip]:5000/api")
    print("\nPress Ctrl+C to stop the server")
    print("="*50 + "\n")
    
    try:
        # Import and run the app
        from app import app
        app.run(
            host='0.0.0.0',  # Allow connections from any IP
            port=5000,
            debug=True,
            use_reloader=True,
            threaded=True
        )
    except ImportError as e:
        print(f"Error importing app: {e}")
        print("Make sure app.py exists in the current directory")
        sys.exit(1)
    except KeyboardInterrupt:
        print("\n\nServer stopped by user")
    except Exception as e:
        print(f"Error starting server: {e}")
        sys.exit(1)

def main():
    """Main function"""
    print("Connect & Contribute Backend Server Startup")
    print("==========================================\n")
    
    # Check current directory
    current_dir = Path.cwd()
    print(f"Current directory: {current_dir}")
    
    # Check if we're in the right directory
    if not Path("app.py").exists():
        print("Error: app.py not found in current directory")
        print("Please navigate to the backend directory first")
        print("Example: cd backend/")
        sys.exit(1)
    
    print("✓ Found app.py")
    
    # Run checks
    check_python_version()
    check_requirements()
    
    # Start server
    start_server()

if __name__ == "__main__":
    main()