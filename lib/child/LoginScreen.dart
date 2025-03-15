import 'package:flutter/material.dart';
import 'package:title_proj/components/PrimaryButton.dart';
import 'package:title_proj/components/SecondaryButton.dart';
import 'package:title_proj/components/custom_textfield.dart';
import 'package:title_proj/child/register_child.dart';
import 'package:title_proj/parent/parent_register_screen.dart';
import 'package:title_proj/utils/constants.dart';

class LoginScreen extends StatefulWidget {
  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>(); // Form key for validation
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  bool isPasswordShown = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            child: Padding(
              padding:
                  const EdgeInsets.symmetric(horizontal: 20.0, vertical: 30),
              child: Form(
                key: _formKey, // Attach form key
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    // User Login Heading
                    Text(
                      "USER LOGIN",
                      style: TextStyle(
                        fontSize: 48,
                        color: primaryColor,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 10),

                    // Logo
                    Image.asset(
                      'assets/SHEildlogo.png',
                      height: 250,
                      width: 450,
                    ),
                    SizedBox(height: 10),

                    // Username Field
                    CustomTextField(
                      controller: _usernameController,
                      hintText: 'Enter Username',
                      prefix: Icon(Icons.person, color: Colors.grey),
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'Username is required';
                        }
                        return null;
                      },
                    ),
                    SizedBox(height: 15),

                    // Password Field
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

                    // Login Button with Validation
                    PrimaryButton(
                      title: 'LOGIN',
                      onPressed: () {
                        progressIndicator(context);
                       // if (_formKey.currentState!.validate()) {
                          // If form is valid, proceed
                         // ScaffoldMessenger.of(context).showSnackBar(
                           // SnackBar(content: Text('Logging in...')),
                          //);
                          // Call login function here
                       // }
                      },
                    ),
                    SizedBox(height: 20),

                    // Forgot Password
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          "Forgot Password?",
                          style: TextStyle(fontSize: 16),
                        ),
                        SecondaryButton(
                          title: 'Click Here',
                          onPressed: () {},
                        ),
                      ],
                    ),
                    SizedBox(height: 15),

                    // Register New User
                    SecondaryButton(
                        title: 'Register New User',
                        onPressed: () {
                          goTo(context, register_child());
                        }),
                        SecondaryButton(
                        title: 'Register As Guardian',
                        onPressed: () {
                          goTo(context, parent_register_screen());
                        }),
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
