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
    fetchUserData();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _emailController.dispose();
    _addressController.dispose();
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

      // TODO: Implement actual profile update logic with AuthProvider
      // For now, just toggle edit mode off
      setState(() {
        _isLoading = false;
        _isEditing = false;
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(_getText('profileUpdatedSuccessfully'))),
        );
      }

      print('Before Firestore write');
      final authProvider = Provider.of<my_auth.AuthProvider>(context, listen: false);
      final user = authProvider.user;
      await FirebaseFirestore.instance.collection('users').doc(user?.uid).set({
        'displayName': _nameController.text,
        'phoneNumber': _phoneController.text,
        'email': _emailController.text,
        'address': _addressController.text,
      });
      print('After Firestore write');
    }
  }

  Future<void> fetchUserData() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      final doc = await FirebaseFirestore.instance.collection('users').doc(user.uid).get();
      setState(() {
        userData = doc.data();
        isLoading = false;
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
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Profile Image
              Center(
                child: Stack(
                  children: [
                    CircleAvatar(
                      radius: 60,
                      backgroundColor: AppTheme.primaryColor.withOpacity(0.1),
                      backgroundImage: userData!['photoURL'] != null
                          ? NetworkImage(userData!['photoURL'])
                          : null,
                      child: userData!['photoURL'] == null
                          ? const Icon(
                              Icons.person,
                              size: 60,
                              color: AppTheme.primaryColor,
                            )
                          : null,
                    ),
                    if (_isEditing)
                      Positioned(
                        bottom: 0,
                        right: 0,
                        child: Container(
                          decoration: BoxDecoration(
                            color: AppTheme.primaryColor,
                            shape: BoxShape.circle,
                          ),
                          padding: const EdgeInsets.all(8),
                          child: const Icon(
                            Icons.camera_alt,
                            color: Colors.white,
                            size: 20,
                          ),
                        ),
                      ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              
              // Personal Information Section
              Text(
                _getText('personalInformation'),
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: AppTheme.textPrimary,
                ),
              ),
              const SizedBox(height: 16),
              
              // Name Field
              TextFormField(
                controller: _nameController,
                decoration: InputDecoration(
                  labelText: _getText('name'),
                  border: const OutlineInputBorder(),
                  prefixIcon: const Icon(Icons.person),
                  enabled: _isEditing,
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return _getText('pleaseEnterYourName');
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              
              // Phone Field
              TextFormField(
                controller: _phoneController,
                decoration: InputDecoration(
                  labelText: _getText('phone'),
                  border: const OutlineInputBorder(),
                  prefixIcon: const Icon(Icons.phone),
                  enabled: _isEditing,
                ),
                keyboardType: TextInputType.phone,
                validator: (value) {
                  if (_isEditing && (value == null || value.isEmpty)) {
                    return _getText('pleaseEnterValidPhoneNumber');
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              
              // Email Field
              TextFormField(
                controller: _emailController,
                decoration: InputDecoration(
                  labelText: _getText('email'),
                  border: const OutlineInputBorder(),
                  prefixIcon: const Icon(Icons.email),
                  enabled: _isEditing,
                ),
                keyboardType: TextInputType.emailAddress,
                validator: (value) {
                  if (_isEditing && value != null && value.isNotEmpty) {
                    // Simple email validation
                    if (!value.contains('@') || !value.contains('.')) {
                      return _getText('pleaseEnterValidEmail');
                    }
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              
              // Address Field
              TextFormField(
                controller: _addressController,
                decoration: InputDecoration(
                  labelText: _getText('address'),
                  border: const OutlineInputBorder(),
                  prefixIcon: const Icon(Icons.location_on),
                  enabled: _isEditing,
                ),
                maxLines: 2,
              ),
              const SizedBox(height: 24),
              
              // Action Buttons
              if (_isEditing)
                Row(
                  children: [
                    Expanded(
                      child: CustomButton(
                        text: _getText('cancel'),
                        onPressed: _toggleEdit,
                        backgroundColor: Colors.grey[300] ?? Colors.grey,
                        textColor: Colors.black,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: CustomButton(
                        text: _getText('save'),
                        onPressed: _saveProfile,
                        isLoading: _isLoading,
                      ),
                    ),
                  ],
                ),
            ],
          ),
        ),
      ),
    );
  }
}