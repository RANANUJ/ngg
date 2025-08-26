# NGG Campaign Fix Deployment Guide

## Problem Analysis
The issue was that fundraising campaigns worked locally but not globally because:

1. **Wrong Backend File**: Render was using `app_simple.py` which only had basic auth and in-memory storage
2. **Missing Campaign APIs**: The production app didn't have campaign and donation request endpoints
3. **Database Issue**: Local development used local MongoDB, but production needed MongoDB Atlas
4. **URL Priority**: API service was trying local URLs first instead of production

## Solution Implemented

### 1. Created New Production App (`app_production.py`)
- Full campaign and donation request functionality
- MongoDB Atlas integration
- All CRUD operations for campaigns and donations
- Proper error handling and authentication

### 2. Updated Deployment Configuration
- **Procfile**: Changed from `app_simple:app` to `app_production:app`
- **API Service**: Prioritized Render URL over local URLs
- **Requirements**: Ensured all dependencies are included

### 3. Key Features Added
- ✅ Create fundraising campaigns (NGO Dashboard)
- ✅ View user campaigns (NGO Dashboard)
- ✅ View all campaigns (Volunteer Dashboard)
- ✅ Donate to campaigns (Both dashboards)
- ✅ UPI payment integration
- ✅ Real-time campaign updates
- ✅ Donation tracking and statistics
- ✅ Cross-platform campaign visibility

## Deployment Steps

### Step 1: Environment Variables on Render
Set these environment variables in your Render dashboard:

```bash
MONGO_URI=mongodb+srv://username:password@cluster.mongodb.net/connect_contribute
SECRET_KEY=your-super-secret-key-here
JWT_SECRET_KEY=your-jwt-secret-key-here
FLASK_ENV=production
```

### Step 2: MongoDB Atlas Setup
1. Create a MongoDB Atlas cluster
2. Create a database named `connect_contribute`
3. Add your Render IP to IP whitelist (or allow all: 0.0.0.0/0)
4. Create a database user with read/write permissions
5. Get the connection string and add it to MONGO_URI

### Step 3: Deploy to Render
```bash
cd backend
git add .
git commit -m "Deploy production app with full campaign functionality"
git push render main  # or your render remote
```

### Step 4: Update Flutter App
The API service is already updated to prioritize Render URL. The app will now:
1. Try Render URL first
2. Fall back to local development URLs if needed
3. Automatically handle connection switching

### Step 5: Test the Deployment

#### Test Campaign Creation (NGO Dashboard)
1. Login as NGO user
2. Go to NGO Dashboard > Fundraising tab
3. Click "New" button
4. Create a campaign
5. Verify it appears in the list

#### Test Campaign Visibility (Volunteer Dashboard)
1. Login as Volunteer user
2. Go to Volunteer Dashboard > Requests tab
3. Verify NGO campaigns appear in the list
4. Test donation functionality

#### Test API Endpoints
```bash
# Health check
curl https://your-app.onrender.com/api/health

# Get all campaigns (should work without auth)
curl https://your-app.onrender.com/api/campaigns/all
```

## API Endpoints Available

### Authentication
- `POST /api/auth/signup` - User registration
- `POST /api/auth/login` - User login
- `GET /api/auth/profile` - Get user profile

### Campaigns
- `POST /api/campaigns` - Create campaign (NGO only)
- `GET /api/campaigns` - Get user's campaigns (NGO only)
- `GET /api/campaigns/all` - Get all active campaigns (Public)
- `GET /api/campaigns/<id>` - Get specific campaign
- `PUT /api/campaigns/<id>` - Update campaign (Owner only)
- `DELETE /api/campaigns/<id>` - Delete campaign (Owner only)

### Donations
- `POST /api/campaigns/<id>/donations` - Create donation
- `GET /api/campaigns/<id>/donations` - Get campaign donations
- `POST /api/campaigns/<id>/upi-payment` - Record UPI payment
- `POST /api/campaigns/<id>/donate` - Quick donate
- `GET /api/campaigns/<id>/donation-stats` - Get donation statistics
- `GET /api/donations/user` - Get user's donations

### Donation Requests
- `POST /api/donation-requests` - Create request (NGO only)
- `GET /api/donation-requests` - Get user's requests (NGO only)
- `GET /api/donation-requests/all` - Get all active requests (Public)
- `GET /api/donation-requests/<id>` - Get specific request
- `PUT /api/donation-requests/<id>` - Update request (Owner only)
- `DELETE /api/donation-requests/<id>` - Delete request (Owner only)

## Data Flow

### Campaign Creation (NGO Side)
1. NGO creates campaign via `/create-fundraising` screen
2. POST to `/api/campaigns` with campaign data
3. Campaign stored in MongoDB with `created_by` field
4. NGO dashboard refreshes to show new campaign

### Campaign Visibility (Volunteer Side)
1. Volunteer dashboard calls `/api/campaigns/all`
2. Returns all active campaigns from all NGOs
3. Volunteers can see and donate to any campaign
4. Real-time updates when donations are made

### Cross-Platform Donations
1. Both NGO and Volunteer dashboards can donate
2. Donations update campaign `raised_amount` in real-time
3. UPI payments are recorded with transaction details
4. Donation history is tracked per user

## Benefits of This Fix

1. **Global Accessibility**: Campaigns are now truly global via Render deployment
2. **Cross-Platform Visibility**: NGO campaigns visible to all volunteers
3. **Real-time Updates**: Donations immediately update campaign progress
4. **Persistent Data**: MongoDB Atlas ensures data persists across deployments
5. **Scalable Architecture**: Production-ready backend with proper error handling
6. **Mobile Compatible**: Works on all platforms (Android, iOS, Web)

## Troubleshooting

### If campaigns still don't appear:
1. Check Render deployment logs
2. Verify MongoDB Atlas connection string
3. Test API endpoints directly
4. Check Flutter app is using correct Render URL

### If donations fail:
1. Verify JWT token is being sent
2. Check campaign ID is valid
3. Ensure MongoDB connection is stable
4. Check Render logs for errors

### If authentication fails:
1. Verify JWT_SECRET_KEY is set on Render
2. Check token expiration (24 hours by default)
3. Ensure CORS is properly configured

## Next Steps

1. **Monitor Performance**: Watch Render metrics for response times
2. **Database Optimization**: Add indexes for better query performance
3. **Error Monitoring**: Implement logging service (e.g., Sentry)
4. **Backup Strategy**: Set up MongoDB Atlas automated backups
5. **Scaling**: Consider upgrading Render plan if needed

Your NGG platform should now work seamlessly with global campaign visibility and donation functionality!
