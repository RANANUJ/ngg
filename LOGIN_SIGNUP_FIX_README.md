# Connect & Contribute - Login/Signup Fix Documentation

## Issues Fixed

This update addresses several critical issues with the login and signup functionality in the Connect & Contribute Flutter application:

### 1. Authentication State Management
- **Problem**: App didn't properly initialize auth state on startup
- **Fix**: Enhanced splash screen to check for existing tokens and navigate appropriately
- **Changes**: 
  - Updated `splash_screen.dart` to call `AuthProvider.initializeAuth()`
  - Added proper navigation logic based on user type (NGO vs Individual)

### 2. Navigation Issues
- **Problem**: Incorrect navigation patterns using `context.push()` instead of `context.go()`
- **Fix**: Updated all authentication-related navigation to use proper routing
- **Changes**:
  - Login screen now navigates to correct dashboard based on user type
  - Signup screen follows same pattern
  - All navigation uses `context.go()` for proper route replacement

### 3. API Connection Problems
- **Problem**: Hardcoded IP addresses causing connection failures
- **Fix**: Improved API service with better platform detection and error handling
- **Changes**:
  - Added support for Android emulator (`10.0.2.2:5000`)
  - Better timeout handling and retry logic
  - Enhanced error messages for connection failures

### 4. Error Handling
- **Problem**: Poor error handling and user feedback
- **Fix**: Comprehensive error handling with user-friendly messages
- **Changes**:
  - Better error messages for different failure scenarios
  - Connection testing before attempting auth operations
  - Proper loading states and user feedback

### 5. Router Configuration
- **Problem**: Basic router without auth guards
- **Fix**: Enhanced router with proper authentication redirects
- **Changes**:
  - Added redirect logic to protect authenticated routes
  - Proper state management integration with routing

## How to Use the Fixes

### 1. Backend Setup

First, ensure your backend is running:

```bash
# Navigate to backend directory
cd backend

# Install dependencies
pip install -r requirements.txt

# Start the server using the new script
python start_server.py

# OR manually
python app.py
```

The backend will be available at `http://localhost:5000`

### 2. Frontend Configuration

The Flutter app is now configured to automatically detect your platform and use the appropriate backend URL:

- **Web**: `http://localhost:5000/api`
- **Android Emulator**: `http://10.0.2.2:5000/api`
- **iOS Simulator**: `http://localhost:5000/api`
- **Real Device**: You may need to update the IP address in `api_service.dart`

### 3. For Real Android Devices

If you're testing on a real Android device, you'll need to:

1. Find your computer's IP address on the local network
2. Update the API service base URL:

```dart
// In connect_contribute/lib/services/api_service.dart
// Replace the Android section with your actual IP
if (Platform.isAndroid) {
  return 'http://YOUR_ACTUAL_IP:5000/api';  // e.g., 'http://192.168.1.100:5000/api'
}
```

### 4. Testing the Fixes

1. **Clean Build**: Run `flutter clean` and `flutter pub get`
2. **Start Backend**: Use `python backend/start_server.py`
3. **Run App**: Start your Flutter app
4. **Test Flow**:
   - App should show splash screen with loading indicator
   - Navigate to onboarding if not logged in
   - Try creating a new account
   - Try logging in with created account
   - Should navigate to appropriate dashboard based on user type

## Key Features Added

### Enhanced Splash Screen
- Proper auth state initialization
- Smart navigation based on user type
- Loading indicator with better UX

### Improved Login/Signup
- Better form validation
- Connection testing before auth attempts
- User-friendly error messages
- Proper navigation to dashboards

### Robust API Service
- Platform-specific base URLs
- Retry logic with exponential backoff
- Better error handling and reporting
- Connection health checks

### Enhanced Auth Provider
- Proper token validation
- Better state management
- Error recovery mechanisms
- Debug logging for troubleshooting

## Troubleshooting

### Common Issues and Solutions

1. **"Cannot connect to server"**
   - Ensure backend is running on port 5000
   - Check firewall settings
   - For real devices, verify IP address configuration

2. **"Login failed after X attempts"**
   - Check backend logs for errors
   - Verify MongoDB is running (if using database)
   - Check network connectivity

3. **Navigation issues**
   - Clear app data/cache
   - Restart the app
   - Check console logs for routing errors

4. **Token/session issues**
   - Use logout functionality to clear stored tokens
   - Clear app data and try fresh login

### Debug Information

The app now includes comprehensive logging. Check your console for:
- API request/response details
- Authentication state changes
- Navigation events
- Error messages with stack traces

### Backend Requirements

Ensure your backend has these dependencies installed:
```
flask
flask-cors
flask-pymongo
flask-jwt-extended
werkzeug
pymongo
```

## Testing Checklist

- [ ] Backend starts without errors
- [ ] Frontend connects to backend
- [ ] Can create new account (Individual)
- [ ] Can create new account (NGO)
- [ ] Can login with existing account
- [ ] Navigates to correct dashboard
- [ ] Auth state persists after app restart
- [ ] Logout functionality works
- [ ] Error messages are user-friendly

## Additional Notes

- All changes are backward compatible
- Enhanced error handling provides better debugging information
- The system is now more resilient to network issues
- Proper state management ensures consistent user experience

For any additional issues, check the console logs for detailed error information and ensure all dependencies are properly installed.