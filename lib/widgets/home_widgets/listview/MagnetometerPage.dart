import 'dart:math';
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:sensors_plus/sensors_plus.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:audioplayers/audioplayers.dart';

final Color primaryColor = Color.fromRGBO(255, 33, 117, 1);

class MagnetometerPage extends StatefulWidget {
  @override
  _MagnetometerPageState createState() => _MagnetometerPageState();
}

class _MagnetometerPageState extends State<MagnetometerPage> {
  double _magX = 0, _magY = 0, _magZ = 0, _magnitude = 0;
  bool _deviceDetected = false;
  final AudioPlayer _audioPlayer = AudioPlayer();
  late final StreamSubscription magnetometerSubscription;

  @override
  void initState() {
    super.initState();
    _showInstructions();
    magnetometerSubscription = magnetometerEvents.listen((event) {
      if (!mounted) return; // Prevents setState on a disposed widget
      setState(() {
        _magX = event.x;
        _magY = event.y;
        _magZ = event.z;
        _magnitude = sqrt(_magX * _magX + _magY * _magY + _magZ * _magZ);
        _magnitude = double.parse(_magnitude.toStringAsFixed(0)); // Rounding

        if (_magnitude > 70 && _magnitude < 90) {
          if (!_deviceDetected) {
            _deviceDetected = true;
            _playBeep('beep.mp3');
            _showAlert("Potential electronic device detected!");
          }
        } else if (_magnitude >= 90) {
          if (!_deviceDetected) {
            _deviceDetected = true;
            _playBeep('beep_high.mp3');
            _showAlert("Electronic device detected!");
          }
        } else {
          _deviceDetected = false;
        }
      });
    });
  }

  @override
  void dispose() {
    magnetometerSubscription.cancel(); // Stop listening when widget is disposed
    _audioPlayer.dispose(); // Dispose audio player to free resources
    super.dispose();
  }

  Future<void> _playBeep(String soundFile) async {
    await _audioPlayer.play(AssetSource(soundFile));
  }

  Future<void> _showInstructions() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    bool firstTime = prefs.getBool('first_time') ?? true;
    if (firstTime) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: Text("Instructions"),
            content: Text("Move your phone near suspected areas to detect hidden cameras."),
            actions: [
              TextButton(
                onPressed: () {
                  prefs.setBool('first_time', false);
                  Navigator.of(context).pop();
                },
                child: Text("Got It"),
              ),
            ],
          ),
        );
      });
    }
  }

  void _showAlert(String message) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: Text("Alert"),
          content: Text(message),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text("OK"),
            ),
          ],
        ),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Hidden Camera Detector"),
        backgroundColor: primaryColor,
        elevation: 0,
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                "Magnetic Field Strength",
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: primaryColor),
              ),
              SizedBox(height: 20),
              LinearProgressIndicator(
                value: _magnitude / 100, // Assuming 100 is the max value for visualization
                backgroundColor: Colors.grey[300],
                valueColor: AlwaysStoppedAnimation<Color>(primaryColor),
              ),
              SizedBox(height: 20),
              Text(
                "X: $_magX µT",
                style: TextStyle(fontSize: 18),
              ),
              Text(
                "Y: $_magY µT",
                style: TextStyle(fontSize: 18),
              ),
              Text(
                "Z: $_magZ µT",
                style: TextStyle(fontSize: 18),
              ),
              SizedBox(height: 20),
              Text(
                "Magnitude: $_magnitude µT",
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: primaryColor),
              ),
              SizedBox(height: 20),
              _deviceDetected
                  ? Text(
                      "Potential Electronic Device Detected!",
                      style: TextStyle(color: Colors.red, fontSize: 18, fontWeight: FontWeight.bold),
                    )
                  : Text(
                      "No Electronic Device Detected",
                      style: TextStyle(color: Colors.green, fontSize: 18, fontWeight: FontWeight.bold),
                    ),
            ],
          ),
        ),
      ),
    );
  }
}