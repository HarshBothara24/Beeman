# WhatsApp API Integration Setup Guide (rpayconnect.com - TezIndia)

This guide will help you set up WhatsApp integration for the BeeMan application using rpayconnect.com's TezIndia WhatsApp API.

## Prerequisites

1. **rpayconnect.com Account**: You need an account with rpayconnect.com
2. **App Key**: Your TezIndia app key from rpayconnect.com
3. **Auth Key**: Your TezIndia authentication key from rpayconnect.com
4. **API Endpoint**: `https://rpayconnect.com/sendMessage.php`

## Setup Steps

### 1. rpayconnect.com TezIndia Setup

1. **Create an Account**:
   - Go to [rpayconnect.com](https://rpayconnect.com)
   - Sign up for a WhatsApp API account
   - Complete the verification process

2. **Get Your Credentials**:
   - Log in to your rpayconnect.com dashboard
   - Navigate to API settings or TezIndia section
   - Copy your app key and auth key
   - Note the API endpoint: `https://rpayconnect.com/sendMessage.php`

3. **API Documentation**: [https://rpayconnect.com/GetApi_docs.php](https://rpayconnect.com/GetApi_docs.php)

### 2. Update Configuration

#### Step 1: Update App Constants

Open `lib/core/constants/app_constants.dart` and update the following values:

```dart
// WhatsApp API Configuration (rpayconnect.com - TezIndia)
static const String whatsappApiUrl = 'https://rpayconnect.com/sendMessage.php';
static const String whatsappAppKey = 'YOUR_TEZINDIA_APP_KEY';
static const String whatsappAuthKey = 'YOUR_TEZINDIA_AUTH_KEY';

// Support Contact Information
static const String supportPhone = '+91 9876543210'; // Your actual support phone
static const String supportEmail = 'support@beeman.com'; // Your actual support email
```

#### Step 2: Configure via Admin Panel (Alternative)

1. Log in to the admin panel
2. Navigate to "WhatsApp Configuration"
3. Enter your TezIndia API credentials:
   - API URL: `https://rpayconnect.com/sendMessage.php`
   - App Key: Your TezIndia app key
   - Auth Key: Your TezIndia auth key
4. Test the connection
5. Save the configuration

### 3. API Parameters

The TezIndia API requires these parameters:

```json
{
  "appkey": "YOUR_APP_KEY",
  "authkey": "YOUR_AUTH_KEY", 
  "to": "+919876543210",
  "message": "Your message content here"
}
```

### 4. Message Templates

The app includes predefined message templates for:

#### Booking Confirmation
```
🐝 *BeeMan Booking Confirmation*

Hello {userName},

Your bee box booking has been confirmed!

📋 *Booking Details:*
• Crop: {crop}
• Start Date: {startDate}
• End Date: {endDate}
• Number of Boxes: {boxes}
• Total Amount Paid: ₹{amount}

📞 For support: {supportContact}

Thank you for choosing BeeMan! 🌸
```

#### Periodic Reminder
```
🐝 *BeeMan Pollination Reminder*

Hello {userName},

Your bee boxes are active for {crop} pollination.

📅 Day {dayNumber} of your booking
📋 Crop: {crop}
📦 Boxes: {boxes}

💡 *Care Tips:*
• Ensure adequate water supply
• Avoid pesticide use during pollination
• Monitor bee activity

📞 Support: {supportContact}
```

#### Harvest Alert
```
🌾 *BeeMan Harvest Alert*

Hello {userName},

Your pollination period for {crop} is ending soon.

📅 End Date: {endDate}
📋 Crop: {crop}
📦 Boxes: {boxes}

⚠️ *Important:*
• Prepare for bee box collection
• Complete any pending payments
• Contact us for extension if needed

📞 Support: {supportContact}
```

### 5. Testing the Integration

#### Test Connection
1. Go to Admin Panel → WhatsApp Configuration
2. Click "Test Connection"
3. Verify the connection is successful

#### Send Test Message
1. Enter a test phone number (with country code, e.g., +919876543210)
2. Enter a test message
3. Click "Send Test Message"
4. Check if the message is delivered

### 6. API Response Format

TezIndia API returns text responses:
- **Success**: Messages containing "success", "sent", or "delivered"
- **Error**: Error messages or failure responses

### 7. Monitoring and Logs

#### Notification History
- Go to Admin Panel → Notification History
- View all sent messages
- Filter by type (booking confirmation, reminders, etc.)
- Check success/failure status

#### Logs in Firebase
All WhatsApp messages are logged in the `notifications` collection with:
- Message type
- Success/failure status
- Error details (if any)
- Timestamp
- User and booking information

### 8. Automatic Notifications

The system automatically sends:

1. **Booking Confirmations**: When a booking is successfully created
2. **Periodic Reminders**: Every 3 days during active pollination
3. **Harvest Alerts**: 3 days before pollination period ends

### 9. Custom Messages

Admins can send custom messages:
1. Go to Booking Management
2. Click on any booking
3. Click "Send WhatsApp Message"
4. Enter custom message
5. Send to the user

### 10. Troubleshooting

#### Common Issues

1. **"API not configured" error**:
   - Check if app key and auth key are properly set
   - Verify via admin panel configuration

2. **"Connection test failed"**:
   - Verify API endpoint is correct: `https://rpayconnect.com/sendMessage.php`
   - Check if app key and auth key are valid
   - Ensure you have sufficient credits/balance

3. **"Message sending failed"**:
   - Check if phone number format is correct (should include country code)
   - Verify the phone number is registered on WhatsApp
   - Check API rate limits and account status

4. **"Invalid phone number"**:
   - Ensure phone number includes country code (+91 for India)
   - Remove any spaces or special characters
   - Format should be: +919876543210

#### Debug Information

Check the console logs for detailed error messages:
- API response status codes
- Error messages from TezIndia API
- Network connectivity issues

### 11. TezIndia Specific Features

#### Rate Limits
- Check your rpayconnect.com dashboard for rate limits
- Monitor your usage to avoid hitting limits
- Consider upgrading your plan if needed

#### Message Delivery
- TezIndia API provides delivery status
- Monitor delivery reports in your dashboard
- Check message delivery rates

#### Account Management
- Manage your credits/balance in rpayconnect.com dashboard
- Monitor API usage and costs
- Set up notifications for low balance

### 12. Security Considerations

1. **API Key Security**:
   - Never commit API keys to version control
   - Use environment variables or secure storage
   - Rotate keys regularly

2. **Phone Number Privacy**:
   - Ensure phone numbers are properly sanitized
   - Log only necessary information
   - Comply with data protection regulations

3. **Rate Limiting**:
   - Respect TezIndia API rate limits
   - Implement retry logic for failed messages
   - Monitor usage to avoid hitting limits

### 13. Production Deployment

Before going live:

1. **Switch to Production API**:
   - Verify API endpoint is correct
   - Use production app key and auth key
   - Test with real phone numbers

2. **Message Templates**:
   - Ensure templates comply with WhatsApp policies
   - Test all message types

3. **Monitoring**:
   - Set up alerts for failed messages
   - Monitor delivery rates
   - Track user engagement

4. **Backup Plan**:
   - Consider SMS fallback for critical notifications
   - Implement retry mechanisms
   - Have manual notification options

## Support

If you encounter issues:

1. Check the notification history for error details
2. Verify your TezIndia credentials
3. Test with the admin panel tools
4. Check [rpayconnect.com documentation](https://rpayconnect.com/GetApi_docs.php)
5. Contact rpayconnect.com support

## API Reference

For detailed API documentation, refer to:
- [TezIndia API Documentation](https://rpayconnect.com/GetApi_docs.php)
- [WhatsApp Business API Guidelines](https://developers.facebook.com/docs/whatsapp)
- [Message Templates](https://developers.facebook.com/docs/whatsapp/message-templates)

## Example Configuration

Here's an example of how your configuration should look:

```dart
// In lib/core/constants/app_constants.dart
static const String whatsappApiUrl = 'https://rpayconnect.com/sendMessage.php';
static const String whatsappAppKey = 'your_app_key_here';
static const String whatsappAuthKey = 'your_auth_key_here';
static const String supportPhone = '+91 9876543210';
```

## Testing Checklist

- [ ] API credentials configured (app key + auth key)
- [ ] Connection test successful
- [ ] Test message sent and delivered
- [ ] Booking confirmation working
- [ ] Periodic reminders scheduled
- [ ] Harvest alerts configured
- [ ] Admin custom messages working
- [ ] Notification history logging
- [ ] Error handling working
- [ ] Rate limiting respected

## Dependency Fix

If you encounter the intl dependency issue, run:
```bash
flutter pub add intl:^0.19.0
flutter pub get
```

This ensures compatibility with flutter_localizations. 