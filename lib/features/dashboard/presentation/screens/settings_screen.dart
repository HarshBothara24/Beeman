import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import '../../../auth/presentation/screens/language_selection_screen.dart'; // Fix import

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    final selectedLanguage = authProvider.selectedLanguage;

    return Scaffold(
      appBar: AppBar(
        title: Text(_getSettingsText(selectedLanguage)),
        backgroundColor: AppTheme.primaryColor,
        foregroundColor: Colors.white,
      ),
      body: ListView(
        children: [
          // Language Settings
          ListTile(
            leading: const Icon(Icons.language),
            title: Text(_getLanguageText(selectedLanguage)),
            subtitle: Text(_getCurrentLanguage(selectedLanguage)),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder:
                      (_) => const LanguageSelectionScreen(), // Fix class name
                ),
              );
            },
          ),
          const Divider(),
          // Add more settings here
        ],
      ),
      floatingActionButton: FloatingActionButton(
        heroTag: 'language_fab_settings',
        backgroundColor: AppTheme.primaryColor,
        child: const Icon(Icons.language, color: Colors.white),
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const LanguageSelectionScreen()),
          );
        },
        tooltip: 'Change Language',
      ),
    );
  }

  void _showLanguageDialog(BuildContext context, String currentLanguage) {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: Text(_getSelectLanguageText(currentLanguage)),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                _buildLanguageOption(context, 'English', AppConstants.english),
                _buildLanguageOption(context, 'हिंदी', AppConstants.hindi),
                _buildLanguageOption(context, 'मराठी', AppConstants.marathi),
              ],
            ),
          ),
    );
  }

  Widget _buildLanguageOption(BuildContext context, String title, String code) {
    final authProvider = Provider.of<AuthProvider>(context);
    final isSelected = authProvider.selectedLanguage == code;

    return ListTile(
      title: Text(title),
      trailing:
          isSelected
              ? const Icon(Icons.check, color: AppTheme.primaryColor)
              : null,
      onTap: () {
        authProvider.setLanguage(code);
        Navigator.pop(context);
      },
    );
  }

  String _getSettingsText(String languageCode) {
    switch (languageCode) {
      case AppConstants.hindi:
        return 'सेटिंग्स';
      case AppConstants.marathi:
        return 'सेटिंग्ज';
      default:
        return 'Settings';
    }
  }

  String _getLanguageText(String languageCode) {
    switch (languageCode) {
      case AppConstants.hindi:
        return 'भाषा';
      case AppConstants.marathi:
        return 'भाषा';
      default:
        return 'Language';
    }
  }

  String _getCurrentLanguage(String languageCode) {
    switch (languageCode) {
      case AppConstants.hindi:
        return 'हिंदी';
      case AppConstants.marathi:
        return 'मराठी';
      default:
        return 'English';
    }
  }

  String _getSelectLanguageText(String languageCode) {
    switch (languageCode) {
      case AppConstants.hindi:
        return 'भाषा चुनें';
      case AppConstants.marathi:
        return 'भाषा निवडा';
      default:
        return 'Select Language';
    }
  }
}
