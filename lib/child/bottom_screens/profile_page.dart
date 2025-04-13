import 'dart:async';
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
import 'package:title_proj/widgets/home_widgets/SOSButton/emergency_service.dart';


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
  double _shakeThreshold = 15.0;
  int _minShakeCount = 3;
  int _shakeCount = 0;
  DateTime? _lastShakeTime;
  Duration _shakeWindow = Duration(milliseconds: 1000);

  late stt.SpeechToText _speech;
  bool _isListening = false;
  bool _sensorsAvailable = false;
  bool _isTestingShake = false;

  @override
  void initState() {
    super.initState();
    _speech = stt.SpeechToText();
    _initializePage();
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

    await FirebaseFirestore.instance.collection('users').doc(user.uid).set({
      'name': user.displayName ?? '',
      'email': user.email ?? '',
      'phone': '',
      'emergencyContact': '',
      'codeWord': '',
      'notificationsEnabled': true,
      'shakeToAlertEnabled': false,
      'createdAt': FieldValue.serverTimestamp(),
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
      final double acceleration = (event.x.abs() + event.y.abs() + event.z.abs());

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
            _triggerSOS();
          } else {
            Fluttertoast.showToast(
              msg: 'Shake detected! Test successful',
              backgroundColor: Colors.green,
            );
          }
        }
      }
    });
  }

  Future<void> _triggerSOS() async {
    if (_nameController.text.isEmpty) {
      Fluttertoast.showToast(msg: 'Please set your name in profile first');
      return;
    }

    setState(() => _isLoading = true);
    try {
      _currentPosition = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
        timeLimit: Duration(seconds: 10),
      );

      await EmergencyService().handleEmergency(_currentPosition!);
      
      Fluttertoast.showToast(
        msg: 'Emergency alert sent!',
        backgroundColor: Colors.green,
      );
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
        'updatedAt': FieldValue.serverTimestamp(),
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
        onResult: (result) {
          if (result.recognizedWords.toLowerCase().contains(
                _codeWordController.text.toLowerCase(),
              )) {
            Fluttertoast.showToast(msg: 'Code word detected! Sending SOS');
            _triggerSOS();
          }
        },
        cancelOnError: true,
      );
    } else {
      Fluttertoast.showToast(msg: 'Speech recognition not available');
    }
  }

  Future<void> _testShakeFeature() async {
    setState(() => _isTestingShake = true);
    Fluttertoast.showToast(
      msg: 'Shake your phone $_minShakeCount times quickly to test',
      toastLength: Toast.LENGTH_LONG,
    );
    await Future.delayed(Duration(seconds: 10));
    setState(() => _isTestingShake = false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Profile & Safety'),
        actions: [
          IconButton(
            icon: const Icon(Icons.save),
            onPressed: _updateProfile,
            tooltip: 'Save Profile',
          ),
          IconButton(
            icon: const Icon(Icons.emergency),
            onPressed: _triggerSOS,
            tooltip: 'Send Emergency Alert',
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  _buildProfileHeader(),
                  const SizedBox(height: 24),
                  _buildProfileForm(),
                  const SizedBox(height: 24),
                  _buildSafetyFeatures(),
                ],
              ),
            ),
    );
  }

  Widget _buildProfileHeader() {
    return Column(
      children: [
        GestureDetector(
          onTap: _updateProfilePicture,
          child: CircleAvatar(
            radius: 50,
            backgroundImage: _profileImageUrl != null
                ? _profileImageUrl!.startsWith('http')
                    ? NetworkImage(_profileImageUrl!)
                    : FileImage(File(_profileImageUrl!)) as ImageProvider
                : const AssetImage('assets/default_profile.png'),
            child: _profileImageUrl == null
                ? const Icon(Icons.camera_alt, size: 30, color: Colors.white)
                : null,
          ),
        ),
        const SizedBox(height: 16),
        Text(
          _nameController.text.isNotEmpty 
              ? _nameController.text 
              : 'No Name Set',
          style: Theme.of(context).textTheme.titleLarge,
        ),
        Text(
          _emailController.text,
          style: Theme.of(context).textTheme.bodyMedium,
        ),
      ],
    );
  }

  Widget _buildProfileForm() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            TextFormField(
              controller: _nameController,
              decoration: const InputDecoration(
                labelText: 'Full Name',
                prefixIcon: Icon(Icons.person),
              ),
              validator: (value) => value?.isEmpty ?? true ? 'Required' : null,
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _emailController,
              decoration: const InputDecoration(
                labelText: 'Email',
                prefixIcon: Icon(Icons.email),
              ),
              readOnly: true,
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _phoneController,
              decoration: const InputDecoration(
                labelText: 'Phone Number',
                prefixIcon: Icon(Icons.phone),
              ),
              keyboardType: TextInputType.phone,
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _emergencyContactController,
              decoration: const InputDecoration(
                labelText: 'Emergency Contact',
                hintText: '+1234567890',
                prefixIcon: Icon(Icons.emergency),
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
        ),
      ),
    );
  }

  Widget _buildSafetyFeatures() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Safety Features',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _codeWordController,
              decoration: const InputDecoration(
                labelText: 'Emergency Code Word',
                hintText: 'e.g. "help me"',
                prefixIcon: Icon(Icons.security),
              ),
            ),
            const SizedBox(height: 16),
            ElevatedButton.icon(
              icon: Icon(_isListening ? Icons.mic_off : Icons.mic),
              label: Text(_isListening ? 'Stop Listening' : 'Start Code Word Listener'),
              onPressed: _toggleListening,
              style: ElevatedButton.styleFrom(
                minimumSize: const Size(double.infinity, 50),
              ),
            ),
            if (_isListening) ...[
              const SizedBox(height: 8),
              const Text(
                'Listening for code word...',
                style: TextStyle(color: Colors.green),
                textAlign: TextAlign.center,
              ),
            ],
            const SizedBox(height: 24),
            SwitchListTile(
              title: const Text('Enable Notifications'),
              subtitle: const Text('Receive safety alerts and notifications'),
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
                      setState(() => _shakeToAlertEnabled = value);
                      if (value) {
                        await _startShakeDetection();
                        _testShakeFeature();
                      } else {
                        _accelerometerSubscription?.cancel();
                      }
                    }
                  : null,
            ),
            const SizedBox(height: 16),
            OutlinedButton.icon(
              icon: const Icon(Icons.emergency),
              label: const Text('Test Emergency Alert'),
              onPressed: _triggerSOS,
              style: OutlinedButton.styleFrom(
                minimumSize: const Size(double.infinity, 50),
                side: const BorderSide(color: Colors.red),
              ),
            ),
            const SizedBox(height: 8),
             Text(
              'Note: Shake your phone $_minShakeCount times quickly to trigger emergency alert',
              style: TextStyle(color: Colors.grey, fontSize: 12),
            ),
          ],
        ),
      ),
    );
  }
}