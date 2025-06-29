import 'package:flutter/foundation.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/services/firestore_service.dart';
import '../../../../core/models/firestore_models.dart' as firestore_models;
import '../../data/services/booking_service.dart';
import '../../domain/models/booking_model.dart' as domain_models;

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
  final List<domain_models.BookingModel> _bookings = [];
  
  // Firestore data
  List<firestore_models.BeeBoxModel> _beeBoxes = [];
  List<firestore_models.BookingModel> _firestoreBookings = [];
  bool _isLoading = false;
  String? _error;

  // Getters
  Set<int> get selectedBoxes => _selectedBoxes;
  double get totalAmount => _totalAmount;
  DateTime? get startDate => _startDate;
  DateTime? get endDate => _endDate;
  String? get crop => _crop;
  String? get location => _location;
  String? get phone => _phone;
  String? get notes => _notes;
  List<domain_models.BookingModel> get bookings => _bookings;
  List<firestore_models.BeeBoxModel> get beeBoxes => _beeBoxes;
  List<firestore_models.BookingModel> get firestoreBookings => _firestoreBookings;
  bool get isLoading => _isLoading;
  String? get error => _error;

  // Initialize Firestore listeners
  void initializeFirestoreListeners() {
    _loadBeeBoxes();
  }

  // Load bee boxes from Firestore
  void _loadBeeBoxes() {
    FirestoreService.getBeeBoxes().listen(
      (QuerySnapshot snapshot) {
        _beeBoxes = snapshot.docs
            .map((doc) => firestore_models.BeeBoxModel.fromFirestore(doc))
            .toList();
        notifyListeners();
      },
      onError: (error) {
        _error = error.toString();
        notifyListeners();
      },
    );
  }

  // Load user bookings from Firestore
  void loadUserBookings(String userId) {
    FirestoreService.getUserBookings(userId).listen(
      (QuerySnapshot snapshot) {
        _firestoreBookings = snapshot.docs
            .map((doc) => firestore_models.BookingModel.fromFirestore(doc))
            .toList();
        notifyListeners();
      },
      onError: (error) {
        _error = error.toString();
        notifyListeners();
      },
    );
  }

  // Create booking using Firestore
  Future<bool> createFirestoreBooking({
    required String userId,
    required String beeBoxId,
    required DateTime startDate,
    required DateTime endDate,
    required int quantity,
    required double totalAmount,
    String? notes,
  }) async {
    try {
      _isLoading = true;
      _error = null;
      notifyListeners();

      String bookingId = await FirestoreService.createBooking(
        userId: userId,
        beeBoxId: beeBoxId,
        startDate: startDate,
        endDate: endDate,
        quantity: quantity,
        totalAmount: totalAmount,
        notes: notes,
      );

      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _isLoading = false;
      _error = e.toString();
      notifyListeners();
      return false;
    }
  }

  // Update booking status
  Future<bool> updateBookingStatus(String bookingId, String status) async {
    try {
      _isLoading = true;
      _error = null;
      notifyListeners();

      await FirestoreService.updateBookingStatus(bookingId, status);

      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _isLoading = false;
      _error = e.toString();
      notifyListeners();
      return false;
    }
  }

  // Search bee boxes
  void searchBeeBoxes(String searchTerm) {
    if (searchTerm.isEmpty) {
      _loadBeeBoxes();
      return;
    }

    FirestoreService.searchBeeBoxes(searchTerm).listen(
      (QuerySnapshot snapshot) {
        _beeBoxes = snapshot.docs
            .map((doc) => firestore_models.BeeBoxModel.fromFirestore(doc))
            .toList();
        notifyListeners();
      },
      onError: (error) {
        _error = error.toString();
        notifyListeners();
      },
    );
  }

  // Get bookings by status
  void loadBookingsByStatus(String status) {
    FirestoreService.getBookingsByStatus(status).listen(
      (QuerySnapshot snapshot) {
        _firestoreBookings = snapshot.docs
            .map((doc) => firestore_models.BookingModel.fromFirestore(doc))
            .toList();
        notifyListeners();
      },
      onError: (error) {
        _error = error.toString();
        notifyListeners();
      },
    );
  }

  // Clear error
  void clearError() {
    _error = null;
    notifyListeners();
  }

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
  }) async {
    final booking = domain_models.BookingModel(
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
    );

    await _bookingService.createBooking(booking);
    addBooking(booking);
    clearBooking();
  }

  void addBooking(domain_models.BookingModel booking) {
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
}
