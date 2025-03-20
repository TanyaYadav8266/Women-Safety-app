import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:title_proj/child/LoginScreen.dart';
import 'package:title_proj/child/register_child.dart'; // Import child register screen
import 'package:title_proj/parent/parent_register_screen.dart'; // Import parent register screen
import 'firebase_options.dart';

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
      title: 'Flutter Demo',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        textTheme: GoogleFonts.poppinsTextTheme(
          Theme.of(context).textTheme,
        ),
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
      ),
      initialRoute: '/',  
      routes: {
        '/': (context) => LoginScreen(), // Default login screen
        '/register_child': (context) => RegisterChildScreen(), // Child register screen
        '/parent_register': (context) => ParentRegisterScreen(), // Parent register screen
      },
    );
  }
}