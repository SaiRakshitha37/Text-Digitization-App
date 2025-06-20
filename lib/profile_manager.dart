import 'package:flutter/material.dart';
import 'user_profile.dart';

class ProfileManager with ChangeNotifier {
  UserProfile? _profile;

  UserProfile? get profile => _profile;

  void setProfile(UserProfile profile) {
    _profile = profile;
    notifyListeners();
  }
}