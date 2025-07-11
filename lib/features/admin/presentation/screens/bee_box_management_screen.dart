import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:uuid/uuid.dart';

// Update the import path for AuthProvider
import '../../../auth/presentation/providers/auth_provider.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../auth/presentation/widgets/custom_button.dart';

class BeeBoxManagementScreen extends StatefulWidget {
  const BeeBoxManagementScreen({super.key});

  @override
  State<BeeBoxManagementScreen> createState() => _BeeBoxManagementScreenState();
}

class _BeeBoxManagementScreenState extends State<BeeBoxManagementScreen> {
  final _formKey = GlobalKey<FormState>();
  final _boxIdController = TextEditingController();
  final _nameController = TextEditingController();
  final _statusController = TextEditingController();
  final _priceController = TextEditingController();
  final _notesController = TextEditingController();
  final _countController = TextEditingController();
  bool _isLoading = false;
  bool _isEditing = false;
  String? _selectedBoxId;

  @override
  void initState() {
    super.initState();
    _generateSequentialBoxId();
  }

  Future<void> _generateSequentialBoxId() async {
    final snapshot = await FirebaseFirestore.instance.collection('bee_boxes').get();
    int maxId = 0;
    for (var doc in snapshot.docs) {
      final data = doc.data();
      // Accept both int and string IDs
      final id = int.tryParse(data['id'].toString());
      if (id != null && id > maxId) {
        maxId = id;
      }
    }
    _boxIdController.text = (maxId + 1).toString();
    setState(() {});
  }

  @override
  void dispose() {
    _boxIdController.dispose();
    _nameController.dispose();
    _statusController.dispose();
    _priceController.dispose();
    _notesController.dispose();
    _countController.dispose();
    super.dispose();
  }

  void _resetForm() {
    _boxIdController.clear();
    _nameController.clear();
    _statusController.clear();
    _priceController.clear();
    _notesController.clear();
    _countController.clear();
    _selectedBoxId = null;
    _isEditing = false;
    _generateSequentialBoxId();
    setState(() {});
  }

  void _editBeeBox(DocumentSnapshot beeBox) {
    final data = beeBox.data() as Map<String, dynamic>;
    setState(() {
      _selectedBoxId = data['id'];
      _boxIdController.text = data['id'];
      _nameController.text = data['name'];
      _statusController.text = data['status'];
      _priceController.text = data['price'].toString();
      _notesController.text = data['notes'];
      _countController.text = data['count']?.toString() ?? '';
      _isEditing = true;
    });
  }

  Future<void> _saveForm() async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isLoading = true;
      });

      final newBeeBox = {
        'id': _boxIdController.text,
        'name': _nameController.text,
        'status': _statusController.text,
        'price': double.parse(_priceController.text),
        'notes': _notesController.text,
        'count': int.tryParse(_countController.text) ?? 0,
        'lastMaintenance': DateTime.now().toString().substring(0, 10),
      };

      if (_isEditing) {
        await FirebaseFirestore.instance
            .collection('bee_boxes')
            .doc(_selectedBoxId)
            .update(newBeeBox);
      } else {
        await FirebaseFirestore.instance
            .collection('bee_boxes')
            .doc(_boxIdController.text)
            .set(newBeeBox);
      }

      setState(() {
        _isLoading = false;
      });

      _resetForm();

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content: Text(
                  '${_isEditing ? 'beeBoxUpdated' : 'beeBoxAdded'}.tr')),
        );
      }
    }
  }

  void _deleteBeeBox(String id) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('confirmDelete'.tr()),
        content: Text('deleteBeeBoxConfirmation'.tr()),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('cancel'.tr()),
          ),
          TextButton(
            onPressed: () async {
              await FirebaseFirestore.instance
                  .collection('bee_boxes')
                  .doc(id)
                  .delete();
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('beeBoxDeleted'.tr())),
              );
            },
            child: Text(
              'delete'.tr(),
              style: const TextStyle(color: Colors.red),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('beeBoxManagement'.tr()),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16.0),
        children: [
          // Form for adding/editing bee boxes
          Card(
            elevation: 2,
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      _isEditing
                          ? 'editBeeBox'.tr()
                          : 'addNewBeeBox'.tr(),
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 16),
                    // Box ID field
                    TextFormField(
                      controller: _boxIdController,
                      decoration: InputDecoration(
                        labelText: 'boxId'.tr(),
                        border: const OutlineInputBorder(),
                      ),
                      enabled: false, // Make Box ID read-only
                      // validator: (value) {
                      //   if (value == null || value.isEmpty) {
                      //     return 'pleaseEnterBoxId'.tr();
                      //   }
                      //   return null;
                      // },
                    ),
                    const SizedBox(height: 16),
                    // name field
                    TextFormField(
                      controller: _nameController,
                      decoration: InputDecoration(
                        labelText: 'name'.tr(),
                        border: const OutlineInputBorder(),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'pleaseEntername'.tr();
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),
                    // Status dropdown
                    DropdownButtonFormField<String>(
                      value: _statusController.text.isEmpty
                          ? null
                          : _statusController.text,
                      decoration: InputDecoration(
                        labelText: 'status'.tr(),
                        border: const OutlineInputBorder(),
                      ),
                      items: [
                        DropdownMenuItem(
                          value: 'Available',
                          child: Text('available'.tr()),
                        ),
                        DropdownMenuItem(
                          value: 'Booked',
                          child: Text('booked'.tr()),
                        ),
                        DropdownMenuItem(
                          value: 'Maintenance',
                          child: Text('maintenance'.tr()),
                        ),
                      ],
                      onChanged: (value) {
                        if (value != null) {
                          _statusController.text = value;
                        }
                      },
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'pleaseEnterStatus'.tr();
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),
                    // Price field
                    TextFormField(
                      controller: _priceController,
                      decoration: InputDecoration(
                        labelText: 'price'.tr(),
                        border: const OutlineInputBorder(),
                      ),
                      keyboardType: TextInputType.number,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'pleaseEnterValidPrice'.tr();
                        }
                        try {
                          double.parse(value);
                        } catch (e) {
                          return 'pleaseEnterValidPrice'.tr();
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),
                    // Number of Boxes field
                    TextFormField(
                      controller: _countController,
                      decoration: InputDecoration(
                        labelText: 'Number of Boxes', // Add translation key if needed
                        border: const OutlineInputBorder(),
                      ),
                      keyboardType: TextInputType.number,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter the number of boxes'; // Add translation key if needed
                        }
                        if (int.tryParse(value) == null || int.parse(value) < 1) {
                          return 'Enter a valid number greater than 0'; // Add translation key if needed
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),
                    // Notes field
                    TextFormField(
                      controller: _notesController,
                      decoration: InputDecoration(
                        labelText: 'notes'.tr(),
                        border: const OutlineInputBorder(),
                      ),
                      maxLines: 3,
                    ),
                    const SizedBox(height: 16),
                    // Action buttons
                    Row(
                      children: [
                        if (_isEditing)
                          Expanded(
                            child: CustomButton(
                              text: 'cancel'.tr(),
                              onPressed: _resetForm,
                              backgroundColor: Colors.grey[300] ?? Colors.grey,
                              textColor: AppTheme.textPrimary,
                            ),
                          ),
                        if (_isEditing) const SizedBox(width: 16),
                        Expanded(
                          child: CustomButton(
                            text: 'save'.tr(),
                            onPressed: _saveForm,
                            isLoading: _isLoading,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
          const SizedBox(height: 24),
          // Bee box list
          FutureBuilder<QuerySnapshot>(
            future: FirebaseFirestore.instance.collection('bee_boxes').get(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }
              if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                return Center(child: Text('noBeeBoxesFound'.tr()));
              }
              final beeBoxes = snapshot.data!.docs;
              return ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: beeBoxes.length,
                itemBuilder: (context, index) {
                  final data = beeBoxes[index].data() as Map<String, dynamic>;
                  return Card(
                    margin: const EdgeInsets.symmetric(vertical: 8),
                    child: ListTile(
                      title: Text(
                        '${data['id']} - ${data['name']}',
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                      subtitle: Text('${'status'.tr()}: ${data['status']}\nCount: ${data['count'] ?? 0}'),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          IconButton(
                            icon: const Icon(Icons.edit, color: AppTheme.primaryColor),
                            onPressed: () => _editBeeBox(beeBoxes[index]),
                            tooltip: 'edit'.tr(),
                          ),
                          IconButton(
                            icon: const Icon(Icons.delete, color: Colors.red),
                            onPressed: () => _deleteBeeBox(beeBoxes[index].id),
                            tooltip: 'delete'.tr(),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildBeeBoxList(List<DocumentSnapshot> beeBoxes) {
    return ListView.builder(
      itemCount: beeBoxes.length,
      itemBuilder: (context, index) {
        final beeBox = beeBoxes[index];
        final data = beeBox.data() as Map<String, dynamic>;
        return Card(
          margin: const EdgeInsets.only(bottom: 8),
          child: ListTile(
            title: Text(
              '${data['id']} - ${data['name']}',
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 4),
                Row(
                  children: [
                    _buildStatusChip(data['status'] ?? ''),
                    const SizedBox(width: 8),
                    Text('₹${data['price']}/day'),
                  ],
                ),
                const SizedBox(height: 4),
                Text('${'lastMaintenance'.tr()}: ${data['lastMaintenance']}'),
                if (data['notes'] != null && data['notes'].isNotEmpty) ...[
                  const SizedBox(height: 4),
                  Text(
                    data['notes'],
                    style: TextStyle(color: Colors.grey[600]),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ],
            ),
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                IconButton(
                  icon: const Icon(Icons.edit, color: AppTheme.primaryColor),
                  onPressed: () => _editBeeBox(beeBox),
                  tooltip: 'edit'.tr(),
                ),
                IconButton(
                  icon: const Icon(Icons.delete, color: Colors.red),
                  onPressed: () => _deleteBeeBox(beeBox.id),
                  tooltip: 'delete'.tr(),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildStatusChip(String status) {
    Color chipColor;
    switch (status) {
      case 'Available':
        chipColor = Colors.green;
        break;
      case 'Booked':
        chipColor = Colors.orange;
        break;
      case 'Maintenance':
        chipColor = Colors.red;
        break;
      default:
        chipColor = Colors.grey;
    }
    String statusText;
    switch (status) {
      case 'Available':
        statusText = 'available'.tr();
        break;
      case 'Booked':
        statusText = 'booked'.tr();
        break;
      case 'Maintenance':
        statusText = 'maintenance'.tr();
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
      child: Text(statusText, style: TextStyle(color: chipColor, fontSize: 12)),
    );
  }
}