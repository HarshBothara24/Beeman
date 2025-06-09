import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../core/constants/app_constants.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import '../../../auth/presentation/screens/login_screen.dart';
import '../widgets/admin_drawer.dart';
import '../widgets/dashboard_card.dart';
import 'bee_box_management_screen.dart';
import 'booking_management_screen.dart';
import 'user_management_screen.dart';
import 'payment_management_screen.dart';

class AdminDashboardScreen extends StatelessWidget {
  const AdminDashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    final user = authProvider.user;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Admin Dashboard'),
        backgroundColor: AppTheme.primaryColor,
        foregroundColor: Colors.white,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () => _confirmSignOut(context),
          ),
        ],
      ),
      drawer: const AdminDrawer(),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Admin info card
                Card(
                  elevation: 2,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Row(
                      children: [
                        CircleAvatar(
                          radius: 30,
                          backgroundColor: AppTheme.primaryColor,
                          child: Text(
                            user?.displayName?.substring(0, 1).toUpperCase() ?? 'A',
                            style: const TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                user?.displayName ?? 'Admin User',
                                style: const TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                user?.email ?? 'admin@beeman.com',
                                style: const TextStyle(
                                  fontSize: 14,
                                  color: AppTheme.textSecondary,
                                ),
                              ),
                              const SizedBox(height: 4),
                              const Text(
                                'Administrator',
                                style: TextStyle(
                                  fontSize: 14,
                                  color: AppTheme.primaryColor,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                // Dashboard title
                const Text(
                  'Dashboard',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: AppTheme.textPrimary,
                  ),
                ),
                const SizedBox(height: 16),
                // Dashboard cards
                GridView.count(
                  crossAxisCount: 2,
                  crossAxisSpacing: 16,
                  mainAxisSpacing: 16,
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  children: [
                    // Bee Box Management
                    DashboardCard(
                      title: 'Bee Boxes',
                      subtitle: 'Manage bee boxes',
                      icon: Icons.grid_view,
                      color: Colors.amber,
                      onTap: () => _navigateToBeeBoxManagement(context),
                    ),
                    // Booking Management
                    DashboardCard(
                      title: 'Bookings',
                      subtitle: 'Manage bookings',
                      icon: Icons.calendar_today,
                      color: Colors.green,
                      onTap: () => _navigateToBookingManagement(context),
                    ),
                    // User Management
                    DashboardCard(
                      title: 'Users',
                      subtitle: 'Manage users',
                      icon: Icons.people,
                      color: Colors.blue,
                      onTap: () => _navigateToUserManagement(context),
                    ),
                    // Payment Management
                    DashboardCard(
                      title: 'Payments',
                      subtitle: 'Manage payments',
                      icon: Icons.payment,
                      color: Colors.purple,
                      onTap: () => _navigateToPaymentManagement(context),
                    ),
                  ],
                ),
                const SizedBox(height: 24),
                // Recent activity title
                const Text(
                  'Recent Activity',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: AppTheme.textPrimary,
                  ),
                ),
                const SizedBox(height: 16),
                // Recent activity list
                _buildRecentActivityList(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildRecentActivityList() {
    // This would typically be populated from a database
    // For now, we'll use dummy data
    final activities = [
      {
        'type': 'booking',
        'title': 'New Booking',
        'description': 'Rahul Sharma booked 5 bee boxes',
        'time': '2 hours ago',
        'icon': Icons.calendar_today,
        'color': Colors.green,
      },
      {
        'type': 'payment',
        'title': 'Payment Received',
        'description': '₹5,000 received from Amit Patel',
        'time': '5 hours ago',
        'icon': Icons.payment,
        'color': Colors.purple,
      },
      {
        'type': 'user',
        'title': 'New User',
        'description': 'Priya Desai registered as a new user',
        'time': '1 day ago',
        'icon': Icons.person_add,
        'color': Colors.blue,
      },
      {
        'type': 'box',
        'title': 'Bee Box Added',
        'description': '10 new bee boxes added to inventory',
        'time': '2 days ago',
        'icon': Icons.add_box,
        'color': Colors.amber,
      },
    ];

    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: activities.length,
      itemBuilder: (context, index) {
        final activity = activities[index];
        return Card(
          elevation: 1,
          margin: const EdgeInsets.only(bottom: 12),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          child: ListTile(
            leading: CircleAvatar(
              backgroundColor: (activity['color'] as Color).withOpacity(0.2),
              child: Icon(
                activity['icon'] as IconData,
                color: activity['color'] as Color,
              ),
            ),
            title: Text(
              activity['title'] as String,
              style: const TextStyle(
                fontWeight: FontWeight.bold,
              ),
            ),
            subtitle: Text(activity['description'] as String),
            trailing: Text(
              activity['time'] as String,
              style: const TextStyle(
                color: AppTheme.textSecondary,
                fontSize: 12,
              ),
            ),
            onTap: () {
              // Navigate to the relevant screen based on activity type
            },
          ),
        );
      },
    );
  }

  void _navigateToBeeBoxManagement(BuildContext context) {
    Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => const BeeBoxManagementScreen()),
    );
  }

  void _navigateToBookingManagement(BuildContext context) {
    Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => const BookingManagementScreen()),
    );
  }

  void _navigateToUserManagement(BuildContext context) {
    Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => const UserManagementScreen()),
    );
  }

  void _navigateToPaymentManagement(BuildContext context) {
    Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => const PaymentManagementScreen()),
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
        Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(builder: (_) => const LoginScreen()),
          (route) => false,
        );
      }
    }
  }
}