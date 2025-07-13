import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../core/constants/app_constants.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../dashboard/presentation/screens/dashboard_screen.dart';
import '../../../admin/presentation/screens/admin_login_screen.dart';
import '../providers/auth_provider.dart';
import '../widgets/custom_button.dart';
import 'registration_screen.dart';
import '../../../profile/presentation/screens/profile_screen.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    // No need to render Google Sign-In button from Dart; plugin handles it.
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    final selectedLanguage = authProvider.selectedLanguage;
    
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      if (authProvider.status == AuthStatus.authenticated && mounted) {
        if (authProvider.isAdmin) {
          Navigator.of(context).pushReplacementNamed('/admin');
        } else {
          Navigator.of(context).pushReplacement(
            MaterialPageRoute(builder: (_) => const DashboardScreen()),
          );
        }
      } else if (authProvider.status == AuthStatus.emailNotVerified && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(authProvider.errorMessage)),
        );
      }
    });

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const SizedBox(height: 48),
                // Logo and app name
                Center(
                  child: Column(
                    children: [
                      Container(
                        width: 120,
                        height: 120,
                        decoration: const BoxDecoration(
                          color: AppTheme.primaryColor,
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.emoji_nature, // Bee icon
                          size: 80,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(height: 16),
                      const Text(
                        AppConstants.appName,
                        style: TextStyle(
                          fontSize: 32,
                          fontWeight: FontWeight.bold,
                          color: AppTheme.primaryColor,
                        ),
                      ),
                      const SizedBox(height: 8),
                      const Text(
                        'BeeBox Pollination Management',
                        style: TextStyle(
                          fontSize: 16,
                          color: AppTheme.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                // Welcome text
                Text(
                  _getWelcomeText(selectedLanguage),
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: AppTheme.textPrimary,
                  ),
                  textAlign: TextAlign.center,
                  softWrap: true,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 16),
                Text(
                  _getSubtitleText(selectedLanguage),
                  style: const TextStyle(
                    fontSize: 16,
                    color: AppTheme.textSecondary,
                  ),
                  textAlign: TextAlign.center,
                  softWrap: true,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 48),
                // Sign-in form section (redesigned)
                Center(
                  child: Container(
                    constraints: const BoxConstraints(maxWidth: 400),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                        const SizedBox(height: 16),
                        TextField(
                          decoration: InputDecoration(
                            labelText: 'Email',
                            border: OutlineInputBorder(),
                          ),
                        ),
                        const SizedBox(height: 16),
                        TextField(
                          obscureText: true,
                          decoration: InputDecoration(
                            labelText: 'Password',
                            border: OutlineInputBorder(),
                          ),
                        ),
                        const SizedBox(height: 12),
                        Row(
                          children: [
                            Checkbox(
                              value: false,
                              onChanged: (v) {},
                            ),
                            const Text('Remember me'),
                            const Spacer(),
                            GestureDetector(
                              onTap: () {},
                              child: Text(
                                'Forgot your password?',
                                style: TextStyle(
                                  color: AppTheme.primaryColor,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        SizedBox(
                          width: double.infinity,
                          height: 48,
                          child: ElevatedButton(
                            onPressed: () {},
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppTheme.primaryColor,
                              foregroundColor: Colors.white,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                            ),
                            child: const Text(
                              'Sign in',
                              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                            ),
                          ),
                        ),
                        const SizedBox(height: 24),
                        Row(
                          children: const [
                            Expanded(child: Divider()),
                            Padding(
                              padding: EdgeInsets.symmetric(horizontal: 8.0),
                              child: Text('Or continue with'),
                            ),
                            Expanded(child: Divider()),
                          ],
                        ),
                        const SizedBox(height: 16),
                      CustomButton(
                        text: _getGoogleSignInText(selectedLanguage),
                        icon: Image.asset(
                          'assets/icons/google_icon.png',
                          width: 24,
                          height: 24,
                        ),
                        onPressed: _isLoading ? null : () => _signInWithGoogle(context),
                        isLoading: _isLoading,
                        backgroundColor: Colors.white,
                        textColor: AppTheme.textPrimary,
                        borderColor: AppTheme.border,
                      ),
                      const SizedBox(height: 16),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Text('Don\'t have an account? '),
                            GestureDetector(
                              onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => const RegistrationScreen(),
                            ),
                          );
                        },
                              child: Text(
                                'Create a new account',
                                style: TextStyle(
                                  color: AppTheme.primaryColor,
                                  fontWeight: FontWeight.bold,
                                  decoration: TextDecoration.underline,
                                ),
                              ),
                              ),
                            ],
                          ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                // Terms and conditions
                Text(
                  _getTermsText(selectedLanguage),
                  style: const TextStyle(
                    fontSize: 12,
                    color: AppTheme.textSecondary,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 16),
                // Admin login button
                TextButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const AdminLoginScreen(),
                      ),
                    );
                  },
                  child: Text(
                    _getAdminLoginText(selectedLanguage),
                    style: const TextStyle(
                      color: AppTheme.textSecondary,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _signInWithGoogle(BuildContext context) async {
    setState(() {
      _isLoading = true;
    });

    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    try {
      final success = await authProvider.signInWithGoogle();
      if (success && context.mounted) {
        // Check if profile is complete
        final user = authProvider.user;
        if (user != null) {
          final doc = await FirebaseFirestore.instance.collection('users').doc(user.uid).get();
          final data = doc.data() ?? {};
          final hasName = (data['displayName'] ?? '').toString().trim().isNotEmpty;
          final hasPhone = (data['phoneNumber'] ?? '').toString().trim().isNotEmpty;
          final hasEmail = (data['email'] ?? '').toString().trim().isNotEmpty;
          final hasAddress = (data['address'] ?? '').toString().trim().isNotEmpty;
          if (!hasName || !hasPhone || !hasEmail || !hasAddress) {
            Navigator.of(context).pushReplacement(
              MaterialPageRoute(builder: (_) => const ProfileScreen()),
            );
            setState(() { _isLoading = false; });
            return;
          }
        }
        // Navigate to dashboard if profile is complete
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (_) => const DashboardScreen()),
        );
      } else if (context.mounted) {
        // Show error message
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(authProvider.errorMessage),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  // Multilingual text getters
  String _getWelcomeText(String languageCode) {
    switch (languageCode) {
      case AppConstants.hindi:
        return 'बीमैन में आपका स्वागत है';
      case AppConstants.marathi:
        return 'बीमॅन मध्ये आपले स्वागत आहे';
      default:
        return 'Welcome to BeeMan';
    }
  }

  String _getSubtitleText(String languageCode) {
    switch (languageCode) {
      case AppConstants.hindi:
        return 'परागण के लिए मधुमक्खी के बक्से किराए पर लें';
      case AppConstants.marathi:
        return 'परागीभवनासाठी मधमाशांचे बॉक्स भाड्याने घ्या';
      default:
        return 'Rent bee boxes for pollination';
    }
  }

  String _getGoogleSignInText(String languageCode) {
    switch (languageCode) {
      case AppConstants.hindi:
        return 'Google के साथ जारी रखें';
      case AppConstants.marathi:
        return 'Google सह सुरू ठेवा';
      default:
        return 'Continue with Google';
    }
  }

  String _getTermsText(String languageCode) {
    switch (languageCode) {
      case AppConstants.hindi:
        return 'जारी रखकर, आप हमारी सेवा की शर्तों और गोपनीयता नीति से सहमत हैं';
      case AppConstants.marathi:
        return 'सुरू ठेवून, आपण आमच्या सेवा अटी आणि गोपनीयता धोरणाशी सहमत आहात';
      default:
        return 'By continuing, you agree to our Terms of Service and Privacy Policy';
    }
  }

  String _getAdminLoginText(String languageCode) {
    switch (languageCode) {
      case AppConstants.hindi:
        return 'एडमिन लॉगिन';
      case AppConstants.marathi:
        return 'अॅडमिन लॉगिन';
      default:
        return 'Admin Login';
    }
  }
}