import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:geolocator/geolocator.dart';
import 'package:image_picker/image_picker.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:sensors_plus/sensors_plus.dart';
import 'package:http/http.dart' as http;
import 'package:title_proj/child/WelcomeScreen.dart';
import 'package:title_proj/child/bottom_page.dart';
import 'package:title_proj/components/custom_textfield.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  // Controllers
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _emergencyContactController = TextEditingController();

  // State variables
  String? _profileImageUrl;
  bool _isLoading = false;
  bool _notificationsEnabled = true;
  bool _shakeSOSEnabled = false;
  bool _isShakeActive = false;
  StreamSubscription<UserAccelerometerEvent>? _accelerometerSubscription;
  Position? _currentPosition;

  // Constants
  final double _shakeThreshold = 2.7; // Adjust sensitivity (2.5-3.5 is typical)
  final int _minShakeIntervalMs = 2000; // Minimum time between shakes (2 seconds)

  @override
  void initState() {
    super.initState();
    _loadUserData();
    _initShakeDetection();
  }

  @override
  void dispose() {
    _accelerometerSubscription?.cancel();
    super.dispose();
  }

  Future<void> _loadUserData() async {
    setState(() => _isLoading = true);
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        final doc = await FirebaseFirestore.instance
            .collection('users')
            .doc(user.uid)
            .get();

        if (doc.exists) {
          setState(() {
            _nameController.text = doc['name'] ?? '';
            _emailController.text = user.email ?? '';
            _phoneController.text = doc['phone'] ?? '';
            _emergencyContactController.text = doc['emergencyContact'] ?? '';
            _profileImageUrl = doc['profileImageUrl'];
            _notificationsEnabled = doc['notificationsEnabled'] ?? true;
            _shakeSOSEnabled = doc['shakeSOSEnabled'] ?? false;
            _isShakeActive = _shakeSOSEnabled;
          });

          if (_shakeSOSEnabled) {
            _startShakeDetection();
          }
        }
      }
    } catch (e) {
      debugPrint('Error loading user data: $e');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  void _initShakeDetection() {
    _accelerometerSubscription = userAccelerometerEvents.listen((event) {
      if (!_isShakeActive) return;

      final now = DateTime.now();
      final timeSinceLastShake = now.difference(_lastShakeTime).inMilliseconds;

      if (timeSinceLastShake < _minShakeIntervalMs) return;

      final acceleration = (event.x.abs() + event.y.abs() + event.z.abs()) / 3;

      if (acceleration > _shakeThreshold) {
        _lastShakeTime = now;
        _triggerSOS();
      }
    });
  }

  DateTime _lastShakeTime = DateTime.now();

  Future<void> _triggerSOS() async {
    if (_emergencyContactController.text.isEmpty) {
      Fluttertoast.showToast(msg: 'No emergency contact set!');
      return;
    }

    setState(() => _isLoading = true);
    
    try {
      // Get current location
      _currentPosition = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );

      // Send SMS via Twilio
      final success = await _sendEmergencySMS();

      Fluttertoast.showToast(
        msg: success 
            ? 'Emergency alert sent!'
            : 'Failed to send alert',
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
    await dotenv.load();
    final accountSid = dotenv.get('TWILIO_ACCOUNT_SID');
    final authToken = dotenv.get('TWILIO_AUTH_TOKEN');
    final twilioNumber = dotenv.get('TWILIO_PHONE_NUMBER');

    final locationUrl = 'https://maps.google.com/?q=${_currentPosition!.latitude},${_currentPosition!.longitude}';
    final message = 'EMERGENCY! ${_nameController.text} needs help! Location: $locationUrl';

    final response = await http.post(
      Uri.parse('https://api.twilio.com/2010-04-01/Accounts/$accountSid/Messages.json'),
      headers: {
        'Content-Type': 'application/x-www-form-urlencoded',
        'Authorization': 'Basic ${base64Encode(utf8.encode('$accountSid:$authToken'))}',
      },
      body: {
        'From': twilioNumber,
        'To': _emergencyContactController.text,
        'Body': message,
      },
    );

    return response.statusCode == 201;
  }

  void _startShakeDetection() async {
    final status = await Permission.sensors.status;
    if (!status.isGranted) {
      await Permission.sensors.request();
    }
    setState(() => _isShakeActive = true);
  }

  void _stopShakeDetection() {
    setState(() => _isShakeActive = false);
  }

  Future<void> _updateProfile() async {
    setState(() => _isLoading = true);
    try {
      final user = FirebaseAuth.instance.currentUser!;
      await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .update({
            'name': _nameController.text,
            'phone': _phoneController.text,
            'emergencyContact': _emergencyContactController.text,
            'notificationsEnabled': _notificationsEnabled,
            'shakeSOSEnabled': _shakeSOSEnabled,
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

      setState(() => _isLoading = true);
      // Here you would upload to Firebase Storage and get URL
      // For now we'll just use the local path
      setState(() => _profileImageUrl = image.path);
      
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
          IconButton(
            icon: const Icon(Icons.save),
            onPressed: _updateProfile,
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  // Profile Picture
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

                  // Profile Form
                  TextFormField(
                    controller: _nameController,
                    decoration: const InputDecoration(labelText: 'Full Name'),
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _emailController,
                    decoration: const InputDecoration(labelText: 'Email'),
                    readOnly: true,
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _phoneController,
                    decoration: const InputDecoration(labelText: 'Phone'),
                    keyboardType: TextInputType.phone,
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _emergencyContactController,
                    decoration: const InputDecoration(
                      labelText: 'Emergency Contact',
                      hintText: '+1234567890',
                      prefixText: '+',
                    ),
                    keyboardType: TextInputType.phone,
                  ),
                  const SizedBox(height: 24),

                  // SOS Settings
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        children: [
                          SwitchListTile(
                            title: const Text('Enable Shake SOS'),
                            value: _shakeSOSEnabled,
                            onChanged: (value) async {
                              setState(() => _shakeSOSEnabled = value);
                              if (value) {
                                await Permission.location.request();
                                await Permission.sms.request();
                                _startShakeDetection();
                              } else {
                                _stopShakeDetection();
                              }
                            },
                          ),
                          if (_shakeSOSEnabled) ...[
                            const SizedBox(height: 8),
                            const Text(
                              'Shake your phone to trigger emergency alert',
                              style: TextStyle(color: Colors.grey, fontSize: 12),
                            ),
                            const SizedBox(height: 8),
                            OutlinedButton(
                              onPressed: _triggerSOS,
                              child: const Text('TEST SOS NOW'),
                            ),
                          ],
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Notifications
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