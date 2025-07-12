import 'dart:convert';
import 'package:http/http.dart' as http;
import '../constants/app_constants.dart';

/// WhatsApp API Response Model
class WhatsAppResponse {
  final bool success;
  final String? messageId;
  final String? error;
  final int statusCode;

  WhatsAppResponse({
    required this.success,
    this.messageId,
    this.error,
    required this.statusCode,
  });

  factory WhatsAppResponse.fromJson(Map<String, dynamic> json, int statusCode) {
    // TezIndia API response format
    final responseText = json.toString().toLowerCase();
    final isSuccess = responseText.contains('success') || 
                     responseText.contains('sent') || 
                     responseText.contains('delivered') ||
                     statusCode == 200;
    
    return WhatsAppResponse(
      success: isSuccess,
      messageId: json['message_id'] ?? json['id'] ?? 'unknown',
      error: isSuccess ? null : (json['error'] ?? json['message'] ?? 'Unknown error'),
      statusCode: statusCode,
    );
  }
}

class WhatsAppMessaging {
  // API Configuration for rpayconnect.com TezIndia
  static const String apiUrl = AppConstants.whatsappApiUrl;
  static const String appKey = AppConstants.whatsappAppKey;
  static const String authKey = AppConstants.whatsappAuthKey;

  /// Sends a WhatsApp booking confirmation message to the user.
  static Future<WhatsAppResponse> sendBookingConfirmation({
    required String phoneNumber,
    required String userName,
    required int numberOfBoxes,
    required String crop,
    required String startDate,
    required String endDate,
    required double totalPaid,
    String? supportContact,
  }) async {
    final message = _formatBookingConfirmationMessage(
      userName: userName,
      crop: crop,
      startDate: startDate,
      endDate: endDate,
      boxes: numberOfBoxes,
      amount: totalPaid,
      supportContact: supportContact ?? AppConstants.supportPhone,
    );

    return await _sendMessage(phoneNumber, message);
  }

  /// Sends a periodic reminder message during pollination period.
  static Future<WhatsAppResponse> sendPeriodicReminder({
    required String phoneNumber,
    required String userName,
    required String crop,
    required int numberOfBoxes,
    required int dayNumber,
    String? supportContact,
  }) async {
    final message = _formatPeriodicReminderMessage(
      userName: userName,
      crop: crop,
      boxes: numberOfBoxes,
      dayNumber: dayNumber,
      supportContact: supportContact ?? AppConstants.supportPhone,
    );

    return await _sendMessage(phoneNumber, message);
  }

  /// Sends a harvest alert message before pollination period ends.
  static Future<WhatsAppResponse> sendHarvestAlert({
    required String phoneNumber,
    required String userName,
    required String crop,
    required int numberOfBoxes,
    required String endDate,
    String? supportContact,
  }) async {
    final message = _formatHarvestAlertMessage(
      userName: userName,
      crop: crop,
      boxes: numberOfBoxes,
      endDate: endDate,
      supportContact: supportContact ?? AppConstants.supportPhone,
    );

    return await _sendMessage(phoneNumber, message);
  }

  /// Sends a custom WhatsApp message to the user.
  static Future<WhatsAppResponse> sendCustomMessage({
    required String phoneNumber,
    required String message,
  }) async {
    return await _sendMessage(phoneNumber, message);
  }

  /// Core method to send WhatsApp messages via rpayconnect.com TezIndia API
  static Future<WhatsAppResponse> _sendMessage(String phoneNumber, String message) async {
    try {
      // Clean phone number (remove spaces, dashes, etc.)
      final cleanPhoneNumber = _cleanPhoneNumber(phoneNumber);
      
      // Prepare the request payload for TezIndia API
      final payload = {
        'appkey': appKey,
        'authkey': authKey,
        'to': cleanPhoneNumber,
        'message': message,
      };

      final response = await http.post(
        Uri.parse(apiUrl),
        headers: {
          'Content-Type': 'application/x-www-form-urlencoded',
        },
        body: payload,
      ).timeout(const Duration(seconds: 30));

      // TezIndia API returns text response, not JSON
      final responseText = response.body;
      final whatsappResponse = WhatsAppResponse.fromJson({'response': responseText}, response.statusCode);

      if (whatsappResponse.success) {
        print('WhatsApp message sent successfully: $responseText');
      } else {
        print('WhatsApp API error: ${response.statusCode} - $responseText');
      }

      return whatsappResponse;
    } catch (e) {
      print('WhatsApp send error: $e');
      return WhatsAppResponse(
        success: false,
        error: e.toString(),
        statusCode: 0,
      );
    }
  }

  /// Cleans phone number for WhatsApp API
  static String _cleanPhoneNumber(String phoneNumber) {
    // Remove all non-numeric characters except +
    String cleaned = phoneNumber.replaceAll(RegExp(r'[^\d+]'), '');
    
    // Ensure it starts with country code
    if (!cleaned.startsWith('+')) {
      // Add +91 for India if no country code
      if (cleaned.length == 10) {
        cleaned = '+91$cleaned';
      } else if (cleaned.length == 12 && cleaned.startsWith('91')) {
        cleaned = '+$cleaned';
      }
    }
    
    return cleaned;
  }

  /// Formats booking confirmation message
  static String _formatBookingConfirmationMessage({
    required String userName,
    required String crop,
    required String startDate,
    required String endDate,
    required int boxes,
    required double amount,
    required String supportContact,
  }) {
    return AppConstants.bookingConfirmationTemplate
        .replaceAll('{userName}', userName)
        .replaceAll('{crop}', crop)
        .replaceAll('{startDate}', startDate)
        .replaceAll('{endDate}', endDate)
        .replaceAll('{boxes}', boxes.toString())
        .replaceAll('{amount}', amount.toStringAsFixed(2))
        .replaceAll('{supportContact}', supportContact);
  }

  /// Formats periodic reminder message
  static String _formatPeriodicReminderMessage({
    required String userName,
    required String crop,
    required int boxes,
    required int dayNumber,
    required String supportContact,
  }) {
    return AppConstants.periodicReminderTemplate
        .replaceAll('{userName}', userName)
        .replaceAll('{crop}', crop)
        .replaceAll('{boxes}', boxes.toString())
        .replaceAll('{dayNumber}', dayNumber.toString())
        .replaceAll('{supportContact}', supportContact);
  }

  /// Formats harvest alert message
  static String _formatHarvestAlertMessage({
    required String userName,
    required String crop,
    required int boxes,
    required String endDate,
    required String supportContact,
  }) {
    return AppConstants.harvestAlertTemplate
        .replaceAll('{userName}', userName)
        .replaceAll('{crop}', crop)
        .replaceAll('{boxes}', boxes.toString())
        .replaceAll('{endDate}', endDate)
        .replaceAll('{supportContact}', supportContact);
  }

  /// Validates if the WhatsApp API is properly configured
  static bool isConfigured() {
    return apiUrl != 'YOUR_RPAYCONNECT_API_ENDPOINT' &&
           appKey != 'YOUR_RPAYCONNECT_APP_KEY' &&
           authKey != 'YOUR_RPAYCONNECT_AUTH_KEY';
  }

  /// Test the WhatsApp API connection
  static Future<bool> testConnection() async {
    if (!isConfigured()) {
      print('WhatsApp API not configured. Please update the constants.');
      return false;
    }

    try {
      // Test with a simple message
      final testResponse = await _sendMessage(
        '+919876543210', // Test number
        'Test message from BeeMan app',
      );
      
      return testResponse.success;
    } catch (e) {
      print('WhatsApp API connection test failed: $e');
      return false;
    }
  }
} 