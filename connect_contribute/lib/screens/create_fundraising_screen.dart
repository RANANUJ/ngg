import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import '../widgets/custom_text_field.dart';

import 'package:google_fonts/google_fonts.dart';
import '../services/api_service.dart';

class CreateFundraisingScreen extends StatefulWidget {
  const CreateFundraisingScreen({super.key});

  @override
  State<CreateFundraisingScreen> createState() =>
      _CreateFundraisingScreenState();
}

class _CreateFundraisingScreenState extends State<CreateFundraisingScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _targetAmountController = TextEditingController();
  final _endDateController = TextEditingController();
  final _bankAccountController = TextEditingController();
  final _upiIdController = TextEditingController();
  final _qrCodeController = TextEditingController();

  DateTime? _selectedEndDate;
  String _selectedCategory = 'Education';
  File? _selectedImage;
  bool _isLoading = false;
  bool _showPaymentDetails = false;

  final List<String> _categories = [
    'Education',
    'Healthcare',
    'Environment',
    'Poverty Relief',
    'Animal Welfare',
    'Disaster Relief',
    'Community Development',
    'Other',
  ];

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _targetAmountController.dispose();
    _endDateController.dispose();
    _bankAccountController.dispose();
    _upiIdController.dispose();
    _qrCodeController.dispose();
    super.dispose();
  }

  String? _validateTitle(String? value) {
    if (value == null || value.isEmpty) {
      return 'Campaign title is required';
    }
    if (value.length < 5) {
      return 'Title must be at least 5 characters';
    }
    return null;
  }

  String? _validateDescription(String? value) {
    if (value == null || value.isEmpty) {
      return 'Description is required';
    }
    if (value.length < 20) {
      return 'Description must be at least 20 characters';
    }
    return null;
  }

  String? _validateTargetAmount(String? value) {
    if (value == null || value.isEmpty) {
      return 'Target amount is required';
    }
    if (double.tryParse(value) == null) {
      return 'Please enter a valid amount';
    }
    if (double.parse(value) <= 0) {
      return 'Amount must be greater than 0';
    }
    return null;
  }

  String? _validateEndDate(String? value) {
    if (_selectedEndDate == null) {
      return 'End date is required';
    }
    if (_selectedEndDate!.isBefore(DateTime.now())) {
      return 'End date must be in the future';
    }
    return null;
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now().add(const Duration(days: 30)),
      firstDate: DateTime.now().add(const Duration(days: 1)),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );
    if (picked != null && picked != _selectedEndDate) {
      setState(() {
        _selectedEndDate = picked;
        _endDateController.text =
            '${picked.day}/${picked.month}/${picked.year}';
      });
    }
  }

  Future<void> _pickImage() async {
    final ImagePicker picker = ImagePicker();
    final XFile? image = await picker.pickImage(
      source: ImageSource.gallery,
      maxWidth: 1024,
      maxHeight: 1024,
      imageQuality: 85,
    );

    if (image != null) {
      setState(() {
        _selectedImage = File(image.path);
      });
    }
  }

  Future<void> _createCampaign() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
    });

    try {
      final data = {
        'title': _titleController.text.trim(),
        'description': _descriptionController.text.trim(),
        'category': _selectedCategory,
        'target_amount': double.parse(_targetAmountController.text.trim()),
        'end_date': _selectedEndDate?.toIso8601String(),
        'cover_image': null, // You can implement image upload if needed
        'payment_details':
            _showPaymentDetails
                ? {
                  'bank_account': _bankAccountController.text.trim(),
                  'upi_id': _upiIdController.text.trim(),
                  'qr_code': _qrCodeController.text.trim(),
                }
                : {},
      };
      await ApiService.instance.createCampaign(data);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Campaign created successfully!'),
            backgroundColor: Colors.green,
          ),
        );
        // Return success to trigger refresh in NGO dashboard
        context.pop(true);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error creating campaign: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        title: Text(
          'Create Fundraising Campaign',
          style: GoogleFonts.poppins(fontSize: 18, fontWeight: FontWeight.w600),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Color(0xFF6A11CB)),
          onPressed: () => context.pop(),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Header
              Container(
                padding: const EdgeInsets.all(24.0),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFF6A11CB), Color(0xFF2575FC)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(20.0),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFF6A11CB).withOpacity(0.3),
                      spreadRadius: 1,
                      blurRadius: 20,
                      offset: const Offset(0, 8),
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: const Icon(
                        Icons.monetization_on,
                        size: 32,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'Create Fundraising Campaign',
                      style: GoogleFonts.poppins(
                        color: Colors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Start a campaign to raise funds for your cause',
                      style: GoogleFonts.poppins(
                        color: Colors.white.withOpacity(0.9),
                        fontSize: 14,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 24),

              // Campaign Title
              CustomTextField(
                label: 'Campaign Title',
                hint: 'Enter campaign title',
                controller: _titleController,
                validator: _validateTitle,
                prefixIcon: Icons.title,
              ),

              const SizedBox(height: 20),

              // Category Dropdown
              DropdownButtonFormField<String>(
                value: _selectedCategory,
                decoration: InputDecoration(
                  labelText: 'Category',
                  hintText: 'Select category',
                  prefixIcon: const Icon(Icons.category),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: Colors.grey[300]!),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(color: Color(0xFF6A11CB)),
                  ),
                ),
                items:
                    _categories.map((String category) {
                      return DropdownMenuItem<String>(
                        value: category,
                        child: Text(category),
                      );
                    }).toList(),
                onChanged: (String? newValue) {
                  setState(() {
                    _selectedCategory = newValue!;
                  });
                },
              ),

              const SizedBox(height: 20),

              // Description
              CustomTextField(
                label: 'Description',
                hint: 'Describe your campaign and its impact',
                controller: _descriptionController,
                validator: _validateDescription,
                prefixIcon: Icons.description,
                maxLines: 4,
              ),

              const SizedBox(height: 20),

              // Target Amount
              CustomTextField(
                label: 'Target Amount (₹)',
                hint: 'Enter target amount',
                controller: _targetAmountController,
                validator: _validateTargetAmount,
                prefixIcon: Icons.attach_money,
                keyboardType: TextInputType.number,
              ),

              const SizedBox(height: 20),

              // End Date
              GestureDetector(
                onTap: () => _selectDate(context),
                child: AbsorbPointer(
                  child: CustomTextField(
                    label: 'Campaign End Date',
                    hint: 'Select end date',
                    controller: _endDateController,
                    validator: _validateEndDate,
                    prefixIcon: Icons.calendar_today,
                  ),
                ),
              ),

              const SizedBox(height: 20),

              // Cover Image Upload
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: Colors.grey[300]!),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey.withOpacity(0.1),
                      spreadRadius: 1,
                      blurRadius: 10,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    if (_selectedImage != null) ...[
                      ClipRRect(
                        borderRadius: BorderRadius.circular(12),
                        child: Image.file(
                          _selectedImage!,
                          height: 120,
                          width: double.infinity,
                          fit: BoxFit.cover,
                        ),
                      ),
                      const SizedBox(height: 16),
                    ] else ...[
                      Icon(
                        Icons.add_photo_alternate,
                        size: 48,
                        color: Colors.grey[400],
                      ),
                      const SizedBox(height: 12),
                    ],
                    Text(
                      'Add Cover Image',
                      style: GoogleFonts.poppins(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: const Color(0xFF1E293B),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Upload an image to make your campaign more appealing',
                      style: GoogleFonts.poppins(
                        fontSize: 14,
                        color: const Color(0xFF64748B),
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 16),
                    ElevatedButton.icon(
                      onPressed: _pickImage,
                      icon: Icon(
                        _selectedImage != null ? Icons.edit : Icons.upload,
                      ),
                      label: Text(
                        _selectedImage != null
                            ? 'Change Image'
                            : 'Choose Image',
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF6A11CB),
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 20),

              // Payment Details Section
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: Colors.grey[300]!),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey.withOpacity(0.1),
                      spreadRadius: 1,
                      blurRadius: 10,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(
                          Icons.payment,
                          color: const Color(0xFF6A11CB),
                          size: 24,
                        ),
                        const SizedBox(width: 12),
                        Text(
                          'Payment Details',
                          style: GoogleFonts.poppins(
                            fontSize: 18,
                            fontWeight: FontWeight.w600,
                            color: const Color(0xFF1E293B),
                          ),
                        ),
                        const Spacer(),
                        Switch(
                          value: _showPaymentDetails,
                          onChanged: (value) {
                            setState(() {
                              _showPaymentDetails = value;
                            });
                          },
                          activeColor: const Color(0xFF6A11CB),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Add payment details so volunteers can donate directly',
                      style: GoogleFonts.poppins(
                        fontSize: 14,
                        color: const Color(0xFF64748B),
                      ),
                    ),
                    if (_showPaymentDetails) ...[
                      const SizedBox(height: 20),
                      CustomTextField(
                        label: 'Bank Account Number',
                        hint: 'Enter bank account number',
                        controller: _bankAccountController,
                        prefixIcon: Icons.account_balance,
                        keyboardType: TextInputType.number,
                      ),
                      const SizedBox(height: 16),
                      CustomTextField(
                        label: 'UPI ID',
                        hint: 'Enter UPI ID (e.g., example@upi)',
                        controller: _upiIdController,
                        prefixIcon: Icons.phone_android,
                      ),
                      const SizedBox(height: 16),
                      CustomTextField(
                        label: 'QR Code URL',
                        hint: 'Enter QR code image URL',
                        controller: _qrCodeController,
                        prefixIcon: Icons.qr_code,
                      ),
                    ],
                  ],
                ),
              ),

              const SizedBox(height: 32),

              // Create Button
              SizedBox(
                height: 50,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _createCampaign,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF6A11CB),
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child:
                      _isLoading
                          ? const SizedBox(
                            height: 20,
                            width: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              valueColor: AlwaysStoppedAnimation<Color>(
                                Colors.white,
                              ),
                            ),
                          )
                          : Text(
                            'Create Campaign',
                            style: GoogleFonts.poppins(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
