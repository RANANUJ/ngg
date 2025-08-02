import 'package:dio/dio.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ApiService {
  static const String baseUrl = 'http://192.168.0.110:5000/api';
  late Dio _dio;

  ApiService() {
    _dio = Dio(
      BaseOptions(
        baseUrl: baseUrl,
        connectTimeout: const Duration(seconds: 30),
        receiveTimeout: const Duration(seconds: 30),
      ),
    );

    _dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) async {
          // Add auth token if available
          final prefs = await SharedPreferences.getInstance();
          final token = prefs.getString('auth_token');
          if (token != null) {
            options.headers['Authorization'] = 'Bearer $token';
          }
          handler.next(options);
        },
        onError: (error, handler) {
          print('API Error: ${error.message}');
          handler.next(error);
        },
      ),
    );
  }

  // Auth methods
  Future<Map<String, dynamic>> login(String email, String password) async {
    try {
      final response = await _dio.post(
        '/auth/login',
        data: {'email': email, 'password': password},
      );
      return response.data;
    } catch (e) {
      rethrow;
    }
  }

  Future<Map<String, dynamic>> signup(
    String name,
    String email,
    String password,
    String userType,
  ) async {
    try {
      final response = await _dio.post(
        '/auth/signup',
        data: {
          'name': name,
          'email': email,
          'password': password,
          'user_type': userType,
        },
      );
      return response.data;
    } catch (e) {
      rethrow;
    }
  }

  Future<Map<String, dynamic>> getProfile() async {
    try {
      final response = await _dio.get('/auth/profile');
      return response.data;
    } catch (e) {
      rethrow;
    }
  }

  Future<Map<String, dynamic>> updateProfile(Map<String, dynamic> data) async {
    try {
      final response = await _dio.put('/auth/profile', data: data);
      return response.data;
    } catch (e) {
      rethrow;
    }
  }

  // Fundraising Campaign methods
  Future<Map<String, dynamic>> createCampaign(Map<String, dynamic> data) async {
    try {
      final response = await _dio.post('/campaigns', data: data);
      return response.data;
    } catch (e) {
      rethrow;
    }
  }

  Future<List<Map<String, dynamic>>> getUserCampaigns() async {
    try {
      final response = await _dio.get('/campaigns');
      return List<Map<String, dynamic>>.from(response.data);
    } catch (e) {
      rethrow;
    }
  }

  Future<List<Map<String, dynamic>>> getAllCampaigns() async {
    try {
      final response = await _dio.get('/campaigns/all');
      return List<Map<String, dynamic>>.from(response.data);
    } catch (e) {
      rethrow;
    }
  }

  Future<Map<String, dynamic>> getCampaign(String campaignId) async {
    try {
      final response = await _dio.get('/campaigns/$campaignId');
      return response.data;
    } catch (e) {
      rethrow;
    }
  }

  Future<Map<String, dynamic>> updateCampaign(
    String campaignId,
    Map<String, dynamic> data,
  ) async {
    try {
      final response = await _dio.put('/campaigns/$campaignId', data: data);
      return response.data;
    } catch (e) {
      rethrow;
    }
  }

  Future<void> deleteCampaign(String campaignId) async {
    try {
      await _dio.delete('/campaigns/$campaignId');
    } catch (e) {
      rethrow;
    }
  }

  // Donation Request methods
  Future<Map<String, dynamic>> createDonationRequest(
    Map<String, dynamic> data,
  ) async {
    try {
      final response = await _dio.post('/donation-requests', data: data);
      return response.data;
    } catch (e) {
      rethrow;
    }
  }

  Future<List<Map<String, dynamic>>> getUserDonationRequests() async {
    try {
      final response = await _dio.get('/donation-requests');
      return List<Map<String, dynamic>>.from(response.data);
    } catch (e) {
      rethrow;
    }
  }

  Future<List<Map<String, dynamic>>> getAllDonationRequests() async {
    try {
      final response = await _dio.get('/donation-requests/all');
      return List<Map<String, dynamic>>.from(response.data);
    } catch (e) {
      rethrow;
    }
  }

  Future<Map<String, dynamic>> getDonationRequest(String requestId) async {
    try {
      final response = await _dio.get('/donation-requests/$requestId');
      return response.data;
    } catch (e) {
      rethrow;
    }
  }

  Future<Map<String, dynamic>> updateDonationRequest(
    String requestId,
    Map<String, dynamic> data,
  ) async {
    try {
      final response = await _dio.put(
        '/donation-requests/$requestId',
        data: data,
      );
      return response.data;
    } catch (e) {
      rethrow;
    }
  }

  Future<void> deleteDonationRequest(String requestId) async {
    try {
      await _dio.delete('/donation-requests/$requestId');
    } catch (e) {
      rethrow;
    }
  }

  // Helper method to handle errors
  String getErrorMessage(dynamic error) {
    if (error is DioException) {
      if (error.response?.data is Map<String, dynamic>) {
        return error.response?.data['error'] ?? 'An error occurred';
      }
      return error.message ?? 'Network error';
    }
    return error.toString();
  }
}
