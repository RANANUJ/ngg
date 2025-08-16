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
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => Container(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Choose UPI App',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.grey[800],
                  ),
                ),
                IconButton(
                  onPressed: () => Navigator.pop(context),
                  icon: const Icon(Icons.close),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              'Amount: ₹${amount.toStringAsFixed(2)}',
              style: TextStyle(
                fontSize: 16,
                color: Colors.green[600],
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 20),
            GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 3,
                childAspectRatio: 0.8,
                crossAxisSpacing: 16,
                mainAxisSpacing: 16,
              ),
              itemCount: upiApps.length,
              itemBuilder: (context, index) {
                final app = upiApps[index];
                return GestureDetector(
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
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.grey[300]!),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.grey.withOpacity(0.1),
                          spreadRadius: 1,
                          blurRadius: 4,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          app['icon']!,
                          style: const TextStyle(fontSize: 32),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          app['name']!,
                          style: const TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
            const SizedBox(height: 16),
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
          ],
        ),
      ),
    );
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
    return "upi://pay?pa=$upiId&pn=${Uri.encodeComponent(name)}&tn=${Uri.encodeComponent(note)}&cu=INR";
  }
}
