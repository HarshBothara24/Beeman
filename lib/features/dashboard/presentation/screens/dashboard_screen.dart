import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../core/constants/app_constants.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/widgets/animated_loading.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import '../../../auth/presentation/screens/login_screen.dart';
import '../../../auth/presentation/screens/language_selection_screen.dart';
import '../../../booking/presentation/screens/bee_box_selection_screen.dart';
import '../../../booking/presentation/screens/my_bookings_screen.dart';
import '../../../payment/presentation/screens/payment_history_screen.dart';
import '../widgets/dashboard_drawer.dart';
import '../widgets/feature_card.dart';
import '../providers/dashboard_provider.dart';
import '../../../support/presentation/screens/support_screen.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen>
    with TickerProviderStateMixin {
  late AnimationController _fadeController;
  late AnimationController _slideController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
    _initializeAnimations();
    // Fetch dashboard stats after first build
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      final user = authProvider.user;
      if (user != null) {
        Provider.of<DashboardProvider>(context, listen: false)
            .fetchDashboardStats(user.uid ?? user.email ?? '');
      }
    });
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

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    final user = authProvider.user;
    final selectedLanguage = authProvider.selectedLanguage;
    final dashboardProvider = Provider.of<DashboardProvider>(context);

    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: AppTheme.backgroundGradient,
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
                          Text(
                            _getGreetingText(selectedLanguage),
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 16,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            user?.displayName ?? 'User',
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
                  icon: const Icon(Icons.language, color: Colors.white),
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const LanguageSelectionScreen(),
                      ),
                    );
                  },
                ),
                IconButton(
                  icon: const Icon(Icons.notifications_outlined, color: Colors.white),
                  onPressed: () {
                    // TODO: Navigate to notifications
                  },
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
                            _buildWelcomeCard(user),
                            const SizedBox(height: 24),

                            // Quick Stats
                            if (dashboardProvider.isLoading)
                              const Center(child: CircularProgressIndicator()),
                            if (dashboardProvider.error != null)
                              Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: Text(
                                  'Error: ${dashboardProvider.error}',
                                  style: const TextStyle(color: Colors.red),
                                ),
                              ),
                            if (!dashboardProvider.isLoading && dashboardProvider.error == null)
                              _buildQuickStats(
                                dashboardProvider.activeBookings,
                                dashboardProvider.totalSpent,
                                dashboardProvider.beeBoxes,
                              ),
                            const SizedBox(height: 32),

                            // Quick Actions Section
                            _buildSectionHeader('Quick Actions', selectedLanguage),
                            const SizedBox(height: 16),
                            _buildQuickActions(selectedLanguage),
                            const SizedBox(height: 32),

                            // Recent Activity Section
                            _buildSectionHeader('Recent Activity', selectedLanguage),
                            const SizedBox(height: 16),
                            _buildRecentActivity(),
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
      drawer: const DashboardDrawer(),
    );
  }

  Widget _buildWelcomeCard(user) {
    return Container(
      decoration: AppTheme.cardDecoration,
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Row(
          children: [
            Hero(
              tag: 'user_avatar',
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
                child: Center(
                  child: Text(
                    user?.displayName?.substring(0, 1).toUpperCase() ?? 'U',
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
                    'Welcome back!',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: AppTheme.textSecondary,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    user?.displayName ?? 'User',
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    user?.email ?? '',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: AppTheme.textMuted,
                    ),
                  ),
                ],
              ),
            ),
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: AppTheme.availableColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(
                Icons.verified_user,
                color: AppTheme.availableColor,
                size: 20,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildQuickStats([int? activeBookings, int? totalSpent, int? beeBoxes]) {
    return Row(
      children: [
        Expanded(
          child: _buildStatCard(
            'Active Bookings',
            activeBookings?.toString() ?? '0',
            Icons.calendar_today,
            AppTheme.warningColor,
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: _buildStatCard(
            'Total Spent',
            totalSpent != null ? '₹${totalSpent}' : '₹0',
            Icons.currency_rupee,
            AppTheme.availableColor,
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: _buildStatCard(
            'Bee Boxes',
            beeBoxes?.toString() ?? '0',
            Icons.inventory,
            AppTheme.infoColor,
          ),
        ),
      ],
    );
  }

  Widget _buildStatCard(String title, String value, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.surfaceColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppTheme.dividerColor, width: 0.5),
        boxShadow: [AppTheme.cardShadow],
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
              color: AppTheme.textPrimary,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            title,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: AppTheme.textSecondary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title, String selectedLanguage) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          title,
          style: Theme.of(context).textTheme.headlineSmall?.copyWith(
            fontWeight: FontWeight.bold,
            color: AppTheme.textPrimary,
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

  Widget _buildQuickActions(String selectedLanguage) {
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
            EnhancedFeatureCard(
              title: _getBookingText(selectedLanguage),
              subtitle: _getBookingSubtitleText(selectedLanguage),
              icon: Icons.calendar_today,
              color: AppTheme.warningColor,
              onTap: () => _navigateToBooking(context),
              isNew: true,
            ),
            EnhancedFeatureCard(
              title: _getMyBookingsText(selectedLanguage),
              subtitle: _getMyBookingsSubtitleText(selectedLanguage),
              icon: Icons.history,
              color: AppTheme.availableColor,
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => const MyBookingsScreen(),
                  ),
                );
              },
            ),
            EnhancedFeatureCard(
              title: _getPaymentsText(selectedLanguage),
              subtitle: _getPaymentsSubtitleText(selectedLanguage),
              icon: Icons.payment,
              color: AppTheme.infoColor,
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => const PaymentHistoryScreen(),
                  ),
                );
              },
            ),
            EnhancedFeatureCard(
              title: _getSupportText(selectedLanguage),
              subtitle: _getSupportSubtitleText(selectedLanguage),
              icon: Icons.support_agent,
              color: AppTheme.selectedColor,
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => const SupportScreen(),
                    settings: RouteSettings(arguments: selectedLanguage),
                  ),
                );
              },
            ),
          ],
        );
      },
    );
  }

  Widget _buildRecentActivity() {
    return Container(
      decoration: AppTheme.cardDecoration,
      child: Column(
        children: [
          _buildActivityItem(
            'Booking Confirmed',
            'Your bee box booking for Farm A has been confirmed',
            Icons.check_circle,
            AppTheme.availableColor,
            '2 hours ago',
          ),
          const Divider(height: 1),
          _buildActivityItem(
            'Payment Received',
            'Payment of ₹2,500 has been processed successfully',
            Icons.payment,
            AppTheme.selectedColor,
            '1 day ago',
          ),
          const Divider(height: 1),
          _buildActivityItem(
            'Booking Reminder',
            'Your bee box rental period ends in 3 days',
            Icons.schedule,
            AppTheme.warningColor,
            '2 days ago',
          ),
        ],
      ),
    );
  }

  Widget _buildActivityItem(
    String title,
    String subtitle,
    IconData icon,
    Color color,
    String time,
  ) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, color: color, size: 20),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  subtitle,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: AppTheme.textSecondary,
                  ),
                ),
              ],
            ),
          ),
          Text(
            time,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: AppTheme.textMuted,
            ),
          ),
        ],
      ),
    );
  }


  void _navigateToBooking(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const BeeBoxSelectionScreen()),
    );
  }

  Future<void> _signOut(BuildContext context) async {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    await authProvider.signOut();

    if (context.mounted) {
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (_) => const LoginScreen()),
        (route) => false,
      );
    }
  }

  // Multilingual text getters
  String _getWelcomeText(String languageCode) {
    switch (languageCode) {
      case AppConstants.hindi:
        return 'बीमैन';
      case AppConstants.marathi:
        return 'बीमॅन';
      default:
        return 'BeeMan';
    }
  }

  String _getGreetingText(String languageCode) {
    final hour = DateTime.now().hour;
    String greeting;

    if (hour < 12) {
      greeting = 'Good Morning';
    } else if (hour < 17) {
      greeting = 'Good Afternoon';
    } else {
      greeting = 'Good Evening';
    }

    switch (languageCode) {
      case AppConstants.hindi:
        if (hour < 12) {
          return 'सुप्रभात';
        } else if (hour < 17) {
          return 'शुभ दोपहर';
        } else {
          return 'शुभ संध्या';
        }
      case AppConstants.marathi:
        if (hour < 12) {
          return 'सुप्रभात';
        } else if (hour < 17) {
          return 'शुभ दुपार';
        } else {
          return 'शुभ संध्याकाळ';
        }
      default:
        return greeting;
    }
  }

  String _getBookNowText(String languageCode) {
    switch (languageCode) {
      case AppConstants.hindi:
        return 'अभी बुक करें';
      case AppConstants.marathi:
        return 'आता बुक करा';
      default:
        return 'Book Now';
    }
  }

  String _getFeaturesText(String languageCode) {
    switch (languageCode) {
      case AppConstants.hindi:
        return 'सुविधाएँ';
      case AppConstants.marathi:
        return 'वैशिष्ट्ये';
      default:
        return 'Features';
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

  String _getBookingSubtitleText(String languageCode) {
    switch (languageCode) {
      case AppConstants.hindi:
        return 'मधुमक्खी के बक्से किराए पर लें';
      case AppConstants.marathi:
        return 'मधमाशांचे बॉक्स भाड्याने घ्या';
      default:
        return 'Rent bee boxes for pollination';
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

  String _getMyBookingsSubtitleText(String languageCode) {
    switch (languageCode) {
      case AppConstants.hindi:
        return 'अपनी बुकिंग देखें';
      case AppConstants.marathi:
        return 'तुमची बुकिंग पहा';
      default:
        return 'View your bookings';
    }
  }

  String _getPaymentsText(String languageCode) {
    switch (languageCode) {
      case AppConstants.hindi:
        return 'भुगतान';
      case AppConstants.marathi:
        return 'पेमेंट';
      default:
        return 'Payments';
    }
  }

  String _getPaymentsSubtitleText(String languageCode) {
    switch (languageCode) {
      case AppConstants.hindi:
        return 'भुगतान इतिहास देखें';
      case AppConstants.marathi:
        return 'पेमेंट इतिहास पहा';
      default:
        return 'View payment history';
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

  String _getSupportSubtitleText(String languageCode) {
    switch (languageCode) {
      case AppConstants.hindi:
        return 'सहायता प्राप्त करें';
      case AppConstants.marathi:
        return 'मदत मिळवा';
      default:
        return 'Get help and support';
    }
  }

  String _getInformationText(String languageCode) {
    switch (languageCode) {
      case AppConstants.hindi:
        return 'जानकारी';
      case AppConstants.marathi:
        return 'माहिती';
      default:
        return 'Information';
    }
  }

  String _getAboutBeesText(String languageCode) {
    switch (languageCode) {
      case AppConstants.hindi:
        return 'मधुमक्खियों के बारे में';
      case AppConstants.marathi:
        return 'मधमाश्यांबद्दल';
      default:
        return 'About Bees';
    }
  }

  String _getBeeInfoText(String languageCode) {
    switch (languageCode) {
      case AppConstants.hindi:
        return 'मधुमक्खियां फसलों के परागण में महत्वपूर्ण भूमिका निभाती हैं। वे फूलों से फूलों तक परागकण ले जाती हैं, जिससे फसल उत्पादन बढ़ता है और फसल की गुणवत्ता में सुधार होता है।';
      case AppConstants.marathi:
        return 'मधमाश्या पिकांच्या परागीभवनात महत्त्वाची भूमिका बजावतात. त्या फुलांमधून फुलांमध्ये परागकण वाहून नेतात, ज्यामुळे पीक उत्पादन वाढते आणि पिकाच्या गुणवत्तेत सुधारणा होते.';
      default:
        return 'Bees play a crucial role in crop pollination. They transfer pollen from flower to flower, which increases crop production and improves crop quality.';
    }
  }

  String _getLearnMoreText(String languageCode) {
    switch (languageCode) {
      case AppConstants.hindi:
        return 'अधिक जानें';
      case AppConstants.marathi:
        return 'अधिक जाणून घ्या';
      default:
        return 'Learn More';
    }
  }
}
