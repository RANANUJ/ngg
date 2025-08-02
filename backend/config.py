import os
from datetime import timedelta

class Config:
    """Base configuration class"""
    SECRET_KEY = os.environ.get('SECRET_KEY') or 'your-secret-key-change-this-in-production'
    JWT_SECRET_KEY = os.environ.get('JWT_SECRET_KEY') or 'your-jwt-secret-key-change-this-in-production'
    JWT_ACCESS_TOKEN_EXPIRES = timedelta(hours=24)
    
    # MongoDB configuration
    MONGO_URI = os.environ.get('MONGO_URI') or 'mongodb://localhost:27017/connect_contribute'
    
    # CORS settings
    CORS_ORIGINS = ['http://localhost:3000', 'http://127.0.0.1:3000']  # Add your Flutter app URL
    
    # Security settings
    JWT_TOKEN_LOCATION = ['headers']
    JWT_HEADER_NAME = 'Authorization'
    JWT_HEADER_TYPE = 'Bearer'

class DevelopmentConfig(Config):
    """Development configuration"""
    DEBUG = True
    MONGO_URI = 'mongodb://localhost:27017/connect_contribute_dev'

class ProductionConfig(Config):
    """Production configuration"""
    DEBUG = False
    # Use environment variables for production
    SECRET_KEY = os.environ.get('SECRET_KEY')
    JWT_SECRET_KEY = os.environ.get('JWT_SECRET_KEY')
    MONGO_URI = os.environ.get('MONGO_URI')

class TestingConfig(Config):
    """Testing configuration"""
    TESTING = True
    MONGO_URI = 'mongodb://localhost:27017/connect_contribute_test'

# Configuration dictionary
config = {
    'development': DevelopmentConfig,
    'production': ProductionConfig,
    'testing': TestingConfig,
    'default': DevelopmentConfig
} 