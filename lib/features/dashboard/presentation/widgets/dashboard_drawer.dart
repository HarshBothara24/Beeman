import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../core/constants/app_constants.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import '../../../auth/presentation/screens/login_screen.dart';
import '../../../booking/presentation/screens/bee_box_selection_screen.dart';
import '../../../booking/presentation/screens/my_bookings_screen.dart';
import '../../../payment/presentation/screens/payment_history_screen.dart';
import '../../../profile/presentation/screens/profile_screen.dart';
import '../screens/dashboard_screen.dart';
// import '../screens/profile_screen.dart';
import '../screens/settings_screen.dart';
import '../screens/support_screen.dart';

class DashboardDrawer extends StatelessWidget {
  const DashboardDrawer({super.key});

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    final user = authProvider.user;
    final selectedLanguage = authProvider.selectedLanguage;

    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          // Drawer header with user info
          UserAccountsDrawerHeader(
            accountName: Text(
              user?.displayName ?? 'User',
              style: const TextStyle(
                fontWeight: FontWeight.bold,
              ),
            ),
            accountEmail: Text(
              user?.email ?? 'user@example.com',
            ),
            currentAccountPicture: CircleAvatar(
              backgroundColor: Colors.white,
              child: Text(
                user?.displayName?.substring(0, 1).toUpperCase() ?? 'U',
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: AppTheme.primaryColor,
                ),
              ),
            ),
            decoration: const BoxDecoration(
              color: AppTheme.primaryColor,
            ),
          ),
          // Home
          ListTile(
            leading: const Icon(Icons.home),
            title: Text(_getHomeText(selectedLanguage)),
            onTap: () {
              Navigator.of(context).pushReplacement(
                MaterialPageRoute(builder: (_) => const DashboardScreen()),
              );
            },
          ),
          // Profile
          ListTile(
            leading: const Icon(Icons.person),
            title: Text(_getProfileText(selectedLanguage)),
            onTap: () {
              Navigator.of(context).push(
                MaterialPageRoute(builder: (_) => const ProfileScreen()),
              );
            },
          ),
          // Book Bee Boxes
          ListTile(
            leading: const Icon(Icons.calendar_today),
            title: const Text('Book Now'),
            onTap: () {
              Navigator.pop(context); // Close drawer
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const BeeBoxSelectionScreen(),
                ),
              );
            },
          ),
          // My Bookings
          ListTile(
            leading: const Icon(Icons.history),
            title: Text(_getMyBookingsText(selectedLanguage)),
            onTap: () {
              Navigator.of(context).push(
                MaterialPageRoute(builder: (_) => const MyBookingsScreen()),
              );
            },
          ),
          // Payment History
          ListTile(
            leading: const Icon(Icons.payment),
            title: Text(_getPaymentHistoryText(selectedLanguage)),
            onTap: () {
              // TODO: Implement PaymentHistoryScreen
              // Navigator.of(context).push(
              //   MaterialPageRoute(builder: (_) => const PaymentHistoryScreen()),
              // );
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Coming soon!'))
              );
            },
          ),
          // Support
          ListTile(
            leading: const Icon(Icons.support_agent),
            title: Text(_getSupportText(selectedLanguage)),
            onTap: () {
              // TODO: Implement SupportScreen
              // Navigator.of(context).push(
              //   MaterialPageRoute(builder: (_) => const SupportScreen()),
              // );
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Coming soon!'))
              );
            },
          ),
          const Divider(),
          // Settings
          ListTile(
            leading: const Icon(Icons.settings),
            title: Text(_getSettingsText(selectedLanguage)),
            onTap: () {
              Navigator.pop(context); // Close drawer first
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const SettingsScreen()),
              );
            },
          ),
          // Sign Out
          ListTile(
            leading: const Icon(Icons.logout),
            title: Text(_getSignOutText(selectedLanguage)),
            onTap: () => _confirmSignOut(context, selectedLanguage),
          ),
          const Divider(),
          // App version
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Text(
              'Version ${AppConstants.appVersion}',
              style: const TextStyle(
                color: AppTheme.textSecondary,
                fontSize: 12,
              ),
              textAlign: TextAlign.center,
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _confirmSignOut(BuildContext context, String languageCode) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(_getSignOutText(languageCode)),
        content: Text(_getSignOutConfirmationText(languageCode)),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: Text(_getCancelText(languageCode)),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: Text(_getSignOutText(languageCode)),
          ),
        ],
      ),
    );

    if (confirmed == true && context.mounted) {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      await authProvider.signOut();

      if (context.mounted) {
        // Navigate back to login screen and clear all routes
        Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(builder: (_) => const LoginScreen()),
          (route) => false,
        );
      }
    }
  }

  // Multilingual text getters
  String _getHomeText(String languageCode) {
    switch (languageCode) {
      case AppConstants.hindi:
        return 'होम';
      case AppConstants.marathi:
        return 'होम';
      default:
        return 'Home';
    }
  }

  String _getProfileText(String languageCode) {
    switch (languageCode) {
      case AppConstants.hindi:
        return 'प्रोफाइल';
      case AppConstants.marathi:
        return 'प्रोफाइल';
      default:
        return 'Profile';
    }
  }

  String _getBookingText(String languageCode) {
    switch (languageCode) {
      case AppConstants.hindi:
        return 'बुकिंग करें';
      case AppConstants.marathi:
        return 'बुकिंग करा';
      default:
        return 'Book Bee Boxes';
    }
  }

  String _getMyBookingsText(String languageCode) {
    switch (languageCode) {
      case AppConstants.hindi:
        return 'मेरी बुकिंग';
      case AppConstants.marathi:
        return 'माझी बुकिंग';
      default:
        return 'My Bookings';
    }
  }

  String _getPaymentHistoryText(String languageCode) {
    switch (languageCode) {
      case AppConstants.hindi:
        return 'भुगतान इतिहास';
      case AppConstants.marathi:
        return 'पेमेंट इतिहास';
      default:
        return 'Payment History';
    }
  }

  String _getSupportText(String languageCode) {
    switch (languageCode) {
      case AppConstants.hindi:
        return 'सहायता';
      case AppConstants.marathi:
        return 'मदत';
      default:
        return 'Support';
    }
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

  String _getSignOutText(String languageCode) {
    switch (languageCode) {
      case AppConstants.hindi:
        return 'साइन आउट';
      case AppConstants.marathi:
        return 'साइन आउट';
      default:
        return 'Sign Out';
    }
  }

  String _getSignOutConfirmationText(String languageCode) {
    switch (languageCode) {
      case AppConstants.hindi:
        return 'क्या आप वाकई साइन आउट करना चाहते हैं?';
      case AppConstants.marathi:
        return 'तुम्हाला खरोखर साइन आउट करायचे आहे का?';
      default:
        return 'Are you sure you want to sign out?';
    }
  }

  String _getCancelText(String languageCode) {
    switch (languageCode) {
      case AppConstants.hindi:
        return 'रद्द करें';
      case AppConstants.marathi:
        return 'रद्द करा';
      default:
        return 'Cancel';
    }
  }
}