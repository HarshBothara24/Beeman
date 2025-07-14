import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:uuid/uuid.dart';
import 'package:excel/excel.dart' as excel;
import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'dart:html' as html;
import 'package:file_picker/file_picker.dart';
import 'package:csv/csv.dart';

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
  String? _selectedSpecies;
  final _statusController = TextEditingController();
  final _priceController = TextEditingController();
  final _notesController = TextEditingController();
  final _countController = TextEditingController();
  bool _isLoading = false;
  bool _isEditing = false;
  String? _selectedBoxId;
  List<String> _selectedRows = [];
  int _currentPage = 1;
  int _rowsPerPage = 10;

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
    _statusController.dispose();
    _priceController.dispose();
    _notesController.dispose();
    _countController.dispose();
    super.dispose();
  }

  void _resetForm() {
    _boxIdController.clear();
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
      _selectedSpecies = data['species_en'];
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

      final Map<String, Map<String, String>> speciesMap = {
        'italian': {'en': 'Italian Honeybees', 'sci': 'Apis mellifera'},
        'stingless': {'en': 'Stingless Honeybees', 'sci': 'Trigona'},
        'sateri': {'en': 'Sateri Honeybees', 'sci': 'Apis cerana'},
      };
      final selectedSpecies = speciesMap[_selectedSpecies ?? 'italian']!;
      final newBeeBox = {
        'id': _boxIdController.text,
        'species_en': selectedSpecies['en'],
        'species_sci': selectedSpecies['sci'],
        'species_key': _selectedSpecies ?? 'italian',
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

  void _openFormModal({DocumentSnapshot? beeBox}) {
    if (beeBox != null) {
      _editBeeBox(beeBox);
    } else {
      _resetForm();
    }
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(_isEditing ? 'Edit Bee Box' : 'Add Bee Box'),
        content: SizedBox(
          width: 400,
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextFormField(
                  controller: _boxIdController,
                  decoration: InputDecoration(labelText: l10n('Box ID')),
                  enabled: !_isEditing,
                  validator: (v) => v == null || v.trim().isEmpty ? l10n('Required') : null,
                ),
                const SizedBox(height: 8),
                DropdownButtonFormField<String>(
                  value: _selectedSpecies,
                  decoration: InputDecoration(labelText: l10n('Bee Species')),
                  items: [
                    DropdownMenuItem(value: 'italian', child: Text('Italian Honeybees (Apis mellifera)')),
                    DropdownMenuItem(value: 'stingless', child: Text('Stingless Honeybees (Trigona)')),
                    DropdownMenuItem(value: 'sateri', child: Text('Sateri Honeybees (Apis cerana)')),
                  ],
                  onChanged: (value) {
                    setState(() { _selectedSpecies = value; });
                  },
                  validator: (v) => v == null || v.isEmpty ? l10n('Required') : null,
                ),
                const SizedBox(height: 8),
                DropdownButtonFormField<String>(
                  value: _statusController.text.isEmpty ? null : _statusController.text,
                  decoration: InputDecoration(labelText: l10n('Status')),
                  items: [
                    DropdownMenuItem(value: 'Available', child: Text(l10n('Available'))),
                    DropdownMenuItem(value: 'Booked', child: Text(l10n('Booked'))),
                    DropdownMenuItem(value: 'Maintenance', child: Text(l10n('Maintenance'))),
                  ],
                  onChanged: (value) {
                    if (value != null) _statusController.text = value;
                  },
                  validator: (v) => v == null || v.isEmpty ? l10n('Required') : null,
                ),
                const SizedBox(height: 8),
                TextFormField(
                  controller: _priceController,
                  decoration: InputDecoration(labelText: l10n('Price (per day)')),
                  keyboardType: TextInputType.number,
                  validator: (v) => v == null || v.trim().isEmpty ? l10n('Required') : null,
                ),
                const SizedBox(height: 8),
                TextFormField(
                  controller: _countController,
                  decoration: InputDecoration(labelText: l10n('Count')),
                  keyboardType: TextInputType.number,
                  validator: (v) => v == null || v.trim().isEmpty ? l10n('Required') : null,
                ),
                const SizedBox(height: 8),
                TextFormField(
                  controller: _notesController,
                  decoration: InputDecoration(labelText: l10n('Notes')),
                ),
              ],
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(l10n('Cancel')),
          ),
          ElevatedButton(
            onPressed: () async {
              await _saveForm();
              Navigator.pop(context);
              setState(() {});
            },
            child: Text(_isEditing ? l10n('Save Changes') : l10n('Add Bee Box')),
          ),
        ],
      ),
    );
  }

  void _deleteSelectedRows() async {
    for (final id in _selectedRows) {
      await FirebaseFirestore.instance.collection('bee_boxes').doc(id).delete();
    }
    setState(() {
      _selectedRows.clear();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(l10n('beeBoxManagement')),
        actions: [
          IconButton(
            icon: const Icon(Icons.download),
            tooltip: 'Export to Excel',
            onPressed: () async {
              await _exportBeeBoxesToExcel();
            },
          ),
          IconButton(
            icon: const Icon(Icons.upload_file),
            tooltip: 'Import from Excel/CSV',
            onPressed: () async {
              await _importBeeBoxesFromFile();
            },
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                Text(l10n('Bee Boxes'), style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: AppTheme.textPrimary)),
                      Row(
                        children: [
                    if (_selectedRows.isNotEmpty)
                      ElevatedButton.icon(
                        onPressed: _deleteSelectedRows,
                        icon: Icon(Icons.delete),
                        label: Text(l10n('Delete')),
                        style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
                      ),
                    const SizedBox(width: 8),
                    ElevatedButton.icon(
                      onPressed: () => _openFormModal(),
                      icon: Icon(Icons.add),
                      label: Text(l10n('Add Bee Box')),
                      style: ElevatedButton.styleFrom(backgroundColor: AppTheme.primaryColor),
                            ),
                        ],
                      ),
                    ],
            ),
            const SizedBox(height: 16),
            Expanded(
              child: FutureBuilder<QuerySnapshot>(
                future: FirebaseFirestore.instance.collection('bee_boxes').get(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }
                  if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                    return Center(child: Text(l10n('No bee boxes found.')));
                  }
                  final beeBoxes = snapshot.data!.docs;
                  final totalPages = (beeBoxes.length / _rowsPerPage).ceil();
                  final start = (_currentPage - 1) * _rowsPerPage;
                  final end = (_currentPage * _rowsPerPage).clamp(0, beeBoxes.length);
                  final pageBoxes = beeBoxes.sublist(start, end);
                  return Column(
                              children: [
                      DataTable(
                        columns: [
                          DataColumn(
                            label: Checkbox(
                              value: _selectedRows.length == pageBoxes.length && pageBoxes.isNotEmpty,
                              onChanged: (checked) {
                                setState(() {
                                  if (checked == true) {
                                    _selectedRows = pageBoxes.map((b) => b.id).toList();
                                  } else {
                                    _selectedRows.clear();
                                  }
                                });
                              },
                            ),
                          ),
                          DataColumn(label: Text(l10n('Box ID'))),
                          DataColumn(label: Text(l10n('Species'))),
                          DataColumn(label: Text(l10n('Status'))),
                          DataColumn(label: Text(l10n('Price'))),
                          DataColumn(label: Text(l10n('Count'))),
                          DataColumn(label: Text(l10n('Notes'))),
                          DataColumn(label: Text(l10n('Actions'))),
                        ],
                        rows: pageBoxes.map((doc) {
                          final data = doc.data() as Map<String, dynamic>;
                          return DataRow(
                            selected: _selectedRows.contains(doc.id),
                            onSelectChanged: (selected) {
                              setState(() {
                                if (selected == true) {
                                  _selectedRows.add(doc.id);
                                } else {
                                  _selectedRows.remove(doc.id);
                                }
                              });
                            },
                            cells: [
                              DataCell(Checkbox(
                                value: _selectedRows.contains(doc.id),
                                onChanged: (checked) {
                                  setState(() {
                                    if (checked == true) {
                                      _selectedRows.add(doc.id);
                                    } else {
                                      _selectedRows.remove(doc.id);
                                    }
                                  });
                                },
                              )),
                              DataCell(Text(data['id'].toString())),
                              DataCell(Text('${data['species_en']} (${data['species_sci']})')),
                              DataCell(Text(data['status'] ?? '')),
                              DataCell(Text('₹${data['price']}')),
                              DataCell(Text(data['count']?.toString() ?? '')),
                              DataCell(Text(data['notes'] ?? '')),
                              DataCell(Row(
                                  children: [
                                  IconButton(
                                    icon: Icon(Icons.edit, color: AppTheme.primaryColor),
                                    onPressed: () => _openFormModal(beeBox: doc),
                                  ),
                                  IconButton(
                                    icon: Icon(Icons.delete, color: Colors.red),
                                    onPressed: () => _deleteBeeBox(doc.id),
                                  ),
                                ],
                              )),
                            ],
                          );
                        }).toList(),
                      ),
                      if (totalPages > 1)
                        Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                              children: [
                                IconButton(
                              icon: Icon(Icons.chevron_left),
                              onPressed: _currentPage > 1 ? () => setState(() => _currentPage--) : null,
                                ),
                            Text('${l10n('Page')} $_currentPage ${l10n('of')} $totalPages'),
                                IconButton(
                              icon: Icon(Icons.chevron_right),
                              onPressed: _currentPage < totalPages ? () => setState(() => _currentPage++) : null,
                            ),
                          ],
                        ),
                    ],
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _exportBeeBoxesToExcel() async {
    final snapshot = await FirebaseFirestore.instance.collection('bee_boxes').get();
    final beeBoxes = snapshot.docs;
    if (beeBoxes.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(l10n('noBeeBoxesFound'))),
      );
      return;
    }
    final workbook = excel.Excel.createExcel();
    final sheet = workbook['BeeBoxes'];
    sheet.appendRow([
      'Box ID', 'Name', 'Status', 'Price', 'Notes', 'Count', 'Last Maintenance'
    ]);
    for (final box in beeBoxes) {
      final data = box.data() as Map<String, dynamic>;
      sheet.appendRow([
        data['id'] ?? '',
        data['name'] ?? '',
        data['status'] ?? '',
        data['price'] ?? '',
        data['notes'] ?? '',
        data['count'] ?? '',
        data['lastMaintenance'] ?? '',
      ]);
    }
    final fileBytes = workbook.encode();
    if (kIsWeb) {
      final blob = html.Blob([fileBytes]);
      final url = html.Url.createObjectUrlFromBlob(blob);
      final anchor = html.AnchorElement(href: url)
        ..setAttribute('download', 'bee_boxes.xlsx')
        ..click();
      html.Url.revokeObjectUrl(url);
    } else {
      final dir = await getApplicationDocumentsDirectory();
      final file = File('${dir.path}/bee_boxes.xlsx');
      await file.writeAsBytes(fileBytes!);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('beeBoxesExported'.tr())),
      );
    }
  }

  Future<void> _importBeeBoxesFromFile() async {
    try {
      FilePickerResult? result = await FilePicker.platform.pickFiles(type: FileType.custom, allowedExtensions: ['csv', 'xlsx']);
      if (result == null) return;
      final file = result.files.first;
      List<List<dynamic>> rows = [];
      if (file.extension == 'csv') {
        final csvString = String.fromCharCodes(file.bytes!);
        rows = const CsvToListConverter().convert(csvString);
      } else if (file.extension == 'xlsx') {
        final workbook = excel.Excel.decodeBytes(file.bytes!);
        final sheet = workbook.tables.values.first;
        rows = sheet!.rows;
      }
      if (rows.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('No data found in file.')));
        return;
      }
      // Assume first row is header
      final header = rows.first.map((e) => e.toString().trim()).toList();
      for (int i = 1; i < rows.length; i++) {
        final row = rows[i];
        if (row.isEmpty) continue;
        final data = Map<String, dynamic>.fromIterables(header, row);
        final boxId = data['id']?.toString() ?? data['Box ID']?.toString();
        if (boxId == null || boxId.isEmpty) continue;
        await FirebaseFirestore.instance.collection('bee_boxes').doc(boxId).set({
          'id': boxId,
          'name': data['name'] ?? data['Name'] ?? '',
          'status': data['status'] ?? data['Status'] ?? 'Available',
          'price': double.tryParse(data['price']?.toString() ?? data['Price']?.toString() ?? '0') ?? 0,
          'notes': data['notes'] ?? data['Notes'] ?? '',
          'count': int.tryParse(data['count']?.toString() ?? data['Count']?.toString() ?? '0') ?? 0,
          'lastMaintenance': data['lastMaintenance'] ?? data['Last Maintenance'] ?? '',
        }, SetOptions(merge: true));
      }
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Bee boxes imported successfully!')));
      setState(() {});
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Import failed: $e')));
    }
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
                  tooltip: l10n('edit'),
                ),
                IconButton(
                  icon: const Icon(Icons.delete, color: Colors.red),
                  onPressed: () => _deleteBeeBox(beeBox.id),
                  tooltip: l10n('delete'),
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
    String statusText = l10n(status);
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

String l10n(String text) => text; // Placeholder for localization