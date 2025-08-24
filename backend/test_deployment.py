#!/usr/bin/env python3
"""
Test script for Render deployment
Run this to test your backend before deploying
"""

import requests
import json
import sys

def test_backend_locally():
    """Test the local backend setup"""
    print("🧪 Testing local backend setup...")
    
    base_url = "http://localhost:5000"
    
    try:
        # Test health endpoint
        print(f"Testing {base_url}/api/health")
        response = requests.get(f"{base_url}/api/health", timeout=5)
        
        if response.status_code == 200:
            print("✅ Health check passed")
            print(f"Response: {response.json()}")
        else:
            print(f"❌ Health check failed: {response.status_code}")
            return False
            
        # Test signup
        print(f"\nTesting {base_url}/api/auth/signup")
        signup_data = {
            "name": "Test User",
            "email": "test@example.com",
            "password": "testpass123",
            "user_type": "Individual"
        }
        
        response = requests.post(f"{base_url}/api/auth/signup", 
                               json=signup_data, 
                               timeout=5)
        
        if response.status_code in [201, 409]:  # 201 = created, 409 = already exists
            print("✅ Signup endpoint working")
            if response.status_code == 201:
                print("✅ Test user created successfully")
            else:
                print("ℹ️ Test user already exists")
        else:
            print(f"❌ Signup failed: {response.status_code}")
            print(f"Response: {response.text}")
            
        # Test login
        print(f"\nTesting {base_url}/api/auth/login")
        login_data = {
            "email": "test@example.com",
            "password": "testpass123"
        }
        
        response = requests.post(f"{base_url}/api/auth/login", 
                               json=login_data, 
                               timeout=5)
        
        if response.status_code == 200:
            print("✅ Login endpoint working")
            data = response.json()
            print(f"✅ Received JWT token: {data.get('token', 'N/A')[:20]}...")
            return True
        else:
            print(f"❌ Login failed: {response.status_code}")
            print(f"Response: {response.text}")
            return False
            
    except requests.exceptions.ConnectionError:
        print("❌ Could not connect to local backend")
        print("Make sure to run: python app_render.py")
        return False
    except Exception as e:
        print(f"❌ Unexpected error: {e}")
        return False

def test_render_deployment(render_url):
    """Test the deployed backend on Render"""
    print(f"\n🌐 Testing Render deployment at {render_url}...")
    
    try:
        # Test health endpoint
        print(f"Testing {render_url}/api/health")
        response = requests.get(f"{render_url}/api/health", timeout=30)
        
        if response.status_code == 200:
            print("✅ Render deployment is working!")
            data = response.json()
            print(f"Environment: {data.get('environment', 'unknown')}")
            print(f"Database: {data.get('database', 'unknown')}")
            return True
        else:
            print(f"❌ Render deployment failed: {response.status_code}")
            return False
            
    except requests.exceptions.ConnectionError:
        print("❌ Could not connect to Render deployment")
        print("Check if the URL is correct and deployment is complete")
        return False
    except Exception as e:
        print(f"❌ Unexpected error: {e}")
        return False

if __name__ == "__main__":
    print("🚀 Connect & Contribute Backend Test")
    print("=" * 40)
    
    # Test local setup
    local_success = test_backend_locally()
    
    # Test Render deployment if URL provided
    if len(sys.argv) > 1:
        render_url = sys.argv[1].rstrip('/')
        render_success = test_render_deployment(render_url)
    else:
        print("\n💡 To test Render deployment, run:")
        print("python test_deployment.py https://your-app-name.onrender.com")
        render_success = None
    
    print("\n" + "=" * 40)
    print("📊 Test Results:")
    print(f"Local Backend: {'✅ PASS' if local_success else '❌ FAIL'}")
    if render_success is not None:
        print(f"Render Deployment: {'✅ PASS' if render_success else '❌ FAIL'}")
    
    if local_success:
        print("\n🎉 Your backend is ready for Render deployment!")
    else:
        print("\n⚠️ Fix local backend issues before deploying to Render")
