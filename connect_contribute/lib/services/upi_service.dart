import 'package:url_launcher/url_launcher.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

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
              future: getInstalledUpiApps(),
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
                    
                    return GestureDetector(
                      onTap: () async {
                        Navigator.pop(context);
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
                      border: Border.all(color: Colors.grey[200]!),
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
                            color: Colors.grey[50],
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Center(
                            child: Text(
                              appInfo['icon']!,
                              style: const TextStyle(fontSize: 24),
                            ),
                          ),
                        ),
                        const SizedBox(height: 12),
                        Text(
                          appInfo['name']!,
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: Colors.grey[800],
                          ),
                          textAlign: TextAlign.center,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                );
              },
            );
              },
            ),
            const SizedBox(height: 24),
            
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

  // Get list of actually installed UPI apps
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
      // Fallback: return hardcoded apps for testing
      print('Using fallback app list for testing...');
      return [
        {'packageName': 'com.google.android.apps.nbu.paisa.user', 'appName': 'Google Pay'},
        {'packageName': 'com.phonepe.app', 'appName': 'PhonePe'},
        {'packageName': 'net.one97.paytm', 'appName': 'Paytm'},
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
      
      // Try multiple URL formats for better compatibility
      List<String> urlsToTry = [];
      
      // Add app-specific URL first
      urlsToTry.add(_buildUpiUrl(upiString, amount, upiScheme));
      
      // Add standard UPI URL as fallback
      urlsToTry.add(_buildUpiUrl(upiString, amount, 'upi://pay'));
      
      // Add additional app-specific formats for known problematic apps
      if (appName == 'Google Pay') {
        urlsToTry.add(_buildUpiUrl(upiString, amount, 'tez://upi/pay'));
        urlsToTry.add(_buildUpiUrl(upiString, amount, 'googlepaytez://upi/pay'));
      } else if (appName == 'Paytm') {
        urlsToTry.add(_buildUpiUrl(upiString, amount, 'paytmmp://upi/pay'));
        urlsToTry.add(_buildUpiUrl(upiString, amount, 'paytm://upi/pay'));
      } else if (appName == 'PhonePe') {
        urlsToTry.add(_buildUpiUrl(upiString, amount, 'phonepe://upi/pay'));
      }
      
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
        // UPI launch failed, show error
        print('UPI launch failed, showing error dialog...');
        await _showUpiErrorDialog(context, 'Unable to open ${appName ?? 'UPI app'}. Please check if you have $appName installed and try again.');
      }
    } catch (e) {
      print('Error launching UPI app: $e');
      if (context.mounted) {
        await _showUpiErrorDialog(context, e.toString());
      }
    }
  }

  static String _buildUpiUrl(String upiString, double amount, String scheme) {
    try {
      print('Building UPI URL with scheme: $scheme');
      print('Original UPI string: $upiString');
      
      // Parse the UPI string to extract parameters
      final uri = Uri.parse(upiString);
      final params = uri.queryParameters;
      
      final payeeAddress = params['pa'] ?? '';
      final payeeName = params['pn'] ?? '';
      final transactionNote = params['tn'] ?? '';
      final currency = params['cu'] ?? 'INR';
      
      print('Extracted params: pa=$payeeAddress, pn=$payeeName, tn=$transactionNote');
      
      String finalUrl;
      
      // Handle different app schemes
      if (scheme.contains('tez://') || scheme.contains('googlepaytez://')) {
        // Google Pay specific format
        finalUrl = 'tez://upi/pay?pa=$payeeAddress&pn=${Uri.encodeComponent(payeeName)}&tn=${Uri.encodeComponent(transactionNote)}&am=$amount&cu=$currency';
      } else if (scheme.contains('paytmmp://')) {
        // Paytm specific format
        finalUrl = 'paytmmp://upi/pay?pa=$payeeAddress&pn=${Uri.encodeComponent(payeeName)}&tn=${Uri.encodeComponent(transactionNote)}&am=$amount&cu=$currency';
      } else if (scheme.contains('phonepe://')) {
        // PhonePe specific format
        finalUrl = 'phonepe://pay?pa=$payeeAddress&pn=${Uri.encodeComponent(payeeName)}&tn=${Uri.encodeComponent(transactionNote)}&am=$amount&cu=$currency';
      } else if (scheme.contains('flipkart://')) {
        // Flipkart UPI format
        finalUrl = 'flipkart://upi/pay?pa=$payeeAddress&pn=${Uri.encodeComponent(payeeName)}&tn=${Uri.encodeComponent(transactionNote)}&am=$amount&cu=$currency';
      } else if (scheme.contains('upi://pay')) {
        // Standard UPI format - add amount to existing URL
        if (upiString.contains('&am=') || upiString.contains('?am=')) {
          // Amount already exists, replace it
          finalUrl = upiString.replaceAllMapped(
            RegExp(r'[&?]am=[\d.]*'),
            (match) => '&am=$amount',
          );
        } else {
          // Add amount parameter
          final separator = upiString.contains('?') ? '&' : '?';
          finalUrl = '$upiString${separator}am=$amount&cu=$currency';
        }
      } else {
        // Generic app-specific schemes - try the app's base scheme with UPI parameters
        String baseScheme = scheme.split('://')[0];
        finalUrl = '$baseScheme://upi/pay?pa=$payeeAddress&pn=${Uri.encodeComponent(payeeName)}&tn=${Uri.encodeComponent(transactionNote)}&am=$amount&cu=$currency';
      }
      
      print('Final URL: $finalUrl');
      return finalUrl;
    } catch (e) {
      print('Error building UPI URL: $e');
      // Fallback to simple concatenation with standard UPI format
      final separator = upiString.contains('?') ? '&' : '?';
      return 'upi://pay?${upiString.split('?').length > 1 ? upiString.split('?')[1] : ''}${separator}am=$amount&cu=INR';
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

  static Future<void> _showUpiErrorDialog(BuildContext context, String error) async {
    if (!context.mounted) return;
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('UPI Payment Error'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Failed to open UPI app. Please try:'),
            const SizedBox(height: 8),
            const Text('• Installing a UPI app (Google Pay, PhonePe, Paytm)'),
            const Text('• Checking if UPI apps are enabled'),
            const Text('• Restarting the app'),
            const SizedBox(height: 12),
            Text(
              'Error: $error',
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey[600],
                fontStyle: FontStyle.italic,
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('OK'),
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

  static String generateUpiString(String upiId, String name, String note) {
    // Ensure UPI ID is in correct format
    String correctedUpiId = upiId;
    
    // If UPI ID doesn't contain @, it's likely just a phone number
    if (!upiId.contains('@')) {
      // Add a default UPI provider
      correctedUpiId = '$upiId@paytm'; // You can change this to @ybl, @oksbi, etc.
      print('Corrected UPI ID from $upiId to $correctedUpiId');
    }
    
    return "upi://pay?pa=$correctedUpiId&pn=${Uri.encodeComponent(name)}&tn=${Uri.encodeComponent(note)}&cu=INR";
  }
}
