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
            padding: const EdgeInsets.all(24.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Section: Admin Info
                Card(
                  elevation: 3,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(20.0),
                    child: Row(
                      children: [
                        user?.photoURL != null
                            ? CircleAvatar(
                                radius: 36,
                                backgroundImage: NetworkImage(user!.photoURL!),
                                backgroundColor: AppTheme.primaryColor,
                              )
                            : CircleAvatar(
                                radius: 36,
                                backgroundColor: AppTheme.primaryColor,
                                child: Text(
                                  (user?.displayName?.isNotEmpty ?? false)
                                      ? user!.displayName![0].toUpperCase()
                                      : 'A',
                                  style: const TextStyle(
                                    fontSize: 28,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white,
                                  ),
                                ),
                              ),
                        const SizedBox(width: 20),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                l10n(user?.displayName ?? 'Admin User'),
                                style: const TextStyle(
                                  fontSize: 22,
                                  fontWeight: FontWeight.bold,
                                  color: AppTheme.textPrimary,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                l10n(user?.email ?? 'admin@beeman.com'),
                                style: const TextStyle(
                                  fontSize: 15,
                                  color: AppTheme.textSecondary,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                l10n('Administrator'),
                                style: const TextStyle(
                                  fontSize: 15,
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
                const SizedBox(height: 32),
                const Divider(thickness: 1, height: 1),
                const SizedBox(height: 24),
                // Section: Stats
                Text(
                  l10n('Quick Stats'),
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: AppTheme.textPrimary,
                  ),
                ),
                const SizedBox(height: 16),
                LayoutBuilder(
                  builder: (context, constraints) {
                    int crossAxisCount = 2;
                    double width = constraints.maxWidth;
                    if (width > 900) {
                      crossAxisCount = 4;
                    } else if (width > 600) {
                      crossAxisCount = 3;
                    }
                    return StreamBuilder<QuerySnapshot>(
                      stream: FirebaseFirestore.instance.collection('bookings').snapshots(),
                      builder: (context, snapshot) {
                        if (snapshot.connectionState == ConnectionState.waiting) {
                          return Center(child: CircularProgressIndicator());
                        }
                        if (snapshot.hasError) {
                          return Center(child: Text('Error: ${snapshot.error}'));
                        }
                        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                          return Center(child: Text('No bookings found.'));
                        }
                        final bookings = snapshot.data!.docs;
                        final totalBookings = bookings.length;
                        final activeBookings = bookings.where((b) => (b.data() as Map<String, dynamic>)['status'] == 'active').length;
                        final pendingBookings = bookings.where((b) => (b.data() as Map<String, dynamic>)['status'] == 'pending').length;
                        final totalRevenue = bookings.fold<double>(0.0, (sum, b) => sum + ((b.data() as Map<String, dynamic>)['totalAmount'] ?? 0.0));
                        return GridView.count(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          crossAxisCount: crossAxisCount,
                          crossAxisSpacing: 24,
                          mainAxisSpacing: 24,
                          childAspectRatio: 1.2,
                          children: [
                            _animatedStatCard(
                              l10n('Total Bookings'),
                              totalBookings.toString(),
                              Icons.calendar_today,
                              Colors.blue,
                            ),
                            _animatedStatCard(
                              l10n('Active Bookings'),
                              activeBookings.toString(),
                              Icons.hive,
                              Colors.green,
                            ),
                            _animatedStatCard(
                              l10n('Pending Bookings'),
                              pendingBookings.toString(),
                              Icons.pending,
                              Colors.orange,
                            ),
                            _animatedStatCard(
                              l10n('Total Revenue'),
                              '₹$totalRevenue',
                              Icons.money,
                              Colors.purple,
                            ),
                          ],
                        );
                      },
                    );
                  },
                ),
                const SizedBox(height: 32),
                const Divider(thickness: 1, height: 1),
                const SizedBox(height: 24),
                // Section: Dashboard Actions
                Text(
                  l10n('Dashboard Actions'),
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: AppTheme.textPrimary,
                  ),
                ),
                const SizedBox(height: 16),
                LayoutBuilder(
                  builder: (context, constraints) {
                    int crossAxisCount = 2;
                    double width = constraints.maxWidth;
                    if (width > 900) {
                      crossAxisCount = 4;
                    } else if (width > 600) {
                      crossAxisCount = 3;
                    }
                    return GridView.count(
                      crossAxisCount: crossAxisCount,
                      crossAxisSpacing: 24,
                      mainAxisSpacing: 24,
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      childAspectRatio: 1.1,
                      children: [
                        _hoverableDashboardCard(
                          title: l10n('Bee Boxes'),
                          subtitle: l10n('Manage bee boxes'),
                          icon: Icons.grid_view,
                          color: Colors.amber,
                          onTap: () => _navigateToBeeBoxManagement(context),
                        ),
                        _hoverableDashboardCard(
                          title: l10n('Bookings'),
                          subtitle: l10n('Manage bookings'),
                          icon: Icons.calendar_today,
                          color: Colors.green,
                          onTap: () => _navigateToBookingManagement(context),
                        ),
                        _hoverableDashboardCard(
                          title: l10n('Users'),
                          subtitle: l10n('Manage users'),
                          icon: Icons.people,
                          color: Colors.blue,
                          onTap: () => _navigateToUserManagement(context),
                        ),
                        _hoverableDashboardCard(
                          title: l10n('Payments'),
                          subtitle: l10n('Manage payments'),
                          icon: Icons.payment,
                          color: Colors.purple,
                          onTap: () => _navigateToPaymentManagement(context),
                        ),
                      ],
                    );
                  },
                ),
                const SizedBox(height: 32),
                const Divider(thickness: 1, height: 1),
                const SizedBox(height: 24),
                // Section: Recent Bookings
                Text(
                  l10n('Recent Bookings'),
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: AppTheme.textPrimary,
                  ),
                ),
                const SizedBox(height: 16),
                bookings.isEmpty
                    ? Center(
                        child: Padding(
                          padding: const EdgeInsets.symmetric(vertical: 32),
                          child: Text(
                            l10n('No recent bookings found.'),
                            style: const TextStyle(
                              color: AppTheme.textSecondary,
                              fontSize: 16,
                            ),
                          ),
                        ),
                      )
                    : ListView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: bookings.length,
                        itemBuilder: (context, index) {
                          final booking = bookings[index];
                          return _hoverableBookingCard(context, booking);
                        },
                      ),
              ],
            ),
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => BeeBoxManagementScreen()),
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

  Widget _animatedStatCard(String title, String value, IconData icon, Color color) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 400),
      curve: Curves.easeInOut,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: color.withOpacity(0.08),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withOpacity(0.3)),
        boxShadow: [
          BoxShadow(
            color: color.withOpacity(0.08),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, color: color, size: 36),
          const SizedBox(height: 10),
          Text(
            value,
            style: TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            title,
            style: TextStyle(
              color: color.withOpacity(0.8),
              fontWeight: FontWeight.w600,
              fontSize: 15,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _hoverableDashboardCard({
    required String title,
    required String subtitle,
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
  }) {
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          curve: Curves.easeInOut,
          decoration: BoxDecoration(
            color: color.withOpacity(0.08),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: color.withOpacity(0.3)),
            boxShadow: [
              BoxShadow(
                color: color.withOpacity(0.08),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, color: color, size: 36),
              const SizedBox(height: 10),
              Text(
                title,
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: color,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                subtitle,
                style: TextStyle(
                  color: color.withOpacity(0.8),
                  fontWeight: FontWeight.w600,
                  fontSize: 14,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _hoverableBookingCard(BuildContext context, dynamic booking) {
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        onTap: () => _showBookingDetails(context, booking),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          curve: Curves.easeInOut,
          margin: const EdgeInsets.only(bottom: 16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: AppTheme.primaryColor.withOpacity(0.08),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
            border: Border.all(color: AppTheme.primaryColor.withOpacity(0.08)),
          ),
          child: ListTile(
            leading: CircleAvatar(
              backgroundColor: AppTheme.primaryColor.withOpacity(0.1),
              child: Icon(Icons.calendar_today, color: AppTheme.primaryColor),
            ),
            title: Text('Booking #${booking.id.substring(0, 8)}', style: const TextStyle(fontWeight: FontWeight.bold)),
            subtitle: Text('${booking.crop} - ${booking.boxNumbers.length} boxes'),
            trailing: _buildStatusChip(booking.status),
          ),
        ),
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
          _buildDetailRow(l10n('Crop'), booking.crop),
          _buildDetailRow(l10n('Location'), booking.location),
          _buildDetailRow(l10n('Boxes'), booking.boxNumbers.length.toString()),
          _buildDetailRow(l10n('Status'), booking.status.toUpperCase()),
          _buildDetailRow(l10n('Total Amount'), '₹${booking.totalAmount}'),
          _buildDetailRow(l10n('Deposit Paid'), '₹${booking.depositAmount}'),
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

String l10n(String text) => text; // Placeholder for localization

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