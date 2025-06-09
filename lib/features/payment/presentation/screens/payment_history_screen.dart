import 'package:flutter/material.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/utils/date_formatter.dart';

class PaymentHistoryScreen extends StatelessWidget {
  const PaymentHistoryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Payment History'),
        backgroundColor: AppTheme.primaryColor,
      ),
      body: Padding(
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
    // Mock payment history data
    final List<Map<String, dynamic>> paymentHistory = [
      {
        'id': 'PAY123456',
        'date': DateTime.now().subtract(const Duration(days: 2)),
        'amount': 1500.0,
        'status': 'Completed',
        'description': 'Booking for Bee Box #A123',
      },
      {
        'id': 'PAY123455',
        'date': DateTime.now().subtract(const Duration(days: 15)),
        'amount': 2000.0,
        'status': 'Completed',
        'description': 'Booking for Bee Box #B456',
      },
      {
        'id': 'PAY123454',
        'date': DateTime.now().subtract(const Duration(days: 30)),
        'amount': 1800.0,
        'status': 'Completed',
        'description': 'Booking for Bee Box #C789',
      },
      {
        'id': 'PAY123453',
        'date': DateTime.now().subtract(const Duration(days: 45)),
        'amount': 1200.0,
        'status': 'Refunded',
        'description': 'Booking for Bee Box #D012 (Cancelled)',
      },
    ];

    if (paymentHistory.isEmpty) {
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
              'Your payment transactions will appear here',
              style: TextStyle(
                fontSize: 14,
                color: AppTheme.textSecondary,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      );
    }

    return ListView.separated(
      itemCount: paymentHistory.length,
      separatorBuilder: (context, index) => const Divider(),
      itemBuilder: (context, index) {
        final payment = paymentHistory[index];
        return _buildPaymentItem(payment);
      },
    );
  }

  Widget _buildPaymentItem(Map<String, dynamic> payment) {
    Color statusColor = AppTheme.availableColor; // Default to green for completed
    
    if (payment['status'] == 'Refunded') {
      statusColor = AppTheme.bookedColor; // Red for refunded
    } else if (payment['status'] == 'Pending') {
      statusColor = Colors.orange; // Orange for pending
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
                  payment['id'],
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
                    payment['status'],
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
                Text(
                  payment['description'],
                  style: TextStyle(
                    color: AppTheme.textSecondary,
                    fontSize: 14,
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
          ],
        ),
      ),
    );
  }
}