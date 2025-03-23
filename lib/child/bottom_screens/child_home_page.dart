import 'dart:async';
import 'dart:convert';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:sensors_plus/sensors_plus.dart';
import 'package:http/http.dart' as http; // HTTP package for sending requests
import 'package:title_proj/widgets/home_widgets/SOSButton/emergency_service.dart';
import 'package:title_proj/widgets/home_widgets/listview/DetectCamera.dart';
import 'package:title_proj/widgets/home_widgets/listview/RiskAnalysis.dart';
import 'package:title_proj/widgets/home_widgets/listview/SelfDefence.dart';
import 'package:vibration/vibration.dart'; // Import vibration package

import 'package:title_proj/widgets/home_widgets/CustomCarouel.dart';
import 'package:title_proj/widgets/home_widgets/custom_appBar.dart';
import 'package:title_proj/widgets/home_widgets/emergency.dart';
import 'package:title_proj/widgets/home_widgets/safehome/SafeHome.dart';
import 'package:title_proj/widgets/live_safe.dart';

class HomeScreen extends StatefulWidget {
  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int qIndex = 2;
  bool isShakeEnabled = false; // To track if the shake feature is enabled
  StreamSubscription<AccelerometerEvent>?
      _accelerometerSubscription; // For controlling the accelerometer listener

  // Variables to handle accelerometer data for shake detection
  double previousX = 0.0, previousY = 0.0, previousZ = 0.0;
  static const double shakeThreshold = 90.0; // Threshold for shake detection
  static const int shakeTimeout =
      20000; // Timeout to prevent multiple shakes in a short time
  int lastShakeTime = 0;

  // Counter for the number of shakes
  int shakeCount = 0;

  // Function to send an SMS using Twilio
  void _sendTwilioSms() async {
    // Twilio credentials (replace with your actual credentials)
    const String accountSid = '';
    const String authToken = '';
    const String fromPhoneNumber = ''; // Your Twilio phone number
    const String toPhoneNumber =
        '+918726744569'; // Recipient phone number (replace with actual number)

    // Twilio API endpoint
    final String url =
        'https://api.twilio.com/2010-04-01/Accounts/$accountSid/Messages.json';

    // Prepare the body for the POST request
    final Map<String, String> body = {
      'To': toPhoneNumber,
      'From': fromPhoneNumber,
      'Body': 'Emergency: I need help!', // Your emergency message
    };

    // Basic authentication header with Twilio Account SID and Auth Token
    final String auth =
        'Basic ' + base64Encode(utf8.encode('$accountSid:$authToken'));

    // Send HTTP POST request to Twilio API
    final response = await http.post(
      Uri.parse(url),
      headers: {
        'Authorization': auth,
        'Content-Type': 'application/x-www-form-urlencoded',
      },
      body: body,
    );

    if (response.statusCode == 201) {
      // Message sent successfully
      print('Message sent: ${response.body}');
      _vibrate(); // Trigger vibration when the message is sent
      _showMessageSentAlert(); // Show the alert when the message is sent
    } else {
      // Handle failure
      print('Failed to send message: ${response.body}');
    }
  }

  // Function to trigger vibration
  void _vibrate() async {
    if (await Vibration.hasVibrator()) {
      Vibration.vibrate(duration: 500); // Vibrates for 500 milliseconds
    } else {
      print('Device does not support vibration');
    }
  }

  // Function to show the alert when message is sent
  void _showMessageSentAlert() {
    // Show a Snackbar for the confirmation message
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Message Sent Successfully!'),
        backgroundColor: Colors.green,
        duration: Duration(seconds: 2),
      ),
    );
  }

  getRandomQuote() {
    Random random = Random();
    setState(() {
      qIndex = random.nextInt(6);
    });
  }

  // Function to toggle the shake detection feature
  void _toggleShakeFeature() {
    setState(() {
      isShakeEnabled = !isShakeEnabled; // Toggle the shake feature
    });

    if (isShakeEnabled) {
      // Start listening to accelerometer events when shake detection is enabled
      _startShakeDetection();
    } else {
      // Cancel the accelerometer listener when shake detection is disabled
      _stopShakeDetection();
    }
  }

  // Function to start shake detection
  void _startShakeDetection() {
    // Ensure no active listener exists before subscribing again
    if (_accelerometerSubscription != null) {
      _accelerometerSubscription!
          .cancel(); // Ensure we cancel any previous subscriptions
    }

    // Start listening to accelerometer events
    _accelerometerSubscription =
        accelerometerEvents.listen((AccelerometerEvent event) {
      // Get the current time for shake detection timeout
      int currentTime = DateTime.now().millisecondsSinceEpoch;

      // Calculate the difference in accelerometer readings
      double deltaX = (event.x - previousX).abs();
      double deltaY = (event.y - previousY).abs();
      double deltaZ = (event.z - previousZ).abs();

      // If the difference exceeds the shake threshold and the shake is not too recent
      if ((deltaX + deltaY + deltaZ) > shakeThreshold &&
          (currentTime - lastShakeTime > shakeTimeout)) {
        // Increment shake count when a valid shake is detected
        shakeCount++;

        // Check if 3 shakes have been detected
        if (shakeCount == 3) {
          // Trigger the shake action (send SMS)
          _sendTwilioSms();

          // Reset the shake count and stop listening to shake events
          shakeCount = 0; // Reset counter after sending the message
        }

        // Update the last shake time to prevent multiple shakes in a short time
        lastShakeTime = currentTime;
      }

      // Update previous accelerometer values
      previousX = event.x;
      previousY = event.y;
      previousZ = event.z;
    });
  }

  // Function to stop shake detection
  void _stopShakeDetection() {
    // Cancel the accelerometer listener when shake detection is disabled
    if (_accelerometerSubscription != null) {
      _accelerometerSubscription!.cancel(); // Cancel the listener if it exists
      _accelerometerSubscription =
          null; // Reset the subscription to prevent further events
    }
  }

  @override
  void dispose() {
    // Cancel the accelerometer listener if the feature is disabled or if the widget is disposed
    _stopShakeDetection();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            children: [
              CustomAppBar(
                  quoteIndex: qIndex,
                  onTap: () {
                    getRandomQuote();
                  }),
              // Distress Button to toggle the shake feature
              ElevatedButton(
                onPressed: _toggleShakeFeature,
                child: Text(isShakeEnabled
                    ? 'Disable Shake (Distress Button)'
                    : 'Enable Shake (Distress Button)'),
                style: ElevatedButton.styleFrom(
                  backgroundColor:
                      Colors.red, // Red color to indicate emergency
                ),
              ),
              Expanded(
                child: 
                ListView(
  shrinkWrap: true,
  children: [
  CustomCarouel(),
  Padding(
    padding: const EdgeInsets.all(8.0),
    child: Text(
      'Emergency',
      style: TextStyle(
        fontSize: 20, 
        fontWeight: FontWeight.bold
      ),
    ),
  ),
  Emergency(
    onSosPressed: () async {
      try {
        // Call emergency service handler
        await EmergencyService().handleEmergency();
        
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Emergency alert sent successfully!'),
            backgroundColor: Colors.green,
            duration: Duration(seconds: 3),
          )
        );
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to send alert: ${e.toString()}'),
            backgroundColor: Colors.red,
            duration: Duration(seconds: 3),
          )
        );
      }
    },
  ),
  Padding(
    padding: const EdgeInsets.all(8.0),
    child: Text(
      'Explore LiveSafe',
      style: TextStyle(
        fontSize: 20, 
        fontWeight: FontWeight.bold
      ),
    ),
  ),
  LiveSafe(),
  SafeHome(),
  Padding(
    padding: const EdgeInsets.all(8.0),
    child: Text(
      'SafeSpace',
      style: TextStyle(
        fontSize: 20, 
        fontWeight: FontWeight.bold
      ),
    ),
  ),
                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children: [
                        DetectCameras(),
                        RiskAnalysis(),
                        SelfDefence(),
                      ],
                    ),
                    ),
                  ],
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}