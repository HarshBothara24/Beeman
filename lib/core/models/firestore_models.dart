import 'package:cloud_firestore/cloud_firestore.dart';

// User Model
class UserModel {
  final String uid;
  final String email;
  final String name;
  final String? phone;
  final String? address;
  final String userType;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  UserModel({
    required this.uid,
    required this.email,
    required this.name,
    this.phone,
    this.address,
    this.userType = 'customer',
    this.createdAt,
    this.updatedAt,
  });

  factory UserModel.fromFirestore(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
    return UserModel(
      uid: data['uid'] ?? '',
      email: data['email'] ?? '',
      name: data['name'] ?? '',
      phone: data['phone'],
      address: data['address'],
      userType: data['userType'] ?? 'customer',
      createdAt: (data['createdAt'] as Timestamp?)?.toDate(),
      updatedAt: (data['updatedAt'] as Timestamp?)?.toDate(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'uid': uid,
      'email': email,
      'name': name,
      'phone': phone,
      'address': address,
      'userType': userType,
      'createdAt': createdAt != null ? Timestamp.fromDate(createdAt!) : null,
      'updatedAt': updatedAt != null ? Timestamp.fromDate(updatedAt!) : null,
    };
  }

  UserModel copyWith({
    String? uid,
    String? email,
    String? name,
    String? phone,
    String? address,
    String? userType,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return UserModel(
      uid: uid ?? this.uid,
      email: email ?? this.email,
      name: name ?? this.name,
      phone: phone ?? this.phone,
      address: address ?? this.address,
      userType: userType ?? this.userType,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}

// Bee Box Model
class BeeBoxModel {
  final String id;
  final String name;
  final String description;
  final double pricePerDay;
  final int quantity;
  final int availableQuantity;
  final String location;
  final String? imageUrl;
  final bool isAvailable;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  BeeBoxModel({
    required this.id,
    required this.name,
    required this.description,
    required this.pricePerDay,
    required this.quantity,
    required this.availableQuantity,
    required this.location,
    this.imageUrl,
    required this.isAvailable,
    this.createdAt,
    this.updatedAt,
  });

  factory BeeBoxModel.fromFirestore(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
    return BeeBoxModel(
      id: doc.id,
      name: data['name'] ?? '',
      description: data['description'] ?? '',
      pricePerDay: (data['pricePerDay'] ?? 0.0).toDouble(),
      quantity: data['quantity'] ?? 0,
      availableQuantity: data['availableQuantity'] ?? 0,
      location: data['location'] ?? '',
      imageUrl: data['imageUrl'],
      isAvailable: data['isAvailable'] ?? false,
      createdAt: (data['createdAt'] as Timestamp?)?.toDate(),
      updatedAt: (data['updatedAt'] as Timestamp?)?.toDate(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'description': description,
      'pricePerDay': pricePerDay,
      'quantity': quantity,
      'availableQuantity': availableQuantity,
      'location': location,
      'imageUrl': imageUrl,
      'isAvailable': isAvailable,
      'createdAt': createdAt != null ? Timestamp.fromDate(createdAt!) : null,
      'updatedAt': updatedAt != null ? Timestamp.fromDate(updatedAt!) : null,
    };
  }

  BeeBoxModel copyWith({
    String? id,
    String? name,
    String? description,
    double? pricePerDay,
    int? quantity,
    int? availableQuantity,
    String? location,
    String? imageUrl,
    bool? isAvailable,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return BeeBoxModel(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      pricePerDay: pricePerDay ?? this.pricePerDay,
      quantity: quantity ?? this.quantity,
      availableQuantity: availableQuantity ?? this.availableQuantity,
      location: location ?? this.location,
      imageUrl: imageUrl ?? this.imageUrl,
      isAvailable: isAvailable ?? this.isAvailable,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}

// Booking Model
class BookingModel {
  final String id;
  final String userId;
  final String beeBoxId;
  final DateTime startDate;
  final DateTime endDate;
  final int quantity;
  final double totalAmount;
  final String? notes;
  final String status;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  BookingModel({
    required this.id,
    required this.userId,
    required this.beeBoxId,
    required this.startDate,
    required this.endDate,
    required this.quantity,
    required this.totalAmount,
    this.notes,
    required this.status,
    this.createdAt,
    this.updatedAt,
  });

  factory BookingModel.fromFirestore(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
    return BookingModel(
      id: doc.id,
      userId: data['userId'] ?? '',
      beeBoxId: data['beeBoxId'] ?? '',
      startDate: (data['startDate'] as Timestamp).toDate(),
      endDate: (data['endDate'] as Timestamp).toDate(),
      quantity: data['quantity'] ?? 0,
      totalAmount: (data['totalAmount'] ?? 0.0).toDouble(),
      notes: data['notes'],
      status: data['status'] ?? 'pending',
      createdAt: (data['createdAt'] as Timestamp?)?.toDate(),
      updatedAt: (data['updatedAt'] as Timestamp?)?.toDate(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'userId': userId,
      'beeBoxId': beeBoxId,
      'startDate': Timestamp.fromDate(startDate),
      'endDate': Timestamp.fromDate(endDate),
      'quantity': quantity,
      'totalAmount': totalAmount,
      'notes': notes,
      'status': status,
      'createdAt': createdAt != null ? Timestamp.fromDate(createdAt!) : null,
      'updatedAt': updatedAt != null ? Timestamp.fromDate(updatedAt!) : null,
    };
  }

  BookingModel copyWith({
    String? id,
    String? userId,
    String? beeBoxId,
    DateTime? startDate,
    DateTime? endDate,
    int? quantity,
    double? totalAmount,
    String? notes,
    String? status,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return BookingModel(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      beeBoxId: beeBoxId ?? this.beeBoxId,
      startDate: startDate ?? this.startDate,
      endDate: endDate ?? this.endDate,
      quantity: quantity ?? this.quantity,
      totalAmount: totalAmount ?? this.totalAmount,
      notes: notes ?? this.notes,
      status: status ?? this.status,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  int get numberOfDays {
    return endDate.difference(startDate).inDays + 1;
  }
}

// Payment Model
class PaymentModel {
  final String id;
  final String bookingId;
  final String userId;
  final double amount;
  final String paymentMethod;
  final String status;
  final String? transactionId;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  PaymentModel({
    required this.id,
    required this.bookingId,
    required this.userId,
    required this.amount,
    required this.paymentMethod,
    required this.status,
    this.transactionId,
    this.createdAt,
    this.updatedAt,
  });

  factory PaymentModel.fromFirestore(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
    return PaymentModel(
      id: doc.id,
      bookingId: data['bookingId'] ?? '',
      userId: data['userId'] ?? '',
      amount: (data['amount'] ?? 0.0).toDouble(),
      paymentMethod: data['paymentMethod'] ?? '',
      status: data['status'] ?? 'pending',
      transactionId: data['transactionId'],
      createdAt: (data['createdAt'] as Timestamp?)?.toDate(),
      updatedAt: (data['updatedAt'] as Timestamp?)?.toDate(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'bookingId': bookingId,
      'userId': userId,
      'amount': amount,
      'paymentMethod': paymentMethod,
      'status': status,
      'transactionId': transactionId,
      'createdAt': createdAt != null ? Timestamp.fromDate(createdAt!) : null,
      'updatedAt': updatedAt != null ? Timestamp.fromDate(updatedAt!) : null,
    };
  }

  PaymentModel copyWith({
    String? id,
    String? bookingId,
    String? userId,
    double? amount,
    String? paymentMethod,
    String? status,
    String? transactionId,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return PaymentModel(
      id: id ?? this.id,
      bookingId: bookingId ?? this.bookingId,
      userId: userId ?? this.userId,
      amount: amount ?? this.amount,
      paymentMethod: paymentMethod ?? this.paymentMethod,
      status: status ?? this.status,
      transactionId: transactionId ?? this.transactionId,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}

// Admin Model
class AdminModel {
  final String uid;
  final String name;
  final String email;
  final String role;
  final DateTime? createdAt;

  AdminModel({
    required this.uid,
    required this.name,
    required this.email,
    required this.role,
    this.createdAt,
  });

  factory AdminModel.fromFirestore(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
    return AdminModel(
      uid: data['uid'] ?? '',
      name: data['name'] ?? '',
      email: data['email'] ?? '',
      role: data['role'] ?? 'admin',
      createdAt: (data['createdAt'] as Timestamp?)?.toDate(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'uid': uid,
      'name': name,
      'email': email,
      'role': role,
      'createdAt': createdAt != null ? Timestamp.fromDate(createdAt!) : null,
    };
  }
} 