import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:razorpay_flutter/razorpay_flutter.dart';
import 'package:flutter/foundation.dart';
import 'dart:js' as js; // For web Razorpay integration
import 'dart:convert'; // For JSON parsing
import 'dart:html' as html; // For web event listener
import 'package:cloud_firestore/cloud_firestore.dart'; // For Firebase Firestore

import '../../../../core/constants/app_constants.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import '../../../dashboard/presentation/screens/dashboard_screen.dart';
import '../../../booking/presentation/providers/booking_provider.dart';
import '../../../booking/domain/models/booking_model.dart';
import '../widgets/payment_method_card.dart';
import '../../../booking/data/services/booking_service.dart';
import '../../../../core/utils/whatsapp_messaging.dart';
import '../../../notifications/notification_service.dart';

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
  late Razorpay _razorpay;

  @override
  void initState() {
    super.initState();
    if (!kIsWeb) {
      _razorpay = Razorpay();
      _razorpay.on(Razorpay.EVENT_PAYMENT_SUCCESS, _handlePaymentSuccess);
      _razorpay.on(Razorpay.EVENT_PAYMENT_ERROR, _handlePaymentError);
      _razorpay.on(Razorpay.EVENT_EXTERNAL_WALLET, _handleExternalWallet);
    }
    // Web: Listen for Razorpay payment result from JS
    if (kIsWeb) {
      html.window.onMessage.listen((event) {
        if (event.data is String) {
          print('Received postMessage: ' + event.data as String); // Debug print
          try {
            final data = jsonDecode(event.data as String);
            if (data['type'] == 'razorpay_payment_success') {
              setState(() { _isProcessing = false; });
              _handleWebPaymentSuccess(data['payload']);
            } else if (data['type'] == 'razorpay_payment_cancelled') {
              setState(() { _isProcessing = false; });
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Payment cancelled.')),
              );
            }
          } catch (e) {
            print('Error parsing postMessage: $e');
          }
        }
      });
    }
  }

  Future<void> _markBoxesAsBooked(String boxTypeId, List<int> bookedIndexes) async {
    final docRef = FirebaseFirestore.instance.collection('bee_boxes').doc(boxTypeId);
    final doc = await docRef.get();
    List<dynamic> currentBooked = [];
    if (doc.exists && doc.data() != null && doc.data()!.containsKey('bookedIndexes')) {
      currentBooked = List<dynamic>.from(doc['bookedIndexes']);
    }
    final updatedBooked = Set<int>.from(currentBooked).union(Set<int>.from(bookedIndexes)).toList();
    await docRef.update({'bookedIndexes': updatedBooked});
  }

  Future<void> _handleWebPaymentSuccess(dynamic paymentResponse) async {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final bookingProvider = Provider.of<BookingProvider>(context, listen: false);
    final bookingService = BookingService();
    final userName = authProvider.user?.displayName ?? '';
    final booking = BookingModel(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      userId: authProvider.user?.uid ?? '',
      boxNumbers: Set<int>.from(widget.bookingDetails['selectedBoxes']),
      crop: widget.bookingDetails['crop'],
      location: widget.bookingDetails['location'],
      phone: widget.bookingDetails['phone'],
      startDate: widget.bookingDetails['startDate'],
      endDate: widget.bookingDetails['endDate'],
      numberOfBoxes: widget.bookingDetails['numberOfBoxes'],
      notes: widget.bookingDetails['notes'],
      totalAmount: widget.bookingDetails['totalRent'].toDouble(),
      depositAmount: widget.bookingDetails['depositAmount'].toDouble(),
      status: 'pending',
      createdAt: DateTime.now(),
      userName: userName,
      userPhone: widget.bookingDetails['phone'],
      boxCount: widget.bookingDetails['numberOfBoxes'],
      paymentStatus: 'success',
    );
    try {
      await bookingService.createBooking(booking);
      bookingProvider.addBooking(booking);
      // Mark boxes as booked in bee_boxes collection
      if (widget.bookingDetails['selectedBoxes'] is List) {
        // If only one box type
        final boxTypeId = widget.bookingDetails['boxTypeId'] ?? '';
        final bookedIndexes = List<int>.from(widget.bookingDetails['selectedBoxes']);
        if (boxTypeId.isNotEmpty) {
          await _markBoxesAsBooked(boxTypeId, bookedIndexes);
        }
      } else if (widget.bookingDetails['selectedBoxes'] is Map) {
        // If multiple box types
        final selectedBoxes = Map<String, dynamic>.from(widget.bookingDetails['selectedBoxes']);
        for (final entry in selectedBoxes.entries) {
          final boxTypeId = entry.key;
          final bookedIndexes = List<int>.from(entry.value);
          await _markBoxesAsBooked(boxTypeId, bookedIndexes);
        }
      }
      // Send WhatsApp confirmation automatically
      final sent = await NotificationService.sendBookingConfirmation(booking);
      if (!sent && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Booking confirmed, but WhatsApp message failed to send.')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to create booking: $e'), backgroundColor: Colors.red),
      );
      return;
    }
    // Show success dialog or navigate to dashboard
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: Text('Payment Successful!'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.check_circle, color: Colors.green, size: 64),
            const SizedBox(height: 16),
            const Text('Your booking is confirmed.'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pushAndRemoveUntil(
                MaterialPageRoute(builder: (_) => const DashboardScreen()),
                (route) => false,
              );
            },
            child: const Text('Go to Dashboard'),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    if (!kIsWeb) {
      _razorpay.clear();
    }
    super.dispose();
  }

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
            padding: const EdgeInsets.all(24.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Section: Payment Summary
                const Text(
                  'Payment Summary',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: AppTheme.textPrimary),
                ),
                const SizedBox(height: 12),
                AnimatedContainer(
                  duration: const Duration(milliseconds: 300),
                  curve: Curves.easeInOut,
                  child: _buildBookingSummaryCard(selectedLanguage),
                ),
                const SizedBox(height: 32),
                // Section: Payment Methods
                const Text(
                  'Select Payment Method',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: AppTheme.textPrimary),
                ),
                const SizedBox(height: 12),
                Card(
                  elevation: 2,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  child: Padding(
                    padding: const EdgeInsets.all(20.0),
                    child: Column(
                      children: [
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
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 32),
                // Section: Pay Now Button
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
                            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                          ),
                  ),
                ),
                const SizedBox(height: 16),
                // Payment note
                Text(
                  _getPaymentNoteText(selectedLanguage),
                  style: const TextStyle(fontSize: 12, color: AppTheme.textSecondary, fontStyle: FontStyle.italic),
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

  void _processPayment(String languageCode) async {
    if (_selectedPaymentMethod != 'upi') {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Only UPI payment is supported right now.')),
      );
      return;
    }
    setState(() {
      _isProcessing = true;
    });
    final amount = widget.bookingDetails['depositAmount'] as int;
    final userName = Provider.of<AuthProvider>(context, listen: false).user?.displayName ?? 'BeeMan User';
    final userEmail = Provider.of<AuthProvider>(context, listen: false).user?.email ?? '';
    final userPhone = widget.bookingDetails['phone'] ?? '';
    var options = {
      'key': AppConstants.razorpayKeyId,
      'amount': amount * 100, // in paise
      'name': 'BeeMan',
      'description': 'BeeBox Booking Deposit',
      'prefill': {'contact': userPhone, 'email': userEmail},
      'theme': {'color': '#FFC107'},
      'currency': 'INR',
      'method': {'upi': true, 'card': false, 'netbanking': false},
    };
    try {
      if (kIsWeb) {
        _openRazorpayWebCheckout(options);
      } else {
        _razorpay.open(options);
      }
    } catch (e) {
      setState(() { _isProcessing = false; });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e'), backgroundColor: Colors.red),
      );
    }
  }

  // Helper for web Razorpay integration
  void _openRazorpayWebCheckout(Map options) {
    // Requires you to add Razorpay Checkout.js and a JS function openRazorpay(options) in web/index.html
    js.context.callMethod('openRazorpay', [js.JsObject.jsify(options)]);
  }

  void _handlePaymentSuccess(PaymentSuccessResponse response) async {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final bookingProvider = Provider.of<BookingProvider>(context, listen: false);
    final bookingService = BookingService();
    final userName = authProvider.user?.displayName ?? '';
    final booking = BookingModel(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      userId: authProvider.user?.uid ?? '',
      boxNumbers: Set<int>.from(widget.bookingDetails['selectedBoxes']),
      crop: widget.bookingDetails['crop'],
      location: widget.bookingDetails['location'],
      phone: widget.bookingDetails['phone'],
      startDate: widget.bookingDetails['startDate'],
      endDate: widget.bookingDetails['endDate'],
      numberOfBoxes: widget.bookingDetails['numberOfBoxes'],
      notes: widget.bookingDetails['notes'],
      totalAmount: widget.bookingDetails['totalRent'].toDouble(),
      depositAmount: widget.bookingDetails['depositAmount'].toDouble(),
      status: 'pending',
      createdAt: DateTime.now(),
      userName: userName,
      userPhone: widget.bookingDetails['phone'],
      boxCount: widget.bookingDetails['numberOfBoxes'],
      paymentStatus: 'success',
    );
    try {
      await bookingService.createBooking(booking);
      bookingProvider.addBooking(booking);
      // Mark boxes as booked in bee_boxes collection
      if (widget.bookingDetails['selectedBoxes'] is List) {
        // If only one box type
        final boxTypeId = widget.bookingDetails['boxTypeId'] ?? '';
        final bookedIndexes = List<int>.from(widget.bookingDetails['selectedBoxes']);
        if (boxTypeId.isNotEmpty) {
          await _markBoxesAsBooked(boxTypeId, bookedIndexes);
        }
      } else if (widget.bookingDetails['selectedBoxes'] is Map) {
        // If multiple box types
        final selectedBoxes = Map<String, dynamic>.from(widget.bookingDetails['selectedBoxes']);
        for (final entry in selectedBoxes.entries) {
          final boxTypeId = entry.key;
          final bookedIndexes = List<int>.from(entry.value);
          await _markBoxesAsBooked(boxTypeId, bookedIndexes);
        }
      }
      // Send WhatsApp confirmation automatically
      final sent = await NotificationService.sendBookingConfirmation(booking);
      if (!sent && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Booking confirmed, but WhatsApp message failed to send.')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to create booking: $e'), backgroundColor: Colors.red),
      );
      setState(() { _isProcessing = false; });
      return;
    }
    setState(() { _isProcessing = false; });
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: Text(_getPaymentSuccessText(authProvider.selectedLanguage)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              Icons.check_circle,
              color: Colors.green,
              size: 64,
            ),
            const SizedBox(height: 16),
            Text(_getPaymentSuccessMessageText(authProvider.selectedLanguage)),
            const SizedBox(height: 8),
            Text(
              _getBookingIdText(authProvider.selectedLanguage),
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pushAndRemoveUntil(
                MaterialPageRoute(builder: (_) => const DashboardScreen()),
                (route) => false,
              );
            },
            child: Text(_getGoToDashboardText(authProvider.selectedLanguage)),
          ),
        ],
      ),
    );
  }

  void _handlePaymentError(PaymentFailureResponse response) {
    setState(() { _isProcessing = false; });
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Payment failed: ${response.message}'), backgroundColor: Colors.red),
    );
  }

  void _handleExternalWallet(ExternalWalletResponse response) {
    setState(() { _isProcessing = false; });
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('External wallet selected: ${response.walletName}')),
    );
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