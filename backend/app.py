from flask import Flask, request, jsonify
from flask_cors import CORS
from flask_pymongo import PyMongo
from flask_jwt_extended import JWTManager, create_access_token, jwt_required, get_jwt_identity
from werkzeug.security import generate_password_hash, check_password_hash
from datetime import datetime, timedelta
import os
from bson import ObjectId

app = Flask(__name__)

# Configuration

app.config['SECRET_KEY'] = 'your-secret-key-change-this-in-production'
app.config['JWT_SECRET_KEY'] = 'your-jwt-secret-key-change-this-in-production'
app.config['JWT_ACCESS_TOKEN_EXPIRES'] = timedelta(hours=24)
app.config['MONGO_URI'] = 'mongodb://localhost:27017/connect_contribute'

# Initialize extensions
CORS(app)
jwt = JWTManager(app)
mongo = PyMongo(app)

# User model helper functions
def serialize_user(user):
    """Convert user object to JSON-serializable format"""
    if not user:
        return None
    
    # Convert _id to string
    user['_id'] = str(user['_id'])
    
    # Convert datetime fields to ISO format strings
    if user.get('created_at'):
        user['created_at'] = user['created_at'].isoformat()
    if user.get('updated_at'):
        user['updated_at'] = user['updated_at'].isoformat()
    
    # Remove password from response
    user.pop('password', None)
    
    return user

def create_user(name, email, password, user_type):
    """Create a new user in the database"""
    hashed_password = generate_password_hash(password)
    user = {
        'name': name,
        'email': email,
        'password': hashed_password,
        'user_type': user_type,
        'phone': None,
        'address': None,
        'profile_image': None,
        'created_at': datetime.utcnow(),
        'updated_at': datetime.utcnow()
    }
    result = mongo.db.users.insert_one(user)
    user['_id'] = result.inserted_id
    return user

def get_user_by_email(email):
    """Get user by email"""
    user = mongo.db.users.find_one({'email': email})
    return user

def get_user_by_id(user_id):
    """Get user by ID"""
    try:
        user = mongo.db.users.find_one({'_id': ObjectId(user_id)})
        return user
    except:
        return None

def update_user(user_id, data):
    """Update user data"""
    data['updated_at'] = datetime.utcnow()
    result = mongo.db.users.update_one(
        {'_id': ObjectId(user_id)},
        {'$set': data}
    )
    return result.modified_count > 0

# Fundraising Campaign model helper functions
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

def create_campaign(data, user_id):
    """Create a new fundraising campaign"""
    campaign = {
        'title': data['title'],
        'description': data['description'],
        'category': data['category'],
        'target_amount': float(data['target_amount']),
        'raised_amount': 0.0,
        'end_date': datetime.fromisoformat(data['end_date']),
        'cover_image': data.get('cover_image'),
        'payment_details': data.get('payment_details', {}),
        'status': 'active',
        'created_by': ObjectId(user_id),
        'created_at': datetime.utcnow(),
        'updated_at': datetime.utcnow()
    }
    result = mongo.db.campaigns.insert_one(campaign)
    campaign['_id'] = result.inserted_id
    return campaign

def get_campaigns_by_user(user_id):
    """Get campaigns created by a specific user"""
    print(f"[DEBUG] get_campaigns_by_user: user_id={user_id}")
    try:
        query = {'created_by': ObjectId(user_id)}
        print(f"[DEBUG] MongoDB query: {query}")
        campaigns = list(mongo.db.campaigns.find(query))
        print(f"[DEBUG] Found {len(campaigns)} campaigns for user {user_id}")
        return [serialize_campaign(campaign) for campaign in campaigns]
    except Exception as e:
        print(f"[DEBUG] Error in get_campaigns_by_user: {e}")
        return []

def get_all_active_campaigns():
    """Get all active campaigns"""
    campaigns = list(mongo.db.campaigns.find({'status': 'active'}))
    return [serialize_campaign(campaign) for campaign in campaigns]

def get_campaign_by_id(campaign_id):
    """Get campaign by ID"""
    try:
        campaign = mongo.db.campaigns.find_one({'_id': ObjectId(campaign_id)})
        return serialize_campaign(campaign)
    except:
        return None

def update_campaign(campaign_id, data, user_id):
    """Update campaign data"""
    data['updated_at'] = datetime.utcnow()
    result = mongo.db.campaigns.update_one(
        {'_id': ObjectId(campaign_id), 'created_by': ObjectId(user_id)},
        {'$set': data}
    )
    return result.modified_count > 0

def delete_campaign(campaign_id, user_id):
    """Delete campaign"""
    result = mongo.db.campaigns.delete_one(
        {'_id': ObjectId(campaign_id), 'created_by': ObjectId(user_id)}
    )
    return result.deleted_count > 0

def add_donation_to_campaign(campaign_id, amount, donor_id=None):
    """Increment a campaign's raised amount by the specified amount.

    Returns the updated serialized campaign or None if not found.
    """
    try:
        update_result = mongo.db.campaigns.update_one(
            {'_id': ObjectId(campaign_id)},
            {
                '$inc': {'raised_amount': float(amount)},
                '$set': {'updated_at': datetime.utcnow()}
            }
        )
        if update_result.matched_count == 0:
            return None

        # Optionally record a donation entry (simple audit)
        try:
            mongo.db.donations.insert_one({
                'campaign_id': ObjectId(campaign_id),
                'amount': float(amount),
                'donor_id': ObjectId(donor_id) if donor_id else None,
                'created_at': datetime.utcnow()
            })
        except Exception:
            # Do not block on donation log failure
            pass

        updated = mongo.db.campaigns.find_one({'_id': ObjectId(campaign_id)})
        return serialize_campaign(updated)
    except Exception:
        return None

# Donation Request model helper functions
def serialize_donation_request(request):
    """Convert donation request object to JSON-serializable format"""
    if not request:
        return None
    
    request['_id'] = str(request['_id'])
    request['created_by'] = str(request['created_by'])
    
    if request.get('created_at'):
        request['created_at'] = request['created_at'].isoformat()
    if request.get('updated_at'):
        request['updated_at'] = request['updated_at'].isoformat()
    if request.get('deadline'):
        request['deadline'] = request['deadline'].isoformat()
    
    return request

def create_donation_request(data, user_id):
    """Create a new donation request"""
    donation_request = {
        'title': data['title'],
        'description': data['description'],
        'category': data['category'],
        'quantity_needed': int(data['quantity_needed']),
        'quantity_received': 0,
        'unit': data['unit'],
        'deadline': datetime.fromisoformat(data['deadline']),
        'item_image': data.get('item_image'),
        'status': 'active',
        'created_by': ObjectId(user_id),
        'created_at': datetime.utcnow(),
        'updated_at': datetime.utcnow()
    }
    result = mongo.db.donation_requests.insert_one(donation_request)
    donation_request['_id'] = result.inserted_id
    return donation_request

def get_donation_requests_by_user(user_id):
    """Get donation requests created by a specific user"""
    requests = list(mongo.db.donation_requests.find({'created_by': ObjectId(user_id)}))
    return [serialize_donation_request(req) for req in requests]

def get_all_active_donation_requests():
    """Get all active donation requests"""
    requests = list(mongo.db.donation_requests.find({'status': 'active'}))
    return [serialize_donation_request(req) for req in requests]

def get_donation_request_by_id(request_id):
    """Get donation request by ID"""
    try:
        request = mongo.db.donation_requests.find_one({'_id': ObjectId(request_id)})
        return serialize_donation_request(request)
    except:
        return None

def update_donation_request(request_id, data, user_id):
    """Update donation request data"""
    data['updated_at'] = datetime.utcnow()
    result = mongo.db.donation_requests.update_one(
        {'_id': ObjectId(request_id), 'created_by': ObjectId(user_id)},
        {'$set': data}
    )
    return result.modified_count > 0

def delete_donation_request(request_id, user_id):
    """Delete donation request"""
    result = mongo.db.donation_requests.delete_one(
        {'_id': ObjectId(request_id), 'created_by': ObjectId(user_id)}
    )
    return result.deleted_count > 0

# Routes
@app.route('/')
def home():
    return jsonify({'message': 'Connect Contribute API is running!'})

@app.route('/api/health', methods=['GET'])
def health_check():
    return jsonify({'status': 'healthy', 'message': 'Backend is running'})

@app.route('/api/auth/signup', methods=['POST'])
def signup():
    try:
        data = request.get_json()
        
        # Validate required fields
        required_fields = ['name', 'email', 'password', 'user_type']
        for field in required_fields:
            if not data.get(field):
                return jsonify({'error': f'{field} is required'}), 422
        
        name = data['name'].strip()
        email = data['email'].strip().lower()
        password = data['password']
        user_type = data['user_type']
        
        # Validate user type
        if user_type not in ['Individual', 'NGO']:
            return jsonify({'error': 'Invalid user type'}), 422
        
        # Check if email already exists
        existing_user = get_user_by_email(email)
        if existing_user:
            return jsonify({'error': 'Email already exists'}), 409
        
        # Validate password length
        if len(password) < 6:
            return jsonify({'error': 'Password must be at least 6 characters'}), 422
        
        # Create user
        user = create_user(name, email, password, user_type)
        
        # Serialize user for JSON response
        serialized_user = serialize_user(user)
        
        # Create access token
        access_token = create_access_token(identity=str(user['_id']))
        
        return jsonify({
            'token': access_token,
            'user': serialized_user
        }), 201
        
    except Exception as e:
        return jsonify({'error': 'Internal server error'}), 500

@app.route('/api/auth/login', methods=['POST'])
def login():
    try:
        data = request.get_json()
        
        # Validate required fields
        if not data.get('email') or not data.get('password'):
            return jsonify({'error': 'Email and password are required'}), 422
        
        email = data['email'].strip().lower()
        password = data['password']
        
        # Get user by email
        user = get_user_by_email(email)
        if not user:
            return jsonify({'error': 'Invalid email or password'}), 401
        
        # Check password
        if not check_password_hash(user['password'], password):
            return jsonify({'error': 'Invalid email or password'}), 401
        
        # Serialize user for JSON response
        serialized_user = serialize_user(user)
        
        # Create access token
        access_token = create_access_token(identity=str(user['_id']))
        
        return jsonify({
            'token': access_token,
            'user': serialized_user
        }), 200
        
    except Exception as e:
        return jsonify({'error': 'Internal server error'}), 500

@app.route('/api/auth/profile', methods=['GET'])
@jwt_required()
def get_profile():
    try:
        user_id = get_jwt_identity()
        user = get_user_by_id(user_id)
        
        if not user:
            return jsonify({'error': 'User not found'}), 404
        
        # Serialize user for JSON response
        serialized_user = serialize_user(user)
        
        return jsonify(serialized_user), 200
        
    except Exception as e:
        return jsonify({'error': 'Internal server error'}), 500

@app.route('/api/auth/profile', methods=['PUT'])
@jwt_required()
def update_profile():
    try:
        user_id = get_jwt_identity()
        data = request.get_json()
        
        # Fields that can be updated
        allowed_fields = ['name', 'phone', 'address']
        update_data = {}
        
        for field in allowed_fields:
            if field in data:
                update_data[field] = data[field]
        
        if not update_data:
            return jsonify({'error': 'No valid fields to update'}), 422
        
        # Update user
        success = update_user(user_id, update_data)
        if not success:
            return jsonify({'error': 'Failed to update profile'}), 500
        
        # Get updated user
        user = get_user_by_id(user_id)
        
        # Serialize user for JSON response
        serialized_user = serialize_user(user)
        
        return jsonify(serialized_user), 200
        
    except Exception as e:
        return jsonify({'error': 'Internal server error'}), 500

@app.route('/api/auth/logout', methods=['POST'])
@jwt_required()
def logout():
    try:
        # In a real application, you might want to blacklist the token
        # For now, we'll just return a success message
        return jsonify({'message': 'Logged out successfully'}), 200
    except Exception as e:
        return jsonify({'error': 'Internal server error'}), 500

# Fundraising Campaign routes
@app.route('/api/campaigns', methods=['POST'])
@jwt_required()
def create_fundraising_campaign():
    try:
        user_id = get_jwt_identity()
        data = request.get_json()
        
        # Validate required fields
        required_fields = ['title', 'description', 'category', 'target_amount', 'end_date']
        for field in required_fields:
            if not data.get(field):
                return jsonify({'error': f'{field} is required'}), 422
        
        # Create campaign
        campaign = create_campaign(data, user_id)
        
        # Serialize campaign for JSON response
        serialized_campaign = serialize_campaign(campaign)
        
        return jsonify(serialized_campaign), 201
        
    except Exception as e:
        return jsonify({'error': 'Internal server error'}), 500

@app.route('/api/campaigns', methods=['GET'])
@jwt_required()
def get_user_campaigns():
    try:
        user_id = get_jwt_identity()
        print(f"[DEBUG] /api/campaigns called by user_id={user_id}")
        campaigns = get_campaigns_by_user(user_id)
        print(f"[DEBUG] /api/campaigns returning {len(campaigns)} campaigns")
        return jsonify(campaigns), 200
    except Exception as e:
        print(f"[DEBUG] Error in /api/campaigns: {e}")
        return jsonify({'error': 'Internal server error'}), 500

@app.route('/api/campaigns/all', methods=['GET'])
def get_all_campaigns():
    try:
        campaigns = get_all_active_campaigns()
        
        return jsonify(campaigns), 200
        
    except Exception as e:
        return jsonify({'error': 'Internal server error'}), 500

@app.route('/api/campaigns/<campaign_id>', methods=['GET'])
def get_campaign(campaign_id):
    try:
        campaign = get_campaign_by_id(campaign_id)
        
        if not campaign:
            return jsonify({'error': 'Campaign not found'}), 404
        
        return jsonify(campaign), 200
        
    except Exception as e:
        return jsonify({'error': 'Internal server error'}), 500

@app.route('/api/campaigns/<campaign_id>', methods=['PUT'])
@jwt_required()
def update_campaign_route(campaign_id):
    try:
        user_id = get_jwt_identity()
        data = request.get_json()
        
        # Update campaign
        success = update_campaign(campaign_id, data, user_id)
        if not success:
            return jsonify({'error': 'Campaign not found or unauthorized'}), 404
        
        # Get updated campaign
        campaign = get_campaign_by_id(campaign_id)
        
        return jsonify(campaign), 200
        
    except Exception as e:
        return jsonify({'error': 'Internal server error'}), 500

@app.route('/api/campaigns/<campaign_id>', methods=['DELETE'])
@jwt_required()
def delete_campaign_route(campaign_id):
    try:
        user_id = get_jwt_identity()
        
        # Delete campaign
        success = delete_campaign(campaign_id, user_id)
        if not success:
            return jsonify({'error': 'Campaign not found or unauthorized'}), 404
        
        return jsonify({'message': 'Campaign deleted successfully'}), 200
        
    except Exception as e:
        return jsonify({'error': 'Internal server error'}), 500

# Campaign donation route (volunteer contribution)
@app.route('/api/campaigns/<campaign_id>/donate', methods=['POST'])
@jwt_required()
def donate_to_campaign_route(campaign_id):
    try:
        user_id = get_jwt_identity()
        data = request.get_json() or {}
        amount = data.get('amount')

        # Basic validation
        try:
            amount = float(amount)
        except Exception:
            return jsonify({'error': 'Invalid amount'}), 422

        if amount <= 0:
            return jsonify({'error': 'Amount must be greater than 0'}), 422

        updated_campaign = add_donation_to_campaign(campaign_id, amount, user_id)
        if not updated_campaign:
            return jsonify({'error': 'Campaign not found'}), 404

        return jsonify(updated_campaign), 200
    except Exception:
        return jsonify({'error': 'Internal server error'}), 500

# Donation Request routes
@app.route('/api/donation-requests', methods=['POST'])
@jwt_required()
def create_donation_request_route():
    try:
        user_id = get_jwt_identity()
        data = request.get_json()
        
        # Validate required fields
        required_fields = ['title', 'description', 'category', 'quantity_needed', 'unit', 'deadline']
        for field in required_fields:
            if not data.get(field):
                return jsonify({'error': f'{field} is required'}), 422
        
        # Create donation request
        donation_request = create_donation_request(data, user_id)
        
        # Serialize donation request for JSON response
        serialized_request = serialize_donation_request(donation_request)
        
        return jsonify(serialized_request), 201
        
    except Exception as e:
        return jsonify({'error': 'Internal server error'}), 500

@app.route('/api/donation-requests', methods=['GET'])
@jwt_required()
def get_user_donation_requests():
    try:
        user_id = get_jwt_identity()
        requests = get_donation_requests_by_user(user_id)
        
        return jsonify(requests), 200
        
    except Exception as e:
        return jsonify({'error': 'Internal server error'}), 500

@app.route('/api/donation-requests/all', methods=['GET'])
def get_all_donation_requests():
    try:
        requests = get_all_active_donation_requests()
        
        return jsonify(requests), 200
        
    except Exception as e:
        return jsonify({'error': 'Internal server error'}), 500

@app.route('/api/donation-requests/<request_id>', methods=['GET'])
def get_donation_request(request_id):
    try:
        donation_request = get_donation_request_by_id(request_id)
        
        if not donation_request:
            return jsonify({'error': 'Donation request not found'}), 404
        
        return jsonify(donation_request), 200
        
    except Exception as e:
        return jsonify({'error': 'Internal server error'}), 500

@app.route('/api/donation-requests/<request_id>', methods=['PUT'])
@jwt_required()
def update_donation_request_route(request_id):
    try:
        user_id = get_jwt_identity()
        data = request.get_json()
        
        # Update donation request
        success = update_donation_request(request_id, data, user_id)
        if not success:
            return jsonify({'error': 'Donation request not found or unauthorized'}), 404
        
        # Get updated donation request
        donation_request = get_donation_request_by_id(request_id)
        
        return jsonify(donation_request), 200
        
    except Exception as e:
        return jsonify({'error': 'Internal server error'}), 500

@app.route('/api/donation-requests/<request_id>', methods=['DELETE'])
@jwt_required()
def delete_donation_request_route(request_id):
    try:
        user_id = get_jwt_identity()
        
        # Delete donation request
        success = delete_donation_request(request_id, user_id)
        if not success:
            return jsonify({'error': 'Donation request not found or unauthorized'}), 404
        
        return jsonify({'message': 'Donation request deleted successfully'}), 200
        
    except Exception as e:
        return jsonify({'error': 'Internal server error'}), 500

# Error handlers
@app.errorhandler(404)
def not_found(error):
    return jsonify({'error': 'Not found'}), 404

@app.errorhandler(500)
def internal_error(error):
    return jsonify({'error': 'Internal server error'}), 500

if __name__ == '__main__':
    app.run(debug=True, host='0.0.0.0', port=5000) 