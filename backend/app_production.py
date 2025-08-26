from flask import Flask, request, jsonify
from flask_cors import CORS
from flask_pymongo import PyMongo
from flask_jwt_extended import JWTManager, create_access_token, jwt_required, get_jwt_identity
from werkzeug.security import generate_password_hash, check_password_hash
from datetime import datetime, timedelta
import os
from bson import ObjectId

app = Flask(__name__)

# Configuration - Use environment variables for production
app.config['SECRET_KEY'] = os.environ.get('SECRET_KEY', 'your-secret-key-change-this-in-production')
app.config['JWT_SECRET_KEY'] = os.environ.get('JWT_SECRET_KEY', 'your-jwt-secret-key-change-this-in-production')
app.config['JWT_ACCESS_TOKEN_EXPIRES'] = timedelta(hours=24)

# MongoDB configuration - Use MongoDB Atlas for production
MONGO_URI = os.environ.get('MONGO_URI', 'mongodb://localhost:27017/connect_contribute')
app.config['MONGO_URI'] = MONGO_URI

# Initialize extensions
CORS(app, resources={
    r"/api/*": {
        "origins": ["*"],
        "methods": ["GET", "POST", "PUT", "DELETE", "OPTIONS"],
        "allow_headers": ["Content-Type", "Authorization"]
    }
})
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
    try:
        if not campaign:
            return None
        
        print(f"[DEBUG] Serializing campaign: {campaign.get('title', 'N/A')}")
        
        campaign['_id'] = str(campaign['_id'])
        campaign['created_by'] = str(campaign['created_by'])
        
        if campaign.get('created_at'):
            campaign['created_at'] = campaign['created_at'].isoformat()
        if campaign.get('updated_at'):
            campaign['updated_at'] = campaign['updated_at'].isoformat()
        
        # Handle end_date serialization
        if campaign.get('end_date'):
            if isinstance(campaign['end_date'], datetime):
                campaign['end_date'] = campaign['end_date'].isoformat()
        
        print(f"[DEBUG] Serialized campaign successfully: {campaign.get('title', 'N/A')}")
        return campaign
    except Exception as e:
        print(f"[DEBUG] Error serializing campaign: {e}")
        import traceback
        print(f"[DEBUG] Full traceback: {traceback.format_exc()}")
        return None

def create_campaign(data, user_id):
    """Create a new fundraising campaign"""
    campaign = {
        'title': data['title'],
        'description': data['description'],
        'category': data['category'],
        'target_amount': float(data['target_amount']),
        'raised_amount': 0.0,
        'end_date': data['end_date'],
        'created_by': ObjectId(user_id),
        'status': 'active',
        'created_at': datetime.utcnow(),
        'updated_at': datetime.utcnow(),
        'payment_details': data.get('payment_details', {}),
    }
    result = mongo.db.campaigns.insert_one(campaign)
    campaign['_id'] = result.inserted_id
    return campaign

def get_campaigns_by_user(user_id):
    """Get all campaigns created by a specific user"""
    try:
        print(f"[DEBUG] get_campaigns_by_user called with user_id={user_id}, type={type(user_id)}")
        user_object_id = ObjectId(user_id)
        print(f"[DEBUG] Converted to ObjectId: {user_object_id}")
        campaigns = list(mongo.db.campaigns.find({'created_by': user_object_id}))
        print(f"[DEBUG] Found {len(campaigns)} campaigns in database")
        serialized_campaigns = [serialize_campaign(campaign) for campaign in campaigns]
        print(f"[DEBUG] Serialized {len(serialized_campaigns)} campaigns")
        return serialized_campaigns
    except Exception as e:
        print(f"[DEBUG] Error in get_campaigns_by_user: {e}")
        import traceback
        print(f"[DEBUG] Full traceback: {traceback.format_exc()}")
        return []

def get_all_active_campaigns():
    """Get all active campaigns"""
    campaigns = list(mongo.db.campaigns.find({'status': 'active'}))
    return [serialize_campaign(campaign) for campaign in campaigns]

def get_campaign_by_id(campaign_id):
    """Get a specific campaign by ID"""
    try:
        campaign = mongo.db.campaigns.find_one({'_id': ObjectId(campaign_id)})
        return serialize_campaign(campaign) if campaign else None
    except:
        return None

def update_campaign(campaign_id, data):
    """Update campaign data"""
    try:
        data['updated_at'] = datetime.utcnow()
        result = mongo.db.campaigns.update_one(
            {'_id': ObjectId(campaign_id)},
            {'$set': data}
        )
        return result.modified_count > 0
    except:
        return False

def delete_campaign(campaign_id):
    """Delete a campaign"""
    try:
        result = mongo.db.campaigns.delete_one({'_id': ObjectId(campaign_id)})
        return result.deleted_count > 0
    except:
        return False

# Donation Request model helper functions
def serialize_donation_request(request_obj):
    """Convert donation request object to JSON-serializable format"""
    if not request_obj:
        return None
    
    request_obj['_id'] = str(request_obj['_id'])
    request_obj['created_by'] = str(request_obj['created_by'])
    
    if request_obj.get('created_at'):
        request_obj['created_at'] = request_obj['created_at'].isoformat()
    if request_obj.get('updated_at'):
        request_obj['updated_at'] = request_obj['updated_at'].isoformat()
    if request_obj.get('deadline'):
        if isinstance(request_obj['deadline'], datetime):
            request_obj['deadline'] = request_obj['deadline'].isoformat()
    
    return request_obj

def create_donation_request(data, user_id):
    """Create a new donation request"""
    deadline = None
    if data.get('deadline'):
        try:
            deadline = datetime.fromisoformat(data['deadline'].replace('Z', '+00:00'))
        except:
            deadline = datetime.utcnow() + timedelta(days=30)
    
    request_obj = {
        'title': data['title'],
        'description': data['description'],
        'category': data['category'],
        'quantity_needed': int(data['quantity_needed']),
        'quantity_received': 0,
        'unit': data['unit'],
        'deadline': deadline,
        'created_by': ObjectId(user_id),
        'status': 'active',
        'created_at': datetime.utcnow(),
        'updated_at': datetime.utcnow(),
    }
    result = mongo.db.donation_requests.insert_one(request_obj)
    request_obj['_id'] = result.inserted_id
    return request_obj

def get_donation_requests_by_user(user_id):
    """Get all donation requests created by a specific user"""
    requests = list(mongo.db.donation_requests.find({'created_by': ObjectId(user_id)}))
    return [serialize_donation_request(req) for req in requests]

def get_all_active_donation_requests():
    """Get all active donation requests"""
    requests = list(mongo.db.donation_requests.find({'status': 'active'}))
    return [serialize_donation_request(req) for req in requests]

def get_donation_request_by_id(request_id):
    """Get a specific donation request by ID"""
    try:
        request_obj = mongo.db.donation_requests.find_one({'_id': ObjectId(request_id)})
        return serialize_donation_request(request_obj) if request_obj else None
    except:
        return None

def update_donation_request(request_id, data):
    """Update donation request data"""
    try:
        data['updated_at'] = datetime.utcnow()
        result = mongo.db.donation_requests.update_one(
            {'_id': ObjectId(request_id)},
            {'$set': data}
        )
        return result.modified_count > 0
    except:
        return False

def delete_donation_request(request_id):
    """Delete a donation request"""
    try:
        result = mongo.db.donation_requests.delete_one({'_id': ObjectId(request_id)})
        return result.deleted_count > 0
    except:
        return False

# Health check endpoint
@app.route('/api/health', methods=['GET'])
def health_check():
    try:
        # Test database connection
        mongo.db.admin.command('ping')
        
        # Get some database info
        db_name = mongo.db.name
        mongo_uri = app.config.get('MONGO_URI', 'Not set')
        
        return jsonify({
            'status': 'healthy',
            'message': 'Production API is running with MongoDB Atlas',
            'database': 'MongoDB Atlas',
            'database_name': db_name,
            'environment': os.environ.get('FLASK_ENV', 'development'),
            'mongo_uri_set': 'cluster0.2dqh6mp.mongodb.net' in mongo_uri,
            'timestamp': datetime.utcnow().isoformat(),
            'version': '2.0.0'
        }), 200
    except Exception as e:
        return jsonify({
            'status': 'unhealthy',
            'message': f'Database connection failed: {str(e)}',
            'database': 'connection_failed',
            'environment': os.environ.get('FLASK_ENV', 'development'),
            'timestamp': datetime.utcnow().isoformat()
        }), 500

# Authentication routes
@app.route('/api/auth/signup', methods=['POST'])
def signup():
    try:
        data = request.get_json()
        
        # Validate required fields
        required_fields = ['name', 'email', 'password', 'user_type']
        for field in required_fields:
            if not data.get(field):
                return jsonify({'error': f'{field} is required'}), 422
        
        # Check if user already exists
        existing_user = get_user_by_email(data['email'])
        if existing_user:
            return jsonify({'error': 'User already exists'}), 409
        
        # Create new user
        user = create_user(
            data['name'],
            data['email'],
            data['password'],
            data['user_type']
        )
        
        # Serialize user for response
        user_data = serialize_user(user)
        
        # Create access token
        access_token = create_access_token(identity=str(user['_id']))
        
        return jsonify({
            'message': 'User created successfully',
            'token': access_token,
            'user': user_data
        }), 201
        
    except Exception as e:
        print(f"Signup error: {e}")
        return jsonify({'error': 'Internal server error'}), 500

@app.route('/api/auth/login', methods=['POST'])
def login():
    try:
        data = request.get_json()
        
        # Validate required fields
        if not data.get('email') or not data.get('password'):
            return jsonify({'error': 'Email and password are required'}), 422
        
        # Find user
        user = get_user_by_email(data['email'])
        if not user:
            return jsonify({'error': 'Invalid credentials'}), 401
        
        # Check password
        if not check_password_hash(user['password'], data['password']):
            return jsonify({'error': 'Invalid credentials'}), 401
        
        # Serialize user for response
        user_data = serialize_user(user)
        
        # Create access token
        access_token = create_access_token(identity=str(user['_id']))
        
        return jsonify({
            'message': 'Login successful',
            'token': access_token,
            'user': user_data
        }), 200
        
    except Exception as e:
        print(f"Login error: {e}")
        return jsonify({'error': 'Internal server error'}), 500

@app.route('/api/auth/profile', methods=['GET'])
@jwt_required()
def get_profile():
    try:
        user_id = get_jwt_identity()
        user = get_user_by_id(user_id)
        
        if not user:
            return jsonify({'error': 'User not found'}), 404
        
        user_data = serialize_user(user)
        return jsonify(user_data), 200
        
    except Exception as e:
        print(f"Profile error: {e}")
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
        print(f"Create campaign error: {e}")
        return jsonify({'error': 'Internal server error'}), 500

@app.route('/api/campaigns', methods=['GET'])
@jwt_required()
def get_user_campaigns():
    try:
        user_id = get_jwt_identity()
        print(f"[DEBUG] /api/campaigns called by user_id={user_id}")
        print(f"[DEBUG] About to call get_campaigns_by_user with user_id={user_id}")
        campaigns = get_campaigns_by_user(user_id)
        print(f"[DEBUG] get_campaigns_by_user returned: {campaigns}")
        print(f"[DEBUG] /api/campaigns returning {len(campaigns)} campaigns")
        return jsonify(campaigns), 200
    except Exception as e:
        print(f"[DEBUG] Error in /api/campaigns: {e}")
        import traceback
        print(f"[DEBUG] Full traceback: {traceback.format_exc()}")
        return jsonify({'error': 'Internal server error'}), 500

@app.route('/api/campaigns/all', methods=['GET'])
def get_all_campaigns():
    try:
        campaigns = get_all_active_campaigns()
        return jsonify(campaigns), 200
    except Exception as e:
        print(f"Get all campaigns error: {e}")
        return jsonify({'error': 'Internal server error'}), 500

@app.route('/api/campaigns/<campaign_id>', methods=['GET'])
def get_campaign(campaign_id):
    try:
        campaign = get_campaign_by_id(campaign_id)
        
        if not campaign:
            return jsonify({'error': 'Campaign not found'}), 404
        
        return jsonify(campaign), 200
        
    except Exception as e:
        print(f"Get campaign error: {e}")
        return jsonify({'error': 'Internal server error'}), 500

@app.route('/api/campaigns/<campaign_id>', methods=['PUT'])
@jwt_required()
def update_fundraising_campaign(campaign_id):
    try:
        user_id = get_jwt_identity()
        data = request.get_json()
        
        # Check if campaign exists and belongs to user
        campaign = get_campaign_by_id(campaign_id)
        if not campaign:
            return jsonify({'error': 'Campaign not found'}), 404
        
        if campaign['created_by'] != user_id:
            return jsonify({'error': 'Unauthorized'}), 403
        
        # Update campaign
        success = update_campaign(campaign_id, data)
        if not success:
            return jsonify({'error': 'Failed to update campaign'}), 500
        
        # Return updated campaign
        updated_campaign = get_campaign_by_id(campaign_id)
        return jsonify(updated_campaign), 200
        
    except Exception as e:
        print(f"Update campaign error: {e}")
        return jsonify({'error': 'Internal server error'}), 500

@app.route('/api/campaigns/<campaign_id>', methods=['DELETE'])
@jwt_required()
def delete_fundraising_campaign(campaign_id):
    try:
        user_id = get_jwt_identity()
        
        # Check if campaign exists and belongs to user
        campaign = get_campaign_by_id(campaign_id)
        if not campaign:
            return jsonify({'error': 'Campaign not found'}), 404
        
        if campaign['created_by'] != user_id:
            return jsonify({'error': 'Unauthorized'}), 403
        
        # Delete campaign
        success = delete_campaign(campaign_id)
        if not success:
            return jsonify({'error': 'Failed to delete campaign'}), 500
        
        return jsonify({'message': 'Campaign deleted successfully'}), 200
        
    except Exception as e:
        print(f"Delete campaign error: {e}")
        return jsonify({'error': 'Internal server error'}), 500

# Campaign donation routes
@app.route('/api/campaigns/<campaign_id>/donations', methods=['POST'])
@jwt_required()
def create_donation(campaign_id):
    try:
        user_id = get_jwt_identity()
        data = request.get_json()
        
        # Validate required fields
        if not data.get('amount'):
            return jsonify({'error': 'Amount is required'}), 422
        
        amount = float(data['amount'])
        if amount <= 0:
            return jsonify({'error': 'Amount must be positive'}), 422
        
        # Check if campaign exists
        campaign = get_campaign_by_id(campaign_id)
        if not campaign:
            return jsonify({'error': 'Campaign not found'}), 404
        
        # Create donation record
        donation = {
            'campaign_id': ObjectId(campaign_id),
            'donor_id': ObjectId(user_id),
            'amount': amount,
            'payment_method': data.get('payment_method', 'online'),
            'transaction_id': data.get('transaction_id'),
            'message': data.get('message', ''),
            'status': 'completed',
            'created_at': datetime.utcnow(),
        }
        result = mongo.db.donations.insert_one(donation)
        
        # Update campaign raised amount
        new_raised_amount = campaign['raised_amount'] + amount
        update_campaign(campaign_id, {'raised_amount': new_raised_amount})
        
        donation['_id'] = str(result.inserted_id)
        donation['campaign_id'] = str(donation['campaign_id'])
        donation['donor_id'] = str(donation['donor_id'])
        donation['created_at'] = donation['created_at'].isoformat()
        
        return jsonify(donation), 201
        
    except Exception as e:
        print(f"Create donation error: {e}")
        return jsonify({'error': 'Internal server error'}), 500

@app.route('/api/campaigns/<campaign_id>/donations', methods=['GET'])
def get_campaign_donations(campaign_id):
    try:
        donations = list(mongo.db.donations.find({'campaign_id': ObjectId(campaign_id)}))
        
        # Serialize donations
        serialized_donations = []
        for donation in donations:
            donation['_id'] = str(donation['_id'])
            donation['campaign_id'] = str(donation['campaign_id'])
            donation['donor_id'] = str(donation['donor_id'])
            donation['created_at'] = donation['created_at'].isostring()
            serialized_donations.append(donation)
        
        return jsonify(serialized_donations), 200
        
    except Exception as e:
        print(f"Get campaign donations error: {e}")
        return jsonify({'error': 'Internal server error'}), 500

@app.route('/api/campaigns/<campaign_id>/donation-stats', methods=['GET'])
def get_donation_stats(campaign_id):
    try:
        # Get campaign
        campaign = get_campaign_by_id(campaign_id)
        if not campaign:
            return jsonify({'error': 'Campaign not found'}), 404
        
        # Get donation count
        donation_count = mongo.db.donations.count_documents({'campaign_id': ObjectId(campaign_id)})
        
        stats = {
            'total_raised': campaign['raised_amount'],
            'target_amount': campaign['target_amount'],
            'donation_count': donation_count,
            'percentage_raised': (campaign['raised_amount'] / campaign['target_amount']) * 100 if campaign['target_amount'] > 0 else 0
        }
        
        return jsonify(stats), 200
        
    except Exception as e:
        print(f"Get donation stats error: {e}")
        return jsonify({'error': 'Internal server error'}), 500

@app.route('/api/campaigns/<campaign_id>/upi-payment', methods=['POST'])
@jwt_required()
def record_upi_payment(campaign_id):
    try:
        user_id = get_jwt_identity()
        data = request.get_json()
        
        # Validate required fields
        required_fields = ['amount', 'payment_method']
        for field in required_fields:
            if not data.get(field):
                return jsonify({'error': f'{field} is required'}), 422
        
        amount = float(data['amount'])
        if amount <= 0:
            return jsonify({'error': 'Amount must be positive'}), 422
        
        # Check if campaign exists
        campaign = get_campaign_by_id(campaign_id)
        if not campaign:
            return jsonify({'error': 'Campaign not found'}), 404
        
        # Create donation record
        donation = {
            'campaign_id': ObjectId(campaign_id),
            'donor_id': ObjectId(user_id),
            'amount': amount,
            'payment_method': data['payment_method'],
            'transaction_id': data.get('transaction_id', f"UPI_{datetime.now().timestamp()}"),
            'payment_status': data.get('payment_status', 'completed'),
            'payment_time': data.get('payment_time', datetime.utcnow().isostring()),
            'created_at': datetime.utcnow(),
        }
        result = mongo.db.donations.insert_one(donation)
        
        # Update campaign raised amount
        new_raised_amount = campaign['raised_amount'] + amount
        update_campaign(campaign_id, {'raised_amount': new_raised_amount})
        
        donation['_id'] = str(result.inserted_id)
        donation['campaign_id'] = str(donation['campaign_id'])
        donation['donor_id'] = str(donation['donor_id'])
        donation['created_at'] = donation['created_at'].isostring()
        
        return jsonify({
            'message': 'Payment recorded successfully',
            'donation': donation
        }), 201
        
    except Exception as e:
        print(f"Record UPI payment error: {e}")
        return jsonify({'error': 'Internal server error'}), 500

@app.route('/api/campaigns/<campaign_id>/donate', methods=['POST'])
@jwt_required()
def donate_to_campaign(campaign_id):
    try:
        user_id = get_jwt_identity()
        data = request.get_json()
        
        # Validate amount
        if not data.get('amount'):
            return jsonify({'error': 'Amount is required'}), 422
        
        amount = float(data['amount'])
        if amount <= 0:
            return jsonify({'error': 'Amount must be positive'}), 422
        
        # Check if campaign exists
        campaign = get_campaign_by_id(campaign_id)
        if not campaign:
            return jsonify({'error': 'Campaign not found'}), 404
        
        # Create donation record
        donation = {
            'campaign_id': ObjectId(campaign_id),
            'donor_id': ObjectId(user_id),
            'amount': amount,
            'payment_method': 'online',
            'status': 'completed',
            'created_at': datetime.utcnow(),
        }
        result = mongo.db.donations.insert_one(donation)
        
        # Update campaign raised amount
        new_raised_amount = campaign['raised_amount'] + amount
        update_campaign(campaign_id, {'raised_amount': new_raised_amount})
        
        return jsonify({
            'message': 'Donation successful',
            'donation_id': str(result.inserted_id),
            'new_total': new_raised_amount
        }), 200
        
    except Exception as e:
        print(f"Donate to campaign error: {e}")
        return jsonify({'error': 'Internal server error'}), 500

# Donation Request routes
@app.route('/api/donation-requests', methods=['POST'])
@jwt_required()
def create_donation_request_route():
    try:
        user_id = get_jwt_identity()
        data = request.get_json()
        
        # Validate required fields
        required_fields = ['title', 'description', 'category', 'quantity_needed', 'unit']
        for field in required_fields:
            if not data.get(field):
                return jsonify({'error': f'{field} is required'}), 422
        
        # Create donation request
        request_obj = create_donation_request(data, user_id)
        
        # Serialize request for JSON response
        serialized_request = serialize_donation_request(request_obj)
        
        return jsonify(serialized_request), 201
        
    except Exception as e:
        print(f"Create donation request error: {e}")
        return jsonify({'error': 'Internal server error'}), 500

@app.route('/api/donation-requests', methods=['GET'])
@jwt_required()
def get_user_donation_requests():
    try:
        user_id = get_jwt_identity()
        requests = get_donation_requests_by_user(user_id)
        return jsonify(requests), 200
    except Exception as e:
        print(f"Get user donation requests error: {e}")
        return jsonify({'error': 'Internal server error'}), 500

@app.route('/api/donation-requests/all', methods=['GET'])
def get_all_donation_requests():
    try:
        requests = get_all_active_donation_requests()
        return jsonify(requests), 200
    except Exception as e:
        print(f"Get all donation requests error: {e}")
        return jsonify({'error': 'Internal server error'}), 500

@app.route('/api/donation-requests/<request_id>', methods=['GET'])
def get_donation_request(request_id):
    try:
        request_obj = get_donation_request_by_id(request_id)
        
        if not request_obj:
            return jsonify({'error': 'Donation request not found'}), 404
        
        return jsonify(request_obj), 200
        
    except Exception as e:
        print(f"Get donation request error: {e}")
        return jsonify({'error': 'Internal server error'}), 500

@app.route('/api/donation-requests/<request_id>', methods=['PUT'])
@jwt_required()
def update_donation_request_route(request_id):
    try:
        user_id = get_jwt_identity()
        data = request.get_json()
        
        # Check if request exists and belongs to user
        request_obj = get_donation_request_by_id(request_id)
        if not request_obj:
            return jsonify({'error': 'Donation request not found'}), 404
        
        if request_obj['created_by'] != user_id:
            return jsonify({'error': 'Unauthorized'}), 403
        
        # Update request
        success = update_donation_request(request_id, data)
        if not success:
            return jsonify({'error': 'Failed to update donation request'}), 500
        
        # Return updated request
        updated_request = get_donation_request_by_id(request_id)
        return jsonify(updated_request), 200
        
    except Exception as e:
        print(f"Update donation request error: {e}")
        return jsonify({'error': 'Internal server error'}), 500

@app.route('/api/donation-requests/<request_id>', methods=['DELETE'])
@jwt_required()
def delete_donation_request_route(request_id):
    try:
        user_id = get_jwt_identity()
        
        # Check if request exists and belongs to user
        request_obj = get_donation_request_by_id(request_id)
        if not request_obj:
            return jsonify({'error': 'Donation request not found'}), 404
        
        if request_obj['created_by'] != user_id:
            return jsonify({'error': 'Unauthorized'}), 403
        
        # Delete request
        success = delete_donation_request(request_id)
        if not success:
            return jsonify({'error': 'Failed to delete donation request'}), 500
        
        return jsonify({'message': 'Donation request deleted successfully'}), 200
        
    except Exception as e:
        print(f"Delete donation request error: {e}")
        return jsonify({'error': 'Internal server error'}), 500

# Get user donations
@app.route('/api/donations/user', methods=['GET'])
@jwt_required()
def get_user_donations():
    try:
        user_id = get_jwt_identity()
        donations = list(mongo.db.donations.find({'donor_id': ObjectId(user_id)}))
        
        # Serialize donations
        serialized_donations = []
        for donation in donations:
            donation['_id'] = str(donation['_id'])
            donation['campaign_id'] = str(donation['campaign_id'])
            donation['donor_id'] = str(donation['donor_id'])
            donation['created_at'] = donation['created_at'].isostring()
            serialized_donations.append(donation)
        
        return jsonify(serialized_donations), 200
        
    except Exception as e:
        print(f"Get user donations error: {e}")
        return jsonify({'error': 'Internal server error'}), 500

# Root endpoint
@app.route('/', methods=['GET'])
def root():
    return jsonify({
        'message': 'Connect & Contribute Backend API',
        'version': '1.0.0',
        'status': 'running',
        'endpoints': {
            'health': '/api/health',
            'auth': {
                'signup': '/api/auth/signup',
                'login': '/api/auth/login',
                'profile': '/api/auth/profile'
            },
            'campaigns': {
                'create': '/api/campaigns (POST)',
                'user_campaigns': '/api/campaigns (GET)',
                'all_campaigns': '/api/campaigns/all (GET)',
                'get_campaign': '/api/campaigns/<id> (GET)',
                'update_campaign': '/api/campaigns/<id> (PUT)',
                'delete_campaign': '/api/campaigns/<id> (DELETE)',
                'donate': '/api/campaigns/<id>/donate (POST)',
                'donations': '/api/campaigns/<id>/donations (GET)',
                'upi_payment': '/api/campaigns/<id>/upi-payment (POST)',
                'stats': '/api/campaigns/<id>/donation-stats (GET)'
            },
            'donation_requests': {
                'create': '/api/donation-requests (POST)',
                'user_requests': '/api/donation-requests (GET)',
                'all_requests': '/api/donation-requests/all (GET)',
                'get_request': '/api/donation-requests/<id> (GET)',
                'update_request': '/api/donation-requests/<id> (PUT)',
                'delete_request': '/api/donation-requests/<id> (DELETE)'
            }
        }
    }), 200

# Error handlers
@app.errorhandler(404)
def not_found(error):
    return jsonify({'error': 'Endpoint not found'}), 404

@app.errorhandler(500)
def internal_error(error):
    return jsonify({'error': 'Internal server error'}), 500

if __name__ == '__main__':
    port = int(os.environ.get('PORT', 5000))
    app.run(host='0.0.0.0', port=port, debug=os.environ.get('FLASK_ENV') != 'production')
