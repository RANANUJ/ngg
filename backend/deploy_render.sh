#!/bin/bash

# NGG Render Deployment Script

echo "🚀 Starting NGG backend deployment to Render..."

# Check if we're in the backend directory
if [ ! -f "app_production.py" ]; then
    echo "❌ Error: app_production.py not found. Please run this script from the backend directory."
    exit 1
fi

echo "✅ Found app_production.py"

# Check if git is initialized
if [ ! -d ".git" ]; then
    echo "🔧 Initializing git repository..."
    git init
else
    echo "✅ Git repository already initialized"
fi

# Add all files
echo "📦 Adding files to git..."
git add .

# Commit changes
echo "💾 Committing changes..."
git commit -m "Deploy production app with full campaign functionality - $(date)"

# Check if render remote exists
if git remote get-url render > /dev/null 2>&1; then
    echo "✅ Render remote already exists"
else
    echo "❌ Please add your Render git remote:"
    echo "   git remote add render <your-render-git-url>"
    exit 1
fi

# Push to render
echo "🚀 Deploying to Render..."
git push render main

echo "✅ Deployment complete!"
echo ""
echo "📋 Next steps:"
echo "1. Check your Render dashboard for deployment status"
echo "2. Ensure environment variables are set:"
echo "   - MONGO_URI: Your MongoDB Atlas connection string"
echo "   - SECRET_KEY: Your Flask secret key"
echo "   - JWT_SECRET_KEY: Your JWT secret key"
echo "3. Test the API endpoints"
echo ""
echo "🔗 Your API will be available at: https://<your-app-name>.onrender.com"
