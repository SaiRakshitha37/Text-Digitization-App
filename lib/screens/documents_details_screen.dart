import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import '../models/text_model.dart';

class DocumentDetailScreen extends StatefulWidget {
  final TextModel document;
  final int index;
  final Box<TextModel> box;
  final String customKey; // Renamed parameter

  const DocumentDetailScreen({
    Key? key,  // Use the super keyword for Flutter's built-in key
    required this.document,
    required this.index,
    required this.box,
    required this.customKey, // Changed key to customKey
  }); 

  @override
  _DocumentDetailScreenState createState() => _DocumentDetailScreenState();
}

class _DocumentDetailScreenState extends State<DocumentDetailScreen> {
  late TextEditingController _nameController;
  late TextEditingController _contentController;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.document.name);
    _contentController = TextEditingController(text: widget.document.content);
  }

  @override
  void dispose() {
    _nameController.dispose();
    _contentController.dispose();
    super.dispose();
  }

  void _saveDocument() async {
    try {
      final updatedDocument = TextModel(
        name: _nameController.text,
        content: _contentController.text,
        dateTime: widget.document.dateTime,
      );
      await widget.box.putAt(widget.index, updatedDocument);
      debugPrint(
          'Saved updated document: name=${_nameController.text}, content=${_contentController.text}');
      Navigator.pop(context, updatedDocument); // Return the updated document
    } catch (e) {
      debugPrint('Save error: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Save failed: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Edit Document'),
        actions: [
          IconButton(
            icon: const Icon(Icons.save),
            onPressed: _saveDocument,
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: _nameController,
              decoration: const InputDecoration(labelText: 'Name'),
            ),
            TextField(
              controller: _contentController,
              maxLines: 10,
              decoration: const InputDecoration(labelText: 'Content'),
            ),
          ],
        ),
      ),
    );
  }
}