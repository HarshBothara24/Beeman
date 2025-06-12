import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:provider/provider.dart';
import 'package:flutter/foundation.dart' show kIsWeb;

import 'core/config/firebase_options.dart';
import 'core/theme/app_theme.dart';
import 'features/auth/presentation/providers/auth_provider.dart';
import 'features/auth/presentation/screens/splash_screen.dart';
import 'features/booking/presentation/providers/booking_provider.dart';
import 'features/auth/presentation/screens/language_selection_screen.dart';
import 'widgets/adaptive_layout.dart';
import 'constants/breakpoints.dart';
import 'utils/responsive_utils.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  try {
    // Initialize Firebase
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
    print('Firebase initialized successfully');
  } catch (e) {
    print('Failed to initialize Firebase: $e');
    // Continue without Firebase for development purposes
  }
  
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProvider(create: (_) => BookingProvider()),
      ],
      child: Consumer<AuthProvider>(
        builder: (context, authProvider, child) {
          if (!authProvider.hasSelectedLanguage) {
            return const LanguageSelectionScreen();
          }
          
          return MaterialApp(
            title: 'BeeMan',
            debugShowCheckedModeBanner: false,
            theme: AppTheme.lightTheme,
            supportedLocales: const [
              Locale('en', ''), // English
              Locale('hi', ''), // Hindi
              Locale('mr', ''), // Marathi
            ],
            localizationsDelegates: const [
              GlobalMaterialLocalizations.delegate,
              GlobalWidgetsLocalizations.delegate,
              GlobalCupertinoLocalizations.delegate,
            ],
            home: const SplashScreen(),
          );
        },
      ),
    );
  }
}

class HomeScreen extends StatelessWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Adjust layout based on platform
    final isWebPlatform = kIsWeb;
    
    return Scaffold(
      appBar: AppBar(
        title: const Text('BeeMan'),
        elevation: 0,
        // Add responsive actions for web
        actions: isWebPlatform ? [
          IconButton(
            icon: const Icon(Icons.account_circle),
            onPressed: () {},
          ),
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () {},
          ),
        ] : null,
      ),
      body: SafeArea(
        child: Center(
          child: LayoutBuilder(
            builder: (context, constraints) {
              return Container(
                constraints: BoxConstraints(
                  maxWidth: Breakpoints.maxContentWidth,
                  minWidth: Breakpoints.minContentWidth,
                ),
                child: AdaptiveLayout(
                  mobile: _buildMobileLayout(context),
                  tablet: _buildTabletLayout(context),
                  desktop: _buildDesktopLayout(context),
                ),
              );
            },
          ),
        ),
      ),
    );
  }

  Widget _buildMobileLayout(BuildContext context) {
    return SingleChildScrollView(
      padding: EdgeInsets.all(ResponsiveUtils.getResponsivePadding(context)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _buildWelcomeSection(context),
          SizedBox(height: ResponsiveUtils.getResponsivePadding(context)),
          _buildNavigationGrid(context),
        ],
      ),
    );
  }

  Widget _buildTabletLayout(BuildContext context) {
    return Row(
      children: [
        SizedBox(
          width: ResponsiveUtils.getAdaptiveWidth(context, 0.3),
          child: _buildNavigationCards(context),
        ),
        Expanded(
          child: SingleChildScrollView(
            padding: EdgeInsets.all(ResponsiveUtils.getResponsivePadding(context)),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildWelcomeSection(context),
                SizedBox(height: ResponsiveUtils.getResponsivePadding(context)),
                _buildDashboardGrid(context, 2),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildDesktopLayout(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: ResponsiveUtils.getAdaptiveWidth(context, 0.2),
          child: _buildNavigationCards(context),
        ),
        Expanded(
          child: SingleChildScrollView(
            padding: EdgeInsets.all(ResponsiveUtils.getResponsivePadding(context)),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildWelcomeSection(context),
                SizedBox(height: ResponsiveUtils.getResponsivePadding(context)),
                _buildDashboardGrid(context, 3),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildNavigationGrid(BuildContext context) {
    return GridView.count(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisCount: ResponsiveUtils.isMobile(context) ? 2 : 3,
      mainAxisSpacing: Breakpoints.mediumPadding,
      crossAxisSpacing: Breakpoints.mediumPadding,
      children: [
        _buildNavCard(
          context,
          'Book Bee Boxes',
          Icons.hive,
          'Rent bee boxes for pollination',
          () {},
        ),
        _buildNavCard(
          context,
          'My Bookings',
          Icons.calendar_today,
          'View your bookings',
          () {},
        ),
        _buildNavCard(
          context,
          'Analytics',
          Icons.analytics,
          'View performance metrics',
          () {},
        ),
      ],
    );
  }

  Widget _buildNavCard(BuildContext context, String title, IconData icon,
      String subtitle, VoidCallback onTap) {
    return Card(
      elevation: 2,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(8),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, size: 32),
              const SizedBox(height: 8),
              Text(
                title,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 4),
              Text(
                subtitle,
                style: const TextStyle(
                  fontSize: 12,
                  color: Colors.grey,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildWelcomeSection(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: const [
        Text(
          'Welcome to BeeMan',
          style: TextStyle(
            fontSize: 28,
            fontWeight: FontWeight.bold,
          ),
        ),
        SizedBox(height: 8),
        Text(
          'Manage your hives and monitor your bees',
          style: TextStyle(
            fontSize: 16,
            color: Colors.grey,
          ),
        ),
      ],
    );
  }

  Widget _buildNavigationCards(BuildContext context) {
    return Column(
      children: [
        Card(
          elevation: 0,
          child: ListTile(
            leading: const Icon(Icons.hive),
            title: const Text('My Hives'),
            onTap: () {
              // Navigate to hives screen
            },
          ),
        ),
        Card(
          elevation: 0,
          child: ListTile(
            leading: const Icon(Icons.analytics),
            title: const Text('Analytics'),
            onTap: () {
              // Navigate to analytics screen
            },
          ),
        ),
      ],
    );
  }

  Widget _buildDashboardGrid(BuildContext context, int crossAxisCount) {
    return GridView.count(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisCount: crossAxisCount,
      mainAxisSpacing: Breakpoints.mediumPadding,
      crossAxisSpacing: Breakpoints.mediumPadding,
      children: [
        _buildDashboardCard(
          context,
          'Total Hives',
          '24',
          Icons.hive,
          Colors.amber,
        ),
        _buildDashboardCard(
          context,
          'Active Bookings',
          '12',
          Icons.calendar_today,
          Colors.green,
        ),
        _buildDashboardCard(
          context,
          'Revenue',
          '₹45,000',
          Icons.currency_rupee,
          Colors.blue,
        ),
        _buildDashboardCard(
          context,
          'Performance',
          '92%',
          Icons.trending_up,
          Colors.purple,
        ),
      ],
    );
  }

  Widget _buildDashboardCard(
    BuildContext context,
    String title,
    String value,
    IconData icon,
    Color color,
  ) {
    return Card(
      elevation: 2,
      child: Padding(
        padding: EdgeInsets.all(ResponsiveUtils.getResponsivePadding(context)),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              size: Breakpoints.iconSize,
              color: color,
            ),
            const SizedBox(height: 16),
            Text(
              value,
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              title,
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[600],
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
