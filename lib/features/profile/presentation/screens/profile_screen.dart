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
    // Only allow toggling out of edit mode if profile is complete
    if (_isEditing) {
      if (_nameController.text.trim().isEmpty ||
          _phoneController.text.trim().isEmpty ||
          _emailController.text.trim().isEmpty ||
          _addressController.text.trim().isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Please complete all required fields before exiting edit mode.')),
        );
        return;
      }
    }
    setState(() {
      _isEditing = !_isEditing;
      if (!_isEditing) {
        // Reset controllers to original values if canceling edit
        final authProvider = Provider.of<my_auth.AuthProvider>(context, listen: false);
        _nameController.text = authProvider.user?.displayName ?? '';
        _phoneController.text = authProvider.user?.phoneNumber ?? '';
        _emailController.text = authProvider.user?.email ?? '';
        _addressController.text = userData?['address'] ?? '';
        _landSizeController.text = userData?['landSize'] ?? '';
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

      // After saving, if profile is now complete, navigate to dashboard
      if (_nameController.text.trim().isNotEmpty &&
          _phoneController.text.trim().isNotEmpty &&
          _emailController.text.trim().isNotEmpty &&
          _addressController.text.trim().isNotEmpty) {
        if (mounted) {
          Navigator.of(context).pushReplacementNamed('/dashboard');
        }
      }
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
        // If profile is incomplete, force edit mode
        if (((userData?['displayName'] == null) || (userData?['displayName']?.toString().trim().isEmpty ?? true)) ||
            ((userData?['phone'] == null) || (userData?['phone']?.toString().trim().isEmpty ?? true)) ||
            ((userData?['address'] == null) || (userData?['address']?.toString().trim().isEmpty ?? true))) {
          _isEditing = true;
        }
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
    final isEdit = _isEditing;
    final requiredFields = [
      _nameController.text.trim(),
      _phoneController.text.trim(),
      _emailController.text.trim(),
      _addressController.text.trim(),
    ];
    final completion = (requiredFields.where((f) => f.isNotEmpty).length / requiredFields.length * 100).round();
    return Scaffold(
      appBar: AppBar(
        title: Text(_getText('profile')),
        backgroundColor: AppTheme.primaryColor,
        elevation: 0,
      ),
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(24.0),
              child: isEdit
                  ? Container(
                      constraints: const BoxConstraints(maxWidth: 600),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [
                          BoxShadow(
                            color: AppTheme.primaryColor.withOpacity(0.08),
                            blurRadius: 16,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Gradient header
                          Container(
                            decoration: BoxDecoration(
                              borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
                              gradient: LinearGradient(
                                colors: [
                                  AppTheme.primaryColor,
                                  AppTheme.primaryColor.withOpacity(0.85),
                                ],
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                              ),
                            ),
                            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
                            child: Row(
                              children: [
                                CircleAvatar(
                                  backgroundColor: Colors.white,
                                  radius: 22,
                                  child: Icon(Icons.groups_2, color: AppTheme.primaryColor, size: 28),
                                ),
                                const SizedBox(width: 16),
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      _getText('profile'),
                                      style: const TextStyle(
                                        fontSize: 22,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.white,
                                      ),
                                    ),
                                    const SizedBox(height: 2),
                                    Text(
                                      'Update your information to keep your profile current',
                                      style: TextStyle(
                                        fontSize: 14,
                                        color: Colors.white.withOpacity(0.9),
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                // Profile completion bar
                                Container(
                                  decoration: BoxDecoration(
                                    color: AppTheme.primaryColor.withOpacity(0.12),
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        'Profile Completion: $completion%',
                                        style: TextStyle(
                                          fontSize: 14,
                                          color: AppTheme.primaryColor,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                      const SizedBox(height: 6),
                                      LinearProgressIndicator(
                                        value: completion / 100,
                                        backgroundColor: Colors.grey[200],
                                        color: AppTheme.primaryColor,
                                        minHeight: 7,
                                        borderRadius: BorderRadius.circular(4),
                                      ),
                                    ],
                                  ),
                                ),
                                const SizedBox(height: 24),
                                Form(
                                  key: _formKey,
                                  child: Column(
                                    children: [
                                      Row(
                                        children: [
                                          Expanded(
                                            child: TextFormField(
                                              controller: _nameController,
                                              decoration: InputDecoration(
                                                labelText: _getText('name'),
                                                prefixIcon: const Icon(Icons.person),
                                                border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                                              ),
                                              validator: (v) => v == null || v.trim().isEmpty ? _getText('pleaseEnterYourName') : null,
                                            ),
                                          ),
                                          const SizedBox(width: 16),
                                          Expanded(
                                            child: TextFormField(
                                              controller: _phoneController,
                                              decoration: InputDecoration(
                                                labelText: _getText('phone'),
                                                prefixIcon: const Icon(Icons.phone),
                                                border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                                              ),
                                              keyboardType: TextInputType.phone,
                                              validator: (v) => v == null || v.trim().isEmpty ? _getText('pleaseEnterValidPhoneNumber') : null,
                                            ),
                                          ),
                                        ],
                                      ),
                                      const SizedBox(height: 16),
                                      TextFormField(
                                        controller: _emailController,
                                        decoration: InputDecoration(
                                          labelText: _getText('email'),
                                          prefixIcon: const Icon(Icons.email),
                                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                                        ),
                                        keyboardType: TextInputType.emailAddress,
                                        validator: (v) => v == null || v.trim().isEmpty ? _getText('pleaseEnterValidEmail') : null,
                                      ),
                                      const SizedBox(height: 16),
                                      TextFormField(
                                        controller: _addressController,
                                        decoration: InputDecoration(
                                          labelText: _getText('address'),
                                          prefixIcon: const Icon(Icons.edit_location_alt),
                                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                                        ),
                                        minLines: 2,
                                        maxLines: 3,
                                      ),
                                      const SizedBox(height: 16),
                                      TextFormField(
                                        controller: _landSizeController,
                                        decoration: InputDecoration(
                                          labelText: 'Land Size (optional)',
                                          prefixIcon: const Icon(Icons.agriculture),
                                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                                        ),
                                      ),
                                      const SizedBox(height: 28),
                                      Row(
                                        children: [
                                          ElevatedButton(
                                            onPressed: _isLoading ? null : _saveProfile,
                                            style: ElevatedButton.styleFrom(
                                              backgroundColor: AppTheme.primaryColor,
                                              foregroundColor: Colors.white,
                                              padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 14),
                                              textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                                            ),
                                            child: _isLoading ? const CircularProgressIndicator() : Text(_getText('save')),
                                          ),
                                          const SizedBox(width: 16),
                                          TextButton(
                                            onPressed: _isLoading ? null : _toggleEdit,
                                            style: TextButton.styleFrom(
                                              foregroundColor: AppTheme.primaryColor,
                                              textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                                            ),
                                            child: Text(_getText('cancel')),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    )
                  : Center(
                      child: Container(
                        constraints: const BoxConstraints(maxWidth: 500),
                        margin: const EdgeInsets.symmetric(vertical: 32),
                        padding: const EdgeInsets.symmetric(vertical: 32, horizontal: 0),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(16),
                          boxShadow: [
                            BoxShadow(
                              color: AppTheme.primaryColor.withOpacity(0.08),
                              blurRadius: 16,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: Stack(
                          children: [
                            Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 32),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  // Avatar with initials and gradient
                                  Container(
                                    margin: const EdgeInsets.only(top: 8, bottom: 16),
                                    child: CircleAvatar(
                                      radius: 44,
                                      backgroundColor: Colors.transparent,
                                      child: Container(
                                        decoration: BoxDecoration(
                                          shape: BoxShape.circle,
                                          gradient: LinearGradient(
                                            colors: [
                                              AppTheme.primaryColor,
                                              AppTheme.primaryColor.withOpacity(0.7),
                                            ],
                                            begin: Alignment.topLeft,
                                            end: Alignment.bottomRight,
                                          ),
                                        ),
                                        child: Center(
                                          child: Text(
                                            _getInitials(userData?['displayName'] ?? ''),
                                            style: const TextStyle(
                                              fontSize: 32,
                                              fontWeight: FontWeight.bold,
                                              color: Colors.white,
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                  Text(
                                    userData?['displayName'] ?? 'User',
                                    style: const TextStyle(
                                      fontSize: 24,
                                      fontWeight: FontWeight.bold,
                                      color: AppTheme.textPrimary,
                                    ),
                                  ),
                                  if ((userData?['id'] ?? '').toString().isNotEmpty) ...[
                                    const SizedBox(height: 2),
                                    Text(
                                      userData?['id'] ?? '',
                                      style: const TextStyle(
                                        fontSize: 15,
                                        color: AppTheme.textSecondary,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                  ],
                                  const SizedBox(height: 24),
                                  _profileField(
                                    icon: Icons.email,
                                    label: 'EMAIL',
                                    value: userData?['email'] ?? '',
                                  ),
                                  const Divider(height: 32),
                                  _profileField(
                                    icon: Icons.phone,
                                    label: 'PHONE',
                                    value: userData?['phone'] ?? '',
                                  ),
                                  const Divider(height: 32),
                                  _profileField(
                                    icon: Icons.location_on,
                                    label: 'LOCATION',
                                    value: userData?['address'] ?? '',
                                  ),
                                  if (userData?['landSize'] != null && userData!['landSize']!.isNotEmpty) ...[
                                    const Divider(height: 32),
                                    _profileField(
                                      icon: Icons.home,
                                      label: 'PROPERTY',
                                      value: userData!['landSize']!,
                                    ),
                                  ],
                                ],
                              ),
                            ),
                            // Edit icon in top right
                            Positioned(
                              top: 0,
                              right: 16,
                              child: IconButton(
                                icon: const Icon(Icons.edit, color: AppTheme.primaryColor),
                                tooltip: _getText('edit'),
                                onPressed: _toggleEdit,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
            ),
          ),
        ),
      ),
    );
  }
}

Widget _profileField({required IconData icon, required String label, required String value}) {
  return Row(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Icon(icon, color: AppTheme.textSecondary, size: 22),
      const SizedBox(width: 16),
      Expanded(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: const TextStyle(
                fontSize: 12,
                color: AppTheme.textSecondary,
                fontWeight: FontWeight.w600,
                letterSpacing: 1.2,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              value,
              style: const TextStyle(
                fontSize: 16,
                color: AppTheme.textPrimary,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    ],
  );
}

String _getInitials(String name) {
  final parts = name.trim().split(' ');
  if (parts.length == 1) return parts[0].isNotEmpty ? parts[0][0].toUpperCase() : '';
  if (parts.length > 1) {
    return (parts[0].isNotEmpty ? parts[0][0] : '') + (parts[1].isNotEmpty ? parts[1][0] : '');
  }
  return '';
}