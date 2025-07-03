/// This file contains all the constants used throughout the app
library;

class AppConstants {
  // Private constructor to prevent instantiation
  AppConstants._();
  
  // App Info
  static const String appName = 'BeeMan';
  static const String appVersion = '1.0.0';
  static const String hostingUrl = 'https://beeman-771bb.firebaseapp.com';
  
  // API Endpoints
  static const String whatsappApiBaseUrl = 'https://api.whatsapp.com/v1/';
  static const String razorpayKeyId = 'YOUR_RAZORPAY_KEY_ID'; // Replace with actual key in production
  
  // Collection Names
  static const String usersCollection = 'users';
  static const String beeBoxesCollection = 'beeboxes';
  static const String bookingsCollection = 'bookings';
  
  // Booking Constants
  static const int depositPercentage = 60; // 60% deposit required
  static const int dailyRentPerBox = 500; // ₹500 per box per day
  
  // Error Messages
  static const String genericErrorMessage = 'Something went wrong. Please try again.';
  static const String networkErrorMessage = 'Network error. Please check your connection.';
  static const String authErrorMessage = 'Authentication failed. Please try again.';
  static const String paymentErrorMessage = 'Payment failed. Please try again.';
  
  // Success Messages
  static const String bookingSuccessMessage = 'Booking successful! You will receive a WhatsApp confirmation shortly.';
  static const String paymentSuccessMessage = 'Payment successful!';
  
  // Shared Preferences Keys
  static const String languageKey = 'language';
  static const String userIdKey = 'userId';
  static const String isLoggedInKey = 'isLoggedIn';
  static const String isAdminKey = 'isAdmin';
  
  // Languages
  static const String english = 'en';
  static const String hindi = 'hi';
  static const String marathi = 'mr';
  
  // WhatsApp Message Templates
  static const String bookingConfirmationTemplate = 
      'Thank you for booking with BeeMan! Your booking details:\n'
      'Crop: {crop}\n'
      'Start Date: {startDate}\n'
      'End Date: {endDate}\n'
      'Total Amount Paid: ₹{amount}\n'
      'Boxes: {boxes}\n\n'
      'For support, contact: +91 9876543210';
  
  // Admin Settings
  static const int maxGridRows = 10;
  static const int maxGridColumns = 10;
}