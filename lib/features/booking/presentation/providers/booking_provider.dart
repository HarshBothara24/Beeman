import 'package:flutter/foundation.dart';
import '../../../../core/constants/app_constants.dart';
import '../../data/services/booking_service.dart';
import '../../domain/models/booking_model.dart';
import 'dart:async';

class BookingProvider with ChangeNotifier {
  Set<int> _selectedBoxes = {};
  double _totalAmount = 0;
  DateTime? _startDate;
  DateTime? _endDate;
  String? _crop;
  String? _location;
  String? _phone;
  String? _notes;

  final BookingService _bookingService = BookingService();

  // Store bookings in memory
  final List<BookingModel> _bookings = [];
  
  // Stream subscription for bookings
  StreamSubscription<List<BookingModel>>? _bookingsSubscription;

  // Getters
  Set<int> get selectedBoxes => _selectedBoxes;
  double get totalAmount => _totalAmount;
  DateTime? get startDate => _startDate;
  DateTime? get endDate => _endDate;
  String? get crop => _crop;
  String? get location => _location;
  String? get phone => _phone;
  String? get notes => _notes;
  List<BookingModel> get bookings => _bookings;

  void setBookingDetails(Set<int> boxes, double amount) {
    _selectedBoxes = boxes;
    _totalAmount = amount;
    notifyListeners();
  }

  void updateBookingDates(DateTime start, DateTime end) {
    _startDate = start;
    _endDate = end;
    notifyListeners();
  }

  void updateBookingInfo({
    String? crop,
    String? location,
    String? phone,
    String? notes,
  }) {
    _crop = crop;
    _location = location;
    _phone = phone;
    _notes = notes;
    notifyListeners();
  }

  Future<void> saveBooking({
    required String userId,
    required String crop,
    required String location,
    required String phone,
    required DateTime startDate,
    required DateTime endDate,
    String? notes,
    String? userName,
    List<Map<String, dynamic>>? beeBoxDetails,
  }) async {
    final booking = BookingModel(
      id: '', // Firestore will generate this
      userId: userId,
      boxNumbers: _selectedBoxes,
      crop: crop,
      location: location,
      phone: phone,
      startDate: startDate,
      endDate: endDate,
      numberOfBoxes: _selectedBoxes.length,
      notes: notes,
      totalAmount: _totalAmount,
      depositAmount: _totalAmount * AppConstants.depositPercentage / 100,
      status: 'pending',
      createdAt: DateTime.now(),
      userName: userName,
      userPhone: phone,
      boxCount: _selectedBoxes.length,
      paymentStatus: 'pending',
      beeBoxDetails: beeBoxDetails,
    );

    await _bookingService.createBooking(booking);
    addBooking(booking);
    clearBooking();
  }

  void addBooking(BookingModel booking) {
    _bookings.add(booking);
    notifyListeners();
  }

  void clearBooking() {
    _selectedBoxes = {};
    _totalAmount = 0;
    _startDate = null;
    _endDate = null;
    _crop = null;
    _location = null;
    _phone = null;
    _notes = null;
    notifyListeners();
  }

  Future<void> fetchUserBookings(String userId) async {
    // Cancel existing subscription if any
    await _bookingsSubscription?.cancel();
    
    print('BookingProvider: Fetching bookings for user: $userId');
    
    try {
      final bookingsStream = _bookingService.getUserBookings(userId);
      _bookingsSubscription = bookingsStream.listen(
        (bookingsList) {
          print('BookingProvider: Received ${bookingsList.length} bookings');
          _bookings.clear();
          _bookings.addAll(bookingsList);
          notifyListeners();
        },
        onError: (error) {
          print('BookingProvider: Error fetching bookings: $error');
          _bookings.clear();
          notifyListeners();
        },
      );
    } catch (e) {
      print('BookingProvider: Exception in fetchUserBookings: $e');
      _bookings.clear();
      notifyListeners();
    }
  }

  @override
  void dispose() {
    _bookingsSubscription?.cancel();
    super.dispose();
  }
}
