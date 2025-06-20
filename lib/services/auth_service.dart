
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/material.dart';
// import 'package:text_digitization_app/screens/welcome_screen.dart';
import 'package:hive/hive.dart';
import 'package:text_digitization_app/models/text_model.dart';
// import ''

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final GoogleSignIn _googleSignIn = GoogleSignIn();

  // Method to sign in with Google and store user info in SharedPreferences
  Future<void> signInWithGoogle(BuildContext context, Box<TextModel> box) async {
    try {
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
      final GoogleSignInAuthentication googleAuth = await googleUser!.authentication;

      final AuthCredential credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      final UserCredential userCredential = await _auth.signInWithCredential(credential);
      final user = userCredential.user;

      if (user != null) {
        // Store the user's email, name, and first letter of the name for avatar in SharedPreferences
        SharedPreferences prefs = await SharedPreferences.getInstance();
        await prefs.setString('email', user.email ?? 'No Email');
        await prefs.setString('name', user.displayName ?? 'No Name');
        
        // Get the first letter of the name for the avatar
        String firstLetter = (user.displayName != null && user.displayName!.isNotEmpty)
            ? user.displayName![0].toUpperCase()
            : 'U';  // Default to 'U' for unknown if the name is empty

        // Store the first letter in SharedPreferences for the avatar
        await prefs.setString('avatar', firstLetter);

        // Navigate to the Welcome screen after successful sign-in
        // Navigator.pushReplacement(
        //   context,
        //   MaterialPageRoute(builder: (context) => WelcomeScreen(box: box)),
        // );
      }
    } catch (e) {
      print('Google Sign-In Error: $e'); // Handle errors
    }
  }

  // Sign out method to handle user sign out
  Future<void> signOut() async {
    try {
      await _googleSignIn.signOut();
      await _auth.signOut();
    } catch (e) {
      print('Sign Out Error: $e');
    }
  }
}
