import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:title_proj/child/LoginScreen.dart';
import 'package:title_proj/parent/parent_homescreen.dart'; 
import 'package:title_proj/home_screen.dart'; 
import 'package:title_proj/utils/shared_preferences.dart';  // Correct the import for SharedPreferencesUtil
import 'firebase_options.dart';
import 'package:title_proj/parent/parent_register_screen.dart'; // Correct import path

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Women Safety App',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        textTheme: GoogleFonts.poppinsTextTheme(
          Theme.of(context).textTheme,
        ),
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
      ),
      initialRoute: '/',
      routes: {
        '/': (context) => FutureBuilder<bool>(
          future: _checkLoginStatus(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return Center(child: CircularProgressIndicator());
            } else {
              if (snapshot.hasData && snapshot.data == true) {
                return _getRoleScreen();
              } else {
                return LoginScreen();  // Show login screen if not logged in
              }
            }
          },
        ),
        '/parent_register': (context) => ParentRegisterScreen(),  // Registration screen route
      },
    );
  }

  // Check login status from SharedPreferences
  Future<bool> _checkLoginStatus() async {
    return await SharedPreferencesUtil.getLoginState();  // This checks if the user is logged in
  }

  // Get the correct screen based on the user role
  Widget _getRoleScreen() {
    return FutureBuilder<String?>(
      future: SharedPreferencesUtil.getUserRole(),  // Retrieve the user's role
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(child: CircularProgressIndicator());
        } else {
          // Check role and navigate accordingly
          if (snapshot.data == 'parent') {
            return ParentHomeScreen();  // Navigate to Parent Home screen if parent role
          } else {
            return HomeScreen();  // Navigate to Child's Home screen if child role
          }
        }
      },
    );
  }
}
