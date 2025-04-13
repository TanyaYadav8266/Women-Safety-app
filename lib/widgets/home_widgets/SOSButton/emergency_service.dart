import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:another_telephony/telephony.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:permission_handler/permission_handler.dart';

class EmergencyService {
  static final EmergencyService _instance = EmergencyService._internal();
  factory EmergencyService() => _instance;
  EmergencyService._internal();

  final Telephony _telephony = Telephony.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  Future<void> handleEmergency(Position position, {String? customMessage}) async {
    try {
      // 1. Get emergency contact exactly as done in ProfilePage
      final recipient = await _getEmergencyContact();
      if (recipient == null || recipient.isEmpty) {
        throw Exception('No valid emergency contact available');
      }

      // 2. Build message (same format as ProfilePage)
      final message = await _buildEmergencyMessage(position, customMessage: customMessage);

      // 3. Send SMS using the EXACT same method as ProfilePage
      final success = await _sendEmergencySMS(recipient, message);
      
      if (!success) {
        throw Exception('Failed to send emergency alert');
      }

      Fluttertoast.showToast(
        msg: 'Emergency alert sent!',
        backgroundColor: Colors.green,
      );

    } catch (e) {
      Fluttertoast.showToast(
        msg: 'Emergency alert failed: ${e.toString().replaceAll('Exception:', '')}',
        backgroundColor: Colors.red,
        toastLength: Toast.LENGTH_LONG,
      );
      rethrow;
    }
  }

  // EXACT COPY FROM PROFILEPAGE IMPLEMENTATION
  Future<bool> _sendEmergencySMS(String recipient, String message) async {
    try {
      final hasPermission = await _telephony.requestSmsPermissions;
      if (hasPermission != true) {
        throw Exception('SMS permission not granted');
      }

      await _telephony.sendSms(to: recipient, message: message);
      return true;
    } catch (e) {
      debugPrint('SMS sending error: $e');
      return false;
    }
  }

  // Same contact fetching as ProfilePage
  Future<String?> _getEmergencyContact() async {
    try {
      final user = _auth.currentUser;
      if (user == null) return null;

      final doc = await _firestore.collection('users').doc(user.uid).get();
      if (!doc.exists) return null;

      // Exactly the same logic as ProfilePage
      return doc.data()?['emergencyContact']?.toString().trim() ?? 
             doc.data()?['phone']?.toString().trim();
    } catch (e) {
      debugPrint('Error getting emergency contact: $e');
      return null;
    }
  }

  // Similar message building as ProfilePage
  Future<String> _buildEmergencyMessage(Position position, {String? customMessage}) async {
    final locationUrl = 'https://maps.google.com?q=${position.latitude},${position.longitude}';
    final userName = await _getUserName() ?? 'User';
    final codeWord = await _getCodeWord();

    return customMessage ?? 
      'EMERGENCY! $userName needs help!\n'
      'Location: $locationUrl\n'
      '${codeWord != null ? "Codeword: $codeWord" : ""}';
  }

  Future<String?> _getUserName() async {
    final user = _auth.currentUser;
    if (user == null) return null;

    final doc = await _firestore.collection('users').doc(user.uid).get();
    return doc.data()?['name']?.toString();
  }

  Future<String?> _getCodeWord() async {
    final user = _auth.currentUser;
    if (user == null) return null;

    final doc = await _firestore.collection('users').doc(user.uid).get();
    return doc.data()?['codeWord']?.toString().trim();
  }
}