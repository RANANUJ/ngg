import 'package:flutter/material.dart';
import '../models/donation_model.dart';
import '../services/api_service.dart';
import 'upi_service.dart';

class DonationService {
  static const List<double> quickAmounts = [100, 250, 500, 1000, 2500, 5000];
  
  static Future<void> showDonationDialog({
    required BuildContext context,
    required String campaignId,
    required String campaignTitle,
    required String upiId,
    required double targetAmount,
    required double currentRaised,
    required VoidCallback onSuccess,
  }) async {
    await showDialog(
      context: context,
      barrierDismissible: true,
      builder: (context) => EnhancedDonationDialog(
        campaignId: campaignId,
        campaignTitle: campaignTitle,
        upiId: upiId,
        targetAmount: targetAmount,
        currentRaised: currentRaised,
        onSuccess: onSuccess,
      ),
    );
  }

  static Future<Donation?> processDonation({
    required String campaignId,
    required DonationRequest donationRequest,
  }) async {
    try {
      final response = await ApiService.instance.createDonation(
        campaignId: campaignId,
        donationData: donationRequest.toJson(),
      );
      
      return Donation.fromJson(response);
    } catch (e) {
      print('Error processing donation: $e');
      return null;
    }
  }

  static Future<List<Donation>> getCampaignDonations(String campaignId) async {
    try {
      final response = await ApiService.instance.getCampaignDonations(campaignId);
      return response.map((json) => Donation.fromJson(json)).toList();
    } catch (e) {
      print('Error fetching donations: $e');
      return [];
    }
  }
}

class EnhancedDonationDialog extends StatefulWidget {
  final String campaignId;
  final String campaignTitle;
  final String upiId;
  final double targetAmount;
  final double currentRaised;
  final VoidCallback onSuccess;

  const EnhancedDonationDialog({
    super.key,
    required this.campaignId,
    required this.campaignTitle,
    required this.upiId,
    required this.targetAmount,
    required this.currentRaised,
    required this.onSuccess,
  });

  @override
  State<EnhancedDonationDialog> createState() => _EnhancedDonationDialogState();
}

class _EnhancedDonationDialogState extends State<EnhancedDonationDialog>
    with SingleTickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  final _amountController = TextEditingController();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _messageController = TextEditingController();
  
  PaymentMethod _selectedPaymentMethod = PaymentMethod.upi;
  bool _isAnonymous = false;
  bool _isProcessing = false;
  late TabController _tabController;
  
  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _amountController.dispose();
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _messageController.dispose();
    _tabController.dispose();
    super.dispose();
  }

  double get remainingAmount => widget.targetAmount - widget.currentRaised;

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      child: Container(
        width: MediaQuery.of(context).size.width * 0.95,
        height: MediaQuery.of(context).size.height * 0.85,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(24),
        ),
        child: Column(
          children: [
            _buildHeader(),
            _buildProgressIndicator(),
            Expanded(
              child: TabBarView(
                controller: _tabController,
                children: [
                  _buildAmountSelectionTab(),
                  _buildDonorDetailsTab(),
                ],
              ),
            ),
            _buildBottomActions(),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            const Color(0xFF667eea),
            const Color(0xFF764ba2),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(Icons.favorite, color: Colors.white, size: 24),
              ),
              Container(
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: IconButton(
                  onPressed: () => Navigator.pop(context),
                  icon: const Icon(Icons.close, color: Colors.white),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            'Support This Campaign',
            style: const TextStyle(
              color: Colors.white,
              fontSize: 24,
              fontWeight: FontWeight.bold,
              letterSpacing: 0.5,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            widget.campaignTitle,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 16,
              fontWeight: FontWeight.w500,
            ),
            textAlign: TextAlign.center,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }

  Widget _buildProgressIndicator() {
    final progress = widget.currentRaised / widget.targetAmount;
    return Container(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          TabBar(
            controller: _tabController,
            labelColor: const Color(0xFF6A11CB),
            unselectedLabelColor: Colors.grey,
            indicatorColor: const Color(0xFF6A11CB),
            tabs: const [
              Tab(icon: Icon(Icons.payment), text: 'Amount'),
              Tab(icon: Icon(Icons.person), text: 'Details'),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '₹${widget.currentRaised.toStringAsFixed(0)}',
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF6A11CB),
                ),
              ),
              Text(
                '₹${widget.targetAmount.toStringAsFixed(0)}',
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: Colors.grey,
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          LinearProgressIndicator(
            value: progress,
            backgroundColor: Colors.grey[200],
            valueColor: const AlwaysStoppedAnimation(Color(0xFF6A11CB)),
            minHeight: 6,
            borderRadius: BorderRadius.circular(3),
          ),
          const SizedBox(height: 8),
          Text(
            '${(progress * 100).toStringAsFixed(1)}% funded • ₹${remainingAmount.toStringAsFixed(0)} to go',
            style: const TextStyle(
              fontSize: 12,
              color: Colors.grey,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAmountSelectionTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Choose Amount',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Every contribution makes a difference',
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[600],
            ),
          ),
          const SizedBox(height: 24),
          
          // Quick amount buttons with enhanced design
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 3,
              childAspectRatio: 2.2,
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
            ),
            itemCount: DonationService.quickAmounts.length,
            itemBuilder: (context, index) {
              final amount = DonationService.quickAmounts[index];
              return _buildQuickAmountButton(amount);
            },
          ),
          
          const SizedBox(height: 32),
          
          const Text(
            'Or enter custom amount',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 16),
          
          // Enhanced custom amount input
          Container(
            decoration: BoxDecoration(
              color: Colors.grey[50],
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: Colors.grey[200]!),
            ),
            child: TextFormField(
              controller: _amountController,
              keyboardType: TextInputType.number,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
              ),
              decoration: InputDecoration(
                labelText: 'Enter Amount',
                hintText: '₹0',
                prefixIcon: Container(
                  margin: const EdgeInsets.all(12),
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.green[100],
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(
                    Icons.currency_rupee,
                    color: Colors.green[700],
                    size: 20,
                  ),
                ),
                border: InputBorder.none,
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 16,
                ),
                labelStyle: TextStyle(color: Colors.grey[600]),
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter an amount';
                }
                final amount = double.tryParse(value);
                if (amount == null || amount <= 0) {
                  return 'Please enter a valid amount';
                }
                if (amount < 10) {
                  return 'Minimum donation amount is ₹10';
                }
                if (amount > 100000) {
                  return 'Amount exceeds daily UPI limit (₹1,00,000)';
                }
                if (amount > 50000) {
                  return 'Large amount - consider bank transfer for amounts above ₹50,000';
                }
                return null;
              },
            ),
          ),
          
          const SizedBox(height: 16),
          
          // UPI Payment Tips
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
                      'UPI Payment Tips',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: Colors.blue[700],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                Text(
                  '• Daily UPI limit: ₹1,00,0000\n• Bank limits may vary (₹10,000-₹25,000)\n• For large amounts, try multiple smaller payments\n• Ensure sufficient balance before payment\n\n💡 App Compatibility Tips:\n• Flipkart UPI & BHIM work most reliably\n• If Google Pay shows "limit error", try different app\n• If Paytm shows "risk alert", use Flipkart UPI\n• PhonePe may need app update for best results',
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
          _buildPaymentMethodSelector(),
        ],
      ),
    );
  }

  Widget _buildQuickAmountButton(double amount) {
    final isSelected = _amountController.text == amount.toStringAsFixed(0);
    return GestureDetector(
      onTap: () {
        setState(() {
          _amountController.text = amount.toStringAsFixed(0);
        });
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        decoration: BoxDecoration(
          gradient: isSelected
              ? LinearGradient(
                  colors: [
                    const Color(0xFF667eea),
                    const Color(0xFF764ba2),
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                )
              : null,
          color: isSelected ? null : Colors.white,
          border: Border.all(
            color: isSelected 
                ? Colors.transparent 
                : Colors.grey[300]!,
            width: 1.5,
          ),
          borderRadius: BorderRadius.circular(12),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: const Color(0xFF667eea).withOpacity(0.3),
                    spreadRadius: 0,
                    blurRadius: 8,
                    offset: const Offset(0, 4),
                  ),
                ]
              : [
                  BoxShadow(
                    color: Colors.grey.withOpacity(0.1),
                    spreadRadius: 0,
                    blurRadius: 4,
                    offset: const Offset(0, 2),
                  ),
                ],
        ),
        child: Center(
          child: Text(
            '₹${amount.toStringAsFixed(0)}',
            style: TextStyle(
              color: isSelected ? Colors.white : Colors.black87,
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildPaymentMethodSelector() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Payment Method',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: Colors.black87,
          ),
        ),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          children: PaymentMethod.values.map((method) {
            final isSelected = _selectedPaymentMethod == method;
            return ChoiceChip(
              label: Text(method.displayName),
              selected: isSelected,
              onSelected: (selected) {
                setState(() {
                  _selectedPaymentMethod = method;
                });
              },
              selectedColor: const Color(0xFF6A11CB),
              labelStyle: TextStyle(
                color: isSelected ? Colors.white : Colors.black87,
                fontSize: 12,
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildDonorDetailsTab() {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Form(
        key: _formKey,
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Donor Information',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
              const SizedBox(height: 16),
              CheckboxListTile(
                title: const Text('Donate anonymously'),
                subtitle: const Text('Your name will not be shown publicly'),
                value: _isAnonymous,
                onChanged: (value) {
                  setState(() {
                    _isAnonymous = value ?? false;
                  });
                },
                activeColor: const Color(0xFF6A11CB),
                controlAffinity: ListTileControlAffinity.leading,
                contentPadding: EdgeInsets.zero,
              ),
              const SizedBox(height: 16),
              if (!_isAnonymous) ...[
                TextFormField(
                  controller: _nameController,
                  decoration: InputDecoration(
                    labelText: 'Full Name',
                    hintText: 'Enter your full name',
                    prefixIcon: const Icon(Icons.person),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(color: Color(0xFF6A11CB)),
                    ),
                  ),
                  validator: (value) {
                    if (!_isAnonymous && (value == null || value.isEmpty)) {
                      return 'Please enter your name';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _emailController,
                  keyboardType: TextInputType.emailAddress,
                  decoration: InputDecoration(
                    labelText: 'Email (Optional)',
                    hintText: 'Enter your email',
                    prefixIcon: const Icon(Icons.email),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(color: Color(0xFF6A11CB)),
                    ),
                  ),
                  validator: (value) {
                    if (value != null && value.isNotEmpty) {
                      if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(value)) {
                        return 'Please enter a valid email';
                      }
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _phoneController,
                  keyboardType: TextInputType.phone,
                  decoration: InputDecoration(
                    labelText: 'Phone (Optional)',
                    hintText: 'Enter your phone number',
                    prefixIcon: const Icon(Icons.phone),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(color: Color(0xFF6A11CB)),
                    ),
                  ),
                  validator: (value) {
                    if (value != null && value.isNotEmpty) {
                      if (!RegExp(r'^\+?[\d\s\-\(\)]{10,}$').hasMatch(value)) {
                        return 'Please enter a valid phone number';
                      }
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
              ],
              TextFormField(
                controller: _messageController,
                maxLines: 3,
                decoration: InputDecoration(
                  labelText: 'Message (Optional)',
                  hintText: 'Add a message of support...',
                  prefixIcon: const Icon(Icons.message),
                  alignLabelWithHint: true,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(color: Color(0xFF6A11CB)),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildBottomActions() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: const BorderRadius.vertical(bottom: Radius.circular(20)),
      ),
      child: Column(
        children: [
          if (_amountController.text.isNotEmpty)
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: const Color(0xFF6A11CB).withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Donation Amount:',
                    style: TextStyle(fontWeight: FontWeight.w600),
                  ),
                  Text(
                    '₹${_amountController.text}',
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF6A11CB),
                    ),
                  ),
                ],
              ),
            ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: () => Navigator.pop(context),
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    side: const BorderSide(color: Color(0xFF6A11CB)),
                  ),
                  child: const Text('Cancel'),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                flex: 2,
                child: ElevatedButton(
                  onPressed: _isProcessing ? null : _processDonation,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF6A11CB),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                  child: _isProcessing
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor: AlwaysStoppedAnimation(Colors.white),
                          ),
                        )
                      : Text(_selectedPaymentMethod == PaymentMethod.upi
                          ? 'Pay Now'
                          : 'Continue'),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Future<void> _processDonation() async {
    if (_amountController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please select or enter an amount'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    if (_tabController.index == 1 && !_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _isProcessing = true;
    });

    try {
      final amount = double.parse(_amountController.text);
      final donationRequest = DonationRequest(
        donorName: _isAnonymous ? 'Anonymous' : _nameController.text.trim(),
        donorEmail: _emailController.text.trim().isEmpty ? null : _emailController.text.trim(),
        donorPhone: _phoneController.text.trim().isEmpty ? null : _phoneController.text.trim(),
        amount: amount,
        paymentMethod: _selectedPaymentMethod,
        message: _messageController.text.trim().isEmpty ? null : _messageController.text.trim(),
        isAnonymous: _isAnonymous,
      );

      if (_selectedPaymentMethod == PaymentMethod.upi) {
        // Process UPI payment
        Navigator.pop(context);
        await _processUpiPayment(amount, donationRequest);
      } else {
        // Process other payment methods
        final donation = await DonationService.processDonation(
          campaignId: widget.campaignId,
          donationRequest: donationRequest,
        );

        if (donation != null) {
          Navigator.pop(context);
          _showSuccessDialog(amount);
          widget.onSuccess();
        } else {
          throw Exception('Failed to process donation');
        }
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error processing donation: $e'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      setState(() {
        _isProcessing = false;
      });
    }
  }

  Future<void> _processUpiPayment(double amount, DonationRequest donationRequest) async {
    final upiString = UpiService.generateUpiString(
      widget.upiId,
      'NGO Campaign',
      widget.campaignTitle,
    );

    UpiService.showUpiAppSelector(
      context,
      upiString,
      amount,
      (paidAmount) async {
        try {
          // Record the donation with payment success
          final donation = await DonationService.processDonation(
            campaignId: widget.campaignId,
            donationRequest: donationRequest.copyWith(amount: paidAmount),
          );

          if (donation != null) {
            // Record UPI payment
            await ApiService.instance.recordUpiPayment(
              campaignId: widget.campaignId,
              amount: paidAmount,
              paymentMethod: 'UPI',
              transactionId: 'UPI_${DateTime.now().millisecondsSinceEpoch}',
            );

            _showSuccessDialog(paidAmount);
            widget.onSuccess();
          }
        } catch (e) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Payment successful but recording failed: $e'),
              backgroundColor: Colors.orange,
            ),
          );
        }
      },
    );
  }

  void _showSuccessDialog(double amount) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              Icons.check_circle,
              color: Colors.green,
              size: 64,
            ),
            const SizedBox(height: 16),
            const Text(
              'Thank You!',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Your donation of ₹${amount.toStringAsFixed(2)} has been processed successfully.',
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () => Navigator.pop(context),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF6A11CB),
                foregroundColor: Colors.white,
              ),
              child: const Text('Close'),
            ),
          ],
        ),
      ),
    );
  }
}

extension DonationRequestExtension on DonationRequest {
  DonationRequest copyWith({
    String? donorName,
    String? donorEmail,
    String? donorPhone,
    double? amount,
    PaymentMethod? paymentMethod,
    String? message,
    bool? isAnonymous,
    Map<String, dynamic>? additionalInfo,
  }) {
    return DonationRequest(
      donorName: donorName ?? this.donorName,
      donorEmail: donorEmail ?? this.donorEmail,
      donorPhone: donorPhone ?? this.donorPhone,
      amount: amount ?? this.amount,
      paymentMethod: paymentMethod ?? this.paymentMethod,
      message: message ?? this.message,
      isAnonymous: isAnonymous ?? this.isAnonymous,
      additionalInfo: additionalInfo ?? this.additionalInfo,
    );
  }
}
