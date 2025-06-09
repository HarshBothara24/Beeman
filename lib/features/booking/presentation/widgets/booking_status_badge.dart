import 'package:flutter/material.dart';

import '../../../../core/constants/app_constants.dart';

class BookingStatusBadge extends StatelessWidget {
  final String status;
  final String languageCode;

  const BookingStatusBadge({
    super.key,
    required this.status,
    required this.languageCode,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: _getStatusColor().withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: _getStatusColor()),
      ),
      child: Text(
        _getStatusText(),
        style: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.bold,
          color: _getStatusColor(),
        ),
      ),
    );
  }

  Color _getStatusColor() {
    switch (status) {
      case 'active':
        return Colors.green;
      case 'completed':
        return Colors.blue;
      case 'cancelled':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  String _getStatusText() {
    switch (status) {
      case 'active':
        return _getActiveText();
      case 'completed':
        return _getCompletedText();
      case 'cancelled':
        return _getCancelledText();
      default:
        return status;
    }
  }

  String _getActiveText() {
    switch (languageCode) {
      case AppConstants.hindi:
        return 'सक्रिय';
      case AppConstants.marathi:
        return 'सक्रिय';
      default:
        return 'Active';
    }
  }

  String _getCompletedText() {
    switch (languageCode) {
      case AppConstants.hindi:
        return 'पूर्ण';
      case AppConstants.marathi:
        return 'पूर्ण';
      default:
        return 'Completed';
    }
  }

  String _getCancelledText() {
    switch (languageCode) {
      case AppConstants.hindi:
        return 'रद्द';
      case AppConstants.marathi:
        return 'रद्द';
      default:
        return 'Cancelled';
    }
  }
}