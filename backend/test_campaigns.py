#!/usr/bin/env python3
"""
Test script to check campaigns in the database
"""

import sys
import os
sys.path.append(os.path.dirname(os.path.abspath(__file__)))

from flask import Flask
from flask_pymongo import PyMongo
from bson import ObjectId
import json
from datetime import datetime

# Same config as main app
app = Flask(__name__)
app.config['MONGO_URI'] = 'mongodb://localhost:27017/connect_contribute'
mongo = PyMongo(app)

def serialize_campaign(campaign):
    """Convert campaign object to JSON-serializable format"""
    if not campaign:
        return None
    
    campaign['_id'] = str(campaign['_id'])
    campaign['created_by'] = str(campaign['created_by'])
    
    if campaign.get('created_at'):
        campaign['created_at'] = campaign['created_at'].isoformat()
    if campaign.get('updated_at'):
        campaign['updated_at'] = campaign['updated_at'].isoformat()
    if campaign.get('end_date'):
        campaign['end_date'] = campaign['end_date'].isoformat()
    
    return campaign

def test_campaigns():
    with app.app_context():
        print("=== Testing Campaigns Database ===\n")
        
        # 1. Check all campaigns
        all_campaigns = list(mongo.db.campaigns.find())
        print(f"Total campaigns in database: {len(all_campaigns)}")
        
        for i, campaign in enumerate(all_campaigns):
            print(f"\nCampaign {i+1}:")
            print(f"  ID: {campaign['_id']}")
            print(f"  Title: {campaign.get('title', 'N/A')}")
            print(f"  Status: {campaign.get('status', 'N/A')}")
            print(f"  Created by: {campaign.get('created_by', 'N/A')}")
            print(f"  Created at: {campaign.get('created_at', 'N/A')}")
            print(f"  Target amount: {campaign.get('target_amount', 'N/A')}")
        
        # 2. Check active campaigns
        active_campaigns = list(mongo.db.campaigns.find({'status': 'active'}))
        print(f"\nActive campaigns: {len(active_campaigns)}")
        
        # 3. Check users
        users = list(mongo.db.users.find())
        print(f"\nTotal users in database: {len(users)}")
        
        for i, user in enumerate(users):
            print(f"\nUser {i+1}:")
            print(f"  ID: {user['_id']}")
            print(f"  Name: {user.get('name', 'N/A')}")
            print(f"  Email: {user.get('email', 'N/A')}")
            print(f"  Type: {user.get('user_type', 'N/A')}")
            
            # Check campaigns for this user
            user_campaigns = list(mongo.db.campaigns.find({'created_by': user['_id']}))
            print(f"  Campaigns created: {len(user_campaigns)}")
            for campaign in user_campaigns:
                print(f"    - {campaign.get('title', 'Untitled')} (status: {campaign.get('status', 'unknown')})")

if __name__ == "__main__":
    test_campaigns()
