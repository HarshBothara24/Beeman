import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

// Update the import path for AuthProvider
import '../../../auth/presentation/providers/auth_provider.dart';
import '../../../../core/theme/app_theme.dart';

class UserManagementScreen extends StatefulWidget {
  const UserManagementScreen({super.key});

  @override
  State<UserManagementScreen> createState() => _UserManagementScreenState();
}

class _UserManagementScreenState extends State<UserManagementScreen> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';
  String _selectedFilter = 'All';

  // Mock data for users
  final List<Map<String, dynamic>> _users = [
    {
      'id': 'U001',
      'name': 'Rajesh Sharma',
      'email': 'rajesh.sharma@example.com',
      'phone': '+91 9876543210',
      'location': 'Pune, Maharashtra',
      'role': 'Farmer',
      'status': 'Active',
      'registrationDate': '2023-08-15',
      'lastActive': '2023-11-25',
      'bookingsCount': 3,
    },
    {
      'id': 'U002',
      'name': 'Priya Patel',
      'email': 'priya.patel@example.com',
      'phone': '+91 8765432109',
      'location': 'Nashik, Maharashtra',
      'role': 'Farmer',
      'status': 'Active',
      'registrationDate': '2023-09-05',
      'lastActive': '2023-11-20',
      'bookingsCount': 1,
    },
    {
      'id': 'U003',
      'name': 'Amit Kumar',
      'email': 'amit.kumar@example.com',
      'phone': '+91 7654321098',
      'location': 'Ratnagiri, Maharashtra',
      'role': 'Farmer',
      'status': 'Inactive',
      'registrationDate': '2023-07-10',
      'lastActive': '2023-10-15',
      'bookingsCount': 0,
    },
    {
      'id': 'U004',
      'name': 'Sneha Desai',
      'email': 'sneha.desai@example.com',
      'phone': '+91 6543210987',
      'location': 'Mahabaleshwar, Maharashtra',
      'role': 'Orchard Owner',
      'status': 'Active',
      'registrationDate': '2023-10-20',
      'lastActive': '2023-11-22',
      'bookingsCount': 2,
    },
    {
      'id': 'U005',
      'name': 'Vikram Singh',
      'email': 'vikram.singh@example.com',
      'phone': '+91 5432109876',
      'location': 'Kolhapur, Maharashtra',
      'role': 'Farmer',
      'status': 'Blocked',
      'registrationDate': '2023-06-30',
      'lastActive': '2023-09-10',
      'bookingsCount': 0,
    },
  ];

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  List<Map<String, dynamic>> _getFilteredUsers() {
    return _users.where((user) {
      // Filter by status
      final statusMatch = _selectedFilter == 'All' || user['status'] == _selectedFilter;
      
      // Filter by search query if present
      final searchMatch = _searchQuery.isEmpty ||
          user['id'].toLowerCase().contains(_searchQuery.toLowerCase()) ||
          user['name'].toLowerCase().contains(_searchQuery.toLowerCase()) ||
          user['email'].toLowerCase().contains(_searchQuery.toLowerCase()) ||
          user['phone'].toLowerCase().contains(_searchQuery.toLowerCase()) ||
          user['location'].toLowerCase().contains(_searchQuery.toLowerCase());
      
      return statusMatch && searchMatch;
    }).toList();
  }

  void _showUserDetails(Map<String, dynamic> user) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('${_getText('userDetails')}: ${user['name']}'),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildDetailRow(_getText('userId'), user['id']),
              _buildDetailRow(_getText('name'), user['name']),
              _buildDetailRow(_getText('email'), user['email']),
              _buildDetailRow(_getText('phone'), user['phone']),
              _buildDetailRow(_getText('location'), user['location']),
              _buildDetailRow(_getText('role'), user['role']),
              _buildDetailRow(_getText('status'), user['status']),
              _buildDetailRow(_getText('registrationDate'), user['registrationDate']),
              _buildDetailRow(_getText('lastActive'), user['lastActive']),
              _buildDetailRow(_getText('bookingsCount'), user['bookingsCount'].toString()),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(_getText('close')),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              _showChangeStatusDialog(user);
            },
            child: Text(_getText('changeStatus')),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(
              '$label:',
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
          Expanded(
            child: Text(value),
          ),
        ],
      ),
    );
  }

  void _showChangeStatusDialog(Map<String, dynamic> user) {
    String newStatus = user['status'];
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(_getText('changeUserStatus')),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            RadioListTile<String>(
              title: Text(_getText('active')),
              value: 'Active',
              groupValue: newStatus,
              onChanged: (value) {
                setState(() {
                  newStatus = value!;
                });
              },
            ),
            RadioListTile<String>(
              title: Text(_getText('inactive')),
              value: 'Inactive',
              groupValue: newStatus,
              onChanged: (value) {
                setState(() {
                  newStatus = value!;
                });
              },
            ),
            RadioListTile<String>(
              title: Text(_getText('blocked')),
              value: 'Blocked',
              groupValue: newStatus,
              onChanged: (value) {
                setState(() {
                  newStatus = value!;
                });
              },
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(_getText('cancel')),
          ),
          TextButton(
            onPressed: () {
              setState(() {
                final index = _users.indexWhere((u) => u['id'] == user['id']);
                if (index != -1) {
                  _users[index]['status'] = newStatus;
                }
              });
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text(_getText('statusUpdated'))),
              );
            },
            child: Text(_getText('update')),
          ),
        ],
      ),
    );
  }

  String _getText(String key) {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final languageCode = authProvider.languageCode;
    
    final Map<String, Map<String, String>> textMap = {
      'userManagement': {
        'en': 'User Management',
        'hi': 'उपयोगकर्ता प्रबंधन',
        'mr': 'वापरकर्ता व्यवस्थापन',
      },
      'search': {
        'en': 'Search users...',
        'hi': 'उपयोगकर्ता खोजें...',
        'mr': 'वापरकर्ते शोधा...',
      },
      'all': {
        'en': 'All',
        'hi': 'सभी',
        'mr': 'सर्व',
      },
      'active': {
        'en': 'Active',
        'hi': 'सक्रिय',
        'mr': 'सक्रिय',
      },
      'inactive': {
        'en': 'Inactive',
        'hi': 'निष्क्रिय',
        'mr': 'निष्क्रिय',
      },
      'blocked': {
        'en': 'Blocked',
        'hi': 'अवरुद्ध',
        'mr': 'अवरोधित',
      },
      'filter': {
        'en': 'Filter',
        'hi': 'फ़िल्टर',
        'mr': 'फिल्टर',
      },
      'userId': {
        'en': 'User ID',
        'hi': 'उपयोगकर्ता आईडी',
        'mr': 'वापरकर्ता आयडी',
      },
      'name': {
        'en': 'Name',
        'hi': 'नाम',
        'mr': 'नाव',
      },
      'email': {
        'en': 'Email',
        'hi': 'ईमेल',
        'mr': 'ईमेल',
      },
      'phone': {
        'en': 'Phone',
        'hi': 'फोन',
        'mr': 'फोन',
      },
      'location': {
        'en': 'Location',
        'hi': 'स्थान',
        'mr': 'स्थान',
      },
      'role': {
        'en': 'Role',
        'hi': 'भूमिका',
        'mr': 'भूमिका',
      },
      'status': {
        'en': 'Status',
        'hi': 'स्थिति',
        'mr': 'स्थिती',
      },
      'registrationDate': {
        'en': 'Registration Date',
        'hi': 'पंजीकरण तिथि',
        'mr': 'नोंदणी तारीख',
      },
      'lastActive': {
        'en': 'Last Active',
        'hi': 'अंतिम सक्रिय',
        'mr': 'शेवटचे सक्रिय',
      },
      'bookingsCount': {
        'en': 'Bookings Count',
        'hi': 'बुकिंग संख्या',
        'mr': 'बुकिंग संख्या',
      },
      'viewDetails': {
        'en': 'View Details',
        'hi': 'विवरण देखें',
        'mr': 'तपशील पहा',
      },
      'changeStatus': {
        'en': 'Change Status',
        'hi': 'स्थिति बदलें',
        'mr': 'स्थिती बदला',
      },
      'userDetails': {
        'en': 'User Details',
        'hi': 'उपयोगकर्ता विवरण',
        'mr': 'वापरकर्ता तपशील',
      },
      'close': {
        'en': 'Close',
        'hi': 'बंद करें',
        'mr': 'बंद करा',
      },
      'changeUserStatus': {
        'en': 'Change User Status',
        'hi': 'उपयोगकर्ता स्थिति बदलें',
        'mr': 'वापरकर्ता स्थिती बदला',
      },
      'cancel': {
        'en': 'Cancel',
        'hi': 'रद्द करें',
        'mr': 'रद्द करा',
      },
      'update': {
        'en': 'Update',
        'hi': 'अपडेट करें',
        'mr': 'अपडेट करा',
      },
      'statusUpdated': {
        'en': 'User status updated successfully',
        'hi': 'उपयोगकर्ता स्थिति सफलतापूर्वक अपडेट की गई',
        'mr': 'वापरकर्ता स्थिती यशस्वीरित्या अपडेट केली',
      },
      'noUsersFound': {
        'en': 'No users found',
        'hi': 'कोई उपयोगकर्ता नहीं मिला',
        'mr': 'कोणतेही वापरकर्ते आढळले नाहीत',
      },
    };

    return textMap[key]?[languageCode] ?? textMap[key]?['en'] ?? key;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_getText('userManagement')),
      ),
      body: Column(
        children: [
          // Search and filter bar
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              children: [
                // Search field
                Expanded(
                  child: TextField(
                    controller: _searchController,
                    decoration: InputDecoration(
                      hintText: _getText('search'),
                      prefixIcon: const Icon(Icons.search),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      contentPadding: const EdgeInsets.symmetric(vertical: 0),
                      suffixIcon: _searchQuery.isNotEmpty
                          ? IconButton(
                              icon: const Icon(Icons.clear),
                              onPressed: () {
                                setState(() {
                                  _searchController.clear();
                                  _searchQuery = '';
                                });
                              },
                            )
                          : null,
                    ),
                    onChanged: (value) {
                      setState(() {
                        _searchQuery = value;
                      });
                    },
                  ),
                ),
                const SizedBox(width: 16),
                // Filter dropdown
                DropdownButton<String>(
                  value: _selectedFilter,
                  hint: Text(_getText('filter')),
                  items: [
                    DropdownMenuItem(value: 'All', child: Text(_getText('all'))),
                    DropdownMenuItem(value: 'Active', child: Text(_getText('active'))),
                    DropdownMenuItem(value: 'Inactive', child: Text(_getText('inactive'))),
                    DropdownMenuItem(value: 'Blocked', child: Text(_getText('blocked'))),
                  ],
                  onChanged: (value) {
                    if (value != null) {
                      setState(() {
                        _selectedFilter = value;
                      });
                    }
                  },
                ),
              ],
            ),
          ),
          // User list
          Expanded(
            child: _buildUserList(),
          ),
        ],
      ),
    );
  }

  Widget _buildUserList() {
    final filteredUsers = _getFilteredUsers();
    
    if (filteredUsers.isEmpty) {
      return Center(
        child: Text(_getText('noUsersFound')),
      );
    }
    
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: filteredUsers.length,
      itemBuilder: (context, index) {
        final user = filteredUsers[index];
        return Card(
          margin: const EdgeInsets.only(bottom: 16),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    CircleAvatar(
                      backgroundColor: AppTheme.primaryColor.withOpacity(0.1),
                      child: Text(
                        user['name'].substring(0, 1),
                        style: const TextStyle(
                          color: AppTheme.primaryColor,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            user['name'],
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            user['email'],
                            style: TextStyle(
                              color: Colors.grey[600],
                              fontSize: 14,
                            ),
                          ),
                        ],
                      ),
                    ),
                    _buildStatusChip(user['status']),
                  ],
                ),
                const Divider(height: 24),
                _buildInfoRow(Icons.phone, _getText('phone'), user['phone']),
                _buildInfoRow(Icons.location_on, _getText('location'), user['location']),
                _buildInfoRow(
                  Icons.calendar_today,
                  _getText('registrationDate'),
                  user['registrationDate'],
                ),
                _buildInfoRow(
                  Icons.shopping_bag,
                  _getText('bookingsCount'),
                  user['bookingsCount'].toString(),
                ),
                const SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    TextButton.icon(
                      icon: const Icon(Icons.visibility),
                      label: Text(_getText('viewDetails')),
                      onPressed: () => _showUserDetails(user),
                    ),
                    TextButton.icon(
                      icon: const Icon(Icons.edit),
                      label: Text(_getText('changeStatus')),
                      onPressed: () => _showChangeStatusDialog(user),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildInfoRow(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Row(
        children: [
          Icon(icon, size: 16, color: AppTheme.primaryColor),
          const SizedBox(width: 8),
          Text(
            '$label: ',
            style: const TextStyle(fontWeight: FontWeight.w500),
          ),
          Expanded(
            child: Text(
              value,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatusChip(String status) {
    Color chipColor;
    switch (status) {
      case 'Active':
        chipColor = Colors.green;
        break;
      case 'Inactive':
        chipColor = Colors.orange;
        break;
      case 'Blocked':
        chipColor = Colors.red;
        break;
      default:
        chipColor = Colors.grey;
    }

    String statusText;
    switch (status) {
      case 'Active':
        statusText = _getText('active');
        break;
      case 'Inactive':
        statusText = _getText('inactive');
        break;
      case 'Blocked':
        statusText = _getText('blocked');
        break;
      default:
        statusText = status;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: chipColor.withOpacity(0.1),
        border: Border.all(color: chipColor),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        statusText,
        style: TextStyle(color: chipColor, fontSize: 12),
      ),
    );
  }
}