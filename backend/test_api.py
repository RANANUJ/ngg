import requests
import json
import sys

# Configuration
BASE_URL = "https://ngg-2yx3.onrender.com/api"  # Update with your actual Render URL
TEST_USER = {
    "name": "Test NGO",
    "email": "test@ngo.com",
    "password": "testpass123",
    "user_type": "NGO"
}

def test_health():
    """Test health endpoint"""
    print("🔍 Testing health endpoint...")
    try:
        response = requests.get(f"{BASE_URL}/health", timeout=30)
        if response.status_code == 200:
            print("✅ Health check passed")
            return True
        else:
            print(f"❌ Health check failed: {response.status_code}")
            return False
    except Exception as e:
        print(f"❌ Health check error: {e}")
        return False

def test_signup():
    """Test user signup"""
    print("🔍 Testing user signup...")
    try:
        response = requests.post(f"{BASE_URL}/auth/signup", json=TEST_USER, timeout=30)
        if response.status_code in [201, 409]:  # 201 = created, 409 = already exists
            print("✅ Signup test passed")
            return True
        else:
            print(f"❌ Signup failed: {response.status_code} - {response.text}")
            return False
    except Exception as e:
        print(f"❌ Signup error: {e}")
        return False

def test_login():
    """Test user login and return token"""
    print("🔍 Testing user login...")
    try:
        login_data = {
            "email": TEST_USER["email"],
            "password": TEST_USER["password"]
        }
        response = requests.post(f"{BASE_URL}/auth/login", json=login_data, timeout=30)
        if response.status_code == 200:
            data = response.json()
            token = data.get('token')
            print("✅ Login test passed")
            return token
        else:
            print(f"❌ Login failed: {response.status_code} - {response.text}")
            return None
    except Exception as e:
        print(f"❌ Login error: {e}")
        return None

def test_campaigns(token):
    """Test campaign endpoints"""
    print("🔍 Testing campaign endpoints...")
    headers = {"Authorization": f"Bearer {token}"}
    
    # Test get all campaigns (public endpoint)
    try:
        response = requests.get(f"{BASE_URL}/campaigns/all", timeout=30)
        if response.status_code == 200:
            campaigns = response.json()
            print(f"✅ Get all campaigns passed - Found {len(campaigns)} campaigns")
        else:
            print(f"❌ Get all campaigns failed: {response.status_code}")
            return False
    except Exception as e:
        print(f"❌ Get all campaigns error: {e}")
        return False
    
    # Test create campaign
    try:
        campaign_data = {
            "title": "Test Campaign",
            "description": "This is a test campaign created by automated test",
            "category": "Education",
            "target_amount": 10000,
            "end_date": "2024-12-31"
        }
        response = requests.post(f"{BASE_URL}/campaigns", json=campaign_data, headers=headers, timeout=30)
        if response.status_code == 201:
            campaign = response.json()
            campaign_id = campaign.get('_id')
            print(f"✅ Create campaign passed - ID: {campaign_id}")
            return campaign_id
        else:
            print(f"❌ Create campaign failed: {response.status_code} - {response.text}")
            return False
    except Exception as e:
        print(f"❌ Create campaign error: {e}")
        return False

def test_donation_requests(token):
    """Test donation request endpoints"""
    print("🔍 Testing donation request endpoints...")
    headers = {"Authorization": f"Bearer {token}"}
    
    # Test get all donation requests (public endpoint)
    try:
        response = requests.get(f"{BASE_URL}/donation-requests/all", timeout=30)
        if response.status_code == 200:
            requests_data = response.json()
            print(f"✅ Get all donation requests passed - Found {len(requests_data)} requests")
            return True
        else:
            print(f"❌ Get all donation requests failed: {response.status_code}")
            return False
    except Exception as e:
        print(f"❌ Get all donation requests error: {e}")
        return False

def main():
    print("🚀 NGG API Test Suite")
    print("=" * 50)
    print(f"Testing API at: {BASE_URL}")
    print()
    
    # Run tests
    tests_passed = 0
    total_tests = 5
    
    if test_health():
        tests_passed += 1
    
    if test_signup():
        tests_passed += 1
    
    token = test_login()
    if token:
        tests_passed += 1
        
        if test_campaigns(token):
            tests_passed += 1
            
        if test_donation_requests(token):
            tests_passed += 1
    
    print()
    print("=" * 50)
    print(f"📊 Test Results: {tests_passed}/{total_tests} passed")
    
    if tests_passed == total_tests:
        print("🎉 All tests passed! Your API is working correctly.")
        return 0
    else:
        print("⚠️  Some tests failed. Please check the deployment.")
        return 1

if __name__ == "__main__":
    sys.exit(main())
