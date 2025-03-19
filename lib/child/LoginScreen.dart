import 'package:flutter/material.dart';
import 'package:title_proj/utils/shared_preferences.dart';  // Import SharedPreferencesUtil

class LoginScreen extends StatefulWidget {
  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  // Login function
  void _login() async {
    // Simulate successful login
    await SharedPreferencesUtil.saveLoginState('child');  // Save login state and role as 'child'
    Navigator.pushReplacementNamed(context, '/childHome');  // Navigate to child home
  }

  // Logout function
  void _logout() async {
    await SharedPreferencesUtil.logout();  // Clear login state and role
    Navigator.pushReplacementNamed(context, '/');  // Navigate back to main login screen
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Child Login'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            // Your login form fields here
            ElevatedButton(
              onPressed: _login,  // Trigger login function
              child: Text('Login as Child'),
            ),
            // Logout Button
            ElevatedButton(
              onPressed: _logout,  // Trigger logout function
              child: Text('Logout'),
            ),
          ],
        ),
      ),
    );
  }
}
