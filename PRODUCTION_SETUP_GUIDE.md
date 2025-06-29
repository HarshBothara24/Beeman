# BeeMan Production Setup Guide

## Overview
This guide will help you set up the BeeMan Flutter app for production use with Firebase Firestore integration.

## Prerequisites
- Flutter SDK (latest stable version)
- Firebase project with Firestore enabled
- Android Studio / VS Code
- Git

## 1. Firebase Setup

### 1.1 Create Firebase Project
1. Go to [Firebase Console](https://console.firebase.google.com/)
2. Create a new project named "BeeMan"
3. Enable Google Analytics (optional but recommended)

### 1.2 Enable Firestore Database
1. In Firebase Console, go to Firestore Database
2. Click "Create Database"
3. Choose "Start in production mode"
4. Select a location (preferably close to your target users)

### 1.3 Configure Firestore Security Rules
Replace the default rules with these production-ready rules:

```javascript
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    // Users can only access their own data
    match /users/{userId} {
      allow read, write: if request.auth != null && request.auth.uid == userId;
    }
    
    // Bookings - users can read/write their own, admins can read all
    match /bookings/{bookingId} {
      allow read, write: if request.auth != null && 
        (resource.data.userId == request.auth.uid || 
         request.auth.token.admin == true);
    }
    
    // Bee boxes - anyone can read, only admins can write
    match /bee_boxes/{beeBoxId} {
      allow read: if true;
      allow write: if request.auth != null && request.auth.token.admin == true;
    }
    
    // Payments - users can read their own, admins can read all
    match /payments/{paymentId} {
      allow read: if request.auth != null && 
        (resource.data.userId == request.auth.uid || 
         request.auth.token.admin == true);
      allow write: if request.auth != null && request.auth.token.admin == true;
    }
    
    // Admins collection - only admins can access
    match /admins/{adminId} {
      allow read, write: if request.auth != null && request.auth.token.admin == true;
    }
  }
}
```

### 1.4 Add Firebase to Flutter App
1. Install Firebase CLI: `npm install -g firebase-tools`
2. Login: `firebase login`
3. Initialize Firebase: `firebase init`
4. Select Firestore and Hosting
5. Download `google-services.json` for Android and `GoogleService-Info.plist` for iOS

## 2. Admin Setup

### 2.1 Set Up Admin User
1. Create a user account in your app
2. Note the user's UID from Firebase Console
3. Run the admin setup script:

```bash
cd admin
npm install
node setAdmin.js <USER_UID>
```

### 2.2 Verify Admin Access
1. Login with the admin account
2. Check if you can access the admin dashboard
3. Verify admin features are working

## 3. Initial Data Setup

### 3.1 Create Sample Bee Boxes
1. Open the app
2. Navigate to Testing → Simple Firestore Test
3. Click "Create Sample Bee Boxes"
4. Verify bee boxes appear in the listing

### 3.2 Test Booking System
1. Create a test booking
2. Verify it appears in Firestore
3. Check admin dashboard shows the booking

## 4. Production Configuration

### 4.1 Update App Configuration
1. Update `lib/core/constants/app_constants.dart` with production values
2. Set appropriate deposit percentages and pricing
3. Configure payment gateway settings

### 4.2 Environment Variables
Create a `.env` file for sensitive data:
```
FIREBASE_API_KEY=your_api_key
PAYMENT_GATEWAY_KEY=your_payment_key
```

### 4.3 Build Configuration
1. Update `android/app/build.gradle` for production signing
2. Configure iOS signing in Xcode
3. Set appropriate version numbers

## 5. Testing Checklist

### 5.1 Core Functionality
- [ ] User registration and login
- [ ] Bee box browsing and selection
- [ ] Booking creation and payment
- [ ] Admin dashboard access
- [ ] Booking management
- [ ] User management

### 5.2 Firestore Integration
- [ ] Real-time data updates
- [ ] Offline support
- [ ] Data persistence
- [ ] Security rules enforcement

### 5.3 Payment Integration
- [ ] Payment processing
- [ ] Payment history
- [ ] Receipt generation
- [ ] Refund handling

## 6. Deployment

### 6.1 Android
1. Build APK: `flutter build apk --release`
2. Test on multiple devices
3. Upload to Google Play Console

### 6.2 iOS
1. Build for iOS: `flutter build ios --release`
2. Archive in Xcode
3. Upload to App Store Connect

### 6.3 Web (Optional)
1. Build web: `flutter build web`
2. Deploy to Firebase Hosting: `firebase deploy`

## 7. Monitoring and Maintenance

### 7.1 Firebase Monitoring
1. Set up Firebase Analytics
2. Monitor Firestore usage
3. Set up alerts for errors

### 7.2 App Performance
1. Monitor app crashes
2. Track user engagement
3. Monitor booking patterns

### 7.3 Regular Maintenance
1. Update dependencies monthly
2. Review security rules quarterly
3. Backup Firestore data regularly

## 8. Troubleshooting

### 8.1 Common Issues
- **Permission Denied**: Check Firestore security rules
- **Admin Access Not Working**: Verify custom claims are set
- **Bookings Not Appearing**: Check Firestore collection structure
- **Payment Failures**: Verify payment gateway configuration

### 8.2 Debug Tools
- Use Firebase Console for data inspection
- Enable debug logging in development
- Use Flutter Inspector for UI debugging

## 9. Security Best Practices

### 9.1 Data Protection
- Never store sensitive data in client code
- Use environment variables for API keys
- Implement proper input validation

### 9.2 Access Control
- Use Firebase Auth for authentication
- Implement role-based access control
- Regular security audits

### 9.3 Data Backup
- Regular Firestore exports
- Version control for configuration
- Document all changes

## 10. Support and Documentation

### 10.1 User Documentation
- Create user guides
- FAQ section
- Video tutorials

### 10.2 Admin Documentation
- Admin dashboard guide
- Booking management procedures
- User management workflows

### 10.3 Technical Documentation
- API documentation
- Database schema
- Deployment procedures

## Contact
For technical support or questions, refer to the project documentation or contact the development team.

---

**Note**: This guide assumes you have basic knowledge of Flutter, Firebase, and mobile app development. Adjust the steps according to your specific requirements and infrastructure. 