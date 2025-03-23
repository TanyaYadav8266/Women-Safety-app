import 'dart:async';
import 'dart:convert';
import 'package:geolocator/geolocator.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'package:http/http.dart' as http;
import 'package:connectivity_plus/connectivity_plus.dart';

class EmergencyService {
  static final EmergencyService _instance = EmergencyService._internal();
  factory EmergencyService() => _instance;
  EmergencyService._internal();

  late Database _database;
  final Connectivity _connectivity = Connectivity();
  final List<String> _trustedContacts = [
    '+918335841730', // Police
    '+918335841730', // Family Member
    '+918335841730'  // Hospital
  ];

  Future<void> initialize() async {
    await _initDatabase();
    await _checkPermissions();
    _setupConnectivity();
  }

  Future<void> _initDatabase() async {
    _database = await openDatabase(
      join(await getDatabasesPath(), 'emergency.db'),
      onCreate: (db, version) => db.execute('''
        CREATE TABLE emergency_messages(
          id INTEGER PRIMARY KEY,
          message TEXT,
          latitude REAL,
          longitude REAL,
          timestamp INTEGER
        )
      '''),
      version: 1,
    );
  }

Future<void> _checkPermissions() async {
  await [
    Permission.location,
    Permission.sms,  // If sending SMS
    Permission.phone, // If making phone calls
    Permission.storage, // For database access
  ].request();
}

  void _setupConnectivity() {
    _connectivity.onConnectivityChanged.listen((result) async {
      if (result != ConnectivityResult.none) {
        await _sendPendingMessages();
      }
    });
  }

  Future<void> handleEmergency() async {
    final position = await Geolocator.getCurrentPosition();
    final message = _createMessage(position);

    if (await _checkConnection()) {
      await _sendViaInternet(message);
    } else {
      await _storeMessage(message, position);
    }
  }

  String _createMessage(Position position) {
    return jsonEncode({
      'emergency': 'SOS Activated!',
      'location': {
        'latitude': position.latitude,
        'longitude': position.longitude,
        'accuracy': position.accuracy
      },
      'timestamp': DateTime.now().toIso8601String(),
    });
  }

  Future<bool> _checkConnection() async {
    final result = await _connectivity.checkConnectivity();
    return result != ConnectivityResult.none;
  }

  Future<void> _sendViaInternet(String message) async {
    try {
      // Send to all trusted contacts
      for (final contact in _trustedContacts) {
        await _sendSMS(contact, message);
      }
    } catch (e) {
      print('Error sending message: $e');
      throw Exception('Failed to send emergency message');
    }
  }

  Future<void> _sendSMS(String toNumber, String message) async {
    // Replace with your SMS gateway implementation
    const accountSid = 'ACcf9c295dac65f3fd31b64772ea79e056';
    const authToken = '49be9e5ffd95681555887b1fa59737cd';
    const fromNumber = '+12564742482';

    final response = await http.post(
      Uri.parse('https://api.twilio.com/2010-04-01/Accounts/$accountSid/Messages.json'),
      headers: {
        'Authorization': 'Basic ${base64Encode(utf8.encode('$accountSid:$authToken'))}',
        'Content-Type': 'application/x-www-form-urlencoded',
      },
      body: {
        'To': toNumber,
        'From': fromNumber,
        'Body': message,
      },
    );

    if (response.statusCode != 201) {
      throw Exception('Failed to send SMS to $toNumber');
    }
  }

  Future<void> _storeMessage(String message, Position position) async {
    await _database.insert('emergency_messages', {
      'message': message,
      'latitude': position.latitude,
      'longitude': position.longitude,
      'timestamp': DateTime.now().millisecondsSinceEpoch,
    });
  }

  Future<void> _sendPendingMessages() async {
    final messages = await _database.query('emergency_messages');
    for (final msg in messages) {
      try {
        await _sendViaInternet(msg['message'] as String);
        await _database.delete('emergency_messages', 
          where: 'id = ?', 
          whereArgs: [msg['id']]
        );
      } catch (e) {
        print('Failed to send pending message: $e');
      }
    }
  }
}