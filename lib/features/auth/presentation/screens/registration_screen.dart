import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart' as fb_auth;
import '../../../../core/theme/app_theme.dart';
import '../providers/auth_provider.dart';
import '../screens/login_screen.dart';
import '../../../dashboard/presentation/screens/dashboard_screen.dart';
import '../../../profile/presentation/screens/profile_screen.dart'; // Added import for ProfileScreen

class RegistrationScreen extends StatefulWidget {
  const RegistrationScreen({super.key});

  @override
  State<RegistrationScreen> createState() => _RegistrationScreenState();
}

class _RegistrationScreenState extends State<RegistrationScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _farmerNameController = TextEditingController();
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _phoneController =
      TextEditingController(); // Added
  final TextEditingController _locationController =
      TextEditingController(); // Added
  final TextEditingController _passwordController =
      TextEditingController(); // Added

  bool _isLoading = false;

  @override
  void dispose() {
    _farmerNameController.dispose();
    _usernameController.dispose();
    _emailController.dispose();
    _phoneController.dispose(); // Added
    _locationController.dispose(); // Added
    _passwordController.dispose(); // Added
    super.dispose();
  }

  Future<bool> _isEmailAlreadyUsed(String email) async {
    final query =
        await FirebaseFirestore.instance
            .collection('users')
            .where('email', isEqualTo: email)
            .limit(1)
            .get();
    return query.docs.isNotEmpty;
  }

  void _register() async {
    if (_formKey.currentState?.validate() ?? false) {
      final email = _emailController.text.trim();
      final password = _passwordController.text; // Added

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

        // Use createUserWithEmailAndPassword instead of signInWithEmailAndPassword
        final userCred = await fb_auth.FirebaseAuth.instance
            .createUserWithEmailAndPassword(email: email, password: password);
        final user = userCred.user;

        if (user != null) {
          await FirebaseFirestore.instance
              .collection('users')
              .doc(user.uid)
              .set({
                'farmerName': _farmerNameController.text.trim(),
                'username': _usernameController.text.trim(),
                'email': _emailController.text.trim(),
                'phone': _phoneController.text.trim(),
                'address': _locationController.text.trim(),
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
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Registration failed: $e')));
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
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
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
                      onPressed:
                          _isLoading
                              ? null
                              : () async {
                                print(
                                  'Google sign-in button pressed',
                                ); // Debug print
                                setState(() => _isLoading = true);
                                try {
                                  final success =
                                      await authProvider.signInWithGoogle();
                                  print(
                                    'signInWithGoogle returned: $success',
                                  ); // Debug print
                                  if (success && context.mounted) {
                                    // Write user data to Firestore
                                    final user = authProvider.user;
                                    if (user != null) {
                                      await FirebaseFirestore.instance
                                          .collection('users')
                                          .doc(user.uid)
                                          .set({
                                            'email': user.email,
                                            'displayName': user.displayName,
                                            'uid': user.uid,
                                            'photoURL': user.photoURL,
                                            'phone': '', // Require completion
                                            'address': '', // Require completion
                                            'createdAt':
                                                FieldValue.serverTimestamp(),
                                          }, SetOptions(merge: true));
                                    }
                                    // After Google sign-in, check if phone or address is missing and redirect to ProfileScreen
                                    final userDoc =
                                        await FirebaseFirestore.instance
                                            .collection('users')
                                            .doc(user!.uid)
                                            .get();
                                    final data = userDoc.data();
                                    if (data == null ||
                                        (data['phone'] == null ||
                                            data['phone'].toString().isEmpty) ||
                                        (data['address'] == null ||
                                            data['address']
                                                .toString()
                                                .isEmpty)) {
                                      if (context.mounted) {
                                        Navigator.pushReplacement(
                                          context,
                                          MaterialPageRoute(
                                            builder:
                                                (context) =>
                                                    const ProfileScreen(),
                                          ),
                                        );
                                        return;
                                      }
                                    }
                                    // Navigate to dashboard
                                    Navigator.pushReplacement(
                                      context,
                                      MaterialPageRoute(
                                        builder:
                                            (context) =>
                                                const DashboardScreen(),
                                      ),
                                    );
                                  } else if (context.mounted) {
                                    print(
                                      'Google sign-in failed: ${authProvider.errorMessage}',
                                    ); // Debug print
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                        content: Text(
                                          authProvider.errorMessage,
                                        ),
                                      ),
                                    );
                                  }
                                } finally {
                                  if (mounted)
                                    setState(() => _isLoading = false);
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
                          validator:
                              (value) =>
                                  value == null || value.isEmpty
                                      ? 'Enter farmer\'s name'
                                      : null,
                        ),
                        const SizedBox(height: 16),
                        TextFormField(
                          controller: _usernameController,
                          decoration: const InputDecoration(
                            labelText: 'Username',
                            border: OutlineInputBorder(),
                          ),
                          validator:
                              (value) =>
                                  value == null || value.isEmpty
                                      ? 'Enter username'
                                      : null,
                        ),
                        const SizedBox(height: 16),
                        TextFormField(
                          controller: _emailController,
                          keyboardType: TextInputType.emailAddress,
                          decoration: const InputDecoration(
                            labelText: 'Email',
                            border: OutlineInputBorder(),
                          ),
                          validator:
                              (value) =>
                                  value == null || value.isEmpty
                                      ? 'Enter email'
                                      : null,
                        ),
                        const SizedBox(height: 16),
                        TextFormField(
                          controller: _passwordController,
                          obscureText: true,
                          decoration: const InputDecoration(
                            labelText: 'Password',
                            border: OutlineInputBorder(),
                          ),
                          validator:
                              (value) =>
                                  value == null || value.isEmpty
                                      ? 'Enter password'
                                      : value.length < 6
                                      ? 'Password must be at least 6 characters'
                                      : null,
                        ),
                        const SizedBox(height: 16),
                        TextFormField(
                          controller: _phoneController,
                          keyboardType: TextInputType.phone,
                          decoration: const InputDecoration(
                            labelText: 'Mobile Number',
                            border: OutlineInputBorder(),
                          ),
                          validator:
                              (value) =>
                                  value == null || value.isEmpty
                                      ? 'Enter mobile number'
                                      : null,
                        ),
                        const SizedBox(height: 16),
                        TextFormField(
                          controller: _locationController,
                          decoration: const InputDecoration(
                            labelText: 'Location',
                            border: OutlineInputBorder(),
                          ),
                          validator:
                              (value) =>
                                  value == null || value.isEmpty
                                      ? 'Enter location'
                                      : null,
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
