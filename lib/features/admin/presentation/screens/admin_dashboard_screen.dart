import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import '../../../../core/theme/app_theme.dart';
import '../../../../core/providers/theme_provider.dart';
import '../../../../core/widgets/animated_loading.dart';
import '../../../../core/widgets/skeleton_loading.dart';
import '../../../../core/widgets/page_transitions.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import '../../../auth/presentation/screens/login_screen.dart';
import '../../../booking/presentation/providers/booking_provider.dart';
import '../widgets/admin_drawer.dart';
import '../widgets/dashboard_card.dart';
import '../widgets/enhanced_admin_card.dart';
import 'bee_box_management_screen.dart';
import 'booking_management_screen.dart';
import 'user_management_screen.dart';
import 'payment_management_screen.dart';

class AdminDashboardScreen extends StatefulWidget {
  const AdminDashboardScreen({super.key});

  @override
  State<AdminDashboardScreen> createState() => _AdminDashboardScreenState();
}

class _AdminDashboardScreenState extends State<AdminDashboardScreen>
    with TickerProviderStateMixin {
  late Future<QuerySnapshot> _bookingsFuture;
  late AnimationController _fadeController;
  late AnimationController _slideController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
    _bookingsFuture = FirebaseFirestore.instance.collection('bookings').get();
    _initializeAnimations();
  }

  void _initializeAnimations() {
    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );

    _slideController = AnimationController(
      duration: const Duration(milliseconds: 1000),
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
      begin: const Offset(0, 0.1),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _slideController,
      curve: Curves.easeOut,
    ));

    // Start animations
    _fadeController.forward();
    _slideController.forward();
  }

  @override
  void dispose() {
    _fadeController.dispose();
    _slideController.dispose();
    super.dispose();
  }

  void _refreshStats() {
    setState(() {
      _bookingsFuture = FirebaseFirestore.instance.collection('bookings').get();
    });
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    final bookingProvider = Provider.of<BookingProvider>(context);
    final themeProvider = Provider.of<ThemeProvider>(context);
    final bookings = bookingProvider.bookings;
    final user = authProvider.user;

    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: themeProvider.isDarkMode
              ? AppTheme.darkBackgroundGradient
              : AppTheme.backgroundGradient,
        ),
        child: CustomScrollView(
          slivers: [
            // Modern App Bar
            SliverAppBar(
              expandedHeight: 120,
              floating: false,
              pinned: true,
              backgroundColor: Colors.transparent,
              elevation: 0,
              flexibleSpace: FlexibleSpaceBar(
                background: Container(
                  decoration: const BoxDecoration(
                    gradient: AppTheme.primaryGradient,
                  ),
                  child: SafeArea(
                    child: Padding(
                      padding: const EdgeInsets.all(20),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          const Text(
                            'Admin Dashboard',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 16,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            user?.displayName ?? 'Administrator',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
              actions: [
                IconButton(
                  icon: Icon(
                    themeProvider.isDarkMode
                        ? Icons.light_mode
                        : Icons.dark_mode,
                    color: Colors.white,
                  ),
                  onPressed: () {
                    themeProvider.toggleTheme();
                  },
                ),
                IconButton(
                  icon: const Icon(Icons.refresh, color: Colors.white),
                  tooltip: 'Refresh Stats',
                  onPressed: _refreshStats,
                ),
                IconButton(
                  icon: const Icon(Icons.logout, color: Colors.white),
                  onPressed: () => _confirmSignOut(context),
                ),
              ],
            ),

            // Dashboard Content
            SliverToBoxAdapter(
              child: AnimatedBuilder(
                animation: _fadeAnimation,
                builder: (context, child) {
                  return FadeTransition(
                    opacity: _fadeAnimation,
                    child: SlideTransition(
                      position: _slideAnimation,
                      child: Padding(
                        padding: const EdgeInsets.all(20),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Welcome Card
                            _buildWelcomeCard(user, themeProvider),
                            const SizedBox(height: 24),

                            // Quick Stats
                            _buildQuickStats(themeProvider),
                            const SizedBox(height: 32),

                            // Dashboard Actions Section
                            _buildSectionHeader('Dashboard Actions'),
                            const SizedBox(height: 16),
                            _buildDashboardActions(),
                            const SizedBox(height: 32),

                            // Recent Bookings Section
                            _buildSectionHeader('Recent Bookings'),
                            const SizedBox(height: 16),
                            _buildRecentBookings(bookings, themeProvider),
                            const SizedBox(height: 32),
                          ],
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
      drawer: const AdminDrawer(),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          NavigationHelper.pushWithTransition(
            context,
            const BeeBoxManagementScreen(),
            transition: TransitionType.slideUp,
          );
        },
        backgroundColor: AppTheme.primaryColor,
        label: const Text('Add Bee Box'),
        icon: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildWelcomeCard(user, ThemeProvider themeProvider) {
    return Container(
      decoration: themeProvider.isDarkMode
          ? AppTheme.darkCardDecoration
          : AppTheme.cardDecoration,
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Row(
          children: [
            Hero(
              tag: 'admin_avatar',
              child: Container(
                width: 60,
                height: 60,
                decoration: BoxDecoration(
                  gradient: AppTheme.primaryGradient,
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: AppTheme.primaryColor.withOpacity(0.3),
                      blurRadius: 8,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: user?.photoURL != null
                    ? ClipOval(
                        child: Image.network(
                          user!.photoURL!,
                          width: 60,
                          height: 60,
                          fit: BoxFit.cover,
                        ),
                      )
                    : Center(
                        child: Text(
                          (user?.displayName?.isNotEmpty ?? false)
                              ? user!.displayName![0].toUpperCase()
                              : 'A',
                          style: const TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                      ),
              ),
            ),
            const SizedBox(width: 20),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Welcome back, Admin!',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: themeProvider.isDarkMode
                              ? AppTheme.darkTextSecondary
                              : AppTheme.textSecondary,
                        ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    user?.displayName ?? 'Administrator',
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    user?.email ?? 'admin@beeman.com',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: themeProvider.isDarkMode
                              ? AppTheme.darkTextMuted
                              : AppTheme.textMuted,
                        ),
                  ),
                ],
              ),
            ),
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: AppTheme.primaryColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(
                Icons.admin_panel_settings,
                color: AppTheme.primaryColor,
                size: 20,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildQuickStats(ThemeProvider themeProvider) {
    return FutureBuilder<QuerySnapshot>(
      future: _bookingsFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          final width = MediaQuery.of(context).size.width;
          if (width < 600) {
            return Column(
              children: [
                Row(
                  children: [
                    Expanded(child: _buildSkeletonStatCard()),
                    const SizedBox(width: 16),
                    Expanded(child: _buildSkeletonStatCard()),
                  ],
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(child: _buildSkeletonStatCard()),
                    const SizedBox(width: 16),
                    Expanded(child: _buildSkeletonStatCard()),
                  ],
                ),
              ],
            );
          } else {
            return Row(
              children: [
                Expanded(child: _buildSkeletonStatCard()),
                const SizedBox(width: 16),
                Expanded(child: _buildSkeletonStatCard()),
                const SizedBox(width: 16),
                Expanded(child: _buildSkeletonStatCard()),
                const SizedBox(width: 16),
                Expanded(child: _buildSkeletonStatCard()),
              ],
            );
          }
        }

        if (snapshot.hasError) {
          return _buildErrorCard('Error loading stats');
        }

        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
          final width = MediaQuery.of(context).size.width;
          if (width < 600) {
            return Column(
              children: [
                Row(
                  children: [
                    Expanded(
                      child: _buildStatCard(
                        'Total Bookings',
                        '0',
                        Icons.calendar_today,
                        AppTheme.selectedColor,
                        themeProvider,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: _buildStatCard(
                        'Active',
                        '0',
                        Icons.hive,
                        AppTheme.availableColor,
                        themeProvider,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: _buildStatCard(
                        'Pending',
                        '0',
                        Icons.pending,
                        AppTheme.warningColor,
                        themeProvider,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: _buildStatCard(
                        'Revenue',
                        '₹0',
                        Icons.currency_rupee,
                        AppTheme.infoColor,
                        themeProvider,
                      ),
                    ),
                  ],
                ),
              ],
            );
          } else {
            return _buildDefaultStats();
          }
        }

        final bookings = snapshot.data!.docs;
        final totalBookings = bookings.length;
        final activeBookings = bookings
            .where((b) =>
                (b.data() as Map<String, dynamic>)['status'] == 'active')
            .length;
        final pendingBookings = bookings
            .where((b) =>
                (b.data() as Map<String, dynamic>)['status'] == 'pending')
            .length;
        final totalRevenue = bookings.fold<double>(
            0.0,
            (sum, b) =>
                sum +
                ((b.data() as Map<String, dynamic>)['totalAmount'] ?? 0.0));

        final width = MediaQuery.of(context).size.width;
        if (width < 600) {
          return Column(
            children: [
              Row(
                children: [
                  Expanded(
                    child: _buildStatCard(
                      'Total Bookings',
                      totalBookings.toString(),
                      Icons.calendar_today,
                      AppTheme.selectedColor,
                      themeProvider,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: _buildStatCard(
                      'Active',
                      activeBookings.toString(),
                      Icons.hive,
                      AppTheme.availableColor,
                      themeProvider,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: _buildStatCard(
                      'Pending',
                      pendingBookings.toString(),
                      Icons.pending,
                      AppTheme.warningColor,
                      themeProvider,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: _buildStatCard(
                      'Revenue',
                      '₹${totalRevenue.toStringAsFixed(0)}',
                      Icons.currency_rupee,
                      AppTheme.infoColor,
                      themeProvider,
                    ),
                  ),
                ],
              ),
            ],
          );
        } else {
          return Row(
            children: [
              Expanded(
                child: _buildStatCard(
                  'Total Bookings',
                  totalBookings.toString(),
                  Icons.calendar_today,
                  AppTheme.selectedColor,
                  themeProvider,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _buildStatCard(
                  'Active',
                  activeBookings.toString(),
                  Icons.hive,
                  AppTheme.availableColor,
                  themeProvider,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _buildStatCard(
                  'Pending',
                  pendingBookings.toString(),
                  Icons.pending,
                  AppTheme.warningColor,
                  themeProvider,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _buildStatCard(
                  'Revenue',
                  '₹${totalRevenue.toStringAsFixed(0)}',
                  Icons.currency_rupee,
                  AppTheme.infoColor,
                  themeProvider,
                ),
              ),
            ],
          );
        }
      },
    );
  }

  Widget _buildStatCard(String title, String value, IconData icon, Color color,
      ThemeProvider themeProvider) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: themeProvider.isDarkMode
            ? AppTheme.darkSurfaceColor
            : AppTheme.surfaceColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: themeProvider.isDarkMode
              ? AppTheme.darkBorderColor
              : AppTheme.dividerColor,
          width: 0.5,
        ),
        boxShadow: [
          themeProvider.isDarkMode ? AppTheme.darkCardShadow : AppTheme.cardShadow
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, color: color, size: 20),
          ),
          const SizedBox(height: 12),
          Text(
            value,
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: themeProvider.isDarkMode
                      ? AppTheme.darkTextPrimary
                      : AppTheme.textPrimary,
                ),
          ),
          const SizedBox(height: 4),
          Text(
            title,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: themeProvider.isDarkMode
                      ? AppTheme.darkTextSecondary
                      : AppTheme.textSecondary,
                ),
          ),
        ],
      ),
    );
  }

  Widget _buildSkeletonStatCard() {
    return const SkeletonCard(
      height: 80,
      showTitle: true,
      showSubtitle: true,
      lineCount: 1,
    );
  }

  Widget _buildErrorCard(String message) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.bookedColor.withOpacity(0.1),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppTheme.bookedColor.withOpacity(0.3)),
      ),
      child: Row(
        children: [
          Icon(Icons.error, color: AppTheme.bookedColor),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              message,
              style: TextStyle(color: AppTheme.bookedColor),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDefaultStats() {
    return Row(
      children: [
        Expanded(
          child: _buildStatCard(
            'Total Bookings',
            '0',
            Icons.calendar_today,
            AppTheme.selectedColor,
            Provider.of<ThemeProvider>(context),
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: _buildStatCard(
            'Active',
            '0',
            Icons.hive,
            AppTheme.availableColor,
            Provider.of<ThemeProvider>(context),
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: _buildStatCard(
            'Pending',
            '0',
            Icons.pending,
            AppTheme.warningColor,
            Provider.of<ThemeProvider>(context),
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: _buildStatCard(
            'Revenue',
            '₹0',
            Icons.currency_rupee,
            AppTheme.infoColor,
            Provider.of<ThemeProvider>(context),
          ),
        ),
      ],
    );
  }

  Widget _buildSectionHeader(String title) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          title,
          style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
              ),
        ),
        TextButton(
          onPressed: () {},
          child: Text(
            'View All',
            style: TextStyle(
              color: AppTheme.primaryColor,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildDashboardActions() {
    return LayoutBuilder(
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
          crossAxisSpacing: 16,
          mainAxisSpacing: 16,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          childAspectRatio: width < 500 ? 0.85 : (width < 700 ? 1.0 : 1.1), // more height for small screens
          children: [
            _buildEnhancedActionCard(
              title: 'Bee Boxes',
              subtitle: 'Manage bee boxes',
              icon: Icons.grid_view,
              color: AppTheme.warningColor,
              onTap: () => _navigateToBeeBoxManagement(context),
            ),
            _buildEnhancedActionCard(
              title: 'Bookings',
              subtitle: 'Manage bookings',
              icon: Icons.calendar_today,
              color: AppTheme.availableColor,
              onTap: () => _navigateToBookingManagement(context),
              isNew: true,
            ),
            _buildEnhancedActionCard(
              title: 'Users',
              subtitle: 'Manage users',
              icon: Icons.people,
              color: AppTheme.selectedColor,
              onTap: () => _navigateToUserManagement(context),
            ),
            _buildEnhancedActionCard(
              title: 'Payments',
              subtitle: 'Manage payments',
              icon: Icons.payment,
              color: AppTheme.infoColor,
              onTap: () => _navigateToPaymentManagement(context),
            ),
          ],
        );
      },
    );
  }

  Widget _buildEnhancedActionCard({
    required String title,
    required String subtitle,
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
    bool isNew = false,
  }) {
    return EnhancedAdminCard(
      title: title,
      subtitle: subtitle,
      icon: icon,
      color: color,
      onTap: onTap,
      isNew: isNew,
    );
  }

  Widget _buildRecentBookings(List<dynamic> bookings, ThemeProvider themeProvider) {
    if (bookings.isEmpty) {
      return Container(
        padding: const EdgeInsets.all(24),
        decoration: themeProvider.isDarkMode
            ? AppTheme.darkCardDecoration
            : AppTheme.cardDecoration,
        child: Column(
          children: [
            Icon(
              Icons.inbox_outlined,
              size: 48,
              color: themeProvider.isDarkMode
                  ? AppTheme.darkTextMuted
                  : AppTheme.textMuted,
            ),
            const SizedBox(height: 16),
            Text(
              'No recent bookings found',
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    color: themeProvider.isDarkMode
                        ? AppTheme.darkTextSecondary
                        : AppTheme.textSecondary,
                  ),
            ),
          ],
        ),
      );
    }

    return Container(
      decoration: themeProvider.isDarkMode
          ? AppTheme.darkCardDecoration
          : AppTheme.cardDecoration,
      child: Column(
        children: bookings.take(5).map((booking) {
          return _buildBookingItem(booking, themeProvider);
        }).toList(),
      ),
    );
  }

  Widget _buildBookingItem(dynamic booking, ThemeProvider themeProvider) {
    return InkWell(
      onTap: () => _showBookingDetails(context, booking),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: AppTheme.primaryColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(
                Icons.calendar_today,
                color: AppTheme.primaryColor,
                size: 20,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Booking #${booking.id.substring(0, 8)}',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '${booking.crop} - ${booking.boxNumbers.length} boxes',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: themeProvider.isDarkMode
                              ? AppTheme.darkTextSecondary
                              : AppTheme.textSecondary,
                        ),
                  ),
                ],
              ),
            ),
            _buildEnhancedStatusChip(booking.status),
          ],
        ),
      ),
    );
  }

  Widget _buildEnhancedStatusChip(String status) {
    Color color;
    switch (status.toLowerCase()) {
      case 'active':
        color = AppTheme.availableColor;
        break;
      case 'pending':
        color = AppTheme.warningColor;
        break;
      case 'completed':
        color = AppTheme.selectedColor;
        break;
      case 'cancelled':
        color = AppTheme.bookedColor;
        break;
      default:
        color = AppTheme.textSecondary;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Text(
        status.toUpperCase(),
        style: TextStyle(
          color: color,
          fontSize: 10,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  // Navigation methods
  void _navigateToBeeBoxManagement(BuildContext context) {
    NavigationHelper.pushWithTransition(
      context,
      const BeeBoxManagementScreen(),
      transition: TransitionType.slideUp,
    );
  }

  void _navigateToBookingManagement(BuildContext context) {
    NavigationHelper.pushWithTransition(
      context,
      const BookingManagementScreen(),
      transition: TransitionType.slideUp,
    );
  }

  void _navigateToUserManagement(BuildContext context) {
    NavigationHelper.pushWithTransition(
      context,
      const UserManagementScreen(),
      transition: TransitionType.slideUp,
    );
  }

  void _navigateToPaymentManagement(BuildContext context) {
    NavigationHelper.pushWithTransition(
      context,
      const PaymentManagementScreen(),
      transition: TransitionType.slideUp,
    );
  }

  Future<void> _confirmSignOut(BuildContext context) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Sign Out'),
        content: const Text('Are you sure you want to sign out?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.bookedColor,
            ),
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

  void _showBookingDetails(BuildContext context, dynamic booking) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
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
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Status update functionality coming soon!'),
                ),
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
}