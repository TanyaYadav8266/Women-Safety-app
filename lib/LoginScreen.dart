import 'package:flutter/material.dart';
import 'package:title_proj/components/custom_textfield.dart';


class LoginScreen extends StatelessWidget {
  const LoginScreen({Key?key}): super(key:key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            children: [
              CustomTextField(
                hintText: 'enter name',
                prefix: Icon(Icons.person),
              ),
                ],
                ),
        ))
    );
  }
}