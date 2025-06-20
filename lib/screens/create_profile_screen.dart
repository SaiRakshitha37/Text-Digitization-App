
// --------------------------------------------------------------------------------
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart'; // Add for SharedPreferences
import '../user_profile.dart';
import '../profile_manager.dart';

class CreateProfileScreen extends StatefulWidget {
  @override
  _CreateProfileScreenState createState() => _CreateProfileScreenState();
}

class _CreateProfileScreenState extends State<CreateProfileScreen> {
  final nameController = TextEditingController();
  final emailController = TextEditingController();
  String selectedLetter = 'A';

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final profile = Provider.of<ProfileManager>(context, listen: false).profile;
    if (profile != null) {
      nameController.text = profile.name;
      emailController.text = profile.email;
      selectedLetter = profile.avatarLetter;
    }
  }

  Future<void> saveProfile() async {
    final profile = UserProfile(
      name: nameController.text.trim(),
      email: emailController.text.trim(),
      password: '', // Password not edited here; can be managed elsewhere
      avatarLetter: selectedLetter,
    );

    // Update ProfileManager
    Provider.of<ProfileManager>(context, listen: false).setProfile(profile);

    // Update SharedPreferences to keep data in sync
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('name', profile.name);
    await prefs.setString('email', profile.email);

    Navigator.pop(context);
  }

  @override
  void dispose() {
    nameController.dispose();
    emailController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Edit Your Profile")),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              TextField(
                controller: nameController,
                decoration: const InputDecoration(
                  labelText: "Name",
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: emailController,
                decoration: const InputDecoration(
                  labelText: "Email",
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.emailAddress,
              ),
              const SizedBox(height: 20),
              const Text(
                "Choose a letter for your avatar:",
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 10),
              Wrap(
                spacing: 10,
                runSpacing: 10,
                children: List.generate(26, (i) {
                  final letter = String.fromCharCode(65 + i);
                  return GestureDetector(
                    onTap: () => setState(() => selectedLetter = letter),
                    child: CircleAvatar(
                      backgroundColor: selectedLetter == letter ? Colors.teal : Colors.grey[300],
                      child: Text(
                        letter,
                        style: TextStyle(
                          color: selectedLetter == letter ? Colors.white : Colors.black,
                        ),
                      ),
                    ),
                  );
                }),
              ),
              const SizedBox(height: 20),
              Center(
                child: ElevatedButton(
                  onPressed: saveProfile,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blueAccent,
                    padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  child: const Text(
                    "Save Profile",
                    style: TextStyle(fontSize: 18, color: Colors.white),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
