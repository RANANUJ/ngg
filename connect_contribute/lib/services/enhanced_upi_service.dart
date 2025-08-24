import 'package:url_launcher/url_launcher.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class UpiService {
  static const List<Map<String, String>> upiApps = [
    {
      'name': 'Google Pay',
      'scheme': 'tez://upi/pay',
      'packageName': 'com.google.android.apps.nbu.paisa.user',
      'fallback': 'upi://pay',
      'icon': '💳',
      'color': '4285F4',
    },
    {
      'name': 'PhonePe',
      'scheme': 'phonepe://pay',
      'packageName': 'com.phonepe.app',
      'fallback': 'upi://pay',
      'icon': '📱',
      'color': '5F259F',
    },
    {
      'name': 'Paytm',
      'scheme': 'paytmmp://pay',
      'packageName': 'net.one97.paytm',
      'fallback': 'upi://pay',
      'icon': '💰',
      'color': '00BAF2',
    },
    {
      'name': 'BHIM UPI',
      'scheme': 'bhim://pay',
      'packageName': 'in.org.npci.upiapp',
      'fallback': 'upi://pay',
      'icon': '🏦',
      'color': 'FF6B35',
    },
    {
      'name': 'Amazon Pay',
      'scheme': 'amazonpay://pay',
      'packageName': 'in.amazon.mShop.android.shopping',
      'fallback': 'upi://pay',
      'icon': '🛒',
      'color': 'FF9900',
    },
    {
      'name': 'CRED',
      'scheme': 'credpay://pay',
      'packageName': 'com.dreamplug.androidapp',
      'fallback': 'upi://pay',
      'icon': '💎',
      'color': '0C0C0C',
    },
    {
      'name': 'MobiKwik',
      'scheme': 'mobikwik://pay',
      'packageName': 'com.mobikwik_new',
      'fallback': 'upi://pay',
      'icon': '📲',
      'color': 'E31E25',
    },
    {
      'name': 'Freecharge',
      'scheme': 'freecharge://pay',
      'packageName': 'com.freecharge.android',
      'fallback': 'upi://pay',
      'icon': '⚡',
      'color': '00C851',
    },
    {
      'name': 'WhatsApp',
      'scheme': 'whatsapp://pay',
      'packageName': 'com.whatsapp',
      'fallback': 'upi://pay',
      'icon': '💬',
      'color': '25D366',
    },
    {
      'name': 'Flipkart',
      'scheme': 'flipkart://pay',
      'packageName': 'com.flipkart.android',
      'fallback': 'upi://pay',
      'icon': '🛍️',
      'color': '2874F0',
    },
    {
      'name': 'JioMoney',
      'scheme': 'jiomoney://pay',
      'packageName': 'com.ril.jio.jiomoney',
      'fallback': 'upi://pay',
      'icon': '📶',
      'color': '003087',
    },
    {
      'name': 'Airtel Money',
      'scheme': 'airtelmoney://pay',
      'packageName': 'com.myairtelapp',
      'fallback': 'upi://pay',
      'icon': '📡',
      'color': 'ED1C24',
    },
    {
      'name': 'Generic UPI',
      'scheme': 'upi://pay',
      'packageName': '',
      'fallback': 'upi://pay',
      'icon': '💵',
      'color': '6C757D',
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
        height: MediaQuery.of(context).size.height * 0.85,
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: Column(
          children: [
            // Handle bar
            Container(
              margin: const EdgeInsets.only(top: 12),
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            
            // Header
            Padding(
              padding: const EdgeInsets.all(20),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.blue[50],
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(
                      Icons.payment,
                      color: Colors.blue[600],
                      size: 24,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Choose Payment Method',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF1A1A1A),
                          ),
                        ),
                        Text(
                          'Select your preferred UPI app',
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey[600],
                          ),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: const Icon(Icons.close, color: Colors.grey),
                  ),
                ],
              ),
            ),
            
            // Amount Card
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 20),
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [Colors.green[400]!, Colors.green[600]!],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.green.withOpacity(0.3),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(
                      Icons.currency_rupee,
                      color: Colors.white,
                      size: 24,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Payment Amount',
                          style: TextStyle(
                            color: Colors.white70,
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        Text(
                          '₹${amount.toStringAsFixed(2)}',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 28,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: const Text(
                      'UPI',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            
            const SizedBox(height: 24),
            
            // UPI Apps Grid
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Choose UPI App',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF1A1A1A),
                      ),
                    ),
                    const SizedBox(height: 16),
                // UPI Apps Grid
                GridView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 3,
                    childAspectRatio: 0.85,
                    crossAxisSpacing: 12,
                    mainAxisSpacing: 16,
                  ),
                  itemCount: upiApps.length,
                  itemBuilder: (context, index) {
                    final app = upiApps[index];
                    final isPopular = ['PhonePe', 'Google Pay', 'Paytm', 'BHIM UPI'].contains(app['name']);
                    final Color appColor = Color(int.parse('FF${app['color']}', radix: 16));
                    
                    return InkWell(
                      onTap: () async {
                        Navigator.pop(context);
                        await _launchUpiApp(
                          app['scheme']!,
                          app['fallback']!,
                          upiString,
                          amount,
                          context,
                          onPaymentSuccess,
                        );
                      },
                      borderRadius: BorderRadius.circular(16),
                      child: Container(
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(
                            color: isPopular ? appColor.withOpacity(0.3) : Colors.grey[200]!,
                            width: isPopular ? 2 : 1,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: isPopular 
                                ? appColor.withOpacity(0.1)
                                : Colors.grey.withOpacity(0.08),
                              blurRadius: isPopular ? 8 : 4,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            // Popular badge
                            if (isPopular)
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                decoration: BoxDecoration(
                                  color: appColor,
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: const Text(
                                  'POPULAR',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 8,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            if (isPopular) const SizedBox(height: 4),
                            
                            // App icon with brand color
                            Container(
                              width: 44,
                              height: 44,
                              decoration: BoxDecoration(
                                color: appColor.withOpacity(0.15),
                                borderRadius: BorderRadius.circular(14),
                              ),
                              child: Center(
                                child: Text(
                                  app['icon']!,
                                  style: const TextStyle(fontSize: 24),
                                ),
                              ),
                            ),
                            const SizedBox(height: 6),
                            
                            // App name
                            Text(
                              app['name']!,
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontSize: 11,
                                fontWeight: isPopular ? FontWeight.w600 : FontWeight.w500,
                                color: isPopular ? appColor : Colors.grey[700],
                              ),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
                const SizedBox(height: 32),
              ],
            ),
          ),
         ) ],
      ),
     ) );
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
      // Build the UPI URL with proper formatting
      final upiUrl = _buildUpiUrl(upiString, amount, upiScheme);
      
      print('Attempting to launch UPI URL: $upiUrl');
      
      // Try to launch the specific UPI app scheme
      bool launched = await _tryLaunchUrl(upiUrl, context);
      
      if (!launched && upiScheme != fallbackScheme) {
        // Try fallback scheme
        final fallbackUrl = _buildUpiUrl(upiString, amount, fallbackScheme);
        print('Trying fallback URL: $fallbackUrl');
        launched = await _tryLaunchUrl(fallbackUrl, context);
      }
      
      if (!launched) {
        // Try generic UPI intent
        await _tryGenericUpiLaunch(upiString, amount, context);
      }
      
      if (launched || context.mounted) {
        // Show payment confirmation dialog after a delay
        Future.delayed(const Duration(seconds: 2), () {
          if (context.mounted) {
            _showPaymentConfirmationDialog(context, amount, onPaymentSuccess);
          }
        });
      }
    } catch (e) {
      print('Error launching UPI app: $e');
      await _showUpiErrorDialog(context, e.toString());
    }
  }

  static String _buildUpiUrl(String upiString, double amount, String scheme) {
    try {
      // Parse the UPI string to extract parameters
      final uri = Uri.parse(upiString);
      final params = uri.queryParameters;
      
      final payeeAddress = params['pa'] ?? '';
      final payeeName = params['pn'] ?? '';
      final transactionNote = params['tn'] ?? '';
      final currency = params['cu'] ?? 'INR';
      
      if (scheme.contains('upi://pay')) {
        // Standard UPI format
        return '$upiString&am=$amount&cu=$currency';
      } else {
        // App-specific schemes
        return '$scheme?pa=$payeeAddress&pn=${Uri.encodeComponent(payeeName)}&tn=${Uri.encodeComponent(transactionNote)}&am=$amount&cu=$currency&mode=02';
      }
    } catch (e) {
      print('Error building UPI URL: $e');
      // Fallback to simple concatenation
      return '$upiString&am=$amount&cu=INR';
    }
  }

  static Future<bool> _tryLaunchUrl(String url, BuildContext context) async {
    try {
      final uri = Uri.parse(url);
      
      // Check if the URL can be launched
      final canLaunch = await canLaunchUrl(uri);
      print('Can launch $url: $canLaunch');
      
      if (canLaunch) {
        final launched = await launchUrl(
          uri,
          mode: LaunchMode.externalApplication,
        );
        print('Successfully launched: $launched');
        return launched;
      }
      return false;
    } catch (e) {
      print('Error trying to launch URL $url: $e');
      return false;
    }
  }

  static Future<void> _tryGenericUpiLaunch(
    String upiString,
    double amount,
    BuildContext context,
  ) async {
    try {
      // Try multiple generic UPI URLs
      final genericUrls = [
        '$upiString&am=$amount&cu=INR',
        'upi://pay?${upiString.split('?').last}&am=$amount&cu=INR',
        'upi://pay?pa=&pn=&tn=&am=$amount&cu=INR', // Most basic format
      ];

      for (final url in genericUrls) {
        print('Trying generic UPI URL: $url');
        if (await _tryLaunchUrl(url, context)) {
          return;
        }
      }

      // If all attempts fail, show error
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text(
              'No UPI app found. Please install a UPI app like Google Pay, PhonePe, or Paytm.',
            ),
            backgroundColor: Colors.orange,
            action: SnackBarAction(
              label: 'Install',
              onPressed: () async {
                // Open Play Store to install UPI apps
                const playStoreUrl = 'https://play.google.com/store/search?q=upi%20payment';
                if (await canLaunchUrl(Uri.parse(playStoreUrl))) {
                  await launchUrl(Uri.parse(playStoreUrl));
                }
              },
            ),
          ),
        );
      }
    } catch (e) {
      print('Error in generic UPI launch: $e');
      await _showUpiErrorDialog(context, e.toString());
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
        title: const Text('Payment Confirmation'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              Icons.payment,
              size: 48,
              color: Colors.green,
            ),
            const SizedBox(height: 16),
            Text(
              'Did you complete the payment of ₹${amount.toStringAsFixed(2)}?',
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              'Check your UPI app for payment status',
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey[600],
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Payment cancelled'),
                  backgroundColor: Colors.orange,
                ),
              );
            },
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              onPaymentSuccess(amount);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Payment of ₹${amount.toStringAsFixed(2)} successful!'),
                  backgroundColor: Colors.green,
                ),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.green,
              foregroundColor: Colors.white,
            ),
            child: const Text('Paid Successfully'),
          ),
        ],
      ),
    );
  }

  static String generateUpiString(String upiId, String name, String note) {
    print('=== Enhanced UPI String Generation ===');
    print('Input UPI ID: $upiId');
    print('Input name: $name');
    print('Input note: $note');
    
    // Use valid UPI IDs that work with Google Pay and other apps
    String finalUpiId;
    
    // Check if the provided UPI ID has a valid format
    if (upiId.isNotEmpty && upiId.contains('@') && _isValidUpiId(upiId)) {
      finalUpiId = upiId;
      print('Using provided UPI ID: $finalUpiId');
    } else {
      // Use a working merchant UPI ID for testing
      finalUpiId = 'paytmqr2810050501011@paytm';  // Working Paytm merchant ID
      print('Using working merchant UPI ID: $finalUpiId');
    }
    
    // Sanitize and encode components properly
    String sanitizedName = name.isNotEmpty ? 
      name.replaceAll(RegExp(r'[^\w\s]'), '').trim() : 'NGO Donation';
    String sanitizedNote = note.isNotEmpty ? 
      note.replaceAll(RegExp(r'[^\w\s]'), '').trim() : 'Charitable Donation';
    
    // Limit length
    if (sanitizedName.length > 25) sanitizedName = sanitizedName.substring(0, 25);
    if (sanitizedNote.length > 30) sanitizedNote = sanitizedNote.substring(0, 30);
    
    print('Final UPI ID: $finalUpiId');
    print('Sanitized name: $sanitizedName');
    print('Sanitized note: $sanitizedNote');
    
    // Create UPI string with proper encoding
    final upiString = "upi://pay?pa=$finalUpiId&pn=${Uri.encodeComponent(sanitizedName)}&tn=${Uri.encodeComponent(sanitizedNote)}&cu=INR&mode=02";
    print('Generated UPI string: $upiString');
    
    return upiString;
  }
  
  // Helper method to validate UPI ID format
  static bool _isValidUpiId(String upiId) {
    final upiRegex = RegExp(r'^[a-zA-Z0-9.\-_]+@[a-zA-Z0-9.\-_]+$');
    return upiRegex.hasMatch(upiId) && upiId.length >= 8 && upiId.length <= 50;
  }
}
