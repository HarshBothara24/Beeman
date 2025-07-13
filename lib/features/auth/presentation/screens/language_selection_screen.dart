import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:easy_localization/easy_localization.dart';

import '../../../../core/constants/app_constants.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../dashboard/presentation/screens/dashboard_screen.dart';
import '../providers/auth_provider.dart';
import 'registration_screen.dart';

class LanguageSelectionScreen extends StatefulWidget {
  const LanguageSelectionScreen({super.key});

  @override
  State<LanguageSelectionScreen> createState() =>
      _LanguageSelectionScreenState();
}

class _LanguageSelectionScreenState extends State<LanguageSelectionScreen> {
  String _selectedLanguage = AppConstants.english;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: SingleChildScrollView(
            child: Column(
              children: [
                const SizedBox(height: 40),
                const Icon(
                  Icons.translate,
                  size: 80,
                  color: AppTheme.primaryColor,
                ),
                const SizedBox(height: 32),
                Text(
                  'select_language'.tr(),
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                // You can add a subtitle if needed, or remove this for now
                const SizedBox(height: 48),
                _buildLanguageButton(
                  'English',
                  AppConstants.english,
                  'English',
                ),
                const SizedBox(height: 16),
                _buildLanguageButton('हिंदी', AppConstants.hindi, 'Hindi'),
                const SizedBox(height: 16),
                _buildLanguageButton('मराठी', AppConstants.marathi, 'Marathi'),
                const SizedBox(height: 40),
                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: ElevatedButton(
                    onPressed: _continueWithLanguage,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppTheme.primaryColor,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: Text(
                      'continue'.tr(),
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
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

  Widget _buildLanguageButton(String title, String code, String subtitle) {
    final isSelected = _selectedLanguage == code;
    return InkWell(
      onTap: () => setState(() => _selectedLanguage = code),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          border: Border.all(
            color: isSelected ? AppTheme.primaryColor : AppTheme.border,
            width: isSelected ? 2 : 1,
          ),
          borderRadius: BorderRadius.circular(12),
          color:
              isSelected ? AppTheme.primaryColor.withValues(alpha: 0.1) : null,
        ),
        child: Row(
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight:
                        isSelected ? FontWeight.bold : FontWeight.normal,
                  ),
                ),
                Text(
                  subtitle,
                  style: const TextStyle(
                    fontSize: 14,
                    color: AppTheme.textSecondary,
                  ),
                ),
              ],
            ),
            const Spacer(),
            if (isSelected)
              const Icon(Icons.check_circle, color: AppTheme.primaryColor),
          ],
        ),
      ),
    );
  }

  void _continueWithLanguage() {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    authProvider.setLanguage(_selectedLanguage);
    context.setLocale(Locale(_selectedLanguage));
    // Navigate based on authentication status
    if (authProvider.user != null) {
      // User is logged in, go to dashboard
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (_) => const DashboardScreen()),
      );
    } else {
      // Not logged in, go to registration
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (_) => const RegistrationScreen()),
      );
    }
  }
}
