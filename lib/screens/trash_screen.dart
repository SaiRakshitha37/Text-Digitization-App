
import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import '../models/text_model.dart';

class TrashScreen extends StatefulWidget {
  final Box<TextModel> textBox;

  const TrashScreen({Key? key, required this.textBox}) : super(key: key);

  @override
  State<TrashScreen> createState() => _TrashScreenState();
}

class _TrashScreenState extends State<TrashScreen> {
  List<TextModel> _trashedTexts = [];

  @override
  void initState() {
    super.initState();
    _loadTrashTexts();
    widget.textBox.watch().listen((_) => _loadTrashTexts());
  }

  void _loadTrashTexts() {
    final texts = widget.textBox.values.where((text) => text.isDeleted).toList();
    setState(() {
      _trashedTexts = texts;
    });
  }

  void _restoreText(TextModel text) async {
  text.isDeleted = false;
  await widget.textBox.put(text.name, text); // ✅ Save updated document

  ScaffoldMessenger.of(context).showSnackBar(
    const SnackBar(content: Text('Restored successfully')),
  );

  _loadTrashTexts(); // Refresh trash screen
}
void _deleteForever(TextModel text) async {
  await widget.textBox.delete(text.name); // ✅ Remove from Hive permanently

  ScaffoldMessenger.of(context).showSnackBar(
    const SnackBar(content: Text('Document deleted permanently')),
  );

  _loadTrashTexts(); // Refresh list
}


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Trash Bin")),
      body: _trashedTexts.isEmpty
          ? Center(child: Text("Trash is empty"))
          : ListView.builder(
              itemCount: _trashedTexts.length,
              itemBuilder: (context, index) {
                final text = _trashedTexts[index];
                return Card(
                  margin: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  child: ListTile(
                    title: Text(text.name),
                    subtitle: Text(text.content),
                    trailing: Row(
  mainAxisSize: MainAxisSize.min,
  children: [
    IconButton(
      icon: Icon(Icons.restore),
      tooltip: "Restore",
      onPressed: () => _restoreText(text),
    ),
    IconButton(
      icon: Icon(Icons.delete_forever),
      tooltip: "Delete Forever",
      onPressed: () => _deleteForever(text),
    ),
  ],
),

                  ),
                );
              },
            ),
    );
  }
}
