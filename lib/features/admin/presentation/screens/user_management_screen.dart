import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:excel/excel.dart' as excel;
import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'dart:html' as html;

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

  Stream<QuerySnapshot> _getUsersStream() {
    return FirebaseFirestore.instance.collection('users').snapshots();
  }

  List<DocumentSnapshot> _getFilteredUsers(List<DocumentSnapshot> users) {
    return users.where((user) {
      final data = user.data() as Map<String, dynamic>;
      // Filter by status
      final statusMatch = _selectedFilter == 'All' || data['status'] == _selectedFilter;

      // Filter by search query if present
      final searchMatch = _searchQuery.isEmpty ||
          (data['id'] ?? '').toLowerCase().contains(_searchQuery.toLowerCase()) ||
          (data['name'] ?? '').toLowerCase().contains(_searchQuery.toLowerCase()) ||
          (data['email'] ?? '').toLowerCase().contains(_searchQuery.toLowerCase()) ||
          (data['phone'] ?? '').toLowerCase().contains(_searchQuery.toLowerCase()) ||
          (data['location'] ?? '').toLowerCase().contains(_searchQuery.toLowerCase());

      return statusMatch && searchMatch;
    }).toList();
  }

  void _showUserDetails(DocumentSnapshot user) {
    final data = user.data() as Map<String, dynamic>;
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('${_getText('userDetails')}: ${data['name']}'),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildDetailRow(_getText('userId'), data['id'] ?? ''),
              _buildDetailRow(_getText('name'), data['name'] ?? ''),
              _buildDetailRow(_getText('email'), data['email'] ?? ''),
              _buildDetailRow(_getText('phone'), data['phone'] ?? ''),
              _buildDetailRow(_getText('location'), data['location'] ?? ''),
              _buildDetailRow(_getText('role'), data['role'] ?? ''),
              _buildDetailRow(_getText('status'), data['status'] ?? ''),
              _buildDetailRow(_getText('registrationDate'), data['registrationDate'] ?? ''),
              _buildDetailRow(_getText('lastActive'), data['lastActive'] ?? ''),
              _buildDetailRow(_getText('bookingsCount'), (data['bookingsCount'] ?? 0).toString()),
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

  void _showChangeStatusDialog(DocumentSnapshot user) {
    final data = user.data() as Map<String, dynamic>;
    String newStatus = data['status'] ?? '';
    
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
              FirebaseFirestore.instance
                  .collection('users')
                  .doc(user.id)
                  .update({'status': newStatus});
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
        actions: [
          IconButton(
            icon: const Icon(Icons.download),
            tooltip: 'Export to Excel',
            onPressed: () async {
              await _exportUsersToExcel();
            },
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'User Management',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: AppTheme.textPrimary),
            ),
            const SizedBox(height: 16),
            Card(
              elevation: 2,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: _searchController,
                        decoration: InputDecoration(
                          hintText: _getText('search'),
                          prefixIcon: const Icon(Icons.search),
                          border: InputBorder.none,
                          contentPadding: const EdgeInsets.symmetric(vertical: 0),
                        ),
                        onChanged: (value) {
                          setState(() {
                            _searchQuery = value;
                          });
                        },
                      ),
                    ),
                    const SizedBox(width: 8),
                    DropdownButton<String>(
                      value: _selectedFilter,
                      items: [
                        DropdownMenuItem(value: 'All', child: Text(l10n('All'))),
                        DropdownMenuItem(value: 'Active', child: Text(l10n('Active'))),
                        DropdownMenuItem(value: 'Inactive', child: Text(l10n('Inactive'))),
                      ],
                      onChanged: (v) => setState(() => _selectedFilter = v ?? 'All'),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),
            Expanded(
              child: StreamBuilder<QuerySnapshot>(
                stream: _getUsersStream(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }
                  final users = snapshot.data?.docs ?? [];
                  final filteredUsers = _getFilteredUsers(users);
                  if (filteredUsers.isEmpty) {
                    return Center(child: Text(l10n('No users found.')));
                  }
                  return ListView.builder(
                    itemCount: filteredUsers.length,
                    itemBuilder: (context, index) {
                      final user = filteredUsers[index];
                      final data = user.data() as Map<String, dynamic>;
                      return AnimatedContainer(
                        duration: const Duration(milliseconds: 300),
                        curve: Curves.easeInOut,
                        margin: const EdgeInsets.only(bottom: 16),
                        child: Card(
                          elevation: 2,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          child: ListTile(
                            leading: CircleAvatar(
                              backgroundColor: AppTheme.primaryColor.withOpacity(0.1),
                              child: Icon(Icons.person, color: AppTheme.primaryColor),
                            ),
                            title: Text(data['name'] ?? '', style: const TextStyle(fontWeight: FontWeight.bold)),
                            subtitle: Text(data['email'] ?? ''),
                            trailing: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                IconButton(
                                  icon: const Icon(Icons.edit, color: AppTheme.primaryColor),
                                  onPressed: () => _showChangeStatusDialog(user),
                                  tooltip: l10n('Edit'),
                                ),
                                IconButton(
                                  icon: const Icon(Icons.delete, color: Colors.red),
                                  onPressed: () async {
                                    await FirebaseFirestore.instance.collection('users').doc(user.id).delete();
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(content: Text(l10n('User deleted'))),
                                    );
                                  },
                                  tooltip: l10n('Delete'),
                                ),
                              ],
                            ),
                          ),
                        ),
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _exportUsersToExcel() async {
    final snapshot = await _getUsersStream().first;
    final users = snapshot.docs;
    if (users.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No users to export.')),
      );
      return;
    }
    final workbook = excel.Excel.createExcel();
    final sheet = workbook['Users'];
    sheet.appendRow([
      'User ID', 'Name', 'Email', 'Phone', 'Location', 'Status'
    ]);
    for (final user in users) {
      final data = user.data() as Map<String, dynamic>;
      sheet.appendRow([
        user.id,
        data['name'] ?? '',
        data['email'] ?? '',
        data['phone'] ?? '',
        data['location'] ?? '',
        data['status'] ?? '',
      ]);
    }
    final fileBytes = workbook.encode();
    if (kIsWeb) {
      final blob = html.Blob([fileBytes]);
      final url = html.Url.createObjectUrlFromBlob(blob);
      final anchor = html.AnchorElement(href: url)
        ..setAttribute('download', 'users.xlsx')
        ..click();
      html.Url.revokeObjectUrl(url);
    } else {
      final dir = await getApplicationDocumentsDirectory();
      final file = File('${dir.path}/users.xlsx');
      await file.writeAsBytes(fileBytes!);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Exported to ${file.path}')),
      );
    }
  }

  Widget _buildUserList() {
    return StreamBuilder<QuerySnapshot>(
      stream: _getUsersStream(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        if (snapshot.hasError) {
          return Center(child: Text('Error: ${snapshot.error}'));
        }

        final users = snapshot.data?.docs ?? [];
        final filteredUsers = _getFilteredUsers(users);

        if (filteredUsers.isEmpty) {
          return Center(
            child: Text(_getText('noUsersFound')),
          );
        }

        return ListView.separated(
          itemCount: filteredUsers.length,
          separatorBuilder: (context, index) => Divider(height: 1),
          itemBuilder: (context, index) {
            final user = filteredUsers[index];
            final data = user.data() as Map<String, dynamic>;
            return ListTile(
              leading: CircleAvatar(
                backgroundColor: AppTheme.primaryColor,
                child: Text(
                  (data['displayName'] ?? data['email'] ?? 'U').substring(0, 1).toUpperCase(),
                  style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                ),
              ),
              title: Text(data['displayName'] ?? data['email'] ?? 'Unknown'),
              subtitle: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Email: ${data['email'] ?? 'N/A'}'),
                  Text('Phone: ${data['phone'] ?? 'N/A'}'),
                  Text('Registered: ${data['createdAt'] != null ? data['createdAt'].toString().substring(0, 10) : 'N/A'}'),
                ],
              ),
              trailing: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  _buildStatusBadge(data['status'] ?? 'Active'),
                  IconButton(
                    icon: Icon(Icons.delete, color: Colors.red),
                    onPressed: () => _confirmDeleteUser(user),
                  ),
                ],
              ),
              onTap: () => _showUserDetails(user),
            );
          },
        );
      },
    );
  }

  Widget _buildStatusBadge(String status) {
    Color color;
    switch (status.toLowerCase()) {
      case 'active':
        color = Colors.green;
        break;
      case 'inactive':
        color = Colors.orange;
        break;
      case 'blocked':
        color = Colors.red;
        break;
      default:
        color = Colors.grey;
    }
    return Container(
      margin: const EdgeInsets.only(left: 8),
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.2),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        l10n(status),
        style: TextStyle(color: color, fontWeight: FontWeight.bold, fontSize: 12),
      ),
    );
  }

  void _confirmDeleteUser(DocumentSnapshot user) {
    final data = user.data() as Map<String, dynamic>;
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Delete User'),
        content: Text('Are you sure you want to delete ${data['displayName'] ?? data['email']}?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cancel'),
          ),
          TextButton(
            onPressed: () async {
              await FirebaseFirestore.instance.collection('users').doc(user.id).delete();
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('User deleted')),
              );
            },
            child: Text('Delete', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }
}

String l10n(String text) => text; // Placeholder for localization