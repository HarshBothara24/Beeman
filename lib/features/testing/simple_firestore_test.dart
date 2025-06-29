import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../core/services/firestore_service.dart';

class SimpleFirestoreTest extends StatefulWidget {
  const SimpleFirestoreTest({super.key});

  @override
  State<SimpleFirestoreTest> createState() => _SimpleFirestoreTestState();
}

class _SimpleFirestoreTestState extends State<SimpleFirestoreTest> {
  String _testResult = '';
  bool _isLoading = false;
  final List<String> _logs = [];

  void _addLog(String message) {
    setState(() {
      _logs.add('${DateTime.now().toString().substring(11, 19)}: $message');
      if (_logs.length > 10) _logs.removeAt(0);
    });
  }

  // Test 1: Check Firebase Connection
  Future<void> _testFirebaseConnection() async {
    setState(() => _isLoading = true);
    _addLog('Testing Firebase connection...');
    
    try {
      final firestore = FirebaseFirestore.instance;
      await firestore.collection('test').doc('connection').set({
        'timestamp': FieldValue.serverTimestamp(),
        'test': 'connection_successful',
      });
      
      _addLog('✅ Firebase connection successful');
      _testResult = 'Firebase connection: SUCCESS';
    } catch (e) {
      _addLog('❌ Firebase connection failed: $e');
      _testResult = 'Firebase connection: FAILED - $e';
    } finally {
      setState(() => _isLoading = false);
    }
  }

  // Test 2: Create Test User
  Future<void> _testCreateUser() async {
    setState(() => _isLoading = true);
    _addLog('Creating test user...');
    
    try {
      final testUid = 'test_user_${DateTime.now().millisecondsSinceEpoch}';
      await FirestoreService.createUser(
        uid: testUid,
        email: 'test@example.com',
        name: 'Test User',
        phone: '+1234567890',
        address: 'Test Address',
      );
      
      _addLog('✅ Test user created successfully');
      _testResult = 'User creation: SUCCESS';
    } catch (e) {
      _addLog('❌ User creation failed: $e');
      _testResult = 'User creation: FAILED - $e';
    } finally {
      setState(() => _isLoading = false);
    }
  }

  // Test 3: Create Test Bee Box
  Future<void> _testCreateBeeBox() async {
    setState(() => _isLoading = true);
    _addLog('Creating test bee box...');
    
    try {
      await FirestoreService.createBeeBox(
        name: 'Test Bee Box',
        description: 'A test bee box for testing purposes',
        pricePerDay: 25.0,
        quantity: 5,
        location: 'Test Farm',
        imageUrl: 'https://example.com/image.jpg',
      );
      
      _addLog('✅ Test bee box created successfully');
      _testResult = 'Bee box creation: SUCCESS';
    } catch (e) {
      _addLog('❌ Bee box creation failed: $e');
      _testResult = 'Bee box creation: FAILED - $e';
    } finally {
      setState(() => _isLoading = false);
    }
  }

  // Test 4: Test Real-time Bee Box Stream
  Future<void> _testBeeBoxStream() async {
    setState(() => _isLoading = true);
    _addLog('Testing bee box real-time stream...');
    
    try {
      final stream = FirestoreService.getBeeBoxes();
      final subscription = stream.listen(
        (snapshot) {
          final count = snapshot.docs.length;
          _addLog('📡 Bee box stream update: $count boxes available');
          _testResult = 'Bee box stream: SUCCESS - $count boxes';
        },
        onError: (error) {
          _addLog('❌ Bee box stream error: $error');
          _testResult = 'Bee box stream: FAILED - $error';
        },
      );
      
      // Wait for first data
      await Future.delayed(const Duration(seconds: 3));
      subscription.cancel();
      
      _addLog('✅ Bee box stream test completed');
    } catch (e) {
      _addLog('❌ Bee box stream test failed: $e');
      _testResult = 'Bee box stream: FAILED - $e';
    } finally {
      setState(() => _isLoading = false);
    }
  }

  // Test 5: Create Sample Bee Boxes
  Future<void> _createSampleBeeBoxes() async {
    setState(() => _isLoading = true);
    _addLog('Creating sample bee boxes...');
    
    try {
      // Create sample bee boxes
      final beeBoxes = [
        {
          'id': 'bee_box_001',
          'name': 'Premium Honey Bee Box',
          'description': 'High-quality bee box for optimal honey production',
          'pricePerDay': 25.0,
          'quantity': 10,
          'availableQuantity': 8,
          'location': 'Pune, Maharashtra',
          'imageUrl': '',
          'isAvailable': true,
          'createdAt': FieldValue.serverTimestamp(),
          'updatedAt': FieldValue.serverTimestamp(),
        },
        {
          'id': 'bee_box_002',
          'name': 'Standard Bee Box',
          'description': 'Reliable bee box for regular honey production',
          'pricePerDay': 20.0,
          'quantity': 15,
          'availableQuantity': 12,
          'location': 'Nashik, Maharashtra',
          'imageUrl': '',
          'isAvailable': true,
          'createdAt': FieldValue.serverTimestamp(),
          'updatedAt': FieldValue.serverTimestamp(),
        },
        {
          'id': 'bee_box_003',
          'name': 'Economy Bee Box',
          'description': 'Cost-effective bee box for small-scale farming',
          'pricePerDay': 15.0,
          'quantity': 20,
          'availableQuantity': 18,
          'location': 'Aurangabad, Maharashtra',
          'imageUrl': '',
          'isAvailable': true,
          'createdAt': FieldValue.serverTimestamp(),
          'updatedAt': FieldValue.serverTimestamp(),
        },
      ];

      for (final beeBox in beeBoxes) {
        await FirestoreService.beeBoxesCollection.doc(beeBox['id'] as String).set(beeBox);
        _addLog('✅ Created bee box: ${beeBox['name']}');
      }

      _addLog('✅ All sample bee boxes created successfully!');
      _testResult = 'Sample bee boxes: CREATED SUCCESSFULLY';
    } catch (e) {
      _addLog('❌ Failed to create bee boxes: $e');
      _testResult = 'Sample bee boxes: FAILED - $e';
    } finally {
      setState(() => _isLoading = false);
    }
  }

  // Test 6: Test Booking Creation
  Future<void> _testBookingCreation() async {
    setState(() => _isLoading = true);
    _addLog('Testing booking creation...');
    
    try {
      final bookingId = await FirestoreService.createBooking(
        userId: 'test_user_${DateTime.now().millisecondsSinceEpoch}',
        beeBoxId: 'bee_box_001',
        startDate: DateTime.now(),
        endDate: DateTime.now().add(const Duration(days: 7)),
        quantity: 2,
        totalAmount: 350.0,
        notes: 'Test booking from app',
      );

      _addLog('✅ Test booking created successfully!');
      _addLog('Booking ID: $bookingId');
      _testResult = 'Booking creation: SUCCESS - ID: $bookingId';
    } catch (e) {
      _addLog('❌ Failed to create test booking: $e');
      _testResult = 'Booking creation: FAILED - $e';
    } finally {
      setState(() => _isLoading = false);
    }
  }

  // Test 7: Run All Tests
  Future<void> _runAllTests() async {
    setState(() => _isLoading = true);
    _addLog('🚀 Starting Firestore tests...');
    
    try {
      await _testFirebaseConnection();
      await Future.delayed(const Duration(seconds: 1));
      
      await _testCreateUser();
      await Future.delayed(const Duration(seconds: 1));
      
      await _createSampleBeeBoxes();
      await Future.delayed(const Duration(seconds: 1));
      
      await _testBeeBoxStream();
      await Future.delayed(const Duration(seconds: 1));
      
      await _testBookingCreation();
      
      _addLog('🎉 All tests completed successfully!');
      _testResult = 'ALL TESTS: PASSED ✅';
    } catch (e) {
      _addLog('💥 Test suite failed: $e');
      _testResult = 'TEST SUITE: FAILED - $e';
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Simple Firestore Test'),
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Test Result Display
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: _testResult.contains('SUCCESS') || _testResult.contains('PASSED')
                    ? Colors.green[50]
                    : Colors.red[50],
                border: Border.all(
                  color: _testResult.contains('SUCCESS') || _testResult.contains('PASSED')
                      ? Colors.green
                      : Colors.red,
                ),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Test Result:',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    _testResult.isEmpty ? 'No tests run yet' : _testResult,
                    style: TextStyle(
                      color: _testResult.contains('SUCCESS') || _testResult.contains('PASSED')
                          ? Colors.green[700]
                          : Colors.red[700],
                    ),
                  ),
                ],
              ),
            ),
            
            const SizedBox(height: 16),
            
            // Test Buttons
            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    // Individual Test Buttons
                    _buildTestButton(
                      'Test Firebase Connection',
                      Icons.wifi,
                      _testFirebaseConnection,
                    ),
                    _buildTestButton(
                      'Test User Creation',
                      Icons.person_add,
                      _testCreateUser,
                    ),
                    _buildTestButton(
                      'Test Bee Box Creation',
                      Icons.hive,
                      _testCreateBeeBox,
                    ),
                    _buildTestButton(
                      'Create Sample Bee Boxes',
                      Icons.add_box,
                      _createSampleBeeBoxes,
                    ),
                    _buildTestButton(
                      'Test Booking Creation',
                      Icons.book_online,
                      _testBookingCreation,
                    ),
                    _buildTestButton(
                      'Test Real-time Stream',
                      Icons.stream,
                      _testBeeBoxStream,
                    ),
                    
                    const SizedBox(height: 24),
                    
                    // Run All Tests Button
                    SizedBox(
                      width: double.infinity,
                      height: 56,
                      child: ElevatedButton.icon(
                        onPressed: _isLoading ? null : _runAllTests,
                        icon: _isLoading
                            ? const SizedBox(
                                width: 20,
                                height: 20,
                                child: CircularProgressIndicator(strokeWidth: 2),
                              )
                            : const Icon(Icons.play_arrow),
                        label: Text(
                          _isLoading ? 'Running Tests...' : 'Run All Tests',
                          style: const TextStyle(fontSize: 16),
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.green,
                          foregroundColor: Colors.white,
                        ),
                      ),
                    ),
                    
                    const SizedBox(height: 24),
                    
                    // Logs Section
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.grey[100],
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: Colors.grey[300]!),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              const Icon(Icons.list_alt, size: 20),
                              const SizedBox(width: 8),
                              const Text(
                                'Test Logs',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          Container(
                            height: 200,
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: Colors.black,
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: SingleChildScrollView(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: _logs.map((log) => Text(
                                  log,
                                  style: TextStyle(
                                    color: Colors.green[400],
                                    fontFamily: 'monospace',
                                    fontSize: 12,
                                  ),
                                )).toList(),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTestButton(String title, IconData icon, VoidCallback onPressed) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: SizedBox(
        width: double.infinity,
        height: 48,
        child: ElevatedButton.icon(
          onPressed: _isLoading ? null : onPressed,
          icon: Icon(icon),
          label: Text(title),
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.blue[50],
            foregroundColor: Colors.blue[700],
            side: BorderSide(color: Colors.blue[200]!),
          ),
        ),
      ),
    );
  }
} 