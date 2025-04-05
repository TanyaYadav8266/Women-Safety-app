// (Keep your imports unchanged)
import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:image_picker/image_picker.dart';
import 'package:title_proj/child/WelcomeScreen.dart';
import 'package:title_proj/child/bottom_page.dart';
import 'package:title_proj/components/PrimaryButton.dart';
import 'package:title_proj/components/custom_textfield.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  final TextEditingController emailC = TextEditingController();
  final TextEditingController phoneC = TextEditingController();
  final TextEditingController nameC = TextEditingController();

  final GlobalKey<FormState> key = GlobalKey<FormState>();
  String? profilePic;
  String? username;
  bool isSaving = false;
  bool notificationsEnabled = true;
  bool shakeToAlertEnabled = true;

  final LinearGradient _buttonGradient = const LinearGradient(
    colors: [Color(0xFFEC407A), Color(0xFFAB47BC)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        final doc = await FirebaseFirestore.instance
            .collection('users')
            .doc(user.uid)
            .get();

        if (doc.exists) {
          setState(() {
            nameC.text = doc['name'] ?? user.displayName ?? '';
            username = doc['username'] ?? user.email?.split('@').first ?? '';
            emailC.text = user.email ?? '';
            phoneC.text = doc['phone'] ?? '';
            profilePic = doc.data()?.containsKey('profilePic') == true
                ? doc['profilePic']
                : null;
            notificationsEnabled = doc['notifications'] ?? true;
            shakeToAlertEnabled = doc['shakeToAlert'] ?? true;
          });
        }
      }
    } catch (e) {
      debugPrint('Failed to load profile data: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: isSaving
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              child: Column(
                children: [
                  Stack(
                    children: [
                      Container(
                        height: 250,
                        width: double.infinity,
                        decoration: const BoxDecoration(
                          image: DecorationImage(
                            image: AssetImage('assets/bgpic.png'),
                            fit: BoxFit.cover,
                          ),
                        ),
                      ),
                      Positioned(
                        top: 40,
                        left: 10,
                        child: IconButton(
                          icon:
                              const Icon(Icons.arrow_back, color: Colors.white),
                          onPressed: () {
                            Navigator.pushReplacement(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => const BottomPage()),
                            );
                          },
                        ),
                      ),
                      Center(
                        child: Padding(
                          padding: const EdgeInsets.only(top: 80),
                          child: Column(
                            children: [
                              GestureDetector(
                                onTap: _updateProfilePicture,
                                child: CircleAvatar(
                                  radius: 50,
                                  backgroundColor:
                                      Colors.white.withOpacity(0.3),
                                  backgroundImage: _getProfileImage(),
                                  child: _getProfileImage() == null
                                      ? const Icon(Icons.person,
                                          size: 40, color: Colors.white)
                                      : null,
                                ),
                              ),
                              const SizedBox(height: 10),
                              if (nameC.text.isNotEmpty)
                                Text(
                                  nameC.text,
                                  style: const TextStyle(
                                    fontSize: 20,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white,
                                  ),
                                ),
                              if (username != null && username!.isNotEmpty)
                                Text(
                                  '@$username',
                                  style: const TextStyle(
                                    fontSize: 16,
                                    color: Colors.white70,
                                  ),
                                ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                  Padding(
                    padding: const EdgeInsets.all(18.0),
                    child: Column(
                      children: [
                        Card(
                          elevation: 4,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(15),
                          ),
                          child: Padding(
                            padding: const EdgeInsets.all(16.0),
                            child: Form(
                              key: key,
                              child: Column(
                                children: [
                                  CustomTextField(
                                    controller: nameC,
                                    hintText: "Full Name",
                                  ),
                                  const SizedBox(height: 15),
                                  CustomTextField(
                                    controller: emailC,
                                    hintText: "Email",
                                    readOnly: true,
                                  ),
                                  const SizedBox(height: 15),
                                  CustomTextField(
                                    controller: phoneC,
                                    hintText: "Phone Number",
                                  ),
                                  const SizedBox(height: 20),
                                  SizedBox(
                                    width: double.infinity,
                                    child: ElevatedButton(
                                      onPressed: _updateProfile,
                                      style: ElevatedButton.styleFrom(
                                        foregroundColor: Colors.white,
                                        backgroundColor: Colors.transparent,
                                        shadowColor: Colors.transparent,
                                        minimumSize:
                                            const Size(double.infinity, 50),
                                        shape: RoundedRectangleBorder(
                                          borderRadius:
                                              BorderRadius.circular(8),
                                        ),
                                      ),
                                      child: Container(
                                        decoration: BoxDecoration(
                                          gradient: _buttonGradient,
                                          borderRadius:
                                              BorderRadius.circular(8),
                                        ),
                                        child: const Padding(
                                          padding: EdgeInsets.all(12.0),
                                          child: Center(
                                            child: Text(
                                              "UPDATE PROFILE",
                                              style: TextStyle(
                                                fontSize: 16,
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 20),
                        Card(
                          elevation: 4,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(15),
                          ),
                          child: Padding(
                            padding: const EdgeInsets.all(12.0),
                            child: Column(
                              children: [
                                SwitchListTile(
                                  title: const Text('Enable Notifications'),
                                  value: notificationsEnabled,
                                  onChanged: (value) {
                                    setState(
                                        () => notificationsEnabled = value);
                                    _updateNotificationSettings();
                                  },
                                  activeColor: Color(0xFFEC407A),
                                ),
                                SwitchListTile(
                                  title: const Text('Shake to Alert'),
                                  value: shakeToAlertEnabled,
                                  onChanged: (value) {
                                    setState(() => shakeToAlertEnabled = value);
                                    _updateShakeToAlertSettings();
                                  },
                                  activeColor: Color(0xFFEC407A),
                                ),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(height: 20),
                        SizedBox(
                          width: double.infinity,
                          child: Container(
                            decoration: BoxDecoration(
                              gradient: _buttonGradient,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: ElevatedButton(
                              onPressed: _logout,
                              style: ElevatedButton.styleFrom(
                                foregroundColor: Colors.white,
                                backgroundColor: Color(0xFFEC407A),
                                shadowColor: Colors.transparent,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                padding:
                                    const EdgeInsets.symmetric(vertical: 16),
                              ),
                              child: const Text(
                                'LOGOUT',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
    );
  }

  ImageProvider? _getProfileImage() {
    if (profilePic == null) return null;
    if (profilePic!.startsWith('http')) return NetworkImage(profilePic!);
    return FileImage(File(profilePic!));
  }

  Future<void> _updateProfilePicture() async {
    try {
      final picker = ImagePicker();
      final pickedFile = await picker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 85,
      );

      if (pickedFile != null) {
        setState(() {
          isSaving = true;
          profilePic = pickedFile.path;
        });

        // Store the image path in Firestore (not uploading)
        await FirebaseFirestore.instance
            .collection('users')
            .doc(FirebaseAuth.instance.currentUser!.uid)
            .update({
          'profilePic': pickedFile.path,
        });

        Fluttertoast.showToast(msg: 'Profile picture updated locally');
      }
    } catch (e) {
      debugPrint('Error picking image: $e');
      Fluttertoast.showToast(msg: 'Failed to update profile picture');
    } finally {
      setState(() => isSaving = false);
    }
  }

  Future<void> _updateProfile() async {
    if (!key.currentState!.validate()) return;

    setState(() => isSaving = true);

    try {
      final updateData = <String, dynamic>{
        'name': nameC.text,
        'phone': phoneC.text,
      };

      if (profilePic != null) {
        updateData['profilePic'] = profilePic!;
      }

      await FirebaseFirestore.instance
          .collection('users')
          .doc(FirebaseAuth.instance.currentUser!.uid)
          .update(updateData);

      Fluttertoast.showToast(msg: 'Profile updated successfully');
      await _loadUserData();
    } catch (e) {
      debugPrint('Update error: $e');
      Fluttertoast.showToast(msg: 'Failed to update profile');
    } finally {
      setState(() => isSaving = false);
    }
  }

  Future<void> _updateNotificationSettings() async {
    try {
      await FirebaseFirestore.instance
          .collection('users')
          .doc(FirebaseAuth.instance.currentUser!.uid)
          .update({
        'notifications': notificationsEnabled,
      });
    } catch (e) {
      Fluttertoast.showToast(msg: 'Failed to update notification settings');
    }
  }

  Future<void> _updateShakeToAlertSettings() async {
    try {
      await FirebaseFirestore.instance
          .collection('users')
          .doc(FirebaseAuth.instance.currentUser!.uid)
          .update({
        'shakeToAlert': shakeToAlertEnabled,
      });
    } catch (e) {
      Fluttertoast.showToast(msg: 'Failed to update shake to alert settings');
    }
  }

  Future<void> _logout() async {
    try {
      await FirebaseAuth.instance.signOut();
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (context) => WelcomeScreen()),
        (route) => false,
      );
    } catch (e) {
      Fluttertoast.showToast(msg: 'Failed to logout: ${e.toString()}');
    }
  }
}
