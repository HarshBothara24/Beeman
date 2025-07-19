import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import '../../../core/utils/whatsapp_messaging.dart';
import '../../../core/constants/app_constants.dart';
import '../../../features/booking/domain/models/booking_model.dart';

class NotificationService {
  static final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  /// Sends booking confirmation message
  static Future<bool> sendBookingConfirmation(BookingModel booking) async {
    try {
      final template = await fetchLatestWhatsAppTemplate();
      final dateRange = '${DateFormat('dd MMM yyyy').format(booking.startDate)} to ${DateFormat('dd MMM yyyy').format(booking.endDate)}';
      final message = template
          .replaceAll('{userName}', booking.userName ?? 'User')
          .replaceAll('{bookingId}', booking.id)
          .replaceAll('{crop}', booking.crop)
          .replaceAll('{status}', 'CONFIRMED')
          .replaceAll('{dateRange}', dateRange);
      final response = await WhatsAppMessaging.sendCustomMessage(
        phoneNumber: booking.userPhone ?? booking.phone,
        message: message,
      );
      // Log the notification
      await _logNotification(
        userId: booking.userId,
        bookingId: booking.id,
        type: 'booking_confirmation',
        message: 'Booking confirmation sent',
        success: response.success,
        error: response.error,
      );
      return response.success;
    } catch (e) {
      print('Error sending booking confirmation: $e');
      return false;
    }
  }

  /// Sends periodic reminder messages during pollination period
  static Future<bool> sendPeriodicReminder(BookingModel booking, int dayNumber) async {
    try {
      final response = await WhatsAppMessaging.sendPeriodicReminder(
        phoneNumber: booking.userPhone ?? booking.phone,
        userName: booking.userName ?? 'User',
        crop: booking.crop,
        numberOfBoxes: booking.numberOfBoxes,
        dayNumber: dayNumber,
        supportContact: AppConstants.supportPhone,
      );

      // Log the notification
      await _logNotification(
        userId: booking.userId,
        bookingId: booking.id,
        type: 'periodic_reminder',
        message: 'Periodic reminder sent for day $dayNumber',
        success: response.success,
        error: response.error,
      );

      return response.success;
    } catch (e) {
      print('Error sending periodic reminder: $e');
      return false;
    }
  }

  /// Sends harvest alert before pollination period ends
  static Future<bool> sendHarvestAlert(BookingModel booking) async {
    try {
      final response = await WhatsAppMessaging.sendHarvestAlert(
        phoneNumber: booking.userPhone ?? booking.phone,
        userName: booking.userName ?? 'User',
        crop: booking.crop,
        numberOfBoxes: booking.numberOfBoxes,
        endDate: DateFormat('dd MMM yyyy').format(booking.endDate),
        supportContact: AppConstants.supportPhone,
      );

      // Log the notification
      await _logNotification(
        userId: booking.userId,
        bookingId: booking.id,
        type: 'harvest_alert',
        message: 'Harvest alert sent',
        success: response.success,
        error: response.error,
      );

      return response.success;
    } catch (e) {
      print('Error sending harvest alert: $e');
      return false;
    }
  }

  /// Sends custom message from admin
  static Future<bool> sendCustomMessage({
    required String phoneNumber,
    required String message,
    required String userId,
    String? bookingId,
  }) async {
    try {
      final response = await WhatsAppMessaging.sendCustomMessage(
        phoneNumber: phoneNumber,
        message: message,
      );

      // Log the notification
      await _logNotification(
        userId: userId,
        bookingId: bookingId,
        type: 'custom_message',
        message: 'Custom message sent',
        success: response.success,
        error: response.error,
      );

      return response.success;
    } catch (e) {
      print('Error sending custom message: $e');
      return false;
    }
  }

  /// Fetches the latest WhatsApp message template from Firestore
  static Future<String> fetchLatestWhatsAppTemplate() async {
    final snapshot = await FirebaseFirestore.instance
        .collection('message_templates')
        .orderBy('updatedAt', descending: true)
        .limit(1)
        .get();
    if (snapshot.docs.isNotEmpty) {
      return snapshot.docs.first['body'] as String;
    }
    // Default template if none exists
    return '''🟡 *BeeMan Booking Update*

Hello {userName},

Your booking *{bookingId}* for *{crop}* is currently *{status}*.

📅 *Dates:* {dateRange}

If you have any questions, reply to this message or contact support.''';
  }

  /// Sends a WhatsApp message using the latest template for booking status updates
  static Future<bool> sendBookingStatusMessage({
    required String phoneNumber,
    required String userName,
    required String bookingId,
    required String crop,
    required String status,
    required String dateRange,
    required String userId,
  }) async {
    try {
      final template = await fetchLatestWhatsAppTemplate();
      final message = template
          .replaceAll('{userName}', userName)
          .replaceAll('{bookingId}', bookingId)
          .replaceAll('{crop}', crop)
          .replaceAll('{status}', status)
          .replaceAll('{dateRange}', dateRange);
      final response = await WhatsAppMessaging.sendCustomMessage(
        phoneNumber: phoneNumber,
        message: message,
      );
      await _logNotification(
        userId: userId,
        bookingId: bookingId,
        type: 'custom_message',
        message: 'Booking status message sent',
        success: response.success,
        error: response.error,
      );
      return response.success;
    } catch (e) {
      print('Error sending booking status message: $e');
      return false;
    }
  }

  /// Processes daily notifications for active bookings
  static Future<void> processDailyNotifications() async {
    try {
      final now = DateTime.now();
      final today = DateTime(now.year, now.month, now.day);

      // Get all active bookings
      final activeBookings = await _firestore
          .collection(AppConstants.bookingsCollection)
          .where('status', isEqualTo: 'active')
          .where('startDate', isLessThanOrEqualTo: today)
          .where('endDate', isGreaterThanOrEqualTo: today)
          .get();

      for (final doc in activeBookings.docs) {
        final booking = BookingModel.fromFirestore(doc);
        await _processBookingNotifications(booking, today);
      }
    } catch (e) {
      print('Error processing daily notifications: $e');
    }
  }

  /// Process notifications for a specific booking
  static Future<void> _processBookingNotifications(BookingModel booking, DateTime today) async {
    final startDate = DateTime(
      booking.startDate.year,
      booking.startDate.month,
      booking.startDate.day,
    );
    final endDate = DateTime(
      booking.endDate.year,
      booking.endDate.month,
      booking.endDate.day,
    );

    // Calculate days since start
    final daysSinceStart = today.difference(startDate).inDays;
    final daysUntilEnd = endDate.difference(today).inDays;

    // Send periodic reminders (every 3 days)
    if (daysSinceStart > 0 && daysSinceStart % 3 == 0) {
      await sendPeriodicReminder(booking, daysSinceStart + 1);
    }

    // Send harvest alert (3 days before end)
    if (daysUntilEnd == 3) {
      await sendHarvestAlert(booking);
    }
  }

  /// Log notification to Firestore
  static Future<void> _logNotification({
    required String userId,
    required String type,
    required String message,
    required bool success,
    String? bookingId,
    String? error,
  }) async {
    try {
      await _firestore.collection(AppConstants.notificationsCollection).add({
        'userId': userId,
        'bookingId': bookingId,
        'type': type,
        'message': message,
        'success': success,
        'error': error,
        'timestamp': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      print('Error logging notification: $e');
    }
  }

  /// Get notification history for a user
  static Stream<QuerySnapshot> getUserNotifications(String userId) {
    return _firestore
        .collection(AppConstants.notificationsCollection)
        .where('userId', isEqualTo: userId)
        .orderBy('timestamp', descending: true)
        .limit(50)
        .snapshots();
  }

  /// Get notification history for admin
  static Stream<QuerySnapshot> getAllNotifications() {
    return _firestore
        .collection(AppConstants.notificationsCollection)
        .orderBy('timestamp', descending: true)
        .limit(100)
        .snapshots();
  }

  /// Test WhatsApp API connection
  static Future<bool> testWhatsAppConnection() async {
    return await WhatsAppMessaging.testConnection();
  }

  /// Check if WhatsApp API is configured
  static bool isWhatsAppConfigured() {
    return WhatsAppMessaging.isConfigured();
  }
} 