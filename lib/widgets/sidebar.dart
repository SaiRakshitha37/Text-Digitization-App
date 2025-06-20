import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/text_model.dart';
import '../screens/saved_documents_screen.dart';
import '../screens/settings_screens.dart';
import '../screens/text_extractor_screen.dart';
import '../screens/login_screen.dart';
import '../screens/deleted_documents_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:provider/provider.dart';
import '../profile_manager.dart';

class Sidebar extends StatefulWidget {
  final Box<TextModel> box; // Changed to non-nullable

  const Sidebar({Key? key, required this.box}) : super(key: key);

  @override
  State<Sidebar> createState() => _SidebarState();
}

class _SidebarState extends State<Sidebar> {
  String? _email;
  String? _name;

  @override
  void initState() {
    super.initState();
    _loadUserInfo();
  }

  Future<void> _loadUserInfo() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _email = prefs.getString('email') ?? 'Your Documents Hub';
      _name = prefs.getString('name') ?? 'Welcome!';
    });
  }

  @override
  Widget build(BuildContext context) {
    print('Sidebar: Building with box length: ${widget.box.length}');
    return Drawer(
      child: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFFE0F7FA), Color(0xFFB2EBF2)],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: Column(
          children: [
            GestureDetector(
              onTap: () {
                Navigator.pushNamed(context, '/createProfile');
              },
              child: Container(
                padding: const EdgeInsets.only(top: 40, bottom: 20),
                width: double.infinity,
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFF80DEEA), Color(0xFFB2EBF2)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  boxShadow: const [
                    BoxShadow(
                      color: Colors.black12,
                      blurRadius: 4,
                      offset: Offset(0, 2),
                    ),
                  ],
                  borderRadius: const BorderRadius.only(
                    bottomLeft: Radius.circular(20),
                    bottomRight: Radius.circular(20),
                  ),
                ),
                child: Consumer<ProfileManager>(
                  builder: (context, profileManager, _) {
                    final profile = profileManager.profile;
                    return Column(
                      children: [
                        CircleAvatar(
                          radius: 40,
                          child: Text(
                            profile?.avatarLetter ?? '?',
                            style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                          ),
                        ),
                        const SizedBox(height: 10),
                        Text(
                          profile?.name.isNotEmpty == true ? 'Welcome, ${profile!.name}!' : 'Welcome!',
                          style: const TextStyle(
                            color: Color(0xFF004D40),
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          profile?.email ?? 'Your Documents Hub',
                          style: const TextStyle(
                            color: Color(0xFF00796B),
                            fontSize: 14,
                          ),
                        ),
                      ],
                    );
                  },
                ),
              ),
            ),
            const SizedBox(height: 10),
            Expanded(
              child: ListView(
                children: [
                  _buildTile(
                    icon: Icons.medical_services,
                    title: 'Text Extractor',
                    page: TextExtractorScreen(box: widget.box),
                  ),
                  _buildTile(
                    icon: Icons.folder_shared,
                    title: 'Saved Documents',
                    onTap: () {
                      Navigator.pop(context); // Close the drawer
                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(builder: (context) => SavedDocumentsScreen(box: widget.box)),
                      );
                    },
                  ),
                  _buildTile(
                    icon: Icons.settings,
                    title: 'Settings',
                    page: SettingsScreen(box: widget.box),
                  ),
                  _buildTile(
                    icon: Icons.delete,
                    title: 'Trash',
                    page: DeletedDocumentsScreen(box: widget.box),
                  ),
                  const Divider(color: Colors.teal, indent: 16, endIndent: 16),
                  _buildTile(
                    icon: Icons.logout,
                    title: 'Log Out',
                    onTap: () async {
                      // Sign out from Firebase
                      await FirebaseAuth.instance.signOut();
                      // Clear the token in SharedPreferences
                      final prefs = await SharedPreferences.getInstance();
                      await prefs.remove('token');
                      // Navigate to LoginScreen and clear the navigation stack
                      Navigator.of(context).pushAndRemoveUntil(
                        MaterialPageRoute(
                          builder: (context) => const LoginScreen(),
                        ),
                        (route) => false,
                      );
                    },
                  ),
                ],
              ),
            ),
            const Padding(
              padding: EdgeInsets.all(12.0),
              child: Text(
                'Made for Doctors 🩺',
                style: TextStyle(
                  color: Color(0xFF004D40),
                  fontStyle: FontStyle.italic,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTile({
    required IconData icon,
    required String title,
    Widget? page,
    VoidCallback? onTap,
  }) {
    return ListTile(
      leading: Icon(icon, color: const Color(0xFF00695C)),
      title: Text(
        title,
        style: const TextStyle(
          color: Color(0xFF004D40),
          fontSize: 16,
          fontWeight: FontWeight.w500,
        ),
      ),
      hoverColor: Colors.teal.shade50,
      onTap: onTap ??
          () {
            if (page == null) return; // Prevent navigation if page is null
            Navigator.pop(context);
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => page),
            );
          },
    );
  }
}
// ------------------------------------------------------------
// import 'package:flutter/material.dart';
// import 'package:hive/hive.dart';
// import 'package:firebase_auth/firebase_auth.dart';
// import '../models/text_model.dart';
// import '../screens/protected_saved_documents_screen.dart';
// import '../screens/settings_screens.dart';
// import '../screens/text_extractor_screen.dart';
// import '../screens/login_screen.dart'; // Import LoginScreen for navigation after sign-out
// import '../screens/deleted_documents_screen.dart';
// import 'package:shared_preferences/shared_preferences.dart';
// import 'package:provider/provider.dart';
// import '../profile_manager.dart';

// class Sidebar extends StatefulWidget {
//   final Box<TextModel>? box;

//   const Sidebar({Key? key, required this.box}) : super(key: key);

//   @override
//   State<Sidebar> createState() => _SidebarState();
// }

// class _SidebarState extends State<Sidebar> {
//   String? _email;
//   String? _name;

//   @override
//   void initState() {
//     super.initState();
//     _loadUserInfo();
//   }

//   Future<void> _loadUserInfo() async {
//     final prefs = await SharedPreferences.getInstance();
//     setState(() {
//       _email = prefs.getString('email') ?? 'Your Documents Hub';
//       _name = prefs.getString('name') ?? 'Welcome!';
//     });
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Drawer(
//       child: Container(
//         decoration: const BoxDecoration(
//           gradient: LinearGradient(
//             colors: [Color(0xFFE0F7FA), Color(0xFFB2EBF2)],
//             begin: Alignment.topCenter,
//             end: Alignment.bottomCenter,
//           ),
//         ),
//         child: Column(
//           children: [
//             GestureDetector(
//               onTap: () {
//                 Navigator.pushNamed(context, '/createProfile');
//               },
//               child: Container(
//                 padding: const EdgeInsets.only(top: 40, bottom: 20),
//                 width: double.infinity,
//                 decoration: BoxDecoration(
//                   gradient: const LinearGradient(
//                     colors: [Color(0xFF80DEEA), Color(0xFFB2EBF2)],
//                     begin: Alignment.topLeft,
//                     end: Alignment.bottomRight,
//                   ),
//                   boxShadow: const [
//                     BoxShadow(
//                       color: Colors.black12,
//                       blurRadius: 4,
//                       offset: Offset(0, 2),
//                     ),
//                   ],
//                   borderRadius: const BorderRadius.only(
//                     bottomLeft: Radius.circular(20),
//                     bottomRight: Radius.circular(20),
//                   ),
//                 ),
//                 child: Consumer<ProfileManager>(
//                   builder: (context, profileManager, _) {
//                     final profile = profileManager.profile;
//                     return Column(
//                       children: [
//                         CircleAvatar(
//                           radius: 40,
//                           child: Text(
//                             profile?.avatarLetter ?? '?',
//                             style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
//                           ),
//                         ),
//                         const SizedBox(height: 10),
//                         Text(
//                           profile?.name.isNotEmpty == true ? 'Welcome, ${profile!.name}!' : 'Welcome!',
//                           style: const TextStyle(
//                             color: Color(0xFF004D40),
//                             fontSize: 18,
//                             fontWeight: FontWeight.bold,
//                           ),
//                         ),
//                         Text(
//                           profile?.email ?? 'Your Documents Hub',
//                           style: const TextStyle(
//                             color: Color(0xFF00796B),
//                             fontSize: 14,
//                           ),
//                         ),
//                       ],
//                     );
//                   },
//                 ),
//               ),
//             ),
//             const SizedBox(height: 10),
//             Expanded(
//               child: ListView(
//                 children: [
//                   _buildTile(
//                     icon: Icons.medical_services,
//                     title: 'Text Extractor',
//                     page: TextExtractorScreen(box: widget.box!),
//                   ),
//                   _buildTile(
//                     icon: Icons.folder_shared,
//                     title: 'Saved Documents',
//                     page: ProtectedSavedDocumentsScreen(box: widget.box!),
//                   ),
//                   _buildTile(
//                     icon: Icons.settings,
//                     title: 'Settings',
//                     page: SettingsScreen(box: widget.box!),
//                   ),
//                   _buildTile(
//                     icon: Icons.delete,
//                     title: 'Trash',
//                     page: DeletedDocumentsScreen(box: widget.box!),
//                   ),
//                   const Divider(color: Colors.teal, indent: 16, endIndent: 16),
//                   _buildTile(
//                     icon: Icons.logout,
//                     title: 'Log Out',
//                     onTap: () async {
//                       // Sign out from Firebase
//                       await FirebaseAuth.instance.signOut();
//                       // Clear the token in SharedPreferences
//                       final prefs = await SharedPreferences.getInstance();
//                       await prefs.remove('token');
//                       // Navigate to LoginScreen and clear the navigation stack
//                       Navigator.of(context).pushAndRemoveUntil(
//                         MaterialPageRoute(
//                           builder: (context) => const LoginScreen(),
//                         ),
//                         (route) => false,
//                       );
//                     },
//                   ),
//                 ],
//               ),
//             ),
//             const Padding(
//               padding: EdgeInsets.all(12.0),
//               child: Text(
//                 'Made for Doctors 🩺',
//                 style: TextStyle(
//                   color: Color(0xFF004D40),
//                   fontStyle: FontStyle.italic,
//                 ),
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }

//   Widget _buildTile({
//     required IconData icon,
//     required String title,
//     Widget? page,
//     VoidCallback? onTap,
//   }) {
//     return ListTile(
//       leading: Icon(icon, color: const Color(0xFF00695C)),
//       title: Text(
//         title,
//         style: const TextStyle(
//           color: Color(0xFF004D40),
//           fontSize: 16,
//           fontWeight: FontWeight.w500,
//         ),
//       ),
//       hoverColor: Colors.teal.shade50,
//       onTap: onTap ??
//           () {
//             Navigator.pop(context);
//             Navigator.pushReplacement(
//               context,
//               MaterialPageRoute(builder: (context) => page!),
//             );
//           },
//     );
//   }
// }