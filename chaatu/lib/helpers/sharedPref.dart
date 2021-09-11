// ignore_for_file: file_names

import 'package:shared_preferences/shared_preferences.dart';

class SharedPrefController {
  final String _userIDKey = "USERKEY";
  final String _usernameKey = "USERNAMEKEY";
  final String _displayNameKey = "DISPLAYNAMEKEY";
  final String _userEmailKey = "EMAILKEY";
  final String _userProfileKey = "PROFILEKEY";

//remove all data

  Future<bool> ClearAll() async {
    SharedPreferences pref = await SharedPreferences.getInstance();
    return pref.clear();
  }

  //saveData
  Future<bool> saveUserName(String username) async {
    SharedPreferences pref = await SharedPreferences.getInstance();
    return pref.setString(_usernameKey, username);
  }

  Future<bool> saveEmail(String email) async {
    SharedPreferences pref = await SharedPreferences.getInstance();
    return pref.setString(_userEmailKey, email);
  }

  Future<bool> saveDisplayName(String displayName) async {
    SharedPreferences pref = await SharedPreferences.getInstance();
    return pref.setString(_displayNameKey, displayName);
  }

  Future<bool> saveProfilePic(String profile) async {
    SharedPreferences pref = await SharedPreferences.getInstance();
    return pref.setString(_userProfileKey, profile);
  }

  Future<bool> saveUserID(String uid) async {
    SharedPreferences pref = await SharedPreferences.getInstance();
    return pref.setString(_userIDKey, uid);
  }

  //get Data

  Future<String?> getUserID() async {
    SharedPreferences pref = await SharedPreferences.getInstance();
    return pref.getString(_userIDKey);
  }

  Future<String?> getUsername() async {
    SharedPreferences pref = await SharedPreferences.getInstance();
    return pref.getString(_usernameKey);
  }

  Future<String?> getDisplayName() async {
    SharedPreferences pref = await SharedPreferences.getInstance();
    return pref.getString(_displayNameKey);
  }

  Future<String?> getEmail() async {
    SharedPreferences pref = await SharedPreferences.getInstance();
    return pref.getString(_userEmailKey);
  }

  Future<String?> getPRofilePic() async {
    SharedPreferences pref = await SharedPreferences.getInstance();
    return pref.getString(_userProfileKey);
  }
}
