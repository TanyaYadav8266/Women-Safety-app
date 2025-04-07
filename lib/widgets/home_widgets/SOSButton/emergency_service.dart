import 'dart:async';
import 'dart:convert'; // This import provides base64Encode and utf8
import 'package:sensors_plus/sensors_plus.dart';
import 'package:geolocator/geolocator.dart';
import 'package:http/http.dart' as http;
import 'package:permission_handler/permission_handler.dart';

class EmergencyService {
  static final EmergencyService _instance = EmergencyService._internal();
  factory EmergencyService() => _instance;
  EmergencyService._internal();

  final double _shakeThreshold = 2.7;
  final int _minShakeIntervalMs = 2000;
  DateTime _lastShakeTime = DateTime.now();
  StreamSubscription<UserAccelerometerEvent>? _accelerometerSubscription;

  Future<void> startShakeDetection(Function onShakeDetected) async {
    if (_accelerometerSubscription != null) return;

    _accelerometerSubscription = userAccelerometerEvents.listen((event) {
      final now = DateTime.now();
      final timeSinceLastShake = now.difference(_lastShakeTime).inMilliseconds;

      if (timeSinceLastShake < _minShakeIntervalMs) return;

      final acceleration = (event.x.abs() + event.y.abs() + event.z.abs()) / 3;

      if (acceleration > _shakeThreshold) {
        _lastShakeTime = now;
        onShakeDetected();
      }
    });
  }

  void stopShakeDetection() {
    _accelerometerSubscription?.cancel();
    _accelerometerSubscription = null;
  }

  Future<void> handleEmergency() async {
    try {
      final position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );
      await _sendEmergencySMS(position);
    } catch (e) {
      throw Exception('Failed to handle emergency: $e');
    }
  }

  Future<void> _sendEmergencySMS(Position position) async {
    const accountSid = 'YOUR_TWILIO_ACCOUNT_SID';
    const authToken = 'YOUR_TWILIO_AUTH_TOKEN';
    const fromNumber = 'YOUR_TWILIO_PHONE_NUMBER';
    const toNumbers = ['+918448018504']; // Add emergency contacts here

    final locationUrl = 'https://www.google.com/maps?q=${position.latitude},${position.longitude}';
    final message = 'EMERGENCY! Need help at: $locationUrl';

    // Create the basic auth token
    final credentials = '$accountSid:$authToken';
    final bytes = utf8.encode(credentials); // Now using the imported utf8
    final base64Str = base64.encode(bytes); // Now using the imported base64

    for (final toNumber in toNumbers) {
      try {
        final response = await http.post(
          Uri.parse('https://api.twilio.com/2010-04-01/Accounts/$accountSid/Messages.json'),
          headers: {
            'Authorization': 'Basic $base64Str',
            'Content-Type': 'application/x-www-form-urlencoded',
          },
          body: {
            'From': fromNumber,
            'To': toNumber,
            'Body': message,
          },
        );

        if (response.statusCode != 201) {
          throw Exception('Failed to send SMS to $toNumber');
        }
      } catch (e) {
        throw Exception('Failed to send SMS: $e');
      }
    }
  }
}