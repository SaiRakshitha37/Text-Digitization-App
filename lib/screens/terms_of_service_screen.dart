import 'package:flutter/material.dart';
//import 'package:/screens/terms_of_service_screen.dart';

class TermsOfServiceScreen extends StatelessWidget {
  const TermsOfServiceScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Terms of Service'),
        backgroundColor: Colors.teal,
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16),
        child: Text(
          '''
Welcome to MyApp!

1. What the app does:
This app helps you digitize text from images quickly and easily.

2. Rules for using the app:
- Do not misuse the app.
- Respect others while using the app.

3. User responsibilities:
- Use the app legally.
- Keep your account secure.

4. Our responsibilities:
- We strive to keep the app working well.
- We do not guarantee perfect results.

5. Privacy:
We collect minimal data to improve your experience. See our Privacy Policy for details.

6. Liability:
We are not responsible for any damages caused by app usage.

7. Disputes:
Any disputes will be handled according to local laws.

8. Updates:
We may update these terms from time to time. Continued use means you accept changes.

Thank you for using our app!
          ''',
          style: TextStyle(fontSize: 16),
        ),
      ),
    );
  }
}


// --------------------------
// import 'package:flutter/material.dart';
// //import 'package:/screens/terms_of_service_screen.dart';

// class TermsOfServiceScreen extends StatelessWidget {
//   const TermsOfServiceScreen({Key? key}) : super(key: key);

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: Text('Terms of Service'),
//         backgroundColor: Colors.teal,
//       ),
//       body: SingleChildScrollView(
//         padding: EdgeInsets.all(16),
//         child: Text(
//           '''
// Welcome to MyApp!

// 1. What the app does:
// This app helps you digitize text from images quickly and easily.

// 2. Rules for using the app:
// - Do not misuse the app.
// - Respect others while using the app.

// 3. User responsibilities:
// - Use the app legally.
// - Keep your account secure.

// 4. Our responsibilities:
// - We strive to keep the app working well.
// - We do not guarantee perfect results.

// 5. Privacy:
// We collect minimal data to improve your experience. See our Privacy Policy for details.

// 6. Liability:
// We are not responsible for any damages caused by app usage.

// 7. Disputes:
// Any disputes will be handled according to local laws.

// 8. Updates:
// We may update these terms from time to time. Continued use means you accept changes.

// 9. Contact:
// For questions, email text_digitization_app.com

// Thank you for using our app!
//           ''',
//           style: TextStyle(fontSize: 16),
//         ),
//       ),
//     );
//   }
// }
