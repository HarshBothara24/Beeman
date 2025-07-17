import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:google_sign_in/google_sign_in.dart';
// Import web-only Google sign-in button and config
import 'package:google_sign_in_web/web_only.dart' as web_only;

import '../../../../core/constants/app_constants.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/widgets/custom_button.dart';
import '../../../../core/widgets/animated_loading.dart';
import '../../../dashboard/presentation/screens/dashboard_screen.dart';
import '../../../admin/presentation/screens/admin_login_screen.dart';
import '../providers/auth_provider.dart';
import 'registration_screen.dart';
import '../../../profile/presentation/screens/profile_screen.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen>
    with TickerProviderStateMixin {
  bool _isLoading = false;
  late AnimationController _fadeController;
  late AnimationController _slideController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
    _initializeAnimations();
  }

  void _initializeAnimations() {
    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    );

    _slideController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _fadeController,
      curve: Curves.easeIn,
    ));

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.3),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _slideController,
      curve: Curves.easeOut,
    ));

    // Start animations
    _fadeController.forward();
    Future.delayed(const Duration(milliseconds: 200), () {
      if (mounted) _slideController.forward();
    });
  }

  @override
  void dispose() {
    _fadeController.dispose();
    _slideController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    final selectedLanguage = authProvider.selectedLanguage;
    
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      print('Auth status in LoginScreen: ${authProvider.status}'); // DEBUG
      if (authProvider.status == AuthStatus.authenticated && mounted) {
        print('Navigating to dashboard or admin...'); // DEBUG
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
      body: Container(
        decoration: const BoxDecoration(
          gradient: AppTheme.backgroundGradient,
        ),
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24.0),
            child: AnimatedBuilder(
              animation: _fadeAnimation,
              builder: (context, child) {
                return Opacity(
                  opacity: _fadeAnimation.value,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      const SizedBox(height: 32),
                      
                      // Animated Logo Section
                      SlideTransition(
                        position: _slideAnimation,
                        child: Center(
                          child: Column(
                            children: [
                              Hero(
                                tag: 'app_logo',
                                child: Container(
                                  width: 120,
                                  height: 120,
                                  decoration: BoxDecoration(
                                    gradient: AppTheme.primaryGradient,
                                    shape: BoxShape.circle,
                                    boxShadow: [
                                      BoxShadow(
                                        color: AppTheme.primaryColor.withOpacity(0.3),
                                        blurRadius: 20,
                                        offset: const Offset(0, 8),
                                      ),
                                    ],
                                  ),
                                  child: const Icon(
                                    Icons.emoji_nature,
                                    size: 80,
                                    color: Colors.white,
                                  ),
                                ),
                              ),
                              const SizedBox(height: 24),
                              ShaderMask(
                                shaderCallback: (bounds) =>
                                    AppTheme.primaryGradient.createShader(bounds),
                                child: const Text(
                                  AppConstants.appName,
                                  style: TextStyle(
                                    fontSize: 36,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white,
                                    letterSpacing: 1,
                                  ),
                                ),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                'Pollination Management System',
                                style: TextStyle(
                                  fontSize: 16,
                                  color: AppTheme.textSecondary,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      
                      const SizedBox(height: 48),
                      
                      // Welcome Section
                      SlideTransition(
                        position: Tween<Offset>(
                          begin: const Offset(0, 0.2),
                          end: Offset.zero,
                        ).animate(CurvedAnimation(
                          parent: _slideController,
                          curve: const Interval(0.3, 1.0, curve: Curves.easeOut),
                        )),
                        child: Column(
                          children: [
                            Text(
                              _getWelcomeText(selectedLanguage),
                              style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                                fontWeight: FontWeight.bold,
                                color: AppTheme.textPrimary,
                              ),
                              textAlign: TextAlign.center,
                            ),
                            const SizedBox(height: 12),
                            Text(
                              _getSubtitleText(selectedLanguage),
                              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                                color: AppTheme.textSecondary,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ],
                        ),
                      ),
                      
                      const SizedBox(height: 48),
                      
                      // Login Form Card
                      SlideTransition(
                        position: Tween<Offset>(
                          begin: const Offset(0, 0.3),
                          end: Offset.zero,
                        ).animate(CurvedAnimation(
                          parent: _slideController,
                          curve: const Interval(0.5, 1.0, curve: Curves.easeOut),
                        )),
                        child: Center(
                          child: Container(
                            constraints: const BoxConstraints(maxWidth: 400),
                            child: Card(
                              elevation: 0,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: Container(
                                decoration: BoxDecoration(
                                  color: AppTheme.surfaceColor,
                                  borderRadius: BorderRadius.circular(20),
                                  border: Border.all(
                                    color: AppTheme.dividerColor,
                                    width: 0.5,
                                  ),
                                  boxShadow: [AppTheme.cardShadow],
                                ),
                                padding: const EdgeInsets.all(32),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.stretch,
                                  children: [
                                    // Email Field
                                    TextField(
                                      decoration: InputDecoration(
                                        labelText: 'Email',
                                        prefixIcon: Icon(
                                          Icons.email_outlined,
                                          color: AppTheme.textSecondary,
                                        ),
                                        filled: true,
                                        fillColor: AppTheme.backgroundColor,
                                      ),
                                    ),
                                    const SizedBox(height: 20),
                                    
                                    // Password Field
                                    TextField(
                                      obscureText: true,
                                      decoration: InputDecoration(
                                        labelText: 'Password',
                                        prefixIcon: Icon(
                                          Icons.lock_outline,
                                          color: AppTheme.textSecondary,
                                        ),
                                        suffixIcon: Icon(
                                          Icons.visibility_off_outlined,
                                          color: AppTheme.textSecondary,
                                        ),
                                        filled: true,
                                        fillColor: AppTheme.backgroundColor,
                                      ),
                                    ),
                                    const SizedBox(height: 16),
                                    
                                    // Remember me & Forgot password
                                    Row(
                                      children: [
                                        Checkbox(
                                          value: false,
                                          onChanged: (v) {},
                                          activeColor: AppTheme.primaryColor,
                                        ),
                                        const Text('Remember me'),
                                        const Spacer(),
                                        TextButton(
                                          onPressed: () {},
                                          child: Text(
                                            'Forgot Password?',
                                            style: TextStyle(
                                              color: AppTheme.primaryColor,
                                              fontWeight: FontWeight.w600,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 24),
                                    
                                    // Sign In Button
                                    GradientButton(
                                      text: 'Sign In',
                                      onPressed: () {},
                                      fullWidth: true,
                                      icon: Icons.login,
                                    ),
                                    
                                    const SizedBox(height: 24),
                                    
                                    // Divider
                                    Row(
                                      children: [
                                        const Expanded(child: Divider()),
                                        Padding(
                                          padding: const EdgeInsets.symmetric(horizontal: 16),
                                          child: Text(
                                            'Or continue with',
                                            style: TextStyle(
                                              color: AppTheme.textSecondary,
                                              fontSize: 14,
                                            ),
                                          ),
                                        ),
                                        const Expanded(child: Divider()),
                                      ],
                                    ),
                                    const SizedBox(height: 24),
                                    
                                    // Google Sign In Button
                                    LoadingOverlay(
                                      isLoading: _isLoading,
                                      loadingText: 'Signing in...',
                                      child: CustomButton(
                                        text: _getGoogleSignInText(selectedLanguage),
                                        onPressed: _isLoading ? null : () => _signInWithGoogle(context),
                                        variant: ButtonVariant.outlined,
                                        fullWidth: true,
                                        iconWidget: Image.asset(
                                          'assets/icons/google_icon.png',
                                          width: 20,
                                          height: 20,
                                        ),
                                      ),
                                    ),
                                    
                                    const SizedBox(height: 24),
                                    
                                    // Sign Up Link
                                    Row(
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      children: [
                                        Text(
                                          'Don\'t have an account? ',
                                          style: TextStyle(color: AppTheme.textSecondary),
                                        ),
                                        TextButton(
                                          onPressed: () {
                                            Navigator.push(
                                              context,
                                              PageRouteBuilder(
                                                pageBuilder: (context, animation, secondaryAnimation) =>
                                                    const RegistrationScreen(),
                                                transitionsBuilder: (context, animation, secondaryAnimation, child) {
                                                  return SlideTransition(
                                                    position: Tween<Offset>(
                                                      begin: const Offset(1.0, 0.0),
                                                      end: Offset.zero,
                                                    ).animate(animation),
                                                    child: child,
                                                  );
                                                },
                                              ),
                                            );
                                          },
                                          child: Text(
                                            'Sign Up',
                                            style: TextStyle(
                                              color: AppTheme.primaryColor,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                      
                      const SizedBox(height: 32),
                      
                      // Terms and Admin Login
                      SlideTransition(
                        position: Tween<Offset>(
                          begin: const Offset(0, 0.2),
                          end: Offset.zero,
                        ).animate(CurvedAnimation(
                          parent: _slideController,
                          curve: const Interval(0.7, 1.0, curve: Curves.easeOut),
                        )),
                        child: Column(
                          children: [
                            Text(
                              _getTermsText(selectedLanguage),
                              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                color: AppTheme.textMuted,
                              ),
                              textAlign: TextAlign.center,
                            ),
                            const SizedBox(height: 16),
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
                                style: TextStyle(
                                  color: AppTheme.textSecondary,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      
                      const SizedBox(height: 32),
                    ],
                  ),
                );
              },
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
      print('signInWithGoogle returned: ${success}'); // DEBUG
      print('AuthProvider status after sign-in: ${authProvider.status}'); // DEBUG
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
            print('Profile incomplete, redirecting to ProfileScreen'); // DEBUG
            Navigator.of(context).pushReplacement(
              MaterialPageRoute(builder: (_) => const ProfileScreen()),
            );
            setState(() { _isLoading = false; });
            return;
          }
        }
        // Navigate to dashboard if profile is complete
        print('Profile complete, navigating to DashboardScreen'); // DEBUG
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (_) => const DashboardScreen()),
        );
      } else if (context.mounted) {
        // Show error message
        print('Google sign-in failed: ${authProvider.errorMessage}'); // DEBUG
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