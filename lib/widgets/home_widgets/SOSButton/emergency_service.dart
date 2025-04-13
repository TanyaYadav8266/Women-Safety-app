import 'package:geolocator/geolocator.dart';
import 'package:another_telephony/telephony.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class EmergencyService {
  static final EmergencyService _instance = EmergencyService._internal();
  factory EmergencyService() => _instance;
  EmergencyService._internal();

  final Telephony telephony = Telephony.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<void> handleEmergency(Position position, {String? customMessage}) async {
    try {
      await _sendEmergencySMS(position, customMessage: customMessage);
    } catch (e) {
      throw Exception('Failed to handle emergency: ${e.toString()}');
    }
  }

  Future<String?> _getEmergencyContact() async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) return null;

      final doc = await _firestore.collection('users').doc(user.uid).get();
      if (!doc.exists) return null;

      final emergencyContact = doc.data()?['emergencyContact']?.toString().trim();
      final userPhone = doc.data()?['phone']?.toString().trim();

      if (emergencyContact?.isNotEmpty ?? false) {
        return emergencyContact;
      } else if (userPhone?.isNotEmpty ?? false) {
        return userPhone;
      }
      return null;
    } catch (e) {
      throw Exception('Failed to fetch emergency contact: ${e.toString()}');
    }
  }

  Future<void> _sendEmergencySMS(Position position, {String? customMessage}) async {
    final recipient = await _getEmergencyContact();
    if (recipient == null) {
      throw Exception('No emergency contact found in profile');
    }

    final locationUrl = 'https://maps.google.com?q=${position.latitude},${position.longitude}';
    final userName = await _getUserName();
    final codeWord = await _getCodeWord();
    
    final message = customMessage ?? 
      '🚨 EMERGENCY ALERT!\n'
      '${userName ?? "User"} needs help!\n'
      'Location: $locationUrl\n'
      '${codeWord != null ? "Code Word: $codeWord" : ""}';

    final permissionsGranted = await telephony.requestPhoneAndSmsPermissions;
    if (permissionsGranted != true) {
      throw Exception('SMS permissions not granted');
    }

    try {
      // The sendSms method returns void, so we can't check status
      await telephony.sendSms(
        to: recipient,
        message: message,
      );
      
      // If we get here, we assume the message was sent
      // Note: This is a limitation of the another_telephony package
      // For more reliable status checking, consider using a different SMS package
      // or implement error handling through try-catch
    } catch (e) {
      throw Exception('Failed to send SMS: ${e.toString()}');
    }
  }

  Future<String?> _getUserName() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return null;

    final doc = await _firestore.collection('users').doc(user.uid).get();
    return doc.data()?['name']?.toString();
  }

  Future<String?> _getCodeWord() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return null;

    final doc = await _firestore.collection('users').doc(user.uid).get();
    final word = doc.data()?['codeWord']?.toString().trim();
    return word?.isNotEmpty == true ? word : null;
  }
}