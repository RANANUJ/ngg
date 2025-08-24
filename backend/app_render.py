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
    
    user_data = {
        'name': name,
        'email': email.lower(),
        'password': hashed_password,
        'user_type': user_type,
        'created_at': datetime.utcnow(),
        'updated_at': datetime.utcnow()
    }
    
    result = mongo.db.users.insert_one(user_data)
    user_data['_id'] = result.inserted_id
    
    return serialize_user(user_data)

def find_user_by_email(email):
    """Find a user by email"""
    user = mongo.db.users.find_one({'email': email.lower()})
    return user

def find_user_by_id(user_id):
    """Find a user by ID"""
    try:
        user = mongo.db.users.find_one({'_id': ObjectId(user_id)})
        return serialize_user(user) if user else None
    except:
        return None

# Health check endpoint
@app.route('/api/health', methods=['GET'])
def health_check():
    try:
        # Test database connection
        mongo.db.command('ping')
        return jsonify({
            'status': 'healthy',
            'message': 'Backend is running',
            'database': 'connected',
            'environment': os.environ.get('FLASK_ENV', 'development')
        }), 200
    except Exception as e:
        return jsonify({
            'status': 'unhealthy',
            'message': 'Database connection failed',
            'error': str(e)
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
                return jsonify({'message': f'{field} is required'}), 400
        
        name = data['name']
        email = data['email']
        password = data['password']
        user_type = data['user_type']
        
        # Validate user type
        if user_type not in ['Individual', 'NGO']:
            return jsonify({'message': 'user_type must be Individual or NGO'}), 400
        
        # Validate email format
        if '@' not in email or '.' not in email:
            return jsonify({'message': 'Invalid email format'}), 400
        
        # Validate password length
        if len(password) < 6:
            return jsonify({'message': 'Password must be at least 6 characters'}), 400
        
        # Check if user already exists
        existing_user = find_user_by_email(email)
        if existing_user:
            return jsonify({'message': 'User already exists with this email'}), 409
        
        # Create new user
        user = create_user(name, email, password, user_type)
        
        # Generate JWT token
        access_token = create_access_token(identity=str(user['_id']))
        
        return jsonify({
            'message': 'User created successfully',
            'token': access_token,
            'user': user
        }), 201
        
    except Exception as e:
        print(f"Signup error: {e}")
        return jsonify({'message': 'Internal server error'}), 500

@app.route('/api/auth/login', methods=['POST'])
def login():
    try:
        data = request.get_json()
        
        # Validate required fields
        if not data.get('email') or not data.get('password'):
            return jsonify({'message': 'Email and password are required'}), 400
        
        email = data['email']
        password = data['password']
        
        # Find user
        user = find_user_by_email(email)
        if not user:
            return jsonify({'message': 'Invalid email or password'}), 401
        
        # Check password
        if not check_password_hash(user['password'], password):
            return jsonify({'message': 'Invalid email or password'}), 401
        
        # Generate JWT token
        access_token = create_access_token(identity=str(user['_id']))
        
        # Remove password from user data
        user_data = serialize_user(user)
        
        return jsonify({
            'message': 'Login successful',
            'token': access_token,
            'user': user_data
        }), 200
        
    except Exception as e:
        print(f"Login error: {e}")
        return jsonify({'message': 'Internal server error'}), 500

@app.route('/api/auth/profile', methods=['GET'])
@jwt_required()
def get_profile():
    try:
        user_id = get_jwt_identity()
        user = find_user_by_id(user_id)
        
        if not user:
            return jsonify({'message': 'User not found'}), 404
        
        return jsonify(user), 200
        
    except Exception as e:
        print(f"Profile error: {e}")
        return jsonify({'message': 'Internal server error'}), 500

# Root endpoint
@app.route('/', methods=['GET'])
def root():
    return jsonify({
        'message': 'Connect & Contribute Backend API',
        'version': '1.0.0',
        'status': 'running',
        'endpoints': {
            'health': '/api/health',
            'signup': '/api/auth/signup',
            'login': '/api/auth/login',
            'profile': '/api/auth/profile'
        }
    }), 200

# Error handlers
@app.errorhandler(404)
def not_found(error):
    return jsonify({'message': 'Endpoint not found'}), 404

@app.errorhandler(500)
def internal_error(error):
    return jsonify({'message': 'Internal server error'}), 500

if __name__ == '__main__':
    port = int(os.environ.get('PORT', 5000))
    app.run(host='0.0.0.0', port=port, debug=os.environ.get('FLASK_ENV') != 'production')
