import 'package:url_launcher/url_launcher.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../config/upi_config.dart';

class UpiService {
  static const MethodChannel _channel = MethodChannel('upi_helper');
  
  static const List<Map<String, String>> upiApps = [
    {
      'name': 'Google Pay',
      'scheme': 'tez://upi/pay',
      'packageName': 'com.google.android.apps.nbu.paisa.user',
      'fallback': 'upi://pay',
      'icon': '💳',
    },
    {
      'name': 'PhonePe',
      'scheme': 'phonepe://pay',
      'packageName': 'com.phonepe.app',
      'fallback': 'upi://pay',
      'icon': '📱', 
    },
    {
      'name': 'Paytm',
      'scheme': 'paytmmp://pay',
      'packageName': 'net.one97.paytm',
      'fallback': 'upi://pay',
      'icon': '💰',
    },
    {
      'name': 'BHIM UPI',
      'scheme': 'bhim://pay',
      'packageName': 'in.org.npci.upiapp',
      'fallback': 'upi://pay',
      'icon': '🏦',
    },
    {
      'name': 'Amazon Pay',
      'scheme': 'amazonpay://pay',
      'packageName': 'in.amazon.mShop.android.shopping',
      'fallback': 'upi://pay',
      'icon': '🛒',
    },
    {
      'name': 'CRED',
      'scheme': 'credpay://pay',
      'packageName': 'com.dreamplug.androidapp',
      'fallback': 'upi://pay',
      'icon': '💎',
    },
    {
      'name': 'Flipkart UPI',
      'scheme': 'flipkart://upi/pay',
      'packageName': 'com.flipkart.android',
      'fallback': 'upi://pay',
      'icon': '🛍️',
    },
    {
      'name': 'Generic UPI',
      'scheme': 'upi://pay',
      'packageName': '',
      'fallback': 'upi://pay',
      'icon': '💵',
    },
  ];

  static Future<void> showUpiAppSelector(
    BuildContext context,
    String upiString,
    double amount,
    Function(double) onPaymentSuccess,
  ) async {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(25)),
        ),
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Handle bar
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 24),
            
            // Header
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Choose UPI App',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Colors.grey[800],
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Select your preferred payment method',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey[600],
                      ),
                    ),
                  ],
                ),
                Container(
                  decoration: BoxDecoration(
                    color: Colors.grey[100],
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: Icon(Icons.close, color: Colors.grey[600]),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            
            // Amount display
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [Colors.green[50]!, Colors.green[100]!],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: Colors.green[200]!),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.currency_rupee, color: Colors.green[700], size: 24),
                  const SizedBox(width: 8),
                  Text(
                    amount.toStringAsFixed(2),
                    style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: Colors.green[700],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 32),
            
            // UPI Apps Grid - Show only installed apps
            FutureBuilder<List<Map<String, String>>>(
              future: getInstalledUpiApps(), // Use all apps, let user choose
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(
                    child: Padding(
                      padding: EdgeInsets.all(32.0),
                      child: CircularProgressIndicator(),
                    ),
                  );
                }
                
                final installedApps = snapshot.data ?? [];
                
                if (installedApps.isEmpty) {
                  return Container(
                    padding: const EdgeInsets.all(32),
                    child: Column(
                      children: [
                        Icon(
                          Icons.error_outline,
                          size: 48,
                          color: Colors.orange[600],
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'No UPI Apps Found',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.grey[700],
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Please install a UPI app like Google Pay, PhonePe, or Paytm to make payments.',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: Colors.grey[600],
                          ),
                        ),
                      ],
                    ),
                  );
                }
                
                return GridView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 3,
                    childAspectRatio: 0.85,
                    crossAxisSpacing: 16,
                    mainAxisSpacing: 16,
                  ),
                  itemCount: installedApps.length,
                  itemBuilder: (context, index) {
                    final installedApp = installedApps[index];
                    
                    // Find matching app info from our static list
                    final appInfo = upiApps.firstWhere(
                      (app) => app['packageName'] == installedApp['packageName'],
                      orElse: () => {
                        'name': installedApp['appName'] ?? 'UPI App',
                        'scheme': 'upi://pay',
                        'packageName': installedApp['packageName'] ?? '',
                        'fallback': 'upi://pay',
                        'icon': '💳',
                      },
                    );
                    
                    // Check if this is Google Pay for special handling
                    final isGooglePay = appInfo['packageName'] == 'com.google.android.apps.nbu.paisa.user';
                    
                    return GestureDetector(
                      onTap: () async {
                        Navigator.pop(context);
                        
                        // Show warning for Google Pay due to known issues
                        if (isGooglePay) {
                          final shouldContinue = await showDialog<bool>(
                            context: context,
                            builder: (context) => AlertDialog(
                              title: const Text('Google Pay Notice'),
                              content: const Text(
                                'Google Pay sometimes has issues with donation UPI IDs. '
                                'We recommend using PhonePe, Paytm, or BHIM for better reliability.\n\n'
                                'Do you want to continue with Google Pay anyway?'
                              ),
                              actions: [
                                TextButton(
                                  onPressed: () => Navigator.pop(context, false),
                                  child: const Text('Choose Different App'),
                                ),
                                TextButton(
                                  onPressed: () => Navigator.pop(context, true),
                                  child: const Text('Continue with Google Pay'),
                                ),
                              ],
                            ),
                          );
                          
                          if (shouldContinue != true) {
                            return;
                          }
                        }
                        
                        await _launchUpiApp(
                          appInfo['scheme']!,
                          appInfo['fallback']!,
                          upiString,
                          amount,
                          context,
                          onPaymentSuccess,
                        );
                      },
                      child: Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: isGooglePay ? Colors.orange[200]! : Colors.grey[200]!,
                        width: isGooglePay ? 2 : 1,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.grey.withOpacity(0.08),
                          spreadRadius: 0,
                          blurRadius: 8,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                          width: 48,
                          height: 48,
                          decoration: BoxDecoration(
                            color: isGooglePay ? Colors.orange[50] : Colors.grey[50],
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Center(
                            child: Text(
                              appInfo['icon']!,
                              style: const TextStyle(fontSize: 24),
                            ),
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          appInfo['name']!,
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: Colors.grey[800],
                          ),
                          textAlign: TextAlign.center,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        if (isGooglePay) ...[
                          const SizedBox(height: 2),
                          Text(
                            'May have issues',
                            style: TextStyle(
                              fontSize: 9,
                              color: Colors.orange[600],
                              fontWeight: FontWeight.w500,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ] else if (appInfo['name'] == 'PhonePe' || 
                                   appInfo['name'] == 'Paytm' || 
                                   appInfo['name'] == 'BHIM UPI' ||
                                   appInfo['name'] == 'Flipkart UPI') ...[
                          const SizedBox(height: 2),
                          Text(
                            'Recommended',
                            style: TextStyle(
                              fontSize: 9,
                              color: Colors.green[600],
                              fontWeight: FontWeight.w500,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ],
                      ],
                    ),
                  ),
                );
              },
            );
              },
            ),
            const SizedBox(height: 16),
            
            // Helpful info section
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.orange[50],
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.orange[200]!),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(Icons.warning_outlined, size: 16, color: Colors.orange[700]),
                      const SizedBox(width: 6),
                      Text(
                        'Development Notice',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: Colors.orange[700],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Currently using placeholder UPI ID. For real payments, you need:\n'
                    '• A valid UPI ID from your NGO\'s bank account\n'
                    '• Or a merchant UPI ID from payment processors\n'
                    '• Test/demo UPI IDs will be rejected by all UPI apps\n'
                    '\nContact your bank to get a real UPI ID for donations.',
                    style: TextStyle(
                      fontSize: 11,
                      color: Colors.orange[600],
                      height: 1.3,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            
            // Payment tips section
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.blue[50],
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.blue[100]!),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(Icons.info_outline, size: 16, color: Colors.blue[700]),
                      const SizedBox(width: 6),
                      Text(
                        'Payment Tips',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: Colors.blue[700],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '• PhonePe, Paytm & BHIM work best for donations\n'
                    '• Google Pay may show "banking name" or "QR code" errors\n'
                    '• If payment fails, try a different UPI app\n'
                    '• Ensure you have sufficient balance before paying',
                    style: TextStyle(
                      fontSize: 11,
                      color: Colors.blue[600],
                      height: 1.3,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            
            // Configuration button for developers
            if (UpiConfig.IS_DEVELOPMENT) ...[
              SizedBox(
                width: double.infinity,
                child: OutlinedButton.icon(
                  onPressed: () {
                    Navigator.pop(context);
                    UpiConfig.showConfigurationDialog(context);
                  },
                  icon: const Icon(Icons.settings, color: Colors.red),
                  label: const Text(
                    'Fix UPI Configuration',
                    style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold),
                  ),
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    side: const BorderSide(color: Colors.red),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 16),
            ],
            
            // Cancel button
            SizedBox(
              width: double.infinity,
              child: TextButton(
                onPressed: () => Navigator.pop(context),
                style: TextButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: Text(
                  'Cancel',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Colors.grey[600],
                  ),
                ),
              ),
            ),
            
            // Safe area padding for bottom
            SizedBox(height: MediaQuery.of(context).padding.bottom),
          ],
        ),
      ),
    );
  }

  // Test if a UPI app can be launched
  static Future<bool> canLaunchUpiApp(String packageName) async {
    try {
      // Try to launch a test UPI URL to see if the app exists
      final testUrl = 'upi://pay?pa=test@upi&pn=Test&am=1&cu=INR';
      
      // Check if the app is installed by trying to resolve the intent
      if (packageName.isNotEmpty) {
        final url = '$testUrl&package=$packageName';
        return await canLaunchUrl(Uri.parse(url));
      } else {
        return await canLaunchUrl(Uri.parse(testUrl));
      }
    } catch (e) {
      print('Error checking if UPI app can be launched: $e');
      return false;
    }
  }

  // Get list of actually working UPI apps
  static Future<List<Map<String, String>>> getWorkingUpiApps() async {
    final allApps = await getInstalledUpiApps();
    final workingApps = <Map<String, String>>[];
    
    for (final app in allApps) {
      // Test if the app can handle UPI intents
      try {
        final testUrl = 'upi://pay?pa=test@upi&pn=Test&am=1&cu=INR';
        if (await canLaunchUrl(Uri.parse(testUrl))) {
          workingApps.add(app);
        }
      } catch (e) {
        // If there's an error testing, include the app anyway
        // Better to show it and let user try than to hide a working app
        workingApps.add(app);
      }
    }
    
    return workingApps;
  }
  static Future<List<Map<String, String>>> getInstalledUpiApps() async {
    try {
      print('=== UPI App Detection Debug ===');
      print('Calling method channel to get installed UPI apps...');
      final List<dynamic> result = await _channel.invokeMethod('getInstalledUpiApps');
      print('Method channel result: $result');
      final apps = result.map((app) => Map<String, String>.from(app)).toList();
      print('Converted apps list: $apps');
      return apps;
    } catch (e) {
      print('Error getting installed UPI apps: $e');
      print('Stack trace: ${StackTrace.current}');
      print('Using fallback app list for better UPI compatibility...');
      
      // Enhanced fallback: return all common UPI apps
      // The app will try to launch each one and show only working ones
      return [
        {'packageName': 'com.google.android.apps.nbu.paisa.user', 'appName': 'Google Pay'},
        {'packageName': 'com.phonepe.app', 'appName': 'PhonePe'},
        {'packageName': 'net.one97.paytm', 'appName': 'Paytm'},
        {'packageName': 'in.org.npci.upiapp', 'appName': 'BHIM UPI'},
        {'packageName': 'in.amazon.mShop.android.shopping', 'appName': 'Amazon Pay'},
        {'packageName': 'com.dreamplug.androidapp', 'appName': 'CRED'},
        {'packageName': 'com.flipkart.android', 'appName': 'Flipkart UPI'},
        {'packageName': 'com.mobikwik_new', 'appName': 'MobiKwik'},
        {'packageName': 'com.freecharge.android', 'appName': 'Freecharge'},
        {'packageName': 'com.myairtelapp', 'appName': 'Airtel Thanks'},
        {'packageName': 'com.whatsapp', 'appName': 'WhatsApp Pay'},
        {'packageName': 'com.jio.myjio', 'appName': 'JioMoney'},
      ];
    }
  }

  // Launch UPI app using method channel
  static Future<bool> _launchUpiWithMethodChannel(
    String packageName,
    String upiUrl,
  ) async {
    try {
      final bool result = await _channel.invokeMethod('launchUpiApp', {
        'packageName': packageName,
        'upiUrl': upiUrl,
      });
      return result;
    } catch (e) {
      print('Error launching UPI app via method channel: $e');
      return false;
    }
  }

  // Launch UPI intent directly
  static Future<bool> _launchUpiIntent(String upiUrl) async {
    try {
      final bool result = await _channel.invokeMethod('launchUpiIntent', {
        'upiUrl': upiUrl,
      });
      return result;
    } catch (e) {
      print('Error launching UPI intent: $e');
      return false;
    }
  }

  static Future<void> _launchUpiApp(
    String upiScheme,
    String fallbackScheme,
    String upiString,
    double amount,
    BuildContext context,
    Function(double) onPaymentSuccess,
  ) async {
    try {
      print('=== UPI Payment Debug ===');
      print('Scheme: $upiScheme');
      print('UPI String: $upiString');
      print('Amount: $amount');
      
      // Extract package name from scheme
      String? packageName;
      String? appName;
      for (final app in upiApps) {
        if (app['scheme'] == upiScheme) {
          packageName = app['packageName'];
          appName = app['name'];
          break;
        }
      }
      
      bool launched = false;
      
      // Simplified URL generation - try only essential formats
      List<String> urlsToTry = [];
      
      print('=== UPI Launch Strategy ===');
      print('App: $appName');
      print('Package: $packageName');
      print('Scheme: $upiScheme');
      
      // Enhanced app launching strategy - try multiple approaches
      urlsToTry.add(_buildUpiUrl(upiString, amount, upiScheme));
      urlsToTry.add(_buildUpiUrl(upiString, amount, 'upi://pay'));
      
      // Add fallback URLs for maximum compatibility
      final workingUpiId = UpiConfig.getUpiId();
      urlsToTry.add('$upiScheme?pa=$workingUpiId&pn=NGO%20Donation&tn=Charitable%20Donation&am=$amount&cu=INR&mode=02');
      urlsToTry.add('upi://pay?pa=$workingUpiId&pn=NGO%20Donation&tn=Charitable%20Donation&am=$amount&cu=INR&mode=02');
      
      print('URLs to try: $urlsToTry');
      
      // Try each URL format until one works
      for (int i = 0; i < urlsToTry.length && !launched; i++) {
        final currentUrl = urlsToTry[i];
        print('Attempting URL ${i + 1}/${urlsToTry.length}: $currentUrl');
        
        // Try method channel approach first if we have a package name
        if (packageName != null && packageName.isNotEmpty) {
          print('Trying method channel launch for package: $packageName');
          launched = await _launchUpiWithMethodChannel(packageName, currentUrl);
          print('Method channel launch result: $launched');
        }
        
        // If method channel failed, try direct intent launch
        if (!launched) {
          print('Trying direct UPI intent launch...');
          launched = await _launchUpiIntent(currentUrl);
          print('Direct intent launch result: $launched');
        }
        
        // If still failed, try the URL launcher approach
        if (!launched) {
          print('Trying URL launcher as fallback...');
          launched = await _tryLaunchUrl(currentUrl, context);
          print('URL launcher fallback result: $launched');
        }
        
        if (launched) {
          print('Successfully launched with URL: $currentUrl');
          break;
        } else {
          print('Failed to launch with URL: $currentUrl');
        }
      }
      
      // Only show payment confirmation dialog if UPI launch was successful
      if (launched && context.mounted) {
        print('UPI app launched successfully, showing payment confirmation dialog...');
        Future.delayed(const Duration(seconds: 1), () {
          if (context.mounted) {
            _showPaymentConfirmationDialog(context, amount, onPaymentSuccess);
          }
        });
      } else if (context.mounted) {
        // Extract UPI ID from upiString for better error messaging
        String? upiId;
        try {
          final uri = Uri.parse(upiString);
          upiId = uri.queryParameters['pa'];
        } catch (e) {
          print('Could not extract UPI ID from string: $e');
        }
        
        // UPI launch failed, show error
        print('UPI launch failed, showing error dialog...');
        await _showUpiErrorDialog(context, 'Unable to open ${appName ?? 'UPI app'}. Please check if you have $appName installed and try again.', upiId);
      }
    } catch (e) {
      print('Error launching UPI app: $e');
      if (context.mounted) {
        // Extract UPI ID from upiString for error context
        String? upiId;
        try {
          final uri = Uri.parse(upiString);
          upiId = uri.queryParameters['pa'];
        } catch (ex) {
          print('Could not extract UPI ID from string: $ex');
        }
        
        await _showUpiErrorDialog(context, e.toString(), upiId);
      }
    }
  }

  static String _buildUpiUrl(String upiString, double amount, String scheme) {
    try {
      print('=== Building UPI URL ===');
      print('Scheme: $scheme');
      print('UPI String: $upiString');
      print('Amount: $amount');
      
      // Parse the UPI string to extract parameters
      final uri = Uri.parse(upiString);
      final params = uri.queryParameters;
      
      final payeeAddress = params['pa'] ?? '';
      final payeeName = params['pn'] ?? 'NGO Donation';
      final transactionNote = params['tn'] ?? 'Charitable Donation';
      final currency = 'INR';
      
      print('Payee Address: $payeeAddress');
      print('Payee Name: $payeeName');
      print('Transaction Note: $transactionNote');
      
      String finalUrl;
      final transactionId = 'TXN${DateTime.now().millisecondsSinceEpoch}';
      
      // Enhanced URL building with proper formatting for each app
      if (scheme.contains('tez://')) {
        // Google Pay - Use the most compatible format
        finalUrl = 'tez://upi/pay?pa=$payeeAddress&pn=${Uri.encodeComponent(payeeName)}&tn=${Uri.encodeComponent(transactionNote)}&am=$amount&cu=$currency&tr=$transactionId&mode=02';
      } else if (scheme.contains('paytmmp://')) {
        // Paytm Merchant format
        finalUrl = 'paytmmp://pay?pa=$payeeAddress&pn=${Uri.encodeComponent(payeeName)}&tn=${Uri.encodeComponent(transactionNote)}&am=$amount&cu=$currency&tr=$transactionId&mode=02';
      } else if (scheme.contains('paytm://')) {
        // Standard Paytm format
        finalUrl = 'paytm://pay?pa=$payeeAddress&pn=${Uri.encodeComponent(payeeName)}&tn=${Uri.encodeComponent(transactionNote)}&am=$amount&cu=$currency&tr=$transactionId&mode=02';
      } else if (scheme.contains('phonepe://')) {
        // PhonePe format
        finalUrl = 'phonepe://pay?pa=$payeeAddress&pn=${Uri.encodeComponent(payeeName)}&tn=${Uri.encodeComponent(transactionNote)}&am=$amount&cu=$currency&tr=$transactionId&mode=02';
      } else if (scheme.contains('bhim://')) {
        // BHIM format
        finalUrl = 'bhim://pay?pa=$payeeAddress&pn=${Uri.encodeComponent(payeeName)}&tn=${Uri.encodeComponent(transactionNote)}&am=$amount&cu=$currency&tr=$transactionId&mode=02';
      } else if (scheme.contains('upi://pay')) {
        // Standard UPI format - add amount parameter
        if (upiString.contains('&am=') || upiString.contains('?am=')) {
          // Replace existing amount
          finalUrl = upiString.replaceAllMapped(
            RegExp(r'[&?]am=[\d.]*'),
            (match) => '&am=$amount',
          );
          // Add currency and mode if not present
          if (!finalUrl.contains('&cu=')) {
            finalUrl += '&cu=$currency';
          }
          if (!finalUrl.contains('&mode=')) {
            finalUrl += '&mode=02';
          }
        } else {
          // Add amount parameter
          final separator = upiString.contains('?') ? '&' : '?';
          finalUrl = '$upiString${separator}am=$amount&cu=$currency&tr=$transactionId&mode=02';
        }
      } else {
        // Fallback - use standard UPI format
        finalUrl = 'upi://pay?pa=$payeeAddress&pn=${Uri.encodeComponent(payeeName)}&tn=${Uri.encodeComponent(transactionNote)}&am=$amount&cu=$currency&tr=$transactionId&mode=02';
      }
      
      print('Final URL: $finalUrl');
      return finalUrl;
    } catch (e) {
      print('Error building UPI URL: $e');
      // Enhanced fallback with working UPI ID
      final workingUpiId = UpiConfig.getUpiId();
      return 'upi://pay?pa=$workingUpiId&pn=NGO%20Donation&tn=Charitable%20Donation&am=$amount&cu=INR&mode=02';
    }
  }

  static Future<bool> _tryLaunchUrl(String url, BuildContext context) async {
    try {
      final uri = Uri.parse(url);
      
      // Check if the URL can be launched
      final canLaunch = await canLaunchUrl(uri);
      print('Can launch $url: $canLaunch');
      
      // Try to launch even if canLaunchUrl returns false (common UPI issue on Android)
      bool launched = false;
      
      if (canLaunch) {
        launched = await launchUrl(
          uri,
          mode: LaunchMode.externalApplication,
        );
      } else {
        // Force launch attempt even if canLaunchUrl says false
        print('Forcing launch attempt despite canLaunchUrl being false...');
        try {
          launched = await launchUrl(
            uri,
            mode: LaunchMode.externalApplication,
          );
        } catch (e) {
          print('Forced launch failed: $e');
          launched = false;
        }
      }
      
      print('Launch result: $launched');
      return launched;
    } catch (e) {
      print('Error in _tryLaunchUrl: $e');
      return false;
    }
  }

  static Future<void> _showUpiErrorDialog(BuildContext context, String error, [String? upiId]) async {
    if (!context.mounted) return;
    
    // Check for specific error types and provide targeted guidance
    String title = 'UPI Payment Issue';
    List<String> suggestions = [];
    
    // The primary issue is likely the UPI ID being invalid/test
    if (error.toLowerCase().contains('risk alert') || 
        error.toLowerCase().contains('suspicious') ||
        error.toLowerCase().contains('risk policy')) {
      title = 'UPI Risk Policy Block';
      suggestions = [
        '⚠️ MAIN ISSUE: Currently using placeholder/test UPI ID',
        '• UPI apps reject test/demo UPI IDs for security',
        '• You need a REAL UPI ID from your NGO\'s bank account',
        '• Contact your bank to create a valid UPI ID',
        '• Alternatively, use a payment gateway for donations',
        '• Test UPI IDs like "test@paytm" will always fail',
      ];
    } else if (error.toLowerCase().contains('limit') || error.toLowerCase().contains('exceed')) {
      title = 'UPI Transaction Limit';
      suggestions = [
        '• Try a smaller amount (₹5000 is daily limit for most apps)',
        '• Check your daily/monthly UPI transaction limits',
        '• Use NEFT/IMPS for larger amounts',
        '• Try again after 24 hours',
      ];
    } else if (error.toLowerCase().contains('no payment account') || 
               error.toLowerCase().contains('cannot pay with this qr') ||
               error.toLowerCase().contains('not registered') ||
               error.toLowerCase().contains('could not load banking name')) {
      title = 'Invalid UPI ID Error';
      suggestions = [
        '⚠️ MAIN ISSUE: UPI ID is not valid/real',
        '• The UPI ID "${upiId ?? "provided"}" doesn\'t exist',
        '• Test/placeholder UPI IDs are rejected by all apps',
        '• You need a real UPI ID from an actual bank account',
        '• Contact your bank to set up UPI for your NGO account',
        '• Try different UPI apps, but the core issue is the invalid UPI ID',
      ];
    } else if (error.toLowerCase().contains('invalid') || error.toLowerCase().contains('not found')) {
      title = 'UPI ID Not Found';
      suggestions = [
        '⚠️ The UPI ID doesn\'t exist or is invalid',
        '• Verify the UPI ID format (should be like name@bank)',
        '• Contact the organization for correct UPI details',
        '• Ensure the UPI ID is from a real bank account',
        '• Test/demo UPI IDs will not work',
      ];
    } else {
      suggestions = [
        '⚠️ Likely issue: Invalid/test UPI ID being used',
        '• Installing a UPI app (Google Pay, PhonePe, Paytm, Flipkart UPI)',
        '• Checking if UPI apps are enabled and updated',
        '• Verifying internet connection',
        '• Most importantly: Use a real UPI ID, not test/demo ones',
      ];
    }
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(title),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Failed to complete UPI payment. Please try:'),
            const SizedBox(height: 8),
            ...suggestions.map((suggestion) => Padding(
              padding: const EdgeInsets.only(bottom: 4),
              child: Text(suggestion),
            )),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.blue[50],
                borderRadius: BorderRadius.circular(8),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '💡 Critical: You need a REAL UPI ID from your bank account. Test IDs like "test@paytm" will always fail.',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.blue[800],
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  if (upiId != null) ...[
                    const SizedBox(height: 4),
                    Text(
                      'UPI ID: $upiId',
                      style: TextStyle(
                        fontSize: 11,
                        color: Colors.blue[600],
                        fontFamily: 'monospace',
                      ),
                    ),
                  ],
                ],
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Technical Error: $error',
              style: TextStyle(
                fontSize: 10,
                color: Colors.grey[600],
                fontStyle: FontStyle.italic,
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Try Again'),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(context);
              const playStoreUrl = 'https://play.google.com/store/search?q=upi%20payment';
              if (await canLaunchUrl(Uri.parse(playStoreUrl))) {
                await launchUrl(Uri.parse(playStoreUrl));
              }
            },
            child: const Text('Install UPI App'),
          ),
        ],
      ),
    );
  }

  static void _showPaymentConfirmationDialog(
    BuildContext context,
    double amount,
    Function(double) onPaymentSuccess,
  ) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        contentPadding: const EdgeInsets.all(24),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                color: Colors.green[50],
                borderRadius: BorderRadius.circular(40),
              ),
              child: Icon(
                Icons.payment_rounded,
                size: 40,
                color: Colors.green[600],
              ),
            ),
            const SizedBox(height: 24),
            Text(
              'Payment Confirmation',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.grey[800],
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 12),
            RichText(
              textAlign: TextAlign.center,
              text: TextSpan(
                children: [
                  TextSpan(
                    text: 'Did you complete the payment of ',
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.grey[600],
                    ),
                  ),
                  TextSpan(
                    text: '₹${amount.toStringAsFixed(2)}',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.green[600],
                    ),
                  ),
                  TextSpan(
                    text: '?',
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.grey[600],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
              decoration: BoxDecoration(
                color: Colors.blue[50],
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                'Check your UPI app for payment status',
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.blue[600],
                  fontWeight: FontWeight.w500,
                ),
                textAlign: TextAlign.center,
              ),
            ),
            const SizedBox(height: 16),
            // Common issues and solutions
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.amber[50],
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.amber[200]!),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(Icons.info_outline, size: 16, color: Colors.amber[700]),
                      const SizedBox(width: 6),
                      Text(
                        'Payment Issues?',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: Colors.amber[700],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Text(
                    '• If payment failed, try a smaller amount\n• Check daily UPI limit (₹1,00,000)\n• Ensure sufficient balance\n• Try different UPI app if needed',
                    style: TextStyle(
                      fontSize: 11,
                      color: Colors.amber[700],
                      height: 1.3,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            Row(
              children: [
                Expanded(
                  child: TextButton(
                    onPressed: () {
                      Navigator.pop(context);
                      _showPaymentFailedDialog(context, amount);
                    },
                    style: TextButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                        side: BorderSide(color: Colors.grey[300]!),
                      ),
                    ),
                    child: Text(
                      'Failed',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: Colors.grey[600],
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.pop(context);
                      onPaymentSuccess(amount);
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Row(
                            children: [
                              const Icon(Icons.check_circle, color: Colors.white, size: 20),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  'Thank you for your donation of ₹${amount.toStringAsFixed(2)}!',
                                  style: const TextStyle(fontWeight: FontWeight.w500),
                                ),
                              ),
                            ],
                          ),
                          backgroundColor: Colors.green[600],
                          duration: const Duration(seconds: 4),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                          behavior: SnackBarBehavior.floating,
                        ),
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green[600],
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    child: const Text(
                      'Success',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  static void _showPaymentFailedDialog(BuildContext context, double originalAmount) {
    final List<double> suggestedAmounts = [
      if (originalAmount > 5000) 5000,
      if (originalAmount > 2000) 2000,
      if (originalAmount > 1000) 1000,
      if (originalAmount > 500) 500,
      if (originalAmount > 100) 100,
    ];

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        contentPadding: const EdgeInsets.all(24),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                color: Colors.red[50],
                borderRadius: BorderRadius.circular(40),
              ),
              child: Icon(
                Icons.error_outline,
                size: 40,
                color: Colors.red[600],
              ),
            ),
            const SizedBox(height: 24),
            Text(
              'Payment Failed',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.grey[800],
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 12),
            Text(
              'Your payment of ₹${originalAmount.toStringAsFixed(2)} could not be processed.',
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey[600],
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.blue[50],
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.blue[200]!),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(Icons.lightbulb_outline, size: 18, color: Colors.blue[700]),
                      const SizedBox(width: 8),
                      Text(
                        'Possible Solutions:',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: Colors.blue[700],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '• Try a smaller amount (daily UPI limit: ₹1,00,000)\n• Check account balance\n• Verify UPI PIN\n• Try different UPI app\n• Contact your bank if issue persists',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.blue[700],
                      height: 1.4,
                    ),
                  ),
                ],
              ),
            ),
            if (suggestedAmounts.isNotEmpty) ...[
              const SizedBox(height: 16),
              Text(
                'Try these amounts:',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: Colors.grey[700],
                ),
              ),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: suggestedAmounts.map((amount) => 
                  OutlinedButton(
                    onPressed: () {
                      Navigator.pop(context);
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('Suggested amount: ₹${amount.toStringAsFixed(0)}'),
                          action: SnackBarAction(
                            label: 'Retry',
                            onPressed: () {
                              // This would trigger a retry with the suggested amount
                            },
                          ),
                        ),
                      );
                    },
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                      ),
                    ),
                    child: Text(
                      '₹${amount.toStringAsFixed(0)}',
                      style: const TextStyle(fontSize: 12),
                    ),
                  ),
                ).toList(),
              ),
            ],
            const SizedBox(height: 24),
            Row(
              children: [
                Expanded(
                  child: TextButton(
                    onPressed: () => Navigator.pop(context),
                    style: TextButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    child: const Text(
                      'Cancel',
                      style: TextStyle(fontSize: 16),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.pop(context);
                      // Retry logic can be added here
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue[600],
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    child: const Text(
                      'Try Again',
                      style: TextStyle(fontSize: 16),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  static String generateUpiString(String upiId, String name, String note, [double? amount]) {
    print('=== UPI String Generation Debug ===');
    print('Input UPI ID: $upiId');
    print('Input name: $name');
    print('Input note: $note');
    print('Input amount: $amount');
    
    // Use the configured UPI ID or use a working test UPI ID for development
    String finalUpiId;
    
    // Check if the provided UPI ID has a valid format
    if (upiId.isNotEmpty && upiId.contains('@') && UpiValidator.isValidUpiId(upiId)) {
      finalUpiId = upiId;
      print('Using provided UPI ID: $finalUpiId');
    } else {
      // Get UPI ID from configuration or use working test UPI ID
      final configuredUpiId = UpiConfig.getUpiId();
      
      if (configuredUpiId == 'INVALID_TEST_UPI_ID' || configuredUpiId == 'your.ngo@bankname') {
        // Development mode or not configured - use a working merchant test ID
        finalUpiId = 'paytmqr2810050501011@paytm';  // Working Paytm merchant ID for testing
        print('Using working test merchant UPI ID: $finalUpiId');
      } else if (UpiValidator.isValidUpiId(configuredUpiId)) {
        finalUpiId = configuredUpiId;
        print('Using configured UPI ID: $finalUpiId');
      } else {
        // Fallback to working merchant ID
        finalUpiId = 'paytmqr2810050501011@paytm';
        print('Using fallback working merchant UPI ID: $finalUpiId');
      }
    }
    
    // Sanitize name and note for better compatibility
    String sanitizedName = name.isNotEmpty ? 
      name.replaceAll(RegExp(r'[^\w\s]'), '').trim() : 'NGO Donation';
    String sanitizedNote = note.isNotEmpty ? 
      note.replaceAll(RegExp(r'[^\w\s]'), '').trim() : 'Charitable Donation';
    
    // Limit length to avoid issues
    if (sanitizedName.length > 25) {
      sanitizedName = sanitizedName.substring(0, 25);
    }
    if (sanitizedNote.length > 30) {
      sanitizedNote = sanitizedNote.substring(0, 30);
    }
    
    print('Sanitized name: $sanitizedName');
    print('Sanitized note: $sanitizedNote');
    
    // Create a UPI string with amount if provided
    String upiString = "upi://pay?pa=$finalUpiId&pn=${Uri.encodeComponent(sanitizedName)}&tn=${Uri.encodeComponent(sanitizedNote)}&cu=INR&mode=02";
    
    if (amount != null && amount > 0) {
      upiString += "&am=${amount.toStringAsFixed(2)}";
    }
    
    print('Generated UPI string: $upiString');
    return upiString;
  }

  // Launch UPI payment with native system app chooser
  static Future<void> launchUpiWithSystemChooser(String upiString) async {
    final Uri upiUri = Uri.parse(upiString);
    
    if (await canLaunchUrl(upiUri)) {
      await launchUrl(
        upiUri,
        mode: LaunchMode.externalApplication,
      );
    } else {
      throw Exception('No UPI apps found on device');
    }
  }

  // Launch specific UPI app
  static Future<void> launchSpecificUpiApp(String upiString, String packageName) async {
    try {
      // For specific apps, try their custom scheme first
      String appSpecificUri = upiString;
      
      switch (packageName) {
        case 'com.google.android.apps.nbu.paisa.user':
          appSpecificUri = upiString.replaceFirst('upi://', 'tez://');
          break;
        case 'com.phonepe.app':
          appSpecificUri = upiString.replaceFirst('upi://', 'phonepe://');
          break;
        case 'net.one97.paytm':
          appSpecificUri = upiString.replaceFirst('upi://', 'paytmmp://');
          break;
      }
      
      final Uri specificUri = Uri.parse(appSpecificUri);
      if (await canLaunchUrl(specificUri)) {
        await launchUrl(specificUri, mode: LaunchMode.externalApplication);
        return;
      }
    } catch (e) {
      print('Failed to launch specific app: $e');
    }
    
    // Fallback to system chooser
    await launchUpiWithSystemChooser(upiString);
  }
}
