import 'package:flutter/material.dart';
import '../../data/services/dashboard_service.dart';

class DashboardProvider extends ChangeNotifier {
  final DashboardService _dashboardService = DashboardService();

  int activeBookings = 0;
  int totalSpent = 0;
  int beeBoxes = 0;
  bool isLoading = false;
  String? error;

  Future<void> fetchDashboardStats(String userId) async {
    isLoading = true;
    error = null;
    notifyListeners();
    try {
      final results = await Future.wait([
        _dashboardService.getActiveBookingsCount(userId),
        _dashboardService.getTotalSpent(userId),
        _dashboardService.getBeeBoxesCount(userId),
      ]);
      activeBookings = results[0];
      totalSpent = results[1];
      beeBoxes = results[2];
    } catch (e) {
      error = e.toString();
    }
    isLoading = false;
    notifyListeners();
  }
} 