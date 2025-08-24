#!/usr/bin/env python3
"""
Quick setup script for local development and testing
"""

import subprocess
import sys
import os

def run_command(command, description):
    """Run a command and handle errors"""
    print(f"🔧 {description}...")
    try:
        result = subprocess.run(command, shell=True, check=True, capture_output=True, text=True)
        print(f"✅ {description} completed")
        return True
    except subprocess.CalledProcessError as e:
        print(f"❌ {description} failed:")
        print(f"Error: {e.stderr}")
        return False

def main():
    print("🚀 Connect & Contribute Backend Setup")
    print("=" * 40)
    
    # Check if we're in the right directory
    if not os.path.exists("app_render.py"):
        print("❌ Please run this script from the backend directory")
        return
    
    # Install dependencies
    if not run_command("pip install -r requirements_render.txt", "Installing dependencies"):
        print("💡 Try: pip install --user -r requirements_render.txt")
        return
    
    # Test the backend
    print("\n🧪 Testing backend setup...")
    if run_command("python test_deployment.py", "Running backend tests"):
        print("\n🎉 Backend setup completed successfully!")
        print("\n📝 Next steps:")
        print("1. Follow RENDER_DEPLOYMENT_GUIDE.md to deploy to Render")
        print("2. Update the Render URL in Flutter app")
        print("3. Test your app from any device!")
    else:
        print("\n⚠️ Backend tests failed. Check the errors above.")

if __name__ == "__main__":
    main()
