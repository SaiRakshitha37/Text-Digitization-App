import 'package:flutter/material.dart';

class PrivacyPolicyScreen extends StatelessWidget {
  const PrivacyPolicyScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Privacy Policy'),
        backgroundColor: Colors.teal,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: const Text(
          '''
Privacy Policy for MediScan

1. Introduction
We value your privacy. This policy explains how we collect and use your data when using MediScan.

2. Information We Collect
- Personal Information: Email address (for account/login)
- Usage Data: How you use the app
- Device Info: Device model, OS version (used for debugging)

3. How We Use Your Information
- To enable text extraction and document storage
- To improve app features and fix bugs
- To provide support when needed

4. Data Sharing
We do not sell your data. We may share data with cloud providers or analytics tools solely to improve the app.

5. Data Security
All your data is encrypted and securely stored. We take necessary precautions to prevent unauthorized access.

6. User Rights
You have the right to request deletion of your account and data at any time.

7. Children’s Privacy
This app is not intended for children under 13. We do not knowingly collect data from children.

8. Policy Updates
We may update this policy. Continued use of the app implies acceptance of changes.

Thank you for trusting MediScan.
          ''',
          style: TextStyle(fontSize: 16),
        ),
      ),
    );
  }
}










// import 'package:flutter/material.dart';

// class PrivacyPolicyScreen extends StatelessWidget {
//   const PrivacyPolicyScreen({Key? key}) : super(key: key);

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: const Text('Privacy Policy'),
//         backgroundColor: Colors.teal,
//       ),
//       body: SingleChildScrollView(
//         padding: const EdgeInsets.all(16),
//         child: const Text(
//           '''
// Privacy Policy for MediScan

// 1. Introduction
// We value your privacy. This policy explains how we collect and use your data when using MediScan.

// 2. Information We Collect
// - Personal Information: Email address (for account/login)
// - Usage Data: How you use the app
// - Device Info: Device model, OS version (used for debugging)

// 3. How We Use Your Information
// - To enable text extraction and document storage
// - To improve app features and fix bugs
// - To provide support when needed

// 4. Data Sharing
// We do not sell your data. We may share data with cloud providers or analytics tools solely to improve the app.

// 5. Data Security
// All your data is encrypted and securely stored. We take necessary precautions to prevent unauthorized access.

// 6. User Rights
// You have the right to request deletion of your account and data at any time.

// 7. Children’s Privacy
// This app is not intended for children under 13. We do not knowingly collect data from children.

// 8. Policy Updates
// We may update this policy. Continued use of the app implies acceptance of changes.

// 9. Contact Us
// For any questions or requests, email us at: support@mediscanapp.com

// Thank you for trusting MediScan.
//           ''',
//           style: TextStyle(fontSize: 16),
//         ),
//       ),
//     );
//   }
// }
