@echo off
echo.
echo 🚀 NGG Backend Deployment to Render
echo ====================================
echo.

REM Check if we're in the backend directory
if not exist "app_production.py" (
    echo ❌ Error: app_production.py not found. 
    echo Please run this script from the backend directory.
    pause
    exit /b 1
)

echo ✅ Found app_production.py

REM Check if git is initialized
if not exist ".git" (
    echo 🔧 Initializing git repository...
    git init
) else (
    echo ✅ Git repository already initialized
)

echo.
echo 📦 Adding files to git...
git add .

echo.
echo 💾 Committing changes...
git commit -m "Deploy production app with full campaign functionality - %date% %time%"

echo.
echo 🚀 Deploying to Render...
git push render main

if %errorlevel% neq 0 (
    echo.
    echo ❌ Deployment failed. Please check:
    echo 1. Render remote is added: git remote add render [your-render-git-url]
    echo 2. You have push permissions to the repository
    echo 3. Your network connection is stable
    pause
    exit /b 1
)

echo.
echo ✅ Deployment complete!
echo.
echo 📋 Next steps:
echo 1. Check your Render dashboard for deployment status
echo 2. Ensure environment variables are set:
echo    - MONGO_URI: Your MongoDB Atlas connection string
echo    - SECRET_KEY: Your Flask secret key
echo    - JWT_SECRET_KEY: Your JWT secret key
echo 3. Test the API endpoints
echo.
echo 🔗 Your API will be available at: https://your-app-name.onrender.com
echo.
pause
