#!/usr/bin/env python3
"""
Simple script to start the Connect & Contribute backend server
"""

import subprocess
import sys
import os
from pathlib import Path

def check_python():
    """Check if Python 3 is available"""
    try:
        result = subprocess.run([sys.executable, '--version'], capture_output=True, text=True)
        print(f"Using Python: {result.stdout.strip()}")
        return True
    except Exception as e:
        print(f"Python check failed: {e}")
        return False

def install_requirements():
    """Install required packages"""
    try:
        print("Installing requirements...")
        subprocess.run([sys.executable, '-m', 'pip', 'install', '-r', 'requirements.txt'], check=True)
        print("Requirements installed successfully!")
        return True
    except subprocess.CalledProcessError as e:
        print(f"Failed to install requirements: {e}")
        return False

def start_server():
    """Start the Flask server"""
    try:
        print("Starting Connect & Contribute Backend Server...")
        print("Server will be available at: http://localhost:5000")
        print("API endpoints will be available at: http://localhost:5000/api")
        print("Press Ctrl+C to stop the server")
        print("-" * 50)
        
        # Start the server
        subprocess.run([sys.executable, 'app.py'], check=True)
        
    except KeyboardInterrupt:
        print("\nServer stopped by user")
    except subprocess.CalledProcessError as e:
        print(f"Failed to start server: {e}")
        return False
    except Exception as e:
        print(f"Unexpected error: {e}")
        return False

def main():
    """Main function"""
    print("=" * 50)
    print("Connect & Contribute Backend Server Starter")
    print("=" * 50)
    
    # Check if we're in the backend directory
    if not Path('app.py').exists():
        print("Error: app.py not found. Please run this script from the backend directory.")
        return False
    
    if not Path('requirements.txt').exists():
        print("Error: requirements.txt not found. Please run this script from the backend directory.")
        return False
    
    # Check Python
    if not check_python():
        return False
    
    # Install requirements
    if not install_requirements():
        return False
    
    # Start server
    start_server()
    
    return True

if __name__ == '__main__':
    success = main()
    if not success:
        sys.exit(1)