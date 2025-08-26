import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/user_model.dart';
import '../services/api_service.dart';

class AuthProvider extends ChangeNotifier {
  final ApiService _apiService = ApiService.instance;

  User? _user;
  String? _token;
  bool _isLoading = false;
  String? _error;
  bool _isInitialized = false;
  bool _isAuthenticating = false; // Add this flag to prevent router interference
  bool _isFirstTimeUser = false; // Track if this is a first-time user - default to false (returning user)

  // Getters
  User? get user => _user;
  String? get token => _token;
  bool get isLoading => _isLoading;
  String? get error => _error;
  bool get isAuthenticated => _token != null && _user != null;
  bool get isInitialized => _isInitialized;
  bool get isAuthenticating => _isAuthenticating;
  bool get isFirstTimeUser => _isFirstTimeUser;

  // Clear error
  void clearError() {
    _error = null;
    notifyListeners();
  }

  // Login
  Future<bool> login(String email, String password) async {
    _isLoading = true;
    _isAuthenticating = true; // Set authentication flag
    _error = null;
    notifyListeners();

    try {
      print('Starting login process...');
      final response = await _apiService.login(email, password);
      
      _token = response['token'];
      _user = User.fromJson(response['user']);
      
      print('Login successful, user: ${_user?.name}, type: ${_user?.userType}');
      
      // Save to preferences
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('auth_token', _token!);
      await prefs.setString('user_email', _user!.email);
      
      print('Auth state updated: isAuthenticated=$isAuthenticated');
      
      // Set loading false but keep authenticating true briefly to prevent router flash
      _isLoading = false;
      notifyListeners();
      
      // Wait longer to ensure smooth transition and prevent onboarding flash
      await Future.delayed(const Duration(milliseconds: 500));
      
      // Clear authentication flag to allow router to redirect
      _isAuthenticating = false;
      notifyListeners();
      
      print('Login completed successfully');
      return true;
    } catch (e) {
      print('Login failed: $e');
      _error = e.toString().replaceAll('Exception: ', '');
      _isLoading = false;
      _isAuthenticating = false; // Clear authentication flag
      notifyListeners();
      return false;
    }
  }

  // Signup
  Future<bool> signup(
    String name,
    String email,
    String password,
    String userType,
  ) async {
    _isLoading = true;
    _isAuthenticating = true; // Set authentication flag
    _error = null;
    notifyListeners();

    try {
      print('Starting signup process...');
      final response = await _apiService.signup(
        name,
        email,
        password,
        userType,
      );
      
      _token = response['token'];
      _user = User.fromJson(response['user']);
      
      print('Signup successful, user: ${_user?.name}, type: ${_user?.userType}');
      
      // Save to preferences
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('auth_token', _token!);
      await prefs.setString('user_email', _user!.email);
      
      print('Auth state updated before notifyListeners: isAuthenticated=$isAuthenticated');
      
      // Set loading false but keep authenticating true briefly to prevent router flash
      _isLoading = false;
      notifyListeners();
      
      // Wait longer to ensure smooth transition and prevent onboarding flash
      await Future.delayed(const Duration(milliseconds: 500));
      
      // Clear authentication flag to allow router to redirect
      _isAuthenticating = false;
      notifyListeners();
      
      print('Signup completed successfully, isAuthenticated: $isAuthenticated');
      return true;
    } catch (e) {
      print('Signup failed: $e');
      _error = e.toString().replaceAll('Exception: ', '');
      _isLoading = false;
      _isAuthenticating = false; // Clear authentication flag
      notifyListeners();
      return false;
    }
  }

  // Logout
  Future<void> logout() async {
    try {
      print('Starting logout process...');
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove('auth_token');
      await prefs.remove('user_email');
      
      // Ensure user is marked as NOT first-time after logout
      await prefs.setBool('has_opened_before', true);
      print('Cleared shared preferences');
    } catch (e) {
      print('Error clearing preferences: $e');
    }
    
    _user = null;
    _token = null;
    _error = null;
    _isFirstTimeUser = false; // Explicitly set to false - user is no longer first-time after logout
    print('Cleared auth state - isAuthenticated: $isAuthenticated, isFirstTimeUser: $_isFirstTimeUser');
    notifyListeners();
    
    // Small delay to ensure state is updated and router properly redirects
    await Future.delayed(const Duration(milliseconds: 200));
    print('Logout completed');
  }

  // Get user profile
  Future<void> getUserProfile() async {
    if (!isAuthenticated) return;
    
    try {
      final response = await _apiService.getProfile();
      _user = User.fromJson(response);
      notifyListeners();
    } catch (e) {
      print('Error getting user profile: $e');
      // If getting profile fails, it might mean the token is invalid
      if (e.toString().contains('401') || e.toString().contains('Unauthorized')) {
        await logout();
      } else {
        _error = e.toString();
        notifyListeners();
      }
    }
  }

  // Update user profile
  Future<bool> updateUserProfile(Map<String, dynamic> data) async {
    if (!isAuthenticated) return false;
    
    _isLoading = true;
    _error = null;
    notifyListeners();
    
    try {
      final response = await _apiService.updateProfile(data);
      _user = User.fromJson(response);
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  // Initialize auth state (for app startup)
  Future<void> initializeAuth() async {
    if (_isInitialized) return;
    
    try {
      print('Initializing auth state...');
      final prefs = await SharedPreferences.getInstance();
      
      // Check if user has opened the app before - this determines first-time vs returning user
      final hasOpenedBefore = prefs.getBool('has_opened_before') ?? false;
      _isFirstTimeUser = !hasOpenedBefore;
      
      print('First time user check: hasOpenedBefore=$hasOpenedBefore, isFirstTimeUser=$_isFirstTimeUser');
      
      if (!hasOpenedBefore) {
        // Mark that the user has opened the app for the first time
        await prefs.setBool('has_opened_before', true);
        print('Marked user as having opened the app before');
      }
      
      final token = prefs.getString('auth_token');
      
      if (token != null) {
        print('Found existing token, verifying...');
        _token = token;
        
        try {
          // Add timeout for the profile verification
          final response = await Future.any([
            _apiService.getProfile(),
            Future.delayed(const Duration(seconds: 8), () => throw Exception('Profile verification timeout'))
          ]);
          _user = User.fromJson(response);
          print('Auth state initialized successfully for user: ${_user?.name}');
        } catch (e) {
          print('Token verification failed: $e');
          // Token is invalid or backend unreachable, clear it
          _user = null;
          _token = null;
          await prefs.remove('auth_token');
          await prefs.remove('user_email');
        }
      } else {
        print('No existing token found');
      }
    } catch (e) {
      print('Error initializing auth state: $e');
      // Clear any invalid state
      _user = null;
      _token = null;
    } finally {
      _isInitialized = true;
      print('Auth initialization complete: isFirstTimeUser=$_isFirstTimeUser, isAuthenticated=$isAuthenticated');
      notifyListeners();
    }
  }

  // Reset auth state (useful for testing or forced logout)
  Future<void> resetAuthState() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.clear();
    } catch (e) {
      print('Error clearing preferences: $e');
    }
    
    _user = null;
    _token = null;
    _error = null;
    _isInitialized = false;
    _isFirstTimeUser = true; // Reset to first-time user
    notifyListeners();
  }
}