#!/usr/bin/env python3
"""
Database verification script - check if users are actually being saved to MongoDB Atlas
"""
import os
from pymongo import MongoClient
from datetime import datetime

def test_mongodb_connection():
    """Test direct connection to MongoDB Atlas"""
    print("🔗 Testing direct MongoDB Atlas connection...")
    
    # Get the MONGO_URI from environment variables
    # You should set this to your actual MongoDB Atlas URI
    mongo_uri = os.environ.get('MONGO_URI')
    
    if not mongo_uri:
        print("❌ MONGO_URI environment variable not set")
        print("Set it with: export MONGO_URI='your_mongodb_atlas_uri'")
        return False
    
    try:
        # Connect to MongoDB Atlas
        client = MongoClient(mongo_uri)
        
        # Test the connection
        client.admin.command('ping')
        print("✅ Successfully connected to MongoDB Atlas!")
        
        # Get the database
        db = client.connect_contribute  # or whatever your database name is
        
        # Check collections
        collections = db.list_collection_names()
        print(f"📚 Available collections: {collections}")
        
        # Count users
        if 'users' in collections:
            user_count = db.users.count_documents({})
            print(f"👥 Total users in database: {user_count}")
            
            # Show recent users (without passwords)
            recent_users = list(db.users.find(
                {}, 
                {'password': 0}  # Exclude password field
            ).sort('created_at', -1).limit(5))
            
            print(f"📋 Recent users:")
            for user in recent_users:
                created_at = user.get('created_at', 'Unknown')
                if hasattr(created_at, 'strftime'):
                    created_at = created_at.strftime('%Y-%m-%d %H:%M:%S')
                print(f"  - {user.get('name', 'Unknown')} ({user.get('email', 'Unknown')}) - {user.get('user_type', 'Unknown')} - Created: {created_at}")
        else:
            print("📋 No 'users' collection found")
        
        client.close()
        return True
        
    except Exception as e:
        print(f"❌ MongoDB connection failed: {e}")
        return False

def create_test_user():
    """Create a test user directly in the database"""
    print("\n🧪 Creating test user directly in database...")
    
    mongo_uri = os.environ.get('MONGO_URI')
    if not mongo_uri:
        print("❌ MONGO_URI environment variable not set")
        return False
    
    try:
        from werkzeug.security import generate_password_hash
        
        client = MongoClient(mongo_uri)
        db = client.connect_contribute
        
        # Create test user
        test_user = {
            'name': 'Database Test User',
            'email': 'dbtest@example.com',
            'password': generate_password_hash('testpass123'),
            'user_type': 'Individual',
            'phone': None,
            'address': None,
            'profile_image': None,
            'created_at': datetime.utcnow(),
            'updated_at': datetime.utcnow()
        }
        
        # Check if user already exists
        existing = db.users.find_one({'email': test_user['email']})
        if existing:
            print(f"📋 Test user already exists, deleting first...")
            db.users.delete_one({'email': test_user['email']})
        
        # Insert test user
        result = db.users.insert_one(test_user)
        print(f"✅ Test user created with ID: {result.inserted_id}")
        
        # Verify user was created
        created_user = db.users.find_one({'_id': result.inserted_id}, {'password': 0})
        print(f"✅ Verification - User found: {created_user}")
        
        client.close()
        return True
        
    except Exception as e:
        print(f"❌ Failed to create test user: {e}")
        return False

if __name__ == "__main__":
    print("🚀 Starting MongoDB verification...")
    
    # Test connection and list users
    connection_ok = test_mongodb_connection()
    
    if connection_ok:
        # Create a test user to verify write operations work
        create_test_user()
        
        # Check again to see if it was added
        print("\n🔄 Checking database again after test user creation...")
        test_mongodb_connection()
    
    print("\n🔚 MongoDB verification completed!")
