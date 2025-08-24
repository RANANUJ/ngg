import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../services/custom_upi_service.dart';
import '../services/secure_upi_service.dart';
import 'add_upi_screen.dart';

class UpiPaymentScreen extends StatefulWidget {
  final String campaignId;
  final String campaignTitle;
  final String upiId;
  final double amount;
  final String donorName;
  final String donorEmail;
  final String donorPhone;
  final String message;
  final bool isAnonymous;
  final VoidCallback onSuccess;

  const UpiPaymentScreen({
    super.key,
    required this.campaignId,
    required this.campaignTitle,
    required this.upiId,
    required this.amount,
    required this.donorName,
    required this.donorEmail,
    required this.donorPhone,
    required this.message,
    required this.isAnonymous,
    required this.onSuccess,
  });

  @override
  State<UpiPaymentScreen> createState() => _UpiPaymentScreenState();
}

class _UpiPaymentScreenState extends State<UpiPaymentScreen> {
  String selectedPaymentMethod = 'sbi'; // Default to SBI AutoPay
  bool _isProcessing = false;
  List<Map<String, dynamic>> customUpiIds = [];

  @override
  void initState() {
    super.initState();
    _loadCustomUpiIds();
  }

  Future<void> _loadCustomUpiIds() async {
    try {
      final upiIds = await CustomUpiService.getCustomUpiIds();
      setState(() {
        customUpiIds = upiIds;
      });
    } catch (e) {
      // Handle error silently
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'Choose payment method',
          style: GoogleFonts.poppins(
            color: Colors.black,
            fontSize: 18,
            fontWeight: FontWeight.w400,
          ),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // AutoPay Section
              Text(
                'AutoPay',
                style: GoogleFonts.poppins(
                  color: Colors.black,
                  fontSize: 24,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 20),
              
              _buildPaymentOption(
                'sbi',
                'assets/images/logo.png',
                'STATE BANK OF INDIA ••••0763',
                'Auto-debit in 2 working days. NAV applicable accordingly.',
                hasPayButton: true,
              ),
              
              const SizedBox(height: 40),
              
              // UPI Section
              Row(
                children: [
                  Container(
                    width: 30,
                    height: 20,
                    decoration: BoxDecoration(
                      color: const Color(0xFF00D4AA),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: const Center(
                      child: Text(
                        'UPI',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'Pay using any UPI app',
                    style: GoogleFonts.poppins(
                      color: Colors.black,
                      fontSize: 18,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              
              _buildPaymentOption(
                'gpay',
                'assets/images/googlepay.png',
                'GPay',
                null,
                hasPayButton: true,
              ),
              
              const SizedBox(height: 16),
              
              _buildPaymentOption(
                'phonepe',
                'assets/images/phonepe.png',
                'PhonePe',
                null,
                hasPayButton: true,
              ),
              
              const SizedBox(height: 16),
              
              _buildPaymentOption(
                'other_upi',
                'assets/images/logo.png',
                'Other UPI Apps',
                null,
                hasPayButton: true,
              ),
              
              const SizedBox(height: 16),
              
              // Custom UPI IDs
              ...customUpiIds.map((upiData) => Column(
                children: [
                  _buildPaymentOption(
                    'custom_${upiData['upiId']}',
                    CustomUpiService.getUpiAppIcon(upiData['upiId']),
                    upiData['displayName'],
                    upiData['upiId'],
                    hasPayButton: true,
                    isCustomUpi: true,
                  ),
                  const SizedBox(height: 16),
                ],
              )),
              
              _buildPaymentOption(
                'add_upi',
                'assets/images/logo.png',
                'Add new UPI ID',
                null,
                hasPayButton: true,
              ),
              
              const SizedBox(height: 40),
              
              // Netbanking Section
              Text(
                'Netbanking',
                style: GoogleFonts.poppins(
                  color: Colors.black,
                  fontSize: 18,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 20),
              
              _buildPaymentOption(
                'netbanking',
                'assets/images/logo.png',
                'State Bank Of India ••••0763',
                null,
                hasPayButton: true,
              ),
              
              const SizedBox(height: 40), // Extra space at bottom
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPaymentOption(
    String value,
    String iconPath,
    String title,
    String? subtitle, {
    bool hasPayButton = false,
    bool isCustomUpi = false,
  }) {
    final isSelected = selectedPaymentMethod == value;
    
    return GestureDetector(
      onTap: () async {
        if (value == 'add_upi') {
          // Navigate to add UPI screen
          final result = await Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const AddUpiScreen(),
            ),
          );
          
          if (result != null) {
            // Reload custom UPI IDs
            await _loadCustomUpiIds();
            // Select the newly added UPI ID
            setState(() {
              selectedPaymentMethod = 'custom_${result['upiId']}';
            });
          }
        } else {
          setState(() {
            selectedPaymentMethod = value;
          });
        }
        
        // Don't auto-trigger payment, let user click the PAY button
      },
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.grey[50],
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected ? const Color(0xFF00D4AA) : Colors.grey[300]!,
            width: 1,
          ),
        ),
        child: Column(
          children: [
            Row(
              children: [
                // Icon with error handling
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: _getIconBackgroundColor(value),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(20),
                    child: _buildIcon(value, iconPath),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: GoogleFonts.poppins(
                          color: Colors.black,
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      if (subtitle != null)
                        Text(
                          subtitle,
                          style: GoogleFonts.poppins(
                            color: Colors.grey[600],
                            fontSize: 12,
                          ),
                        ),
                    ],
                  ),
                ),
                Radio<String>(
                  value: value,
                  groupValue: selectedPaymentMethod,
                  onChanged: (String? newValue) {
                    setState(() {
                      selectedPaymentMethod = newValue!;
                    });
                  },
                  activeColor: const Color(0xFF00D4AA),
                ),
              ],
            ),
            
            if (hasPayButton && isSelected) ...[
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _isProcessing ? null : () => _handlePayment(value),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF00D4AA),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    padding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                  child: _isProcessing
                      ? const CircularProgressIndicator(
                          color: Colors.white,
                          strokeWidth: 2,
                        )
                      : Text(
                          'PAY ₹${widget.amount.toStringAsFixed(0)}',
                          style: GoogleFonts.poppins(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildIcon(String value, String iconPath) {
    // For custom UPI IDs, try to use the determined icon
    if (value.startsWith('custom_')) {
      final customUpiId = value.substring(7);
      final customIconPath = CustomUpiService.getUpiAppIcon(customUpiId);
      
      return Image.asset(
        customIconPath,
        width: 30,
        height: 30,
        fit: BoxFit.contain,
        errorBuilder: (context, error, stackTrace) {
          return Icon(
            Icons.account_balance_wallet,
            color: Colors.white,
            size: 20,
          );
        },
      );
    }
    
    // For GPay, try to use the googlepay.png image
    if (value == 'gpay') {
      return Image.asset(
        'assets/images/googlepay.png',
        width: 30,
        height: 30,
        fit: BoxFit.contain,
        errorBuilder: (context, error, stackTrace) {
          return Icon(
            Icons.payment,
            color: Colors.white,
            size: 20,
          );
        },
      );
    }
    
    // For PhonePe, try to use the phonepe.png image
    if (value == 'phonepe') {
      return Image.asset(
        'assets/images/phonepe.png',
        width: 30,
        height: 30,
        fit: BoxFit.contain,
        errorBuilder: (context, error, stackTrace) {
          return Icon(
            Icons.payment,
            color: Colors.white,
            size: 20,
          );
        },
      );
    }
    
    // For other payment methods, use icons with appropriate colors
    return Icon(
      _getIconData(value),
      color: _getIconColor(value),
      size: 20,
    );
  }

  Color _getIconBackgroundColor(String value) {
    // For custom UPI IDs, determine color based on the UPI domain
    if (value.startsWith('custom_')) {
      final customUpiId = value.substring(7);
      final domain = customUpiId.split('@').last.toLowerCase();
      
      switch (domain) {
        case 'amazonpay':
        case 'apl':
          return const Color(0xFFFF9900); // Amazon Orange
        case 'paytm':
        case 'ptm':
          return const Color(0xFF00BAF2); // Paytm Blue
        case 'ybl':
        case 'yahoobiz':
          return const Color(0xFF5F259F); // PhonePe Purple
        case 'okaxis':
        case 'axis':
          return const Color(0xFF4285F4); // Google Blue
        default:
          return const Color(0xFF00D4AA); // App theme color as fallback
      }
    }
    
    switch (value) {
      case 'sbi':
      case 'netbanking':
        return const Color(0xFF1F4E87); // SBI Blue
      case 'gpay':
        return const Color(0xFF4285F4); // Google Blue
      case 'phonepe':
        return const Color(0xFF5F259F); // PhonePe Purple
      case 'other_upi':
        return const Color(0xFFFF6B35); // Orange
      case 'add_upi':
        return const Color(0xFF00D4AA); // App theme color
      default:
        return Colors.grey[200]!;
    }
  }

  Color _getIconColor(String value) {
    // For custom UPI IDs, use white color
    if (value.startsWith('custom_')) {
      return Colors.white;
    }
    
    switch (value) {
      case 'sbi':
      case 'netbanking':
      case 'gpay':
      case 'phonepe':
      case 'add_upi':
        return Colors.white;
      default:
        return Colors.grey[600]!;
    }
  }

  IconData _getIconData(String value) {
    switch (value) {
      case 'sbi':
      case 'netbanking':
        return Icons.account_balance;
      case 'gpay':
        return Icons.g_mobiledata_rounded;
      case 'phonepe':
        return Icons.phone_android;
      case 'other_upi':
        return Icons.more_horiz;
      case 'add_upi':
        return Icons.add_circle_outline;
      default:
        return Icons.payment;
    }
  }

  void _handlePayment(String paymentMethod) async {
    setState(() {
      _isProcessing = true;
    });

    try {
      String targetUpiId = widget.upiId;
      
      // Check if it's a custom UPI ID
      if (paymentMethod.startsWith('custom_')) {
        final customUpiId = paymentMethod.substring(7); // Remove 'custom_' prefix
        targetUpiId = customUpiId;
      }

      // Use simplified secure payment service
      final result = await SecureUpiService.makeSimpleSecurePayment(
        context: context,
        campaignId: widget.campaignId,
        campaignTitle: widget.campaignTitle,
        amount: widget.amount,
        merchantUpiId: targetUpiId,
        note: 'Donation to ${widget.campaignTitle}',
        onSuccess: widget.onSuccess,
      );

      if (mounted) {
        // Handle the final result
        await _handlePaymentResult(result);
      }

    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error processing payment: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isProcessing = false;
        });
      }
    }
  }

  Future<void> _handlePaymentResult(UpiPaymentResult result) async {
    switch (result.status) {
      case UpiPaymentStatus.success:
        // Payment successful - show success message and navigate back
        widget.onSuccess();
        Navigator.of(context).popUntil((route) => route.isFirst);
        
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Payment completed successfully!'),
                if (result.transactionId != null)
                  Text(
                    'Transaction ID: ${result.transactionId}',
                    style: const TextStyle(fontSize: 12),
                  ),
              ],
            ),
            backgroundColor: Colors.green,
            duration: const Duration(seconds: 4),
          ),
        );
        break;

      case UpiPaymentStatus.failure:
        // Payment failed - show error message
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(result.message ?? 'Payment failed. Please try again.'),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 3),
          ),
        );
        break;

      case UpiPaymentStatus.cancelled:
        // Payment cancelled - show cancelled message
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Payment was cancelled.'),
            backgroundColor: Colors.orange,
            duration: Duration(seconds: 2),
          ),
        );
        break;

      case UpiPaymentStatus.timeout:
        // Payment timeout - show timeout message
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Payment timeout. Please try again.'),
            backgroundColor: Colors.orange,
            duration: Duration(seconds: 3),
          ),
        );
        break;

      case UpiPaymentStatus.initiated:
        // Payment initiated but status unknown - ask user to check
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Payment initiated. Please check your UPI app.'),
            backgroundColor: Colors.blue,
            duration: Duration(seconds: 3),
          ),
        );
        break;
    }
  }
}
