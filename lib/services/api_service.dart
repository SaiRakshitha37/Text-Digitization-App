// import 'dart:convert';
// import 'package:http/http.dart' as http;
// import '../models/text_model.dart';
// //import 'package:text_digitization_app/services/api_services.dart'; // Add this line


// class ApiService {
//   static const String baseUrl = 'http://localhost:3000'; // change if needed

//   static Future<List<TextModel>> fetchSavedTexts() async {
//     final response = await http.get(Uri.parse('$baseUrl/api/getSavedTexts'));

//     if (response.statusCode == 200) {
//       final List<dynamic> jsonData = json.decode(response.body);
//       return jsonData.map((json) => TextModel.fromJson(json)).toList();
//     } else {
//       throw Exception('Failed to load saved texts');
//     }
//   }
// }

// import 'dart:convert';
// import 'package:http/http.dart' as http;
// import '../models/text_model.dart';

// class ApiService {
//   static const String baseUrl = 'http://localhost:3000'; // Update as needed

//   /// Returns the full URL for getting saved texts.
//   static String getSavedTextsUrl() {
//     return '$baseUrl/api/getSavedTexts';
//   }

//   /// Fetch saved texts from the backend.
//   static Future<List<TextModel>> fetchSavedTexts() async {
//     final response = await http.get(Uri.parse(getSavedTextsUrl()));

//     if (response.statusCode == 200) {
//       final List<dynamic> jsonData = json.decode(response.body);
//       return jsonData.map((json) => TextModel.fromJson(json)).toList();
//     } else {
//       throw Exception('Failed to load saved texts');
//     }
//   }
// }

import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/text_model.dart';

class ApiService {
  static const String baseUrl = 'http://localhost:3000'; // Replace with production URL if needed
  // static const String baseUrl = 'http://192.168.29.162.159:3000';
  /// Returns the full URL for getting saved texts.
  static String getSavedTextsUrl() {
    return '$baseUrl/api/getSavedTexts';
  }

  /// Fetch saved texts from the backend.
  static Future<List<TextModel>> fetchSavedTexts() async {
    final response = await http.get(Uri.parse(getSavedTextsUrl()));

    if (response.statusCode == 200) {
      final List<dynamic> jsonData = json.decode(response.body);
      return jsonData.map((json) => TextModel.fromJson(json)).toList();
    } else {
      throw Exception('Failed to load saved texts');
    }
  }

  /// Save user profile (used during Google Sign-In or profile creation)
  static Future<bool> saveUserProfile({
    required String name,
    required String email,
    required String password, // Send dummy password for Google users
  }) async {
    final url = Uri.parse('$baseUrl/api/saveUser');

    final response = await http.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: json.encode({
        'name': name,
        'email': email,
        'password': password,
      }),
    );

    if (response.statusCode == 200 || response.statusCode == 201) {
      return true;
    } else {
      print("Failed to save profile: ${response.body}");
      return false;
    }
  }
}

