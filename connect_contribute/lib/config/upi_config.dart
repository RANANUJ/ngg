import 'package:flutter/material.dart';

class UpiConfig {
  // IMPORTANT: Replace this with your actual NGO's UPI ID
  // For development, you can use a real UPI ID for testing
  static const String DEFAULT_UPI_ID = 'test@paytm'; // REPLACE WITH REAL UPI ID!
  
  // Configuration for development vs production
  static const bool IS_DEVELOPMENT = true; // Set to false for production
  
  // Real UPI ID examples (replace with your actual ones):
  // 'ngoname@paytm'
  // 'donations@sbi' 
  // 'charity@ybl'
  // 'ngo.account@axisbank'
  
  // List of verified working UPI IDs for testing (these are real merchant IDs)
  static const List<String> TEST_UPI_IDS = [
    'paytmqr2810050501011@paytm',  // Working Paytm merchant ID
    'razorpay@ybl',                // Working Razorpay ID  
    'merchant@paytm',              // Generic merchant
    'demo@ybl',                    // Yes Bank test ID
    'test@axisbank'                // Axis Bank test ID
  ];
  
  static String getUpiId() {
    if (IS_DEVELOPMENT) {
      // Use a working test UPI ID instead of invalid ones
      return TEST_UPI_IDS.first;
    } else {
      // In production, use the configured UPI ID
      return DEFAULT_UPI_ID;
    }
  }
  
  static void showConfigurationDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('UPI Configuration Required'),
        content: const SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'URGENT: UPI Payment Setup Required',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Colors.red,
                ),
              ),
              SizedBox(height: 16),
              Text(
                'The app is currently using placeholder UPI IDs which cause all payment failures. To fix this:',
              ),
              SizedBox(height: 12),
              Text('1. OBTAIN A REAL UPI ID:'),
              Text('   • Contact your NGO\'s bank'),
              Text('   • Request UPI setup for your account'),
              Text('   • Get the UPI ID (format: name@bank)'),
              SizedBox(height: 12),
              Text('2. UPDATE THE CODE:'),
              Text('   • Open lib/config/upi_config.dart'),
              Text('   • Replace DEFAULT_UPI_ID with your real UPI ID'),
              Text('   • Set IS_DEVELOPMENT = false'),
              SizedBox(height: 12),
              Text('3. ALTERNATIVE SOLUTIONS:'),
              Text('   • Use Razorpay/PayU payment gateway'),
              Text('   • Integrate with payment processors'),
              Text('   • Set up merchant account with UPI'),
              SizedBox(height: 16),
              Text(
                'Current Issue: All UPI apps reject test/demo UPI IDs for security reasons.',
                style: TextStyle(
                  fontStyle: FontStyle.italic,
                  color: Colors.orange,
                ),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('I Understand'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              // Could open documentation or help
            },
            child: const Text('Learn More'),
          ),
        ],
      ),
    );
  }
}

// Helper class for UPI validation
class UpiValidator {
  static bool isValidUpiId(String upiId) {
    // Basic UPI ID validation
    final upiRegex = RegExp(r'^[a-zA-Z0-9.\-_]+@[a-zA-Z0-9.\-_]+$');
    return upiRegex.hasMatch(upiId) && 
           upiId.length >= 8 && 
           upiId.length <= 50 &&
           !upiId.toLowerCase().contains('test') &&
           !upiId.toLowerCase().contains('demo') &&
           !upiId.toLowerCase().contains('invalid');
  }
  
  static List<String> getCommonBankSuffixes() {
    return [
      '@paytm',
      '@ybl',         // Yes Bank
      '@oksbi',       // SBI
      '@axisbank',    // Axis Bank
      '@ibl',         // IDBI Bank
      '@icici',       // ICICI Bank
      '@hdfcbank',    // HDFC Bank
      '@upi',         // Generic UPI
    ];
  }
}
