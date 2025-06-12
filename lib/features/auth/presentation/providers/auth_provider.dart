import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../../core/constants/app_constants.dart';

enum AuthStatus { initial, authenticated, unauthenticated, loading, error }

// Mock User class to replace Firebase User
class User {
  final String uid;
  final String? email;
  final String? displayName;
  final String? photoURL;
  final String? phoneNumber; // Added phoneNumber property
  
  User({required this.uid, this.email, this.displayName, this.photoURL, this.phoneNumber});
}

class AuthProvider extends ChangeNotifier {
  // Mock implementation since firebase_auth is commented out
  // ignore: unused_field
  final GoogleSignIn _googleSignIn = GoogleSignIn();
  
  User? _user;
  AuthStatus _status = AuthStatus.initial;
  String _errorMessage = '';
  String _selectedLanguage = AppConstants.english;
  bool _isAdmin = false;
  bool _hasSelectedLanguage = false;
  
  // Getters
  User? get user => _user;
  AuthStatus get status => _status;
  String get errorMessage => _errorMessage;
  String get selectedLanguage => _selectedLanguage;
  String get languageCode => _selectedLanguage; // Added for compatibility
  bool get isAdmin => _isAdmin;
  bool get isAuthenticated => _status == AuthStatus.authenticated;
  bool get hasSelectedLanguage => _hasSelectedLanguage;
  
  AuthProvider() {
    // Check if user is already logged in
    _checkCurrentUser();
    _loadLanguagePreference();
  }
  
  // Check if user is already logged in
  Future<void> _checkCurrentUser() async {
    _status = AuthStatus.loading;
    notifyListeners();
    
    try {
      // For demo purposes, create a mock user
      _user = User(
        uid: 'mock-uid-123',
        email: 'demo@example.com',
        displayName: 'Demo User',
        photoURL: null,
        phoneNumber: '+1234567890', // Added phone number
      );
      
      // Check if user is admin
      await _checkIfAdmin();
      _status = AuthStatus.authenticated;
      
      notifyListeners();
    } catch (e) {
      _status = AuthStatus.error;
      _errorMessage = e.toString();
      notifyListeners();
    }
  }
  
  // Sign in with email and password
  Future<bool> signInWithEmailAndPassword(String email, String password) async {
    _status = AuthStatus.loading;
    notifyListeners();
    
    try {
      // Mock authentication
      if (email == 'admin@beeman.com' && password == 'admin123') {
        _user = User(
          uid: 'admin-uid-123',
          email: email,
          displayName: 'Admin User',
          photoURL: null,
        );
        _isAdmin = true;
      } else if (email == 'user@beeman.com' && password == 'user123') {
        _user = User(
          uid: 'user-uid-123',
          email: email,
          displayName: 'Regular User',
          photoURL: null,
        );
        _isAdmin = false;
      } else {
        throw Exception('Invalid email or password');
      }
      
      _status = AuthStatus.authenticated;
      notifyListeners();
      return true;
    } catch (e) {
      _status = AuthStatus.error;
      _errorMessage = e.toString();
      notifyListeners();
      return false;
    }
  }
  
  // Sign in with Google
  Future<bool> signInWithGoogle() async {
    _status = AuthStatus.loading;
    notifyListeners();
    
    try {
      // Mock Google sign in
      _user = User(
        uid: 'google-uid-123',
        email: 'google@example.com',
        displayName: 'Google User',
        photoURL: null,
      );
      
      await _checkIfAdmin();
      _status = AuthStatus.authenticated;
      notifyListeners();
      return true;
    } catch (e) {
      _status = AuthStatus.error;
      _errorMessage = e.toString();
      notifyListeners();
      return false;
    }
  }
  
  // Sign out
  Future<void> signOut() async {
    _status = AuthStatus.loading;
    notifyListeners();
    
    try {
      // Mock sign out
      _user = null;
      _isAdmin = false;
      _status = AuthStatus.unauthenticated;
      notifyListeners();
    } catch (e) {
      _status = AuthStatus.error;
      _errorMessage = e.toString();
      notifyListeners();
    }
  }
  
  // Check if user is admin
  Future<void> _checkIfAdmin() async {
    // For demo purposes
    _isAdmin = _user?.email == 'admin@beeman.com';
  }
  
  // Set language preference
  Future<void> setLanguage(String languageCode) async {
    _selectedLanguage = languageCode;
    _hasSelectedLanguage = true;
    
    // Save language preference
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(AppConstants.languageKey, languageCode);
    await prefs.setBool('hasSelectedLanguage', true);
    
    notifyListeners();
  }
  
  // Load language preference
  Future<void> _loadLanguagePreference() async {
    final prefs = await SharedPreferences.getInstance();
    _selectedLanguage = prefs.getString(AppConstants.languageKey) ?? AppConstants.english;
    _hasSelectedLanguage = prefs.getBool('hasSelectedLanguage') ?? false;
    notifyListeners();
  }
}