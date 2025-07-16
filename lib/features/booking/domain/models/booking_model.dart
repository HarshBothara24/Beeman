import 'package:cloud_firestore/cloud_firestore.dart';

class BookingModel {
  final String id;
  final String userId;
  final Set<int> boxNumbers;
  final String crop;
  final String location;
  final String phone;
  final DateTime startDate;
  final DateTime endDate;
  final int numberOfBoxes;
  final String? notes;
  final double totalAmount;
  final double depositAmount;
  final String status; // pending, active, completed, cancelled
  final DateTime createdAt;
  final String? userName;
  final String? userPhone;
  final int? boxCount;
  final String? paymentStatus;
  final List<Map<String, dynamic>>? beeBoxDetails;

  BookingModel({
    required this.id,
    required this.userId,
    required this.boxNumbers,
    required this.crop,
    required this.location,
    required this.phone,
    required this.startDate,
    required this.endDate,
    required this.numberOfBoxes,
    this.notes,
    required this.totalAmount,
    required this.depositAmount,
    required this.status,
    required this.createdAt,
    this.userName,
    this.userPhone,
    this.boxCount,
    this.paymentStatus,
    this.beeBoxDetails,
  });

  factory BookingModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return BookingModel(
      id: doc.id,
      userId: data['userId'],
      boxNumbers: Set<int>.from(data['boxNumbers'] ?? []),
      crop: data['crop'],
      location: data['location'],
      phone: data['phone'],
      startDate: (data['startDate'] as Timestamp).toDate(),
      endDate: (data['endDate'] as Timestamp).toDate(),
      numberOfBoxes: data['numberOfBoxes'] ?? 0,
      notes: data['notes'],
      totalAmount: data['totalAmount'],
      depositAmount: data['depositAmount'],
      status: data['status'],
      createdAt: (data['createdAt'] as Timestamp).toDate(),
      userName: data['userName'],
      userPhone: data['userPhone'],
      boxCount: data['boxCount'],
      paymentStatus: data['paymentStatus'],
      beeBoxDetails: (data['beeBoxDetails'] as List?)?.map((e) => Map<String, dynamic>.from(e)).toList(),
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'userId': userId,
      'boxNumbers': boxNumbers.toList(),
      'crop': crop,
      'location': location,
      'phone': phone,
      'startDate': Timestamp.fromDate(startDate),
      'endDate': Timestamp.fromDate(endDate),
      'numberOfBoxes': numberOfBoxes,
      'notes': notes,
      'totalAmount': totalAmount,
      'depositAmount': depositAmount,
      'status': status,
      'createdAt': Timestamp.fromDate(createdAt),
      'userName': userName,
      'userPhone': userPhone,
      'boxCount': boxCount,
      'paymentStatus': paymentStatus,
      'beeBoxDetails': beeBoxDetails,
    };
  }
}
