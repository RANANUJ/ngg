import 'dart:io' show Platform;
import 'package:flutter/foundation.dart';
import 'package:dio/dio.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ApiService {
  // Determines the base URL depending on platform or a compile-time override
  static String get baseUrl {
    const String override = String.fromEnvironment('API_BASE_URL', defaultValue: '');
    if (override.isNotEmpty) {
      return override;
    }
    if (kIsWeb) {
      return 'http://127.0.0.1:5000/api';
    }
    // Android emulator uses 10.0.2.2 to reach the host machine
    try {
      if (Platform.isAndroid) {
        return 'http://10.0.2.2:5000/api';
      }
    } catch (_) {}
    // Windows/macOS/Linux desktops and iOS simulator default to localhost
    return 'http://127.0.0.1:5000/api';
  }
  static ApiService? _instance;
  late Dio _dio;
  bool _isReconnecting = false;
  int _retryCount = 0;
  static const int maxRetries = 5;

  ApiService._internal() {
    _initializeDio();
  }

  static ApiService get instance {
    _instance ??= ApiService._internal();
    return _instance!;
  }

  void _initializeDio() {
    _dio = Dio(
      BaseOptions(
        baseUrl: baseUrl,
        connectTimeout: const Duration(seconds: 15),
        receiveTimeout: const Duration(seconds: 30),
        sendTimeout: const Duration(seconds: 30),
        validateStatus: (status) {
          return status != null && status < 500;
        },
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
      ),
    );

    _dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) async {
          try {
            // Add auth token if available
            final prefs = await SharedPreferences.getInstance();
            final token = prefs.getString('auth_token');
            if (token != null) {
              options.headers['Authorization'] = 'Bearer $token';
            }
            handler.next(options);
          } catch (e) {
            print('Error in request interceptor: $e');
            handler.next(options);
          }
        },
        onError: (error, handler) async {
          print('API Error: ${error.message}');
          print('API Error Type: ${error.type}');
          
          // Handle connection errors during hot reload
          if ((error.type == DioExceptionType.connectionError ||
               error.type == DioExceptionType.connectionTimeout ||
               error.type == DioExceptionType.receiveTimeout) && 
              !_isReconnecting) {
            print('Connection error detected, attempting to reconnect...');
            await _attemptReconnection();
          }
          
          handler.next(error);
        },
      ),
    );
  }

  // Method to handle hot reload
  void handleHotReload() {
    print('Hot reload detected, reinitializing Dio...');
    _isReconnecting = false;
    _retryCount = 0;
    _initializeDio();
  }

  // Method to attempt reconnection
  Future<void> _attemptReconnection() async {
    if (_isReconnecting) return;
    
    _isReconnecting = true;
    try {
      print('Attempting to reinitialize Dio...');
      _initializeDio();
      
      // Test the connection with a simple endpoint
      await _dio.get('/health', options: Options(
        sendTimeout: const Duration(seconds: 5),
        receiveTimeout: const Duration(seconds: 5),
      ));
      print('Reconnection successful');
    } catch (e) {
      print('Reconnection failed: $e');
      // If health check fails, try the root endpoint
      try {
        await _dio.get('/', options: Options(
          sendTimeout: const Duration(seconds: 5),
          receiveTimeout: const Duration(seconds: 5),
        ));
        print('Reconnection successful with root endpoint');
      } catch (e2) {
        print('Reconnection failed with root endpoint: $e2');
      }
    } finally {
      _isReconnecting = false;
    }
  }

  // Method to reinitialize Dio if needed
  void reinitializeDio() {
    _initializeDio();
  }

  // Method to check if backend is reachable
  Future<bool> isBackendReachable() async {
    try {
      await _dio.get('/health', options: Options(
        sendTimeout: const Duration(seconds: 5),
        receiveTimeout: const Duration(seconds: 5),
      ));
      return true;
    } catch (e) {
      print('Backend not reachable: $e');
      // Try root endpoint as fallback
      try {
        await _dio.get('/', options: Options(
          sendTimeout: const Duration(seconds: 5),
          receiveTimeout: const Duration(seconds: 5),
        ));
        return true;
      } catch (e2) {
        print('Backend not reachable with root endpoint: $e2');
        return false;
      }
    }
  }

  // Robust auth methods with enhanced retry logic
  Future<Map<String, dynamic>> login(String email, String password) async {
    _retryCount = 0;
    
    while (_retryCount < maxRetries) {
      try {
        print('Login attempt ${_retryCount + 1}');
        
        // Test connection first
        if (!await isBackendReachable()) {
          print('Backend not reachable, retrying...');
          _retryCount++;
          if (_retryCount >= maxRetries) {
            throw Exception('Server is not reachable. Please check your connection.');
          }
          await Future.delayed(Duration(seconds: _retryCount));
          continue;
        }

        final response = await _dio.post(
          '/auth/login',
          data: {'email': email, 'password': password},
          options: Options(
            sendTimeout: const Duration(seconds: 20),
            receiveTimeout: const Duration(seconds: 20),
          ),
        );
        
        print('Login successful');
        return response.data;
      } catch (e) {
        _retryCount++;
        print('Login attempt $_retryCount failed: $e');
        
        if (_retryCount >= maxRetries) {
          if (e is DioException) {
            if (e.response?.statusCode == 401) {
              throw Exception('Invalid email or password');
            } else if (e.response?.statusCode == 404) {
              throw Exception('User not found');
            } else if (e.type == DioExceptionType.connectionError ||
                       e.type == DioExceptionType.connectionTimeout) {
              throw Exception('Connection failed. Please check your internet connection.');
            } else {
              throw Exception('Login failed. Please try again.');
            }
          }
          throw Exception('Login failed after $_retryCount attempts');
        }
        
        // Wait before retry with exponential backoff
        await Future.delayed(Duration(seconds: _retryCount * 2));
        
        // Try to reconnect if it's a connection error
        if (e is DioException && 
            (e.type == DioExceptionType.connectionError ||
             e.type == DioExceptionType.connectionTimeout)) {
          await _attemptReconnection();
        }
      }
    }
    
    throw Exception('Login failed after $maxRetries attempts');
  }

  Future<Map<String, dynamic>> signup(
    String name,
    String email,
    String password,
    String userType,
  ) async {
    _retryCount = 0;
    
    while (_retryCount < maxRetries) {
      try {
        print('Signup attempt ${_retryCount + 1}');
        
        // Test connection first
        if (!await isBackendReachable()) {
          print('Backend not reachable, retrying...');
          _retryCount++;
          if (_retryCount >= maxRetries) {
            throw Exception('Server is not reachable. Please check your connection.');
          }
          await Future.delayed(Duration(seconds: _retryCount));
          continue;
        }

        final response = await _dio.post(
          '/auth/signup',
          data: {
            'name': name,
            'email': email,
            'password': password,
            'user_type': userType,
          },
          options: Options(
            sendTimeout: const Duration(seconds: 20),
            receiveTimeout: const Duration(seconds: 20),
          ),
        );
        
        print('Signup successful');
        return response.data;
      } catch (e) {
        _retryCount++;
        print('Signup attempt $_retryCount failed: $e');
        
        if (_retryCount >= maxRetries) {
          if (e is DioException) {
            if (e.response?.statusCode == 409) {
              throw Exception('Email already exists');
            } else if (e.response?.statusCode == 400) {
              throw Exception('Invalid data provided');
            } else if (e.type == DioExceptionType.connectionError ||
                       e.type == DioExceptionType.connectionTimeout) {
              throw Exception('Connection failed. Please check your internet connection.');
            } else {
              throw Exception('Signup failed. Please try again.');
            }
          }
          throw Exception('Signup failed after $_retryCount attempts');
        }
        
        // Wait before retry with exponential backoff
        await Future.delayed(Duration(seconds: _retryCount * 2));
        
        // Try to reconnect if it's a connection error
        if (e is DioException && 
            (e.type == DioExceptionType.connectionError ||
             e.type == DioExceptionType.connectionTimeout)) {
          await _attemptReconnection();
        }
      }
    }
    
    throw Exception('Signup failed after $maxRetries attempts');
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

  Future<Map<String, dynamic>> donateToCampaign({
    required String campaignId,
    required double amount,
  }) async {
    try {
      final response = await _dio.post(
        '/campaigns/$campaignId/donate',
        data: {'amount': amount},
        options: Options(
          sendTimeout: const Duration(seconds: 20),
          receiveTimeout: const Duration(seconds: 20),
        ),
      );
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

  // Test method to verify API service is working
  Future<bool> testApiConnection() async {
    try {
      final response = await _dio.get('/health');
      return response.statusCode == 200;
    } catch (e) {
      print('API connection test failed: $e');
      return false;
    }
  }
}
