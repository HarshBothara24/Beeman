import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../core/constants/app_constants.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../dashboard/presentation/screens/dashboard_screen.dart';
import '../../../admin/presentation/screens/admin_login_screen.dart';
import '../providers/auth_provider.dart';
import '../widgets/custom_button.dart';
import 'registration_screen.dart';

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
                // Google Sign In Button
                Container(
                  constraints: const BoxConstraints(maxWidth: 500),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
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
                      CustomButton(
                        text: _getPhoneSignInText(selectedLanguage),
                        icon: const Icon(
                          Icons.phone,
                          color: Colors.white,
                        ),
                        onPressed: _isLoading ? null : () {
                          final authProvider = Provider.of<AuthProvider>(context, listen: false);
                          authProvider.signInWithPhone(context);
                        },
                        isLoading: false,
                        backgroundColor: AppTheme.primaryColor,
                        textColor: Colors.white,
                      ),
                      const SizedBox(height: 16),
                      ElevatedButton(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => const RegistrationScreen(),
                            ),
                          );
                        },
                        child: const Text('Registration Page'),
                      ),
                      if (authProvider.status == AuthStatus.emailNotVerified)
                        Padding(
                          padding: const EdgeInsets.only(top: 16.0),
                          child: Column(
                            children: [
                              const Text(
                                'Please verify your email and then click below:',
                                style: TextStyle(color: Colors.red),
                              ),
                              const SizedBox(height: 8),
                              ElevatedButton(
                                onPressed: () async {
                                  final verified = await authProvider.reloadAndCheckEmailVerified();
                                  if (verified && mounted) {
                                    Navigator.of(context).pushReplacement(
                                      MaterialPageRoute(builder: (_) => const DashboardScreen()),
                                    );
                                  } else {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(content: Text('Email not verified yet. Please check your inbox.')),
                                    );
                                  }
                                },
                                child: const Text('I have verified my email'),
                              ),
                            ],
                          ),
                        ),
                    ],
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
        // Navigate to dashboard
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

  String _getPhoneSignInText(String languageCode) {
    switch (languageCode) {
      case AppConstants.hindi:
        return 'फोन नंबर के साथ जारी रखें';
      case AppConstants.marathi:
        return 'फोन नंबरसह सुरू ठेवा';
      default:
        return 'Continue with Phone';
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