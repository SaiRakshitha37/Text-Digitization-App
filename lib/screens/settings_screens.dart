import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/text_model.dart';
import '../widgets/sidebar.dart';
import 'package:text_digitization_app/screens/terms_of_service_screen.dart';
import 'package:text_digitization_app/screens/about_us_screen.dart';
import 'package:text_digitization_app/screens/privacy_policy_screen.dart';

class SettingsScreen extends StatefulWidget {
  final Box<TextModel> box;
  const SettingsScreen({Key? key, required this.box}) : super(key: key);

  @override
  _SettingsScreenState createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  bool _alwaysUseCamera = false;

  @override
  void initState() {
    super.initState();
    _loadCameraPreference();
  }

  void _loadCameraPreference() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      _alwaysUseCamera = prefs.getBool('alwaysUseCamera') ?? false;
    });
  }

  void _toggleCameraPreference(bool value) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setBool('alwaysUseCamera', value);
    setState(() {
      _alwaysUseCamera = value;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: Sidebar(box: widget.box),
      appBar: AppBar(
        title: const Text('Settings for Doctors'),
        backgroundColor: Colors.teal,
        elevation: 2,
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFFE8F5E9), Color(0xFFF1F8E9)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            _buildSectionTitle('🔧 Preferences'),
            _buildCard([
              SwitchListTile(
                title: const Text('Always Use Camera'),
                subtitle: const Text('Skip gallery and directly open camera view'),
                value: _alwaysUseCamera,
                onChanged: _toggleCameraPreference,
                activeColor: Colors.teal,
                secondary: const Icon(Icons.camera_alt_outlined),
              ),
            ]),

            _buildSectionTitle('📄 Legal'),
            _buildCard([
              ListTile(
                title: const Text('Terms of Service'),
                leading: const Icon(Icons.description_outlined, color: Colors.teal),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const TermsOfServiceScreen()),
                  );
                },
              ),
              ListTile(
                title: const Text('Privacy Policy'),
                leading: const Icon(Icons.privacy_tip_outlined, color: Colors.teal),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const PrivacyPolicyScreen()),
                  );
                },
              ),
            ]),

            _buildSectionTitle('👥 About Us'),
            _buildCard([
              ListTile(
                title: const Text('About Us'),
                leading: const Icon(Icons.info_outline, color: Colors.teal),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const AboutUsScreen()),
                  );
                },
              ),
            ]),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Text(
        title,
        style: const TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.bold,
          color: Colors.teal,
        ),
      ),
    );
  }

  Widget _buildCard(List<Widget> children) {
    return Card(
      elevation: 6,
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Column(children: children),
    );
  }
}



// import 'package:flutter/material.dart';
// import 'package:hive/hive.dart';
// import 'package:shared_preferences/shared_preferences.dart';
// import '../models/text_model.dart';
// import '../widgets/sidebar.dart';
// import 'package:text_digitization_app/screens/terms_of_service_screen.dart';
// import 'package:text_digitization_app/screens/about_us_screen.dart';
// import 'package:text_digitization_app/screens/privacy_policy_screen.dart';

// class SettingsScreen extends StatefulWidget {
//   final Box<TextModel> box;
//   const SettingsScreen({Key? key, required this.box}) : super(key: key);

//   @override
//   _SettingsScreenState createState() => _SettingsScreenState();
// }

// class _SettingsScreenState extends State<SettingsScreen> {
//   bool _alwaysUseCamera = false;

//   @override
//   void initState() {
//     super.initState();
//     _loadCameraPreference();
//   }

//   void _loadCameraPreference() async {
//     SharedPreferences prefs = await SharedPreferences.getInstance();
//     setState(() {
//       _alwaysUseCamera = prefs.getBool('alwaysUseCamera') ?? false;
//     });
//   }

//   void _toggleCameraPreference(bool value) async {
//     SharedPreferences prefs = await SharedPreferences.getInstance();
//     await prefs.setBool('alwaysUseCamera', value);
//     setState(() {
//       _alwaysUseCamera = value;
//     });
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       drawer: Sidebar(box: widget.box),
//       appBar: AppBar(
//         title: const Text('Settings for Doctors'),
//         backgroundColor: Colors.teal,
//         elevation: 2,
//       ),
//       body: Container(
//         decoration: const BoxDecoration(
//           gradient: LinearGradient(
//             colors: [Color(0xFFE8F5E9), Color(0xFFF1F8E9)],
//             begin: Alignment.topLeft,
//             end: Alignment.bottomRight,
//           ),
//         ),
//         child: ListView(
//           padding: const EdgeInsets.all(16),
//           children: [
//             _buildSectionTitle('🔧 Preferences'),
//             _buildCard([
//               SwitchListTile(
//                 title: const Text('Always Use Camera'),
//                 subtitle: const Text('Skip gallery and directly open camera view'),
//                 value: _alwaysUseCamera,
//                 onChanged: _toggleCameraPreference,
//                 activeColor: Colors.teal,
//                 secondary: const Icon(Icons.camera_alt_outlined),
//               ),
//             ]),

//             _buildSectionTitle('📄 Legal'),
//             _buildCard([
//               ListTile(
//                 title: const Text('Terms of Service'),
//                 leading: const Icon(Icons.description_outlined, color: Colors.teal),
//                 onTap: () {
//                   Navigator.push(
//                     context,
//                     MaterialPageRoute(builder: (_) => const TermsOfServiceScreen()),
//                   );
//                 },
//               ),
//               ListTile(
//                 title: const Text('Privacy Policy'),
//                 leading: const Icon(Icons.privacy_tip_outlined, color: Colors.teal),
//                 onTap: () {
//                   Navigator.push(
//                     context,
//                     MaterialPageRoute(builder: (_) => const PrivacyPolicyScreen()),
//                   );
//                 },
//               ),
//             ]),

//             _buildSectionTitle('👥 About Us'),
//             _buildCard([
//               ListTile(
//                 title: const Text('About Us'),
//                 leading: const Icon(Icons.info_outline, color: Colors.teal),
//                 onTap: () {
//                   Navigator.push(
//                     context,
//                     MaterialPageRoute(builder: (_) => const AboutUsScreen()),
//                   );
//                 },
//               ),
//             ]),
//           ],
//         ),
//       ),
//     );
//   }

//   Widget _buildSectionTitle(String title) {
//     return Padding(
//       padding: const EdgeInsets.symmetric(vertical: 10),
//       child: Text(
//         title,
//         style: const TextStyle(
//           fontSize: 20,
//           fontWeight: FontWeight.bold,
//           color: Colors.teal,
//         ),
//       ),
//     );
//   }

//   Widget _buildCard(List<Widget> children) {
//     return Card(
//       elevation: 6,
//       margin: const EdgeInsets.only(bottom: 12),
//       shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
//       child: Column(children: children),
//     );
//   }
// }

