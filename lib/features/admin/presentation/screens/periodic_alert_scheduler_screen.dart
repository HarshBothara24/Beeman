import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class PeriodicAlertSchedulerScreen extends StatefulWidget {
  const PeriodicAlertSchedulerScreen({super.key});

  @override
  State<PeriodicAlertSchedulerScreen> createState() => _PeriodicAlertSchedulerScreenState();
}

class _PeriodicAlertSchedulerScreenState extends State<PeriodicAlertSchedulerScreen> {
  final _formKey = GlobalKey<FormState>();
  final _typeController = TextEditingController();
  final _daysController = TextEditingController();
  bool _isBefore = true;
  bool _enabled = true;
  String? _editingId;

  @override
  void dispose() {
    _typeController.dispose();
    _daysController.dispose();
    super.dispose();
  }

  Future<void> _saveAlert() async {
    if (!_formKey.currentState!.validate()) return;
    try {
      final data = {
        'type': _typeController.text.trim(),
        'days': int.tryParse(_daysController.text.trim()) ?? 0,
        'isBefore': _isBefore,
        'enabled': _enabled,
        'updatedAt': DateTime.now(),
      };
      if (_editingId != null) {
        await FirebaseFirestore.instance.collection('alert_schedules').doc(_editingId).update(data);
      } else {
        await FirebaseFirestore.instance.collection('alert_schedules').add(data);
      }
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Alert schedule saved!')));
      _resetForm();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Save failed: $e')));
    }
  }

  void _editAlert(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    setState(() {
      _editingId = doc.id;
      _typeController.text = data['type'] ?? '';
      _daysController.text = (data['days'] ?? '').toString();
      _isBefore = data['isBefore'] ?? true;
      _enabled = data['enabled'] ?? true;
    });
  }

  Future<void> _deleteAlert(String id) async {
    try {
      await FirebaseFirestore.instance.collection('alert_schedules').doc(id).delete();
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Alert deleted.')));
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Delete failed: $e')));
    }
  }

  void _resetForm() {
    setState(() {
      _editingId = null;
      _typeController.clear();
      _daysController.clear();
      _isBefore = true;
      _enabled = true;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Periodic Alert Scheduler')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Form(
              key: _formKey,
              child: Column(
                children: [
                  TextFormField(
                    controller: _typeController,
                    decoration: const InputDecoration(labelText: 'Alert Type (e.g. Care Reminder)'),
                    validator: (v) => v == null || v.trim().isEmpty ? 'Enter alert type' : null,
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Expanded(
                        child: TextFormField(
                          controller: _daysController,
                          keyboardType: TextInputType.number,
                          decoration: const InputDecoration(labelText: 'Days Before/After'),
                          validator: (v) => v == null || v.trim().isEmpty ? 'Enter days' : null,
                        ),
                      ),
                      const SizedBox(width: 8),
                      DropdownButton<bool>(
                        value: _isBefore,
                        items: const [
                          DropdownMenuItem(value: true, child: Text('Before')),
                          DropdownMenuItem(value: false, child: Text('After')),
                        ],
                        onChanged: (v) => setState(() => _isBefore = v ?? true),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  SwitchListTile(
                    value: _enabled,
                    onChanged: (v) => setState(() => _enabled = v),
                    title: const Text('Enabled'),
                  ),
                  Row(
                    children: [
                      ElevatedButton(
                        onPressed: _saveAlert,
                        child: Text(_editingId == null ? 'Add Alert' : 'Save Changes'),
                      ),
                      const SizedBox(width: 8),
                      if (_editingId != null)
                        TextButton(
                          onPressed: _resetForm,
                          child: const Text('Cancel'),
                        ),
                    ],
                  ),
                ],
              ),
            ),
            const Divider(height: 32),
            Expanded(
              child: StreamBuilder<QuerySnapshot>(
                stream: FirebaseFirestore.instance.collection('alert_schedules').orderBy('updatedAt', descending: true).limit(50).snapshots(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }
                  final docs = snapshot.data?.docs ?? [];
                  if (docs.isEmpty) {
                    return const Center(child: Text('No scheduled alerts.'));
                  }
                  return ListView.builder(
                    itemCount: docs.length,
                    itemBuilder: (context, i) {
                      final doc = docs[i];
                      final data = doc.data() as Map<String, dynamic>;
                      return Card(
                        child: ListTile(
                          title: Text('${data['type']} (${data['days']} days ${data['isBefore'] ? 'before' : 'after'})'),
                          subtitle: Text('Enabled: ${data['enabled'] ? 'Yes' : 'No'}'),
                          trailing: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              IconButton(
                                icon: const Icon(Icons.edit),
                                onPressed: () => _editAlert(doc),
                              ),
                              IconButton(
                                icon: const Icon(Icons.delete),
                                onPressed: () => _deleteAlert(doc.id),
                              ),
                            ],
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
} 