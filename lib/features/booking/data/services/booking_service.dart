import 'package:cloud_firestore/cloud_firestore.dart';
import '../../domain/models/booking_model.dart';

class BookingService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<void> createBooking(BookingModel booking) async {
    try {
      final docRef = await _firestore.collection('bookings').add(booking.toFirestore());
      print('Booking created with ID: ${docRef.id}'); // Debug print
    } catch (e) {
      print('Error creating booking: $e'); // Debug print
      rethrow;
    }
  }

  Stream<List<BookingModel>> getUserBookings(String userId) {
    print('Fetching bookings for user: $userId'); // Debug print
    try {
      return _firestore
          .collection('bookings')
          .where('userId', isEqualTo: userId)
          .orderBy('createdAt', descending: true)
          .snapshots()
          .map((snapshot) {
            print('Received ${snapshot.docs.length} bookings'); // Debug print
            return snapshot.docs
                .map((doc) {
                  print('Processing booking ${doc.id}'); // Debug print
                  return BookingModel.fromFirestore(doc);
                })
                .toList();
          })
          .handleError((error) {
            print('Error in stream: $error'); // Debug print
            return <BookingModel>[];
          });
    } catch (e) {
      print('Exception in getUserBookings: $e'); // Debug print
      return Stream.value(<BookingModel>[]);
    }
  }

  Future<void> updateBookingStatus(String bookingId, String status) async {
    await _firestore
        .collection('bookings')
        .doc(bookingId)
        .update({'status': status});
  }
}
