import 'package:flutter/material.dart';
import 'package:title_proj/components/PrimaryButton.dart';
import 'package:title_proj/components/SecondaryButton.dart';
import 'package:title_proj/components/custom_textfield.dart';
import 'package:title_proj/utils/constants.dart';

class parent_register_screen extends StatefulWidget {
  const parent_register_screen({super.key});

  @override
  State<parent_register_screen> createState() => _ParentRegisterScreenState();
}

class _ParentRegisterScreenState extends State<parent_register_screen> {
  final _formKey = GlobalKey<FormState>();
  final Map<String, String> _formData = {};

  bool isPasswordVisible = false;
  bool isConfirmPasswordVisible = false;

  TextEditingController nameController = TextEditingController();
  TextEditingController emailController = TextEditingController();
  TextEditingController phoneController = TextEditingController();
  TextEditingController childEmailController = TextEditingController();
  TextEditingController passwordController = TextEditingController();
  TextEditingController confirmPasswordController = TextEditingController();

  // Submit function
  void _onSubmit() {
    if (_formKey.currentState!.validate()) {
      progressIndicator(context);
      _formKey.currentState!.save(); // Save the form data
      print(_formData);
      // Handle Registration Logic Here
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 30),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  // Heading
                  Text(
                    "REGISTER AS PARENT",
                    style: TextStyle(
                      fontSize: 32,
                      color: primaryColor,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 15),

                  // Logo
                  Image.asset(
                    'assets/SHEildlogo.png',
                    height: 150,
                    width: 200,
                  ),
                  SizedBox(height: 20),

                  // Name Field
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
                    onSaved: (value) {
                      _formData['name'] = value!;
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
                      } else if (value.length != 10) {
                        return 'Enter a valid 10-digit phone number';
                      }
                      return null;
                    },
                    onSaved: (value) {
                      _formData['phone'] = value!;
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
                    onSaved: (value) {
                      _formData['email'] = value!;
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
                      } else if (!RegExp(
                              r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$')
                          .hasMatch(value)) {
                        return 'Enter a valid email address';
                      }
                      return null;
                    },
                    onSaved: (value) {
                      _formData['child_email'] = value!;
                    },
                  ),
                  SizedBox(height: 15),

                  // Password Field
                  CustomTextField(
                    controller: passwordController,
                    hintText: 'Enter Password',
                    isPassword: !isPasswordVisible,
                    prefix: Icon(Icons.lock, color: Colors.grey),
                    suffix: IconButton(
                      icon: Icon(isPasswordVisible
                          ? Icons.visibility
                          : Icons.visibility_off),
                      onPressed: () => setState(
                          () => isPasswordVisible = !isPasswordVisible),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter your password';
                      } else if (value.length < 6) {
                        return 'Password must be at least 6 characters';
                      }
                      return null;
                    },
                    onSaved: (value) {
                      _formData['password'] = value!;
                    },
                  ),
                  SizedBox(height: 15),

                  // Confirm Password Field
                  CustomTextField(
                    controller: confirmPasswordController,
                    hintText: 'Retype Password',
                    isPassword: !isConfirmPasswordVisible,
                    prefix: Icon(Icons.lock, color: Colors.grey),
                    suffix: IconButton(
                      icon: Icon(isConfirmPasswordVisible
                          ? Icons.visibility
                          : Icons.visibility_off),
                      onPressed: () => setState(() =>
                          isConfirmPasswordVisible =
                              !isConfirmPasswordVisible),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please confirm your password';
                      } else if (value != passwordController.text) {
                        return 'Passwords do not match';
                      }
                      return null;
                    },
                  ),
                  SizedBox(height: 20),

                  // Register Button
                  PrimaryButton(
                    title: 'REGISTER',
                    onPressed: _onSubmit,
                  ),
                  SizedBox(height: 20),

                  // Already have an account? Login
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text("Already have an account? "),
                      SecondaryButton(
                        title: 'Login',
                        onPressed: () => Navigator.pop(context),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
