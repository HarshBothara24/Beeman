import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import '../../../../core/theme/app_theme.dart';
import 'package:excel/excel.dart' as excel;
import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'dart:html' as html;

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
    FirebaseFirestore.instance.collection('payments').limit(100).snapshots().listen((snapshot) {
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
        title: Text(l10n('paymentManagement')),
        bottom: TabBar(
          controller: _tabController,
          tabs: [
            Tab(text: l10n('all')),
            Tab(text: l10n('completed')),
            Tab(text: l10n('pending')),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.download),
            tooltip: 'Export to Excel',
            onPressed: () async {
              await _exportPaymentsToExcel();
            },
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Payment Management',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: AppTheme.textPrimary),
            ),
            const SizedBox(height: 16),
            Card(
              elevation: 2,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: TextField(
                  controller: _searchController,
                  decoration: const InputDecoration(
                    hintText: 'Search payments...',
                    prefixIcon: Icon(Icons.search),
                    border: InputBorder.none,
                    contentPadding: EdgeInsets.symmetric(vertical: 0),
                  ),
                  onChanged: (value) {
                    setState(() {
                      _searchQuery = value;
                    });
                  },
                ),
              ),
            ),
            const SizedBox(height: 24),
            Expanded(
              child: ListView.builder(
                itemCount: _payments.length,
                itemBuilder: (context, index) {
                  final payment = _payments[index];
                  return AnimatedContainer(
                    duration: const Duration(milliseconds: 300),
                    curve: Curves.easeInOut,
                    margin: const EdgeInsets.only(bottom: 16),
                    child: Card(
                      elevation: 2,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      child: ListTile(
                        leading: CircleAvatar(
                          backgroundColor: AppTheme.primaryColor.withOpacity(0.1),
                          child: Icon(Icons.payment, color: AppTheme.primaryColor),
                        ),
                        title: Text('Payment #${payment['docId']}', style: const TextStyle(fontWeight: FontWeight.bold)),
                        subtitle: Text('Amount: ₹${payment['amount']} | Status: ${payment['status']}'),
                        trailing: IconButton(
                          icon: const Icon(Icons.delete, color: Colors.red),
                          onPressed: () async {
                            await FirebaseFirestore.instance.collection('payments').doc(payment['docId']).delete();
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text('Payment deleted')),
                            );
                          },
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _exportPaymentsToExcel() async {
    final snapshot = await FirebaseFirestore.instance.collection('payments').get();
    final payments = snapshot.docs;
    if (payments.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No payments to export.')),
      );
      return;
    }
    final workbook = excel.Excel.createExcel();
    final sheet = workbook['Payments'];
    sheet.appendRow([
      'Payment ID', 'User ID', 'Amount', 'Status', 'Date', 'Description'
    ]);
    for (final payment in payments) {
      final data = payment.data() as Map<String, dynamic>;
      sheet.appendRow([
        payment.id,
        data['userId'] ?? '',
        data['amount'] ?? '',
        data['status'] ?? '',
        data['date'] ?? '',
        data['description'] ?? '',
      ]);
    }
    final fileBytes = workbook.encode();
    if (kIsWeb) {
      final blob = html.Blob([fileBytes]);
      final url = html.Url.createObjectUrlFromBlob(blob);
      final anchor = html.AnchorElement(href: url)
        ..setAttribute('download', 'payments.xlsx')
        ..click();
      html.Url.revokeObjectUrl(url);
    } else {
      final dir = await getApplicationDocumentsDirectory();
      final file = File('${dir.path}/payments.xlsx');
      await file.writeAsBytes(fileBytes!);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Exported to ${file.path}')),
      );
    }
  }

  Widget _buildPaymentList(String status) {
    final filteredPayments = _getFilteredPayments(status);
    if (filteredPayments.isEmpty) {
      return Center(child: Text(l10n('No payments found')));
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
                    Text('${l10n('paymentId')}: ${payment['id']}', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                    _buildStatusChip(payment['status']),
                  ],
                ),
                const Divider(),
                _buildInfoRow(Icons.confirmation_number, l10n('bookingId'), payment['bookingId']),
                _buildInfoRow(Icons.person, l10n('customer'), payment['userName']),
                _buildInfoRow(Icons.payments, l10n('amount'), '₹${payment['amount']}'),
                _buildInfoRow(Icons.payment, l10n('paymentMethod'), payment['paymentMethod']),
                if ((payment['transactionId'] ?? '').toString().isNotEmpty)
                  _buildInfoRow(Icons.receipt_long, l10n('transactionId'), payment['transactionId']),
                _buildInfoRow(Icons.calendar_today, l10n('date'), payment['date']),
                const SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    TextButton.icon(
                      icon: const Icon(Icons.visibility),
                      label: Text(l10n('viewDetails')),
                      onPressed: () => _showPaymentDetails(payment),
                    ),
                    if (payment['status'] == 'Pending')
                      TextButton.icon(
                        icon: const Icon(Icons.edit),
                        label: Text(l10n('updateStatus')),
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
    final statusText = l10n(status);
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
          title: Text(l10n('updatePaymentStatus')),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: ['Completed', 'Pending', 'Refunded', 'Failed'].map((status) {
              return RadioListTile<String>(
                title: Text(l10n(status.toLowerCase())),
                value: status,
                groupValue: newStatus,
                onChanged: (value) => setStateDialog(() => newStatus = value!),
              );
            }).toList(),
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(context), child: Text(l10n('cancel'))),
            TextButton(
              onPressed: () {
                FirebaseFirestore.instance.collection('payments').doc(payment['docId']).update({'status': newStatus});
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(l10n('statusUpdated'))));
              },
              child: Text(l10n('update')),
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

  String l10n(String text) => text; // Placeholder for localization
}
