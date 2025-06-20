
// import 'package:flutter/material.dart';
// import 'package:google_fonts/google_fonts.dart';
// import 'package:google_sign_in/google_sign_in.dart';
// import 'package:hive/hive.dart';
// import '../models/text_model.dart';
// import '../models/user_model.dart';
// import 'text_extractor_screen.dart';
// import 'package:text_digitization_app/services/auth_service.dart';

// class WelcomeScreen extends StatefulWidget {
//   final Box<TextModel> box;

//   const WelcomeScreen({super.key, required this.box});

//   @override
//   State<WelcomeScreen> createState() => _WelcomeScreenState();
// }

// class _WelcomeScreenState extends State<WelcomeScreen> {
//   final TextEditingController emailController = TextEditingController();
//   final TextEditingController passwordController = TextEditingController();

//   final GoogleSignIn _googleSignIn = GoogleSignIn(
//     clientId:
//         '148854509440-kn285oqvob9hn3vku4r0fnm0alnkg93a.apps.googleusercontent.com',
//   );
//   // final GoogleSignIn _googleSignIn = GoogleSignIn(
//   // scopes: ['email'],
//   // clientId: Platform.isAndroid
//   //     ? '148854509440-dvk3k7iup0tfg1n5b3b9u8pbf0k3usv2.apps.googleusercontent.com' // Android
//   // );


//   void _createProfile(BuildContext context) async {
//     final email = emailController.text.trim();
//     final password = passwordController.text.trim();

//     final emailRegex = RegExp(r'^[^@]+@[^@]+\.[^@]+');
//     if (email.isEmpty || password.isEmpty) {
//       ScaffoldMessenger.of(context).showSnackBar(
//         const SnackBar(content: Text('Please enter email and password')),
//       );
//       return;
//     }

//     if (!emailRegex.hasMatch(email)) {
//       ScaffoldMessenger.of(context).showSnackBar(
//         const SnackBar(content: Text('Please enter a valid email address')),
//       );
//       return;
//     }

//     if (password.length < 8) {
//       ScaffoldMessenger.of(context).showSnackBar(
//         const SnackBar(
//             content: Text('Password must be at least 8 characters long')),
//       );
//       return;
//     }

//     final userBox = Hive.box<UserModel>('users');

//     UserModel? existingUser;
//     try {
//       existingUser =
//           userBox.values.firstWhere((user) => user.email == email);
//     } catch (e) {
//       existingUser = null; // No user found
//     }

//     if (existingUser != null) {
//       if (existingUser.password != password) {
//         ScaffoldMessenger.of(context).showSnackBar(
//           const SnackBar(
//               content: Text('User already exists with a different password')),
//         );
//         return;
//       } else {
//         // Login allowed
//         Navigator.pushReplacement(
//           context,
//           MaterialPageRoute(builder: (_) => TextExtractorScreen(box: widget.box)),
//         );
//         return;
//       }
//     }

//     // Save new user
//     await userBox.add(UserModel(email: email, password: password));

//     Navigator.pushReplacement(
//       context,
//       MaterialPageRoute(builder: (_) => TextExtractorScreen(box: widget.box)),
//     );
//   }

//   Future<void> _continueWithGoogle(BuildContext context) async {
//     try {
//       final account = await _googleSignIn.signIn();
//       if (account != null) {
//         await AuthService().signInWithGoogle(context, widget.box);
//         Navigator.pushReplacement(
//           context,
//           MaterialPageRoute(builder: (_) => TextExtractorScreen(box: widget.box)),
//         );
//       } else {
//         ScaffoldMessenger.of(context).showSnackBar(
//           const SnackBar(content: Text('Google Sign-In was cancelled')),
//         );
//       }
//     } catch (error) {
//       ScaffoldMessenger.of(context).showSnackBar(
//         SnackBar(content: Text('Google Sign-In failed: $error')),
//       );
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       body: Container(
//         decoration: const BoxDecoration(
//           gradient: LinearGradient(
//             colors: [Color(0xFFE0F7FA), Color(0xFFB2EBF2)],
//             begin: Alignment.topCenter,
//             end: Alignment.bottomCenter,
//           ),
//         ),
//         child: Center(
//           child: SingleChildScrollView(
//             padding: const EdgeInsets.all(24),
//             child: Column(
//               mainAxisAlignment: MainAxisAlignment.center,
//               children: [
//                 Container(
//                   decoration: BoxDecoration(
//                     shape: BoxShape.circle,
//                     boxShadow: [
//                       BoxShadow(
//                         color: Colors.grey.withOpacity(0.5),
//                         blurRadius: 10,
//                         spreadRadius: 2,
//                         offset: const Offset(0, 5),
//                       ),
//                     ],
//                   ),
//                   child: const CircleAvatar(
//                     radius: 60,
//                     backgroundImage: AssetImage('assets/images/doctor.png'),
//                     backgroundColor: Colors.transparent,
//                   ),
//                 ),
//                 const SizedBox(height: 30),
//                 Text(
//                   'Welcome to MediScan',
//                   style: GoogleFonts.poppins(
//                     fontSize: 28,
//                     fontWeight: FontWeight.bold,
//                     color: Colors.teal[800],
//                   ),
//                 ),
//                 const SizedBox(height: 8),
//                 Text(
//                   'Empowering Doctors with AI Tools',
//                   style: GoogleFonts.poppins(
//                     fontSize: 16,
//                     color: Colors.teal[600],
//                   ),
//                 ),
//                 const SizedBox(height: 30),
//                 Card(
//                   elevation: 8,
//                   shape: RoundedRectangleBorder(
//                     borderRadius: BorderRadius.circular(16),
//                   ),
//                   child: Padding(
//                     padding:
//                         const EdgeInsets.symmetric(horizontal: 24, vertical: 30),
//                     child: Column(
//                       children: [
//                         TextField(
//                           controller: emailController,
//                           keyboardType: TextInputType.emailAddress,
//                           decoration: const InputDecoration(
//                             labelText: 'Email',
//                             prefixIcon: Icon(Icons.email),
//                             border: OutlineInputBorder(),
//                           ),
//                         ),
//                         const SizedBox(height: 16),
//                         TextField(
//                           controller: passwordController,
//                           obscureText: true,
//                           decoration: const InputDecoration(
//                             labelText: 'New Password',
//                             prefixIcon: Icon(Icons.lock),
//                             border: OutlineInputBorder(),
//                           ),
//                         ),
//                         const SizedBox(height: 24),
//                         ElevatedButton(
//                           onPressed: () => _createProfile(context),
//                           style: ElevatedButton.styleFrom(
//                             backgroundColor: Colors.teal,
//                             minimumSize: const Size.fromHeight(50),
//                             shape: RoundedRectangleBorder(
//                               borderRadius: BorderRadius.circular(12),
//                             ),
//                           ),
//                           child: const Text('Create Profile'),
//                         ),
//                         const SizedBox(height: 12),
//                         OutlinedButton.icon(
//                           onPressed: () => _continueWithGoogle(context),
//                           icon: const Icon(Icons.login, color: Colors.teal),
//                           label: const Text(
//                             'Continue with Google',
//                             style: TextStyle(color: Colors.teal),
//                           ),
//                           style: OutlinedButton.styleFrom(
//                             minimumSize: const Size.fromHeight(50),
//                             side: const BorderSide(color: Colors.teal),
//                             shape: RoundedRectangleBorder(
//                               borderRadius: BorderRadius.circular(12),
//                             ),
//                           ),
//                         ),
//                       ],
//                     ),
//                   ),
//                 ),
//               ],
//             ),
//           ),
//         ),
//       ),
//     );
//   }
// }
