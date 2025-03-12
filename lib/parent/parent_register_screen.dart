import 'package:flutter/material.dart';
import 'package:title_proj/components/PrimaryButton.dart';
import 'package:title_proj/components/SecondaryButton.dart';
import 'package:title_proj/components/custom_textfield.dart';
import 'package:title_proj/utils/constants.dart';

class parent_register_screen extends StatefulWidget {
  const parent_register_screen({super.key});

  @override
  State<parent_register_screen> createState() => _parent_register_screen();
}

class _parent_register_screen extends State<parent_register_screen> {
  final _formKey = GlobalKey<FormState>();
  bool isPasswordVisible = false;
  bool isConfirmPasswordVisible = false;
  String? gender;
  DateTime? selectedDate;

  TextEditingController nameController = TextEditingController();
  TextEditingController emailController = TextEditingController();
  TextEditingController phoneController = TextEditingController();
  TextEditingController passwordController = TextEditingController();
  TextEditingController confirmPasswordController = TextEditingController();

  // Date Picker
  Future<void> _selectDate(BuildContext context) async {
    DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
    );

    if (picked != null && picked != selectedDate) {
      setState(() {
        selectedDate = picked;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
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
                    // Register Heading
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
                    ),
                    SizedBox(height: 15),

                    // Gender Dropdown
                    DropdownButtonFormField<String>(
                      value: gender,
                      hint: Text("Select Gender"),
                      items: ['Male', 'Female', 'Other']
                          .map((label) => DropdownMenuItem(
                                child: Text(label),
                                value: label,
                              ))
                          .toList(),
                      onChanged: (value) {
                        setState(() {
                          gender = value;
                        });
                      },
                      decoration: InputDecoration(
                        filled: true,
                        fillColor: Colors.grey[200],
                        border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10)),
                        contentPadding:
                            EdgeInsets.symmetric(vertical: 10, horizontal: 15),
                      ),
                      validator: (value) {
                        if (value == null) {
                          return 'Please select a gender';
                        }
                        return null;
                      },
                    ),
                    SizedBox(height: 15),

                    // Date of Birth Picker
                    GestureDetector(
                      onTap: () => _selectDate(context),
                      child: Container(
                        padding:
                            EdgeInsets.symmetric(vertical: 14, horizontal: 16),
                        width: double.infinity,
                        decoration: BoxDecoration(
                          color: Colors.grey[200],
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(color: Colors.grey),
                        ),
                        child: Text(
                          selectedDate == null
                              ? "Select Date of Birth"
                              : "${selectedDate!.day}/${selectedDate!.month}/${selectedDate!.year}",
                          style: TextStyle(fontSize: 16, color: Colors.black87),
                        ),
                      ),
                    ),
                    SizedBox(height: 15),

                    // Password Field
                    CustomTextField(
                      controller: passwordController,
                      hintText: 'Enter Password',
                      isPassword: !isPasswordVisible,
                      prefix: Icon(Icons.lock, color: Colors.grey),
                      suffix: IconButton(
                        icon: Icon(
                          isPasswordVisible
                              ? Icons.visibility_off
                              : Icons.visibility,
                          color: Colors.grey,
                        ),
                        onPressed: () {
                          setState(() {
                            isPasswordVisible = !isPasswordVisible;
                          });
                        },
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter a password';
                        } else if (value.length < 6) {
                          return 'Password must be at least 6 characters';
                        }
                        return null;
                      },
                    ),
                    SizedBox(height: 15),

                    // Confirm Password Field
                    CustomTextField(
                      controller: confirmPasswordController,
                      hintText: 'Confirm Password',
                      isPassword: !isConfirmPasswordVisible,
                      prefix: Icon(Icons.lock, color: Colors.grey),
                      suffix: IconButton(
                        icon: Icon(
                          isConfirmPasswordVisible
                              ? Icons.visibility_off
                              : Icons.visibility,
                          color: Colors.grey,
                        ),
                        onPressed: () {
                          setState(() {
                            isConfirmPasswordVisible =
                                !isConfirmPasswordVisible;
                          });
                        },
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
                      onPressed: () {
                        if (_formKey.currentState!.validate()) {
                          // Handle Registration Logic Here
                        }
                      },
                    ),
                    SizedBox(height: 20),

                    // Already have an account? Login
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          "Already have an account?",
                          style: TextStyle(fontSize: 16),
                        ),
                        SecondaryButton(
                          title: 'Login',
                          onPressed: () {
                            Navigator.pop(context);
                          },
                        ),
                      ],
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
