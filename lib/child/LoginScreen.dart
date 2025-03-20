import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:title_proj/components/PrimaryButton.dart';
import 'package:title_proj/components/SecondaryButton.dart';
import 'package:title_proj/components/custom_textfield.dart';
import 'package:title_proj/home_screen.dart';
import 'package:title_proj/parent/parent_homescreen.dart';
import 'package:title_proj/utils/constants.dart';

class LoginScreen extends StatefulWidget {
  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  bool isPasswordShown = false;

  final FirebaseAuth _auth = FirebaseAuth.instance; // FirebaseAuth instance

  Future<void> _login() async {
    if (!_formKey.currentState!.validate()) return;
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => Center(child: CircularProgressIndicator()),
    );

    try {
      UserCredential userCredential = await _auth.signInWithEmailAndPassword(
        email: _emailController.text.trim(),
        password: _passwordController.text.trim(),
      );
      Navigator.of(context).pop(); // Close loading dialog

      // Assuming role differentiation is stored in Firestore or Firebase user metadata
      User? user = userCredential.user;
      if (user != null) {
        // Implement logic to check user role from Firestore or user metadata
        if (user.email!.contains("child")) {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => HomeScreen()),
          );
        } else {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => ParentHomeScreen()),
          );
        }
      }
    } catch (e) {
      Navigator.of(context).pop(); // Close loading dialog
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Login failed: ${e.toString()}")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 30),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Text(
                      "Welcome Back!",
                      style: TextStyle(
                        fontSize: 36,
                        color: primaryColor,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 10),
                    Text(
                      "Login to your account",
                      style: TextStyle(fontSize: 18, color: Colors.grey[700]),
                    ),
                    SizedBox(height: 20),
                    Image.asset('assets/SHEildlogo.png', height: 250, width: 450),
                    SizedBox(height: 20),
                    Container(
                      decoration: BoxDecoration(
                        color: Colors.grey[200],
                        borderRadius: BorderRadius.circular(15),
                      ),
                      padding: EdgeInsets.all(20),
                      child: Column(
                        children: [
                          CustomTextField(
                            controller: _emailController,
                            hintText: 'Enter Email',
                            prefix: Icon(Icons.email, color: Colors.grey),
                            validator: (value) {
                              if (value == null || value.trim().isEmpty) {
                                return 'Email is required';
                              }
                              return null;
                            },
                          ),
                          SizedBox(height: 15),
                          CustomTextField(
                            controller: _passwordController,
                            hintText: 'Enter Password',
                            isPassword: isPasswordShown,
                            prefix: Icon(Icons.lock, color: Colors.grey),
                            suffix: IconButton(
                              onPressed: () {
                                setState(() {
                                  isPasswordShown = !isPasswordShown;
                                });
                              },
                              icon: isPasswordShown
                                  ? Icon(Icons.visibility_off)
                                  : Icon(Icons.visibility),
                            ),
                            validator: (value) {
                              if (value == null || value.length < 6) {
                                return 'Password must be at least 6 characters';
                              }
                              return null;
                            },
                          ),
                          SizedBox(height: 20),
                          PrimaryButton(title: 'LOGIN', onPressed: _login),
                          SizedBox(height: 15),
                          TextButton(
                            onPressed: () {},
                            child: Text(
                              "Forgot Password?",
                              style: TextStyle(fontSize: 16, color: primaryColor),
                            ),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(height: 20),
                    Text("Don't have an account?", style: TextStyle(fontSize: 16)),
                    SizedBox(height: 10),
                    SecondaryButton(
                      title: 'Register as Child',
                      onPressed: () {
                        Navigator.pushNamed(context, '/register_child');
                      },
                    ),
                    SizedBox(height: 10),
                    SecondaryButton(
                      title: 'Register As Guardian',
                      onPressed: () {
                        Navigator.pushNamed(context, '/parent_register');
                      },
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}