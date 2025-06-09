import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../../../../core/constants/app_constants.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import '../widgets/booking_status_badge.dart';

class MyBookingsScreen extends StatefulWidget {
  const MyBookingsScreen({super.key});

  @override
  State<MyBookingsScreen> createState() => _MyBookingsScreenState();
}

class _MyBookingsScreenState extends State<MyBookingsScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final DateFormat _dateFormat = DateFormat('dd MMM yyyy');

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    final selectedLanguage = authProvider.selectedLanguage;

    return Scaffold(
      appBar: AppBar(
        title: Text(_getMyBookingsTitleText(selectedLanguage)),
        backgroundColor: AppTheme.primaryColor,
        foregroundColor: Colors.white,
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: Colors.white,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white.withOpacity(0.7),
          tabs: [
            Tab(text: _getActiveTabText(selectedLanguage)),
            Tab(text: _getCompletedTabText(selectedLanguage)),
            Tab(text: _getCancelledTabText(selectedLanguage)),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          // Active bookings tab
          _buildBookingsList(
            _getMockActiveBookings(),
            selectedLanguage,
            _getNoActiveBookingsText(selectedLanguage),
          ),
          // Completed bookings tab
          _buildBookingsList(
            _getMockCompletedBookings(),
            selectedLanguage,
            _getNoCompletedBookingsText(selectedLanguage),
          ),
          // Cancelled bookings tab
          _buildBookingsList(
            _getMockCancelledBookings(),
            selectedLanguage,
            _getNoCancelledBookingsText(selectedLanguage),
          ),
        ],
      ),
    );
  }

  Widget _buildBookingsList(List<Map<String, dynamic>> bookings, String languageCode, String emptyMessage) {
    if (bookings.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.event_busy,
              size: 64,
              color: Colors.grey.shade400,
            ),
            const SizedBox(height: 16),
            Text(
              emptyMessage,
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey.shade600,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: bookings.length,
      itemBuilder: (context, index) {
        final booking = bookings[index];
        return _buildBookingCard(booking, languageCode);
      },
    );
  }

  Widget _buildBookingCard(Map<String, dynamic> booking, String languageCode) {
    final startDate = booking['startDate'] as DateTime;
    final endDate = booking['endDate'] as DateTime;
    final status = booking['status'] as String;

    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  booking['bookingId'] as String,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: AppTheme.textPrimary,
                  ),
                ),
                BookingStatusBadge(status: status, languageCode: languageCode),
              ],
            ),
            const Divider(),
            _buildInfoRow(
              Icons.grass,
              _getCropText(languageCode),
              booking['crop'] as String,
            ),
            const SizedBox(height: 8),
            _buildInfoRow(
              Icons.location_on,
              _getLocationText(languageCode),
              booking['location'] as String,
            ),
            const SizedBox(height: 8),
            _buildInfoRow(
              Icons.calendar_today,
              _getDateRangeText(languageCode),
              '${_dateFormat.format(startDate)} - ${_dateFormat.format(endDate)}',
            ),
            const SizedBox(height: 8),
            _buildInfoRow(
              Icons.inventory_2,
              _getBoxesText(languageCode),
              '${booking['numberOfBoxes']} ${_getBoxesText(languageCode)}',
            ),
            const SizedBox(height: 8),
            _buildInfoRow(
              Icons.payments,
              _getTotalAmountText(languageCode),
              '₹${booking['totalAmount']}',
              valueColor: AppTheme.primaryColor,
              valueBold: true,
            ),
            if (status == 'active')
              Padding(
                padding: const EdgeInsets.only(top: 16.0),
                child: Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () => _showCancelDialog(languageCode, booking['bookingId'] as String),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: Colors.red,
                          side: const BorderSide(color: Colors.red),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        child: Text(_getCancelText(languageCode)),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () => _showBookingDetails(booking),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppTheme.primaryColor,
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        child: Text(_getViewDetailsText(languageCode)),
                      ),
                    ),
                  ],
                ),
              ),
            if (status != 'active')
              Padding(
                padding: const EdgeInsets.only(top: 16.0),
                child: SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () => _showBookingDetails(booking),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppTheme.primaryColor,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: Text(_getViewDetailsText(languageCode)),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String label, String value, {Color? valueColor, bool valueBold = false}) {
    return Row(
      children: [
        Icon(
          icon,
          size: 16,
          color: Colors.grey.shade600,
        ),
        const SizedBox(width: 8),
        Text(
          '$label: ',
          style: TextStyle(
            fontSize: 14,
            color: Colors.grey.shade600,
          ),
        ),
        Expanded(
          child: Text(
            value,
            style: TextStyle(
              fontSize: 14,
              color: valueColor ?? AppTheme.textPrimary,
              fontWeight: valueBold ? FontWeight.bold : FontWeight.normal,
            ),
          ),
        ),
      ],
    );
  }

  void _showCancelDialog(String languageCode, String bookingId) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(_getCancelBookingText(languageCode)),
        content: Text(_getCancelConfirmationText(languageCode)),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text(_getNoText(languageCode)),
          ),
          TextButton(
            onPressed: () {
              // Implement cancel booking logic here
              Navigator.of(context).pop();
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(_getBookingCancelledText(languageCode)),
                  backgroundColor: Colors.green,
                ),
              );
              // Refresh the bookings list
              setState(() {});
            },
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: Text(_getYesText(languageCode)),
          ),
        ],
      ),
    );
  }

  void _showBookingDetails(Map<String, dynamic> booking) {
    // Implement show booking details logic here
    // This could navigate to a detailed booking screen
  }

  // Mock data for bookings
  List<Map<String, dynamic>> _getMockActiveBookings() {
    return [
      {
        'bookingId': 'BEE123456',
        'crop': 'Sunflower',
        'location': 'Nashik, Maharashtra',
        'startDate': DateTime.now().add(const Duration(days: 5)),
        'endDate': DateTime.now().add(const Duration(days: 15)),
        'numberOfBoxes': 3,
        'totalAmount': 3300,
        'status': 'active',
      },
      {
        'bookingId': 'BEE123457',
        'crop': 'Apple',
        'location': 'Shimla, Himachal Pradesh',
        'startDate': DateTime.now().add(const Duration(days: 10)),
        'endDate': DateTime.now().add(const Duration(days: 25)),
        'numberOfBoxes': 5,
        'totalAmount': 7500,
        'status': 'active',
      },
    ];
  }

  List<Map<String, dynamic>> _getMockCompletedBookings() {
    return [
      {
        'bookingId': 'BEE123450',
        'crop': 'Mango',
        'location': 'Ratnagiri, Maharashtra',
        'startDate': DateTime.now().subtract(const Duration(days: 30)),
        'endDate': DateTime.now().subtract(const Duration(days: 15)),
        'numberOfBoxes': 4,
        'totalAmount': 6000,
        'status': 'completed',
      },
      {
        'bookingId': 'BEE123451',
        'crop': 'Strawberry',
        'location': 'Mahabaleshwar, Maharashtra',
        'startDate': DateTime.now().subtract(const Duration(days: 60)),
        'endDate': DateTime.now().subtract(const Duration(days: 45)),
        'numberOfBoxes': 2,
        'totalAmount': 3000,
        'status': 'completed',
      },
    ];
  }

  List<Map<String, dynamic>> _getMockCancelledBookings() {
    return [
      {
        'bookingId': 'BEE123452',
        'crop': 'Pomegranate',
        'location': 'Solapur, Maharashtra',
        'startDate': DateTime.now().subtract(const Duration(days: 20)),
        'endDate': DateTime.now().subtract(const Duration(days: 10)),
        'numberOfBoxes': 3,
        'totalAmount': 3300,
        'status': 'cancelled',
      },
    ];
  }

  // Multilingual text getters
  String _getMyBookingsTitleText(String languageCode) {
    switch (languageCode) {
      case AppConstants.hindi:
        return 'मेरी बुकिंग';
      case AppConstants.marathi:
        return 'माझी बुकिंग';
      default:
        return 'My Bookings';
    }
  }

  String _getActiveTabText(String languageCode) {
    switch (languageCode) {
      case AppConstants.hindi:
        return 'सक्रिय';
      case AppConstants.marathi:
        return 'सक्रिय';
      default:
        return 'Active';
    }
  }

  String _getCompletedTabText(String languageCode) {
    switch (languageCode) {
      case AppConstants.hindi:
        return 'पूर्ण';
      case AppConstants.marathi:
        return 'पूर्ण';
      default:
        return 'Completed';
    }
  }

  String _getCancelledTabText(String languageCode) {
    switch (languageCode) {
      case AppConstants.hindi:
        return 'रद्द';
      case AppConstants.marathi:
        return 'रद्द';
      default:
        return 'Cancelled';
    }
  }

  String _getNoActiveBookingsText(String languageCode) {
    switch (languageCode) {
      case AppConstants.hindi:
        return 'कोई सक्रिय बुकिंग नहीं है';
      case AppConstants.marathi:
        return 'कोणतीही सक्रिय बुकिंग नाही';
      default:
        return 'No active bookings';
    }
  }

  String _getNoCompletedBookingsText(String languageCode) {
    switch (languageCode) {
      case AppConstants.hindi:
        return 'कोई पूर्ण बुकिंग नहीं है';
      case AppConstants.marathi:
        return 'कोणतीही पूर्ण बुकिंग नाही';
      default:
        return 'No completed bookings';
    }
  }

  String _getNoCancelledBookingsText(String languageCode) {
    switch (languageCode) {
      case AppConstants.hindi:
        return 'कोई रद्द बुकिंग नहीं है';
      case AppConstants.marathi:
        return 'कोणतीही रद्द बुकिंग नाही';
      default:
        return 'No cancelled bookings';
    }
  }

  String _getCropText(String languageCode) {
    switch (languageCode) {
      case AppConstants.hindi:
        return 'फसल';
      case AppConstants.marathi:
        return 'पीक';
      default:
        return 'Crop';
    }
  }

  String _getLocationText(String languageCode) {
    switch (languageCode) {
      case AppConstants.hindi:
        return 'स्थान';
      case AppConstants.marathi:
        return 'स्थान';
      default:
        return 'Location';
    }
  }

  String _getDateRangeText(String languageCode) {
    switch (languageCode) {
      case AppConstants.hindi:
        return 'तारीख सीमा';
      case AppConstants.marathi:
        return 'तारीख श्रेणी';
      default:
        return 'Date Range';
    }
  }

  String _getBoxesText(String languageCode) {
    switch (languageCode) {
      case AppConstants.hindi:
        return 'बक्से';
      case AppConstants.marathi:
        return 'बॉक्स';
      default:
        return 'Boxes';
    }
  }

  String _getTotalAmountText(String languageCode) {
    switch (languageCode) {
      case AppConstants.hindi:
        return 'कुल राशि';
      case AppConstants.marathi:
        return 'एकूण रक्कम';
      default:
        return 'Total Amount';
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

  String _getViewDetailsText(String languageCode) {
    switch (languageCode) {
      case AppConstants.hindi:
        return 'विवरण देखें';
      case AppConstants.marathi:
        return 'तपशील पहा';
      default:
        return 'View Details';
    }
  }

  String _getCancelBookingText(String languageCode) {
    switch (languageCode) {
      case AppConstants.hindi:
        return 'बुकिंग रद्द करें';
      case AppConstants.marathi:
        return 'बुकिंग रद्द करा';
      default:
        return 'Cancel Booking';
    }
  }

  String _getCancelConfirmationText(String languageCode) {
    switch (languageCode) {
      case AppConstants.hindi:
        return 'क्या आप वाकई इस बुकिंग को रद्द करना चाहते हैं? यह क्रिया पूर्ववत नहीं की जा सकती है।';
      case AppConstants.marathi:
        return 'तुम्हाला खरंच ही बुकिंग रद्द करायची आहे का? ही क्रिया पूर्ववत केली जाऊ शकत नाही.';
      default:
        return 'Are you sure you want to cancel this booking? This action cannot be undone.';
    }
  }

  String _getNoText(String languageCode) {
    switch (languageCode) {
      case AppConstants.hindi:
        return 'नहीं';
      case AppConstants.marathi:
        return 'नाही';
      default:
        return 'No';
    }
  }

  String _getYesText(String languageCode) {
    switch (languageCode) {
      case AppConstants.hindi:
        return 'हां';
      case AppConstants.marathi:
        return 'होय';
      default:
        return 'Yes';
    }
  }

  String _getBookingCancelledText(String languageCode) {
    switch (languageCode) {
      case AppConstants.hindi:
        return 'आपकी बुकिंग सफलतापूर्वक रद्द कर दी गई है';
      case AppConstants.marathi:
        return 'तुमची बुकिंग यशस्वीरित्या रद्द केली गेली आहे';
      default:
        return 'Your booking has been successfully cancelled';
    }
  }
}