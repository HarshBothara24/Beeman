import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

// Update the import path for AuthProvider
import '../../../auth/presentation/providers/auth_provider.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../booking/presentation/widgets/booking_status_badge.dart';

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

  Stream<QuerySnapshot> _getBookingsStream() {
    return FirebaseFirestore.instance.collection('bookings').snapshots();
  }

  List<DocumentSnapshot> _getFilteredBookings(List<DocumentSnapshot> bookings, String status) {
    return bookings.where((booking) {
      final data = booking.data() as Map<String, dynamic>;
      // Filter by status
      final statusMatch = data['status'] == status;

      // Filter by search query if present
      final searchMatch = _searchQuery.isEmpty ||
          (data['id'] ?? '').toLowerCase().contains(_searchQuery.toLowerCase()) ||
          (data['userName'] ?? '').toLowerCase().contains(_searchQuery.toLowerCase()) ||
          (data['userPhone'] ?? '').toLowerCase().contains(_searchQuery.toLowerCase()) ||
          (data['crop'] ?? '').toLowerCase().contains(_searchQuery.toLowerCase()) ||
          (data['location'] ?? '').toLowerCase().contains(_searchQuery.toLowerCase());

      return statusMatch && searchMatch;
    }).toList();
  }

  Future<Map<String, dynamic>?> _fetchUserDetails(String userId) async {
    try {
      final userDoc = await FirebaseFirestore.instance.collection('users').doc(userId).get();
      return userDoc.data();
    } catch (e) {
      print('Error fetching user details: $e');
      return null;
    }
  }

  void _showBookingDetails(DocumentSnapshot booking) {
    final data = booking.data() as Map<String, dynamic>;
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('${_getText('bookingDetails')}: ${data['id']}'),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildDetailRow(_getText('customer'), data['userName'] ?? ''),
              _buildDetailRow(_getText('phone'), data['userPhone'] ?? ''),
              _buildDetailRow(_getText('crop'), data['crop'] ?? ''),
              _buildDetailRow(_getText('location'), data['location'] ?? ''),
              _buildDetailRow(_getText('dateRange'), '${data['startDate']} to ${data['endDate']}'),
              _buildDetailRow(_getText('boxCount'), (data['boxCount'] ?? 0).toString()),
              _buildDetailRow(_getText('totalAmount'), '₹${data['totalAmount']}'),
              _buildDetailRow(_getText('paymentStatus'), data['paymentStatus'] ?? ''),
              _buildDetailRow(_getText('bookingStatus'), data['status'] ?? ''),
              if (data['notes'] != null && data['notes'].isNotEmpty)
                _buildDetailRow(_getText('notes'), data['notes']),
              _buildDetailRow(_getText('createdAt'), data['createdAt'] ?? ''),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(_getText('close')),
          ),
          if (data['status'] == 'active')
            TextButton(
              onPressed: () {
                Navigator.pop(context);
                _showStatusChangeDialog(booking);
              },
              child: Text(_getText('changeStatus')),
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
            width: 100,
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

  void _showStatusChangeDialog(DocumentSnapshot booking) {
    final data = booking.data() as Map<String, dynamic>;
    String newStatus = data['status'] ?? '';
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(_getText('changeBookingStatus')),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            RadioListTile<String>(
              title: Text(_getText('active')),
              value: 'active',
              groupValue: newStatus,
              onChanged: (value) {
                setState(() {
                  newStatus = value!;
                });
              },
            ),
            RadioListTile<String>(
              title: Text(_getText('completed')),
              value: 'completed',
              groupValue: newStatus,
              onChanged: (value) {
                setState(() {
                  newStatus = value!;
                });
              },
            ),
            RadioListTile<String>(
              title: Text(_getText('cancelled')),
              value: 'cancelled',
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
              FirebaseFirestore.instance
                  .collection('bookings')
                  .doc(booking.id)
                  .update({'status': newStatus});
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
      'bookingManagement': {
        'en': 'Booking Management',
        'hi': 'बुकिंग प्रबंधन',
        'mr': 'बुकिंग व्यवस्थापन',
      },
      'active': {
        'en': 'Active',
        'hi': 'सक्रिय',
        'mr': 'सक्रिय',
      },
      'completed': {
        'en': 'Completed',
        'hi': 'पूर्ण',
        'mr': 'पूर्ण',
      },
      'cancelled': {
        'en': 'Cancelled',
        'hi': 'रद्द',
        'mr': 'रद्द',
      },
      'search': {
        'en': 'Search bookings...',
        'hi': 'बुकिंग खोजें...',
        'mr': 'बुकिंग शोधा...',
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
      'phone': {
        'en': 'Phone',
        'hi': 'फोन',
        'mr': 'फोन',
      },
      'crop': {
        'en': 'Crop',
        'hi': 'फसल',
        'mr': 'पीक',
      },
      'location': {
        'en': 'Location',
        'hi': 'स्थान',
        'mr': 'स्थान',
      },
      'dateRange': {
        'en': 'Date Range',
        'hi': 'तारीख सीमा',
        'mr': 'तारीख श्रेणी',
      },
      'boxCount': {
        'en': 'Box Count',
        'hi': 'बॉक्स संख्या',
        'mr': 'बॉक्स संख्या',
      },
      'totalAmount': {
        'en': 'Total Amount',
        'hi': 'कुल राशि',
        'mr': 'एकूण रक्कम',
      },
      'paymentStatus': {
        'en': 'Payment Status',
        'hi': 'भुगतान स्थिति',
        'mr': 'पेमेंट स्थिती',
      },
      'bookingStatus': {
        'en': 'Booking Status',
        'hi': 'बुकिंग स्थिति',
        'mr': 'बुकिंग स्थिती',
      },
      'notes': {
        'en': 'Notes',
        'hi': 'नोट्स',
        'mr': 'नोट्स',
      },
      'createdAt': {
        'en': 'Created At',
        'hi': 'बनाया गया',
        'mr': 'तयार केले',
      },
      'viewDetails': {
        'en': 'View Details',
        'hi': 'विवरण देखें',
        'mr': 'तपशील पहा',
      },
      'changeStatus': {
        'en': 'Change Status',
        'hi': 'स्थिति बदलें',
        'mr': 'स्थिती बदला',
      },
      'bookingDetails': {
        'en': 'Booking Details',
        'hi': 'बुकिंग विवरण',
        'mr': 'बुकिंग तपशील',
      },
      'close': {
        'en': 'Close',
        'hi': 'बंद करें',
        'mr': 'बंद करा',
      },
      'changeBookingStatus': {
        'en': 'Change Booking Status',
        'hi': 'बुकिंग स्थिति बदलें',
        'mr': 'बुकिंग स्थिती बदला',
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
        'en': 'Booking status updated successfully',
        'hi': 'बुकिंग स्थिति सफलतापूर्वक अपडेट की गई',
        'mr': 'बुकिंग स्थिती यशस्वीरित्या अपडेट केली',
      },
      'noBookingsFound': {
        'en': 'No bookings found',
        'hi': 'कोई बुकिंग नहीं मिली',
        'mr': 'कोणतीही बुकिंग आढळली नाही',
      },
    };

    return textMap[key]?[languageCode] ?? textMap[key]?['en'] ?? key;
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    
    return Scaffold(
      appBar: AppBar(
        title: Text(_getText('bookingManagement')),
        bottom: TabBar(
          controller: _tabController,
          tabs: [
            Tab(text: _getText('active')),
            Tab(text: _getText('completed')),
            Tab(text: _getText('cancelled')),
          ],
        ),
      ),
      body: Column(
        children: [
          // Search bar
          Padding(
            padding: const EdgeInsets.all(16.0),
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
          // Tab content
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                _buildBookingList('active'),
                _buildBookingList('completed'),
                _buildBookingList('cancelled'),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBookingList(String status) {
    return StreamBuilder<QuerySnapshot>(
      stream: _getBookingsStream(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        if (snapshot.hasError) {
          return Center(child: Text('Error: ${snapshot.error}'));
        }

        final bookings = snapshot.data?.docs ?? [];
        final filteredBookings = _getFilteredBookings(bookings, status);
        final authProvider = Provider.of<AuthProvider>(context);

        if (filteredBookings.isEmpty) {
          return Center(
            child: Text(_getText('noBookingsFound')),
          );
        }

        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: filteredBookings.length,
          itemBuilder: (context, index) {
            final booking = filteredBookings[index];
            final data = booking.data() as Map<String, dynamic>;
            final userId = data['userId'] ?? '';
            return FutureBuilder<Map<String, dynamic>?>(
              future: _fetchUserDetails(userId),
              builder: (context, userSnapshot) {
                final user = userSnapshot.data;
                return ListTile(
                  title: Text('Booking for: \\${user?['displayName'] ?? user?['email'] ?? 'Unknown'}'),
                  subtitle: Text('Phone: \\${user?['phone'] ?? 'N/A'}\nEmail: \\${user?['email'] ?? 'N/A'}'),
                  trailing: IconButton(
                    icon: Icon(Icons.delete, color: Colors.red),
                    onPressed: () async {
                      await FirebaseFirestore.instance.collection('bookings').doc(booking.id).delete();
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('Booking deleted')),
                      );
                    },
                  ),
                  onTap: () => _showBookingDetailsWithUser(booking, user),
                );
              },
            );
          },
        );
      },
    );
  }

  void _showBookingDetailsWithUser(DocumentSnapshot booking, Map<String, dynamic>? user) {
    final data = booking.data() as Map<String, dynamic>;
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('${_getText('bookingDetails')}: ${booking.id}'),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildDetailRow(_getText('customer'), user?['displayName'] ?? user?['email'] ?? ''),
              _buildDetailRow(_getText('phone'), user?['phone'] ?? ''),
              _buildDetailRow(_getText('email'), user?['email'] ?? ''),
              _buildDetailRow(_getText('crop'), data['crop'] ?? ''),
              _buildDetailRow(_getText('location'), data['location'] ?? ''),
              _buildDetailRow(_getText('dateRange'), '${data['startDate']} to ${data['endDate']}'),
              _buildDetailRow(_getText('boxCount'), (data['boxCount'] ?? 0).toString()),
              _buildDetailRow(_getText('totalAmount'), '₹${data['totalAmount']}'),
              _buildDetailRow(_getText('paymentStatus'), data['paymentStatus'] ?? ''),
              _buildDetailRow(_getText('bookingStatus'), data['status'] ?? ''),
              if (data['notes'] != null && data['notes'].isNotEmpty)
                _buildDetailRow(_getText('notes'), data['notes']),
              _buildDetailRow(_getText('createdAt'), data['createdAt'] ?? ''),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(_getText('close')),
          ),
          if (data['status'] == 'active')
            TextButton(
              onPressed: () {
                Navigator.pop(context);
                _showStatusChangeDialog(booking);
              },
              child: Text(_getText('changeStatus')),
            ),
        ],
      ),
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
}