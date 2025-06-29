import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:firebase_auth/firebase_auth.dart' as fb_auth;
import 'package:flutter/foundation.dart';

import '../../../../core/constants/app_constants.dart';
import '../../../../core/services/firestore_service.dart';
import '../../../../core/models/firestore_models.dart';

enum AuthStatus { initial, authenticated, unauthenticated, loading, error }

class AuthProvider extends ChangeNotifier {
  final fb_auth.FirebaseAuth _firebaseAuth;
  final GoogleSignIn _googleSignIn = GoogleSignIn();

  fb_auth.User? _user;
  AuthStatus _status = AuthStatus.initial;
  String _errorMessage = '';
  String _selectedLanguage = AppConstants.english;
  bool _isAdmin = false;
  bool _hasSelectedLanguage = false;
  
  // User data from Firestore
  UserModel? _userData;
  
  // Getters
  fb_auth.User? get user => _user;
  AuthStatus get status => _status;
  String get errorMessage => _errorMessage;
  String get selectedLanguage => _selectedLanguage;
  String get languageCode => _selectedLanguage; // Added for compatibility
  bool get isAdmin => _isAdmin;
  bool get isAuthenticated => _status == AuthStatus.authenticated;
  bool get hasSelectedLanguage => _hasSelectedLanguage;
  UserModel? get userData => _userData;
  
  AuthProvider({fb_auth.FirebaseAuth? firebaseAuth})
      : _firebaseAuth = firebaseAuth ?? fb_auth.FirebaseAuth.instance {
    _loadLanguagePreference();
    _firebaseAuth.authStateChanges().listen(_onAuthStateChanged);
  }
  
  Future<void> _onAuthStateChanged(fb_auth.User? user) async {
    if (user == null) {
      _user = null;
      _userData = null;
      _isAdmin = false;
      _status = AuthStatus.unauthenticated;
    } else {
      _user = user;
      await _loadUserData();
      await _checkIfAdmin();
      _status = AuthStatus.authenticated;
    }
    notifyListeners();
  }

  // Load user data from Firestore
  Future<void> _loadUserData() async {
    if (_user == null) return;
    
    try {
      final userData = await FirestoreService.getUser(_user!.uid);
      if (userData != null) {
        _userData = UserModel.fromFirestore(
          await FirestoreService.usersCollection.doc(_user!.uid).get(),
        );
      }
    } catch (e) {
      print('Error loading user data: $e');
    }
  }

  // Create user in Firestore after successful authentication
  Future<void> _createUserInFirestore() async {
    if (_user == null) return;
    
    try {
      // Check if user already exists in Firestore
      final existingUser = await FirestoreService.getUser(_user!.uid);
      if (existingUser == null) {
        // Create new user in Firestore
        await FirestoreService.createUser(
          uid: _user!.uid,
          email: _user!.email ?? '',
          name: _user!.displayName ?? 'User',
          phone: _user!.phoneNumber,
          userType: 'customer',
        );
        
        // Reload user data
        await _loadUserData();
      }
    } catch (e) {
      print('Error creating user in Firestore: $e');
    }
  }

  // Update user data in Firestore
  Future<void> updateUserData({
    String? name,
    String? phone,
    String? address,
  }) async {
    if (_user == null) return;
    
    try {
      final updateData = <String, dynamic>{};
      if (name != null) updateData['name'] = name;
      if (phone != null) updateData['phone'] = phone;
      if (address != null) updateData['address'] = address;
      
      await FirestoreService.updateUser(_user!.uid, updateData);
      await _loadUserData(); // Reload user data
      notifyListeners();
    } catch (e) {
      print('Error updating user data: $e');
      rethrow;
    }
  }
  
  // Check if user is already logged in (will be handled by authStateChanges)
  Future<void> _checkCurrentUser() async {
    // This method is now largely redundant due to the authStateChanges listener,
    // but can be kept for initial sync if needed.
    final currentUser = _firebaseAuth.currentUser;
    await _onAuthStateChanged(currentUser);
  }
  
  // Sign in with email and password
  Future<bool> signInWithEmailAndPassword(String email, String password) async {
    _status = AuthStatus.loading;
    notifyListeners();
    
    try {
      final userCredential = await _firebaseAuth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      _user = userCredential.user;
      await _createUserInFirestore();
      await _checkIfAdmin();
      _status = AuthStatus.authenticated;
      notifyListeners();
      return true;
    } on fb_auth.FirebaseAuthException catch (e) {
      _status = AuthStatus.error;
      _errorMessage = e.message ?? 'An unknown error occurred.';
      notifyListeners();
      return false;
    }
  }
  
  // Sign in with Google
  Future<bool> signInWithGoogle() async {
    print('signInWithGoogle called'); // Debug print
    _status = AuthStatus.loading;
    notifyListeners();

    try {
      if (kIsWeb) {
        print('Running on web'); // Debug print
        // Use interactive sign-in for web (FedCM compatible)
        final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
        print('googleUser (web): ' + googleUser.toString()); // Debug print
        if (googleUser != null) {
          final GoogleSignInAuthentication googleAuth = await googleUser.authentication;
          final fb_auth.OAuthCredential credential = fb_auth.GoogleAuthProvider.credential(
            accessToken: googleAuth.accessToken,
            idToken: googleAuth.idToken,
          );
          final fb_auth.UserCredential userCredential =
              await _firebaseAuth.signInWithCredential(credential);
          _user = userCredential.user;
          print('Firebase user (web): ' + _user.toString()); // Debug print
          if (_user != null) {
            await _createUserInFirestore();
            await _checkIfAdmin();
            _status = AuthStatus.authenticated;
            notifyListeners();
            return true;
          }
          _status = AuthStatus.unauthenticated;
          notifyListeners();
          return false;
        } else {
          print('No Google user found (web)'); // Debug print
          _status = AuthStatus.unauthenticated;
          notifyListeners();
          return false;
        }
      } else {
        print('Running on mobile/desktop'); // Debug print
        final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
        print('googleUser (mobile): ' + googleUser.toString()); // Debug print
        if (googleUser == null) {
          print('User cancelled Google sign-in'); // Debug print
          _status = AuthStatus.unauthenticated;
          notifyListeners();
          return false; // User cancelled the sign-in
        }
        final GoogleSignInAuthentication googleAuth = await googleUser.authentication;
        final fb_auth.OAuthCredential credential = fb_auth.GoogleAuthProvider.credential(
          accessToken: googleAuth.accessToken,
          idToken: googleAuth.idToken,
        );
        final fb_auth.UserCredential userCredential =
            await _firebaseAuth.signInWithCredential(credential);
        _user = userCredential.user;
        print('Firebase user (mobile): ' + _user.toString()); // Debug print
        if (_user != null) {
          await _createUserInFirestore();
          await _checkIfAdmin();
          _status = AuthStatus.authenticated;
          notifyListeners();
          return true;
        }
        print('Google sign-in failed, user is null (mobile)'); // Debug print
        return false;
      }
    } catch (e) {
      print('Error in signInWithGoogle: ' + e.toString()); // Debug print
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
      await _googleSignIn.signOut();
      await _firebaseAuth.signOut();
      _user = null;
      _userData = null;
      _isAdmin = false;
      _status = AuthStatus.unauthenticated;
      notifyListeners();
    } catch (e) {
      _status = AuthStatus.error;
      _errorMessage = e.toString();
      notifyListeners();
    }
  }
  
  // Check if user is admin using Firestore
  Future<void> _checkIfAdmin() async {
    if (_user == null) {
      _isAdmin = false;
      return;
    }
    
    try {
      _isAdmin = await FirestoreService.isAdmin(_user!.uid);
    } catch (e) {
      print('Error checking admin status: $e');
      _isAdmin = false;
    }
  }
  
  // Admin-specific authentication method
  Future<bool> signInAsAdmin(String email, String password) async {
    _status = AuthStatus.loading;
    notifyListeners();
    
    try {
      // Hardcoded admin credentials
      const String adminEmail = 'admin@beeman.com';
      const String adminPassword = 'admin123';
      
      // Check if credentials match
      if (email == adminEmail && password == adminPassword) {
        // Create a mock user for admin
        _isAdmin = true;
        _status = AuthStatus.authenticated;
        notifyListeners();
        return true;
      } else {
        _status = AuthStatus.error;
        _errorMessage = 'Invalid admin credentials';
        notifyListeners();
        return false;
      }
    } catch (e) {
      _status = AuthStatus.error;
      _errorMessage = e.toString();
      notifyListeners();
      return false;
    }
  }

  // Register new user with email and password
  Future<bool> registerWithEmailAndPassword({
    required String email,
    required String password,
    required String name,
    String? phone,
    String? address,
  }) async {
    _status = AuthStatus.loading;
    notifyListeners();
    
    try {
      final userCredential = await _firebaseAuth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      
      _user = userCredential.user;
      
      if (_user != null) {
        // Create user in Firestore
        await FirestoreService.createUser(
          uid: _user!.uid,
          email: email,
          name: name,
          phone: phone,
          address: address,
          userType: 'customer',
        );
        
        await _loadUserData();
        await _checkIfAdmin();
        _status = AuthStatus.authenticated;
        notifyListeners();
        return true;
      }
      
      _status = AuthStatus.error;
      _errorMessage = 'Failed to create user';
      notifyListeners();
      return false;
    } on fb_auth.FirebaseAuthException catch (e) {
      _status = AuthStatus.error;
      _errorMessage = e.message ?? 'An unknown error occurred.';
      notifyListeners();
      return false;
    }
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

  // Phone sign-in with OTP (real Firebase logic)
  Future<void> signInWithPhone(BuildContext context) async {
    String? phoneNumber = await showDialog(
      context: context,
      builder: (context) => const PhoneNumberDialog(),
    );
    if (phoneNumber == null || phoneNumber.isEmpty) return;

    fb_auth.FirebaseAuth auth = fb_auth.FirebaseAuth.instance;

    await auth.verifyPhoneNumber(
      phoneNumber: phoneNumber,
      verificationCompleted: (fb_auth.PhoneAuthCredential credential) async {
        await auth.signInWithCredential(credential);
        // Auth state change will be picked up by the listener
      },
      verificationFailed: (fb_auth.FirebaseAuthException e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Verification failed: ${e.message}')),
        );
      },
      codeSent: (String verificationId, int? resendToken) async {
        String? smsCode = await showDialog(
          context: context,
          builder: (context) => const OTPDialog(),
        );
        if (smsCode == null || smsCode.isEmpty) return;

        fb_auth.PhoneAuthCredential credential = fb_auth.PhoneAuthProvider.credential(
          verificationId: verificationId,
          smsCode: smsCode,
        );
        await auth.signInWithCredential(credential);
        // Auth state change will be picked up by the listener
      },
      codeAutoRetrievalTimeout: (String verificationId) {},
    );
  }
}

// Dialog for entering phone number
class PhoneNumberDialog extends StatefulWidget {
  const PhoneNumberDialog({Key? key}) : super(key: key);

  @override
  State<PhoneNumberDialog> createState() => _PhoneNumberDialogState();
}

class _PhoneNumberDialogState extends State<PhoneNumberDialog> {
  final TextEditingController _controller = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Enter Phone Number'),
      content: TextField(
        controller: _controller,
        keyboardType: TextInputType.phone,
        decoration: const InputDecoration(
          labelText: 'Phone Number',
          hintText: '+91XXXXXXXXXX',
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(_controller.text),
          child: const Text('Continue'),
        ),
      ],
    );
  }
}

// Dialog for entering OTP
class OTPDialog extends StatefulWidget {
  const OTPDialog({Key? key}) : super(key: key);

  @override
  State<OTPDialog> createState() => _OTPDialogState();
}

class _OTPDialogState extends State<OTPDialog> {
  final TextEditingController _controller = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Enter OTP'),
      content: TextField(
        controller: _controller,
        keyboardType: TextInputType.number,
        decoration: const InputDecoration(
          labelText: 'OTP',
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(_controller.text),
          child: const Text('Verify'),
        ),
      ],
    );
  }
}