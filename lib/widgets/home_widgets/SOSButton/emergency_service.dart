import 'dart:async';
import 'dart:convert';
import 'package:geolocator/geolocator.dart';
import 'package:http/http.dart' as http;

class EmergencyService {
  static final EmergencyService _instance = EmergencyService._internal();
  factory EmergencyService() => _instance;
  EmergencyService._internal();

  // ⚠️ Hardcoded credentials — replace with your actual Twilio info
  final String accountSid = 'ACf9f5049fb42a7462d7cd83dfc8311280';
  final String authToken = '8de7027b99f6a71f5d95b0ce46df9723';
  final String fromNumber = '+14632836151'; // Your Twilio number
  final List<String> toNumbers = ['+918448018504']; // Emergency contact numbers

  Future<void> handleEmergency(Position position) async {
    try {
      await _sendEmergencySMS(position);
    } catch (e) {
      throw Exception('Failed to handle emergency: ${e.toString()}');
    }
  }

  Future<void> _sendEmergencySMS(Position position) async {
    final locationUrl = 'https://maps.google.com?q=${position.latitude},${position.longitude}';
    final message = 'EMERGENCY! Need help at: $locationUrl';

    for (final toNumber in toNumbers) {
      try {
        final response = await http.post(
          Uri.parse('https://api.twilio.com/2010-04-01/Accounts/$accountSid/Messages.json'),
          headers: {
            'Authorization': 'Basic ${base64Encode(utf8.encode('$accountSid:$authToken'))}',
            'Content-Type': 'application/x-www-form-urlencoded',
          },
          body: {
            'From': fromNumber,
            'To': toNumber.trim(),
            'Body': message,
          },
        ).timeout(const Duration(seconds: 10));

        if (response.statusCode != 201) {
          throw Exception('Failed to send SMS: ${response.body}');
        }
      } catch (e) {
        throw Exception('Failed to send SMS to $toNumber: ${e.toString()}');
      }
    }
  }
}
