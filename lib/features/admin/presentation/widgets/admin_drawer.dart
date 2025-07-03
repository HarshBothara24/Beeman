import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../core/constants/app_constants.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import '../screens/admin_dashboard_screen.dart';
import '../screens/bee_box_management_screen.dart';
import '../screens/booking_management_screen.dart';
import '../screens/payment_management_screen.dart';
import '../screens/user_management_screen.dart';

class AdminDrawer extends StatelessWidget {
  const AdminDrawer({super.key});

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    final user = authProvider.user;

    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          // Drawer header with admin info
          UserAccountsDrawerHeader(
            accountName: Text(
              user?.displayName ?? 'Admin',
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            accountEmail: Text(
              user?.email ?? '',
              style: const TextStyle(fontSize: 14),
            ),
            currentAccountPicture: CircleAvatar(
              backgroundColor: Colors.white,
              child: user?.photoURL != null
                  ? ClipOval(
                      child: Image.network(
                        user!.photoURL!,
                        width: 72,
                        height: 72,
                        fit: BoxFit.cover,
                      ),
                    )
                  : Text(
                      user?.displayName?.substring(0, 1).toUpperCase() ?? 'A',
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
          // Dashboard
          ListTile(
            leading: const Icon(Icons.dashboard),
            title: const Text('Dashboard'),
            onTap: () {
              Navigator.of(context).pushReplacement(
                MaterialPageRoute(builder: (_) => const AdminDashboardScreen()),
              );
            },
          ),
          // Bee Box Management
          ListTile(
            leading: const Icon(Icons.grid_view),
            title: const Text('Bee Box Management'),
            onTap: () {
              Navigator.of(context).push(
                MaterialPageRoute(builder: (_) => const BeeBoxManagementScreen()),
              );
            },
          ),
          // Booking Management
          ListTile(
            leading: const Icon(Icons.calendar_today),
            title: const Text('Booking Management'),
            onTap: () {
              Navigator.of(context).push(
                MaterialPageRoute(builder: (_) => const BookingManagementScreen()),
              );
            },
          ),
          // User Management
          ListTile(
            leading: const Icon(Icons.people),
            title: const Text('User Management'),
            onTap: () {
              Navigator.of(context).push(
                MaterialPageRoute(builder: (_) => const UserManagementScreen()),
              );
            },
          ),
          // Payment Management
          ListTile(
            leading: const Icon(Icons.payment),
            title: const Text('Payment Management'),
            onTap: () {
              Navigator.of(context).push(
                MaterialPageRoute(builder: (_) => const PaymentManagementScreen()),
              );
            },
          ),
          const Divider(),
          // Settings
          ListTile(
            leading: const Icon(Icons.settings),
            title: const Text('Settings'),
            onTap: () {
              // TODO: Implement Settings Screen
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Settings coming soon!')),
              );
              // Navigator.of(context).push(
              //   MaterialPageRoute(builder: (_) => const SettingsScreen()),
              // );
            },
          ),
          // Sign Out
          ListTile(
            leading: const Icon(Icons.logout),
            title: const Text('Sign Out'),
            onTap: () => _confirmSignOut(context),
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

  Future<void> _confirmSignOut(BuildContext context) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Sign Out'),
        content: const Text('Are you sure you want to sign out?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('Sign Out'),
          ),
        ],
      ),
    );

    if (confirmed == true && context.mounted) {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      await authProvider.signOut();

      if (context.mounted) {
        // Navigate back to login screen and clear all routes
        Navigator.of(context).pushNamedAndRemoveUntil('/login', (route) => false);
      }
    }
  }
}