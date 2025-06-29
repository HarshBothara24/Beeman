import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class FirestoreService {
  static final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  static final FirebaseAuth _auth = FirebaseAuth.instance;

  // Collection references
  static CollectionReference get usersCollection => _firestore.collection('users');
  static CollectionReference get beeBoxesCollection => _firestore.collection('bee_boxes');
  static CollectionReference get bookingsCollection => _firestore.collection('bookings');
  static CollectionReference get paymentsCollection => _firestore.collection('payments');
  static CollectionReference get adminCollection => _firestore.collection('admins');

  // User Management
  static Future<void> createUser({
    required String uid,
    required String email,
    required String name,
    String? phone,
    String? address,
    String userType = 'customer',
  }) async {
    try {
      await usersCollection.doc(uid).set({
        'uid': uid,
        'email': email,
        'name': name,
        'phone': phone,
        'address': address,
        'userType': userType,
        'createdAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      throw Exception('Failed to create user: $e');
    }
  }

  static Future<Map<String, dynamic>?> getUser(String uid) async {
    try {
      DocumentSnapshot doc = await usersCollection.doc(uid).get();
      return doc.data() as Map<String, dynamic>?;
    } catch (e) {
      throw Exception('Failed to get user: $e');
    }
  }

  static Future<void> updateUser(String uid, Map<String, dynamic> data) async {
    try {
      data['updatedAt'] = FieldValue.serverTimestamp();
      await usersCollection.doc(uid).update(data);
    } catch (e) {
      throw Exception('Failed to update user: $e');
    }
  }

  // Bee Box Management
  static Future<void> createBeeBox({
    required String name,
    required String description,
    required double pricePerDay,
    required int quantity,
    required String location,
    String? imageUrl,
    bool isAvailable = true,
  }) async {
    try {
      await beeBoxesCollection.add({
        'name': name,
        'description': description,
        'pricePerDay': pricePerDay,
        'quantity': quantity,
        'availableQuantity': quantity,
        'location': location,
        'imageUrl': imageUrl,
        'isAvailable': isAvailable,
        'createdAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      throw Exception('Failed to create bee box: $e');
    }
  }

  static Stream<QuerySnapshot> getBeeBoxes() {
    return beeBoxesCollection
        .where('isAvailable', isEqualTo: true)
        .orderBy('createdAt', descending: true)
        .snapshots();
  }

  static Future<Map<String, dynamic>?> getBeeBox(String beeBoxId) async {
    try {
      DocumentSnapshot doc = await beeBoxesCollection.doc(beeBoxId).get();
      return doc.data() as Map<String, dynamic>?;
    } catch (e) {
      throw Exception('Failed to get bee box: $e');
    }
  }

  static Future<void> updateBeeBox(String beeBoxId, Map<String, dynamic> data) async {
    try {
      data['updatedAt'] = FieldValue.serverTimestamp();
      await beeBoxesCollection.doc(beeBoxId).update(data);
    } catch (e) {
      throw Exception('Failed to update bee box: $e');
    }
  }

  // Booking Management
  static Future<String> createBooking({
    required String userId,
    required String beeBoxId,
    required DateTime startDate,
    required DateTime endDate,
    required int quantity,
    required double totalAmount,
    String? notes,
  }) async {
    try {
      DocumentReference bookingRef = await bookingsCollection.add({
        'userId': userId,
        'beeBoxId': beeBoxId,
        'startDate': Timestamp.fromDate(startDate),
        'endDate': Timestamp.fromDate(endDate),
        'quantity': quantity,
        'totalAmount': totalAmount,
        'notes': notes,
        'status': 'pending', // pending, confirmed, completed, cancelled
        'createdAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
      });

      // Update bee box availability
      await updateBeeBoxAvailability(beeBoxId, quantity, false);

      return bookingRef.id;
    } catch (e) {
      throw Exception('Failed to create booking: $e');
    }
  }

  static Stream<QuerySnapshot> getUserBookings(String userId) {
    return bookingsCollection
        .where('userId', isEqualTo: userId)
        .orderBy('createdAt', descending: true)
        .snapshots();
  }

  static Stream<QuerySnapshot> getAllBookings() {
    return bookingsCollection
        .orderBy('createdAt', descending: true)
        .snapshots();
  }

  static Future<void> updateBookingStatus(String bookingId, String status) async {
    try {
      await bookingsCollection.doc(bookingId).update({
        'status': status,
        'updatedAt': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      throw Exception('Failed to update booking status: $e');
    }
  }

  // Payment Management
  static Future<void> createPayment({
    required String bookingId,
    required String userId,
    required double amount,
    required String paymentMethod,
    required String status,
    String? transactionId,
  }) async {
    try {
      await paymentsCollection.add({
        'bookingId': bookingId,
        'userId': userId,
        'amount': amount,
        'paymentMethod': paymentMethod,
        'status': status, // pending, completed, failed, refunded
        'transactionId': transactionId,
        'createdAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      throw Exception('Failed to create payment: $e');
    }
  }

  static Stream<QuerySnapshot> getUserPayments(String userId) {
    return paymentsCollection
        .where('userId', isEqualTo: userId)
        .orderBy('createdAt', descending: true)
        .snapshots();
  }

  // Admin Management
  static Future<bool> isAdmin(String uid) async {
    try {
      DocumentSnapshot doc = await adminCollection.doc(uid).get();
      return doc.exists;
    } catch (e) {
      return false;
    }
  }

  static Future<void> addAdmin(String uid, Map<String, dynamic> adminData) async {
    try {
      await adminCollection.doc(uid).set({
        'uid': uid,
        ...adminData,
        'createdAt': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      throw Exception('Failed to add admin: $e');
    }
  }

  // Utility Methods
  static Future<void> updateBeeBoxAvailability(String beeBoxId, int quantity, bool isAdding) async {
    try {
      DocumentSnapshot beeBoxDoc = await beeBoxesCollection.doc(beeBoxId).get();
      Map<String, dynamic> beeBoxData = beeBoxDoc.data() as Map<String, dynamic>;
      
      int currentAvailable = beeBoxData['availableQuantity'] ?? 0;
      int newAvailable = isAdding ? currentAvailable + quantity : currentAvailable - quantity;
      
      await beeBoxesCollection.doc(beeBoxId).update({
        'availableQuantity': newAvailable,
        'isAvailable': newAvailable > 0,
        'updatedAt': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      throw Exception('Failed to update bee box availability: $e');
    }
  }

  // Search and Filter Methods
  static Stream<QuerySnapshot> searchBeeBoxes(String searchTerm) {
    return beeBoxesCollection
        .where('name', isGreaterThanOrEqualTo: searchTerm)
        .where('name', isLessThan: searchTerm + '\uf8ff')
        .where('isAvailable', isEqualTo: true)
        .snapshots();
  }

  static Stream<QuerySnapshot> getBookingsByStatus(String status) {
    return bookingsCollection
        .where('status', isEqualTo: status)
        .orderBy('createdAt', descending: true)
        .snapshots();
  }

  // Real-time listeners
  static Stream<DocumentSnapshot> watchUser(String uid) {
    return usersCollection.doc(uid).snapshots();
  }

  static Stream<DocumentSnapshot> watchBeeBox(String beeBoxId) {
    return beeBoxesCollection.doc(beeBoxId).snapshots();
  }

  static Stream<DocumentSnapshot> watchBooking(String bookingId) {
    return bookingsCollection.doc(bookingId).snapshots();
  }

  // Batch operations
  static Future<void> batchUpdateBookings(List<Map<String, dynamic>> updates) async {
    try {
      WriteBatch batch = _firestore.batch();
      
      for (Map<String, dynamic> update in updates) {
        String bookingId = update['bookingId'];
        Map<String, dynamic> data = Map<String, dynamic>.from(update);
        data.remove('bookingId');
        data['updatedAt'] = FieldValue.serverTimestamp();
        
        batch.update(bookingsCollection.doc(bookingId), data);
      }
      
      await batch.commit();
    } catch (e) {
      throw Exception('Failed to batch update bookings: $e');
    }
  }

  // Delete operations (use with caution)
  static Future<void> deleteBooking(String bookingId) async {
    try {
      // Get booking details first
      DocumentSnapshot bookingDoc = await bookingsCollection.doc(bookingId).get();
      Map<String, dynamic> bookingData = bookingDoc.data() as Map<String, dynamic>;
      
      // Restore bee box availability
      await updateBeeBoxAvailability(
        bookingData['beeBoxId'],
        bookingData['quantity'],
        true,
      );
      
      // Delete the booking
      await bookingsCollection.doc(bookingId).delete();
    } catch (e) {
      throw Exception('Failed to delete booking: $e');
    }
  }

  static Future<void> deleteBeeBox(String beeBoxId) async {
    try {
      await beeBoxesCollection.doc(beeBoxId).delete();
    } catch (e) {
      throw Exception('Failed to delete bee box: $e');
    }
  }
} 