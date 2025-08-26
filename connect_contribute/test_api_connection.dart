import 'package:flutter/material.dart';
import 'lib/services/api_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  print('🚀 Testing NGG API Connection...');
  print('=====================================');
  
  try {
    // Test API connection
    final isConnected = await ApiService.instance.testApiConnection();
    print('API Connection Test: ${isConnected ? "✅ SUCCESS" : "❌ FAILED"}');
    
    if (isConnected) {
      print('API Base URL: ${ApiService.baseUrl}');
      
      // Test get all campaigns (public endpoint)
      try {
        final campaigns = await ApiService.instance.getAllCampaigns();
        print('Get All Campaigns: ✅ SUCCESS (${campaigns.length} campaigns found)');
        
        if (campaigns.isNotEmpty) {
          print('Sample campaign: ${campaigns.first['title']}');
        }
      } catch (e) {
        print('Get All Campaigns: ❌ FAILED - $e');
      }
      
      // Test get all donation requests (public endpoint)
      try {
        final requests = await ApiService.instance.getAllDonationRequests();
        print('Get All Donation Requests: ✅ SUCCESS (${requests.length} requests found)');
        
        if (requests.isNotEmpty) {
          print('Sample request: ${requests.first['title']}');
        }
      } catch (e) {
        print('Get All Donation Requests: ❌ FAILED - $e');
      }
    }
  } catch (e) {
    print('API Connection Test: ❌ FAILED - $e');
  }
  
  print('=====================================');
  print('Test completed. Check results above.');
}
