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
import 'package:sensors_plus/sensors_plus.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;
import 'package:another_telephony/telephony.dart';
import 'package:shared_preferences/shared_preferences.dart';

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
  bool _shakeToAlertEnabled = false;

  Position? _currentPosition;
  final Telephony telephony = Telephony.instance;
  StreamSubscription<AccelerometerEvent>? _accelerometerSubscription;
  double _shakeThreshold = 10.0;
  int _minShakeCount = 2;
  int _shakeCount = 0;
  DateTime? _lastShakeTime;
  Duration _shakeWindow = Duration(milliseconds: 800);

  late stt.SpeechToText _speech;
  bool _isListening = false;
  bool _sensorsAvailable = false;
  bool _isTestingShake = false;

  @override
  void initState() {
    super.initState();
    _speech = stt.SpeechToText();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _initializePage();
    });
  }

  Future<void> _initializePage() async {
    try {
      setState(() => _isLoading = true);
      await _loadUserData();
      await _checkPermissions();
      _sensorsAvailable = await _checkSensorsAvailable();
      
      if (_shakeToAlertEnabled && _sensorsAvailable) {
        await _startShakeDetection();
      }
    } catch (e) {
      debugPrint('Initialization error: $e');
      Fluttertoast.showToast(msg: 'Error initializing profile');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _checkPermissions() async {
    final statuses = await [
      Permission.location,
      Permission.microphone,
      Permission.sms,
    ].request();
    
    if (statuses[Permission.location]?.isDenied ?? true) {
      Fluttertoast.showToast(msg: 'Location permission required for emergency alerts');
    }
    if (statuses[Permission.sms]?.isDenied ?? true) {
      Fluttertoast.showToast(msg: 'SMS permission required for emergency alerts');
    }
  }

  @override
  void dispose() {
    _accelerometerSubscription?.cancel();
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _emergencyContactController.dispose();
    _codeWordController.dispose();
    super.dispose();
  }

  Future<void> _loadUserData() async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) {
        throw Exception('User not logged in');
      }

      final doc = await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .get();

      if (!doc.exists) {
        await _initializeUserData();
        return;
      }

      final data = doc.data() ?? {};

      setState(() {
        _nameController.text = data['name'] ?? '';
        _emailController.text = user.email ?? '';
        _phoneController.text = data['phone'] ?? '';
        _emergencyContactController.text = data['emergencyContact'] ?? '';
        _codeWordController.text = data['codeWord'] ?? '';
        _profileImageUrl = data['profileImageUrl'];
        _notificationsEnabled = data['notificationsEnabled'] ?? true;
        _shakeToAlertEnabled = data['shakeToAlertEnabled'] ?? false;
      });
    } catch (e) {
      debugPrint('Error loading user data: $e');
      Fluttertoast.showToast(msg: 'Error loading profile data');
      rethrow;
    }
  }

  Future<void> _initializeUserData() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    final docRef = FirebaseFirestore.instance.collection('users').doc(user.uid);
    
    await docRef.set({
      'name': user.displayName ?? '',
      'email': user.email ?? '',
      'phone': '',
      'emergencyContact': '',
      'codeWord': '',
      'notificationsEnabled': true,
      'shakeToAlertEnabled': false,
    }, SetOptions(merge: true));
  }

  Future<bool> _checkSensorsAvailable() async {
    try {
      await accelerometerEvents.first.timeout(Duration(milliseconds: 100));
      return true;
    } catch (e) {
      debugPrint('Sensor check error: $e');
      return false;
    }
  }

  Future<void> _startShakeDetection() async {
    if (!_sensorsAvailable) {
      Fluttertoast.showToast(msg: 'Shake detection not available on this device');
      return;
    }

    _accelerometerSubscription?.cancel();
    _accelerometerSubscription = accelerometerEvents.listen((event) {
      final double acceleration = (event.x * event.x + event.y * event.y + event.z * event.z);

      if (acceleration > _shakeThreshold) {
        final now = DateTime.now();
        
        if (_lastShakeTime == null || now.difference(_lastShakeTime!) > _shakeWindow) {
          _shakeCount = 1;
        } else {
          _shakeCount++;
        }
        
        _lastShakeTime = now;

        if (_shakeCount >= _minShakeCount) {
          _shakeCount = 0;
          if (!_isTestingShake) {
            debugPrint('Shake detected! Triggering SOS');
            _triggerSOS();
          } else {
            Fluttertoast.showToast(
              msg: 'Shake detected! Feature is working',
              backgroundColor: Colors.green,
            );
          }
        }
      }
    });
  }

  Future<void> _triggerSOS() async {
    if (_nameController.text.isEmpty || 
        (_emergencyContactController.text.isEmpty && _phoneController.text.isEmpty)) {
      Fluttertoast.showToast(msg: 'Please set your name and emergency contact first');
      return;
    }

    setState(() => _isLoading = true);
    try {
      try {
        _currentPosition = await Geolocator.getCurrentPosition(
          desiredAccuracy: LocationAccuracy.high,
          timeLimit: Duration(seconds: 5),
        );
      } catch (e) {
        debugPrint('Location error: $e');
        _currentPosition = null;
      }

      final recipient = _emergencyContactController.text.isNotEmpty 
          ? _emergencyContactController.text 
          : _phoneController.text;

      final success = await _sendEmergencySMS(recipient);
      if (success) {
        Fluttertoast.showToast(
          msg: 'Emergency alert sent!',
          backgroundColor: Colors.green,
        );
      } else {
        throw Exception('Failed to send emergency alert');
      }
    } catch (e) {
      debugPrint('SOS Error: $e');
      Fluttertoast.showToast(
        msg: 'Failed to send alert: ${e.toString()}',
        backgroundColor: Colors.red,
      );
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<bool> _sendEmergencySMS(String recipient) async {
    try {
      final locationInfo = _currentPosition != null
          ? 'https://maps.google.com/?q=${_currentPosition!.latitude},${_currentPosition!.longitude}'
          : 'Location unavailable';
      
      final message = 'EMERGENCY! ${_nameController.text} needs help!\n'
          'Location: $locationInfo\n'
          'Codeword: ${_codeWordController.text.isNotEmpty ? _codeWordController.text : "Not set"}';

      final hasPermission = await telephony.requestSmsPermissions;
      if (hasPermission != true) {
        throw Exception('SMS permission not granted');
      }

      await telephony.sendSms(to: recipient, message: message);
      return true;
    } catch (e) {
      debugPrint('SMS sending error: $e');
      return false;
    }
  }

  Future<void> _updateProfile() async {
    if (_nameController.text.isEmpty) {
      Fluttertoast.showToast(msg: 'Name cannot be empty');
      return;
    }

    setState(() => _isLoading = true);
    try {
      final user = FirebaseAuth.instance.currentUser!;
      final prefs = await SharedPreferences.getInstance();
      
      await FirebaseFirestore.instance.collection('users').doc(user.uid).update({
        'name': _nameController.text,
        'phone': _phoneController.text,
        'emergencyContact': _emergencyContactController.text,
        'codeWord': _codeWordController.text,
        'notificationsEnabled': _notificationsEnabled,
        'shakeToAlertEnabled': _shakeToAlertEnabled,
      });

      await prefs.setBool('shakeToAlertEnabled', _shakeToAlertEnabled);

      if (_shakeToAlertEnabled && _sensorsAvailable) {
        await _startShakeDetection();
      } else {
        _accelerometerSubscription?.cancel();
      }

      Fluttertoast.showToast(msg: 'Profile updated successfully');
    } catch (e) {
      debugPrint('Update error: $e');
      Fluttertoast.showToast(msg: 'Failed to update profile');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _updateProfilePicture() async {
    try {
      final image = await ImagePicker().pickImage(source: ImageSource.gallery);
      if (image == null) return;

      setState(() => _isLoading = true);
      _profileImageUrl = image.path;

      await FirebaseFirestore.instance
          .collection('users')
          .doc(FirebaseAuth.instance.currentUser!.uid)
          .update({'profileImageUrl': _profileImageUrl});

      Fluttertoast.showToast(msg: 'Profile picture updated');
    } catch (e) {
      debugPrint('Image error: $e');
      Fluttertoast.showToast(msg: 'Failed to update picture');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  void _toggleListening() async {
    if (_isListening) {
      await _speech.stop();
      setState(() => _isListening = false);
      Fluttertoast.showToast(msg: 'Stopped listening for code word');
      return;
    }

    if (_codeWordController.text.isEmpty) {
      Fluttertoast.showToast(msg: 'Please set a code word first');
      return;
    }

    final status = await Permission.microphone.request();
    if (!status.isGranted) {
      Fluttertoast.showToast(msg: 'Microphone permission required');
      return;
    }

    final available = await _speech.initialize();
    if (available) {
      setState(() => _isListening = true);
      Fluttertoast.showToast(
        msg: 'Listening for code word... Say "${_codeWordController.text}"',
        toastLength: Toast.LENGTH_LONG,
      );
      
      _speech.listen(
        listenMode: stt.ListenMode.dictation,
        onResult: (result) {
          final spoken = result.recognizedWords.toLowerCase();
          final codeWord = _codeWordController.text.toLowerCase();
          
          if (spoken.contains(codeWord)) {
            Fluttertoast.showToast(msg: 'Code word detected! Sending SOS');
            _triggerSOS();
          }
        },
        cancelOnError: true,
        partialResults: true,
      );
    } else {
      Fluttertoast.showToast(msg: 'Speech recognition not available');
    }
  }

  Future<void> _testShakeFeature() async {
    setState(() => _isTestingShake = true);
    Fluttertoast.showToast(
      msg: 'Shake your phone $_minShakeCount times to test',
      toastLength: Toast.LENGTH_LONG,
    );
    await Future.delayed(Duration(seconds: 10));
    setState(() => _isTestingShake = false);
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
                  _buildProfileForm(),
                  const SizedBox(height: 24),
                  _buildSafetyFeatures(),
                ],
              ),
            ),
    );
  }

  Widget _buildProfileForm() {
    return Column(
      children: [
        TextFormField(
          controller: _nameController,
          decoration: const InputDecoration(labelText: 'Full Name'),
          validator: (value) => value?.isEmpty ?? true ? 'Required' : null,
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
          ),
          keyboardType: TextInputType.phone,
          validator: (value) {
            if (value?.isEmpty ?? true) return 'Required for emergency alerts';
            if (!RegExp(r'^\+?[0-9]{10,15}$').hasMatch(value!)) {
              return 'Enter a valid phone number';
            }
            return null;
          },
        ),
      ],
    );
  }

  Widget _buildSafetyFeatures() {
    return Column(
      children: [
        TextFormField(
          controller: _codeWordController,
          decoration: const InputDecoration(
            labelText: 'Emergency Code Word',
            hintText: 'e.g. "help me"',
          ),
        ),
        const SizedBox(height: 16),
        ElevatedButton.icon(
          icon: Icon(_isListening ? Icons.mic_off : Icons.mic),
          label: Text(_isListening ? 'Stop Listening' : 'Start Code Word Listener'),
          onPressed: _toggleListening,
        ),
        if (_isListening) ...[
          const SizedBox(height: 8),
          const Text('Listening for code word...', style: TextStyle(color: Colors.green)),
          const SizedBox(height: 8),
        ],
        const SizedBox(height: 24),
        SwitchListTile(
          title: const Text('Enable Notifications'),
          value: _notificationsEnabled,
          onChanged: (value) => setState(() => _notificationsEnabled = value),
        ),
        SwitchListTile(
          title: const Text('Shake to Alert'),
          subtitle: Text(_sensorsAvailable 
              ? 'Shake phone to send emergency alert'
              : 'Shake detection not available on this device'),
          value: _shakeToAlertEnabled,
          onChanged: _sensorsAvailable 
              ? (value) async {
                  setState(() {
                    _shakeToAlertEnabled = value;
                    if (value) {
                      _testShakeFeature();
                    }
                  });
                  if (value) {
                    await _startShakeDetection();
                  } else {
                    _accelerometerSubscription?.cancel();
                  }
                }
              : null,
        ),
        const SizedBox(height: 16),
        Text(
          'Shake your phone $_minShakeCount times quickly to trigger emergency alert',
          style: TextStyle(color: Colors.grey[600]),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }
}