import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../core/constants/app_constants.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import '../../../payment/presentation/screens/payment_screen.dart';
import '../widgets/bee_box_counter.dart';
import '../widgets/date_range_picker.dart';

class BookingScreen extends StatefulWidget {
  const BookingScreen({super.key});

  @override
  State<BookingScreen> createState() => _BookingScreenState();
}

class _BookingScreenState extends State<BookingScreen> {
  final _formKey = GlobalKey<FormState>();
  final _cropController = TextEditingController();
  final _locationController = TextEditingController();
  final _phoneController = TextEditingController();
  final _notesController = TextEditingController();

  DateTime? _startDate;
  DateTime? _endDate;
  int _numberOfBoxes = 1;

  @override
  void dispose() {
    _cropController.dispose();
    _locationController.dispose();
    _phoneController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    final selectedLanguage = authProvider.selectedLanguage;

    return Scaffold(
      appBar: AppBar(
        title: Text(_getBookingTitleText(selectedLanguage)),
        backgroundColor: AppTheme.primaryColor,
        foregroundColor: Colors.white,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Booking info card
                  Card(
                    elevation: 2,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              const Icon(
                                Icons.info,
                                color: AppTheme.primaryColor,
                              ),
                              const SizedBox(width: 8),
                              Text(
                                _getBookingInfoText(selectedLanguage),
                                style: const TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: AppTheme.textPrimary,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 16),
                          Text(
                            _getBookingDescriptionText(selectedLanguage),
                            style: const TextStyle(
                              fontSize: 14,
                              color: AppTheme.textSecondary,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                  // Booking form
                  Text(
                    _getBookingDetailsText(selectedLanguage),
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: AppTheme.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 16),
                  // Crop field
                  TextFormField(
                    controller: _cropController,
                    decoration: InputDecoration(
                      labelText: _getCropLabelText(selectedLanguage),
                      hintText: _getCropHintText(selectedLanguage),
                      border: const OutlineInputBorder(),
                      prefixIcon: const Icon(Icons.grass),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return _getRequiredFieldText(selectedLanguage);
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),
                  // Location field
                  TextFormField(
                    controller: _locationController,
                    decoration: InputDecoration(
                      labelText: _getLocationLabelText(selectedLanguage),
                      hintText: _getLocationHintText(selectedLanguage),
                      border: const OutlineInputBorder(),
                      prefixIcon: const Icon(Icons.location_on),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return _getRequiredFieldText(selectedLanguage);
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),
                  // Phone field
                  TextFormField(
                    controller: _phoneController,
                    keyboardType: TextInputType.phone,
                    decoration: InputDecoration(
                      labelText: _getPhoneLabelText(selectedLanguage),
                      hintText: _getPhoneHintText(selectedLanguage),
                      border: const OutlineInputBorder(),
                      prefixIcon: const Icon(Icons.phone),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return _getRequiredFieldText(selectedLanguage);
                      }
                      if (value.length != 10) {
                        return _getInvalidPhoneText(selectedLanguage);
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 24),
                  // Date range picker
                  Text(
                    _getSelectDatesText(selectedLanguage),
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: AppTheme.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 8),
                  DateRangePicker(
                    onDateRangeSelected: (startDate, endDate) {
                      setState(() {
                        _startDate = startDate;
                        _endDate = endDate;
                      });
                    },
                    selectedLanguage: selectedLanguage,
                  ),
                  const SizedBox(height: 24),
                  // Number of bee boxes
                  Text(
                    _getSelectBoxesText(selectedLanguage),
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: AppTheme.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 8),
                  BeeBoxCounter(
                    initialValue: _numberOfBoxes,
                    onChanged: (value) {
                      setState(() {
                        _numberOfBoxes = value;
                      });
                    },
                    selectedLanguage: selectedLanguage,
                  ),
                  const SizedBox(height: 24),
                  // Notes field
                  TextFormField(
                    controller: _notesController,
                    maxLines: 3,
                    decoration: InputDecoration(
                      labelText: _getNotesLabelText(selectedLanguage),
                      hintText: _getNotesHintText(selectedLanguage),
                      border: const OutlineInputBorder(),
                      alignLabelWithHint: true,
                    ),
                  ),
                  const SizedBox(height: 24),
                  // Booking summary
                  if (_startDate != null && _endDate != null)
                    _buildBookingSummary(selectedLanguage),
                  const SizedBox(height: 24),
                  // Book now button
                  SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: ElevatedButton(
                      onPressed: () => _validateAndProceed(selectedLanguage),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppTheme.primaryColor,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: Text(
                        _getBookNowText(selectedLanguage),
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildBookingSummary(String languageCode) {
    // Calculate number of days
    final days = _endDate!.difference(_startDate!).inDays + 1;
    
    // Calculate total rent
    final totalRent = days * _numberOfBoxes * AppConstants.dailyRentPerBox;
    
    // Calculate deposit amount (60% of total rent)
    final depositAmount = (totalRent * AppConstants.depositPercentage) ~/ 100;

    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              _getBookingSummaryText(languageCode),
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: AppTheme.textPrimary,
              ),
            ),
            const SizedBox(height: 16),
            // Booking details
            _buildSummaryRow(
              _getDurationText(languageCode),
              '$days ${_getDaysText(languageCode)}',
            ),
            const SizedBox(height: 8),
            _buildSummaryRow(
              _getBoxesText(languageCode),
              '$_numberOfBoxes',
            ),
            const SizedBox(height: 8),
            _buildSummaryRow(
              _getDailyRateText(languageCode),
              '₹${AppConstants.dailyRentPerBox} ${_getPerBoxPerDayText(languageCode)}',
            ),
            const Divider(),
            _buildSummaryRow(
              _getTotalRentText(languageCode),
              '₹$totalRent',
              isBold: true,
            ),
            const SizedBox(height: 8),
            _buildSummaryRow(
              _getDepositText(languageCode),
              '₹$depositAmount (${AppConstants.depositPercentage}%)',
              isBold: true,
              textColor: AppTheme.primaryColor,
            ),
            const SizedBox(height: 16),
            Text(
              _getDepositNoteText(languageCode),
              style: const TextStyle(
                fontSize: 12,
                color: AppTheme.textSecondary,
                fontStyle: FontStyle.italic,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSummaryRow(String label, String value, {bool isBold = false, Color? textColor}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 14,
            color: AppTheme.textSecondary,
            fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
          ),
        ),
        Text(
          value,
          style: TextStyle(
            fontSize: 14,
            color: textColor ?? AppTheme.textPrimary,
            fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
          ),
        ),
      ],
    );
  }

  void _validateAndProceed(String languageCode) {
    if (_formKey.currentState!.validate()) {
      if (_startDate == null || _endDate == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(_getSelectDatesErrorText(languageCode)),
            backgroundColor: Colors.red,
          ),
        );
        return;
      }

      // Calculate number of days
      final days = _endDate!.difference(_startDate!).inDays + 1;
      
      // Calculate total rent
      final totalRent = days * _numberOfBoxes * AppConstants.dailyRentPerBox;
      
      // Calculate deposit amount (60% of total rent)
      final depositAmount = (totalRent * AppConstants.depositPercentage) ~/ 100;

      // Navigate to payment screen
      Navigator.of(context).push(
        MaterialPageRoute(
          builder: (_) => PaymentScreen(
            bookingDetails: {
              'crop': _cropController.text,
              'location': _locationController.text,
              'phone': _phoneController.text,
              'startDate': _startDate!,
              'endDate': _endDate!,
              'numberOfBoxes': _numberOfBoxes,
              'notes': _notesController.text,
              'totalRent': totalRent,
              'depositAmount': depositAmount,
              'days': days,
            },
          ),
        ),
      );
    }
  }

  // Multilingual text getters
  String _getBookingTitleText(String languageCode) {
    switch (languageCode) {
      case AppConstants.hindi:
        return 'मधुमक्खी के बक्से बुक करें';
      case AppConstants.marathi:
        return 'मधमाशांचे बॉक्स बुक करा';
      default:
        return 'Book Bee Boxes';
    }
  }

  String _getBookingInfoText(String languageCode) {
    switch (languageCode) {
      case AppConstants.hindi:
        return 'बुकिंग जानकारी';
      case AppConstants.marathi:
        return 'बुकिंग माहिती';
      default:
        return 'Booking Information';
    }
  }

  String _getBookingDescriptionText(String languageCode) {
    switch (languageCode) {
      case AppConstants.hindi:
        return 'मधुमक्खी के बक्से किराए पर लेकर अपनी फसल की पैदावार बढ़ाएं। बुकिंग के लिए नीचे दिए गए फॉर्म को भरें।';
      case AppConstants.marathi:
        return 'मधमाशांचे बॉक्स भाड्याने घेऊन तुमच्या पिकांचे उत्पादन वाढवा. बुकिंगसाठी खालील फॉर्म भरा.';
      default:
        return 'Increase your crop yield by renting bee boxes for pollination. Fill the form below to book bee boxes for your farm.';
    }
  }

  String _getBookingDetailsText(String languageCode) {
    switch (languageCode) {
      case AppConstants.hindi:
        return 'बुकिंग विवरण';
      case AppConstants.marathi:
        return 'बुकिंग तपशील';
      default:
        return 'Booking Details';
    }
  }

  String _getCropLabelText(String languageCode) {
    switch (languageCode) {
      case AppConstants.hindi:
        return 'फसल';
      case AppConstants.marathi:
        return 'पीक';
      default:
        return 'Crop';
    }
  }

  String _getCropHintText(String languageCode) {
    switch (languageCode) {
      case AppConstants.hindi:
        return 'अपनी फसल का नाम दर्ज करें';
      case AppConstants.marathi:
        return 'तुमच्या पिकाचे नाव प्रविष्ट करा';
      default:
        return 'Enter your crop name';
    }
  }

  String _getLocationLabelText(String languageCode) {
    switch (languageCode) {
      case AppConstants.hindi:
        return 'स्थान';
      case AppConstants.marathi:
        return 'स्थान';
      default:
        return 'Location';
    }
  }

  String _getLocationHintText(String languageCode) {
    switch (languageCode) {
      case AppConstants.hindi:
        return 'अपने खेत का स्थान दर्ज करें';
      case AppConstants.marathi:
        return 'तुमच्या शेताचे स्थान प्रविष्ट करा';
      default:
        return 'Enter your farm location';
    }
  }

  String _getPhoneLabelText(String languageCode) {
    switch (languageCode) {
      case AppConstants.hindi:
        return 'फोन नंबर';
      case AppConstants.marathi:
        return 'फोन नंबर';
      default:
        return 'Phone Number';
    }
  }

  String _getPhoneHintText(String languageCode) {
    switch (languageCode) {
      case AppConstants.hindi:
        return 'अपना 10 अंकों का फोन नंबर दर्ज करें';
      case AppConstants.marathi:
        return 'तुमचा 10 अंकी फोन नंबर प्रविष्ट करा';
      default:
        return 'Enter your 10-digit phone number';
    }
  }

  String _getSelectDatesText(String languageCode) {
    switch (languageCode) {
      case AppConstants.hindi:
        return 'तारीखें चुनें';
      case AppConstants.marathi:
        return 'तारखा निवडा';
      default:
        return 'Select Dates';
    }
  }

  String _getSelectBoxesText(String languageCode) {
    switch (languageCode) {
      case AppConstants.hindi:
        return 'मधुमक्खी के बक्सों की संख्या चुनें';
      case AppConstants.marathi:
        return 'मधमाशांच्या बॉक्सची संख्या निवडा';
      default:
        return 'Select Number of Bee Boxes';
    }
  }

  String _getNotesLabelText(String languageCode) {
    switch (languageCode) {
      case AppConstants.hindi:
        return 'नोट्स (वैकल्पिक)';
      case AppConstants.marathi:
        return 'नोट्स (वैकल्पिक)';
      default:
        return 'Notes (Optional)';
    }
  }

  String _getNotesHintText(String languageCode) {
    switch (languageCode) {
      case AppConstants.hindi:
        return 'कोई अतिरिक्त जानकारी या विशेष निर्देश';
      case AppConstants.marathi:
        return 'कोणतीही अतिरिक्त माहिती किंवा विशेष सूचना';
      default:
        return 'Any additional information or special instructions';
    }
  }

  String _getBookingSummaryText(String languageCode) {
    switch (languageCode) {
      case AppConstants.hindi:
        return 'बुकिंग सारांश';
      case AppConstants.marathi:
        return 'बुकिंग सारांश';
      default:
        return 'Booking Summary';
    }
  }

  String _getDurationText(String languageCode) {
    switch (languageCode) {
      case AppConstants.hindi:
        return 'अवधि';
      case AppConstants.marathi:
        return 'कालावधी';
      default:
        return 'Duration';
    }
  }

  String _getDaysText(String languageCode) {
    switch (languageCode) {
      case AppConstants.hindi:
        return 'दिन';
      case AppConstants.marathi:
        return 'दिवस';
      default:
        return 'days';
    }
  }

  String _getBoxesText(String languageCode) {
    switch (languageCode) {
      case AppConstants.hindi:
        return 'बक्से';
      case AppConstants.marathi:
        return 'बॉक्स';
      default:
        return 'Boxes';
    }
  }

  String _getDailyRateText(String languageCode) {
    switch (languageCode) {
      case AppConstants.hindi:
        return 'दैनिक दर';
      case AppConstants.marathi:
        return 'दैनिक दर';
      default:
        return 'Daily Rate';
    }
  }

  String _getPerBoxPerDayText(String languageCode) {
    switch (languageCode) {
      case AppConstants.hindi:
        return 'प्रति बक्सा प्रति दिन';
      case AppConstants.marathi:
        return 'प्रति बॉक्स प्रति दिवस';
      default:
        return 'per box per day';
    }
  }

  String _getTotalRentText(String languageCode) {
    switch (languageCode) {
      case AppConstants.hindi:
        return 'कुल किराया';
      case AppConstants.marathi:
        return 'एकूण भाडे';
      default:
        return 'Total Rent';
    }
  }

  String _getDepositText(String languageCode) {
    switch (languageCode) {
      case AppConstants.hindi:
        return 'जमा राशि (अभी भुगतान करें)';
      case AppConstants.marathi:
        return 'ठेव रक्कम (आता भरा)';
      default:
        return 'Deposit Amount (Pay Now)';
    }
  }

  String _getDepositNoteText(String languageCode) {
    switch (languageCode) {
      case AppConstants.hindi:
        return 'नोट: अभी ${AppConstants.depositPercentage}% जमा राशि का भुगतान करें। शेष राशि का भुगतान बक्से वापस करते समय किया जाएगा।';
      case AppConstants.marathi:
        return 'टीप: आता ${AppConstants.depositPercentage}% ठेव रक्कम भरा. उर्वरित रक्कम बॉक्स परत करताना भरावी लागेल.';
      default:
        return 'Note: Pay ${AppConstants.depositPercentage}% deposit amount now. The remaining amount will be payable when returning the boxes.';
    }
  }

  String _getBookNowText(String languageCode) {
    switch (languageCode) {
      case AppConstants.hindi:
        return 'अभी बुक करें';
      case AppConstants.marathi:
        return 'आता बुक करा';
      default:
        return 'Book Now';
    }
  }

  String _getRequiredFieldText(String languageCode) {
    switch (languageCode) {
      case AppConstants.hindi:
        return 'यह फ़ील्ड आवश्यक है';
      case AppConstants.marathi:
        return 'हे फील्ड आवश्यक आहे';
      default:
        return 'This field is required';
    }
  }

  String _getInvalidPhoneText(String languageCode) {
    switch (languageCode) {
      case AppConstants.hindi:
        return 'कृपया 10 अंकों का फोन नंबर दर्ज करें';
      case AppConstants.marathi:
        return 'कृपया 10 अंकी फोन नंबर प्रविष्ट करा';
      default:
        return 'Please enter a 10-digit phone number';
    }
  }

  String _getSelectDatesErrorText(String languageCode) {
    switch (languageCode) {
      case AppConstants.hindi:
        return 'कृपया तारीखें चुनें';
      case AppConstants.marathi:
        return 'कृपया तारखा निवडा';
      default:
        return 'Please select dates';
    }
  }
}