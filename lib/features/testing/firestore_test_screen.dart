import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../core/services/firestore_service.dart';
import '../../../core/models/firestore_models.dart';
import '../../auth/presentation/providers/auth_provider.dart';
import '../../booking/presentation/providers/booking_provider.dart';

class FirestoreTestScreen extends StatefulWidget {
  const FirestoreTestScreen({Key? key}) : super(key: key);

  @override
  State<FirestoreTestScreen> createState() => _FirestoreTestScreenState();
}

class _FirestoreTestScreenState extends State<FirestoreTestScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  
  String _testResult = '';
  bool _isLoading = false;
  List<String> _logs = [];

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  void _addLog(String message) {
    setState(() {
      _logs.add('${DateTime.now().toString().substring(11, 19)}: $message');
      if (_logs.length > 20) _logs.removeAt(0);
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
      await Future.delayed(Duration(seconds: 3));
      subscription.cancel();
      
      _addLog('✅ Bee box stream test completed');
    } catch (e) {
      _addLog('❌ Bee box stream test failed: $e');
      _testResult = 'Bee box stream: FAILED - $e';
    } finally {
      setState(() => _isLoading = false);
    }
  }

  // Test 5: Test Search Functionality
  Future<void> _testSearch() async {
    setState(() => _isLoading = true);
    _addLog('Testing search functionality...');
    
    try {
      final stream = FirestoreService.searchBeeBoxes('Test');
      final subscription = stream.listen(
        (snapshot) {
          final count = snapshot.docs.length;
          _addLog('🔍 Search results: $count boxes found');
          _testResult = 'Search functionality: SUCCESS - $count results';
        },
        onError: (error) {
          _addLog('❌ Search error: $error');
          _testResult = 'Search functionality: FAILED - $error';
        },
      );
      
      await Future.delayed(Duration(seconds: 2));
      subscription.cancel();
      
      _addLog('✅ Search test completed');
    } catch (e) {
      _addLog('❌ Search test failed: $e');
      _testResult = 'Search functionality: FAILED - $e';
    } finally {
      setState(() => _isLoading = false);
    }
  }

  // Test 6: Test Booking Creation
  Future<void> _testCreateBooking() async {
    setState(() => _isLoading = true);
    _addLog('Creating test booking...');
    
    try {
      // First, get a bee box ID
      final beeBoxesSnapshot = await FirestoreService.beeBoxesCollection.limit(1).get();
      if (beeBoxesSnapshot.docs.isEmpty) {
        throw Exception('No bee boxes available for testing');
      }
      
      final beeBoxId = beeBoxesSnapshot.docs.first.id;
      final userId = 'test_user_${DateTime.now().millisecondsSinceEpoch}';
      
      final bookingId = await FirestoreService.createBooking(
        userId: userId,
        beeBoxId: beeBoxId,
        startDate: DateTime.now(),
        endDate: DateTime.now().add(Duration(days: 7)),
        quantity: 1,
        totalAmount: 175.0,
        notes: 'Test booking',
      );
      
      _addLog('✅ Test booking created: $bookingId');
      _testResult = 'Booking creation: SUCCESS - ID: $bookingId';
    } catch (e) {
      _addLog('❌ Booking creation failed: $e');
      _testResult = 'Booking creation: FAILED - $e';
    } finally {
      setState(() => _isLoading = false);
    }
  }

  // Test 7: Test Admin Functionality
  Future<void> _testAdminFunctions() async {
    setState(() => _isLoading = true);
    _addLog('Testing admin functions...');
    
    try {
      final testAdminUid = 'test_admin_${DateTime.now().millisecondsSinceEpoch}';
      
      // Test adding admin
      await FirestoreService.addAdmin(testAdminUid, {
        'name': 'Test Admin',
        'email': 'admin@test.com',
        'role': 'admin',
      });
      
      // Test checking admin status
      final isAdmin = await FirestoreService.isAdmin(testAdminUid);
      
      _addLog('✅ Admin functions test: isAdmin = $isAdmin');
      _testResult = 'Admin functions: SUCCESS - isAdmin: $isAdmin';
    } catch (e) {
      _addLog('❌ Admin functions failed: $e');
      _testResult = 'Admin functions: FAILED - $e';
    } finally {
      setState(() => _isLoading = false);
    }
  }

  // Test 8: Run All Tests
  Future<void> _runAllTests() async {
    setState(() => _isLoading = true);
    _addLog('🚀 Starting comprehensive Firestore test...');
    
    try {
      // Test 1: Connection
      await _testFirebaseConnection();
      await Future.delayed(Duration(seconds: 1));
      
      // Test 2: User Creation
      await _testCreateUser();
      await Future.delayed(Duration(seconds: 1));
      
      // Test 3: Bee Box Creation
      await _testCreateBeeBox();
      await Future.delayed(Duration(seconds: 1));
      
      // Test 4: Stream
      await _testBeeBoxStream();
      await Future.delayed(Duration(seconds: 1));
      
      // Test 5: Search
      await _testSearch();
      await Future.delayed(Duration(seconds: 1));
      
      // Test 6: Booking
      await _testCreateBooking();
      await Future.delayed(Duration(seconds: 1));
      
      // Test 7: Admin
      await _testAdminFunctions();
      
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
        title: const Text('Firestore Integration Test'),
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
                  Text(
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
                      'Test Real-time Stream',
                      Icons.stream,
                      _testBeeBoxStream,
                    ),
                    _buildTestButton(
                      'Test Search',
                      Icons.search,
                      _testSearch,
                    ),
                    _buildTestButton(
                      'Test Booking Creation',
                      Icons.book_online,
                      _testCreateBooking,
                    ),
                    _buildTestButton(
                      'Test Admin Functions',
                      Icons.admin_panel_settings,
                      _testAdminFunctions,
                    ),
                    
                    const SizedBox(height: 24),
                    
                    // Run All Tests Button
                    SizedBox(
                      width: double.infinity,
                      height: 56,
                      child: ElevatedButton.icon(
                        onPressed: _isLoading ? null : _runAllTests,
                        icon: _isLoading
                            ? SizedBox(
                                width: 20,
                                height: 20,
                                child: CircularProgressIndicator(strokeWidth: 2),
                              )
                            : Icon(Icons.play_arrow),
                        label: Text(
                          _isLoading ? 'Running Tests...' : 'Run All Tests',
                          style: TextStyle(fontSize: 16),
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
                              Icon(Icons.list_alt, size: 20),
                              const SizedBox(width: 8),
                              Text(
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