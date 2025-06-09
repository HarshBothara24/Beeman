import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../core/providers/auth_provider.dart';
import '../../../../core/theme/app_theme.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  String _getText(String key, BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final languageCode = authProvider.languageCode;
    
    final Map<String, Map<String, String>> textMap = {
      'settings': {
        'en': 'Settings',
        'hi': 'सेटिंग्स',
        'mr': 'सेटिंग्ज',
      },
      'language': {
        'en': 'Language',
        'hi': 'भाषा',
        'mr': 'भाषा',
      },
      'notifications': {
        'en': 'Notifications',
        'hi': 'सूचनाएं',
        'mr': 'सूचना',
      },
      'darkMode': {
        'en': 'Dark Mode',
        'hi': 'डार्क मोड',
        'mr': 'डार्क मोड',
      },
      'about': {
        'en': 'About',
        'hi': 'के बारे में',
        'mr': 'बद्दल',
      },
      'privacyPolicy': {
        'en': 'Privacy Policy',
        'hi': 'गोपनीयता नीति',
        'mr': 'गोपनीयता धोरण',
      },
      'termsOfService': {
        'en': 'Terms of Service',
        'hi': 'सेवा की शर्तें',
        'mr': 'सेवा अटी',
      },
      'appVersion': {
        'en': 'App Version',
        'hi': 'ऐप वर्शन',
        'mr': 'अॅप आवृत्ती',
      },
      'english': {
        'en': 'English',
        'hi': 'अंग्रेज़ी',
        'mr': 'इंग्रजी',
      },
      'hindi': {
        'en': 'Hindi',
        'hi': 'हिंदी',
        'mr': 'हिंदी',
      },
      'marathi': {
        'en': 'Marathi',
        'hi': 'मराठी',
        'mr': 'मराठी',
      },
      'languageChanged': {
        'en': 'Language changed successfully',
        'hi': 'भाषा सफलतापूर्वक बदल दी गई है',
        'mr': 'भाषा यशस्वीरित्या बदलली',
      },
    };

    return textMap[key]?[languageCode] ?? textMap[key]?['en'] ?? key;
  }

  void _showLanguageDialog(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final currentLanguage = authProvider.languageCode;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(_getText('language', context)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildLanguageOption(
              context,
              'en',
              _getText('english', context),
              currentLanguage == 'en',
            ),
            _buildLanguageOption(
              context,
              'hi',
              _getText('hindi', context),
              currentLanguage == 'hi',
            ),
            _buildLanguageOption(
              context,
              'mr',
              _getText('marathi', context),
              currentLanguage == 'mr',
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLanguageOption(
    BuildContext context,
    String languageCode,
    String languageName,
    bool isSelected,
  ) {
    return ListTile(
      title: Text(languageName),
      trailing: isSelected
          ? const Icon(
              Icons.check_circle,
              color: AppTheme.primaryColor,
            )
          : null,
      onTap: () {
        final authProvider = Provider.of<AuthProvider>(context, listen: false);
        authProvider.setLanguage(languageCode);
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(_getText('languageChanged', context))),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_getText('settings', context)),
      ),
      body: ListView(
        children: [
          // Language Settings
          ListTile(
            leading: const Icon(Icons.language),
            title: Text(_getText('language', context)),
            subtitle: Consumer<AuthProvider>(
              builder: (context, authProvider, _) {
                final languageCode = authProvider.languageCode;
                String languageName;
                switch (languageCode) {
                  case 'hi':
                    languageName = _getText('hindi', context);
                    break;
                  case 'mr':
                    languageName = _getText('marathi', context);
                    break;
                  case 'en':
                  default:
                    languageName = _getText('english', context);
                }
                return Text(languageName);
              },
            ),
            onTap: () => _showLanguageDialog(context),
          ),
          const Divider(),

          // Notifications Settings
          SwitchListTile(
            secondary: const Icon(Icons.notifications),
            title: Text(_getText('notifications', context)),
            value: true, // TODO: Connect to actual settings provider
            onChanged: (value) {
              // TODO: Implement notifications toggle
            },
          ),
          const Divider(),

          // Dark Mode Settings
          SwitchListTile(
            secondary: const Icon(Icons.dark_mode),
            title: Text(_getText('darkMode', context)),
            value: false, // TODO: Connect to actual theme provider
            onChanged: (value) {
              // TODO: Implement dark mode toggle
            },
          ),
          const Divider(),

          // About Section
          ListTile(
            leading: const Icon(Icons.info),
            title: Text(_getText('about', context)),
            onTap: () {
              // TODO: Navigate to About screen
            },
          ),
          const Divider(),

          // Privacy Policy
          ListTile(
            leading: const Icon(Icons.privacy_tip),
            title: Text(_getText('privacyPolicy', context)),
            onTap: () {
              // TODO: Navigate to Privacy Policy screen or open URL
            },
          ),
          const Divider(),

          // Terms of Service
          ListTile(
            leading: const Icon(Icons.description),
            title: Text(_getText('termsOfService', context)),
            onTap: () {
              // TODO: Navigate to Terms of Service screen or open URL
            },
          ),
          const Divider(),

          // App Version
          ListTile(
            leading: const Icon(Icons.phone_android),
            title: Text(_getText('appVersion', context)),
            subtitle: const Text('1.0.0'), // TODO: Get actual app version
            enabled: false,
          ),
        ],
      ),
    );
  }
}