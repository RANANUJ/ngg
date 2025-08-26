#!/usr/bin/env python3
"""
Test script to simulate the Flutter app's campaign fetching behavior
"""
import requests
import json

# Test the campaign endpoints
base_url = "http://localhost:5000/api"

# First, let's try to login to get a token
def test_login():
    print("=== Testing Login ===")
    login_data = {
        "email": "anuj@gmail.com",  # The user who created the campaigns
        "password": "123456"  # Assuming this is the password
    }
    
    try:
        response = requests.post(f"{base_url}/auth/login", json=login_data)
        print(f"Login Status: {response.status_code}")
        if response.status_code == 200:
            data = response.json()
            token = data.get('access_token')
            print(f"Login successful! Token: {token[:20]}..." if token else "No token received")
            return token
        else:
            print(f"Login failed: {response.text}")
            return None
    except Exception as e:
        print(f"Login error: {e}")
        return None

def test_get_user_campaigns(token):
    print("\n=== Testing Get User Campaigns ===")
    headers = {
        "Authorization": f"Bearer {token}",
        "Content-Type": "application/json"
    }
    
    try:
        response = requests.get(f"{base_url}/campaigns", headers=headers)
        print(f"Get Campaigns Status: {response.status_code}")
        print(f"Response: {response.text}")
        
        if response.status_code == 200:
            campaigns = response.json()
            print(f"Found {len(campaigns)} campaigns")
            for i, campaign in enumerate(campaigns):
                print(f"  Campaign {i+1}: {campaign.get('title', 'N/A')}")
        
    except Exception as e:
        print(f"Get campaigns error: {e}")

def test_get_all_campaigns():
    print("\n=== Testing Get All Campaigns (No Auth) ===")
    try:
        response = requests.get(f"{base_url}/campaigns/all")
        print(f"Get All Campaigns Status: {response.status_code}")
        print(f"Response: {response.text}")
        
        if response.status_code == 200:
            campaigns = response.json()
            print(f"Found {len(campaigns)} public campaigns")
            for i, campaign in enumerate(campaigns):
                print(f"  Campaign {i+1}: {campaign.get('title', 'N/A')}")
        
    except Exception as e:
        print(f"Get all campaigns error: {e}")

if __name__ == "__main__":
    print("Testing Campaign Fetch Endpoints")
    print("=" * 50)
    
    # Test login first
    token = test_login()
    
    if token:
        # Test authenticated endpoint
        test_get_user_campaigns(token)
    
    # Test public endpoint
    test_get_all_campaigns()
