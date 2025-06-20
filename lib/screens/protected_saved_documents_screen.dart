import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import '../models/text_model.dart';
import '../services/password_service.dart';
import 'saved_documents_screen.dart';

class ProtectedSavedDocumentsScreen extends StatelessWidget {
  final Box<TextModel> box;

  const ProtectedSavedDocumentsScreen({super.key, required this.box});

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<String?>(
      future: PasswordService.getPassword(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        final savedPassword = snapshot.data;

        if (savedPassword == null || savedPassword.isEmpty) {
          return SavedDocumentsScreen(box: box); // No password set
        }

        return _PasswordPromptScreen(box: box, savedPassword: savedPassword);
      },
    );
  }
}

class _PasswordPromptScreen extends StatefulWidget {
  final Box<TextModel> box;
  final String savedPassword;

  const _PasswordPromptScreen({required this.box, required this.savedPassword});

  @override
  State<_PasswordPromptScreen> createState() => _PasswordPromptScreenState();
}

class _PasswordPromptScreenState extends State<_PasswordPromptScreen> {
  final TextEditingController _controller = TextEditingController();
  String? _error;

  void _checkPassword() {
    if (_controller.text.trim() == widget.savedPassword) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => SavedDocumentsScreen(box: widget.box)),
      );
    } else {
      setState(() {
        _error = "Incorrect password.";
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Password Required")),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          children: [
            const Text("Enter your app password to access saved documents:"),
            const SizedBox(height: 20),
            TextField(
              controller: _controller,
              obscureText: true,
              decoration: InputDecoration(
                labelText: "Password",
                errorText: _error,
              ),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: _checkPassword,
              child: const Text("Unlock"),
            ),
          ],
        ),
      ),
    );
  }
}
