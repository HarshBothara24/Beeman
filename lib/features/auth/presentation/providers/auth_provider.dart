import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:firebase_auth/firebase_auth.dart' as fb_auth;
import 'package:flutter/foundation.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import '../../../../core/constants/app_constants.dart';

enum AuthStatus { initial, authenticated, unauthenticated, loading, error, emailNotVerified }

class AuthProvider extends ChangeNotifier {
  final fb_auth.FirebaseAuth _firebaseAuth;
  final GoogleSignIn _googleSignIn = GoogleSignIn();

  fb_auth.User? _user;
  AuthStatus _status = AuthStatus.initial;
  String _errorMessage = '';
  String _selectedLanguage = AppConstants.english;
  bool _isAdmin = false;
  bool _hasSelectedLanguage = false;
  
  // Getters
  fb_auth.User? get user => _user;
  AuthStatus get status => _status;
  String get errorMessage => _errorMessage;
  String get selectedLanguage => _selectedLanguage;
  String get languageCode => _selectedLanguage; // Added for compatibility
  bool get isAdmin => _isAdmin;
  bool get isAuthenticated => _status == AuthStatus.authenticated;
  bool get hasSelectedLanguage => _hasSelectedLanguage;
  
  AuthProvider({fb_auth.FirebaseAuth? firebaseAuth})
      : _firebaseAuth = firebaseAuth ?? fb_auth.FirebaseAuth.instance {
    _loadLanguagePreference();
    _firebaseAuth.authStateChanges().listen(_onAuthStateChanged);
  }
  
  Future<void> _onAuthStateChanged(fb_auth.User? user) async {
    if (user == null) {
      _user = null;
      _isAdmin = false;
      _status = AuthStatus.unauthenticated;
    } else {
      _user = user;
      await _checkIfAdmin();
      _status = AuthStatus.authenticated;
    }
    notifyListeners();
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
      await _checkIfAdmin();
      const adminUid = 'jwXO9LX5g0eA387930lBQx4keie2';
      if (_user != null && !_user!.emailVerified && _user!.uid != adminUid) {
        await _user!.sendEmailVerification();
        _status = AuthStatus.emailNotVerified;
        _errorMessage = 'Please verify your email. A verification link has been sent.';
        notifyListeners();
        return false;
      }
      if (_user != null) {
        await _createUserInFirestore(_user!);
      }
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
  
  Future<bool> reloadAndCheckEmailVerified() async {
    if (_user == null) return false;
    await _user!.reload();
    _user = _firebaseAuth.currentUser;
    if (_user != null && _user!.emailVerified) {
      _status = AuthStatus.authenticated;
      notifyListeners();
      return true;
    }
    return false;
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
        print('googleUser (web): $googleUser'); // Debug print
        if (googleUser != null) {
          final GoogleSignInAuthentication googleAuth = await googleUser.authentication;
          final fb_auth.OAuthCredential credential = fb_auth.GoogleAuthProvider.credential(
            accessToken: googleAuth.accessToken,
            idToken: googleAuth.idToken,
          );
          final fb_auth.UserCredential userCredential =
              await _firebaseAuth.signInWithCredential(credential);
          _user = userCredential.user;
          print('Firebase user (web): $_user'); // Debug print
          if (_user != null) {
            await _checkIfAdmin();
            await _createUserInFirestore(_user!);
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
        print('googleUser (mobile): $googleUser'); // Debug print
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
        print('Firebase user (mobile): $_user'); // Debug print
        if (_user != null) {
          await _checkIfAdmin();
          await _createUserInFirestore(_user!);
          _status = AuthStatus.authenticated;
          notifyListeners();
          return true;
        }
        print('Google sign-in failed, user is null (mobile)'); // Debug print
        return false;
      }
    } catch (e) {
      print('Error in signInWithGoogle: $e'); // Debug print
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
    const adminUid = 'jwXO9LX5g0eA387930lBQx4keie2';
    _isAdmin = _user?.email == 'admin@beeman.com' || _user?.uid == adminUid;
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
        final userCredential = await auth.signInWithCredential(credential);
        final user = userCredential.user;
        if (user != null) {
          await _createUserInFirestore(user);
        }
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
        final userCredential = await auth.signInWithCredential(credential);
        final user = userCredential.user;
        if (user != null) {
          await _createUserInFirestore(user);
        }
        // Auth state change will be picked up by the listener
      },
      codeAutoRetrievalTimeout: (String verificationId) {},
    );
  }

  // Helper to create user in Firestore
  Future<void> _createUserInFirestore(fb_auth.User user) async {
    try {
      await FirebaseFirestore.instance.collection('users').doc(user.uid).set({
        'uid': user.uid,
        'email': user.email,
        'displayName': user.displayName,
        'photoURL': user.photoURL,
        'createdAt': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));
    } catch (e) {
      print('Firestore user creation error: $e');
    }
  }
}

// Dialog for entering phone number
class PhoneNumberDialog extends StatefulWidget {
  const PhoneNumberDialog({super.key});

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
  const OTPDialog({super.key});

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