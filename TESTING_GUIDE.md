# Firestore Integration Testing Guide

This guide will help you test the Firestore integration in your BeeMan app step by step.

## Prerequisites

1. **Firebase Console Setup**
   - Go to [Firebase Console](https://console.firebase.google.com/)
   - Select your project: `beeman-771bb`
   - Enable Firestore Database if not already enabled

2. **Security Rules Setup**
   - In Firestore Database → Rules, set to test mode:
   ```javascript
   rules_version = '2';
   service cloud.firestore {
     match /databases/{database}/documents {
       match /{document=**} {
         allow read, write: if true;
       }
     }
   }
   ```

## Step 1: Run the App

```bash
cd Beeman
flutter run -d chrome --web-port=8080
```

## Step 2: Access the Test Screen

1. **Navigate to the Dashboard**
   - Complete the language selection
   - Complete the login/registration process
   - You should see the main dashboard

2. **Find the Test Button**
   - Look for a red "Test Firestore" card in the dashboard
   - This button only appears in debug mode
   - Click on it to open the test screen

## Step 3: Run Individual Tests

### Test 1: Firebase Connection
- Click "Test Firebase Connection"
- **Expected Result**: ✅ SUCCESS
- **What it tests**: Basic connectivity to Firebase

### Test 2: User Creation
- Click "Test User Creation"
- **Expected Result**: ✅ SUCCESS
- **What it tests**: Creating users in Firestore

### Test 3: Bee Box Creation
- Click "Test Bee Box Creation"
- **Expected Result**: ✅ SUCCESS
- **What it tests**: Creating bee boxes in Firestore

### Test 4: Real-time Stream
- Click "Test Real-time Stream"
- **Expected Result**: ✅ SUCCESS - X boxes
- **What it tests**: Real-time data synchronization

## Step 4: Run All Tests

- Click "Run All Tests" to execute all tests in sequence
- **Expected Result**: 🎉 ALL TESTS: PASSED ✅

## Step 5: Verify in Firebase Console

1. **Check Collections Created**
   - Go to Firebase Console → Firestore Database
   - You should see these collections:
     - `users` - Contains test user data
     - `bee_boxes` - Contains test bee box data
     - `test` - Contains connection test data

2. **Verify Data**
   - Click on each collection to see the documents
   - Check that the data structure matches our models

## Step 6: Test Real-time Updates

1. **Open Firebase Console**
2. **Add a new bee box manually**
3. **Watch the app update in real-time**

## Troubleshooting

### Common Issues:

1. **"Firebase connection failed"**
   - Check internet connection
   - Verify Firebase project configuration
   - Check if Firestore is enabled

2. **"Permission denied"**
   - Update security rules to allow read/write
   - Check if you're in test mode

3. **"No bee boxes available"**
   - Run the bee box creation test first
   - Check if the collection exists

4. **Import errors**
   - Run `flutter clean && flutter pub get`
   - Check that all dependencies are installed

### Debug Information:

- **Test Logs**: Check the black console at the bottom of the test screen
- **Browser Console**: Press F12 to see detailed error messages
- **Flutter Console**: Check the terminal for compilation errors

## Expected Test Results

When all tests pass, you should see:

```
🚀 Starting Firestore tests...
✅ Firebase connection successful
✅ Test user created successfully
✅ Test bee box created successfully
📡 Bee box stream update: 1 boxes available
✅ Bee box stream test completed
🎉 All tests completed successfully!
```

## Next Steps After Testing

1. **Update Security Rules**: Replace test rules with production rules
2. **Add Real Data**: Create actual bee boxes and users
3. **Test User Flows**: Test booking creation and management
4. **Performance Testing**: Test with larger datasets

## Production Checklist

- [ ] Security rules configured
- [ ] Error handling implemented
- [ ] Data validation added
- [ ] Performance optimized
- [ ] Offline support tested
- [ ] Real-time updates working
- [ ] Admin functions tested

## Support

If you encounter issues:

1. Check the test logs for specific error messages
2. Verify Firebase configuration in `firebase_options.dart`
3. Ensure all dependencies are up to date
4. Check the Firebase Console for any service issues

## Manual Testing Commands

You can also test individual functions in the Dart console:

```dart
// Test user creation
await FirestoreService.createUser(
  uid: 'test_user_123',
  email: 'test@example.com',
  name: 'Test User',
);

// Test bee box creation
await FirestoreService.createBeeBox(
  name: 'Test Box',
  description: 'Test description',
  pricePerDay: 25.0,
  quantity: 5,
  location: 'Test Location',
);

// Test real-time stream
FirestoreService.getBeeBoxes().listen((snapshot) {
  print('Bee boxes: ${snapshot.docs.length}');
});
```

This testing guide ensures that your Firestore integration is working correctly before moving to production use. 