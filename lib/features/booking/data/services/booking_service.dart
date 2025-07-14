import 'package:cloud_firestore/cloud_firestore.dart';
import '../../domain/models/booking_model.dart';

class BookingService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<void> createBooking(BookingModel booking) async {
    try {
      final docRef = await _firestore.collection('bookings').add(booking.toFirestore());
      print('BookingService: Booking created with ID: ${docRef.id}');
      print('BookingService: Booking userId: ${booking.userId}');
    } catch (e) {
      print('BookingService: Error creating booking: $e');
      rethrow;
    }
  }

  Stream<List<BookingModel>> getUserBookings(String userId) {
    print('BookingService: Fetching bookings for user: $userId');
    
    if (userId.isEmpty) {
      print('BookingService: userId is empty, returning empty stream');
      return Stream.value(<BookingModel>[]);
    }
    
    try {
      return _firestore
          .collection('bookings')
          .where('userId', isEqualTo: userId)
          .orderBy('createdAt', descending: true)
          .limit(20)
          .snapshots()
          .map((snapshot) {
            print('BookingService: Received ${snapshot.docs.length} bookings from Firestore');
            
            final List<BookingModel> bookings = [];
            for (var doc in snapshot.docs) {
              try {
                print('BookingService: Processing booking ${doc.id}');
                final booking = BookingModel.fromFirestore(doc);
                print('BookingService: Booking ${doc.id} userId: ${booking.userId}');
                bookings.add(booking);
              } catch (e) {
                print('BookingService: Error processing booking ${doc.id}: $e');
                print('BookingService: Document data: ${doc.data()}');
              }
            }
            
            print('BookingService: Successfully processed ${bookings.length} bookings');
            return bookings;
          })
          .handleError((error) {
            print('BookingService: Error in stream: $error');
            return <BookingModel>[];
          });
    } catch (e) {
      print('BookingService: Exception in getUserBookings: $e');
      return Stream.value(<BookingModel>[]);
    }
  }

  Future<void> updateBookingStatus(String bookingId, String status) async {
    try {
      await _firestore
          .collection('bookings')
          .doc(bookingId)
          .update({'status': status});
      print('BookingService: Updated booking $bookingId status to $status');
    } catch (e) {
      print('BookingService: Error updating booking status: $e');
      rethrow;
    }
  }
}
