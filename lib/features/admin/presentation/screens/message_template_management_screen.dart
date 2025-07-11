import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class MessageTemplateManagementScreen extends StatefulWidget {
  const MessageTemplateManagementScreen({super.key});

  @override
  State<MessageTemplateManagementScreen> createState() => _MessageTemplateManagementScreenState();
}

class _MessageTemplateManagementScreenState extends State<MessageTemplateManagementScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _bodyController = TextEditingController();
  String? _editingId;

  @override
  void dispose() {
    _nameController.dispose();
    _bodyController.dispose();
    super.dispose();
  }

  Future<void> _saveTemplate() async {
    if (!_formKey.currentState!.validate()) return;
    try {
      final data = {
        'name': _nameController.text.trim(),
        'body': _bodyController.text.trim(),
        'updatedAt': DateTime.now(),
      };
      if (_editingId != null) {
        await FirebaseFirestore.instance.collection('message_templates').doc(_editingId).update(data);
      } else {
        await FirebaseFirestore.instance.collection('message_templates').add(data);
      }
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Template saved!')));
      _resetForm();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Save failed: $e')));
    }
  }

  void _editTemplate(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    setState(() {
      _editingId = doc.id;
      _nameController.text = data['name'] ?? '';
      _bodyController.text = data['body'] ?? '';
    });
  }

  Future<void> _deleteTemplate(String id) async {
    try {
      await FirebaseFirestore.instance.collection('message_templates').doc(id).delete();
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Template deleted.')));
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Delete failed: $e')));
    }
  }

  void _resetForm() {
    setState(() {
      _editingId = null;
      _nameController.clear();
      _bodyController.clear();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Message Templates')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Form(
              key: _formKey,
              child: Column(
                children: [
                  TextFormField(
                    controller: _nameController,
                    decoration: const InputDecoration(labelText: 'Template Name'),
                    validator: (v) => v == null || v.trim().isEmpty ? 'Enter a name' : null,
                  ),
                  const SizedBox(height: 8),
                  TextFormField(
                    controller: _bodyController,
                    maxLines: 4,
                    decoration: const InputDecoration(labelText: 'Message Body'),
                    validator: (v) => v == null || v.trim().isEmpty ? 'Enter a message' : null,
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      ElevatedButton(
                        onPressed: _saveTemplate,
                        child: Text(_editingId == null ? 'Add Template' : 'Save Changes'),
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
                stream: FirebaseFirestore.instance.collection('message_templates').orderBy('updatedAt', descending: true).snapshots(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }
                  final docs = snapshot.data?.docs ?? [];
                  if (docs.isEmpty) {
                    return const Center(child: Text('No templates found.'));
                  }
                  return ListView.builder(
                    itemCount: docs.length,
                    itemBuilder: (context, i) {
                      final doc = docs[i];
                      final data = doc.data() as Map<String, dynamic>;
                      return Card(
                        child: ListTile(
                          title: Text(data['name'] ?? ''),
                          subtitle: Text(data['body'] ?? '', maxLines: 2, overflow: TextOverflow.ellipsis),
                          trailing: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              IconButton(
                                icon: const Icon(Icons.edit),
                                onPressed: () => _editTemplate(doc),
                              ),
                              IconButton(
                                icon: const Icon(Icons.delete),
                                onPressed: () => _deleteTemplate(doc.id),
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