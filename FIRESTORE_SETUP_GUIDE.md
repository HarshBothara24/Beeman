# Firestore Setup and Usage Guide for BeeMan

This guide explains how to set up and use Firestore database in your BeeMan Flutter app.

## Table of Contents
1. [Prerequisites](#prerequisites)
2. [Firebase Console Setup](#firebase-console-setup)
3. [Firestore Database Structure](#firestore-database-structure)
4. [Using the Firestore Service](#using-the-firestore-service)
5. [Data Models](#data-models)
6. [Example Usage](#example-usage)
7. [Security Rules](#security-rules)
8. [Best Practices](#best-practices)

## Prerequisites

Your app already has the necessary dependencies in `pubspec.yaml`:
- `cloud_firestore: ^4.13.6`
- `firebase_core: ^2.32.0`
- `firebase_auth: ^4.16.0`

## Firebase Console Setup

1. **Enable Firestore Database:**
   - Go to [Firebase Console](https://console.firebase.google.com/)
   - Select your project (`beeman-771bb`)
   - Go to Firestore Database in the left sidebar
   - Click "Create Database"
   - Choose "Start in test mode" for development
   - Select a location (preferably close to your users)

2. **Set up Security Rules:**
   - In Firestore Database, go to the "Rules" tab
   - Update the rules with the provided security rules below

## Firestore Database Structure

The app uses the following collections:

### 1. `users` Collection
```javascript
{
  uid: "string",
  email: "string",
  name: "string",
  phone: "string?",
  address: "string?",
  userType: "customer" | "admin",
  createdAt: "timestamp",
  updatedAt: "timestamp"
}
```

### 2. `bee_boxes` Collection
```javascript
{
  name: "string",
  description: "string",
  pricePerDay: "number",
  quantity: "number",
  availableQuantity: "number",
  location: "string",
  imageUrl: "string?",
  isAvailable: "boolean",
  createdAt: "timestamp",
  updatedAt: "timestamp"
}
```

### 3. `bookings` Collection
```javascript
{
  userId: "string",
  beeBoxId: "string",
  startDate: "timestamp",
  endDate: "timestamp",
  quantity: "number",
  totalAmount: "number",
  notes: "string?",
  status: "pending" | "confirmed" | "completed" | "cancelled",
  createdAt: "timestamp",
  updatedAt: "timestamp"
}
```

### 4. `payments` Collection
```javascript
{
  bookingId: "string",
  userId: "string",
  amount: "number",
  paymentMethod: "string",
  status: "pending" | "completed" | "failed" | "refunded",
  transactionId: "string?",
  createdAt: "timestamp",
  updatedAt: "timestamp"
}
```

### 5. `admins` Collection
```javascript
{
  uid: "string",
  name: "string",
  email: "string",
  role: "string",
  createdAt: "timestamp"
}
```

## Using the Firestore Service

The `FirestoreService` class provides all the necessary methods to interact with Firestore.

### Basic Usage

```dart
import 'package:your_app/core/services/firestore_service.dart';
import 'package:your_app/core/models/firestore_models.dart';

// Create a user
await FirestoreService.createUser(
  uid: 'user123',
  email: 'user@example.com',
  name: 'John Doe',
  phone: '+1234567890',
  address: '123 Main St',
);

// Get a user
final userData = await FirestoreService.getUser('user123');

// Create a bee box
await FirestoreService.createBeeBox(
  name: 'Premium Bee Box',
  description: 'High-quality bee box for pollination',
  pricePerDay: 50.0,
  quantity: 10,
  location: 'Farm Location A',
);

// Get bee boxes stream (real-time updates)
FirestoreService.getBeeBoxes().listen((snapshot) {
  final beeBoxes = snapshot.docs
      .map((doc) => BeeBoxModel.fromFirestore(doc))
      .toList();
  // Update your UI
});
```

### Real-time Listeners

```dart
// Listen to user changes
FirestoreService.watchUser('user123').listen((doc) {
  if (doc.exists) {
    final user = UserModel.fromFirestore(doc);
    // Update UI with user data
  }
});

// Listen to bee box changes
FirestoreService.watchBeeBox('beeBox123').listen((doc) {
  if (doc.exists) {
    final beeBox = BeeBoxModel.fromFirestore(doc);
    // Update UI with bee box data
  }
});
```

## Data Models

The app includes type-safe data models in `lib/core/models/firestore_models.dart`:

- `UserModel` - For user data
- `BeeBoxModel` - For bee box data
- `BookingModel` - For booking data
- `PaymentModel` - For payment data
- `AdminModel` - For admin data

### Using Models

```dart
// Convert Firestore document to model
final doc = await FirestoreService.usersCollection.doc('user123').get();
final user = UserModel.fromFirestore(doc);

// Convert model to Firestore data
final userData = user.toMap();
await FirestoreService.usersCollection.doc('user123').set(userData);
```

## Example Usage

### 1. Creating a Booking

```dart
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

Future<void> createBooking({
  required String bookingId,
  required String crop,
  required String location,
  required DateTime startDate,
  required DateTime endDate,
  required int duration,
  required int boxes,
  required double totalRent,
  required double depositAmount,
  // ...any other fields you want...
}) async {
  final user = FirebaseAuth.instance.currentUser;
  if (user == null) return;

  await FirebaseFirestore.instance.collection('bookings').add({
    'userId': user.uid,
    'bookingId': bookingId,
    'crop': crop,
    'location': location,
    'startDate': startDate,
    'endDate': endDate,
    'duration': duration,
    'boxes': boxes,
    'totalRent': totalRent,
    'depositAmount': depositAmount,
    'createdAt': FieldValue.serverTimestamp(),
    // ...add more fields as needed...
  });
}
```

### 2. Loading User Bookings

```dart
class MyBookingsScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
      stream: FirestoreService.getUserBookings('currentUserId'),
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return Text('Error: ${snapshot.error}');
        }
        
        if (snapshot.connectionState == ConnectionState.waiting) {
          return CircularProgressIndicator();
        }
        
        final bookings = snapshot.data!.docs
            .map((doc) => BookingModel.fromFirestore(doc))
            .toList();
            
        return ListView.builder(
          itemCount: bookings.length,
          itemBuilder: (context, index) {
            final booking = bookings[index];
            return ListTile(
              title: Text('Booking #${booking.id}'),
              subtitle: Text('Status: ${booking.status}'),
              trailing: Text('₹${booking.totalAmount}'),
            );
          },
        );
      },
    );
  }
}
```

### 3. Search Functionality

```dart
// Search bee boxes by name
void searchBeeBoxes(String searchTerm) {
  FirestoreService.searchBeeBoxes(searchTerm).listen((snapshot) {
    final beeBoxes = snapshot.docs
        .map((doc) => BeeBoxModel.fromFirestore(doc))
        .toList();
    // Update UI with search results
  });
}
```

## Security Rules

Add these security rules to your Firestore database:

```javascript
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    // Users can read and write their own data
    match /users/{userId} {
      allow read, write: if request.auth != null && request.auth.uid == userId;
    }
    
    // Anyone can read bee boxes
    match /bee_boxes/{beeBoxId} {
      allow read: if true;
      allow write: if request.auth != null && 
        exists(/databases/$(database)/documents/admins/$(request.auth.uid));
    }
    
    // Users can read their own bookings, admins can read all
    match /bookings/{bookingId} {
      allow read: if request.auth != null && 
        (resource.data.userId == request.auth.uid || 
         exists(/databases/$(database)/documents/admins/$(request.auth.uid)));
      allow create: if request.auth != null;
      allow update: if request.auth != null && 
        (resource.data.userId == request.auth.uid || 
         exists(/databases/$(database)/documents/admins/$(request.auth.uid)));
    }
    
    // Users can read their own payments, admins can read all
    match /payments/{paymentId} {
      allow read: if request.auth != null && 
        (resource.data.userId == request.auth.uid || 
         exists(/databases/$(database)/documents/admins/$(request.auth.uid)));
      allow create: if request.auth != null;
    }
    
    // Only admins can access admin collection
    match /admins/{adminId} {
      allow read, write: if request.auth != null && 
        exists(/databases/$(database)/documents/admins/$(request.auth.uid));
    }
  }
}
```

## Best Practices

### 1. Error Handling
Always wrap Firestore operations in try-catch blocks:

```dart
try {
  await FirestoreService.createUser(...);
} catch (e) {
  print('Error: $e');
  // Handle error appropriately
}
```

### 2. Loading States
Show loading indicators during Firestore operations:

```dart
bool _isLoading = false;

Future<void> createBooking() async {
  setState(() => _isLoading = true);
  try {
    await FirestoreService.createBooking(...);
  } catch (e) {
    // Handle error
  } finally {
    setState(() => _isLoading = false);
  }
}
```

### 3. Offline Support
Firestore automatically handles offline scenarios. Data will sync when connection is restored.

### 4. Data Validation
Validate data before sending to Firestore:

```dart
if (quantity <= 0 || quantity > maxAvailable) {
  throw Exception('Invalid quantity');
}
```

### 5. Batch Operations
Use batch operations for multiple updates:

```dart
final updates = [
  {'bookingId': 'booking1', 'status': 'confirmed'},
  {'bookingId': 'booking2', 'status': 'confirmed'},
];

await FirestoreService.batchUpdateBookings(updates);
```

## Testing

To test your Firestore integration:

1. **Use Firebase Emulator Suite** for local development
2. **Create test data** in the Firebase Console
3. **Test offline scenarios** by disabling network
4. **Verify security rules** with different user roles

## Troubleshooting

### Common Issues:

1. **Permission Denied**: Check security rules
2. **Network Error**: Verify internet connection
3. **Invalid Data**: Check data types and required fields
4. **Real-time Updates Not Working**: Ensure proper stream handling

### Debug Tips:

```dart
// Enable Firestore debug logging
FirebaseFirestore.instance.settings = Settings(
  persistenceEnabled: true,
  cacheSizeBytes: Settings.CACHE_SIZE_UNLIMITED,
);
```

This setup provides a robust foundation for using Firestore in your BeeMan app. The service layer abstracts the complexity of Firestore operations, making it easy to use throughout your app while maintaining type safety and proper error handling. 

## New Code Block

```dart
await FirebaseFirestore.instance.collection('bookings').add({
  'userId': FirebaseAuth.instance.currentUser!.uid,
  'bookingId': generatedBookingId,
  'crop': crop,
  'location': location,
  // ...other fields...
  'createdAt': FieldValue.serverTimestamp(),
});
``` 

Stream<QuerySnapshot> getAllBookingsStream() {
  return FirebaseFirestore.instance
      .collection('bookings')
      .orderBy('createdAt', descending: true)
      .snapshots();
} 
```

## Example: StreamBuilder for Admin Dashboard

```dart
StreamBuilder<QuerySnapshot>(
  stream: getAllBookingsStream(),
  builder: (context, snapshot) {
    if (!snapshot.hasData) return CircularProgressIndicator();
    final bookings = snapshot.data!.docs;
    return ListView.builder(
      itemCount: bookings.length,
      itemBuilder: (context, index) {
        final booking = bookings[index].data() as Map<String, dynamic>;
        return ListTile(
          title: Text('Booking ID: ${booking['bookingId']}'),
          subtitle: Text('User: ${booking['userId']} - Crop: ${booking['crop']}'),
          // ...display more fields as needed...
        );
      },
    );
  },
)
``` 