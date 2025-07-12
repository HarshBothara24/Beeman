import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../notifications/notification_service.dart';
import '../../../../core/utils/whatsapp_messaging.dart';

class WhatsAppConfigScreen extends StatefulWidget {
  const WhatsAppConfigScreen({super.key});

  @override
  State<WhatsAppConfigScreen> createState() => _WhatsAppConfigScreenState();
}

class _WhatsAppConfigScreenState extends State<WhatsAppConfigScreen> {
  final _formKey = GlobalKey<FormState>();
  final _apiUrlController = TextEditingController();
  final _appKeyController = TextEditingController();
  final _authKeyController = TextEditingController();
  final _testPhoneController = TextEditingController();
  final _testMessageController = TextEditingController();
  
  bool _isLoading = false;
  bool _isConfigured = false;
  bool _connectionTested = false;
  bool _connectionSuccess = false;

  @override
  void initState() {
    super.initState();
    _loadConfiguration();
    _checkConfiguration();
  }

  @override
  void dispose() {
    _apiUrlController.dispose();
    _appKeyController.dispose();
    _authKeyController.dispose();
    _testPhoneController.dispose();
    _testMessageController.dispose();
    super.dispose();
  }

  Future<void> _loadConfiguration() async {
    try {
      final doc = await FirebaseFirestore.instance
          .collection('admin_config')
          .doc('whatsapp')
          .get();
      
      if (doc.exists) {
        final data = doc.data()!;
        _apiUrlController.text = data['apiUrl'] ?? '';
        _appKeyController.text = data['appKey'] ?? '';
        _authKeyController.text = data['authKey'] ?? '';
      }
    } catch (e) {
      print('Error loading WhatsApp configuration: $e');
    }
  }

  void _checkConfiguration() {
    setState(() {
      _isConfigured = WhatsAppMessaging.isConfigured();
    });
  }

  Future<void> _saveConfiguration() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      await FirebaseFirestore.instance
          .collection('admin_config')
          .doc('whatsapp')
          .set({
        'apiUrl': _apiUrlController.text.trim(),
        'appKey': _appKeyController.text.trim(),
        'authKey': _authKeyController.text.trim(),
        'updatedAt': FieldValue.serverTimestamp(),
      });

      setState(() {
        _isConfigured = true;
        _connectionTested = false;
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Configuration saved successfully!')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error saving configuration: $e')),
        );
      }
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _testConnection() async {
    setState(() => _isLoading = true);

    try {
      final success = await NotificationService.testWhatsAppConnection();
      
      setState(() {
        _connectionTested = true;
        _connectionSuccess = success;
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(success ? 'Connection test successful!' : 'Connection test failed.'),
            backgroundColor: success ? Colors.green : Colors.red,
          ),
        );
      }
    } catch (e) {
      setState(() {
        _connectionTested = true;
        _connectionSuccess = false;
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Connection test error: $e')),
        );
      }
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _sendTestMessage() async {
    if (_testPhoneController.text.isEmpty || _testMessageController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter both phone number and message.')),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      final success = await NotificationService.sendCustomMessage(
        phoneNumber: _testPhoneController.text.trim(),
        message: _testMessageController.text.trim(),
        userId: 'admin_test',
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(success ? 'Test message sent successfully!' : 'Failed to send test message.'),
            backgroundColor: success ? Colors.green : Colors.red,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error sending test message: $e')),
        );
      }
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('WhatsApp Configuration'),
        backgroundColor: AppTheme.primaryColor,
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Configuration Status
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Configuration Status',
                        style: Theme.of(context).textTheme.titleLarge,
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          Icon(
                            _isConfigured ? Icons.check_circle : Icons.error,
                            color: _isConfigured ? Colors.green : Colors.red,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            _isConfigured ? 'Configured' : 'Not Configured',
                            style: TextStyle(
                              color: _isConfigured ? Colors.green : Colors.red,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                      if (_connectionTested) ...[
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            Icon(
                              _connectionSuccess ? Icons.wifi : Icons.wifi_off,
                              color: _connectionSuccess ? Colors.green : Colors.red,
                            ),
                            const SizedBox(width: 8),
                            Text(
                              _connectionSuccess ? 'Connection OK' : 'Connection Failed',
                              style: TextStyle(
                                color: _connectionSuccess ? Colors.green : Colors.red,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 24),

              // API Configuration
              Text(
                'API Configuration',
                style: Theme.of(context).textTheme.titleLarge,
              ),
              const SizedBox(height: 16),
              
              TextFormField(
                controller: _apiUrlController,
                decoration: const InputDecoration(
                  labelText: 'TezIndia API URL',
                  hintText: 'https://rpayconnect.com/sendMessage.php',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Please enter the API URL';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),

              TextFormField(
                controller: _appKeyController,
                decoration: const InputDecoration(
                  labelText: 'App Key',
                  hintText: 'Enter your TezIndia app key',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Please enter the app key';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),

              TextFormField(
                controller: _authKeyController,
                decoration: const InputDecoration(
                  labelText: 'Auth Key',
                  hintText: 'Enter your TezIndia auth key',
                  border: OutlineInputBorder(),
                ),
                obscureText: true,
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Please enter the auth key';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 24),

              // Action Buttons
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton(
                      onPressed: _isLoading ? null : _saveConfiguration,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppTheme.primaryColor,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                      ),
                      child: _isLoading
                          ? const CircularProgressIndicator(color: Colors.white)
                          : const Text('Save Configuration'),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: _isLoading ? null : _testConnection,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blue,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                      ),
                      child: _isLoading
                          ? const CircularProgressIndicator(color: Colors.white)
                          : const Text('Test Connection'),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 32),

              // Test Message Section
              Text(
                'Test Message',
                style: Theme.of(context).textTheme.titleLarge,
              ),
              const SizedBox(height: 16),

              TextFormField(
                controller: _testPhoneController,
                decoration: const InputDecoration(
                  labelText: 'Test Phone Number',
                  hintText: '+91XXXXXXXXXX',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 16),

              TextFormField(
                controller: _testMessageController,
                decoration: const InputDecoration(
                  labelText: 'Test Message',
                  hintText: 'Enter a test message to send',
                  border: OutlineInputBorder(),
                ),
                maxLines: 3,
              ),
              const SizedBox(height: 16),

              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _sendTestMessage,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                  child: _isLoading
                      ? const CircularProgressIndicator(color: Colors.white)
                      : const Text('Send Test Message'),
                ),
              ),
              const SizedBox(height: 32),

              // Information Section
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Information',
                        style: Theme.of(context).textTheme.titleLarge,
                      ),
                      const SizedBox(height: 8),
                                             const Text(
                         '• Configure your TezIndia WhatsApp API credentials\n'
                         '• Test the connection before saving\n'
                         '• Use test messages to verify functionality\n'
                         '• All messages are logged for monitoring',
                         style: TextStyle(fontSize: 14),
                       ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
} 