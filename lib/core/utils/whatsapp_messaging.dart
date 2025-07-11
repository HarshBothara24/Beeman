import 'dart:convert';
import 'package:http/http.dart' as http;

class WhatsAppMessaging {
  static const String apiUrl = 'YOUR_WHATSAPP_API_URL'; // TODO: Set your WhatsApp API endpoint
  static const String apiToken = 'YOUR_WHATSAPP_API_TOKEN'; // TODO: Set your WhatsApp API token

  /// Sends a WhatsApp booking confirmation message to the user.
  static Future<bool> sendBookingConfirmation({
    required String phoneNumber,
    required String userName,
    required int numberOfBoxes,
    required String crop,
    required String startDate,
    required String endDate,
    required double totalPaid,
    String? supportContact,
  }) async {
    final message =
        'Hello $userName,\nYour booking for $numberOfBoxes bee boxes for $crop from $startDate to $endDate is confirmed! Total paid: ₹$totalPaid. For support: ${supportContact ?? ''}';
    try {
      final response = await http.post(
        Uri.parse(apiUrl),
        headers: {
          'Authorization': 'Bearer $apiToken',
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          // Adjust payload as per your WhatsApp API provider
          'to': phoneNumber,
          'type': 'text',
          'text': {'body': message},
        }),
      );
      if (response.statusCode == 200 || response.statusCode == 201) {
        return true;
      } else {
        print('WhatsApp API error: ${response.statusCode} ${response.body}');
        return false;
      }
    } catch (e) {
      print('WhatsApp send error: $e');
      return false;
    }
  }

  /// Sends a custom WhatsApp message to the user.
  static Future<bool> sendCustomMessage({
    required String phoneNumber,
    required String message,
  }) async {
    try {
      final response = await http.post(
        Uri.parse(apiUrl),
        headers: {
          'Authorization': 'Bearer $apiToken',
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'to': phoneNumber,
          'type': 'text',
          'text': {'body': message},
        }),
      );
      if (response.statusCode == 200 || response.statusCode == 201) {
        return true;
      } else {
        print('WhatsApp API error: ${response.statusCode} ${response.body}');
        return false;
      }
    } catch (e) {
      print('WhatsApp send error: $e');
      return false;
    }
  }
} 