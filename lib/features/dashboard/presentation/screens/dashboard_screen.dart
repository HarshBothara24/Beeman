import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../core/constants/app_constants.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import '../../../auth/presentation/screens/login_screen.dart';
import '../../../auth/presentation/screens/language_selection_screen.dart';
import '../../../booking/presentation/screens/bee_box_selection_screen.dart';
import '../../../booking/presentation/screens/my_bookings_screen.dart';
import '../../../payment/presentation/screens/payment_history_screen.dart';
import '../widgets/dashboard_drawer.dart';
import '../widgets/feature_card.dart';

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    final user = authProvider.user;
    final selectedLanguage = authProvider.selectedLanguage;

    return Scaffold(
      appBar: AppBar(
        title: const Text('BeeMan Dashboard'),
        backgroundColor: AppTheme.primaryColor,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      drawer: const DashboardDrawer(),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Section: Welcome
                Card(
                  elevation: 2,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(20.0),
                    child: Row(
                      children: [
                        CircleAvatar(
                          radius: 32,
                          backgroundColor: AppTheme.primaryColor,
                          child: Text(
                            user?.displayName?.substring(0, 1).toUpperCase() ??
                                'U',
                            style: const TextStyle(
                              fontSize: 26,
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
                                user?.displayName ?? 'User',
                                style: const TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                user?.email ?? '',
                                style: const TextStyle(
                                  fontSize: 14,
                                  color: AppTheme.textSecondary,
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
                // Section: Quick Actions
                const Text(
                  'Quick Actions',
                  style: TextStyle(
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
                        _animatedFeatureCard(
                          title: _getBookingText(selectedLanguage),
                          subtitle: _getBookingSubtitleText(selectedLanguage),
                          icon: Icons.calendar_today,
                          color: Colors.amber,
                          onTap: () => _navigateToBooking(context),
                        ),
                        _animatedFeatureCard(
                          title: _getMyBookingsText(selectedLanguage),
                          subtitle: _getMyBookingsSubtitleText(
                            selectedLanguage,
                          ),
                          icon: Icons.history,
                          color: Colors.green,
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => const MyBookingsScreen(),
                              ),
                            );
                          },
                        ),
                        _animatedFeatureCard(
                          title: _getPaymentsText(selectedLanguage),
                          subtitle: _getPaymentsSubtitleText(selectedLanguage),
                          icon: Icons.payment,
                          color: Colors.purple,
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => const PaymentHistoryScreen(),
                              ),
                            );
                          },
                        ),
                        _animatedFeatureCard(
                          title: _getSupportText(selectedLanguage),
                          subtitle: _getSupportSubtitleText(selectedLanguage),
                          icon: Icons.support_agent,
                          color: Colors.blue,
                          onTap: () {
                            // Navigate to support screen
                          },
                        ),
                      ],
                    );
                  },
                ),
                const SizedBox(height: 32),
                // Section: Info
                const Text(
                  'Your Activity',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: AppTheme.textPrimary,
                  ),
                ),
                const SizedBox(height: 16),
                // Add more user activity widgets here as needed
              ],
            ),
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        heroTag: 'language_fab',
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

  Widget _animatedFeatureCard({
    required String title,
    required String subtitle,
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
  }) {
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
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: onTap,
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
              textAlign: TextAlign.center,
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
