import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:title_proj/child/LoginScreen.dart';
import 'package:title_proj/utils/constants.dart';

class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
          child: TextButton(
              onPressed: () async {
                try {
                  await FirebaseAuth.instance.signOut();
                  goTo(context, LoginScreen());
                } on FirebaseAuthException catch (e) {
                  dialogueBox(context, e.toString());
                }
              },
              child: Text("SIGN OUT"))),
    );
  }
}
