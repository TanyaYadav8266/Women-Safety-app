import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:geolocator/geolocator.dart';
import 'package:image_picker/image_picker.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:http/http.dart' as http;
import 'package:speech_to_text/speech_to_text.dart' as stt;

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _emergencyContactController = TextEditingController();
  final TextEditingController _codeWordController = TextEditingController();

  String? _profileImageUrl;
  bool _isLoading = false;
  bool _notificationsEnabled = true;

  Position? _currentPosition;

  // Twilio Credentials
  final String twilioAccountSid = 'ACf9f5049fb42a7462d7cd83dfc8311280';
  final String twilioAuthToken = '8de7027b99f6a71f5d95b0ce46df9723';
  final String twilioPhoneNumber = '+14632836151';
  final String hardcodedSOSNumber = '+918448018504'; // Replace with desired number

  late stt.SpeechToText _speech;
  bool _isListening = false;

  @override
  void initState() {
    super.initState();
    _loadUserData();
    _speech = stt.SpeechToText();
  }

  Future<void> _loadUserData() async {
    setState(() => _isLoading = true);
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        final doc = await FirebaseFirestore.instance.collection('users').doc(user.uid).get();
        if (doc.exists) {
          setState(() {
            _nameController.text = doc['name'] ?? '';
            _emailController.text = user.email ?? '';
            _phoneController.text = doc['phone'] ?? '';
            _emergencyContactController.text = doc['emergencyContact'] ?? '';
            _profileImageUrl = doc['profileImageUrl'];
            _notificationsEnabled = doc['notificationsEnabled'] ?? true;
          });
        }
      }
    } catch (e) {
      debugPrint('Error loading user data: $e');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  void _startCodeWordListening() async {
    final status = await Permission.microphone.request();
    if (!status.isGranted) {
      Fluttertoast.showToast(msg: 'Microphone permission is required');
      return;
    }

    bool available = await _speech.initialize(
      onStatus: (status) {
        if (status == 'done' || status == 'notListening') {
          if (!_isListening) {
            _startCodeWordListening(); // Keep listening
          }
        }
      },
      onError: (error) {
        debugPrint('Speech error: $error');
        _startCodeWordListening(); // Keep listening on error
      },
    );

    if (available) {
      setState(() => _isListening = true);
      _speech.listen(
        onResult: (result) async {
          final spoken = result.recognizedWords.toLowerCase().trim();
          final codeWord = _codeWordController.text.toLowerCase().trim();
          debugPrint('Heard: $spoken');
          if (spoken.contains(codeWord)) {
            _speech.stop();
            setState(() => _isListening = false);
            await _triggerSOS();
          }
        },
        listenMode: stt.ListenMode.confirmation,
        partialResults: true,
      );
    }
  }

  Future<void> _triggerSOS() async {
    if (_nameController.text.isEmpty) {
      Fluttertoast.showToast(msg: 'Name is empty!');
      return;
    }

    setState(() => _isLoading = true);
    try {
      _currentPosition = await Geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.high);
      final success = await _sendEmergencySMS();
      Fluttertoast.showToast(
        msg: success ? 'Emergency alert sent!' : 'Failed to send alert',
        backgroundColor: success ? Colors.green : Colors.red,
      );
    } catch (e) {
      debugPrint('SOS Error: $e');
      Fluttertoast.showToast(
        msg: 'Emergency failed: ${e.toString()}',
        backgroundColor: Colors.red,
      );
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<bool> _sendEmergencySMS() async {
    final locationUrl = 'https://maps.google.com/?q=${_currentPosition!.latitude},${_currentPosition!.longitude}';
    final message = 'EMERGENCY! ${_nameController.text} needs help! Location: $locationUrl';

    final response = await http.post(
      Uri.parse('https://api.twilio.com/2010-04-01/Accounts/$twilioAccountSid/Messages.json'),
      headers: {
        'Content-Type': 'application/x-www-form-urlencoded',
        'Authorization': 'Basic ${base64Encode(utf8.encode('$twilioAccountSid:$twilioAuthToken'))}',
      },
      body: {
        'From': twilioPhoneNumber,
        'To': hardcodedSOSNumber,
        'Body': message,
      },
    );

    return response.statusCode == 201 || response.statusCode == 200;
  }

  Future<void> _updateProfile() async {
    setState(() => _isLoading = true);
    try {
      final user = FirebaseAuth.instance.currentUser!;
      await FirebaseFirestore.instance.collection('users').doc(user.uid).update({
        'name': _nameController.text,
        'phone': _phoneController.text,
        'emergencyContact': _emergencyContactController.text,
        'notificationsEnabled': _notificationsEnabled,
      });
      Fluttertoast.showToast(msg: 'Profile updated');
    } catch (e) {
      debugPrint('Update error: $e');
      Fluttertoast.showToast(msg: 'Update failed');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _updateProfilePicture() async {
    try {
      final image = await ImagePicker().pickImage(source: ImageSource.gallery);
      if (image == null) return;

      setState(() {
        _isLoading = true;
        _profileImageUrl = image.path;
      });

      await FirebaseFirestore.instance
          .collection('users')
          .doc(FirebaseAuth.instance.currentUser!.uid)
          .update({'profileImageUrl': image.path});
    } catch (e) {
      debugPrint('Image error: $e');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Profile'),
        actions: [
          IconButton(icon: const Icon(Icons.save), onPressed: _updateProfile),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  GestureDetector(
                    onTap: _updateProfilePicture,
                    child: CircleAvatar(
                      radius: 50,
                      backgroundImage: _profileImageUrl != null
                          ? _profileImageUrl!.startsWith('http')
                              ? NetworkImage(_profileImageUrl!)
                              : FileImage(File(_profileImageUrl!)) as ImageProvider
                          : null,
                      child: _profileImageUrl == null
                          ? const Icon(Icons.person, size: 50)
                          : null,
                    ),
                  ),
                  const SizedBox(height: 20),
                  TextFormField(controller: _nameController, decoration: const InputDecoration(labelText: 'Full Name')),
                  const SizedBox(height: 16),
                  TextFormField(controller: _emailController, decoration: const InputDecoration(labelText: 'Email'), readOnly: true),
                  const SizedBox(height: 16),
                  TextFormField(controller: _phoneController, decoration: const InputDecoration(labelText: 'Phone'), keyboardType: TextInputType.phone),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _emergencyContactController,
                    decoration: const InputDecoration(labelText: 'Emergency Contact', hintText: '+1234567890'),
                    keyboardType: TextInputType.phone,
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _codeWordController,
                    decoration: const InputDecoration(labelText: 'Code Word (e.g. help me)'),
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton.icon(
                    icon: const Icon(Icons.mic),
                    label: const Text('Start Code Word Listener'),
                    onPressed: _startCodeWordListening,
                  ),
                  const SizedBox(height: 24),
                  SwitchListTile(
                    title: const Text('Enable Notifications'),
                    value: _notificationsEnabled,
                    onChanged: (value) => setState(() => _notificationsEnabled = value),
                  ),
                ],
              ),
            ),
    );
  }
}
