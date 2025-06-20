import 'dart:async';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:path_provider/path_provider.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart'; // Import for clearing token
import 'models/user_model.dart';
import 'models/text_model.dart';
import 'screens/login_screen.dart';
import 'screens/create_profile_screen.dart';
import 'profile_manager.dart';

Future<Box<TextModel>> _initializeHive() async {
  if (!kIsWeb) {
    final appDocDir = await getApplicationDocumentsDirectory();
    await Hive.initFlutter(appDocDir.path);
    debugPrint('Hive initialized for native at: ${appDocDir.path}');
  } else {
    await Hive.initFlutter();
    debugPrint('Hive initialized for web');
  }
  Hive.registerAdapter(TextModelAdapter());
  Hive.registerAdapter(UserModelAdapter());
  await Hive.openBox<UserModel>('users');
  final box = await Hive.openBox<TextModel>('text_model');
  debugPrint('Box opened, size: ${box.length}');
  return box;
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  if (kIsWeb) {
    await Firebase.initializeApp(
      options: const FirebaseOptions(
        apiKey: "AIzaSyDvmcsqJaz0kUBBCyjVGwhd2wJIMcGiKEU",
        authDomain: "mediscan-textdigitizer-d37ad.firebaseapp.com",
        projectId: "mediscan-textdigitizer-d37ad",
        storageBucket: "mediscan-textdigitizer-d37ad.appspot.com",
        messagingSenderId: "189601133833",
        appId: "1:189601133833:web:d3822fa00ffb0076e44fd8",
        measurementId: "G-SNLZL9VK6Q",
      ),
    );
  }

  // Clear the token in SharedPreferences on app start
  final prefs = await SharedPreferences.getInstance();
  await prefs.remove('token');

  final boxFuture = _initializeHive();

  runApp(
    ChangeNotifierProvider(
      create: (_) => ProfileManager(),
      child: MediScanApp(boxFuture: boxFuture),
    ),
  );
}

class MediScanApp extends StatelessWidget {
  final Future<Box<TextModel>> boxFuture;

  const MediScanApp({Key? key, required this.boxFuture}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'MediScan',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.indigo,
        textTheme: GoogleFonts.notoSansTextTheme(
          Theme.of(context).textTheme,
        ),
      ),
      routes: {
        '/createProfile': (_) => CreateProfileScreen(),
      },
      home: SplashScreen(boxFuture: boxFuture),
    );
  }
}

class SplashScreen extends StatefulWidget {
  final Future<Box<TextModel>> boxFuture;
  const SplashScreen({Key? key, required this.boxFuture}) : super(key: key);

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with TickerProviderStateMixin {
  late AnimationController _dropController;
  late Animation<Offset> _logoDrop;
  late AnimationController _fadeController;
  late Animation<double> _fadeIn;
  late AnimationController _scanController;
  double _scanY = 0;
  late AnimationController _bgController;
  late Animation<Color?> _bgColor;

  @override
  void initState() {
    super.initState();
    _dropController = AnimationController(
      duration: const Duration(milliseconds: 900),
      vsync: this,
    );
    _logoDrop = Tween<Offset>(begin: const Offset(0, -2), end: Offset.zero)
        .animate(
            CurvedAnimation(parent: _dropController, curve: Curves.bounceOut));
    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 700),
      vsync: this,
    );
    _fadeIn = Tween<double>(begin: 0, end: 1).animate(_fadeController);
    _scanController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..addListener(() {
        setState(() {
          _scanY = _scanController.value * 100;
        });
      });
    _bgController = AnimationController(
      duration: const Duration(seconds: 5),
      vsync: this,
    )..repeat(reverse: true);
    _bgColor = ColorTween(
      begin: const Color(0xFF00C9A7),
      end: const Color(0xFFB2FEFA),
    ).animate(_bgController);

    _startSequence();
  }

  Future<void> _startSequence() async {
    await _dropController.forward();
    await _fadeController.forward();
    await _scanController.forward();
    await Future.delayed(const Duration(milliseconds: 700));

    final box = await widget.boxFuture;
    if (mounted) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => LoginScreen()),
      );
    }
  }

  @override
  void dispose() {
    _dropController.dispose();
    _fadeController.dispose();
    _scanController.dispose();
    _bgController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _bgColor,
      builder: (context, child) {
        return Scaffold(
          backgroundColor: _bgColor.value,
          body: Stack(
            children: [
              Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    SlideTransition(
                      position: _logoDrop,
                      child: const Icon(Icons.document_scanner,
                          size: 70, color: Colors.white),
                    ),
                    const SizedBox(height: 30),
                    FadeTransition(
                      opacity: _fadeIn,
                      child: Column(
                        children: [
                          const Text(
                            "MEDISCAN",
                            style: TextStyle(
                              fontSize: 28,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                              letterSpacing: 2,
                            ),
                          ),
                          const SizedBox(height: 30),
                          buildPaperScanner(),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              Positioned(
                top: 40,
                right: 20,
                child: TextButton(
                  onPressed: () async {
                    final box = await widget.boxFuture;
                    if (!mounted) return;
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(
                        builder: (context) => LoginScreen(),
                      ),
                    );
                  },
                  style: TextButton.styleFrom(
                    backgroundColor: Colors.white.withOpacity(0.2),
                    foregroundColor: Colors.white,
                    padding:
                        const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30),
                    ),
                  ),
                  child: const Text("Skip"),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget buildPaperScanner() {
    return Stack(
      alignment: Alignment.topCenter,
      children: [
        Container(
          width: 140,
          height: 100,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(6),
            boxShadow: [
              BoxShadow(
                color: Colors.black12,
                blurRadius: 6,
                offset: Offset(0, 2),
              ),
            ],
          ),
          child: const Icon(Icons.description, size: 40, color: Colors.grey),
        ),
        Positioned(
          top: _scanY,
          child: Container(
            width: 120,
            height: 4,
            decoration: BoxDecoration(
              color: Colors.lightGreenAccent,
              borderRadius: BorderRadius.circular(4),
            ),
          ),
        ),
      ],
    );
  }
}
