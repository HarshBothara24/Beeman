import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

// import '../../../../core/providers/auth_provider.dart';
import '../../../auth/presentation/providers/auth_provider.dart' as my_auth;
import '../../../../core/theme/app_theme.dart';
import '../../../auth/presentation/widgets/custom_button.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameController;
  late TextEditingController _phoneController;
  late TextEditingController _emailController;
  late TextEditingController _addressController;
  late TextEditingController _landSizeController;
  bool _isEditing = false;
  bool _isLoading = false;
  Map<String, dynamic>? userData;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    final authProvider = Provider.of<my_auth.AuthProvider>(context, listen: false);
    _nameController = TextEditingController(text: authProvider.user?.displayName ?? '');
    _phoneController = TextEditingController(text: authProvider.user?.phoneNumber ?? '');
    _emailController = TextEditingController(text: authProvider.user?.email ?? '');
    _addressController = TextEditingController(text: ''); // Placeholder for address
    _landSizeController = TextEditingController(text: ''); // Land Size (optional)
    fetchUserData();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _emailController.dispose();
    _addressController.dispose();
    _landSizeController.dispose();
    super.dispose();
  }

  void _toggleEdit() {
    setState(() {
      _isEditing = !_isEditing;
      if (!_isEditing) {
        // Reset controllers to original values if canceling edit
        final authProvider = Provider.of<my_auth.AuthProvider>(context, listen: false);
        _nameController.text = authProvider.user?.displayName ?? '';
        _phoneController.text = authProvider.user?.phoneNumber ?? '';
        _emailController.text = authProvider.user?.email ?? '';
      }
    });
  }

  Future<void> _saveProfile() async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isLoading = true;
      });

      // Simulate API call
      await Future.delayed(const Duration(seconds: 2));

      setState(() {
        _isLoading = false;
        _isEditing = false;
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(_getText('profileUpdatedSuccessfully'))),
        );
      }

      final authProvider = Provider.of<my_auth.AuthProvider>(context, listen: false);
      final user = authProvider.user;
      await FirebaseFirestore.instance.collection('users').doc(user?.uid).set({
        'displayName': _nameController.text,
        'phone': _phoneController.text, // Use 'phone' consistently
        'email': _emailController.text,
        'address': _addressController.text,
        'landSize': _landSizeController.text,
      });
    }
  }

  Future<void> fetchUserData() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      final doc = await FirebaseFirestore.instance.collection('users').doc(user.uid).get();
      setState(() {
        userData = doc.data();
        isLoading = false;
        _addressController.text = userData?['address'] ?? '';
        _landSizeController.text = userData?['landSize'] ?? '';
      });
    } else {
      setState(() {
        isLoading = false;
      });
    }
  }

  String _getText(String key) {
    final authProvider = Provider.of<my_auth.AuthProvider>(context, listen: false);
    final languageCode = authProvider.languageCode;
    
    final Map<String, Map<String, String>> textMap = {
      'profile': {
        'en': 'Profile',
        'hi': 'प्रोफ़ाइल',
        'mr': 'प्रोफाइल',
      },
      'personalInformation': {
        'en': 'Personal Information',
        'hi': 'व्यक्तिगत जानकारी',
        'mr': 'वैयक्तिक माहिती',
      },
      'name': {
        'en': 'Name',
        'hi': 'नाम',
        'mr': 'नाव',
      },
      'phone': {
        'en': 'Phone',
        'hi': 'फोन',
        'mr': 'फोन',
      },
      'email': {
        'en': 'Email',
        'hi': 'ईमेल',
        'mr': 'ईमेल',
      },
      'address': {
        'en': 'Address',
        'hi': 'पता',
        'mr': 'पत्ता',
      },
      'edit': {
        'en': 'Edit',
        'hi': 'संपादित करें',
        'mr': 'संपादित करा',
      },
      'save': {
        'en': 'Save',
        'hi': 'सहेजें',
        'mr': 'जतन करा',
      },
      'cancel': {
        'en': 'Cancel',
        'hi': 'रद्द करें',
        'mr': 'रद्द करा',
      },
      'profileUpdatedSuccessfully': {
        'en': 'Profile updated successfully',
        'hi': 'प्रोफ़ाइल सफलतापूर्वक अपडेट किया गया',
        'mr': 'प्रोफाइल यशस्वीरित्या अपडेट केले',
      },
      'pleaseEnterYourName': {
        'en': 'Please enter your name',
        'hi': 'कृपया अपना नाम दर्ज करें',
        'mr': 'कृपया आपले नाव प्रविष्ट करा',
      },
      'pleaseEnterValidPhoneNumber': {
        'en': 'Please enter a valid phone number',
        'hi': 'कृपया एक मान्य फोन नंबर दर्ज करें',
        'mr': 'कृपया वैध फोन नंबर प्रविष्ट करा',
      },
      'pleaseEnterValidEmail': {
        'en': 'Please enter a valid email',
        'hi': 'कृपया एक मान्य ईमेल दर्ज करें',
        'mr': 'कृपया वैध ईमेल प्रविष्ट करा',
      },
    };

    return textMap[key]?[languageCode] ?? textMap[key]?['en'] ?? key;
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const Center(child: CircularProgressIndicator());
    }
    if (userData == null) {
      return const Center(child: Text('No user data found.'));
    }
    return Scaffold(
      appBar: AppBar(
        title: Text(_getText('profile')),
        actions: [
          if (!_isEditing)
            IconButton(
              icon: const Icon(Icons.edit),
              onPressed: _toggleEdit,
              tooltip: _getText('edit'),
            ),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: _isEditing
                ? Form(
                    key: _formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Edit Profile',
                          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: AppTheme.textPrimary),
                        ),
                        const SizedBox(height: 16),
                        TextFormField(
                          controller: _nameController,
                          decoration: InputDecoration(labelText: _getText('name'), border: const OutlineInputBorder()),
                          validator: (v) => v == null || v.trim().isEmpty ? _getText('pleaseEnterYourName') : null,
                        ),
                        const SizedBox(height: 16),
                        TextFormField(
                          controller: _phoneController,
                          decoration: InputDecoration(labelText: _getText('phone'), border: const OutlineInputBorder()),
                          keyboardType: TextInputType.phone,
                          validator: (v) => v == null || v.trim().isEmpty ? _getText('pleaseEnterValidPhoneNumber') : null,
                        ),
                        const SizedBox(height: 16),
                        TextFormField(
                          controller: _emailController,
                          decoration: InputDecoration(labelText: _getText('email'), border: const OutlineInputBorder()),
                          keyboardType: TextInputType.emailAddress,
                          validator: (v) => v == null || v.trim().isEmpty ? _getText('pleaseEnterValidEmail') : null,
                        ),
                        const SizedBox(height: 16),
                        TextFormField(
                          controller: _addressController,
                          decoration: InputDecoration(labelText: _getText('address'), border: const OutlineInputBorder()),
                        ),
                        const SizedBox(height: 16),
                        TextFormField(
                          controller: _landSizeController,
                          decoration: const InputDecoration(labelText: 'Land Size (optional)', border: OutlineInputBorder()),
                        ),
                        const SizedBox(height: 24),
                        Row(
                          children: [
                            ElevatedButton(
                              onPressed: _isLoading ? null : _saveProfile,
                              child: _isLoading ? const CircularProgressIndicator() : Text(_getText('save')),
                            ),
                            const SizedBox(width: 16),
                            TextButton(
                              onPressed: _isLoading ? null : _toggleEdit,
                              child: Text(_getText('cancel')),
                            ),
                          ],
                        ),
                      ],
                    ),
                  )
                : Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'My Profile',
                        style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: AppTheme.textPrimary),
                      ),
                      const SizedBox(height: 16),
                      AnimatedContainer(
                        duration: const Duration(milliseconds: 300),
                        curve: Curves.easeInOut,
                        child: Card(
                          elevation: 2,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                          child: Padding(
                            padding: const EdgeInsets.all(20.0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    CircleAvatar(
                                      radius: 32,
                                      backgroundColor: AppTheme.primaryColor,
                                      child: const Icon(Icons.person, color: Colors.white, size: 32),
                                    ),
                                    const SizedBox(width: 20),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            userData?['displayName'] ?? 'User',
                                            style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                                          ),
                                          const SizedBox(height: 4),
                                          Text(
                                            userData?['email'] ?? '',
                                            style: const TextStyle(fontSize: 14, color: AppTheme.textSecondary),
                                          ),
                                          if (userData?['phone'] != null && userData!['phone']!.isNotEmpty) ...[
                                            const SizedBox(height: 2),
                                            Text(
                                              userData!['phone']!,
                                              style: const TextStyle(fontSize: 14, color: AppTheme.textSecondary),
                                            ),
                                          ],
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 20),
                                // Add more profile info or actions here
                              ],
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 32),
                      // Add more profile actions or settings here
                    ],
                  ),
          ),
        ),
      ),
    );
  }
}