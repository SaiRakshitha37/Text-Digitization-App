import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:flutter/services.dart';

import '../models/text_model.dart';
import '../widgets/sidebar.dart';

class SavedDocumentsScreen extends StatefulWidget {
  final Box<TextModel> box;

  const SavedDocumentsScreen({Key? key, required this.box}) : super(key: key);

  @override
  _SavedDocumentsScreenState createState() => _SavedDocumentsScreenState();
}

class _SavedDocumentsScreenState extends State<SavedDocumentsScreen> {
  List<TextModel> _texts = [];
  List<TextModel> _filteredTexts = [];
  late TextEditingController _searchController;

  @override
  void initState() {
    super.initState();
    _searchController = TextEditingController();
    _loadTextsFromServer(); // Load without password check
  }

  Future<void> _loadTextsFromServer() async {
    try {
      final response = await http.get(Uri.parse('http://192.168.120.159:3000/api/getSavedTexts'));
      // final response = await http.get(Uri.parse('http://192.168.29.162:3000/api/getSavedTexts'));

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        final loadedTexts = data.map((json) => TextModel.fromJson(json)).toList();

        setState(() {
          _texts = loadedTexts;
          _filteredTexts = _texts.where((t) => !t.isDeleted).toList();
        });
      } else {
        _showMessage('Failed to load texts');
      }
    } catch (e) {
      _showMessage('Error: $e');
    }
  }
  void _searchDocuments(String query) {
  final queryLower = query.toLowerCase();
  setState(() {
    _filteredTexts = _texts.where((t) =>
      !t.isDeleted &&
      (t.name.toLowerCase().contains(queryLower) ||
       t.content.toLowerCase().contains(queryLower))
    ).toList();
  });
}


  // void _searchDocuments(String query) {
  //   final queryLower = query.toLowerCase();
  //   setState(() {
  //     _filteredTexts = _texts
  //         .where((t) => !t.isDeleted && t.name.toLowerCase().contains(queryLower))
  //         .toList();
  //   });
  // }

  void _showMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
  }

  void _copyText(TextModel text) {
    Clipboard.setData(ClipboardData(text: text.content));
    _showMessage('Text copied to clipboard');
  }

  Future<void> _deleteText(int index) async {
    final textToDelete = _filteredTexts[index];
    final realIndex = _texts.indexWhere((t) => t.name == textToDelete.name);

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text("Delete Document"),
        content: const Text("Are you sure you want to delete this document?"),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text("Cancel")),
          ElevatedButton(onPressed: () => Navigator.pop(context, true), child: const Text("Delete")),
        ],
      ),
    );

    if (confirmed == true) {
      setState(() {
        _texts[realIndex].isDeleted = true;
        _filteredTexts.removeAt(index);
      });
      await widget.box.put(_texts[realIndex].name, _texts[realIndex]);
      _showMessage('Document moved to trash');
    }
  }

  Future<void> _renameText(int index) async {
    final originalName = _filteredTexts[index].name;
    final controller = TextEditingController(text: originalName);

    await showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text("Rename Document"),
        content: TextField(
          controller: controller,
          decoration: const InputDecoration(hintText: "New document name"),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text("Cancel")),
          ElevatedButton(
            onPressed: () async {
              final newName = controller.text.trim();
              if (newName.isEmpty || _texts.any((t) => t.name == newName && t.name != originalName)) {
                _showMessage("Name already exists or is invalid.");
                return;
              }

              final realIndex = _texts.indexWhere((t) => t.name == originalName);
              if (realIndex != -1) {
                final updated = _texts[realIndex];
                updated.name = newName;
                await widget.box.delete(originalName);
                await widget.box.put(newName, updated);
              }

              setState(() {
                _filteredTexts[index].name = newName;
              });

              Navigator.pop(context);
              _showMessage("Document renamed");
            },
            child: const Text("Save"),
          ),
        ],
      ),
    );
  }

  Future<void> _editText(int index) async {
    final controller = TextEditingController(text: _filteredTexts[index].content);

    await showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text("Edit Text"),
        content: TextField(
          controller: controller,
          maxLines: 10,
          decoration: const InputDecoration(hintText: "Edit your text here"),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text("Cancel")),
          ElevatedButton(
            onPressed: () async {
              final updatedText = controller.text.trim();
              final realIndex = _texts.indexWhere((t) => t.name == _filteredTexts[index].name);

              if (realIndex != -1) {
                setState(() {
                  _texts[realIndex].content = updatedText;
                  _filteredTexts[index].content = updatedText;
                });
                await widget.box.put(_texts[realIndex].name, _texts[realIndex]);
              }

              Navigator.pop(context);
              _showMessage("Document updated");
            },
            child: const Text("Save"),
          ),
        ],
      ),
    );
  }

  void _restoreText(int index) async {
    final textToRestore = _filteredTexts[index];
    final realIndex = _texts.indexWhere((t) => t.name == textToRestore.name);

    textToRestore.isDeleted = false;
    await widget.box.put(textToRestore.name, textToRestore);

    setState(() {
      _texts[realIndex] = textToRestore;
      _filteredTexts.removeAt(index);
    });

    _showMessage('Restored "${textToRestore.name}"');
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: Sidebar(box: widget.box),
      appBar: AppBar(
        title: const Text('Saved Documents'),
        backgroundColor: Colors.lightBlue.shade700,
      ),
      body: Container(
        color: Colors.blue.shade50,
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            TextField(
              controller: _searchController,
              onChanged: _searchDocuments,
              decoration: InputDecoration(
                prefixIcon: const Icon(Icons.search),
                hintText: 'Search documents...',
                filled: true,
                fillColor: Colors.white,
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
              ),
            ),
            const SizedBox(height: 16),
            Expanded(
              child: _filteredTexts.isEmpty
                  ? const Center(child: Text('No documents found.'))
                  : ListView.builder(
                      itemCount: _filteredTexts.length,
                      itemBuilder: (context, index) {
                        final text = _filteredTexts[index];
                        return Card(
                          key: ValueKey(text.name),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                          elevation: 4,
                          margin: const EdgeInsets.symmetric(vertical: 8),
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
                            onTap: () {
                              _editText(index); // Open document on tap
                            },
                            trailing: PopupMenuButton<String>(
                              onSelected: (value) {
                                switch (value) {
                                  case 'Edit':
                                    _editText(index);
                                    break;
                                  case 'Rename':
                                    _renameText(index);
                                    break;
                                  case 'Copy':
                                    _copyText(text);
                                    break;
                                  case 'Delete':
                                    _deleteText(index);
                                    break;
                                }
                              },
                              itemBuilder: (context) => [
                                const PopupMenuItem(value: 'Edit', child: Text('Edit')),
                                const PopupMenuItem(value: 'Rename', child: Text('Rename')),
                                const PopupMenuItem(value: 'Copy', child: Text('Copy')),
                                const PopupMenuItem(value: 'Delete', child: Text('Delete')),
                              ],
                            ),
                          ),
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