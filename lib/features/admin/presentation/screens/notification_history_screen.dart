import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/constants/app_constants.dart';

class NotificationHistoryScreen extends StatefulWidget {
  const NotificationHistoryScreen({super.key});

  @override
  State<NotificationHistoryScreen> createState() => _NotificationHistoryScreenState();
}

class _NotificationHistoryScreenState extends State<NotificationHistoryScreen> {
  String _selectedFilter = 'all';
  final DateFormat _dateFormat = DateFormat('dd MMM yyyy, HH:mm');

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Notification History'),
        backgroundColor: AppTheme.primaryColor,
        foregroundColor: Colors.white,
        actions: [
          PopupMenuButton<String>(
            onSelected: (value) {
              setState(() {
                _selectedFilter = value;
              });
            },
            itemBuilder: (context) => [
              const PopupMenuItem(
                value: 'all',
                child: Text('All Messages'),
              ),
              const PopupMenuItem(
                value: 'booking_confirmation',
                child: Text('Booking Confirmations'),
              ),
              const PopupMenuItem(
                value: 'periodic_reminder',
                child: Text('Periodic Reminders'),
              ),
              const PopupMenuItem(
                value: 'harvest_alert',
                child: Text('Harvest Alerts'),
              ),
              const PopupMenuItem(
                value: 'custom_message',
                child: Text('Custom Messages'),
              ),
              const PopupMenuItem(
                value: 'success',
                child: Text('Successful'),
              ),
              const PopupMenuItem(
                value: 'failed',
                child: Text('Failed'),
              ),
            ],
            child: const Padding(
              padding: EdgeInsets.all(16.0),
              child: Icon(Icons.filter_list),
            ),
          ),
        ],
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: _getNotificationsStream(),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return Center(
              child: Text('Error: ${snapshot.error}'),
            );
          }

          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }

          final notifications = snapshot.data?.docs ?? [];

          if (notifications.isEmpty) {
            return const Center(
              child: Text(
                'No notifications found',
                style: TextStyle(fontSize: 16, color: Colors.grey),
              ),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16.0),
            itemCount: notifications.length,
            itemBuilder: (context, index) {
              final notification = notifications[index].data() as Map<String, dynamic>;
              return _buildNotificationCard(notification);
            },
          );
        },
      ),
    );
  }

  Stream<QuerySnapshot> _getNotificationsStream() {
    Query query = FirebaseFirestore.instance
        .collection(AppConstants.notificationsCollection)
        .orderBy('timestamp', descending: true);

    // Apply filters
    if (_selectedFilter == 'booking_confirmation') {
      query = query.where('type', isEqualTo: 'booking_confirmation');
    } else if (_selectedFilter == 'periodic_reminder') {
      query = query.where('type', isEqualTo: 'periodic_reminder');
    } else if (_selectedFilter == 'harvest_alert') {
      query = query.where('type', isEqualTo: 'harvest_alert');
    } else if (_selectedFilter == 'custom_message') {
      query = query.where('type', isEqualTo: 'custom_message');
    } else if (_selectedFilter == 'success') {
      query = query.where('success', isEqualTo: true);
    } else if (_selectedFilter == 'failed') {
      query = query.where('success', isEqualTo: false);
    }

    return query.limit(100).snapshots();
  }

  Widget _buildNotificationCard(Map<String, dynamic> notification) {
    final timestamp = notification['timestamp'] as Timestamp?;
    final type = notification['type'] as String? ?? '';
    final message = notification['message'] as String? ?? '';
    final success = notification['success'] as bool? ?? false;
    final error = notification['error'] as String?;
    final userId = notification['userId'] as String? ?? '';
    final bookingId = notification['bookingId'] as String?;

    return Card(
      margin: const EdgeInsets.only(bottom: 12.0),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  _getTypeIcon(type),
                  color: _getTypeColor(type),
                  size: 20,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    _getTypeTitle(type),
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: success ? Colors.green : Colors.red,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    success ? 'Success' : 'Failed',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              message,
              style: const TextStyle(fontSize: 14),
            ),
            if (error != null && error.isNotEmpty) ...[
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.red.shade50,
                  borderRadius: BorderRadius.circular(4),
                  border: Border.all(color: Colors.red.shade200),
                ),
                child: Text(
                  'Error: $error',
                  style: TextStyle(
                    color: Colors.red.shade700,
                    fontSize: 12,
                  ),
                ),
              ),
            ],
            const SizedBox(height: 8),
            Row(
              children: [
                Icon(Icons.person, size: 16, color: Colors.grey.shade600),
                const SizedBox(width: 4),
                Expanded(
                  child: Text(
                    'User: ${userId.length > 20 ? '${userId.substring(0, 20)}...' : userId}',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey.shade600,
                    ),
                  ),
                ),
              ],
            ),
            if (bookingId != null) ...[
              const SizedBox(height: 4),
              Row(
                children: [
                  Icon(Icons.calendar_today, size: 16, color: Colors.grey.shade600),
                  const SizedBox(width: 4),
                  Expanded(
                    child: Text(
                      'Booking: ${bookingId.length > 20 ? '${bookingId.substring(0, 20)}...' : bookingId}',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey.shade600,
                      ),
                    ),
                  ),
                ],
              ),
            ],
            const SizedBox(height: 8),
            Row(
              children: [
                Icon(Icons.access_time, size: 16, color: Colors.grey.shade600),
                const SizedBox(width: 4),
                Text(
                  timestamp != null ? _dateFormat.format(timestamp.toDate()) : 'Unknown time',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey.shade600,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  IconData _getTypeIcon(String type) {
    switch (type) {
      case 'booking_confirmation':
        return Icons.check_circle;
      case 'periodic_reminder':
        return Icons.schedule;
      case 'harvest_alert':
        return Icons.warning;
      case 'custom_message':
        return Icons.message;
      default:
        return Icons.notifications;
    }
  }

  Color _getTypeColor(String type) {
    switch (type) {
      case 'booking_confirmation':
        return Colors.green;
      case 'periodic_reminder':
        return Colors.blue;
      case 'harvest_alert':
        return Colors.orange;
      case 'custom_message':
        return Colors.purple;
      default:
        return Colors.grey;
    }
  }

  String _getTypeTitle(String type) {
    switch (type) {
      case 'booking_confirmation':
        return 'Booking Confirmation';
      case 'periodic_reminder':
        return 'Periodic Reminder';
      case 'harvest_alert':
        return 'Harvest Alert';
      case 'custom_message':
        return 'Custom Message';
      default:
        return 'Notification';
    }
  }
} 