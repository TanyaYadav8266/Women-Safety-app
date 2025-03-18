import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:title_proj/components/PrimaryButton.dart';
import 'package:title_proj/components/custom_textfield.dart';
import 'package:title_proj/utils/constants.dart';
import 'package:title_proj/model/user_model.dart';

class ParentRegisterScreen extends StatefulWidget {
  const ParentRegisterScreen({super.key});

  @override
  State<ParentRegisterScreen> createState() => _ParentRegisterScreenState();
}

class _ParentRegisterScreenState extends State<ParentRegisterScreen> {
  final _formKey = GlobalKey<FormState>();

  // Controllers for input fields
  TextEditingController nameController = TextEditingController();
  TextEditingController emailController = TextEditingController();
  TextEditingController phoneController = TextEditingController();
  TextEditingController childEmailController = TextEditingController();
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
          childEmail: childEmailController.text.trim(),
          guardianEmail: emailController.text.trim(),
          type: "guardian",  // Default user type as "guardian"
          profilePic: "",
        );

        // Store user details in Firestore Database
        await _firestore.collection('users').doc(user.id).set(user.toJson());

        // Navigate to login screen after successful registration
        Navigator.pop(context);

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
        title: Text("Parent Registration"),
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

                    // Phone Number Field
                    CustomTextField(
                      controller: phoneController,
                      hintText: 'Enter Phone Number',
                      prefix: Icon(Icons.phone, color: Colors.grey),
                      keyboardType: TextInputType.phone,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter your phone number';
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
                        }
                        return null;
                      },
                    ),
                    SizedBox(height: 15),

                    // Child Email Field
                    CustomTextField(
                      controller: childEmailController,
                      hintText: 'Enter Child Email',
                      prefix: Icon(Icons.child_care, color: Colors.grey),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter child email';
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
