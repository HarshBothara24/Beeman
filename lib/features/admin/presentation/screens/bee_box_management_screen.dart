import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

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
  final _locationController = TextEditingController();
  final _statusController = TextEditingController();
  final _priceController = TextEditingController();
  final _notesController = TextEditingController();
  bool _isLoading = false;
  bool _isEditing = false;
  String? _selectedBoxId;

  @override
  void dispose() {
    _boxIdController.dispose();
    _locationController.dispose();
    _statusController.dispose();
    _priceController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  void _resetForm() {
    _boxIdController.clear();
    _locationController.clear();
    _statusController.clear();
    _priceController.clear();
    _notesController.clear();
    _selectedBoxId = null;
    _isEditing = false;
    setState(() {});
  }

  void _editBeeBox(DocumentSnapshot beeBox) {
    final data = beeBox.data() as Map<String, dynamic>;
    setState(() {
      _selectedBoxId = data['id'];
      _boxIdController.text = data['id'];
      _locationController.text = data['location'];
      _statusController.text = data['status'];
      _priceController.text = data['price'].toString();
      _notesController.text = data['notes'];
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
        'location': _locationController.text,
        'status': _statusController.text,
        'price': double.parse(_priceController.text),
        'notes': _notesController.text,
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
                  _getText(_isEditing ? 'beeBoxUpdated' : 'beeBoxAdded'))),
        );
      }
    }
  }

  void _deleteBeeBox(String id) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(_getText('confirmDelete')),
        content: Text(_getText('deleteBeeBoxConfirmation')),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(_getText('cancel')),
          ),
          TextButton(
            onPressed: () async {
              await FirebaseFirestore.instance
                  .collection('bee_boxes')
                  .doc(id)
                  .delete();
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text(_getText('beeBoxDeleted'))),
              );
            },
            child: Text(
              _getText('delete'),
              style: const TextStyle(color: Colors.red),
            ),
          ),
        ],
      ),
    );
  }

  String _getText(String key) {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final languageCode = authProvider.languageCode;
    
    final Map<String, Map<String, String>> textMap = {
      'beeBoxManagement': {
        'en': 'Bee Box Management',
        'hi': 'मधुमक्खी बॉक्स प्रबंधन',
        'mr': 'मधमाशी बॉक्स व्यवस्थापन',
      },
      'addNewBeeBox': {
        'en': 'Add New Bee Box',
        'hi': 'नया मधुमक्खी बॉक्स जोड़ें',
        'mr': 'नवीन मधमाशी बॉक्स जोडा',
      },
      'editBeeBox': {
        'en': 'Edit Bee Box',
        'hi': 'मधुमक्खी बॉक्स संपादित करें',
        'mr': 'मधमाशी बॉक्स संपादित करा',
      },
      'boxId': {
        'en': 'Box ID',
        'hi': 'बॉक्स आईडी',
        'mr': 'बॉक्स आयडी',
      },
      'location': {
        'en': 'Location',
        'hi': 'स्थान',
        'mr': 'स्थान',
      },
      'status': {
        'en': 'Status',
        'hi': 'स्थिति',
        'mr': 'स्थिती',
      },
      'price': {
        'en': 'Price (₹/day)',
        'hi': 'मूल्य (₹/दिन)',
        'mr': 'किंमत (₹/दिवस)',
      },
      'notes': {
        'en': 'Notes',
        'hi': 'नोट्स',
        'mr': 'नोट्स',
      },
      'lastMaintenance': {
        'en': 'Last Maintenance',
        'hi': 'अंतिम रखरखाव',
        'mr': 'शेवटची देखभाल',
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
      'edit': {
        'en': 'Edit',
        'hi': 'संपादित करें',
        'mr': 'संपादित करा',
      },
      'delete': {
        'en': 'Delete',
        'hi': 'हटाएं',
        'mr': 'हटवा',
      },
      'confirmDelete': {
        'en': 'Confirm Delete',
        'hi': 'हटाने की पुष्टि करें',
        'mr': 'हटविण्याची पुष्टी करा',
      },
      'deleteBeeBoxConfirmation': {
        'en': 'Are you sure you want to delete this bee box? This action cannot be undone.',
        'hi': 'क्या आप वाकई इस मधुमक्खी बॉक्स को हटाना चाहते हैं? यह क्रिया पूर्ववत नहीं की जा सकती है।',
        'mr': 'तुम्हाला खात्री आहे की तुम्ही हा मधमाशी बॉक्स हटवू इच्छिता? ही क्रिया पूर्ववत केली जाऊ शकत नाही.',
      },
      'beeBoxAdded': {
        'en': 'Bee box added successfully',
        'hi': 'मधुमक्खी बॉक्स सफलतापूर्वक जोड़ा गया',
        'mr': 'मधमाशी बॉक्स यशस्वीरित्या जोडला गेला',
      },
      'beeBoxUpdated': {
        'en': 'Bee box updated successfully',
        'hi': 'मधुमक्खी बॉक्स सफलतापूर्वक अपडेट किया गया',
        'mr': 'मधमाशी बॉक्स यशस्वीरित्या अपडेट केला गेला',
      },
      'beeBoxDeleted': {
        'en': 'Bee box deleted successfully',
        'hi': 'मधुमक्खी बॉक्स सफलतापूर्वक हटा दिया गया',
        'mr': 'मधमाशी बॉक्स यशस्वीरित्या हटवला गेला',
      },
      'pleaseEnterBoxId': {
        'en': 'Please enter box ID',
        'hi': 'कृपया बॉक्स आईडी दर्ज करें',
        'mr': 'कृपया बॉक्स आयडी प्रविष्ट करा',
      },
      'pleaseEnterLocation': {
        'en': 'Please enter location',
        'hi': 'कृपया स्थान दर्ज करें',
        'mr': 'कृपया स्थान प्रविष्ट करा',
      },
      'pleaseEnterStatus': {
        'en': 'Please enter status',
        'hi': 'कृपया स्थिति दर्ज करें',
        'mr': 'कृपया स्थिती प्रविष्ट करा',
      },
      'pleaseEnterValidPrice': {
        'en': 'Please enter a valid price',
        'hi': 'कृपया एक मान्य मूल्य दर्ज करें',
        'mr': 'कृपया वैध किंमत प्रविष्ट करा',
      },
      'available': {
        'en': 'Available',
        'hi': 'उपलब्ध',
        'mr': 'उपलब्ध',
      },
      'booked': {
        'en': 'Booked',
        'hi': 'बुक किया गया',
        'mr': 'बुक केलेले',
      },
      'maintenance': {
        'en': 'Maintenance',
        'hi': 'रखरखाव',
        'mr': 'देखभाल',
      },
    };

    return textMap[key]?[languageCode] ?? textMap[key]?['en'] ?? key;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_getText('beeBoxManagement')),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
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
                            ? _getText('editBeeBox')
                            : _getText('addNewBeeBox'),
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
                          labelText: _getText('boxId'),
                          border: const OutlineInputBorder(),
                        ),
                        enabled: !_isEditing, // Can't change ID when editing
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return _getText('pleaseEnterBoxId');
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),
                      // Location field
                      TextFormField(
                        controller: _locationController,
                        decoration: InputDecoration(
                          labelText: _getText('location'),
                          border: const OutlineInputBorder(),
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return _getText('pleaseEnterLocation');
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
                          labelText: _getText('status'),
                          border: const OutlineInputBorder(),
                        ),
                        items: [
                          DropdownMenuItem(
                            value: 'Available',
                            child: Text(_getText('available')),
                          ),
                          DropdownMenuItem(
                            value: 'Booked',
                            child: Text(_getText('booked')),
                          ),
                          DropdownMenuItem(
                            value: 'Maintenance',
                            child: Text(_getText('maintenance')),
                          ),
                        ],
                        onChanged: (value) {
                          if (value != null) {
                            _statusController.text = value;
                          }
                        },
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return _getText('pleaseEnterStatus');
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),
                      // Price field
                      TextFormField(
                        controller: _priceController,
                        decoration: InputDecoration(
                          labelText: _getText('price'),
                          border: const OutlineInputBorder(),
                        ),
                        keyboardType: TextInputType.number,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return _getText('pleaseEnterValidPrice');
                          }
                          try {
                            double.parse(value);
                          } catch (e) {
                            return _getText('pleaseEnterValidPrice');
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),
                      // Notes field
                      TextFormField(
                        controller: _notesController,
                        decoration: InputDecoration(
                          labelText: _getText('notes'),
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
                                text: _getText('cancel'),
                                onPressed: _resetForm,
                                backgroundColor: Colors.grey[300] ?? Colors.grey,
                                textColor: AppTheme.textPrimary,
                              ),
                            ),
                          if (_isEditing) const SizedBox(width: 16),
                          Expanded(
                            child: CustomButton(
                              text: _getText('save'),
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
            const SizedBox(height: 16),
            // List of bee boxes
            Expanded(
              child: StreamBuilder<QuerySnapshot>(
                stream: FirebaseFirestore.instance.collection('bee_boxes').snapshots(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }
                  if (snapshot.hasError) {
                    return Center(child: Text('Error: ${snapshot.error}'));
                  }

                  final beeBoxes = snapshot.data?.docs ?? [];

                  if (beeBoxes.isEmpty) {
                    return Center(child: Text(_getText('noBeeBoxesFound')));
                  }

                  return _buildBeeBoxList(beeBoxes);
                },
              ),
            ),
          ],
        ),
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
              '${data['id']} - ${data['location']}',
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
                Text('${_getText('lastMaintenance')}: ${data['lastMaintenance']}'),
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
                  tooltip: _getText('edit'),
                ),
                IconButton(
                  icon: const Icon(Icons.delete, color: Colors.red),
                  onPressed: () => _deleteBeeBox(beeBox.id),
                  tooltip: _getText('delete'),
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
        statusText = _getText('available');
        break;
      case 'Booked':
        statusText = _getText('booked');
        break;
      case 'Maintenance':
        statusText = _getText('maintenance');
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