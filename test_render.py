#!/usr/bin/env python3
"""
Test your Render deployment and Flutter app connectivity
"""

import requests
import json
import time

def test_render_backend():
    """Test the deployed backend on Render"""
    render_url = "https://ngg.onrender.com"
    
    print("🌐 Testing Render Backend Deployment")
    print("=" * 50)
    
    try:
        print(f"📡 Testing: {render_url}/api/health")
        print("⏳ Please wait... (first request may take 30-60 seconds if app was sleeping)")
        
        # First request might be slow due to cold start
        response = requests.get(f"{render_url}/api/health", timeout=90)
        
        if response.status_code == 200:
            data = response.json()
            print("✅ SUCCESS! Backend is running on Render")
            print(f"   Status: {data.get('status')}")
            print(f"   Environment: {data.get('environment')}")
            print(f"   Database: {data.get('database')}")
            
            # Test login endpoint
            print(f"\n📡 Testing: {render_url}/api/auth/login")
            login_data = {
                "email": "test@example.com",
                "password": "testpass123"
            }
            
            login_response = requests.post(f"{render_url}/api/auth/login", 
                                         json=login_data, 
                                         timeout=30)
            
            if login_response.status_code == 200:
                login_result = login_response.json()
                print("✅ SUCCESS! Login endpoint working")
                print(f"   User: {login_result.get('user', {}).get('name')}")
                print(f"   Type: {login_result.get('user', {}).get('user_type')}")
                print(f"   Token: {login_result.get('token', '')[:20]}...")
                
                print("\n🎉 RENDER DEPLOYMENT SUCCESSFUL!")
                print(f"🌍 Your backend is now accessible worldwide at: {render_url}")
                print("\n📱 Flutter App Configuration:")
                print(f"   Primary URL: {render_url}/api")
                print("   This will work from any device, anywhere!")
                
                return True
            else:
                print(f"❌ Login test failed: {login_response.status_code}")
                print(f"   Response: {login_response.text}")
                return False
                
        else:
            print(f"❌ Health check failed: {response.status_code}")
            print(f"   Response: {response.text}")
            return False
            
    except requests.exceptions.Timeout:
        print("⏰ Request timed out. This might happen if:")
        print("   1. App is still starting up (try again in 1-2 minutes)")
        print("   2. Render service is sleeping (first request takes longer)")
        print("   3. There's a configuration issue")
        return False
    except requests.exceptions.ConnectionError:
        print("❌ Could not connect to Render deployment")
        print("   Check if the deployment completed successfully")
        return False
    except Exception as e:
        print(f"❌ Unexpected error: {e}")
        return False

def show_development_workflow():
    """Show the development workflow"""
    print("\n" + "=" * 60)
    print("🚀 YOUR DEVELOPMENT WORKFLOW")
    print("=" * 60)
    print("\n📝 Development Process:")
    print("1. Make code changes locally")
    print("2. Test locally (optional): python app.py")
    print("3. Commit and push: git add . && git commit -m 'message' && git push")
    print("4. Render auto-deploys (2-3 minutes)")
    print("5. Test on any device using: https://ngg.onrender.com")
    
    print("\n📱 Flutter App Testing:")
    print("- flutter run -d chrome  (local web testing)")
    print("- flutter run -d <android-device>  (uses Render URL automatically)")
    print("- Your app will work from ANY WiFi network now!")
    
    print("\n🔗 Important URLs:")
    print("- Backend API: https://ngg.onrender.com/api")
    print("- Health Check: https://ngg.onrender.com/api/health")
    print("- Login Endpoint: https://ngg.onrender.com/api/auth/login")
    
    print("\n✨ Benefits:")
    print("✅ No more WiFi/IP address issues")
    print("✅ Test from any device, anywhere")
    print("✅ Share with team members easily")
    print("✅ Real-world testing environment")

if __name__ == "__main__":
    print("🧪 Connect & Contribute - Render Deployment Test")
    print("=" * 60)
    
    success = test_render_backend()
    
    if success:
        show_development_workflow()
    else:
        print("\n🔧 Troubleshooting Steps:")
        print("1. Check Render dashboard for deployment status")
        print("2. Verify environment variables are set")
        print("3. Check build and start commands are correct")
        print("4. Wait 2-3 minutes and try again")
        print("5. Check Render logs for error details")
    
    print(f"\n💡 Run this test anytime: python test_render.py")
