import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:excel/excel.dart' as excel;
import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'dart:html' as html;

// Update the import path for AuthProvider
import '../../../auth/presentation/providers/auth_provider.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../booking/presentation/widgets/booking_status_badge.dart';
import '../../../../core/utils/whatsapp_messaging.dart';
import '../../../notifications/notification_service.dart';

class BookingManagementScreen extends StatefulWidget {
  const BookingManagementScreen({super.key});

  @override
  State<BookingManagementScreen> createState() => _BookingManagementScreenState();
}

class _BookingManagementScreenState extends State<BookingManagementScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

  // Add crop filter state
  final List<String> _cropKeys = [
    'crop_pomegranate',
    'crop_watermelon',
    'crop_mango',
    'crop_muskmelon',
    'crop_onion_seeds',
    'crop_jujube',
  ];
  String? _selectedCropKey;

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
    return FirebaseFirestore.instance
        .collection('bookings')
        .orderBy('createdAt', descending: true)
        .limit(100)
        .snapshots();
  }

  List<DocumentSnapshot> _getFilteredBookings(List<DocumentSnapshot> bookings, String status) {
    return bookings.where((booking) {
      final data = booking.data() as Map<String, dynamic>;
      // For the 'active' tab, include both 'active' and 'pending'
      final statusMatch = status == 'active'
          ? (data['status'] == 'active' || data['status'] == 'pending')
          : data['status'] == status;

      // Filter by search query if present
      final searchMatch = _searchQuery.isEmpty ||
          (data['id'] ?? '').toLowerCase().contains(_searchQuery.toLowerCase()) ||
          (data['userName'] ?? '').toLowerCase().contains(_searchQuery.toLowerCase()) ||
          (data['userPhone'] ?? '').toLowerCase().contains(_searchQuery.toLowerCase()) ||
          (data['crop'] ?? '').toLowerCase().contains(_searchQuery.toLowerCase()) ||
          (data['location'] ?? '').toLowerCase().contains(_searchQuery.toLowerCase());

      // Filter by selected crop if set
      final cropMatch = _selectedCropKey == null || _selectedCropKey!.isEmpty
        ? true
        : _getText(_selectedCropKey!).toLowerCase() == (data['crop'] ?? '').toString().toLowerCase();

      return statusMatch && searchMatch && cropMatch;
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

  void _showBookingDetails(DocumentSnapshot booking) async {
    final data = booking.data() as Map<String, dynamic>;
    Map<String, dynamic>? user;
    if (data['userId'] != null && data['userId'].toString().isNotEmpty) {
      user = await _fetchUserDetails(data['userId']);
    }
    _showBookingDetailsWithUser(booking, user);
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
      'crop_pomegranate': {
        'en': 'Pomegranate',
        'hi': 'अनार',
        'mr': 'डाळिंब',
      },
      'crop_watermelon': {
        'en': 'Watermelon',
        'hi': 'तरबूज',
        'mr': 'टरबूज',
      },
      'crop_mango': {
        'en': 'Mango',
        'hi': 'आम',
        'mr': 'आंबा',
      },
      'crop_muskmelon': {
        'en': 'Muskmelon',
        'hi': 'खरबूजा',
        'mr': 'खरबूज',
      },
      'crop_onion_seeds': {
        'en': 'Onion Seeds',
        'hi': 'प्याज के बीज',
        'mr': 'कांदा बियाणे',
      },
      'crop_jujube': {
        'en': 'Jujube',
        'hi': 'बेर',
        'mr': 'बोर',
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
        actions: [
          IconButton(
            icon: const Icon(Icons.download),
            tooltip: 'Export to Excel',
            onPressed: () async {
              await _exportBookingsToExcel();
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
              'Booking Management',
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
                  decoration: InputDecoration(
                    hintText: _getText('search'),
                    prefixIcon: const Icon(Icons.search),
                    border: InputBorder.none,
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
            ),
            const SizedBox(height: 12),
            // Crop filter dropdown
            Row(
              children: [
                Text(_getText('crop') + ': '),
                const SizedBox(width: 8),
                Expanded(
                  child: DropdownButtonFormField<String>(
                    value: _selectedCropKey,
                    isExpanded: true,
                    decoration: InputDecoration(
                      hintText: _getText('Choose'),
                      border: OutlineInputBorder(),
                      contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 0),
                    ),
                    items: [
                      DropdownMenuItem<String>(
                        value: null,
                        child: Text(_getText('Choose')),
                      ),
                      ..._cropKeys.map((key) => DropdownMenuItem<String>(
                        value: key,
                        child: Text(_getText(key)),
                      )),
                    ],
                    onChanged: (value) {
                      setState(() {
                        _selectedCropKey = value;
                      });
                    },
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),
            TabBar(
              controller: _tabController,
              tabs: [
                Tab(icon: Icon(Icons.check_circle, color: Colors.green), text: _getText('active')),
                Tab(icon: Icon(Icons.done_all, color: Colors.blue), text: _getText('completed')),
                Tab(icon: Icon(Icons.cancel, color: Colors.red), text: _getText('cancelled')),
              ],
            ),
            const SizedBox(height: 16),
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
      ),
    );
  }

  Future<void> _exportBookingsToExcel() async {
    final snapshot = await _getBookingsStream().first;
    final bookings = snapshot.docs;
    if (bookings.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No bookings to export.')),
      );
      return;
    }
    final workbook = excel.Excel.createExcel();
    final sheet = workbook['Bookings'];
    sheet.appendRow([
      'Booking ID', 'User Name', 'Phone', 'Crop', 'Location', 'Start Date', 'End Date', 'Box Count', 'Total Amount', 'Deposit', 'Status', 'Created At'
    ]);
    for (final booking in bookings) {
      final data = booking.data() as Map<String, dynamic>;
      sheet.appendRow([
        booking.id,
        data['userName'] ?? '',
        data['userPhone'] ?? '',
        data['crop'] ?? '',
        data['location'] ?? '',
        data['startDate'] ?? '',
        data['endDate'] ?? '',
        data['boxCount'] ?? '',
        data['totalAmount'] ?? '',
        data['depositAmount'] ?? '',
        data['status'] ?? '',
        data['createdAt'] ?? '',
      ]);
    }
    final fileBytes = workbook.encode();
    if (kIsWeb) {
      final blob = html.Blob([fileBytes]);
      final url = html.Url.createObjectUrlFromBlob(blob);
      final anchor = html.AnchorElement(href: url)
        ..setAttribute('download', 'bookings.xlsx')
        ..click();
      html.Url.revokeObjectUrl(url);
    } else {
      final dir = await getApplicationDocumentsDirectory();
      final file = File('${dir.path}/bookings.xlsx');
      await file.writeAsBytes(fileBytes!);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Exported to ${file.path}')),
      );
    }
  }

  Widget _buildBookingList(String status) {
    return StreamBuilder<QuerySnapshot>(
      stream: _getBookingsStream(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        if (snapshot.hasError) {
          return Center(child: Text('Error:  [1m${snapshot.error} [0m'));
        }

        final bookings = snapshot.data?.docs ?? [];
        // Sort by createdAt descending
        bookings.sort((a, b) {
          final aData = a.data() as Map<String, dynamic>;
          final bData = b.data() as Map<String, dynamic>;
          final aCreated = aData['createdAt'] is Timestamp ? (aData['createdAt'] as Timestamp).toDate() : DateTime.tryParse(aData['createdAt']?.toString() ?? '') ?? DateTime(1970);
          final bCreated = bData['createdAt'] is Timestamp ? (bData['createdAt'] as Timestamp).toDate() : DateTime.tryParse(bData['createdAt']?.toString() ?? '') ?? DateTime(1970);
          return bCreated.compareTo(aCreated);
        });
        final filteredBookings = _getFilteredBookings(bookings, status);
        if (filteredBookings.isEmpty) {
          return Center(child: Text(l10n('No bookings found')));
        }
        return SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: DataTable(
            columns: [
              DataColumn(label: Text(_getText('bookingId'))),
              DataColumn(label: Text(_getText('customer'))),
              DataColumn(label: Text(_getText('phone'))),
              DataColumn(label: Text(_getText('crop'))),
              DataColumn(label: Text(_getText('dateRange'))),
              DataColumn(label: Text(_getText('boxCount'))),
              DataColumn(label: Text(_getText('totalAmount'))),
              DataColumn(label: Text(_getText('bookingStatus'))),
              DataColumn(label: Text('Actions')),
            ],
            rows: filteredBookings.map((booking) {
            final data = booking.data() as Map<String, dynamic>;
              final bookingId = booking.id;
              final userName = data['userName'] ?? '';
              final userPhone = data['userPhone'] ?? '';
              final crop = data['crop'] ?? '';
              String formatDate(dynamic value) {
                if (value == null) return '';
                if (value is String) return value.split(' ').first;
                if (value is Timestamp) return value.toDate().toString().split(' ').first;
                return value.toString();
              }
              final startDate = formatDate(data['startDate']);
              final endDate = formatDate(data['endDate']);
              final dateRange = '$startDate to $endDate';
              final boxCount = data['boxCount']?.toString() ?? '';
              final totalAmount = data['totalAmount'] != null ? '₹${data['totalAmount']}' : '';
              final bookingStatus = data['status'] ?? '';
              return DataRow(cells: [
                DataCell(Text(bookingId)),
                DataCell(Text(userName)),
                DataCell(Text(userPhone)),
                DataCell(Text(crop)),
                DataCell(Text(dateRange)),
                DataCell(Text(boxCount)),
                DataCell(Text(totalAmount)),
                DataCell(_statusDropdown(booking, bookingStatus)),
                DataCell(Row(
                  children: [
                    IconButton(
                      icon: const Icon(Icons.message, color: Colors.green),
                      tooltip: 'Send WhatsApp',
                    onPressed: () async {
                        final message =
                            '🟡 *BeeMan Booking Update*\n\n'
                            'Hello $userName,\n\n'
                            'Your booking *$bookingId* for *$crop* is currently *${bookingStatus.toUpperCase()}*.\n\n'
                            '📅 *Dates:* $dateRange\n\n'
                            'If you have any questions, reply to this message or contact support.';
                        final sent = await NotificationService.sendCustomMessage(
                          phoneNumber: userPhone,
                          message: message,
                          userId: data['userId'] ?? '',
                          bookingId: bookingId,
                        );
                      ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text(sent ? 'WhatsApp message sent!' : 'Failed to send WhatsApp message.')),
                      );
                    },
                  ),
                    IconButton(
                      icon: const Icon(Icons.info_outline, color: Colors.blue),
                      tooltip: 'View Details',
                      onPressed: () => _showBookingDetails(booking),
                    ),
                  ],
                )),
              ]);
            }).toList(),
          ),
        );
      },
    );
  }

  Widget _statusDropdown(DocumentSnapshot booking, String currentStatus) {
    return DropdownButton<String>(
      value: currentStatus,
      items: <String>['pending', 'active', 'completed', 'cancelled']
          .map((status) => DropdownMenuItem(
                value: status,
                child: Text(status[0].toUpperCase() + status.substring(1)),
              ))
          .toList(),
      onChanged: (newStatus) async {
        if (newStatus != null && newStatus != currentStatus) {
          await FirebaseFirestore.instance.collection('bookings').doc(booking.id).update({'status': newStatus});
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Status updated to $newStatus')),
          );
        }
      },
    );
  }

  void _showBookingDetailsWithUser(DocumentSnapshot booking, Map<String, dynamic>? user) {
    final data = booking.data() as Map<String, dynamic>;
    // Fallbacks for user info
    final displayName = user?['displayName'] ?? data['userName'] ?? user?['email'] ?? 'N/A';
    final phone = user?['phone'] ?? data['userPhone'] ?? 'N/A';
    final email = user?['email'] ?? 'N/A';
    final crop = data['crop'] ?? 'N/A';
    final location = data['location'] ?? 'N/A';
    String formatDate(dynamic value) {
      if (value == null) return 'N/A';
      if (value is String) return value.split(' ').first;
      if (value is Timestamp) return value.toDate().toString().split(' ').first;
      return value.toString();
    }
    final startDate = formatDate(data['startDate']);
    final endDate = formatDate(data['endDate']);
    final boxCount = (data['boxCount'] ?? 0).toString();
    final boxNumbers = (data['boxNumbers'] != null && (data['boxNumbers'] as List).isNotEmpty)
      ? (data['boxNumbers'] as List).join(', ')
      : null;
    final totalAmount = data['totalAmount'] != null ? '₹${data['totalAmount']}' : 'N/A';
    final depositAmount = data['depositAmount'] != null ? '₹${data['depositAmount']}' : null;
    final paymentStatus = data['paymentStatus'] ?? 'N/A';
    final bookingStatus = data['status'] ?? 'N/A';
    final notes = data['notes'] ?? '';
    final createdAt = formatDate(data['createdAt']);

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('${_getText('bookingDetails')}: ${booking.id}'),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildDetailRow(_getText('customer'), displayName),
              _buildDetailRow(_getText('phone'), phone),
              _buildDetailRow(_getText('email'), email),
              _buildDetailRow(_getText('crop'), crop),
              _buildDetailRow(_getText('location'), location),
              _buildDetailRow(_getText('dateRange'), '$startDate to $endDate'),
              _buildDetailRow(_getText('boxCount'), boxCount),
              if (boxNumbers != null) _buildDetailRow('Box Numbers', boxNumbers),
              _buildDetailRow(_getText('totalAmount'), totalAmount),
              if (depositAmount != null) _buildDetailRow('Deposit', depositAmount),
              _buildDetailRow(_getText('paymentStatus'), paymentStatus),
              _buildDetailRow(_getText('bookingStatus'), bookingStatus),
              if (notes.isNotEmpty) _buildDetailRow(_getText('notes'), notes),
              _buildDetailRow(_getText('createdAt'), createdAt),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(_getText('close')),
          ),
          if (data['status'] == 'active' || data['status'] == 'pending')
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

  Future<String?> _showCustomMessageDialog(BuildContext context) async {
    final controller = TextEditingController();
    return showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Send Custom WhatsApp Message'),
        content: TextField(
          controller: controller,
          maxLines: 4,
          decoration: const InputDecoration(
            hintText: 'Enter your message here...',
            border: OutlineInputBorder(),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, controller.text),
            child: const Text('Send'),
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

String l10n(String text) => text; // Placeholder for localization