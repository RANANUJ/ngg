import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:url_launcher/url_launcher.dart';
import '../services/api_service.dart';
import '../screens/payment_status_screen.dart';

enum UpiPaymentStatus {
  initiated,
  success,
  failure,
  cancelled,
  timeout,
}

class UpiPaymentResult {
  final UpiPaymentStatus status;
  final String? transactionId;
  final String? responseCode;
  final String? message;
  final String? transactionRefId;

  UpiPaymentResult({
    required this.status,
    this.transactionId,
    this.responseCode,
    this.message,
    this.transactionRefId,
  });

  factory UpiPaymentResult.fromMap(Map<String, dynamic> map) {
    UpiPaymentStatus status;
    switch (map['status']?.toString().toLowerCase()) {
      case 'success':
        status = UpiPaymentStatus.success;
        break;
      case 'failure':
      case 'failed':
        status = UpiPaymentStatus.failure;
        break;
      case 'cancelled':
        status = UpiPaymentStatus.cancelled;
        break;
      case 'timeout':
        status = UpiPaymentStatus.timeout;
        break;
      default:
        status = UpiPaymentStatus.initiated;
    }

    return UpiPaymentResult(
      status: status,
      transactionId: map['transactionId'],
      responseCode: map['responseCode'],
      message: map['message'],
      transactionRefId: map['transactionRefId'],
    );
  }
}

class SecureUpiService {
  static const MethodChannel _channel = MethodChannel('secure_upi_payment');
  
  // Initialize the UPI payment channel
  static Future<void> initialize() async {
    try {
      await _channel.invokeMethod('initialize');
    } catch (e) {
      print('Failed to initialize UPI service: $e');
    }
  }

  // Generate UPI payment string
  static String generateUpiString(
    String upiId,
    String payeeName,
    String transactionNote,
    double amount, {
    String? transactionRefId,
  }) {
    final refId = transactionRefId ?? DateTime.now().millisecondsSinceEpoch.toString();
    
    return 'upi://pay?'
        'pa=$upiId&'
        'pn=${Uri.encodeComponent(payeeName)}&'
        'tr=$refId&'
        'tn=${Uri.encodeComponent(transactionNote)}&'
        'am=${amount.toStringAsFixed(2)}&'
        'cu=INR';
  }

  // Launch UPI payment with result handling
  static Future<UpiPaymentResult> makeSecurePayment({
    required String upiId,
    required String payeeName,
    required String transactionNote,
    required double amount,
    required String campaignId,
    required String donorName,
    required String donorEmail,
    required String donorPhone,
    required bool isAnonymous,
    String? packageName,
  }) async {
    try {
      final transactionRefId = DateTime.now().millisecondsSinceEpoch.toString();
      
      final upiString = generateUpiString(
        upiId,
        payeeName,
        transactionNote,
        amount,
        transactionRefId: transactionRefId,
      );

      // Launch UPI app and wait for result
      final result = await _launchUpiAndWaitForResult(
        upiString: upiString,
        packageName: packageName,
        transactionRefId: transactionRefId,
      );

      // If payment was successful, update the campaign
      if (result.status == UpiPaymentStatus.success) {
        try {
          await _updateCampaignAfterPayment(
            campaignId: campaignId,
            amount: amount,
            transactionId: result.transactionId ?? transactionRefId,
            donorName: isAnonymous ? 'Anonymous' : donorName,
            donorEmail: donorEmail,
            donorPhone: donorPhone,
            paymentMethod: 'UPI',
            upiId: upiId,
          );
        } catch (e) {
          print('Failed to update campaign after payment: $e');
          // Payment was successful but campaign update failed
          // This should be handled by showing a warning message
        }
      }

      return result;
    } catch (e) {
      print('UPI payment error: $e');
      return UpiPaymentResult(
        status: UpiPaymentStatus.failure,
        message: 'Payment failed: $e',
      );
    }
  }

  // Launch UPI app and wait for result using URL launcher with custom scheme
  static Future<UpiPaymentResult> _launchUpiAndWaitForResult({
    required String upiString,
    String? packageName,
    required String transactionRefId,
  }) async {
    try {
      // Create a Completer to wait for the payment result
      final uri = Uri.parse(upiString);
      
      // Launch the UPI app
      if (packageName != null && packageName.isNotEmpty) {
        // Try to launch specific app
        final specificAppUri = Uri.parse(upiString);
        if (await canLaunchUrl(specificAppUri)) {
          await launchUrl(
            specificAppUri,
            mode: LaunchMode.externalApplication,
          );
        } else {
          // Fallback to system chooser
          await launchUrl(
            uri,
            mode: LaunchMode.externalApplication,
          );
        }
      } else {
        // Launch with system chooser
        await launchUrl(
          uri,
          mode: LaunchMode.externalApplication,
        );
      }

      // Wait for the result (this is a simplified version)
      // In a real implementation, you would use app lifecycle callbacks
      // or deep links to detect when the user returns from the UPI app
      
      // For now, we'll use a timer-based approach with user confirmation
      return await _waitForPaymentResult(transactionRefId);
      
    } catch (e) {
      return UpiPaymentResult(
        status: UpiPaymentStatus.failure,
        message: 'Failed to launch UPI app: $e',
      );
    }
  }

  // Wait for payment result with timeout
  static Future<UpiPaymentResult> _waitForPaymentResult(String transactionRefId) async {
    // This is a simplified implementation
    // In production, you should implement proper app state monitoring
    
    // Wait for 30 seconds, then assume timeout
    await Future.delayed(const Duration(seconds: 2));
    
    // Return a result that requires user confirmation
    // In a real app, you would implement deep links or use the UPI SDK
    return UpiPaymentResult(
      status: UpiPaymentStatus.initiated,
      transactionRefId: transactionRefId,
      message: 'Payment initiated. Please complete in UPI app.',
    );
  }

  // Update campaign after successful payment
  static Future<void> _updateCampaignAfterPayment({
    required String campaignId,
    required double amount,
    required String transactionId,
    required String donorName,
    required String donorEmail,
    required String donorPhone,
    required String paymentMethod,
    required String upiId,
  }) async {
    try {
      final apiService = ApiService.instance;
      
      // Create donation record
      final donationData = {
        'amount': amount,
        'donor_name': donorName,
        'donor_email': donorEmail,
        'donor_phone': donorPhone,
        'payment_method': paymentMethod,
        'transaction_id': transactionId,
        'upi_id': upiId,
        'payment_status': 'completed',
        'donated_at': DateTime.now().toIso8601String(),
        'message': 'UPI Payment via $paymentMethod',
      };

      // Send to backend using the existing createDonation method
      await apiService.createDonation(
        campaignId: campaignId,
        donationData: donationData,
      );
      
      print('Campaign updated successfully after payment');
    } catch (e) {
      print('Failed to update campaign: $e');
      throw e;
    }
  }

  // Show payment status screen instead of simple dialog
  static Future<UpiPaymentResult> showPaymentStatusScreen(
    BuildContext context,
    String transactionRefId,
    String campaignTitle,
    double amount,
    String upiId,
    VoidCallback onSuccess,
  ) async {
    final result = await Navigator.push<UpiPaymentResult>(
      context,
      MaterialPageRoute(
        builder: (context) => PaymentStatusScreen(
          campaignTitle: campaignTitle,
          amount: amount,
          transactionRefId: transactionRefId,
          upiId: upiId,
          onSuccess: onSuccess,
        ),
      ),
    );

    return result ?? UpiPaymentResult(
      status: UpiPaymentStatus.cancelled,
      transactionRefId: transactionRefId,
      message: 'Payment cancelled by user',
    );
  }

  // Simplified method for UpiPaymentScreen integration
  static Future<UpiPaymentResult> makeSimpleSecurePayment({
    required BuildContext context,
    required String campaignId,
    required String campaignTitle,
    required double amount,
    required String merchantUpiId,
    String? note,
    VoidCallback? onSuccess,
  }) async {
    // Generate a unique transaction reference ID
    final transactionRefId = 'TXN${DateTime.now().millisecondsSinceEpoch}';
    
    // Import the UpiService from the existing file
    try {
      // First, launch the UPI app using existing UpiService
      final upiString = 'upi://pay?'
          'pa=$merchantUpiId&'
          'pn=${Uri.encodeComponent('Connect & Contribute')}&'
          'tr=$transactionRefId&'
          'tn=${Uri.encodeComponent(note ?? 'Donation for $campaignTitle')}&'
          'am=${amount.toStringAsFixed(2)}&'
          'cu=INR';

      final uri = Uri.parse(upiString);
      final launched = await launchUrl(
        uri,
        mode: LaunchMode.externalApplication,
      );

      if (!launched) {
        return UpiPaymentResult(
          status: UpiPaymentStatus.failure,
          transactionRefId: transactionRefId,
          message: 'Failed to launch UPI app',
        );
      }

      // Show payment status screen for user confirmation
      final result = await showPaymentStatusScreen(
        context,
        transactionRefId,
        campaignTitle,
        amount,
        merchantUpiId,
        onSuccess ?? () {},
      );

      // If payment was successful, update the campaign
      if (result.status == UpiPaymentStatus.success) {
        final updateSuccess = await _updateSimpleCampaign(
          campaignId,
          amount,
          result.transactionRefId ?? transactionRefId,
        );

        if (!updateSuccess) {
          // Show warning but don't change the result status
          print('Warning: Failed to update campaign on server');
        }

        // Call the success callback if provided
        if (onSuccess != null) {
          onSuccess();
        }
      }

      return result;
    } catch (e) {
      return UpiPaymentResult(
        status: UpiPaymentStatus.failure,
        transactionRefId: transactionRefId,
        message: 'Payment failed: $e',
      );
    }
  }

  // Simple campaign update method
  static Future<bool> _updateSimpleCampaign(
    String campaignId,
    double amount,
    String transactionId,
  ) async {
    try {
      final apiService = ApiService.instance;
      
      final donationData = {
        'amount': amount,
        'donor_name': 'Anonymous',
        'donor_email': '',
        'donor_phone': '',
        'payment_method': 'UPI',
        'transaction_id': transactionId,
        'payment_status': 'completed',
        'donated_at': DateTime.now().toIso8601String(),
        'message': 'UPI Payment',
      };

      await apiService.createDonation(
        campaignId: campaignId,
        donationData: donationData,
      );
      
      return true;
    } catch (e) {
      print('Failed to update campaign: $e');
      return false;
    }
  }

  // Get UPI app package name
  static String getPackageNameForDomain(String upiId) {
    final domain = upiId.split('@').last.toLowerCase();
    
    switch (domain) {
      case 'ybl':
      case 'yahoobiz':
        return 'com.phonepe.app';
      case 'okaxis':
      case 'axis':
        return 'com.google.android.apps.nbu.paisa.user';
      case 'paytm':
      case 'ptm':
        return 'net.one97.paytm';
      case 'amazonpay':
      case 'apl':
        return 'in.amazon.mShop.android.shopping';
      case 'sbi':
        return 'com.sbi.upi';
      default:
        return '';
    }
  }

  // Get payment method name from package
  static String getPaymentMethodName(String? packageName) {
    switch (packageName) {
      case 'com.phonepe.app':
        return 'PhonePe';
      case 'com.google.android.apps.nbu.paisa.user':
        return 'Google Pay';
      case 'net.one97.paytm':
        return 'Paytm';
      case 'in.amazon.mShop.android.shopping':
        return 'Amazon Pay';
      case 'com.sbi.upi':
        return 'SBI Pay';
      default:
        return 'UPI';
    }
  }
}
