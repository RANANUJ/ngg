# Render Deployment Guide for Connect & Contribute Backend

This guide will help you deploy your backend to Render, making it accessible from anywhere without needing the same WiFi network.

## Step 1: Set up MongoDB Atlas (Free Database)

1. Go to [MongoDB Atlas](https://www.mongodb.com/atlas)
2. Create a free account
3. Create a new cluster (choose the free tier)
4. Create a database user:
   - Go to "Database Access"
   - Click "Add New Database User"
   - Username: `admin`
   - Password: Generate a secure password
   - Database User Privileges: "Read and write to any database"
5. Set up network access:
   - Go to "Network Access"
   - Click "Add IP Address"
   - Select "Allow access from anywhere" (0.0.0.0/0)
6. Get connection string:
   - Go to "Clusters"
   - Click "Connect" on your cluster
   - Choose "Connect your application"
   - Copy the connection string (replace `<password>` with your database user password)
   - Example: `mongodb+srv://admin:yourpassword@cluster0.xxxxx.mongodb.net/connect_contribute?retryWrites=true&w=majority`

## Step 2: Deploy to Render

1. **Create Render Account**
   - Go to [render.com](https://render.com)
   - Sign up with GitHub

2. **Connect GitHub Repository**
   - Push your code to GitHub first
   - In Render dashboard, click "New +"
   - Select "Web Service"
   - Connect your GitHub repository

3. **Configure Render Settings**
   - **Name**: `connect-contribute-backend`
   - **Environment**: `Python 3`
   - **Build Command**: `pip install -r requirements_render.txt`
   - **Start Command**: `gunicorn app_render:app --bind 0.0.0.0:$PORT`
   - **Python Version**: `3.11.0`

4. **Set Environment Variables**
   In Render dashboard, go to "Environment" tab and add:
   ```
   FLASK_ENV=production
   SECRET_KEY=your-super-secret-key-here-use-a-random-string
   JWT_SECRET_KEY=your-jwt-secret-key-here-use-another-random-string
   MONGO_URI=mongodb+srv://admin:yourpassword@cluster0.xxxxx.mongodb.net/connect_contribute?retryWrites=true&w=majority
   ```

5. **Deploy**
   - Click "Create Web Service"
   - Render will automatically deploy your app
   - You'll get a URL like: `https://connect-contribute-backend.onrender.com`

## Step 3: Test Your Deployed Backend

Open your browser and go to:
```
https://your-app-name.onrender.com/api/health
```

You should see:
```json
{
  "status": "healthy",
  "message": "Backend is running",
  "database": "connected",
  "environment": "production"
}
```

## Step 4: Update Flutter App

The Flutter app will automatically use the Render URL when deployed. For testing, you can set the environment variable:

```bash
flutter run --dart-define=API_BASE_URL=https://your-app-name.onrender.com/api
```

## Important Notes

1. **Free Tier Limitations**:
   - Render free tier may sleep after 15 minutes of inactivity
   - First request after sleep may take 30-60 seconds
   - Consider upgrading to paid tier for production

2. **Database**:
   - MongoDB Atlas free tier has 512MB storage limit
   - Sufficient for development and small-scale testing

3. **Security**:
   - Never commit environment variables to Git
   - Use strong, unique secret keys
   - Enable MongoDB Atlas IP restrictions in production

## Troubleshooting

1. **Build Fails**: Check `requirements_render.txt` has correct dependencies
2. **Database Connection Fails**: Verify MongoDB Atlas connection string and IP whitelist
3. **App Won't Start**: Check Render logs for detailed error messages

## Cost

- **MongoDB Atlas**: Free (up to 512MB)
- **Render**: Free tier available (with limitations)
- **Total**: $0 for development/testing

Your app will now be accessible from any device worldwide!
