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

  // Mock data for bookings
  final List<Map<String, dynamic>> _bookings = [
    {
      'id': 'BK001',
      'userId': 'U001',
      'userName': 'Rajesh Sharma',
      'userPhone': '+91 9876543210',
      'crop': 'Sunflower',
      'location': 'Pune, Maharashtra',
      'startDate': '2023-11-15',
      'endDate': '2023-12-15',
      'boxCount': 5,
      'totalAmount': 12500.0,
      'paymentStatus': 'Paid',
      'bookingStatus': 'active',
      'notes': 'Farmer requested delivery to the field',
      'createdAt': '2023-11-10',
    },
    {
      'id': 'BK002',
      'userId': 'U002',
      'userName': 'Priya Patel',
      'userPhone': '+91 8765432109',
      'crop': 'Apple',
      'location': 'Nashik, Maharashtra',
      'startDate': '2023-10-01',
      'endDate': '2023-11-01',
      'boxCount': 3,
      'totalAmount': 7500.0,
      'paymentStatus': 'Paid',
      'bookingStatus': 'completed',
      'notes': '',
      'createdAt': '2023-09-25',
    },
    {
      'id': 'BK003',
      'userId': 'U003',
      'userName': 'Amit Kumar',
      'userPhone': '+91 7654321098',
      'crop': 'Mango',
      'location': 'Ratnagiri, Maharashtra',
      'startDate': '2023-12-01',
      'endDate': '2024-01-01',
      'boxCount': 4,
      'totalAmount': 10000.0,
      'paymentStatus': 'Pending',
      'bookingStatus': 'active',
      'notes': 'First-time customer, needs guidance',
      'createdAt': '2023-11-20',
    },
    {
      'id': 'BK004',
      'userId': 'U004',
      'userName': 'Sneha Desai',
      'userPhone': '+91 6543210987',
      'crop': 'Strawberry',
      'location': 'Mahabaleshwar, Maharashtra',
      'startDate': '2023-09-15',
      'endDate': '2023-10-15',
      'boxCount': 2,
      'totalAmount': 5000.0,
      'paymentStatus': 'Paid',
      'bookingStatus': 'cancelled',
      'notes': 'Cancelled due to weather conditions',
      'createdAt': '2023-09-10',
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

  List<Map<String, dynamic>> _getFilteredBookings(String status) {
    return _bookings.where((booking) {
      // Filter by status
      final statusMatch = booking['bookingStatus'] == status;
      
      // Filter by search query if present
      final searchMatch = _searchQuery.isEmpty ||
          booking['id'].toLowerCase().contains(_searchQuery.toLowerCase()) ||
          booking['userName'].toLowerCase().contains(_searchQuery.toLowerCase()) ||
          booking['userPhone'].toLowerCase().contains(_searchQuery.toLowerCase()) ||
          booking['crop'].toLowerCase().contains(_searchQuery.toLowerCase()) ||
          booking['location'].toLowerCase().contains(_searchQuery.toLowerCase());
      
      return statusMatch && searchMatch;
    }).toList();
  }

  void _showBookingDetails(Map<String, dynamic> booking) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('${_getText('bookingDetails')}: ${booking['id']}'),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildDetailRow(_getText('customer'), booking['userName']),
              _buildDetailRow(_getText('phone'), booking['userPhone']),
              _buildDetailRow(_getText('crop'), booking['crop']),
              _buildDetailRow(_getText('location'), booking['location']),
              _buildDetailRow(_getText('dateRange'), '${booking['startDate']} to ${booking['endDate']}'),
              _buildDetailRow(_getText('boxCount'), booking['boxCount'].toString()),
              _buildDetailRow(_getText('totalAmount'), '₹${booking['totalAmount']}'),
              _buildDetailRow(_getText('paymentStatus'), booking['paymentStatus']),
              _buildDetailRow(_getText('bookingStatus'), booking['bookingStatus']),
              if (booking['notes'].isNotEmpty)
                _buildDetailRow(_getText('notes'), booking['notes']),
              _buildDetailRow(_getText('createdAt'), booking['createdAt']),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(_getText('close')),
          ),
          if (booking['bookingStatus'] == 'active')
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

  void _showStatusChangeDialog(Map<String, dynamic> booking) {
    String newStatus = booking['bookingStatus'];
    
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
              setState(() {
                final index = _bookings.indexWhere((b) => b['id'] == booking['id']);
                if (index != -1) {
                  _bookings[index]['bookingStatus'] = newStatus;
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
    final filteredBookings = _getFilteredBookings(status);
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
                      '${_getText('bookingId')}: ${booking['id']}',
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                    BookingStatusBadge(
                      status: booking['bookingStatus'],
                      languageCode: authProvider.languageCode,
                    ),
                  ],
                ),
                const Divider(),
                _buildInfoRow(Icons.person, _getText('customer'), booking['userName']),
                _buildInfoRow(Icons.phone, _getText('phone'), booking['userPhone']),
                _buildInfoRow(Icons.grass, _getText('crop'), booking['crop']),
                _buildInfoRow(Icons.location_on, _getText('location'), booking['location']),
                _buildInfoRow(
                  Icons.date_range,
                  _getText('dateRange'),
                  '${booking['startDate']} to ${booking['endDate']}',
                ),
                _buildInfoRow(
                  Icons.inventory_2,
                  _getText('boxCount'),
                  booking['boxCount'].toString(),
                ),
                _buildInfoRow(
                  Icons.payments,
                  _getText('totalAmount'),
                  '₹${booking['totalAmount']}',
                ),
                const SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    TextButton.icon(
                      icon: const Icon(Icons.visibility),
                      label: Text(_getText('viewDetails')),
                      onPressed: () => _showBookingDetails(booking),
                    ),
                    if (booking['bookingStatus'] == 'active')
                      TextButton.icon(
                        icon: const Icon(Icons.edit),
                        label: Text(_getText('changeStatus')),
                        onPressed: () => _showStatusChangeDialog(booking),
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
}