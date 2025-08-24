package com.example.connect_contribute;

import android.content.Intent;
import android.content.pm.PackageManager;
import android.content.pm.ResolveInfo;
import android.net.Uri;
import io.flutter.embedding.android.FlutterActivity;
import io.flutter.embedding.engine.FlutterEngine;
import io.flutter.plugin.common.MethodChannel;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

public class MainActivity extends FlutterActivity {
    private static final String CHANNEL = "upi_helper";
    
    // Common UPI apps with their package names
    private static final Map<String, String> UPI_APPS = new HashMap<String, String>() {{
        put("com.google.android.apps.nbu.paisa.user", "Google Pay");
        put("com.phonepe.app", "PhonePe");
        put("net.one97.paytm", "Paytm");
        put("in.org.npci.upiapp", "BHIM UPI");
        put("in.amazon.mShop.android.shopping", "Amazon Pay");
        put("com.dreamplug.androidapp", "CRED");
        put("com.flipkart.android", "Flipkart UPI");
        put("com.mobikwik_new", "MobiKwik");
        put("com.freecharge.android", "Freecharge");
        put("com.myairtelapp", "Airtel Thanks");
        put("com.whatsapp", "WhatsApp Pay");
        put("com.jio.myjio", "JioMoney");
    }};

    @Override
    public void configureFlutterEngine(FlutterEngine flutterEngine) {
        super.configureFlutterEngine(flutterEngine);
        
        new MethodChannel(flutterEngine.getDartExecutor().getBinaryMessenger(), CHANNEL)
            .setMethodCallHandler((call, result) -> {
                switch (call.method) {
                    case "getInstalledUpiApps":
                        result.success(getInstalledUpiApps());
                        break;
                    case "launchUpiApp":
                        String packageName = call.argument("packageName");
                        String upiUrl = call.argument("upiUrl");
                        result.success(launchUpiApp(packageName, upiUrl));
                        break;
                    case "launchUpiIntent":
                        String upiUrlIntent = call.argument("upiUrl");
                        result.success(launchUpiIntent(upiUrlIntent));
                        break;
                    default:
                        result.notImplemented();
                        break;
                }
            });
    }
    
    private List<Map<String, String>> getInstalledUpiApps() {
        List<Map<String, String>> installedApps = new ArrayList<>();
        PackageManager packageManager = getPackageManager();
        
        // Check each known UPI app
        for (Map.Entry<String, String> entry : UPI_APPS.entrySet()) {
            String packageName = entry.getKey();
            String appName = entry.getValue();
            
            try {
                packageManager.getPackageInfo(packageName, PackageManager.GET_ACTIVITIES);
                // App is installed
                Map<String, String> appInfo = new HashMap<>();
                appInfo.put("packageName", packageName);
                appInfo.put("appName", appName);
                installedApps.add(appInfo);
            } catch (PackageManager.NameNotFoundException e) {
                // App is not installed, skip
            }
        }
        
        // Also check for any other apps that can handle UPI intents
        Intent upiIntent = new Intent(Intent.ACTION_VIEW);
        upiIntent.setData(Uri.parse("upi://pay"));
        List<ResolveInfo> resolveInfos = packageManager.queryIntentActivities(upiIntent, 0);
        
        for (ResolveInfo resolveInfo : resolveInfos) {
            String packageName = resolveInfo.activityInfo.packageName;
            String appName = resolveInfo.loadLabel(packageManager).toString();
            
            // Check if we already added this app
            boolean alreadyAdded = false;
            for (Map<String, String> existingApp : installedApps) {
                if (packageName.equals(existingApp.get("packageName"))) {
                    alreadyAdded = true;
                    break;
                }
            }
            
            if (!alreadyAdded) {
                Map<String, String> appInfo = new HashMap<>();
                appInfo.put("packageName", packageName);
                appInfo.put("appName", appName);
                installedApps.add(appInfo);
            }
        }
        
        return installedApps;
    }
    
    private boolean launchUpiApp(String packageName, String upiUrl) {
        try {
            Intent intent = new Intent(Intent.ACTION_VIEW);
            intent.setData(Uri.parse(upiUrl));
            intent.setPackage(packageName);
            
            if (intent.resolveActivity(getPackageManager()) != null) {
                startActivity(intent);
                return true;
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return false;
    }
    
    private boolean launchUpiIntent(String upiUrl) {
        try {
            Intent intent = new Intent(Intent.ACTION_VIEW);
            intent.setData(Uri.parse(upiUrl));
            
            if (intent.resolveActivity(getPackageManager()) != null) {
                startActivity(intent);
                return true;
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return false;
    }
}
