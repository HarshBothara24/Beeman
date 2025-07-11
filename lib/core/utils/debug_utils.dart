import 'package:cloud_firestore/cloud_firestore.dart';

class DebugUtils {
  static Future<void> debugUserBookings(String userId) async {
    print('=== DEBUG: User Bookings for $userId ===');
    
    try {
      // Check all bookings
      final allBookings = await FirebaseFirestore.instance
          .collection('bookings')
          .get();
      
      print('Total bookings in collection: ${allBookings.docs.length}');
      
      // Check user-specific bookings
      final userBookings = await FirebaseFirestore.instance
          .collection('bookings')
          .where('userId', isEqualTo: userId)
          .get();
      
      print('Bookings for user $userId: ${userBookings.docs.length}');
      
      for (var doc in userBookings.docs) {
        final data = doc.data();
        print('Booking ${doc.id}:');
        print('  - userId: ${data['userId']}');
        print('  - status: ${data['status']}');
        print('  - paymentStatus: ${data['paymentStatus']}');
        print('  - createdAt: ${data['createdAt']}');
        print('  - crop: ${data['crop']}');
        print('  - amount: ${data['depositAmount']}');
      }
      
      // Check for bookings with empty userId
      final emptyUserIdBookings = await FirebaseFirestore.instance
          .collection('bookings')
          .where('userId', isEqualTo: '')
          .get();
      
      print('Bookings with empty userId: ${emptyUserIdBookings.docs.length}');
      
      // Check for bookings without userId field
      final allDocs = allBookings.docs;
      int missingUserIdCount = 0;
      for (var doc in allDocs) {
        final data = doc.data();
        if (!data.containsKey('userId')) {
          missingUserIdCount++;
          print('Booking ${doc.id} missing userId field');
        }
      }
      print('Bookings missing userId field: $missingUserIdCount');
      
    } catch (e) {
      print('Error in debugUserBookings: $e');
    }
    
    print('=== END DEBUG ===');
  }
  
  static Future<void> debugAllBookings() async {
    print('=== DEBUG: All Bookings ===');
    
    try {
      final allBookings = await FirebaseFirestore.instance
          .collection('bookings')
          .get();
      
      print('Total bookings: ${allBookings.docs.length}');
      
      for (var doc in allBookings.docs) {
        final data = doc.data();
        print('Booking ${doc.id}:');
        print('  - userId: ${data['userId'] ?? 'MISSING'}');
        print('  - status: ${data['status'] ?? 'MISSING'}');
        print('  - paymentStatus: ${data['paymentStatus'] ?? 'MISSING'}');
        print('  - createdAt: ${data['createdAt'] ?? 'MISSING'}');
        print('  - crop: ${data['crop'] ?? 'MISSING'}');
        print('  - amount: ${data['depositAmount'] ?? 'MISSING'}');
        print('---');
      }
      
    } catch (e) {
      print('Error in debugAllBookings: $e');
    }
    
    print('=== END DEBUG ===');
  }
} 