import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:title_proj/components/PrimaryButton.dart';
import 'package:title_proj/utils/constants.dart';
import 'package:title_proj/child/LoginScreen.dart'; // Import the login screen
import 'package:shared_preferences/shared_preferences.dart';

class ParentHomeScreen extends StatelessWidget {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // Logout function
  Future<void> _logout(BuildContext context) async {
    // Clear SharedPreferences (removes login state and role)
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.clear();

    // Sign out from Firebase
    await _auth.signOut();

    // Navigate to the Login screen
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => LoginScreen()), // Navigate to login screen
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Guardian Home"),
        backgroundColor: primaryColor,
        actions: [
          IconButton(
            icon: Icon(Icons.logout),
            onPressed: () => _logout(context), // Log out on button press
          ),
        ],
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              "Welcome Guardian!",
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 20),
            Text(
              "You are logged in as a Guardian.",
              style: TextStyle(fontSize: 16),
            ),
            SizedBox(height: 30),
            PrimaryButton(
              title: "Logout",
              onPressed: () => _logout(context), // Log out button
            ),
          ],
        ),
      ),
    );
  }
}
