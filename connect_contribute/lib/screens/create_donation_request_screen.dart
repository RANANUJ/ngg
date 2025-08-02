import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import '../widgets/custom_text_field.dart';
import '../themes/app_theme.dart';
import 'package:google_fonts/google_fonts.dart';

class CreateDonationRequestScreen extends StatefulWidget {
  const CreateDonationRequestScreen({super.key});

  @override
  State<CreateDonationRequestScreen> createState() =>
      _CreateDonationRequestScreenState();
}

class _CreateDonationRequestScreenState
    extends State<CreateDonationRequestScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _quantityController = TextEditingController();
  final _unitController = TextEditingController();
  final _deadlineController = TextEditingController();

  DateTime? _selectedDeadline;
  String _selectedCategory = 'Books';
  File? _selectedImage;
  bool _isLoading = false;

  final List<String> _categories = [
    'Books',
    'Clothes',
    'Food',
    'Medical Supplies',
    'School Supplies',
    'Toys',
    'Electronics',
    'Furniture',
    'Other',
  ];

  final List<String> _units = [
    'items',
    'kg',
    'pairs',
    'sets',
    'boxes',
    'pieces',
  ];

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _quantityController.dispose();
    _unitController.dispose();
    _deadlineController.dispose();
    super.dispose();
  }

  String? _validateTitle(String? value) {
    if (value == null || value.isEmpty) {
      return 'Request title is required';
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

  String? _validateQuantity(String? value) {
    if (value == null || value.isEmpty) {
      return 'Quantity is required';
    }
    if (int.tryParse(value) == null) {
      return 'Please enter a valid quantity';
    }
    if (int.parse(value) <= 0) {
      return 'Quantity must be greater than 0';
    }
    return null;
  }

  String? _validateDeadline(String? value) {
    if (_selectedDeadline == null) {
      return 'Deadline is required';
    }
    if (_selectedDeadline!.isBefore(DateTime.now())) {
      return 'Deadline must be in the future';
    }
    return null;
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now().add(const Duration(days: 7)),
      firstDate: DateTime.now().add(const Duration(days: 1)),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );
    if (picked != null && picked != _selectedDeadline) {
      setState(() {
        _selectedDeadline = picked;
        _deadlineController.text =
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

  Future<void> _createDonationRequest() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
    });

    try {
      // TODO: Implement API call to create donation request
      await Future.delayed(const Duration(seconds: 2)); // Simulate API call

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Donation request created successfully!'),
            backgroundColor: Colors.green,
          ),
        );
        context.pop();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error creating donation request: $e'),
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
          'Create Donation Request',
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
                        Icons.inventory,
                        size: 32,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'Create Donation Request',
                      style: GoogleFonts.poppins(
                        color: Colors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Request items needed for your cause',
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

              // Request Title
              CustomTextField(
                label: 'Request Title',
                hint: 'Enter request title',
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
                hint: 'Describe what items you need and why',
                controller: _descriptionController,
                validator: _validateDescription,
                prefixIcon: Icons.description,
                maxLines: 4,
              ),

              const SizedBox(height: 20),

              // Quantity and Unit Row
              Row(
                children: [
                  Expanded(
                    flex: 2,
                    child: CustomTextField(
                      label: 'Quantity',
                      hint: 'Enter quantity',
                      controller: _quantityController,
                      validator: _validateQuantity,
                      prefixIcon: Icons.numbers,
                      keyboardType: TextInputType.number,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    flex: 1,
                    child: DropdownButtonFormField<String>(
                      value: _units.first,
                      decoration: InputDecoration(
                        labelText: 'Unit',
                        prefixIcon: const Icon(Icons.straighten),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(color: Colors.grey[300]!),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: const BorderSide(
                            color: Color(0xFF6A11CB),
                          ),
                        ),
                      ),
                      items:
                          _units.map((String unit) {
                            return DropdownMenuItem<String>(
                              value: unit,
                              child: Text(unit),
                            );
                          }).toList(),
                      onChanged: (String? newValue) {
                        setState(() {
                          _unitController.text = newValue!;
                        });
                      },
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 20),

              // Deadline
              GestureDetector(
                onTap: () => _selectDate(context),
                child: AbsorbPointer(
                  child: CustomTextField(
                    label: 'Deadline',
                    hint: 'Select deadline',
                    controller: _deadlineController,
                    validator: _validateDeadline,
                    prefixIcon: Icons.calendar_today,
                  ),
                ),
              ),

              const SizedBox(height: 20),

              // Image Upload
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
                      'Add Item Image',
                      style: GoogleFonts.poppins(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: const Color(0xFF1E293B),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Upload an image to show what items you need',
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

              const SizedBox(height: 32),

              // Create Button
              SizedBox(
                height: 50,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _createDonationRequest,
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
                            'Create Request',
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
