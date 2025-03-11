import 'package:flutter/material.dart';
import 'package:title_proj/components/PrimaryButton.dart';
import 'package:title_proj/components/SecondaryButton.dart';
import 'package:title_proj/components/custom_textfield.dart';
import 'package:title_proj/utils/constants.dart';

class LoginScreen extends StatelessWidget {
  const LoginScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 30),
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
                  SizedBox(height: 10,
                  width: 50,),

                  // Username Field
                  CustomTextField(
                    hintText: 'Enter Username',
                    prefix: Icon(Icons.person, color: Colors.grey),
                  ),
                  SizedBox(height: 15),

                  // Password Field
                  CustomTextField(
                    hintText: 'Enter Password',
                    prefix: Icon(Icons.lock, color: Colors.grey),
                    isPassword: true,
                  ),
                  SizedBox(height: 20),

                  // Register Button
                  PrimaryButton(
                    title: 'REGISTER',
                    onPressed: () {},
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
                    onPressed: () {},
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
