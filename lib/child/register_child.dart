import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:title_proj/child/LoginScreen.dart';
import 'package:title_proj/components/PrimaryButton.dart';
import 'package:title_proj/components/custom_textfield.dart';
import 'package:title_proj/utils/constants.dart';
import 'package:title_proj/model/user_model.dart';

class RegisterChildScreen extends StatefulWidget {
  const RegisterChildScreen({super.key});

  @override
  State<RegisterChildScreen> createState() => _RegisterChildScreenState();
}

class _RegisterChildScreenState extends State<RegisterChildScreen> {
  final _formKey = GlobalKey<FormState>();

  // Controllers for input fields
  TextEditingController nameController = TextEditingController();
  TextEditingController emailController = TextEditingController();
  TextEditingController phoneController = TextEditingController();
  TextEditingController guardianEmailController = TextEditingController();
  TextEditingController passwordController = TextEditingController();
  TextEditingController confirmPasswordController = TextEditingController();

  bool isPasswordVisible = false;
  bool isConfirmPasswordVisible = false;
  bool isLoading = false; // To show progress indicator

  final FirebaseAuth _auth = FirebaseAuth.instance; // Firebase Auth instance
  final FirebaseFirestore _firestore = FirebaseFirestore.instance; // Firestore instance

  // Function to handle form submission
  void _onSubmit() async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        isLoading = true;
      });

      try {
        // Create user in Firebase Authentication
        UserCredential userCredential = await _auth.createUserWithEmailAndPassword(
          email: emailController.text.trim(),
          password: passwordController.text.trim(),
        );

        // Create a user model instance
        UserModel user = UserModel(
          id: userCredential.user!.uid,
          name: nameController.text.trim(),
          phone: phoneController.text.trim(),
          childEmail: emailController.text.trim(),
          guardianEmail: guardianEmailController.text.trim(),
          type: "child",  // Default user type as "child"
          profilePic: "",
        );

        // Store user details in Firestore Database
        await _firestore.collection('users').doc(user.id).set(user.toJson());

        // Navigate to login screen after successful registration
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => LoginScreen()),
        );

      } on FirebaseAuthException catch (e) {
        _showErrorDialog(e.message ?? "Registration failed!");
      } catch (e) {
        _showErrorDialog("Something went wrong. Please try again!");
      } finally {
        setState(() {
          isLoading = false;
        });
      }
    }
  }

  // Show error dialog
  void _showErrorDialog(String message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text("Error"),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text("OK"),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Child Registration"),
        backgroundColor: primaryColor,
      ),
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 30),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    // Full Name Field
                    CustomTextField(
                      controller: nameController,
                      hintText: 'Enter Full Name',
                      prefix: Icon(Icons.person, color: Colors.grey),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter your full name';
                        }
                        return null;
                      },
                    ),
                    SizedBox(height: 15),

                    // Email Field
                    CustomTextField(
                      controller: emailController,
                      hintText: 'Enter Email',
                      prefix: Icon(Icons.email, color: Colors.grey),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter your email';
                        } else if (!RegExp(
                                r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$')
                            .hasMatch(value)) {
                          return 'Enter a valid email address';
                        }
                        return null;
                      },
                    ),
                    SizedBox(height: 15),

                    // Guardian Email Field
                    CustomTextField(
                      controller: guardianEmailController,
                      hintText: 'Enter Guardian Email',
                      prefix: Icon(Icons.email, color: Colors.grey),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter guardian email';
                        }
                        return null;
                      },
                    ),
                    SizedBox(height: 15),

                    // Password Field
                    CustomTextField(
                      controller: passwordController,
                      hintText: 'Enter Password',
                      isPassword: !isPasswordVisible,
                      prefix: Icon(Icons.lock, color: Colors.grey),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter a password';
                        } else if (value.length < 6) {
                          return 'Password must be at least 6 characters';
                        }
                        return null;
                      },
                    ),
                    SizedBox(height: 20),

                    // Register Button with progress indicator
                    isLoading
                        ? CircularProgressIndicator()
                        : PrimaryButton(
                            title: 'REGISTER',
                            onPressed: _onSubmit,
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