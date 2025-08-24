import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'upi_payment_screen.dart';

class DonationScreen extends StatefulWidget {
  final String campaignId;
  final String campaignTitle;
  final String upiId;
  final double targetAmount;
  final double currentRaised;
  final VoidCallback onSuccess;

  const DonationScreen({
    super.key,
    required this.campaignId,
    required this.campaignTitle,
    required this.upiId, 
    required this.targetAmount,
    required this.currentRaised,
    required this.onSuccess,
  });

  @override
  State<DonationScreen> createState() => _DonationScreenState();
}

class _DonationScreenState extends State<DonationScreen> {
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _messageController = TextEditingController();
  
  bool _donateAnonymously = false;
  bool _isProcessing = false;

  @override
  void initState() {
    super.initState();
    // Add listeners to refresh button state when user types
    _nameController.addListener(() => setState(() {}));
    _emailController.addListener(() => setState(() {}));
    _phoneController.addListener(() => setState(() {}));
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _messageController.dispose();
    super.dispose();
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
          'Donate',
          style: GoogleFonts.poppins(
            color: Colors.black,
            fontSize: 20,
            fontWeight: FontWeight.w600,
          ),
        ),
        centerTitle: true,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Campaign Info
              _buildCampaignInfo(),
              const SizedBox(height: 30),
              
              // Donation Details Section
              if (!_donateAnonymously) ...[
                _buildDetailsSection(),
                const SizedBox(height: 30),
              ],
              
              // OR Divider with Anonymous Toggle
              _buildOrDividerWithToggle(),
              const SizedBox(height: 30),
              
              // Message Section (always visible)
              _buildMessageSection(),
              const SizedBox(height: 40),
              
              // Tap to Pay Button
              _buildTapToPayButton(),
              
              const SizedBox(height: 40), // Extra space at bottom to prevent overflow
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCampaignInfo() {
    final progress = widget.currentRaised / widget.targetAmount;
    final remainingAmount = widget.targetAmount - widget.currentRaised;
    
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey[300]!),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            widget.campaignTitle,
            style: GoogleFonts.poppins(
              color: Colors.black,
              fontSize: 18,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 16),
          
          // Progress Bar
          Container(
            height: 8,
            decoration: BoxDecoration(
              color: Colors.grey[300],
              borderRadius: BorderRadius.circular(4),
            ),
            child: LinearProgressIndicator(
              value: progress,
              backgroundColor: Colors.transparent,
              valueColor: const AlwaysStoppedAnimation<Color>(Color(0xFF00D4AA)),
              borderRadius: BorderRadius.circular(4),
            ),
          ),
          const SizedBox(height: 12),
          
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Raised',
                    style: GoogleFonts.poppins(
                      color: Colors.grey[600],
                      fontSize: 12,
                    ),
                  ),
                  Text(
                    '₹${widget.currentRaised.toStringAsFixed(0)}',
                    style: GoogleFonts.poppins(
                      color: const Color(0xFF00D4AA),
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    'Remaining',
                    style: GoogleFonts.poppins(
                      color: Colors.grey[600],
                      fontSize: 12,
                    ),
                  ),
                  Text(
                    '₹${remainingAmount.toStringAsFixed(0)}',
                    style: GoogleFonts.poppins(
                      color: Colors.black,
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildDetailsSection() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey[300]!),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Donor Details',
            style: GoogleFonts.poppins(
              color: Colors.black,
              fontSize: 18,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 20),
          
          _buildTextField(
            controller: _nameController,
            label: 'Full Name',
            hint: 'Enter your full name',
            icon: Icons.person_outline,
          ),
          const SizedBox(height: 16),
          
          _buildTextField(
            controller: _emailController,
            label: 'Email Address',
            hint: 'Enter your email',
            icon: Icons.email_outlined,
            keyboardType: TextInputType.emailAddress,
          ),
          const SizedBox(height: 16),
          
          _buildTextField(
            controller: _phoneController,
            label: 'Phone Number',
            hint: 'Enter your phone number',
            icon: Icons.phone_outlined,
            keyboardType: TextInputType.phone,
          ),
        ],
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required String hint,
    required IconData icon,
    TextInputType? keyboardType,
    int? maxLines,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: GoogleFonts.poppins(
            color: Colors.grey[700],
            fontSize: 14,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 8),
        TextField(
          controller: controller,
          keyboardType: keyboardType,
          maxLines: maxLines ?? 1,
          style: GoogleFonts.poppins(
            color: Colors.black,
            fontSize: 16,
          ),
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: GoogleFonts.poppins(
              color: Colors.grey[500],
              fontSize: 16,
            ),
            prefixIcon: Icon(icon, color: Colors.grey[600]),
            filled: true,
            fillColor: Colors.white,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: Colors.grey[300]!),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Color(0xFF00D4AA), width: 2),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: Colors.grey[300]!),
            ),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 16,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildOrDividerWithToggle() {
    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: Container(
                height: 1,
                color: Colors.grey[400],
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Text(
                'OR',
                style: GoogleFonts.poppins(
                  color: Colors.grey[600],
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
            Expanded(
              child: Container(
                height: 1,
                color: Colors.grey[400],
              ),
            ),
          ],
        ),
        const SizedBox(height: 20),
        
        // Anonymous Toggle
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.grey[50],
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: _donateAnonymously ? const Color(0xFF00D4AA) : Colors.grey[300]!,
            ),
          ),
          child: Row(
            children: [
              GestureDetector(
                onTap: () {
                  setState(() {
                    _donateAnonymously = !_donateAnonymously;
                    if (_donateAnonymously) {
                      _nameController.clear();
                      _emailController.clear();
                      _phoneController.clear();
                    }
                  });
                },
                child: Container(
                  width: 24,
                  height: 24,
                  decoration: BoxDecoration(
                    color: _donateAnonymously ? const Color(0xFF00D4AA) : Colors.transparent,
                    border: Border.all(
                      color: _donateAnonymously ? const Color(0xFF00D4AA) : Colors.grey[400]!,
                      width: 2,
                    ),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: _donateAnonymously
                      ? const Icon(
                          Icons.check,
                          color: Colors.white,
                          size: 16,
                        )
                      : null,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Donate anonymously',
                      style: GoogleFonts.poppins(
                        color: Colors.black,
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    Text(
                      'Your name will not be shown publicly',
                      style: GoogleFonts.poppins(
                        color: Colors.grey[600],
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildMessageSection() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey[300]!),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Message (Optional)',
            style: GoogleFonts.poppins(
              color: Colors.black,
              fontSize: 18,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 16),
          
          _buildTextField(
            controller: _messageController,
            label: 'Your Message',
            hint: 'Write a message of support or motivation...',
            icon: Icons.message_outlined,
            maxLines: 3,
          ),
        ],
      ),
    );
  }

  Widget _buildTapToPayButton() {
    // Check if user has filled details or selected anonymous
    final hasValidDetails = _donateAnonymously || 
        (_nameController.text.trim().isNotEmpty && 
         _emailController.text.trim().isNotEmpty && 
         _phoneController.text.trim().isNotEmpty);
    
    return Container(
      width: double.infinity,
      height: 56,
      child: ElevatedButton(
        onPressed: hasValidDetails && !_isProcessing ? _handleTapToPay : null,
        style: ElevatedButton.styleFrom(
          backgroundColor: hasValidDetails ? const Color(0xFF00D4AA) : Colors.grey[400],
          disabledBackgroundColor: Colors.grey[400],
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          elevation: 0,
        ),
        child: _isProcessing
            ? const CircularProgressIndicator(
                color: Colors.white,
                strokeWidth: 2,
              )
            : Text(
                'Continue to Payment',
                style: GoogleFonts.poppins(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                ),
              ),
      ),
    );
  }

  void _handleTapToPay() async {
    // Validate before proceeding
    if (!_donateAnonymously) {
      if (_nameController.text.trim().isEmpty ||
          _emailController.text.trim().isEmpty ||
          _phoneController.text.trim().isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Please fill all required fields or select "Donate anonymously"'),
            backgroundColor: Colors.red,
          ),
        );
        return;
      }
    }

    setState(() {
      _isProcessing = true;
    });

    try {
      // Navigate to payment interface screen with default amount
      final result = await Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => PaymentInterfaceScreen(
            campaignId: widget.campaignId,
            campaignTitle: widget.campaignTitle,
            upiId: widget.upiId,
            amount: 0, // Start with 0, user will enter amount in payment screen
            donorName: _donateAnonymously ? 'Anonymous' : _nameController.text,
            donorEmail: _donateAnonymously ? '' : _emailController.text,
            donorPhone: _donateAnonymously ? '' : _phoneController.text,
            message: _messageController.text,
            isAnonymous: _donateAnonymously,
            onSuccess: widget.onSuccess,
          ),
        ),
      );
      
      if (result == true) {
        Navigator.pop(context);
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error: $e'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      setState(() {
        _isProcessing = false;
      });
    }
  }
}

// Payment Interface Screen (like SIP interface)
class PaymentInterfaceScreen extends StatefulWidget {
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

  const PaymentInterfaceScreen({
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
  State<PaymentInterfaceScreen> createState() => _PaymentInterfaceScreenState();
}

class _PaymentInterfaceScreenState extends State<PaymentInterfaceScreen> {
  final _amountController = TextEditingController();
  bool _isProcessing = false;
  static const double maxDonationLimit = 100000000; // ₹10,00,00,000

  @override
  void initState() {
    super.initState();
    // Start with a default amount of 100 if no amount is provided
    _amountController.text = widget.amount > 0 ? widget.amount.toStringAsFixed(0) : '10';
  }

  @override
  void dispose() {
    _amountController.dispose();
    super.dispose();
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
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'DONATION',
              style: GoogleFonts.poppins(
                color: Colors.black,
                fontSize: 18,
                fontWeight: FontWeight.w600,
              ),
            ),
            Text(
              widget.campaignTitle.length > 30 
                  ? '${widget.campaignTitle.substring(0, 30)}...'
                  : widget.campaignTitle,
              style: GoogleFonts.poppins(
                color: Colors.grey[600],
                fontSize: 12,
              ),
            ),
          ],
        ),
      ),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(20),
                child: Column(
                  children: [
                    // Amount Display
                    Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          'Donation amount',
                          style: GoogleFonts.poppins(
                            color: Colors.grey[600],
                            fontSize: 16,
                          ),
                        ),
                        const SizedBox(height: 16),
                        Text(
                          '₹ ${_amountController.text}',
                          style: GoogleFonts.poppins(
                            color: Colors.black,
                            fontSize: 48,
                            fontWeight: FontWeight.w300,
                          ),
                        ),
                        const SizedBox(height: 8),
                        
                        // Show limit warning if amount exceeds limit
                        if (double.tryParse(_amountController.text) != null && 
                            double.parse(_amountController.text) > maxDonationLimit)
                          Text(
                            'You can only donate upto ₹${_formatAmount(maxDonationLimit.toInt())}',
                            style: GoogleFonts.poppins(
                              color: Colors.red,
                              fontSize: 14,
                              fontWeight: FontWeight.w400,
                            ),
                          ),
                        
                        const SizedBox(height: 30),
                        
                        // Quick amount adjustment buttons
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            _buildQuickAmountButton(100),
                            const SizedBox(width: 12),
                            _buildQuickAmountButton(500),
                            const SizedBox(width: 12),
                            _buildQuickAmountButton(1000),
                          ],
                        ),
                        const SizedBox(height: 20),
                        
                        // Preset amount buttons
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            _buildPresetAmountButton(250),
                            const SizedBox(width: 12),
                            _buildPresetAmountButton(2500),
                            const SizedBox(width: 12),
                            _buildPresetAmountButton(5000),
                          ],
                        ),
                      ],
                    ),
                    
                    const SizedBox(height: 30),
                    
                    // Payment Method Selection
                    GestureDetector(
                      onTap: _navigateToPaymentMethod,
                      child: Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.grey[50],
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: Colors.grey[300]!),
                        ),
                        child: Row(
                          children: [
                            Container(
                              width: 40,
                              height: 40,
                              decoration: BoxDecoration(
                                color: const Color(0xFF00D4AA),
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: const Icon(
                                Icons.account_balance,
                                color: Colors.white,
                                size: 20,
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Text(
                                'Pay via UPI',
                                style: GoogleFonts.poppins(
                                  color: Colors.black,
                                  fontSize: 16,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ),
                            const Icon(
                              Icons.arrow_forward_ios,
                              color: Colors.grey,
                              size: 16,
                            ),
                          ],
                        ),
                      ),
                    ),
                    
                    const SizedBox(height: 30),
                    
                    // Number Pad
                    Container(
                      height: 280,
                      child: _buildNumberPad(),
                    ),
                    
                    const SizedBox(height: 20), // Extra space before bottom buttons
                  ],
                ),
              ),
            ),
            
            // Action Buttons - Fixed at bottom
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                border: Border(
                  top: BorderSide(color: Colors.grey[200]!, width: 1),
                ),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => Navigator.pop(context),
                      style: OutlinedButton.styleFrom(
                        side: const BorderSide(color: Color(0xFF00D4AA)),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        padding: const EdgeInsets.symmetric(vertical: 16),
                      ),
                      child: Text(
                        'Cancel',
                        style: GoogleFonts.poppins(
                          color: const Color(0xFF00D4AA),
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: _isProcessing ? null : _handleDonation,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF00D4AA),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        padding: const EdgeInsets.symmetric(vertical: 16),
                      ),
                      child: _isProcessing
                          ? const CircularProgressIndicator(
                              color: Colors.white,
                              strokeWidth: 2,
                            )
                          : Text(
                              'Start Donation',
                              style: GoogleFonts.poppins(
                                color: Colors.white,
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildQuickAmountButton(int amount) {
    return GestureDetector(
      onTap: () {
        final currentAmount = int.tryParse(_amountController.text) ?? 0;
        final newAmount = currentAmount + amount;
        
        if (newAmount <= maxDonationLimit) {
          setState(() {
            _amountController.text = newAmount.toString();
          });
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Maximum donation limit is ₹${_formatAmount(maxDonationLimit.toInt())}'),
              backgroundColor: Colors.red,
            ),
          );
        }
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: Colors.grey[300]!),
        ),
        child: Text(
          '+ ₹$amount',
          style: GoogleFonts.poppins(
            color: Colors.black,
            fontSize: 14,
            fontWeight: FontWeight.w500,
          ),
        ),
      ),
    );
  }

  Widget _buildPresetAmountButton(int amount) {
    return GestureDetector(
      onTap: () {
        if (amount <= maxDonationLimit) {
          setState(() {
            _amountController.text = amount.toString();
          });
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Maximum donation limit is ₹${_formatAmount(maxDonationLimit.toInt())}'),
              backgroundColor: Colors.red,
            ),
          );
        }
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: const Color(0xFF00D4AA),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: const Color(0xFF00D4AA)),
        ),
        child: Text(
          '₹$amount',
          style: GoogleFonts.poppins(
            color: Colors.white,
            fontSize: 14,
            fontWeight: FontWeight.w500,
          ),
        ),
      ),
    );
  }

  Widget _buildNumberPad() {
    return GridView.count(
      crossAxisCount: 3,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      children: [
        _buildNumberButton('1'),
        _buildNumberButton('2'),
        _buildNumberButton('3'),
        _buildNumberButton('4'),
        _buildNumberButton('5'),
        _buildNumberButton('6'),
        _buildNumberButton('7'),
        _buildNumberButton('8'),
        _buildNumberButton('9'),
        _buildNumberButton('•'),
        _buildNumberButton('0'),
        _buildNumberButton('⌫'),
      ],
    );
  }

  Widget _buildNumberButton(String text) {
    return GestureDetector(
      onTap: () => _onNumberTap(text),
      child: Container(
        margin: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: Colors.transparent,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Center(
          child: text == '⌫'
              ? const Icon(
                  Icons.backspace_outlined,
                  color: Colors.black,
                  size: 24,
                )
              : Text(
                  text,
                  style: GoogleFonts.poppins(
                    color: Colors.black,
                    fontSize: 24,
                    fontWeight: FontWeight.w400,
                  ),
                ),
        ),
      ),
    );
  }

  void _onNumberTap(String value) {
    setState(() {
      if (value == '⌫') {
        if (_amountController.text.isNotEmpty) {
          _amountController.text = _amountController.text.substring(0, _amountController.text.length - 1);
        }
      } else if (value == '•') {
        // Do nothing for dot for now (or implement decimal support)
      } else {
        String newText;
        if (_amountController.text == '0') {
          newText = value;
        } else {
          newText = _amountController.text + value;
        }
        
        // Check if new amount would exceed limit
        final newAmount = double.tryParse(newText);
        if (newAmount != null && newAmount <= maxDonationLimit) {
          _amountController.text = newText;
        } else if (newAmount != null && newAmount > maxDonationLimit) {
          // Show alert when trying to exceed limit
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Maximum donation limit is ₹${_formatAmount(maxDonationLimit.toInt())}'),
              backgroundColor: Colors.red,
              duration: const Duration(seconds: 2),
            ),
          );
        }
      }
    });
  }

  String _formatAmount(int amount) {
    if (amount >= 10000000) {
      return '${(amount / 10000000).toStringAsFixed(0)},${((amount % 10000000) / 100000).toStringAsFixed(0).padLeft(2, '0')},${((amount % 100000) / 1000).toStringAsFixed(0).padLeft(2, '0')}';
    } else if (amount >= 100000) {
      return '${(amount / 100000).toStringAsFixed(0)},${((amount % 100000) / 1000).toStringAsFixed(0).padLeft(2, '0')},${(amount % 1000).toStringAsFixed(0).padLeft(3, '0')}';
    } else if (amount >= 1000) {
      return '${(amount / 1000).toStringAsFixed(0)},${(amount % 1000).toStringAsFixed(0).padLeft(3, '0')}';
    } else {
      return amount.toString();
    }
  }

  void _handleDonation() async {
    final amount = double.tryParse(_amountController.text);
    if (amount == null || amount <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please enter a valid amount'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    // Check if amount exceeds limit
    if (amount > maxDonationLimit) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Maximum donation limit is ₹${_formatAmount(maxDonationLimit.toInt())}'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    // Navigate to UPI payment method selection screen
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => UpiPaymentScreen(
          campaignId: widget.campaignId,
          campaignTitle: widget.campaignTitle,
          upiId: widget.upiId,
          amount: amount,
          donorName: widget.donorName,
          donorEmail: widget.donorEmail,
          donorPhone: widget.donorPhone,
          message: widget.message,
          isAnonymous: widget.isAnonymous,
          onSuccess: widget.onSuccess,
        ),
      ),
    );
  }

  void _navigateToPaymentMethod() {
    final amount = double.tryParse(_amountController.text);
    if (amount == null || amount <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please enter a valid amount first'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    // Check if amount exceeds limit
    if (amount > maxDonationLimit) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Maximum donation limit is ₹${_formatAmount(maxDonationLimit.toInt())}'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    // Navigate to UPI payment method selection screen
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => UpiPaymentScreen(
          campaignId: widget.campaignId,
          campaignTitle: widget.campaignTitle,
          upiId: widget.upiId,
          amount: amount,
          donorName: widget.donorName,
          donorEmail: widget.donorEmail,
          donorPhone: widget.donorPhone,
          message: widget.message,
          isAnonymous: widget.isAnonymous,
          onSuccess: widget.onSuccess,
        ),
      ),
    );
  }
}
