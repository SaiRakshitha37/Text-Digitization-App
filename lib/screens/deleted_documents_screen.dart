import 'package:flutter/material.dart';
import 'package:hive/hive.dart';

import '../models/text_model.dart';
import '../widgets/sidebar.dart';

class DeletedDocumentsScreen extends StatefulWidget {
  final Box<TextModel> box;

  const DeletedDocumentsScreen({Key? key, required this.box}) : super(key: key);

  @override
  _DeletedDocumentsScreenState createState() => _DeletedDocumentsScreenState();
}

class _DeletedDocumentsScreenState extends State<DeletedDocumentsScreen> {
  List<TextModel> _deletedTexts = [];

  @override
  void initState() {
    super.initState();
    _loadDeletedTexts();
  }

  void _loadDeletedTexts() {
    final allTexts = widget.box.values.toList();
    setState(() {
      _deletedTexts = allTexts.where((text) => text.isDeleted).toList();
    });
  }

  Future<void> _restoreText(int index) async {
    final text = _deletedTexts[index];
    text.isDeleted = false;
    await text.save();
    _loadDeletedTexts();
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Document restored')),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: Sidebar(box: widget.box),
      appBar: AppBar(
        title: const Text('Deleted Documents'),
        backgroundColor: Colors.red.shade700,
        actions: [
          PopupMenuButton<String>(
            onSelected: (value) {
              if (value == 'exit') {
                Scaffold.of(context).openDrawer();
              }
            },
            itemBuilder: (context) => [
              const PopupMenuItem(value: 'exit', child: Text('Exit')),
            ],
          ),
        ],
      ),
      body: _deletedTexts.isEmpty
          ? const Center(child: Text('No deleted documents found.'))
          : ListView.builder(
              itemCount: _deletedTexts.length,
              itemBuilder: (context, index) {
                final text = _deletedTexts[index];
                return Card(
                  margin:
                      const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
                  child: ListTile(
                    title: Text(
                      text.name,
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    subtitle: Text(
                      text.content.length > 100
                          ? '${text.content.substring(0, 100)}...'
                          : text.content,
                    ),
                    trailing: PopupMenuButton<String>(
                      onSelected: (value) {
                        if (value == 'restore') {
                          _restoreText(index);
                        }
                      },
                      itemBuilder: (context) => [
                        const PopupMenuItem(
                            value: 'restore', child: Text('Restore')),
                      ],
                    ),
                  ),
                );
              },
            ),
    );
  }
}