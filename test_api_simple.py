import requests

# Test campaigns API
url = "http://localhost:5000/api/campaigns/all"
try:
    response = requests.get(url)
    print(f"Status: {response.status_code}")
    if response.status_code == 200:
        campaigns = response.json()
        print(f"Found {len(campaigns)} campaigns")
        for i, campaign in enumerate(campaigns[:5]):
            print(f"  {i+1}. {campaign.get('title', 'N/A')}")
    else:
        print(f"Error: {response.text}")
except Exception as e:
    print(f"Error: {e}")
