import 'package:cloud_firestore/cloud_firestore.dart';

class DashboardService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<int> getActiveBookingsCount(String userId) async {
    final query = await _firestore
        .collection('bookings')
        .where('userId', isEqualTo: userId)
        .where('status', whereIn: ['pending', 'active'])
        .get();
    return query.docs.length;
  }

  Future<int> getBeeBoxesCount(String userId) async {
    final query = await _firestore
        .collection('bookings')
        .where('userId', isEqualTo: userId)
        .where('status', whereIn: ['pending', 'active'])
        .get();
    int totalBoxes = 0;
    for (var doc in query.docs) {
      totalBoxes += (doc['boxCount'] ?? 0) as int;
    }
    return totalBoxes;
  }

  Future<int> getTotalSpent(String userId) async {
    final query = await _firestore
        .collection('payments')
        .where('userId', isEqualTo: userId)
        .where('paymentStatus', isEqualTo: 'success')
        .get();
    int total = 0;
    for (var doc in query.docs) {
      total += (doc['totalAmount'] ?? 0) as int;
    }
    return total;
  }
} 