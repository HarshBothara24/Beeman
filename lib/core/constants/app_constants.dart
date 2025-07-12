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
  static const String razorpayKeyId = 'rzp_test_KO5xeVD1vkxq42'; // Replace with your actual Razorpay test key
  
  static const String whatsappApiUrl = 'https://rpayconnect.com/api/create-message';
  static const String whatsappAppKey = '128522ac-989f-4e26-a820-9c9a54504cfc'; // Replace with your app key
  static const String whatsappAuthKey = 'KkNAIC3mVlPrWsDgNvfo4EwFI7CP6leYpsfeVOSVp7HavKcEnm'; // Replace with your auth key
  
  // Support Contact Information
  static const String supportPhone = '+91 9876543210'; // Replace with your actual support phone
  static const String supportEmail = 'support@beeman.com'; // Replace with your actual support email
  static const String supportAddress = 'Mumbai, Maharashtra, India';
  
  // Collection Names
  static const String usersCollection = 'users';
  static const String beeBoxesCollection = 'bee_boxes';
  static const String bookingsCollection = 'bookings';
  static const String notificationsCollection = 'notifications';
  
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
      '🐝 *BeeMan Booking Confirmation*\n\n'
      'Hello {userName},\n\n'
      'Your bee box booking has been confirmed!\n\n'
      '📋 *Booking Details:*\n'
      '• Crop: {crop}\n'
      '• Start Date: {startDate}\n'
      '• End Date: {endDate}\n'
      '• Number of Boxes: {boxes}\n'
      '• Total Amount Paid: ₹{amount}\n\n'
      '📞 For support: {supportContact}\n\n'
      'Thank you for choosing BeeMan! 🌸';
  
  static const String periodicReminderTemplate = 
      '🐝 *BeeMan Pollination Reminder*\n\n'
      'Hello {userName},\n\n'
      'Your bee boxes are active for {crop} pollination.\n\n'
      '📅 Day {dayNumber} of your booking\n'
      '📋 Crop: {crop}\n'
      '📦 Boxes: {boxes}\n\n'
      '💡 *Care Tips:*\n'
      '• Ensure adequate water supply\n'
      '• Avoid pesticide use during pollination\n'
      '• Monitor bee activity\n\n'
      '📞 Support: {supportContact}';
  
  static const String harvestAlertTemplate = 
      '🌾 *BeeMan Harvest Alert*\n\n'
      'Hello {userName},\n\n'
      'Your pollination period for {crop} is ending soon.\n\n'
      '📅 End Date: {endDate}\n'
      '📋 Crop: {crop}\n'
      '📦 Boxes: {boxes}\n\n'
      '⚠️ *Important:*\n'
      '• Prepare for bee box collection\n'
      '• Complete any pending payments\n'
      '• Contact us for extension if needed\n\n'
      '📞 Support: {supportContact}';
  
  // Admin Settings
  static const int maxGridRows = 10;
  static const int maxGridColumns = 10;
}