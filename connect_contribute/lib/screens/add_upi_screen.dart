import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

class AddUpiScreen extends StatefulWidget {
  const AddUpiScreen({super.key});

  @override
  State<AddUpiScreen> createState() => _AddUpiScreenState();
}

class _AddUpiScreenState extends State<AddUpiScreen> {
  final _upiIdController = TextEditingController();
  final _nameController = TextEditingController();
  bool _isLoading = false;

  @override
  void dispose() {
    _upiIdController.dispose();
    _nameController.dispose();
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
          'Add New UPI ID',
          style: GoogleFonts.poppins(
            color: Colors.black,
            fontSize: 18,
            fontWeight: FontWeight.w400,
          ),
        ),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 20),
              
              // UPI ID Input
              Text(
                'UPI ID',
                style: GoogleFonts.poppins(
                  color: Colors.black,
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 8),
              TextFormField(
                controller: _upiIdController,
                keyboardType: TextInputType.emailAddress,
                decoration: InputDecoration(
                  hintText: 'Enter UPI ID (e.g., username@paytm)',
                  hintStyle: GoogleFonts.poppins(
                    color: Colors.grey[500],
                    fontSize: 14,
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: Colors.grey[300]!),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: Colors.grey[300]!),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(color: Color(0xFF00D4AA)),
                  ),
                  contentPadding: const EdgeInsets.all(16),
                ),
              ),
              
              const SizedBox(height: 20),
              
              // Display Name Input
              Text(
                'Display Name',
                style: GoogleFonts.poppins(
                  color: Colors.black,
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 8),
              TextFormField(
                controller: _nameController,
                decoration: InputDecoration(
                  hintText: 'Enter display name (e.g., My Paytm)',
                  hintStyle: GoogleFonts.poppins(
                    color: Colors.grey[500],
                    fontSize: 14,
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: Colors.grey[300]!),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: Colors.grey[300]!),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(color: Color(0xFF00D4AA)),
                  ),
                  contentPadding: const EdgeInsets.all(16),
                ),
              ),
              
              const SizedBox(height: 30),
              
              // Info text
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.blue[50],
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.blue[200]!),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.info_outline,
                      color: Colors.blue[600],
                      size: 20,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        'Make sure your UPI ID is correct. You can find it in your UPI app settings.',
                        style: GoogleFonts.poppins(
                          color: Colors.blue[700],
                          fontSize: 12,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              
              const Spacer(),
              
              // Add Button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _addUpiId,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF00D4AA),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    padding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                  child: _isLoading
                      ? const CircularProgressIndicator(
                          color: Colors.white,
                          strokeWidth: 2,
                        )
                      : Text(
                          'Add UPI ID',
                          style: GoogleFonts.poppins(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                ),
              ),
              
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  void _addUpiId() async {
    final upiId = _upiIdController.text.trim();
    final displayName = _nameController.text.trim();
    
    if (upiId.isEmpty) {
      _showSnackBar('Please enter a UPI ID', Colors.red);
      return;
    }
    
    if (displayName.isEmpty) {
      _showSnackBar('Please enter a display name', Colors.red);
      return;
    }
    
    // Basic UPI ID validation
    if (!_isValidUpiId(upiId)) {
      _showSnackBar('Please enter a valid UPI ID (e.g., username@paytm)', Colors.red);
      return;
    }
    
    setState(() {
      _isLoading = true;
    });
    
    try {
      // Save UPI ID to shared preferences
      await _saveUpiId(upiId, displayName);
      
      if (mounted) {
        _showSnackBar('UPI ID added successfully!', Colors.green);
        
        // Navigate back with result
        Navigator.pop(context, {
          'upiId': upiId,
          'displayName': displayName,
        });
      }
      
    } catch (e) {
      if (mounted) {
        _showSnackBar('Error adding UPI ID: $e', Colors.red);
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }
  
  bool _isValidUpiId(String upiId) {
    // Basic validation for UPI ID format
    final upiRegex = RegExp(r'^[a-zA-Z0-9.\-_]+@[a-zA-Z0-9.\-_]+$');
    return upiRegex.hasMatch(upiId);
  }
  
  Future<void> _saveUpiId(String upiId, String displayName) async {
    final prefs = await SharedPreferences.getInstance();
    
    // Get existing UPI IDs
    final existingUpiIds = await _getStoredUpiIds();
    
    // Check if UPI ID already exists
    if (existingUpiIds.any((item) => item['upiId'] == upiId)) {
      throw Exception('This UPI ID already exists');
    }
    
    // Add new UPI ID
    existingUpiIds.add({
      'upiId': upiId,
      'displayName': displayName,
      'addedAt': DateTime.now().toIso8601String(),
    });
    
    // Save back to shared preferences
    await prefs.setString('custom_upi_ids', json.encode(existingUpiIds));
  }
  
  Future<List<Map<String, dynamic>>> _getStoredUpiIds() async {
    final prefs = await SharedPreferences.getInstance();
    final storedData = prefs.getString('custom_upi_ids');
    
    if (storedData == null) {
      return [];
    }
    
    try {
      final List<dynamic> decoded = json.decode(storedData);
      return decoded.cast<Map<String, dynamic>>();
    } catch (e) {
      return [];
    }
  }
  
  void _showSnackBar(String message, Color backgroundColor) {
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(message),
          backgroundColor: backgroundColor,
        ),
      );
    }
  }
}
