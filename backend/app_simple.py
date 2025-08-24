from flask import Flask, request, jsonify
from flask_cors import CORS
from flask_jwt_extended import JWTManager, create_access_token, jwt_required, get_jwt_identity
from werkzeug.security import generate_password_hash, check_password_hash
from datetime import datetime, timedelta
import os

app = Flask(__name__)

# Configuration - Use environment variables for production
app.config['SECRET_KEY'] = os.environ.get('SECRET_KEY', 'your-secret-key-change-this-in-production')
app.config['JWT_SECRET_KEY'] = os.environ.get('JWT_SECRET_KEY', 'your-jwt-secret-key-change-this-in-production')
app.config['JWT_ACCESS_TOKEN_EXPIRES'] = timedelta(hours=24)

# Initialize extensions
CORS(app, resources={
    r"/api/*": {
        "origins": ["*"],
        "methods": ["GET", "POST", "PUT", "DELETE", "OPTIONS"],
        "allow_headers": ["Content-Type", "Authorization"]
    }
})
jwt = JWTManager(app)

# In-memory database for testing (replace with MongoDB in production)
users_db = {
    "test@example.com": {
        "_id": "1",
        "name": "Test User",
        "email": "test@example.com",
        "password": generate_password_hash("testpass123"),
        "user_type": "Individual",
        "created_at": datetime.utcnow(),
        "updated_at": datetime.utcnow()
    }
}

def serialize_user(user):
    """Convert user object to JSON-serializable format"""
    if not user:
        return None
    
    user_copy = user.copy()
    
    # Convert datetime fields to ISO format strings
    if user_copy.get('created_at'):
        user_copy['created_at'] = user_copy['created_at'].isoformat()
    if user_copy.get('updated_at'):
        user_copy['updated_at'] = user_copy['updated_at'].isoformat()
    
    # Remove password from response
    user_copy.pop('password', None)
    
    return user_copy

# Health check endpoint
@app.route('/api/health', methods=['GET'])
def health_check():
    return jsonify({
        'status': 'healthy',
        'message': 'Backend is running',
        'database': 'in-memory (testing)',
        'environment': os.environ.get('FLASK_ENV', 'development')
    }), 200

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
        email = data['email'].lower()
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
        if email in users_db:
            return jsonify({'message': 'User already exists with this email'}), 409
        
        # Create new user
        user_id = str(len(users_db) + 1)
        hashed_password = generate_password_hash(password)
        
        user_data = {
            '_id': user_id,
            'name': name,
            'email': email,
            'password': hashed_password,
            'user_type': user_type,
            'created_at': datetime.utcnow(),
            'updated_at': datetime.utcnow()
        }
        
        users_db[email] = user_data
        
        # Generate JWT token
        access_token = create_access_token(identity=user_id)
        
        return jsonify({
            'message': 'User created successfully',
            'token': access_token,
            'user': serialize_user(user_data)
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
        
        email = data['email'].lower()
        password = data['password']
        
        # Find user
        user = users_db.get(email)
        if not user:
            return jsonify({'message': 'Invalid email or password'}), 401
        
        # Check password
        if not check_password_hash(user['password'], password):
            return jsonify({'message': 'Invalid email or password'}), 401
        
        # Generate JWT token
        access_token = create_access_token(identity=user['_id'])
        
        return jsonify({
            'message': 'Login successful',
            'token': access_token,
            'user': serialize_user(user)
        }), 200
        
    except Exception as e:
        print(f"Login error: {e}")
        return jsonify({'message': 'Internal server error'}), 500

@app.route('/api/auth/profile', methods=['GET'])
@jwt_required()
def get_profile():
    try:
        user_id = get_jwt_identity()
        
        # Find user by ID
        user = None
        for u in users_db.values():
            if u['_id'] == user_id:
                user = u
                break
        
        if not user:
            return jsonify({'message': 'User not found'}), 404
        
        return jsonify(serialize_user(user)), 200
        
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
    print(f"🚀 Starting Connect & Contribute Backend on port {port}")
    print(f"🌍 Available at:")
    print(f"   - http://localhost:{port}")
    print(f"   - http://192.168.0.115:{port}")
    print(f"🧪 Test credentials:")
    print(f"   - Email: test@example.com")
    print(f"   - Password: testpass123")
    print("=" * 50)
    app.run(host='0.0.0.0', port=port, debug=os.environ.get('FLASK_ENV') != 'production')
