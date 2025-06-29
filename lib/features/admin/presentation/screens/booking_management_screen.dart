import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:provider/provider.dart';

// Update the import path for AuthProvider
import '../../../auth/presentation/providers/auth_provider.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../booking/presentation/widgets/booking_status_badge.dart';
import '../../../testing/simple_firestore_test.dart';

class BookingManagementScreen extends StatefulWidget {
  const BookingManagementScreen({super.key});

  @override
  State<BookingManagementScreen> createState() => _BookingManagementScreenState();
}

class _BookingManagementScreenState extends State<BookingManagementScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

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

  Stream<QuerySnapshot> getAllBookingsStream() {
    return FirebaseFirestore.instance
        .collection('bookings')
        .orderBy('createdAt', descending: true)
        .snapshots();
  }

  List<Map<String, dynamic>> _filterBookings(List<QueryDocumentSnapshot> docs, String status) {
    return docs.map((doc) => doc.data() as Map<String, dynamic>)
      .where((booking) {
        final statusMatch = booking['status'] == status;
        final searchMatch = _searchQuery.isEmpty ||
            (booking['bookingId']?.toString().toLowerCase().contains(_searchQuery.toLowerCase()) ?? false) ||
            (booking['userId']?.toString().toLowerCase().contains(_searchQuery.toLowerCase()) ?? false) ||
            (booking['crop']?.toString().toLowerCase().contains(_searchQuery.toLowerCase()) ?? false) ||
            (booking['location']?.toString().toLowerCase().contains(_searchQuery.toLowerCase()) ?? false);
        return statusMatch && searchMatch;
      }).toList();
  }

  void _showBookingDetails(Map<String, dynamic> booking) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Booking Details: ${booking['bookingId'] ?? booking['id']}'),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildDetailRow('User ID', booking['userId'] ?? ''),
              _buildDetailRow('Crop', booking['crop'] ?? ''),
              _buildDetailRow('Location', booking['location'] ?? ''),
              _buildDetailRow('Date Range',
                '${_formatDate(booking['startDate'])} to ${_formatDate(booking['endDate'])}'),
              _buildDetailRow('Boxes', booking['quantity']?.toString() ?? ''),
              _buildDetailRow('Total Amount', '₹${booking['totalAmount'] ?? ''}'),
              _buildDetailRow('Status', booking['status'] ?? ''),
              if (booking['notes'] != null && booking['notes'].toString().isNotEmpty)
                _buildDetailRow('Notes', booking['notes']),
              _buildDetailRow('Created At', _formatDate(booking['createdAt'])),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  String _formatDate(dynamic timestamp) {
    if (timestamp == null) return '';
    if (timestamp is String) return timestamp;
    if (timestamp is DateTime) return timestamp.toLocal().toString().split(' ')[0];
    try {
      return timestamp.toDate().toLocal().toString().split(' ')[0];
    } catch (_) {
      return timestamp.toString();
    }
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2.0),
      child: Row(
        children: [
          Text('$label: ', style: const TextStyle(fontWeight: FontWeight.bold)),
          Expanded(child: Text(value)),
        ],
      ),
    );
  }

  Widget _buildBookingList(List<QueryDocumentSnapshot> docs, String status) {
    final filteredBookings = _filterBookings(docs, status);
    if (filteredBookings.isEmpty) {
      return const Center(child: Text('No bookings found'));
    }
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: filteredBookings.length,
      itemBuilder: (context, index) {
        final booking = filteredBookings[index];
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
                      'Booking ID: ${booking['bookingId'] ?? booking['id']}',
                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                    ),
                    BookingStatusBadge(
                      status: booking['status'] ?? '',
                      languageCode: Provider.of<AuthProvider>(context, listen: false).languageCode,
                    ),
                  ],
                ),
                const Divider(),
                _buildDetailRow('User ID', booking['userId'] ?? ''),
                _buildDetailRow('Crop', booking['crop'] ?? ''),
                _buildDetailRow('Location', booking['location'] ?? ''),
                _buildDetailRow('Date Range',
                  '${_formatDate(booking['startDate'])} to ${_formatDate(booking['endDate'])}'),
                _buildDetailRow('Boxes', booking['quantity']?.toString() ?? ''),
                _buildDetailRow('Total Amount', '₹${booking['totalAmount'] ?? ''}'),
                if (booking['notes'] != null && booking['notes'].toString().isNotEmpty)
                  _buildDetailRow('Notes', booking['notes']),
                const SizedBox(height: 8),
                Align(
                  alignment: Alignment.centerRight,
                  child: TextButton(
                    onPressed: () => _showBookingDetails(booking),
                    child: const Text('View Details'),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Booking Management'),
        backgroundColor: AppTheme.primaryColor,
        foregroundColor: Colors.white,
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: 'Active'),
            Tab(text: 'Completed'),
            Tab(text: 'Cancelled'),
          ],
        ),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              controller: _searchController,
              decoration: const InputDecoration(
                hintText: 'Search bookings...',
                prefixIcon: Icon(Icons.search),
                border: OutlineInputBorder(),
              ),
              onChanged: (value) {
                setState(() {
                  _searchQuery = value;
                });
              },
            ),
          ),
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: getAllBookingsStream(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (snapshot.hasError) {
                  return Center(child: Text('Error: ${snapshot.error}'));
                }
                if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                  return const Center(child: Text('No bookings found'));
                }
                final docs = snapshot.data!.docs;
                return TabBarView(
                  controller: _tabController,
                  children: [
                    _buildBookingList(docs, 'pending'), // or 'active' if you use that status
                    _buildBookingList(docs, 'completed'),
                    _buildBookingList(docs, 'cancelled'),
                  ],
                );
              },
            ),
          ),
          ElevatedButton(
            child: Text('Simple Firestore Test'),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => SimpleFirestoreTest()),
              );
            },
          ),
        ],
      ),
    );
  }
}