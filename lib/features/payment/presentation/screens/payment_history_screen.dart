import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/utils/date_formatter.dart';
import '../../../auth/presentation/providers/auth_provider.dart';

class PaymentHistoryScreen extends StatefulWidget {
  const PaymentHistoryScreen({super.key});

  @override
  State<PaymentHistoryScreen> createState() => _PaymentHistoryScreenState();
}

class _PaymentHistoryScreenState extends State<PaymentHistoryScreen> {
  bool _isLoading = true;
  List<Map<String, dynamic>> _paymentHistory = [];

  @override
  void initState() {
    super.initState();
    _fetchPaymentHistory();
  }

  Future<void> _fetchPaymentHistory() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      final userId = authProvider.user?.uid;
      
      if (userId == null) {
        setState(() {
          _isLoading = false;
          _paymentHistory = [];
        });
        return;
      }

      print('PaymentHistory: Fetching payments for user: $userId');

      // Fetch all bookings for the user (not just success payments)
      final querySnapshot = await FirebaseFirestore.instance
          .collection('bookings')
          .where('userId', isEqualTo: userId)
          .orderBy('createdAt', descending: true)
          .get();

      print('PaymentHistory: Found ${querySnapshot.docs.length} bookings for user');

      final List<Map<String, dynamic>> payments = [];
      
      for (var doc in querySnapshot.docs) {
        final data = doc.data();
        print('PaymentHistory: Processing booking ${doc.id}');
        print('PaymentHistory: Payment status: ${data['paymentStatus']}');
        print('PaymentHistory: Booking status: ${data['status']}');
        print('PaymentHistory: Deposit amount: ${data['depositAmount']}');
        
        // Include all bookings that have a deposit amount (indicating payment was made)
        if (data['depositAmount'] != null && data['depositAmount'] > 0) {
          final paymentStatus = data['paymentStatus'] ?? 'unknown';
          final bookingStatus = data['status'] ?? 'unknown';
          
          payments.add({
            'id': doc.id,
            'date': (data['createdAt'] as Timestamp).toDate(),
            'amount': (data['depositAmount'] ?? 0.0).toDouble(),
            'status': paymentStatus,
            'bookingStatus': bookingStatus,
            'description': 'Booking for ${data['crop'] ?? 'Bee Box'} - ${data['numberOfBoxes'] ?? 0} boxes',
            'bookingData': data,
          });
          
          print('PaymentHistory: Added payment for booking ${doc.id}');
        }
      }

      print('PaymentHistory: Total payments found: ${payments.length}');

      setState(() {
        _paymentHistory = payments;
        _isLoading = false;
      });
    } catch (e) {
      print('PaymentHistory: Error fetching payment history: $e');
      setState(() {
        _isLoading = false;
        _paymentHistory = [];
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Payment History'),
        backgroundColor: AppTheme.primaryColor,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _fetchPaymentHistory,
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Your Payment History',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: AppTheme.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'View all your past transactions',
                    style: TextStyle(
                      fontSize: 14,
                      color: AppTheme.textSecondary,
                    ),
                  ),
                  const SizedBox(height: 24),
                  Expanded(
                    child: _buildPaymentHistoryList(),
                  ),
                ],
              ),
            ),
    );
  }

  Widget _buildPaymentHistoryList() {
    if (_paymentHistory.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.receipt_long_outlined,
              size: 64,
              color: AppTheme.textSecondary,
            ),
            const SizedBox(height: 16),
            Text(
              'No payment history found',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: AppTheme.textPrimary,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Your payment transactions will appear here\nMake sure you have completed bookings with payments.',
              style: TextStyle(
                fontSize: 14,
                color: AppTheme.textSecondary,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                ElevatedButton(
                  onPressed: _fetchPaymentHistory,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.primaryColor,
                  ),
                  child: const Text('Refresh'),
                ),
              ],
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: _fetchPaymentHistory,
      child: ListView.separated(
        itemCount: _paymentHistory.length,
        separatorBuilder: (context, index) => const Divider(),
        itemBuilder: (context, index) {
          final payment = _paymentHistory[index];
          return _buildPaymentItem(payment);
        },
      ),
    );
  }

  Widget _buildPaymentItem(Map<String, dynamic> payment) {
    // Determine status color based on payment status
    Color statusColor = Colors.green; // Default to green for success
    
    final paymentStatus = payment['status'].toString().toLowerCase();
    final bookingStatus = payment['bookingStatus'].toString().toLowerCase();
    
    if (paymentStatus == 'pending' || bookingStatus == 'pending') {
      statusColor = Colors.orange; // Orange for pending
    } else if (paymentStatus == 'failed' || bookingStatus == 'cancelled') {
      statusColor = Colors.red; // Red for failed/cancelled
    } else if (paymentStatus == 'success' || bookingStatus == 'active' || bookingStatus == 'completed') {
      statusColor = Colors.green; // Green for success/active/completed
    }

    // Determine display status
    String displayStatus = paymentStatus.toUpperCase();
    if (paymentStatus == 'unknown' || paymentStatus.isEmpty) {
      displayStatus = bookingStatus.toUpperCase();
    }

    return Card(
      elevation: 2,
      margin: const EdgeInsets.symmetric(vertical: 4),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Booking #${payment['id'].substring(0, 8)}',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: AppTheme.textPrimary,
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: statusColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: statusColor),
                  ),
                  child: Text(
                    displayStatus,
                    style: TextStyle(
                      color: statusColor,
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    payment['description'],
                    style: TextStyle(
                      color: AppTheme.textSecondary,
                      fontSize: 14,
                    ),
                  ),
                ),
                Text(
                  '₹${payment['amount'].toStringAsFixed(2)}',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                    color: AppTheme.textPrimary,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              'Date: ${DateFormatter.formatDate(payment['date'])}',
              style: TextStyle(
                color: AppTheme.textSecondary,
                fontSize: 12,
              ),
            ),
            if (paymentStatus != bookingStatus) ...[
              const SizedBox(height: 4),
              Text(
                'Payment: ${paymentStatus.toUpperCase()} | Booking: ${bookingStatus.toUpperCase()}',
                style: TextStyle(
                  color: AppTheme.textSecondary,
                  fontSize: 10,
                  fontStyle: FontStyle.italic,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}