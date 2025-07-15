import 'package:flutter/material.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/widgets/custom_button.dart';
import 'package:url_launcher/url_launcher.dart';

class SupportScreen extends StatefulWidget {
  const SupportScreen({super.key});

  @override
  State<SupportScreen> createState() => _SupportScreenState();
}

class _SupportScreenState extends State<SupportScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _subjectController = TextEditingController();
  final _messageController = TextEditingController();
  
  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _subjectController.dispose();
    _messageController.dispose();
    super.dispose();
  }

  void _submitForm() {
    if (_formKey.currentState!.validate()) {
      // Process the support request
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Support request submitted successfully!')),
      );
      
      // Clear the form
      _nameController.clear();
      _emailController.clear();
      _subjectController.clear();
      _messageController.clear();
    }
  }

  @override
  Widget build(BuildContext context) {
    // Get selected language from provider
    final selectedLanguage = ModalRoute.of(context)?.settings.arguments as String? ?? 'en';
    final info = _getSupportInfo(selectedLanguage);
    return Scaffold(
      appBar: AppBar(
        title: Text(_getSupportTitle(selectedLanguage)),
        backgroundColor: AppTheme.primaryColor,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Card(
                  elevation: 2,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  child: Padding(
                    padding: const EdgeInsets.all(20.0),
                    child: Text(
                      info,
                      style: const TextStyle(fontSize: 16, color: AppTheme.textPrimary),
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                Wrap(
                  spacing: 16,
                  runSpacing: 8,
                  children: [
                    ElevatedButton.icon(
                      icon: const Icon(Icons.map),
                      label: Text(_getMapText(selectedLanguage)),
                      onPressed: () => _launchUrl('https://maps.app.goo.gl/XNkfxn7u96jZhLK69'),
                    ),
                    ElevatedButton.icon(
                      icon: const Icon(Icons.group),
                      label: Text(_getWhatsAppText(selectedLanguage)),
                      onPressed: () => _launchUrl('https://chat.whatsapp.com/CORzhnFUmyq7klw9EOksbW'),
                      style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _launchUrl(String url) async {
    final uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }

  String _getMapText(String languageCode) {
    switch (languageCode) {
      case 'hi':
        return 'गूगल मैप्स पर देखें';
      case 'mr':
        return 'Google Maps वर पहा';
      default:
        return 'View on Google Maps';
    }
  }

  String _getWhatsAppText(String languageCode) {
    switch (languageCode) {
      case 'hi':
        return 'व्हाट्सएप ग्रुप जॉइन करें';
      case 'mr':
        return 'WhatsApp ग्रुप जॉइन करा';
      default:
        return 'Join WhatsApp Group';
    }
  }

  String _getSupportTitle(String languageCode) {
    switch (languageCode) {
      case 'hi':
        return 'सहायता';
      case 'mr':
        return 'मदत';
      default:
        return 'Support';
    }
  }

  String _getSupportInfo(String languageCode) {
    switch (languageCode) {
      case 'hi':
        return '''🐝 गोडागिरी फार्म्स, श्रीरामपुर\nबी बॉक्स परागण किराया सेवा\n📞 संपर्क: 9960553407\n\n📦 किराया योजनाएँ\n✅ तरबूज के लिए:\nकिराया: ₹2000 (15 दिन)\nजमा: ₹1500\n\n✅ अनार के लिए:\nकिराया: ₹2500 (30 दिन)\nजमा: ₹1500\n\n📌 महत्वपूर्ण निर्देश\n📍 बॉक्स पिकअप और रिटर्न किसान की जिम्मेदारी\n🕖 सुबह 7 या शाम 7 बजे कलेक्ट करें। पिकअप के बाद कॉल करें\n🚲 1 बॉक्स – हेल्पर के साथ टू-व्हीलर\n🚗 1 से अधिक बॉक्स – फोर-व्हीलर\n🔍 कलेक्ट करते समय मधुमक्खी गतिविधि जांचें\n❌ 50% मधुमक्खियाँ मृत पाई गईं तो जमा वापस नहीं\n🗓 निरीक्षण के अगले दिन जमा वापस\n⚠️ देर से लौटाने पर पेनल्टी: प्रति दिन ₹100 जमा से कटेगा\n\n🐝 मधुमक्खी सुरक्षा निर्देश\n✅ डिलीवरी पर दिए गए सभी निर्देशों का पालन करें\n❌ बॉक्स के साथ छेड़छाड़ न करें\n🐝 मधुमक्खी का डंक खतरनाक हो सकता है – चक्कर, सांस की समस्या या मृत्यू\n🧭 बॉक्स को छाया में, पूर्व की ओर, साफ जमीन पर रखें\n🧱 ईंटों पर रखें, स्टील के बाउल में साफ पानी भरें\n💧 पानी साफ और भरा रखें\n🕐 मधुमक्खियाँ 2–3 दिन में काम शुरू करेंगी\n❌ कीटनाशक या गुड़ का पानी न छिड़कें\n🐜 पानी से चींटियाँ/कीट दूर रहते हैं\n\n📍 आदर्श बॉक्स स्थान\n✅ सीमा पर रखें, फसल के अंदर नहीं\n✅ खुली, हवादार, साफ जगह\n✅ 1 एकड़ में 4 बॉक्स (सिफारिश)\n🌼 फूल आने से 5–10 दिन पहले रखें\n🌙 सूर्यास्त के बाद रात में सेट करें\n\n🔍 मधुमक्खी गतिविधि मॉनिटरिंग\n☀️ अगले दिन सुबह (8–9 बजे) मधुमक्खियाँ आ-जा रही हों\n❌ कोई गतिविधि नहीं? – तुरंत कॉल करें\n🐝 फूलों के दौरान कीटनाशक न छिड़कें\n🚨 मृत मधुमक्खियाँ दिखें? – तुरंत सूचित करें\n\n🛑 सुरक्षा टिप्स\nडंक लगे तो:\n➤ शांत रहें\n➤ डंक को नाखून से साइड से निकालें\n➤ चक्कर/सांस की दिक्कत हो तो डॉक्टर को दिखाएँ\n🚭 मधुमक्खियाँ आक्रामक हों तो हल्का धुआँ करें\n\n🎥 बॉक्स कैसे रखें देखें\n🔗 वीडियो 1\n🔗 वीडियो 2\n\n🌿 प्राकृतिक परागण को बढ़ावा दें\n80% परागण कीटों से होता है – मधुमक्खियाँ सबसे महत्वपूर्ण!''';
      case 'mr':
        return '''🐝 गोडागिरी फार्म्स, श्रीरामपूर\nबी बॉक्स परागण भाडे सेवा\n📞 संपर्क: 9960553407\n\n📦 भाडे योजना\n✅ टरबूजसाठी:\nभाडे: ₹2000 (15 दिवस)\nठेव: ₹1500\n\n✅ डाळिंबसाठी:\nभाडे: ₹2500 (30 दिवस)\nठेव: ₹1500\n\n📌 महत्वाचे निर्देश\n📍 बॉक्स पिकअप आणि रिटर्न शेतकऱ्याची जबाबदारी\n🕖 सकाळी 7 किंवा संध्याकाळी 7 वाजता घ्या. पिकअपनंतर कॉल करा\n🚲 1 बॉक्स – मदतनीसासह दुचाकी\n🚗 1 पेक्षा जास्त बॉक्स – चारचाकी\n🔍 घेताना मधमाश्यांची हालचाल तपासा\n❌ 50% मधमाश्या मृत आढळल्यास ठेव परत मिळणार नाही\n🗓 तपासणीनंतर दुसऱ्या दिवशी ठेव परत\n⚠️ उशीर झाल्यास दंड: दररोज ₹100 ठेवेतून वजा\n\n🐝 मधमाशी सुरक्षा सूचना\n✅ डिलिव्हरीवेळी दिलेल्या सर्व सूचनांचे पालन करा\n❌ बॉक्सशी छेडछाड करू नका\n🐝 मधमाशीचे दंश धोकादायक – चक्कर, श्वासोच्छ्वासाचा त्रास किंवा मृत्यू\n🧭 बॉक्स सावलीत, पूर्वेकडे, स्वच्छ जमिनीवर ठेवा\n🧱 विटांवर ठेवा, स्टीलच्या वाटीत स्वच्छ पाणी भरा\n💧 पाणी स्वच्छ आणि भरलेले ठेवा\n🕐 मधमाश्या 2–3 दिवसात काम सुरू करतील\n❌ कीटकनाशक किंवा गूळपाणी फवारू नका\n🐜 पाण्यामुळे मुंग्या/कीटक दूर राहतात\n\n📍 आदर्श बॉक्स स्थान\n✅ सीमारेषेवर ठेवा, पिकात नाही\n✅ मोकळी, हवेशीर, स्वच्छ जागा\n✅ 1 एकरात 4 बॉक्स (शिफारस)\n🌼 फुल येण्यापूर्वी 5–10 दिवस ठेवा\n🌙 सूर्यास्तानंतर रात्री सेट करा\n\n🔍 मधमाशी हालचाल मॉनिटरिंग\n☀️ दुसऱ्या दिवशी सकाळी (8–9 वाजता) मधमाश्या ये-जा करत असाव्यात\n❌ हालचाल नाही? – त्वरित कॉल करा\n🐝 फुलांच्या काळात कीटकनाशक फवारू नका\n🚨 मृत मधमाश्या आढळल्यास त्वरित कळवा\n\n🛑 सुरक्षा टिप्स\nदंश झाल्यास:\n➤ शांत राहा\n➤ नखाने बाजूने दंश काढा\n➤ चक्कर/श्वासोच्छ्वासाचा त्रास झाल्यास डॉक्टरांना दाखवा\n🚭 मधमाश्या आक्रमक झाल्यास हलका धूर करा\n\n🎥 बॉक्स कसा ठेवावा पहा\n🔗 व्हिडिओ 1\n🔗 व्हिडिओ 2\n\n🌿 नैसर्गिक परागणास मदत करा\n80% परागण कीटकांमुळे होते – मधमाश्या सर्वात महत्त्वाच्या!''';
      default:
        return '''🐝 Godagiri Farms, Shrirampur\nBee Box Pollination Rental Service\n📞 Contact: 9960553407\n\n📦 RENTAL PLANS\n✅ For Watermelon:\nRent: ₹2000 (15 Days)\nDeposit: ₹1500\n\n✅ For Pomegranate:\nRent: ₹2500 (30 Days)\nDeposit: ₹1500\n\n📌 IMPORTANT INSTRUCTIONS\n📍 Box pickup & return is the farmer’s responsibility\n🕖 Collect at 7 AM or 7 PM. Call after leaving the pickup location\n🚲 1 box – use two-wheeler with a helper\n🚗 More than 1 box – use four-wheeler\n🔍 Check bee activity while collecting\n❌ If 50% bees are dead, no deposit refund\n🗓 Deposit is refunded next day after inspection\n⚠️ LATE RETURN PENALTY\n₹100 per day will be deducted from the deposit\n(Delays affect availability for other farmers)\n\n🐝 BEE SAFETY GUIDELINES\n✅ Follow all instructions provided at delivery\n❌ Do NOT tamper with the box\n🐝 Bee stings can be dangerous. Can cause dizziness, breathing issues, or even death\n🧭 Keep box in shade, facing east, on clean ground\n🧱 Place box on bricks with steel bowls filled with clean water\n💧 Keep water bowls clean and full\n🕐 Bees may take 2–3 days to settle and start work\n❌ DO NOT spray pesticides or jaggery water\n🐜 Water bowls prevent ants & pests\n\n📍 IDEAL BOX PLACEMENT\n✅ On boundaries, not inside crop field\n✅ Ensure box is in open, ventilated, clean area\n✅ Use 4 boxes per acre (Recommended)\n🌼 Place boxes 5–10 days before flowering begins\n🌙 Set up box at night after sunset\n\n🔍 MONITORING BEE ACTIVITY\n☀️ Next day morning (8–9 AM), bees should be entering/exiting\n❌ No bee movement? – Call us immediately\n🐝 During flowering, avoid insecticide spraying\n🚨 Found dead bees near box? – Inform immediately\n\n🛑 SAFETY TIPS\nIf stung:\n➤ Move away calmly\n➤ Remove sting sideways with nail\n➤ Seek medical help if dizzy or breathless\n🚭 Use light smoke if bees swarm aggressively\n\n🎥 WATCH HOW TO PLACE THE BOX\n🔗 Video 1\n🔗 Video 2\n\n🌿 Support Natural Pollination & Increase Crop Yield\n80% of pollination is done by insects – bees are the most important!''';
    }
  }

  Widget _buildContactCard({
    required IconData icon,
    required String title,
    required String content,
  }) {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          children: [
            Icon(icon, color: AppTheme.primaryColor, size: 28),
            const SizedBox(width: 16),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: AppTheme.textPrimary,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  content,
                  style: TextStyle(
                    fontSize: 14,
                    color: AppTheme.textSecondary,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}