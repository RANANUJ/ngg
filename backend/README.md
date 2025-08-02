# Connect & Contribute Backend

Flask backend for the Connect & Contribute mobile application with JWT authentication and MongoDB integration.

## Features

- ✅ JWT Authentication
- ✅ User registration and login
- ✅ Profile management
- ✅ MongoDB integration
- ✅ CORS support
- ✅ Error handling
- ✅ Input validation

## Setup Instructions

### 1. Install Dependencies

```bash
# Activate virtual environment
source backend_env/Scripts/activate  # Windows
# or
source backend_env/bin/activate      # Linux/Mac

# Install dependencies
pip install -r requirements.txt
```

### 2. Install MongoDB

**Windows:**
1. Download MongoDB Community Server from [mongodb.com](https://www.mongodb.com/try/download/community)
2. Install and start MongoDB service

**Linux/Mac:**
```bash
# Ubuntu/Debian
sudo apt-get install mongodb

# macOS with Homebrew
brew install mongodb-community
brew services start mongodb-community
```

### 3. Start MongoDB

Make sure MongoDB is running on `localhost:27017`

### 4. Run the Backend

```bash
cd backend
python app.py
```

The server will start on `http://localhost:5000`

## API Endpoints

### Authentication

#### POST `/api/auth/signup`
Register a new user.

**Request Body:**
```json
{
  "name": "John Doe",
  "email": "john@example.com",
  "password": "password123",
  "user_type": "Individual"
}
```

**Response:**
```json
{
  "token": "jwt_token_here",
  "user": {
    "_id": "user_id",
    "name": "John Doe",
    "email": "john@example.com",
    "user_type": "Individual",
    "created_at": "2024-01-01T00:00:00Z",
    "updated_at": "2024-01-01T00:00:00Z"
  }
}
```

#### POST `/api/auth/login`
Login with email and password.

**Request Body:**
```json
{
  "email": "john@example.com",
  "password": "password123"
}
```

**Response:**
```json
{
  "token": "jwt_token_here",
  "user": {
    "_id": "user_id",
    "name": "John Doe",
    "email": "john@example.com",
    "user_type": "Individual"
  }
}
```

#### GET `/api/auth/profile`
Get user profile (requires authentication).

**Headers:**
```
Authorization: Bearer jwt_token_here
```

**Response:**
```json
{
  "_id": "user_id",
  "name": "John Doe",
  "email": "john@example.com",
  "user_type": "Individual",
  "phone": null,
  "address": null,
  "profile_image": null,
  "created_at": "2024-01-01T00:00:00Z",
  "updated_at": "2024-01-01T00:00:00Z"
}
```

#### PUT `/api/auth/profile`
Update user profile (requires authentication).

**Headers:**
```
Authorization: Bearer jwt_token_here
```

**Request Body:**
```json
{
  "name": "John Smith",
  "phone": "+1234567890",
  "address": "123 Main St"
}
```

#### POST `/api/auth/logout`
Logout (requires authentication).

**Headers:**
```
Authorization: Bearer jwt_token_here
```

## Error Responses

All endpoints return appropriate HTTP status codes:

- `200` - Success
- `201` - Created (signup)
- `400` - Bad Request
- `401` - Unauthorized
- `404` - Not Found
- `409` - Conflict (email already exists)
- `422` - Validation Error
- `500` - Internal Server Error

**Error Response Format:**
```json
{
  "error": "Error message here"
}
```

## Testing

### Using curl

**Signup:**
```bash
curl -X POST http://localhost:5000/api/auth/signup \
  -H "Content-Type: application/json" \
  -d '{
    "name": "Test User",
    "email": "test@example.com",
    "password": "password123",
    "user_type": "Individual"
  }'
```

**Login:**
```bash
curl -X POST http://localhost:5000/api/auth/login \
  -H "Content-Type: application/json" \
  -d '{
    "email": "test@example.com",
    "password": "password123"
  }'
```

**Get Profile:**
```bash
curl -X GET http://localhost:5000/api/auth/profile \
  -H "Authorization: Bearer YOUR_JWT_TOKEN"
```

## Environment Variables

For production, set these environment variables:

```bash
export SECRET_KEY="your-secure-secret-key"
export JWT_SECRET_KEY="your-secure-jwt-secret"
export MONGO_URI="mongodb://your-mongodb-uri"
```

## Security Notes

- Change default secret keys in production
- Use HTTPS in production
- Implement rate limiting for production
- Add input sanitization for production
- Consider implementing token blacklisting for logout

## Development

The backend is configured for development with:
- Debug mode enabled
- CORS enabled for local development
- Detailed error messages
- Hot reloading 