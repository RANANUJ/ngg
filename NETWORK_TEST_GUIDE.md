# Network Connection Test Guide

## Step 1: Ensure Backend is Running
Make sure your backend server is running with external access:

```bash
cd "backend"
python run_server.py
```

You should see:
```
Starting server on http://0.0.0.0:5000
Backend will be accessible from:
  - http://localhost:5000
  - http://192.168.0.136:5000
  - Any device on your network
```

## Step 2: Test from Android Device Browser
On your Android device, open a web browser and navigate to:
```
http://192.168.0.136:5000/api/health
```

You should see:
```json
{"status": "healthy", "message": "Backend is running"}
```

## Step 3: Enable Windows Firewall Rule (Run as Administrator)
If Step 2 fails, run PowerShell as Administrator and execute:

```powershell
netsh advfirewall firewall add rule name="Flutter Backend Port 5000" dir=in action=allow protocol=TCP localport=5000
```

## Step 4: Test Login Credentials
Use these test credentials:
- Email: `test@example.com`
- Password: `testpass123`
- Type: Individual (will redirect to volunteer dashboard)

## Step 5: Alternative Testing
If Android device still can't connect, try:

1. **Use Android Emulator:**
   ```bash
   flutter emulators --launch <emulator_id>
   flutter run -d <emulator_id>
   ```

2. **Use Chrome Web:**
   ```bash
   flutter run -d chrome
   ```

3. **USB Tethering:**
   - Enable USB tethering on Android device
   - Connect via USB to PC
   - Both devices will be on same network

## Expected Debug Output (Success)
```
Login successful, user: Test User, type: Individual
Router redirect check: isLoggedIn=true, isInitialized=true, path=/login
User authenticated, redirecting to dashboard. User type: Individual
Redirecting to volunteer dashboard
```

## Troubleshooting Connection Issues
- Ensure both devices are on the same WiFi network
- Check Windows Firewall settings
- Verify backend is bound to 0.0.0.0:5000 (not just localhost)
- Try disabling antivirus temporarily for testing
