package com.example.connect_contribute;

import android.content.Context;
import android.content.Intent;
import android.content.pm.PackageManager;
import android.content.pm.ResolveInfo;
import android.net.Uri;
import android.util.Log;
import io.flutter.plugin.common.MethodCall;
import io.flutter.plugin.common.MethodChannel;
import java.util.*;

public class UpiHelper implements MethodChannel.MethodCallHandler {
    
    private static final String TAG = "UpiHelper";
    private final Context context;
    
    private static final Map<String, String> UPI_APPS = new HashMap<String, String>() {{
        put("com.google.android.apps.nbu.paisa.user", "Google Pay");
        put("com.phonepe.app", "PhonePe");
        put("net.one97.paytm", "Paytm");
        put("in.org.npci.upiapp", "BHIM");
        put("com.amazon.sss.channelpay", "Amazon Pay");
        put("com.amazon.mShop.android.shopping", "Amazon Pay");
        put("com.mobikwik_new", "MobiKwik");
        put("com.freecharge.android", "Freecharge");
        put("com.whatsapp", "WhatsApp");
        put("com.flipkart.android", "Flipkart");
        put("com.dreamplug.androidapp", "CRED");
    }};
    
    public UpiHelper(Context context) {
        this.context = context;
    }
    
    @Override
    public void onMethodCall(MethodCall call, MethodChannel.Result result) {
        Log.d(TAG, "Method call received: " + call.method);
        
        switch (call.method) {
            case "getInstalledUpiApps":
                Log.d(TAG, "Getting installed UPI apps...");
                List<Map<String, String>> installedApps = getInstalledUpiApps();
                Log.d(TAG, "Found " + installedApps.size() + " UPI apps: " + installedApps.toString());
                result.success(installedApps);
                break;
                
            case "launchUpiApp":
                String packageName = call.argument("packageName");
                String upiUrl = call.argument("upiUrl");
                
                Log.d(TAG, "Launching UPI app: " + packageName + " with URL: " + upiUrl);
                
                if (packageName != null && upiUrl != null) {
                    boolean success = launchUpiApp(packageName, upiUrl);
                    Log.d(TAG, "Launch result: " + success);
                    result.success(success);
                } else {
                    Log.e(TAG, "Invalid arguments for launchUpiApp");
                    result.error("INVALID_ARGUMENTS", "Package name and UPI URL are required", null);
                }
                break;
                
            case "launchUpiIntent":
                String upiIntentUrl = call.argument("upiUrl");
                Log.d(TAG, "Launching UPI intent with URL: " + upiIntentUrl);
                
                if (upiIntentUrl != null) {
                    boolean success = launchUpiIntent(upiIntentUrl);
                    Log.d(TAG, "Intent launch result: " + success);
                    result.success(success);
                } else {
                    Log.e(TAG, "Invalid arguments for launchUpiIntent");
                    result.error("INVALID_ARGUMENTS", "UPI URL is required", null);
                }
                break;
                
            default:
                Log.w(TAG, "Unhandled method: " + call.method);
                result.notImplemented();
                break;
        }
    }
    
    private List<Map<String, String>> getInstalledUpiApps() {
        Log.d(TAG, "Checking for installed UPI apps...");
        List<Map<String, String>> installedApps = new ArrayList<>();
        PackageManager pm = context.getPackageManager();
        
        for (Map.Entry<String, String> entry : UPI_APPS.entrySet()) {
            String packageName = entry.getKey();
            String appName = entry.getValue();
            
            try {
                Log.d(TAG, "Checking for app: " + appName + " (" + packageName + ")");
                pm.getPackageInfo(packageName, PackageManager.GET_ACTIVITIES);
                Log.d(TAG, "Found installed app: " + appName);
                
                Map<String, String> app = new HashMap<>();
                app.put("packageName", packageName);
                app.put("appName", appName);
                installedApps.add(app);
            } catch (PackageManager.NameNotFoundException e) {
                Log.d(TAG, "App not installed: " + appName + " (" + packageName + ")");
            }
        }
        
        // Also check for generic UPI capable apps
        Intent upiIntent = new Intent(Intent.ACTION_VIEW, Uri.parse("upi://pay"));
        List<ResolveInfo> resolveInfos = pm.queryIntentActivities(upiIntent, PackageManager.MATCH_DEFAULT_ONLY);
        
        for (ResolveInfo resolveInfo : resolveInfos) {
            String pkg = resolveInfo.activityInfo.packageName;
            String name = resolveInfo.loadLabel(pm).toString();
            
            // Check if we already have this app
            boolean alreadyAdded = false;
            for (Map<String, String> existingApp : installedApps) {
                if (pkg.equals(existingApp.get("packageName"))) {
                    alreadyAdded = true;
                    break;
                }
            }
            
            if (!alreadyAdded) {
                Log.d(TAG, "Found additional UPI-capable app: " + name + " (" + pkg + ")");
                Map<String, String> app = new HashMap<>();
                app.put("packageName", pkg);
                app.put("appName", name);
                installedApps.add(app);
            }
        }
        
        Log.d(TAG, "Total UPI apps found: " + installedApps.size());
        return installedApps;
    }
    
    private boolean launchUpiApp(String packageName, String upiUrl) {
        try {
            Intent intent = new Intent(Intent.ACTION_VIEW, Uri.parse(upiUrl));
            intent.setPackage(packageName);
            intent.addFlags(Intent.FLAG_ACTIVITY_NEW_TASK);
            
            // Check if the app can handle this intent
            List<ResolveInfo> activities = context.getPackageManager().queryIntentActivities(intent, 0);
            if (!activities.isEmpty()) {
                context.startActivity(intent);
                return true;
            } else {
                Log.w(TAG, "No activity found for package: " + packageName);
                return false;
            }
        } catch (Exception e) {
            Log.e(TAG, "Error launching UPI app: " + e.getMessage(), e);
            return false;
        }
    }
    
    private boolean launchUpiIntent(String upiUrl) {
        try {
            Intent intent = new Intent(Intent.ACTION_VIEW, Uri.parse(upiUrl));
            intent.addFlags(Intent.FLAG_ACTIVITY_NEW_TASK);
            
            // Check if any app can handle this intent
            List<ResolveInfo> activities = context.getPackageManager().queryIntentActivities(intent, 0);
            if (!activities.isEmpty()) {
                context.startActivity(intent);
                return true;
            } else {
                Log.w(TAG, "No app can handle UPI intent");
                return false;
            }
        } catch (Exception e) {
            Log.e(TAG, "Error launching UPI intent: " + e.getMessage(), e);
            return false;
        }
    }
}
