import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class CustomUpiService {
  static const String _storageKey = 'custom_upi_ids';
  
  // Get all stored custom UPI IDs
  static Future<List<Map<String, dynamic>>> getCustomUpiIds() async {
    final prefs = await SharedPreferences.getInstance();
    final storedData = prefs.getString(_storageKey);
    
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
  
  // Add a new custom UPI ID
  static Future<void> addCustomUpiId(String upiId, String displayName) async {
    final prefs = await SharedPreferences.getInstance();
    final existingUpiIds = await getCustomUpiIds();
    
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
    await prefs.setString(_storageKey, json.encode(existingUpiIds));
  }
  
  // Remove a custom UPI ID
  static Future<void> removeCustomUpiId(String upiId) async {
    final prefs = await SharedPreferences.getInstance();
    final existingUpiIds = await getCustomUpiIds();
    
    // Remove the UPI ID
    existingUpiIds.removeWhere((item) => item['upiId'] == upiId);
    
    // Save back to shared preferences
    await prefs.setString(_storageKey, json.encode(existingUpiIds));
  }
  
  // Check if a UPI ID exists
  static Future<bool> upiIdExists(String upiId) async {
    final existingUpiIds = await getCustomUpiIds();
    return existingUpiIds.any((item) => item['upiId'] == upiId);
  }
  
  // Get display name for a UPI ID
  static Future<String?> getDisplayName(String upiId) async {
    final existingUpiIds = await getCustomUpiIds();
    final upiData = existingUpiIds.firstWhere(
      (item) => item['upiId'] == upiId,
      orElse: () => {},
    );
    return upiData['displayName'];
  }
  
  // Get UPI app icon based on UPI ID domain
  static String getUpiAppIcon(String upiId) {
    final domain = upiId.split('@').last.toLowerCase();
    
    switch (domain) {
      case 'paytm':
      case 'ptm':
        return 'assets/images/logo.png'; // Use logo for Paytm for now
      case 'ybl':
      case 'yahoobiz':
        return 'assets/images/phonepe.png';
      case 'okaxis':
      case 'axis':
        return 'assets/images/googlepay.png';
      case 'ibl':
      case 'icici':
        return 'assets/images/logo.png';
      case 'hdfcbank':
      case 'hdfc':
        return 'assets/images/logo.png';
      case 'sbi':
        return 'assets/images/logo.png';
      case 'amazonpay':
      case 'apl':
        return 'assets/images/amazonpay.png'; // Use Amazon Pay icon
      default:
        return 'assets/images/logo.png'; // Default icon
    }
  }
  
  // Get UPI app name based on UPI ID domain
  static String getUpiAppName(String upiId) {
    final domain = upiId.split('@').last.toLowerCase();
    
    switch (domain) {
      case 'paytm':
      case 'ptm':
        return 'Paytm';
      case 'ybl':
      case 'yahoobiz':
        return 'PhonePe';
      case 'okaxis':
      case 'axis':
        return 'Google Pay';
      case 'ibl':
      case 'icici':
        return 'ICICI Bank';
      case 'hdfcbank':
      case 'hdfc':
        return 'HDFC Bank';
      case 'sbi':
        return 'SBI';
      case 'amazonpay':
      case 'apl':
        return 'Amazon Pay';
      default:
        return 'UPI App';
    }
  }
  
  // Get package name for launching specific UPI app
  static String getUpiAppPackage(String upiId) {
    final domain = upiId.split('@').last.toLowerCase();
    
    switch (domain) {
      case 'paytm':
      case 'ptm':
        return 'net.one97.paytm';
      case 'ybl':
      case 'yahoobiz':
        return 'com.phonepe.app';
      case 'okaxis':
      case 'axis':
        return 'com.google.android.apps.nbu.paisa.user';
      case 'amazonpay':
      case 'apl':
        return 'in.amazon.mShop.android.shopping';
      default:
        return 'in.org.npci.upiapp'; // BHIM UPI as fallback
    }
  }
}
