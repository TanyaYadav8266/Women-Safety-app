import 'package:shared_preferences/shared_preferences.dart';

class SharedPreferencesUtil {
  // Save login state and role
  static Future<void> saveLoginState(String role) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setBool('isLoggedIn', true);  // Set login state to true
    await prefs.setString('role', role);      // Save the user role (parent or child)
  }

  // Get login state
  static Future<bool> getLoginState() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getBool('isLoggedIn') ?? false;  // Default is false
  }

  // Get user role
  static Future<String?> getUserRole() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getString('role');
  }

  // Logout and clear the saved state
  static Future<void> logout() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.remove('isLoggedIn');  // Remove login state
    await prefs.remove('role');        // Remove the role
  }
}
