import 'package:flutter/material.dart';

class CustomTextField extends StatelessWidget {
  final String hintText;
  final Widget? prefix;
  final Widget? suffix;
  final bool isPassword;
  final TextEditingController? controller;
  final FormFieldValidator<String>? validator; // Added validator

  const CustomTextField({
    Key? key,
    required this.hintText,
    this.prefix,
    this.suffix,
    this.isPassword = false,
    this.controller,
    this.validator, // Initialize validator
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      obscureText: isPassword,
      decoration: InputDecoration(
        hintText: hintText,
        prefixIcon: prefix,
        suffixIcon: suffix,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
      ),
      validator: validator, // Enable validation
    );
  }
}
