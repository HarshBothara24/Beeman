import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
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
  List<Map<String, dynamic>> _payments = [];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _listenToPayments();
  }

  void _listenToPayments() {
    FirebaseFirestore.instance.collection('payments').snapshots().listen((snapshot) {
      setState(() {
        _payments = snapshot.docs.map((doc) {
          final data = doc.data();
          data['docId'] = doc.id;
          return data;
        }).toList();
      });
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  List<Map<String, dynamic>> _getFilteredPayments(String status) {
    return _payments.where((payment) {
      final statusMatch = status == 'All' || payment['status'] == status;
      final query = _searchQuery.toLowerCase();
      final searchMatch = _searchQuery.isEmpty ||
          (payment['id'] ?? '').toLowerCase().contains(query) ||
          (payment['bookingId'] ?? '').toLowerCase().contains(query) ||
          (payment['userName'] ?? '').toLowerCase().contains(query) ||
          (payment['transactionId'] ?? '').toLowerCase().contains(query);
      return statusMatch && searchMatch;
    }).toList();
  }

  double _calculateTotalRevenue() => _payments
      .where((payment) => payment['status'] == 'Completed')
      .fold(0.0, (sum, payment) => sum + (payment['amount'] ?? 0.0));

  double _calculatePendingAmount() => _payments
      .where((payment) => payment['status'] == 'Pending')
      .fold(0.0, (sum, payment) => sum + (payment['amount'] ?? 0.0));

  double _calculateRefundedAmount() => _payments
      .where((payment) => payment['status'] == 'Refunded')
      .fold(0.0, (sum, payment) => sum + (payment['amount'] ?? 0.0));

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
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              children: [
                Expanded(child: _buildSummaryCard(_getText('totalRevenue'), '₹${_calculateTotalRevenue()}', Colors.green, Icons.payments)),
                const SizedBox(width: 16),
                Expanded(child: _buildSummaryCard(_getText('pendingAmount'), '₹${_calculatePendingAmount()}', Colors.orange, Icons.pending_actions)),
                const SizedBox(width: 16),
                Expanded(child: _buildSummaryCard(_getText('refundedAmount'), '₹${_calculateRefundedAmount()}', Colors.red, Icons.money_off)),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: _getText('search'),
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                contentPadding: const EdgeInsets.symmetric(vertical: 0),
                suffixIcon: _searchQuery.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear),
                        onPressed: () => setState(() {
                          _searchQuery = '';
                          _searchController.clear();
                        }),
                      )
                    : null,
              ),
              onChanged: (value) => setState(() => _searchQuery = value),
            ),
          ),
          const SizedBox(height: 8),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Align(
              alignment: Alignment.centerRight,
              child: ElevatedButton.icon(
                onPressed: () {
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

  Widget _buildPaymentList(String status) {
    final filteredPayments = _getFilteredPayments(status);
    if (filteredPayments.isEmpty) {
      return Center(child: Text(_getText('noPaymentsFound')));
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
                    Text('${_getText('paymentId')}: ${payment['id']}', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                    _buildStatusChip(payment['status']),
                  ],
                ),
                const Divider(),
                _buildInfoRow(Icons.confirmation_number, _getText('bookingId'), payment['bookingId']),
                _buildInfoRow(Icons.person, _getText('customer'), payment['userName']),
                _buildInfoRow(Icons.payments, _getText('amount'), '₹${payment['amount']}'),
                _buildInfoRow(Icons.payment, _getText('paymentMethod'), payment['paymentMethod']),
                if ((payment['transactionId'] ?? '').toString().isNotEmpty)
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
    final statusText = _getText(status.toLowerCase());
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: chipColor.withOpacity(0.1),
        border: Border.all(color: chipColor),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(statusText, style: TextStyle(color: chipColor, fontSize: 12)),
    );
  }

  void _confirmDeletePayment(Map<String, dynamic> payment) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Delete Payment'),
        content: Text('Are you sure you want to delete Payment ID: ${payment['id']}?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cancel'),
          ),
          TextButton(
            onPressed: () async {
              await FirebaseFirestore.instance.collection('payments').doc(payment['docId']).delete();
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('Payment deleted')),
              );
            },
            child: Text('Delete', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  void _showPaymentDetails(Map<String, dynamic> payment) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Payment Details'),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('Payment ID: ${payment['id']}'),
              Text('User: ${payment['userName'] ?? 'N/A'}'),
              Text('Amount: ₹${payment['amount'] ?? 'N/A'}'),
              Text('Date: ${payment['date'] ?? 'N/A'}'),
              Text('Status: ${payment['status'] ?? 'N/A'}'),
              Text('Payment Method: ${payment['paymentMethod'] ?? 'N/A'}'),
              Text('Transaction ID: ${payment['transactionId'] ?? 'N/A'}'),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Close'),
          ),
        ],
      ),
    );
  }

  void _showUpdateStatusDialog(Map<String, dynamic> payment) {
    String newStatus = payment['status'];
    showDialog(
      context: context,
      builder: (_) => StatefulBuilder(
        builder: (context, setStateDialog) => AlertDialog(
          title: Text(_getText('updatePaymentStatus')),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: ['Completed', 'Pending', 'Refunded', 'Failed'].map((status) {
              return RadioListTile<String>(
                title: Text(_getText(status.toLowerCase())),
                value: status,
                groupValue: newStatus,
                onChanged: (value) => setStateDialog(() => newStatus = value!),
              );
            }).toList(),
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(context), child: Text(_getText('cancel'))),
            TextButton(
              onPressed: () {
                FirebaseFirestore.instance.collection('payments').doc(payment['docId']).update({'status': newStatus});
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(_getText('statusUpdated'))));
              },
              child: Text(_getText('update')),
            ),
          ],
        ),
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
            Row(children: [Icon(icon, color: color, size: 20), const SizedBox(width: 8), Text(title, style: TextStyle(color: Colors.grey[600], fontSize: 14))]),
            const SizedBox(height: 8),
            Text(value, style: TextStyle(color: color, fontSize: 18, fontWeight: FontWeight.bold)),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String label, String value) {
    return Row(
      children: [
        Icon(icon, size: 20, color: Colors.grey),
        const SizedBox(width: 8),
        Text(label, style: const TextStyle(color: Colors.grey)),
        const SizedBox(width: 8),
        Text(value, style: const TextStyle(fontWeight: FontWeight.bold)),
      ],
    );
  }

  String _getText(String key) {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final lang = authProvider.languageCode;
    const textMap = {
      'paymentManagement': {'en': 'Payment Management', 'hi': 'भुगतान प्रबंधन', 'mr': 'पेमेंट व्यवस्थापन'},
      'all': {'en': 'All', 'hi': 'सभी', 'mr': 'सर्व'},
      'completed': {'en': 'Completed', 'hi': 'पूर्ण', 'mr': 'पूर्ण'},
      'pending': {'en': 'Pending', 'hi': 'लंबित', 'mr': 'प्रलंबित'},
      'refunded': {'en': 'Refunded', 'hi': 'वापस किया गया', 'mr': 'परत केले'},
      'failed': {'en': 'Failed', 'hi': 'विफल', 'mr': 'अयशस्वी'},
      'search': {'en': 'Search payments...', 'hi': 'भुगतान खोजें...', 'mr': 'पेमेंट शोधा...'},
      'paymentId': {'en': 'Payment ID', 'hi': 'भुगतान आईडी', 'mr': 'पेमेंट आयडी'},
      'bookingId': {'en': 'Booking ID', 'hi': 'बुकिंग आईडी', 'mr': 'बुकिंग आयडी'},
      'customer': {'en': 'Customer', 'hi': 'ग्राहक', 'mr': 'ग्राहक'},
      'amount': {'en': 'Amount', 'hi': 'राशि', 'mr': 'रक्कम'},
      'paymentMethod': {'en': 'Payment Method', 'hi': 'भुगतान विधि', 'mr': 'पेमेंट पद्धत'},
      'transactionId': {'en': 'Transaction ID', 'hi': 'लेनदेन आईडी', 'mr': 'व्यवहार आयडी'},
      'status': {'en': 'Status', 'hi': 'स्थिति', 'mr': 'स्थिती'},
      'date': {'en': 'Date', 'hi': 'तारीख', 'mr': 'तारीख'},
      'notes': {'en': 'Notes', 'hi': 'नोट्स', 'mr': 'नोट्स'},
      'viewDetails': {'en': 'View Details', 'hi': 'विवरण देखें', 'mr': 'तपशील पहा'},
      'updateStatus': {'en': 'Update Status', 'hi': 'स्थिति अपडेट करें', 'mr': 'स्थिती अपडेट करा'},
      'paymentDetails': {'en': 'Payment Details', 'hi': 'भुगतान विवरण', 'mr': 'पेमेंट तपशील'},
      'close': {'en': 'Close', 'hi': 'बंद करें', 'mr': 'बंद करा'},
      'updatePaymentStatus': {'en': 'Update Payment Status', 'hi': 'भुगतान स्थिति अपडेट करें', 'mr': 'पेमेंट स्थिती अपडेट करा'},
      'cancel': {'en': 'Cancel', 'hi': 'रद्द करें', 'mr': 'रद्द करा'},
      'update': {'en': 'Update', 'hi': 'अपडेट करें', 'mr': 'अपडेट करा'},
      'statusUpdated': {'en': 'Payment status updated successfully', 'hi': 'भुगतान स्थिति सफलतापूर्वक अपडेट की गई', 'mr': 'पेमेंट स्थिती यशस्वीरित्या अपडेट केली'},
      'noPaymentsFound': {'en': 'No payments found', 'hi': 'कोई भुगतान नहीं मिला', 'mr': 'कोणतेही पेमेंट आढळले नाही'},
      'totalRevenue': {'en': 'Total Revenue', 'hi': 'कुल राजस्व', 'mr': 'एकूण महसूल'},
      'pendingAmount': {'en': 'Pending Amount', 'hi': 'लंबित राशि', 'mr': 'प्रलंबित रक्कम'},
      'refundedAmount': {'en': 'Refunded Amount', 'hi': 'वापस की गई राशि', 'mr': 'परत केलेली रक्कम'},
      'downloadReport': {'en': 'Download Report', 'hi': 'रिपोर्ट डाउनलोड करें', 'mr': 'अहवाल डाउनलोड करा'},
    };

    return textMap[key]?[lang] ?? textMap[key]?['en'] ?? key;
  }
}
