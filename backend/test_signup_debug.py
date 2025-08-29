#!/usr/bin/env python3
"""
Test script to debug signup issues on Render deployment
"""
import requests
import json
import os

# Use your actual Render URL - replace with your real URL
RENDER_URL = os.environ.get('RENDER_URL', 'https://your-app-name.onrender.com')
BASE_URL = f"{RENDER_URL}/api"

def test_signup_debug():
    """Test signup with detailed debugging"""
    print("🔍 Testing signup with debugging...")
    
    # Test user data
    test_user = {
        "name": "Test User Debug",
        "email": "testdebug@example.com",
        "password": "testpass123",
        "user_type": "Individual"
    }
    
    try:
        print(f"📤 Sending signup request to: {BASE_URL}/auth/signup")
        print(f"📧 User data: {test_user}")
        
        response = requests.post(
            f"{BASE_URL}/auth/signup", 
            json=test_user,
            timeout=30,
            headers={'Content-Type': 'application/json'}
        )
        
        print(f"📥 Response status: {response.status_code}")
        print(f"📥 Response headers: {dict(response.headers)}")
        
        try:
            response_data = response.json()
            print(f"📥 Response data: {json.dumps(response_data, indent=2)}")
        except:
            print(f"📥 Response text: {response.text}")
        
        if response.status_code == 201:
            print("✅ Signup successful!")
            
            # Now test if user exists in database by trying to login
            print("\n🔍 Testing login to verify user was saved...")
            login_data = {
                "email": test_user["email"],
                "password": test_user["password"]
            }
            
            login_response = requests.post(
                f"{BASE_URL}/auth/login",
                json=login_data,
                timeout=30,
                headers={'Content-Type': 'application/json'}
            )
            
            print(f"📥 Login response status: {login_response.status_code}")
            if login_response.status_code == 200:
                print("✅ User found in database - signup worked correctly!")
            else:
                print("❌ User not found in database - signup didn't save to DB!")
                print(f"📥 Login response: {login_response.text}")
                
        else:
            print(f"❌ Signup failed with status {response.status_code}")
            
    except Exception as e:
        print(f"❌ Request failed: {e}")

def test_health_check():
    """Test health check to verify database connection"""
    print("\n🏥 Testing health check...")
    
    try:
        response = requests.get(f"{BASE_URL}/health", timeout=30)
        print(f"📥 Health check status: {response.status_code}")
        
        if response.status_code == 200:
            health_data = response.json()
            print(f"📥 Health data: {json.dumps(health_data, indent=2)}")
        else:
            print(f"📥 Health response: {response.text}")
            
    except Exception as e:
        print(f"❌ Health check failed: {e}")

if __name__ == "__main__":
    print("🚀 Starting signup debugging...")
    print(f"🌐 Base URL: {BASE_URL}")
    
    # First test health check
    test_health_check()
    
    # Then test signup
    test_signup_debug()
    
    print("\n🔚 Debug test completed!")
