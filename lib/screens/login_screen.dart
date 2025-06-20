import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:hive/hive.dart';
import 'package:provider/provider.dart';
import 'text_extractor_screen.dart';
import 'register_screen.dart';
import '../models/text_model.dart';
import '../user_profile.dart';
import '../profile_manager.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final FocusNode _passwordFocusNode = FocusNode();
  late Box<TextModel> _box;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _initHive().then((_) {
      checkLoginStatus();
    });
  }

  Future<void> _initHive() async {
    try {
      _box = await Hive.openBox<TextModel>('text_model');
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to initialize storage: $e')),
        );
      }
    }
  }

  Future<void> loginUser() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final url = Uri.parse("http://192.168.120.159:3000/login");
      // final url = Uri.parse("http:// 192.168.29.162:3000/login");
      final response = await http.post(
        url,
        body: jsonEncode({
          "email": emailController.text.trim(),
          "password": passwordController.text.trim(),
        }),
        headers: {"Content-Type": "application/json"},
      ).timeout(const Duration(seconds: 10), onTimeout: () {
        throw Exception('Request timed out');
      });

      final data = jsonDecode(response.body);
      print("API Response: $data"); // Debug: Log API response

      if (response.statusCode == 200) {
        SharedPreferences prefs = await SharedPreferences.getInstance();
        // Clear existing data to avoid stale values
        await prefs.clear();
        await prefs.setString("token", data["token"]);
        // Save name and email from API response, with a fallback
        await prefs.setString("name", data["name"] ?? emailController.text.split('@')[0]);
        await prefs.setString("email", data["email"] ?? emailController.text.trim());

        // Retrieve name and email
        String? name = prefs.getString("name");
        String? email = prefs.getString("email");
        print("Stored in SharedPreferences: name=$name, email=$email"); // Debug: Log stored values

        if (name != null && email != null) {
          final profileManager = Provider.of<ProfileManager>(context, listen: false);
          final avatarLetter = name.isNotEmpty ? name[0].toUpperCase() : 'A';
          final profile = UserProfile(
            name: name,
            email: email,
            password: passwordController.text.trim(),
            avatarLetter: avatarLetter,
          );
          profileManager.setProfile(profile);
          print("Set in ProfileManager: $profile"); // Debug: Log profile set
        }

        if (mounted) {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => TextExtractorScreen(box: _box)), // Pass the box parameter
          );
        }
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(data["message"] ?? 'Login failed')),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e')),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  Future<void> checkLoginStatus() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? token = prefs.getString("token");
    if (token != null) {
      final profileManager = Provider.of<ProfileManager>(context, listen: false);
      if (profileManager.profile == null) {
        String? name = prefs.getString("name");
        String? email = prefs.getString("email");
        if (name != null && email != null) {
          final avatarLetter = name.isNotEmpty ? name[0].toUpperCase() : 'A';
          final profile = UserProfile(
            name: name,
            email: email,
            password: '',
            avatarLetter: avatarLetter,
          );
          profileManager.setProfile(profile);
        }
      }
      if (mounted) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => TextExtractorScreen(box: _box)), // Pass the box parameter
        );
      }
    }
  }

  @override
  void dispose() {
    emailController.dispose();
    passwordController.dispose();
    _passwordFocusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Login"),
        backgroundColor: const Color.fromARGB(255, 33, 173, 149),
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Card(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(15),
            ),
            elevation: 5,
            child: Padding(
              padding: const EdgeInsets.all(20.0),
              child: RawKeyboardListener(
                focusNode: FocusNode(),
                onKey: (RawKeyEvent event) {
                  if (event is RawKeyDownEvent && event.logicalKey == LogicalKeyboardKey.enter) {
                    loginUser();
                  }
                },
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Text(
                      "Welcome Back!",
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: const Color.fromARGB(255, 33, 173, 149),
                      ),
                    ),
                    const SizedBox(height: 20),
                    TextField(
                      controller: emailController,
                      decoration: InputDecoration(
                        labelText: "Email",
                        prefixIcon: Icon(Icons.email, color: const Color.fromARGB(255, 33, 173, 149)),
                        border: const OutlineInputBorder(),
                      ),
                      keyboardType: TextInputType.emailAddress,
                      textInputAction: TextInputAction.next,
                      onSubmitted: (_) {
                        FocusScope.of(context).requestFocus(_passwordFocusNode);
                      },
                    ),
                    const SizedBox(height: 10),
                    TextField(
                      controller: passwordController,
                      focusNode: _passwordFocusNode,
                      decoration: InputDecoration(
                        labelText: "Password",
                        prefixIcon: Icon(Icons.lock, color: const Color.fromARGB(255, 33, 173, 149)),
                        border: const OutlineInputBorder(),
                      ),
                      obscureText: true,
                      onSubmitted: (_) => loginUser(),
                    ),
                    const SizedBox(height: 20),
                    _isLoading
                        ? Center(child: CircularProgressIndicator(color: const Color.fromARGB(255, 33, 173, 149)))
                        : ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color.fromARGB(255, 33, 173, 149),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                              padding: const EdgeInsets.symmetric(vertical: 12),
                            ),
                            onPressed: loginUser,
                            child: const Text(
                              "Login",
                              style: TextStyle(fontSize: 18, color: Colors.white),
                            ),
                          ),
                    const SizedBox(height: 10),
                    TextButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => const RegisterScreen()),
                        );
                      },
                      child: Text(
                        "Don't have an account? Register",
                        style: TextStyle(color: const Color.fromARGB(255, 33, 173, 149)),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
// ------------------------------------------------------------------
