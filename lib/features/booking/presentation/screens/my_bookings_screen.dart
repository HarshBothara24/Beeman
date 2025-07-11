import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/utils/debug_utils.dart';
import '../../domain/models/booking_model.dart';
import '../providers/booking_provider.dart';
import '../../../auth/presentation/providers/auth_provider.dart';

class MyBookingsScreen extends StatefulWidget {
  const MyBookingsScreen({super.key});

  @override
  State<MyBookingsScreen> createState() => _MyBookingsScreenState();
}

class _MyBookingsScreenState extends State<MyBookingsScreen> {
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchBookings();
  }

  Future<void> _fetchBookings() async {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final bookingProvider = Provider.of<BookingProvider>(context, listen: false);
    final userId = authProvider.user?.uid;
    if (userId != null) {
      await bookingProvider.fetchUserBookings(userId);
    }
    setState(() {
      _isLoading = false;
    });
  }

  Future<void> _debugBookings() async {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final userId = authProvider.user?.uid;
    if (userId != null) {
      await DebugUtils.debugUserBookings(userId);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Debug info printed to console')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('My Bookings'),
        backgroundColor: AppTheme.primaryColor,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _fetchBookings,
          ),
          IconButton(
            icon: const Icon(Icons.bug_report),
            onPressed: _debugBookings,
            tooltip: 'Debug Bookings',
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'My Bookings',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: AppTheme.textPrimary),
                  ),
                  const SizedBox(height: 16),
                  Expanded(
                    child: Consumer<BookingProvider>(
                      builder: (context, bookingProvider, _) {
                        final bookings = bookingProvider.bookings;

                        if (bookings.isEmpty) {
                          return Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                const Icon(
                                  Icons.calendar_today_outlined,
                                  size: 64,
                                  color: Colors.grey,
                                ),
                                const SizedBox(height: 16),
                                const Text(
                                  'No bookings found',
                                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                                ),
                                const SizedBox(height: 8),
                                const Text(
                                  'If you recently made a booking, try refreshing or check the debug info.',
                                  style: TextStyle(fontSize: 14, color: Colors.grey),
                                  textAlign: TextAlign.center,
                                ),
                                const SizedBox(height: 16),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    ElevatedButton(
                                      onPressed: _fetchBookings,
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: AppTheme.primaryColor,
                                      ),
                                      child: const Text('Refresh'),
                                    ),
                                    const SizedBox(width: 16),
                                    ElevatedButton(
                                      onPressed: _debugBookings,
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: Colors.orange,
                                      ),
                                      child: const Text('Debug'),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          );
                        }

                        return ListView.builder(
                          padding: EdgeInsets.zero,
                          itemCount: bookings.length,
                          itemBuilder: (context, index) {
                            final booking = bookings[index];
                            return AnimatedContainer(
                              duration: const Duration(milliseconds: 300),
                              curve: Curves.easeInOut,
                              margin: const EdgeInsets.only(bottom: 16),
                              child: Card(
                                elevation: 2,
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                                child: Padding(
                                  padding: const EdgeInsets.all(16),
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Row(
                                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                        children: [
                                          Text(
                                            'Booking #${booking.id.substring(0, 8)}',
                                            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                                          ),
                                          _buildStatusChip(booking.status),
                                        ],
                                      ),
                                      const Divider(),
                                      _buildInfoRow('Crop', booking.crop),
                                      _buildInfoRow('Location', booking.location),
                                      _buildInfoRow('Boxes', booking.boxNumbers.length.toString()),
                                      _buildInfoRow(
                                        'Duration',
                                        '${booking.startDate.toLocal().toString().split(' ')[0]} to ${booking.endDate.toLocal().toString().split(' ')[0]}',
                                      ),
                                      _buildInfoRow('Total Amount', '₹${booking.totalAmount}'),
                                      _buildInfoRow('Deposit Paid', '₹${booking.depositAmount}'),
                                    ],
                                  ),
                                ),
                              ),
                            );
                          },
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
    );
  }

  Widget _buildBookingCard(BookingModel booking) {
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
                  'Booking #${booking.id.substring(0, 8)}',
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
                _buildStatusChip(booking.status),
              ],
            ),
            const Divider(),
            _buildInfoRow('Crop', booking.crop),
            _buildInfoRow('Location', booking.location),
            _buildInfoRow('Boxes', booking.boxNumbers.length.toString()),
            _buildInfoRow(
              'Duration',
              '${booking.startDate.toLocal().toString().split(' ')[0]} to ${booking.endDate.toLocal().toString().split(' ')[0]}',
            ),
            _buildInfoRow('Total Amount', '₹${booking.totalAmount}'),
            _buildInfoRow('Deposit Paid', '₹${booking.depositAmount}'),
          ],
        ),
      ),
    );
  }

  Widget _buildStatusChip(String status) {
    Color color;
    switch (status.toLowerCase()) {
      case 'active':
        color = Colors.green;
        break;
      case 'pending':
        color = Colors.orange;
        break;
      case 'completed':
        color = Colors.blue;
        break;
      case 'cancelled':
        color = Colors.red;
        break;
      default:
        color = Colors.grey;
    }

    return Chip(
      label: Text(
        status.toUpperCase(),
        style: const TextStyle(
          color: Colors.white,
          fontSize: 12,
        ),
      ),
      backgroundColor: color,
      padding: const EdgeInsets.symmetric(horizontal: 8),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: const TextStyle(
              color: AppTheme.textSecondary,
            ),
          ),
          Text(
            value,
            style: const TextStyle(
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}