import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../core/constants/app_constants.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import '../../../auth/presentation/screens/login_screen.dart';
import '../../../booking/presentation/screens/booking_screen.dart';
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
        title: Text(_getWelcomeText(selectedLanguage)),
        backgroundColor: AppTheme.primaryColor,
        foregroundColor: Colors.white,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications),
            onPressed: () {
              // Navigate to notifications screen
            },
          ),
        ],
      ),
      drawer: const DashboardDrawer(),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header section with greeting and user info
              Container(
                padding: const EdgeInsets.all(16),
                decoration: const BoxDecoration(
                  color: AppTheme.primaryColor,
                  borderRadius: BorderRadius.only(
                    bottomLeft: Radius.circular(24),
                    bottomRight: Radius.circular(24),
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        CircleAvatar(
                          radius: 30,
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
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                _getGreetingText(selectedLanguage),
                                style: const TextStyle(
                                  fontSize: 16,
                                  color: Colors.white70,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                user?.displayName ?? 'User',
                                style: const TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),
                    // Quick booking button
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: () => _navigateToBooking(context),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.white,
                          foregroundColor: AppTheme.primaryColor,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: Text(
                          _getBookNowText(selectedLanguage),
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              // Features section
              Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      _getFeaturesText(selectedLanguage),
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: AppTheme.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 16),
                    // Feature cards grid
                    GridView.count(
                      crossAxisCount: 2,
                      crossAxisSpacing: 16,
                      mainAxisSpacing: 16,
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      children: [
                        // Book Bee Boxes
                        FeatureCard(
                          title: _getBookingText(selectedLanguage),
                          subtitle: _getBookingSubtitleText(selectedLanguage),
                          icon: Icons.calendar_today,
                          color: Colors.amber,
                          onTap: () => _navigateToBooking(context),
                        ),
                        // My Bookings
                        FeatureCard(
                          title: _getMyBookingsText(selectedLanguage),
                          subtitle: _getMyBookingsSubtitleText(selectedLanguage),
                          icon: Icons.history,
                          color: Colors.green,
                          onTap: () {
                            // Navigate to my bookings screen
                          },
                        ),
                        // Payments
                        FeatureCard(
                          title: _getPaymentsText(selectedLanguage),
                          subtitle: _getPaymentsSubtitleText(selectedLanguage),
                          icon: Icons.payment,
                          color: Colors.purple,
                          onTap: () {
                            // Navigate to payments screen
                          },
                        ),
                        // Support
                        FeatureCard(
                          title: _getSupportText(selectedLanguage),
                          subtitle: _getSupportSubtitleText(selectedLanguage),
                          icon: Icons.support_agent,
                          color: Colors.blue,
                          onTap: () {
                            // Navigate to support screen
                          },
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              // Information section
              Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      _getInformationText(selectedLanguage),
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: AppTheme.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 16),
                    // Information card
                    Card(
                      elevation: 2,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                const Icon(
                                  Icons.info,
                                  color: AppTheme.primaryColor,
                                ),
                                const SizedBox(width: 8),
                                Text(
                                  _getAboutBeesText(selectedLanguage),
                                  style: const TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                    color: AppTheme.textPrimary,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 16),
                            Text(
                              _getBeeInfoText(selectedLanguage),
                              style: const TextStyle(
                                fontSize: 14,
                                color: AppTheme.textSecondary,
                              ),
                            ),
                            const SizedBox(height: 16),
                            ElevatedButton(
                              onPressed: () {
                                // Navigate to more information screen
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: AppTheme.primaryColor,
                                foregroundColor: Colors.white,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8),
                                ),
                              ),
                              child: Text(_getLearnMoreText(selectedLanguage)),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _navigateToBooking(BuildContext context) {
    Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => const BookingScreen()),
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