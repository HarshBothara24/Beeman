import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

// Update the import path for AuthProvider
import '../../../auth/presentation/providers/auth_provider.dart';
import '../../../../core/theme/app_theme.dart';

class PaymentManagementScreen extends StatefulWidget {
  const PaymentManagementScreen({super.key});

  @override
  State<PaymentManagementScreen> createState() => _PaymentManagementScreenState();
}

class _PaymentManagementScreenState extends State<PaymentManagementScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

  // Mock data for payments
  final List<Map<String, dynamic>> _payments = [
    {
      'id': 'P001',
      'bookingId': 'BK001',
      'userId': 'U001',
      'userName': 'Rajesh Sharma',
      'amount': 12500.0,
      'paymentMethod': 'UPI',
      'transactionId': 'TXN123456789',
      'status': 'Completed',
      'date': '2023-11-10',
      'notes': 'Full payment received',
    },
    {
      'id': 'P002',
      'bookingId': 'BK002',
      'userId': 'U002',
      'userName': 'Priya Patel',
      'amount': 7500.0,
      'paymentMethod': 'Cash',
      'transactionId': '',
      'status': 'Completed',
      'date': '2023-09-25',
      'notes': 'Cash collected by field agent',
    },
    {
      'id': 'P003',
      'bookingId': 'BK003',
      'userId': 'U003',
      'userName': 'Amit Kumar',
      'amount': 5000.0,
      'paymentMethod': 'UPI',
      'transactionId': 'TXN987654321',
      'status': 'Pending',
      'date': '2023-11-20',
      'notes': 'Partial payment (deposit)',
    },
    {
      'id': 'P004',
      'bookingId': 'BK004',
      'userId': 'U004',
      'userName': 'Sneha Desai',
      'amount': 5000.0,
      'paymentMethod': 'UPI',
      'transactionId': 'TXN456789123',
      'status': 'Refunded',
      'date': '2023-09-20',
      'notes': 'Booking cancelled, full refund processed',
    },
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  List<Map<String, dynamic>> _getFilteredPayments(String status) {
    return _payments.where((payment) {
      // Filter by status
      final statusMatch = status == 'All' || payment['status'] == status;
      
      // Filter by search query if present
      final searchMatch = _searchQuery.isEmpty ||
          payment['id'].toLowerCase().contains(_searchQuery.toLowerCase()) ||
          payment['bookingId'].toLowerCase().contains(_searchQuery.toLowerCase()) ||
          payment['userName'].toLowerCase().contains(_searchQuery.toLowerCase()) ||
          payment['transactionId'].toLowerCase().contains(_searchQuery.toLowerCase());
      
      return statusMatch && searchMatch;
    }).toList();
  }

  void _showPaymentDetails(Map<String, dynamic> payment) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('${_getText('paymentDetails')}: ${payment['id']}'),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildDetailRow(_getText('paymentId'), payment['id']),
              _buildDetailRow(_getText('bookingId'), payment['bookingId']),
              _buildDetailRow(_getText('customer'), payment['userName']),
              _buildDetailRow(_getText('amount'), '₹${payment['amount']}'),
              _buildDetailRow(_getText('paymentMethod'), payment['paymentMethod']),
              if (payment['transactionId'].isNotEmpty)
                _buildDetailRow(_getText('transactionId'), payment['transactionId']),
              _buildDetailRow(_getText('status'), payment['status']),
              _buildDetailRow(_getText('date'), payment['date']),
              if (payment['notes'].isNotEmpty)
                _buildDetailRow(_getText('notes'), payment['notes']),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(_getText('close')),
          ),
          if (payment['status'] == 'Pending')
            TextButton(
              onPressed: () {
                Navigator.pop(context);
                _showUpdateStatusDialog(payment);
              },
              child: Text(_getText('updateStatus')),
            ),
        ],
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(
              '$label:',
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
          Expanded(
            child: Text(value),
          ),
        ],
      ),
    );
  }

  void _showUpdateStatusDialog(Map<String, dynamic> payment) {
    String newStatus = payment['status'];
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(_getText('updatePaymentStatus')),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            RadioListTile<String>(
              title: Text(_getText('completed')),
              value: 'Completed',
              groupValue: newStatus,
              onChanged: (value) {
                setState(() {
                  newStatus = value!;
                });
              },
            ),
            RadioListTile<String>(
              title: Text(_getText('pending')),
              value: 'Pending',
              groupValue: newStatus,
              onChanged: (value) {
                setState(() {
                  newStatus = value!;
                });
              },
            ),
            RadioListTile<String>(
              title: Text(_getText('refunded')),
              value: 'Refunded',
              groupValue: newStatus,
              onChanged: (value) {
                setState(() {
                  newStatus = value!;
                });
              },
            ),
            RadioListTile<String>(
              title: Text(_getText('failed')),
              value: 'Failed',
              groupValue: newStatus,
              onChanged: (value) {
                setState(() {
                  newStatus = value!;
                });
              },
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(_getText('cancel')),
          ),
          TextButton(
            onPressed: () {
              setState(() {
                final index = _payments.indexWhere((p) => p['id'] == payment['id']);
                if (index != -1) {
                  _payments[index]['status'] = newStatus;
                }
              });
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text(_getText('statusUpdated'))),
              );
            },
            child: Text(_getText('update')),
          ),
        ],
      ),
    );
  }

  String _getText(String key) {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final languageCode = authProvider.languageCode;
    
    final Map<String, Map<String, String>> textMap = {
      'paymentManagement': {
        'en': 'Payment Management',
        'hi': 'भुगतान प्रबंधन',
        'mr': 'पेमेंट व्यवस्थापन',
      },
      'all': {
        'en': 'All',
        'hi': 'सभी',
        'mr': 'सर्व',
      },
      'completed': {
        'en': 'Completed',
        'hi': 'पूर्ण',
        'mr': 'पूर्ण',
      },
      'pending': {
        'en': 'Pending',
        'hi': 'लंबित',
        'mr': 'प्रलंबित',
      },
      'refunded': {
        'en': 'Refunded',
        'hi': 'वापस किया गया',
        'mr': 'परत केले',
      },
      'failed': {
        'en': 'Failed',
        'hi': 'विफल',
        'mr': 'अयशस्वी',
      },
      'search': {
        'en': 'Search payments...',
        'hi': 'भुगतान खोजें...',
        'mr': 'पेमेंट शोधा...',
      },
      'paymentId': {
        'en': 'Payment ID',
        'hi': 'भुगतान आईडी',
        'mr': 'पेमेंट आयडी',
      },
      'bookingId': {
        'en': 'Booking ID',
        'hi': 'बुकिंग आईडी',
        'mr': 'बुकिंग आयडी',
      },
      'customer': {
        'en': 'Customer',
        'hi': 'ग्राहक',
        'mr': 'ग्राहक',
      },
      'amount': {
        'en': 'Amount',
        'hi': 'राशि',
        'mr': 'रक्कम',
      },
      'paymentMethod': {
        'en': 'Payment Method',
        'hi': 'भुगतान विधि',
        'mr': 'पेमेंट पद्धत',
      },
      'transactionId': {
        'en': 'Transaction ID',
        'hi': 'लेनदेन आईडी',
        'mr': 'व्यवहार आयडी',
      },
      'status': {
        'en': 'Status',
        'hi': 'स्थिति',
        'mr': 'स्थिती',
      },
      'date': {
        'en': 'Date',
        'hi': 'तारीख',
        'mr': 'तारीख',
      },
      'notes': {
        'en': 'Notes',
        'hi': 'नोट्स',
        'mr': 'नोट्स',
      },
      'viewDetails': {
        'en': 'View Details',
        'hi': 'विवरण देखें',
        'mr': 'तपशील पहा',
      },
      'updateStatus': {
        'en': 'Update Status',
        'hi': 'स्थिति अपडेट करें',
        'mr': 'स्थिती अपडेट करा',
      },
      'paymentDetails': {
        'en': 'Payment Details',
        'hi': 'भुगतान विवरण',
        'mr': 'पेमेंट तपशील',
      },
      'close': {
        'en': 'Close',
        'hi': 'बंद करें',
        'mr': 'बंद करा',
      },
      'updatePaymentStatus': {
        'en': 'Update Payment Status',
        'hi': 'भुगतान स्थिति अपडेट करें',
        'mr': 'पेमेंट स्थिती अपडेट करा',
      },
      'cancel': {
        'en': 'Cancel',
        'hi': 'रद्द करें',
        'mr': 'रद्द करा',
      },
      'update': {
        'en': 'Update',
        'hi': 'अपडेट करें',
        'mr': 'अपडेट करा',
      },
      'statusUpdated': {
        'en': 'Payment status updated successfully',
        'hi': 'भुगतान स्थिति सफलतापूर्वक अपडेट की गई',
        'mr': 'पेमेंट स्थिती यशस्वीरित्या अपडेट केली',
      },
      'noPaymentsFound': {
        'en': 'No payments found',
        'hi': 'कोई भुगतान नहीं मिला',
        'mr': 'कोणतेही पेमेंट आढळले नाही',
      },
      'totalRevenue': {
        'en': 'Total Revenue',
        'hi': 'कुल राजस्व',
        'mr': 'एकूण महसूल',
      },
      'pendingAmount': {
        'en': 'Pending Amount',
        'hi': 'लंबित राशि',
        'mr': 'प्रलंबित रक्कम',
      },
      'refundedAmount': {
        'en': 'Refunded Amount',
        'hi': 'वापस की गई राशि',
        'mr': 'परत केलेली रक्कम',
      },
      'downloadReport': {
        'en': 'Download Report',
        'hi': 'रिपोर्ट डाउनलोड करें',
        'mr': 'अहवाल डाउनलोड करा',
      },
    };

    return textMap[key]?[languageCode] ?? textMap[key]?['en'] ?? key;
  }

  double _calculateTotalRevenue() {
    return _payments
        .where((payment) => payment['status'] == 'Completed')
        .fold(0.0, (sum, payment) => sum + payment['amount']);
  }

  double _calculatePendingAmount() {
    return _payments
        .where((payment) => payment['status'] == 'Pending')
        .fold(0.0, (sum, payment) => sum + payment['amount']);
  }

  double _calculateRefundedAmount() {
    return _payments
        .where((payment) => payment['status'] == 'Refunded')
        .fold(0.0, (sum, payment) => sum + payment['amount']);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_getText('paymentManagement')),
        bottom: TabBar(
          controller: _tabController,
          tabs: [
            Tab(text: _getText('all')),
            Tab(text: _getText('completed')),
            Tab(text: _getText('pending')),
          ],
        ),
      ),
      body: Column(
        children: [
          // Summary cards
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              children: [
                Expanded(
                  child: _buildSummaryCard(
                    _getText('totalRevenue'),
                    '₹${_calculateTotalRevenue()}',
                    Colors.green,
                    Icons.payments,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: _buildSummaryCard(
                    _getText('pendingAmount'),
                    '₹${_calculatePendingAmount()}',
                    Colors.orange,
                    Icons.pending_actions,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: _buildSummaryCard(
                    _getText('refundedAmount'),
                    '₹${_calculateRefundedAmount()}',
                    Colors.red,
                    Icons.money_off,
                  ),
                ),
              ],
            ),
          ),
          // Search bar
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: _getText('search'),
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                contentPadding: const EdgeInsets.symmetric(vertical: 0),
                suffixIcon: _searchQuery.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear),
                        onPressed: () {
                          setState(() {
                            _searchController.clear();
                            _searchQuery = '';
                          });
                        },
                      )
                    : null,
              ),
              onChanged: (value) {
                setState(() {
                  _searchQuery = value;
                });
              },
            ),
          ),
          const SizedBox(height: 8),
          // Download report button
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Align(
              alignment: Alignment.centerRight,
              child: ElevatedButton.icon(
                onPressed: () {
                  // TODO: Implement report download
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Report download feature coming soon')),
                  );
                },
                icon: const Icon(Icons.download),
                label: Text(_getText('downloadReport')),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.primaryColor,
                  foregroundColor: Colors.white,
                ),
              ),
            ),
          ),
          const SizedBox(height: 8),
          // Tab content
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                _buildPaymentList('All'),
                _buildPaymentList('Completed'),
                _buildPaymentList('Pending'),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryCard(String title, String value, Color color, IconData icon) {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, color: color, size: 20),
                const SizedBox(width: 8),
                Text(
                  title,
                  style: TextStyle(
                    color: Colors.grey[600],
                    fontSize: 14,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              value,
              style: TextStyle(
                color: color,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPaymentList(String status) {
    final filteredPayments = _getFilteredPayments(status);
    
    if (filteredPayments.isEmpty) {
      return Center(
        child: Text(_getText('noPaymentsFound')),
      );
    }
    
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: filteredPayments.length,
      itemBuilder: (context, index) {
        final payment = filteredPayments[index];
        return Card(
          margin: const EdgeInsets.only(bottom: 16),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      '${_getText('paymentId')}: ${payment['id']}',
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                    _buildStatusChip(payment['status']),
                  ],
                ),
                const Divider(),
                _buildInfoRow(Icons.confirmation_number, _getText('bookingId'), payment['bookingId']),
                _buildInfoRow(Icons.person, _getText('customer'), payment['userName']),
                _buildInfoRow(Icons.payments, _getText('amount'), '₹${payment['amount']}'),
                _buildInfoRow(Icons.payment, _getText('paymentMethod'), payment['paymentMethod']),
                if (payment['transactionId'].isNotEmpty)
                  _buildInfoRow(Icons.receipt_long, _getText('transactionId'), payment['transactionId']),
                _buildInfoRow(Icons.calendar_today, _getText('date'), payment['date']),
                const SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    TextButton.icon(
                      icon: const Icon(Icons.visibility),
                      label: Text(_getText('viewDetails')),
                      onPressed: () => _showPaymentDetails(payment),
                    ),
                    if (payment['status'] == 'Pending')
                      TextButton.icon(
                        icon: const Icon(Icons.edit),
                        label: Text(_getText('updateStatus')),
                        onPressed: () => _showUpdateStatusDialog(payment),
                      ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildInfoRow(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Row(
        children: [
          Icon(icon, size: 16, color: AppTheme.primaryColor),
          const SizedBox(width: 8),
          Text(
            '$label: ',
            style: const TextStyle(fontWeight: FontWeight.w500),
          ),
          Expanded(
            child: Text(
              value,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatusChip(String status) {
    Color chipColor;
    switch (status) {
      case 'Completed':
        chipColor = Colors.green;
        break;
      case 'Pending':
        chipColor = Colors.orange;
        break;
      case 'Refunded':
        chipColor = Colors.red;
        break;
      case 'Failed':
        chipColor = Colors.grey;
        break;
      default:
        chipColor = Colors.grey;
    }

    String statusText;
    switch (status) {
      case 'Completed':
        statusText = _getText('completed');
        break;
      case 'Pending':
        statusText = _getText('pending');
        break;
      case 'Refunded':
        statusText = _getText('refunded');
        break;
      case 'Failed':
        statusText = _getText('failed');
        break;
      default:
        statusText = status;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: chipColor.withOpacity(0.1),
        border: Border.all(color: chipColor),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        statusText,
        style: TextStyle(color: chipColor, fontSize: 12),
      ),
    );
  }
}