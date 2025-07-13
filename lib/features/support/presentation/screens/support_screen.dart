import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../../core/constants/app_constants.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import '../widgets/support_card.dart';
import '../widgets/faq_item.dart';

class SupportScreen extends StatelessWidget {
  const SupportScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    final selectedLanguage = authProvider.selectedLanguage;

    return Scaffold(
      appBar: AppBar(
        title: Text(_getSupportTitleText(selectedLanguage)),
        backgroundColor: AppTheme.primaryColor,
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Contact us section
              Text(
                _getContactUsText(selectedLanguage),
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
              ),
              const SizedBox(height: 16),
              // Support cards
              Row(
                children: [
                  Expanded(
                    child: SupportCard(
                      icon: Icons.phone,
                      title: _getCallUsText(selectedLanguage),
                      subtitle: AppConstants.supportPhone,
                      onTap: () => _launchPhone(AppConstants.supportPhone),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: SupportCard(
                      icon: Icons.email,
                      title: _getEmailUsText(selectedLanguage),
                      subtitle: AppConstants.supportEmail,
                      onTap: () => _launchEmail(AppConstants.supportEmail),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: SupportCard(
                      icon: Icons.chat,
                      title: _getWhatsAppText(selectedLanguage),
                      subtitle: AppConstants.supportPhone,
                      onTap: () => _launchWhatsApp(AppConstants.supportPhone),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: SupportCard(
                      icon: Icons.location_on,
                      title: _getVisitUsText(selectedLanguage),
                      subtitle: _getAddressText(selectedLanguage),
                      onTap: () => _launchMaps(),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 32),
              // FAQs section
              Text(
                _getFaqsText(selectedLanguage),
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
              ),
              const SizedBox(height: 16),
              // FAQ items
              FaqItem(
                question: _getFaq1QuestionText(selectedLanguage),
                answer: _getFaq1AnswerText(selectedLanguage),
              ),
              const SizedBox(height: 8),
              FaqItem(
                question: _getFaq2QuestionText(selectedLanguage),
                answer: _getFaq2AnswerText(selectedLanguage),
              ),
              const SizedBox(height: 8),
              FaqItem(
                question: _getFaq3QuestionText(selectedLanguage),
                answer: _getFaq3AnswerText(selectedLanguage),
              ),
              const SizedBox(height: 8),
              FaqItem(
                question: _getFaq4QuestionText(selectedLanguage),
                answer: _getFaq4AnswerText(selectedLanguage),
              ),
              const SizedBox(height: 8),
              FaqItem(
                question: _getFaq5QuestionText(selectedLanguage),
                answer: _getFaq5AnswerText(selectedLanguage),
              ),
              const SizedBox(height: 32),
              // About us section
              Text(
                _getAboutUsText(selectedLanguage),
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
              ),
              const SizedBox(height: 16),
              Text(
                _getAboutUsDescriptionText(selectedLanguage),
                style: const TextStyle(
                  fontSize: 14,
                  color: Colors.grey,
                ),
              ),
              const SizedBox(height: 32),
            ],
          ),
        ),
      ),
    );
  }

  // Launch functions
  void _launchPhone(String phoneNumber) async {
    final Uri uri = Uri(scheme: 'tel', path: phoneNumber);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    }
  }

  void _launchEmail(String email) async {
    final Uri uri = Uri(
      scheme: 'mailto',
      path: email,
      queryParameters: {
        'subject': 'Support Request from BeeMan App',
      },
    );
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    }
  }

  void _launchWhatsApp(String phoneNumber) async {
    // Remove any non-numeric characters from the phone number
    final cleanPhoneNumber = phoneNumber.replaceAll(RegExp(r'\D'), '');
    final Uri uri = Uri.parse('https://wa.me/91$cleanPhoneNumber');
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }

  void _launchMaps() async {
    // Example coordinates for a location in Maharashtra
    const latitude = 19.0760;
    const longitude = 72.8777;
    final Uri uri = Uri.parse('https://www.google.com/maps/search/?api=1&query=$latitude,$longitude');
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }

  // Multilingual text getters
  String _getSupportTitleText(String languageCode) {
    switch (languageCode) {
      case AppConstants.hindi:
        return 'सहायता और समर्थन';
      case AppConstants.marathi:
        return 'मदत आणि समर्थन';
      default:
        return 'Help & Support';
    }
  }

  String _getContactUsText(String languageCode) {
    switch (languageCode) {
      case AppConstants.hindi:
        return 'हमसे संपर्क करें';
      case AppConstants.marathi:
        return 'आमच्याशी संपर्क साधा';
      default:
        return 'Contact Us';
    }
  }

  String _getCallUsText(String languageCode) {
    switch (languageCode) {
      case AppConstants.hindi:
        return 'हमें कॉल करें';
      case AppConstants.marathi:
        return 'आम्हाला कॉल करा';
      default:
        return 'Call Us';
    }
  }

  String _getEmailUsText(String languageCode) {
    switch (languageCode) {
      case AppConstants.hindi:
        return 'हमें ईमेल करें';
      case AppConstants.marathi:
        return 'आम्हाला ईमेल करा';
      default:
        return 'Email Us';
    }
  }

  String _getWhatsAppText(String languageCode) {
    switch (languageCode) {
      case AppConstants.hindi:
        return 'व्हाट्सएप पर संपर्क करें';
      case AppConstants.marathi:
        return 'व्हाट्सअॅपवर संपर्क साधा';
      default:
        return 'WhatsApp Us';
    }
  }

  String _getVisitUsText(String languageCode) {
    switch (languageCode) {
      case AppConstants.hindi:
        return 'हमसे मिलें';
      case AppConstants.marathi:
        return 'आम्हाला भेट द्या';
      default:
        return 'Visit Us';
    }
  }

  String _getAddressText(String languageCode) {
    switch (languageCode) {
      case AppConstants.hindi:
        return 'मुंबई, महाराष्ट्र';
      case AppConstants.marathi:
        return 'मुंबई, महाराष्ट्र';
      default:
        return 'Mumbai, Maharashtra';
    }
  }

  String _getFaqsText(String languageCode) {
    switch (languageCode) {
      case AppConstants.hindi:
        return 'अक्सर पूछे जाने वाले प्रश्न';
      case AppConstants.marathi:
        return 'वारंवार विचारले जाणारे प्रश्न';
      default:
        return 'Frequently Asked Questions';
    }
  }

  String _getFaq1QuestionText(String languageCode) {
    switch (languageCode) {
      case AppConstants.hindi:
        return 'मधुमक्खी के बक्से किराए पर लेने के क्या लाभ हैं?';
      case AppConstants.marathi:
        return 'मधमाशांचे बॉक्स भाड्याने घेण्याचे फायदे काय आहेत?';
      default:
        return 'What are the benefits of renting bee boxes?';
    }
  }

  String _getFaq1AnswerText(String languageCode) {
    switch (languageCode) {
      case AppConstants.hindi:
        return 'मधुमक्खी के बक्से किराए पर लेने से परागण में सुधार होता है, जिससे फसल की पैदावार 20-30% तक बढ़ सकती है। यह प्राकृतिक परागण को बढ़ावा देता है और फलों की गुणवत्ता में सुधार करता है।';
      case AppConstants.marathi:
        return 'मधमाशांचे बॉक्स भाड्याने घेतल्याने परागीभवन सुधारते, ज्यामुळे पिकांचे उत्पादन 20-30% पर्यंत वाढू शकते. हे नैसर्गिक परागीभवनास प्रोत्साहन देते आणि फळांची गुणवत्ता सुधारते.';
      default:
        return 'Renting bee boxes improves pollination, which can increase crop yield by 20-30%. It promotes natural pollination and improves fruit quality.';
    }
  }

  String _getFaq2QuestionText(String languageCode) {
    switch (languageCode) {
      case AppConstants.hindi:
        return 'मुझे कितने मधुमक्खी के बक्से किराए पर लेने चाहिए?';
      case AppConstants.marathi:
        return 'मला किती मधमाशांचे बॉक्स भाड्याने घ्यायला हवेत?';
      default:
        return 'How many bee boxes should I rent?';
    }
  }

  String _getFaq2AnswerText(String languageCode) {
    switch (languageCode) {
      case AppConstants.hindi:
        return 'आमतौर पर, प्रति एकड़ 2-3 मधुमक्खी के बक्से पर्याप्त होते हैं। हालांकि, यह फसल के प्रकार और क्षेत्र के आकार पर निर्भर करता है। हमारी टीम आपकी विशिष्ट आवश्यकताओं के आधार पर सलाह दे सकती है।';
      case AppConstants.marathi:
        return 'सामान्यतः, प्रति एकर 2-3 मधमाशांचे बॉक्स पुरेसे असतात. तथापि, हे पिकाच्या प्रकारावर आणि क्षेत्राच्या आकारावर अवलंबून असते. आमची टीम तुमच्या विशिष्ट गरजांच्या आधारे सल्ला देऊ शकते.';
      default:
        return 'Generally, 2-3 bee boxes per acre are sufficient. However, it depends on the type of crop and the size of the area. Our team can advise based on your specific requirements.';
    }
  }

  String _getFaq3QuestionText(String languageCode) {
    switch (languageCode) {
      case AppConstants.hindi:
        return 'मधुमक्खी के बक्से कितने समय के लिए किराए पर लिए जा सकते हैं?';
      case AppConstants.marathi:
        return 'मधमाशांचे बॉक्स किती काळासाठी भाड्याने घेता येतात?';
      default:
        return 'For how long can I rent bee boxes?';
    }
  }

  String _getFaq3AnswerText(String languageCode) {
    switch (languageCode) {
      case AppConstants.hindi:
        return 'न्यूनतम किराया अवधि 7 दिन है, और अधिकतम अवधि 60 दिन है। फूलों के मौसम के दौरान, हम फसल के प्रकार के आधार पर 15-30 दिनों की अवधि की सलाह देते हैं।';
      case AppConstants.marathi:
        return 'किमान भाडे कालावधी 7 दिवस आहे, आणि कमाल कालावधी 60 दिवस आहे. फुलांच्या हंगामादरम्यान, आम्ही पिकाच्या प्रकारावर आधारित 15-30 दिवसांच्या कालावधीची शिफारस करतो.';
      default:
        return 'The minimum rental period is 7 days, and the maximum period is 60 days. During the flowering season, we recommend a period of 15-30 days depending on the type of crop.';
    }
  }

  String _getFaq4QuestionText(String languageCode) {
    switch (languageCode) {
      case AppConstants.hindi:
        return 'क्या मधुमक्खियां मेरी फसलों को नुकसान पहुंचाएंगी?';
      case AppConstants.marathi:
        return 'मधमाश्या माझ्या पिकांना नुकसान करतील का?';
      default:
        return 'Will the bees damage my crops?';
    }
  }

  String _getFaq4AnswerText(String languageCode) {
    switch (languageCode) {
      case AppConstants.hindi:
        return 'नहीं, मधुमक्खियां आपकी फसलों को नुकसान नहीं पहुंचाएंगी। वास्तव में, वे परागण के माध्यम से फसलों को लाभ पहुंचाती हैं, जिससे उपज और गुणवत्ता में सुधार होता है।';
      case AppConstants.marathi:
        return 'नाही, मधमाश्या तुमच्या पिकांना नुकसान करणार नाहीत. वास्तविक, त्या परागीभवनाद्वारे पिकांना फायदा करतात, ज्यामुळे उत्पादन आणि गुणवत्ता सुधारते.';
      default:
        return 'No, bees will not damage your crops. In fact, they benefit crops through pollination, improving yield and quality.';
    }
  }

  String _getFaq5QuestionText(String languageCode) {
    switch (languageCode) {
      case AppConstants.hindi:
        return 'भुगतान प्रक्रिया क्या है?';
      case AppConstants.marathi:
        return 'पेमेंट प्रक्रिया काय आहे?';
      default:
        return 'What is the payment process?';
    }
  }

  String _getFaq5AnswerText(String languageCode) {
    switch (languageCode) {
      case AppConstants.hindi:
        return 'बुकिंग के समय, आपको कुल किराए का ${AppConstants.depositPercentage}% जमा करना होगा। शेष राशि का भुगतान बक्से वापस करते समय किया जाएगा। हम UPI, नकद और बैंक हस्तांतरण स्वीकार करते हैं।';
      case AppConstants.marathi:
        return 'बुकिंग करताना, तुम्हाला एकूण भाड्याच्या ${AppConstants.depositPercentage}% ठेव भरावी लागेल. उर्वरित रक्कम बॉक्स परत करताना देय असेल. आम्ही UPI, रोख आणि बँक हस्तांतरण स्वीकारतो.';
      default:
        return 'At the time of booking, you need to pay ${AppConstants.depositPercentage}% deposit of the total rent. The remaining amount will be payable when returning the boxes. We accept UPI, cash, and bank transfers.';
    }
  }

  String _getAboutUsText(String languageCode) {
    switch (languageCode) {
      case AppConstants.hindi:
        return 'हमारे बारे में';
      case AppConstants.marathi:
        return 'आमच्याबद्दल';
      default:
        return 'About Us';
    }
  }

  String _getAboutUsDescriptionText(String languageCode) {
    switch (languageCode) {
      case AppConstants.hindi:
        return 'BeeMan एक अभिनव सेवा है जो किसानों को मधुमक्खी के बक्से किराए पर देती है, जिससे प्राकृतिक परागण को बढ़ावा मिलता है और फसल की पैदावार में सुधार होता है। हमारी टीम अनुभवी मधुमक्खी पालकों और कृषि विशेषज्ञों से बनी है जो आपकी फसल की आवश्यकताओं को समझते हैं। हम 2018 से महाराष्ट्र के किसानों की सेवा कर रहे हैं और 500 से अधिक संतुष्ट ग्राहकों का एक मजबूत नेटवर्क बना चुके हैं।';
      case AppConstants.marathi:
        return 'BeeMan ही एक अभिनव सेवा आहे जी शेतकऱ्यांना मधमाशांचे बॉक्स भाड्याने देते, ज्यामुळे नैसर्गिक परागीभवनास प्रोत्साहन मिळते आणि पिकांचे उत्पादन सुधारते. आमची टीम अनुभवी मधमाशी पालक आणि कृषी तज्ञांनी बनलेली आहे जे तुमच्या पिकांच्या गरजा समजतात. आम्ही 2018 पासून महाराष्ट्रातील शेतकऱ्यांची सेवा करत आहोत आणि 500 हून अधिक समाधानी ग्राहकांचे एक मजबूत नेटवर्क तयार केले आहे.';
      default:
        return 'BeeMan is an innovative service that provides bee boxes on rent to farmers, promoting natural pollination and improving crop yield. Our team consists of experienced beekeepers and agricultural experts who understand your crop needs. We have been serving farmers in Maharashtra since 2018 and have built a strong network of over 500 satisfied customers.';
    }
  }
}