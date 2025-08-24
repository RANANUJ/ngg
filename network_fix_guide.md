# Network Connection Fix for Android Device

## Issue
Your Android device can't connect to the backend server running on your PC at `192.168.0.136:5000`.

## Solutions

### Option 1: Enable Windows Firewall (Recommended)
1. **Run PowerShell as Administrator**
2. **Execute this command:**
   ```powershell
   netsh advfirewall firewall add rule name="Flutter Backend" dir=in action=allow protocol=TCP localport=5000
   ```

### Option 2: Temporarily Disable Windows Firewall (For Testing)
1. Go to **Windows Security** > **Firewall & Network Protection**
2. Temporarily turn off **Domain network**, **Private network**, and **Public network** firewalls
3. Test the app
4. **Remember to re-enable firewalls after testing**

### Option 3: Use Android Emulator Instead
```bash
# List available devices
flutter devices

# Run on Android emulator (if available)
flutter run -d emulator-5554

# Or create a new emulator
flutter emulators --launch <emulator_id>
```

### Option 4: Test in Chrome Browser
The app is currently being tested in Chrome browser which should work with localhost.

### Option 5: Use USB Tethering/Hotspot
1. Enable **USB tethering** on your Android device
2. Connect to PC via USB
3. Your device will get an IP in the same network as your PC

## Verification Steps

1. **Check if backend is accessible from your Android device:**
   - Open browser on your Android device
   - Navigate to: `http://192.168.0.136:5000/api/health`
   - You should see: `{"status": "healthy", "message": "Backend is running"}`

2. **Alternative test with your device's IP:**
   - Find your Android device's IP address (Settings > About Phone > Status > IP Address)
   - If it's in a different subnet (e.g., 192.168.0.x vs 192.168.1.x), that's the issue

## Current Status
- ✅ Backend is running correctly on PC (`192.168.0.136:5000`)
- ✅ Backend is accessible from PC
- ❌ Android device cannot reach the backend (firewall/network issue)
- 🔄 Testing in Chrome browser (should work with localhost)

## Expected Debug Output After Fix
When the connection works, you should see:
```
I/flutter: Login successful, user: Test User, type: Individual
I/flutter: Router redirect check: isLoggedIn=true, isInitialized=true, path=/login
I/flutter: User authenticated, redirecting to dashboard. User type: Individual
I/flutter: Redirecting to volunteer dashboard
```

## Test Credentials
- Email: `test@example.com`
- Password: `testpass123`
- Type: Individual (redirects to volunteer dashboard)
