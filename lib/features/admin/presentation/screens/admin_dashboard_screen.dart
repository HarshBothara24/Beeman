import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import '../../../../core/theme/app_theme.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import '../../../auth/presentation/screens/login_screen.dart';
import '../../../booking/presentation/providers/booking_provider.dart';
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
    final bookingProvider = Provider.of<BookingProvider>(context);
    final bookings = bookingProvider.bookings;
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
                // Stats cards (real-time)
                StreamBuilder<QuerySnapshot>(
                  stream: FirebaseFirestore.instance.collection('bookings').snapshots(),
                  builder: (context, snapshot) {
                    final bookings = snapshot.hasData ? snapshot.data!.docs : [];
                    final totalBookings = bookings.length;
                    final activeBookings = bookings.where((b) => (b.data() as Map<String, dynamic>)['status'] == 'active').length;
                    final pendingBookings = bookings.where((b) => (b.data() as Map<String, dynamic>)['status'] == 'pending').length;
                    final totalRevenue = bookings.fold<double>(0.0, (sum, b) => sum + ((b.data() as Map<String, dynamic>)['totalAmount'] ?? 0.0));
                    return GridView.count(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      crossAxisCount: 2,
                      crossAxisSpacing: 16,
                      mainAxisSpacing: 16,
                      children: [
                        GestureDetector(
                          onTap: () => _navigateToBookingManagement(context),
                          child: _buildStatCard(
                            'Total Bookings',
                            totalBookings.toString(),
                            Icons.calendar_today,
                            Colors.blue,
                          ),
                        ),
                        _buildStatCard(
                          'Active Bookings',
                          activeBookings.toString(),
                          Icons.hive,
                          Colors.green,
                        ),
                        _buildStatCard(
                          'Pending Bookings',
                          pendingBookings.toString(),
                          Icons.pending,
                          Colors.orange,
                        ),
                        _buildStatCard(
                          'Total Revenue',
                          '₹$totalRevenue',
                          Icons.money,
                          Colors.purple,
                        ),
                      ],
                    );
                  },
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
                // Recent bookings
                const Text(
                  'Recent Bookings',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 16),
                ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: bookings.length,
                  itemBuilder: (context, index) {
                    final booking = bookings[index];
                    return Card(
                      margin: const EdgeInsets.only(bottom: 12),
                      child: ListTile(
                        title: Text('Booking #${booking.id.substring(0, 8)}'),
                        subtitle: Text(
                          '${booking.crop} - ${booking.boxNumbers.length} boxes',
                        ),
                        trailing: _buildStatusChip(booking.status),
                        onTap: () => _showBookingDetails(context, booking),
                      ),
                    );
                  },
                ),
              ],
            ),
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // TODO: Add box management screen
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Box management coming soon!')),
          );
        },
        backgroundColor: AppTheme.primaryColor,
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildStatCard(String title, String value, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.5)),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, color: color, size: 32),
          const SizedBox(height: 8),
          Text(
            value,
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            title,
            style: TextStyle(
              color: color.withOpacity(0.8),
              fontWeight: FontWeight.w500,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildStatusChip(String status) {
    Color color;
    switch (status.toLowerCase()) {
      case 'active':
        color = Colors.green;
        break;
      case 'pending':
        color = Colors.orange;
        break;
      case 'completed':
        color = Colors.blue;
        break;
      case 'cancelled':
        color = Colors.red;
        break;
      default:
        color = Colors.grey;
    }

    return Chip(
      label: Text(
        status.toUpperCase(),
        style: const TextStyle(
          color: Colors.white,
          fontSize: 12,
        ),
      ),
      backgroundColor: color,
      padding: const EdgeInsets.symmetric(horizontal: 8),
    );
  }

  void _showBookingDetails(BuildContext context, dynamic booking) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Booking #${booking.id.substring(0, 8)}'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildDetailRow('Crop', booking.crop),
            _buildDetailRow('Location', booking.location),
            _buildDetailRow('Boxes', booking.boxNumbers.length.toString()),
            _buildDetailRow('Status', booking.status.toUpperCase()),
            _buildDetailRow('Total Amount', '₹${booking.totalAmount}'),
            _buildDetailRow('Deposit Paid', '₹${booking.depositAmount}'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
          TextButton(
            onPressed: () {
              // TODO: Add status update functionality
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Status update coming soon!')),
              );
            },
            child: const Text('Update Status'),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            '$label:',
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              color: AppTheme.textSecondary,
            ),
          ),
          Text(value),
        ],
      ),
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