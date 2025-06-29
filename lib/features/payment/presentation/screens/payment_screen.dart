import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import '../../../../core/constants/app_constants.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import '../../../dashboard/presentation/screens/dashboard_screen.dart';
import '../../../booking/presentation/providers/booking_provider.dart';
import '../../../booking/domain/models/booking_model.dart';
import '../widgets/payment_method_card.dart';
import '../../../../core/services/firestore_service.dart';
import '../../../../core/models/firestore_models.dart';

class PaymentScreen extends StatefulWidget {
  final Map<String, dynamic> bookingDetails;

  const PaymentScreen({
    super.key,
    required this.bookingDetails,
  });

  @override
  State<PaymentScreen> createState() => _PaymentScreenState();
}

class _PaymentScreenState extends State<PaymentScreen> {
  String _selectedPaymentMethod = 'upi';
  bool _isProcessing = false;
  final DateFormat _dateFormat = DateFormat('dd MMM yyyy');

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    final selectedLanguage = authProvider.selectedLanguage;

    return Scaffold(
      appBar: AppBar(
        title: Text(_getPaymentTitleText(selectedLanguage)),
        backgroundColor: AppTheme.primaryColor,
        foregroundColor: Colors.white,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Booking summary card
                _buildBookingSummaryCard(selectedLanguage),
                const SizedBox(height: 24),
                // Payment methods
                Text(
                  _getPaymentMethodText(selectedLanguage),
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: AppTheme.textPrimary,
                  ),
                ),
                const SizedBox(height: 16),
                // UPI payment method
                PaymentMethodCard(
                  title: 'UPI',
                  subtitle: _getUpiDescriptionText(selectedLanguage),
                  icon: Icons.account_balance,
                  isSelected: _selectedPaymentMethod == 'upi',
                  onTap: () {
                    setState(() {
                      _selectedPaymentMethod = 'upi';
                    });
                  },
                ),
                const SizedBox(height: 12),
                // Cash payment method
                PaymentMethodCard(
                  title: _getCashText(selectedLanguage),
                  subtitle: _getCashDescriptionText(selectedLanguage),
                  icon: Icons.money,
                  isSelected: _selectedPaymentMethod == 'cash',
                  onTap: () {
                    setState(() {
                      _selectedPaymentMethod = 'cash';
                    });
                  },
                ),
                const SizedBox(height: 24),
                // Payment button
                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: ElevatedButton(
                    onPressed: _isProcessing ? null : () => _processPayment(selectedLanguage),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppTheme.primaryColor,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      disabledBackgroundColor: Colors.grey.shade400,
                    ),
                    child: _isProcessing
                        ? const CircularProgressIndicator(
                            valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                          )
                        : Text(
                            _getPayNowText(selectedLanguage),
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                  ),
                ),
                const SizedBox(height: 16),
                // Payment note
                Text(
                  _getPaymentNoteText(selectedLanguage),
                  style: const TextStyle(
                    fontSize: 12,
                    color: AppTheme.textSecondary,
                    fontStyle: FontStyle.italic,
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildBookingSummaryCard(String languageCode) {
    final startDate = widget.bookingDetails['startDate'] as DateTime;
    final endDate = widget.bookingDetails['endDate'] as DateTime;
    final numberOfBoxes = widget.bookingDetails['numberOfBoxes'] as int;
    final days = widget.bookingDetails['days'] as int;
    final totalRent = widget.bookingDetails['totalRent'] as int;
    final depositAmount = widget.bookingDetails['depositAmount'] as int;

    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              _getBookingSummaryText(languageCode),
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: AppTheme.textPrimary,
              ),
            ),
            const SizedBox(height: 16),
            // Booking details
            _buildSummaryRow(
              _getCropText(languageCode),
              widget.bookingDetails['crop'] as String,
            ),
            const SizedBox(height: 8),
            _buildSummaryRow(
              _getLocationText(languageCode),
              widget.bookingDetails['location'] as String,
            ),
            const SizedBox(height: 8),
            _buildSummaryRow(
              _getDateRangeText(languageCode),
              '${_dateFormat.format(startDate)} - ${_dateFormat.format(endDate)}',
            ),
            const SizedBox(height: 8),
            _buildSummaryRow(
              _getDurationText(languageCode),
              '$days ${_getDaysText(languageCode)}',
            ),
            const SizedBox(height: 8),
            _buildSummaryRow(
              _getBoxesText(languageCode),
              '$numberOfBoxes',
            ),
            const Divider(),
            _buildSummaryRow(
              _getTotalRentText(languageCode),
              '₹$totalRent',
              isBold: true,
            ),
            const SizedBox(height: 8),
            _buildSummaryRow(
              _getDepositText(languageCode),
              '₹$depositAmount (${AppConstants.depositPercentage}%)',
              isBold: true,
              textColor: AppTheme.primaryColor,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSummaryRow(String label, String value, {bool isBold = false, Color? textColor}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 14,
            color: AppTheme.textSecondary,
            fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
          ),
        ),
        Text(
          value,
          style: TextStyle(
            fontSize: 14,
            color: textColor ?? AppTheme.textPrimary,
            fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
          ),
        ),
      ],
    );
  }

  Future<void> _processPayment(String languageCode) async {
    setState(() {
      _isProcessing = true;
    });

    // Simulate payment processing
    await Future.delayed(const Duration(seconds: 2));

    // Show success dialog
    if (mounted) {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      final bookingProvider = Provider.of<BookingProvider>(context, listen: false);

      try {
        // Create booking in Firestore using the correct service
        final bookingId = await FirestoreService.createBooking(
          userId: authProvider.user?.uid ?? '',
          beeBoxId: 'bee_box_001', // Default bee box ID - you can make this dynamic later
          startDate: widget.bookingDetails['startDate'],
          endDate: widget.bookingDetails['endDate'],
          quantity: widget.bookingDetails['numberOfBoxes'],
          totalAmount: widget.bookingDetails['totalRent'].toDouble(),
          notes: widget.bookingDetails['notes'] ?? '',
        );

        // Also create a payment record
        await FirestoreService.createPayment(
          bookingId: bookingId,
          userId: authProvider.user?.uid ?? '',
          amount: widget.bookingDetails['totalRent'].toDouble(),
          paymentMethod: _selectedPaymentMethod == 'upi' ? 'UPI' : 'Cash',
          status: 'completed',
          transactionId: 'TXN_${DateTime.now().millisecondsSinceEpoch}',
        );

        showDialog(
          context: context,
          barrierDismissible: false,
          builder: (context) => AlertDialog(
            title: Text(_getPaymentSuccessText(languageCode)),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(
                  Icons.check_circle,
                  color: Colors.green,
                  size: 64,
                ),
                const SizedBox(height: 16),
                Text(_getPaymentSuccessMessageText(languageCode)),
                const SizedBox(height: 8),
                Text(
                  '${_getBookingIdText(languageCode)}: $bookingId',
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () {
                  // Navigate to dashboard
                  Navigator.of(context).pushAndRemoveUntil(
                    MaterialPageRoute(builder: (_) => const DashboardScreen()),
                    (route) => false,
                  );
                },
                child: Text(_getGoToDashboardText(languageCode)),
              ),
            ],
          ),
        );
      } catch (e) {
        // Show error dialog
        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('Error'),
            content: Text('Failed to create booking: $e'),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('OK'),
              ),
            ],
          ),
        );
      }
    }

    // Reset processing state
    setState(() {
      _isProcessing = false;
    });
  }

  // Multilingual text getters
  String _getPaymentTitleText(String languageCode) {
    switch (languageCode) {
      case AppConstants.hindi:
        return 'भुगतान';
      case AppConstants.marathi:
        return 'पेमेंट';
      default:
        return 'Payment';
    }
  }

  String _getBookingSummaryText(String languageCode) {
    switch (languageCode) {
      case AppConstants.hindi:
        return 'बुकिंग सारांश';
      case AppConstants.marathi:
        return 'बुकिंग सारांश';
      default:
        return 'Booking Summary';
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

  String _getDurationText(String languageCode) {
    switch (languageCode) {
      case AppConstants.hindi:
        return 'अवधि';
      case AppConstants.marathi:
        return 'कालावधी';
      default:
        return 'Duration';
    }
  }

  String _getDaysText(String languageCode) {
    switch (languageCode) {
      case AppConstants.hindi:
        return 'दिन';
      case AppConstants.marathi:
        return 'दिवस';
      default:
        return 'days';
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

  String _getTotalRentText(String languageCode) {
    switch (languageCode) {
      case AppConstants.hindi:
        return 'कुल किराया';
      case AppConstants.marathi:
        return 'एकूण भाडे';
      default:
        return 'Total Rent';
    }
  }

  String _getDepositText(String languageCode) {
    switch (languageCode) {
      case AppConstants.hindi:
        return 'जमा राशि (अभी भुगतान करें)';
      case AppConstants.marathi:
        return 'ठेव रक्कम (आता भरा)';
      default:
        return 'Deposit Amount (Pay Now)';
    }
  }

  String _getPaymentMethodText(String languageCode) {
    switch (languageCode) {
      case AppConstants.hindi:
        return 'भुगतान विधि चुनें';
      case AppConstants.marathi:
        return 'पेमेंट पद्धत निवडा';
      default:
        return 'Select Payment Method';
    }
  }

  String _getUpiDescriptionText(String languageCode) {
    switch (languageCode) {
      case AppConstants.hindi:
        return 'Google Pay, PhonePe, Paytm या किसी भी UPI ऐप का उपयोग करें';
      case AppConstants.marathi:
        return 'Google Pay, PhonePe, Paytm किंवा कोणत्याही UPI अॅपचा वापर करा';
      default:
        return 'Use Google Pay, PhonePe, Paytm or any UPI app';
    }
  }

  String _getCashText(String languageCode) {
    switch (languageCode) {
      case AppConstants.hindi:
        return 'नकद';
      case AppConstants.marathi:
        return 'रोख';
      default:
        return 'Cash';
    }
  }

  String _getCashDescriptionText(String languageCode) {
    switch (languageCode) {
      case AppConstants.hindi:
        return 'बक्से डिलीवरी के समय नकद भुगतान करें';
      case AppConstants.marathi:
        return 'बॉक्स डिलिव्हरी करताना रोख पैसे द्या';
      default:
        return 'Pay cash at the time of box delivery';
    }
  }

  String _getPayNowText(String languageCode) {
    switch (languageCode) {
      case AppConstants.hindi:
        return 'अभी भुगतान करें';
      case AppConstants.marathi:
        return 'आता पेमेंट करा';
      default:
        return 'Pay Now';
    }
  }

  String _getPaymentNoteText(String languageCode) {
    switch (languageCode) {
      case AppConstants.hindi:
        return 'नोट: आपकी बुकिंग की पुष्टि भुगतान के बाद की जाएगी। आपको एक पुष्टिकरण संदेश प्राप्त होगा।';
      case AppConstants.marathi:
        return 'टीप: तुमची बुकिंग पेमेंट केल्यानंतर कन्फर्म केली जाईल. तुम्हाला एक कन्फर्मेशन मेसेज मिळेल.';
      default:
        return 'Note: Your booking will be confirmed after payment. You will receive a confirmation message.';
    }
  }

  String _getPaymentSuccessText(String languageCode) {
    switch (languageCode) {
      case AppConstants.hindi:
        return 'भुगतान सफल!';
      case AppConstants.marathi:
        return 'पेमेंट यशस्वी!';
      default:
        return 'Payment Successful!';
    }
  }

  String _getPaymentSuccessMessageText(String languageCode) {
    switch (languageCode) {
      case AppConstants.hindi:
        return 'आपकी बुकिंग सफलतापूर्वक पूरी हो गई है। आपका बुकिंग आईडी है:';
      case AppConstants.marathi:
        return 'तुमची बुकिंग यशस्वीरित्या पूर्ण झाली आहे. तुमचा बुकिंग आयडी आहे:';
      default:
        return 'Your booking has been successfully completed. Your booking ID is:';
    }
  }

  String _getBookingIdText(String languageCode) {
    // Generate a random booking ID
    final bookingId = 'BEE${DateTime.now().millisecondsSinceEpoch.toString().substring(5)}';
    return bookingId;
  }

  String _getGoToDashboardText(String languageCode) {
    switch (languageCode) {
      case AppConstants.hindi:
        return 'डैशबोर्ड पर जाएं';
      case AppConstants.marathi:
        return 'डॅशबोर्डवर जा';
      default:
        return 'Go to Dashboard';
    }
  }
}