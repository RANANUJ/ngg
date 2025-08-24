import 'package:dio/dio.dart';

class NetworkDiagnostics {
  static Future<void> performDiagnostics() async {
    print('\n=== NETWORK DIAGNOSTICS ===');
    
    // Test URLs that should be accessible
    final testUrls = [
      'http://192.168.0.136:5000/api/health',
      'http://10.0.2.2:5000/api/health',
      'http://localhost:5000/api/health',
    ];
    
    for (String url in testUrls) {
      print('\nTesting: $url');
      await _testUrl(url);
    }
    
    print('\n=== END DIAGNOSTICS ===\n');
  }
  
  static Future<void> _testUrl(String url) async {
    try {
      final dio = Dio(BaseOptions(
        connectTimeout: const Duration(seconds: 5),
        receiveTimeout: const Duration(seconds: 5),
      ));
      
      final response = await dio.get(url);
      
      if (response.statusCode == 200) {
        print('✅ SUCCESS: Connected to $url');
        print('   Response: ${response.data}');
      } else {
        print('❌ FAILED: $url returned status ${response.statusCode}');
      }
    } catch (e) {
      print('❌ ERROR: Failed to connect to $url');
      print('   Error: $e');
      
      if (e is DioException) {
        switch (e.type) {
          case DioExceptionType.connectionTimeout:
            print('   Reason: Connection timeout - server may be unreachable');
            break;
          case DioExceptionType.connectionError:
            print('   Reason: Connection error - check network/firewall');
            break;
          case DioExceptionType.receiveTimeout:
            print('   Reason: Receive timeout - server not responding');
            break;
          default:
            print('   Reason: ${e.type}');
        }
      }
    }
  }
}
