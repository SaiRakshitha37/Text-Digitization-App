
import 'package:shared_preferences/shared_preferences.dart';

class PasswordService {
  static const _key = 'app_password';

  static Future<void> savePassword(String password) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_key, password);
  }

  static Future<String?> getPassword() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_key);
  }

  static Future<bool> isPasswordCorrect(String input) async {
    final saved = await getPassword();
    return saved == input;
  }
}
