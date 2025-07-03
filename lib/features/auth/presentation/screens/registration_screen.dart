import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart' as fb_auth;
import '../../../../core/theme/app_theme.dart';
import '../providers/auth_provider.dart';
import '../screens/login_screen.dart';
import '../../../dashboard/presentation/screens/dashboard_screen.dart';

class RegistrationScreen extends StatefulWidget {
  const RegistrationScreen({super.key});

  @override
  State<RegistrationScreen> createState() => _RegistrationScreenState();
}

class _RegistrationScreenState extends State<RegistrationScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _farmerNameController = TextEditingController();
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _otpController = TextEditingController();

  bool _isOTPSent = false;
  bool _isLoading = false;
  String? _verificationId;

  @override
  void dispose() {
    _farmerNameController.dispose();
    _usernameController.dispose();
    _phoneController.dispose();
    _emailController.dispose();
    _otpController.dispose();
    super.dispose();
  }

  Future<bool> _isEmailAlreadyUsed(String email) async {
    final query = await FirebaseFirestore.instance
        .collection('users')
        .where('email', isEqualTo: email)
        .limit(1)
        .get();
    return query.docs.isNotEmpty;
  }

  void _sendOTP() async {
    final phone = '+91${_phoneController.text.trim()}';
    final phoneRegex = RegExp(r'^\+\d{10,15}$'); // Accepts +<country_code><number>

    if (!phoneRegex.hasMatch(phone)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Enter valid phone number with country code (e.g. +919876543210)')),
      );
      return;
    }

    if (_phoneController.text.trim().length != 10) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Enter a valid 10-digit phone number')),
      );
      return;
    }

    setState(() => _isLoading = true);

    await fb_auth.FirebaseAuth.instance.verifyPhoneNumber(
      phoneNumber: phone,
      verificationCompleted: (fb_auth.PhoneAuthCredential credential) async {},
      verificationFailed: (fb_auth.FirebaseAuthException e) {
        setState(() => _isLoading = false);
        if (!context.mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Verification failed: ${e.message}')),
        );
      },
      codeSent: (String verificationId, int? resendToken) {
        setState(() {
          _isOTPSent = true;
          _verificationId = verificationId;
          _isLoading = false;
        });
        if (!context.mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('OTP sent!')),
        );
      },
      codeAutoRetrievalTimeout: (String verificationId) {
        _verificationId = verificationId;
      },
    );
  }

  void _register() async {
    if (!_isOTPSent) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please request and enter the OTP')),
      );
      return;
    }

    if (_formKey.currentState?.validate() ?? false) {
      final smsCode = _otpController.text.trim();
      final email = _emailController.text.trim();

      if (_verificationId == null || smsCode.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Enter the OTP')),
        );
        return;
      }

      setState(() => _isLoading = true);

      try {
        // Check email uniqueness
        final alreadyUsed = await _isEmailAlreadyUsed(email);
        if (alreadyUsed) {
          setState(() => _isLoading = false);
          if (!context.mounted) return;
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Email is already registered')),
          );
          return;
        }

        final credential = fb_auth.PhoneAuthProvider.credential(
          verificationId: _verificationId!,
          smsCode: smsCode,
        );

        final userCred = await fb_auth.FirebaseAuth.instance.signInWithCredential(credential);
        final user = userCred.user;

        if (user != null) {
          await FirebaseFirestore.instance.collection('users').doc(user.uid).set({
            'farmerName': _farmerNameController.text.trim(),
            'username': _usernameController.text.trim(),
            'phone': _phoneController.text.trim(),
            'email': _emailController.text.trim(),
            'uid': user.uid,
            'createdAt': FieldValue.serverTimestamp(),
          });

          if (!context.mounted) return;
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Registration successful!')),
          );

          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => const DashboardScreen()),
          );
        }
      } catch (e) {
        if (!context.mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('OTP verification failed: $e')),
        );
      }

      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);

    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Card(
            elevation: 4,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            child: Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (_isLoading) const LinearProgressIndicator(),
                  const SizedBox(height: 8),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      icon: Image.asset(
                        'assets/icons/google_icon.png',
                        width: 24,
                        height: 24,
                      ),
                      label: const Text(
                        'Continue with Google',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.white,
                        foregroundColor: AppTheme.textPrimary,
                        side: const BorderSide(color: AppTheme.primaryColor),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        padding: const EdgeInsets.symmetric(vertical: 14),
                      ),
                      onPressed: _isLoading
                          ? null
                          : () async {
                              print('Google sign-in button pressed'); // Debug print
                              setState(() => _isLoading = true);
                              try {
                                final success = await authProvider.signInWithGoogle();
                                print('signInWithGoogle returned: $success'); // Debug print
                                if (success && context.mounted) {
                                  // Write user data to Firestore
                                  final user = authProvider.user;
                                  if (user != null) {
                                    await FirebaseFirestore.instance.collection('users').doc(user.uid).set({
                                      'email': user.email,
                                      'displayName': user.displayName,
                                      'uid': user.uid,
                                      'photoURL': user.photoURL,
                                      'createdAt': FieldValue.serverTimestamp(),
                                    }, SetOptions(merge: true));
                                  }
                                  // Navigate to dashboard
                                  Navigator.pushReplacement(
                                    context,
                                    MaterialPageRoute(builder: (context) => const DashboardScreen()),
                                  );
                                } else if (context.mounted) {
                                  print('Google sign-in failed: ${authProvider.errorMessage}'); // Debug print
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(content: Text(authProvider.errorMessage)),
                                  );
                                }
                              } finally {
                                if (mounted) setState(() => _isLoading = false);
                              }
                            },
                    ),
                  ),
                  const SizedBox(height: 24),
                  Row(
                    children: const [
                      Expanded(child: Divider()),
                      Padding(
                        padding: EdgeInsets.symmetric(horizontal: 8.0),
                        child: Text('OR'),
                      ),
                      Expanded(child: Divider()),
                    ],
                  ),
                  const SizedBox(height: 24),
                  Form(
                    key: _formKey,
                    child: Column(
                      children: [
                        TextFormField(
                          controller: _farmerNameController,
                          decoration: const InputDecoration(
                            labelText: "Farmer's Name",
                            border: OutlineInputBorder(),
                          ),
                          validator: (value) =>
                              value == null || value.isEmpty ? 'Enter farmer\'s name' : null,
                        ),
                        const SizedBox(height: 16),
                        TextFormField(
                          controller: _usernameController,
                          decoration: const InputDecoration(
                            labelText: 'Username',
                            border: OutlineInputBorder(),
                          ),
                          validator: (value) =>
                              value == null || value.isEmpty ? 'Enter username' : null,
                        ),
                        const SizedBox(height: 16),
                        TextFormField(
                          controller: _phoneController,
                          keyboardType: TextInputType.phone,
                          decoration: InputDecoration(
                            labelText: 'Phone Number',
                            border: const OutlineInputBorder(),
                            prefixText: '+91 ',
                            suffixIcon: !_isOTPSent
                                ? TextButton(
                                    onPressed: _sendOTP,
                                    child: const Text('Send Code'),
                                  )
                                : null,
                          ),
                          validator: (value) =>
                              value == null || value.isEmpty ? 'Enter phone number' : null,
                        ),
                        if (_isOTPSent) ...[
                          const SizedBox(height: 16),
                          TextFormField(
                            controller: _otpController,
                            keyboardType: TextInputType.number,
                            decoration: const InputDecoration(
                              labelText: 'Verification Code',
                              border: OutlineInputBorder(),
                            ),
                            validator: (value) =>
                                value == null || value.isEmpty ? 'Enter verification code' : null,
                          ),
                        ],
                        const SizedBox(height: 16),
                        TextFormField(
                          controller: _emailController,
                          keyboardType: TextInputType.emailAddress,
                          decoration: const InputDecoration(
                            labelText: 'Email',
                            border: OutlineInputBorder(),
                          ),
                          validator: (value) =>
                              value == null || value.isEmpty ? 'Enter email' : null,
                        ),
                        const SizedBox(height: 24),
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton(
                            onPressed: _isLoading ? null : _register,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppTheme.primaryColor,
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(vertical: 14),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                            ),
                            child: const Text(
                              'Register / Login',
                              style: TextStyle(fontWeight: FontWeight.bold),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
