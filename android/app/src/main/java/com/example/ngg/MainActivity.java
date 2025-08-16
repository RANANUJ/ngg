package com.example.ngg;

import android.content.Intent;
import android.content.pm.PackageManager;
import android.net.Uri;
import io.flutter.embedding.android.FlutterActivity;
import io.flutter.embedding.engine.FlutterEngine;
import io.flutter.plugin.common.MethodChannel;
import java.util.*;

public class MainActivity extends FlutterActivity {
    private static final String CHANNEL = "upi_helper";

    @Override
    public void configureFlutterEngine(FlutterEngine flutterEngine) {
        super.configureFlutterEngine(flutterEngine);
        
        new MethodChannel(flutterEngine.getDartExecutor().getBinaryMessenger(), CHANNEL)
            .setMethodCallHandler((call, result) -> {
                switch (call.method) {
                    case "getInstalledUpiApps":
                        List<Map<String, String>> apps = getInstalledUpiApps();
                        result.success(apps);
                        break;
                    case "launchUpiIntent":
                        String upiUrl = call.argument("upiUrl");
                        if (upiUrl != null) {
                            boolean success = launchUpiIntent(upiUrl);
                            result.success(success);
                        } else {
                            result.error("INVALID_ARGUMENT", "UPI URL is required", null);
                        }
                        break;
                    default:
                        result.notImplemented();
                        break;
                }
            });
    }
    
    private List<Map<String, String>> getInstalledUpiApps() {
        String[][] upiPackages = {
            {"com.google.android.apps.nbu.paisa.user", "Google Pay"},
            {"net.one97.paytm", "Paytm"},
            {"in.org.npci.upiapp", "BHIM"},
            {"com.phonepe.app", "PhonePe"},
            {"com.amazon.mShop.android.shopping", "Amazon Pay"},
            {"com.whatsapp", "WhatsApp"}
        };
        
        List<Map<String, String>> installedApps = new ArrayList<>();
        PackageManager packageManager = getPackageManager();
        
        for (String[] packageInfo : upiPackages) {
            try {
                packageManager.getPackageInfo(packageInfo[0], 0);
                Map<String, String> app = new HashMap<>();
                app.put("packageName", packageInfo[0]);
                app.put("appName", packageInfo[1]);
                installedApps.add(app);
            } catch (PackageManager.NameNotFoundException e) {
                // App not installed
            }
        }
        
        return installedApps;
    }
    
    private boolean launchUpiIntent(String upiUrl) {
        try {
            Intent intent = new Intent(Intent.ACTION_VIEW, Uri.parse(upiUrl));
            intent.addFlags(Intent.FLAG_ACTIVITY_NEW_TASK);
            
            if (intent.resolveActivity(getPackageManager()) != null) {
                startActivity(intent);
                return true;
            } else {
                return false;
            }
        } catch (Exception e) {
            return false;
        }
    }
}
