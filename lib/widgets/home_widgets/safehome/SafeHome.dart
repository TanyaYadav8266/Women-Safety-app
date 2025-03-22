import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:geolocator/geolocator.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:twilio_flutter/twilio_flutter.dart'; // Import Twilio package
import 'package:title_proj/components/PrimaryButton.dart';

class SafeHome extends StatefulWidget {
  @override
  State<SafeHome> createState() => _SafeHomeState();
}

class _SafeHomeState extends State<SafeHome> {
  Position? _currentPosition;
  LocationPermission? permission;

  // Initialize TwilioFlutter with your credentials
  late TwilioFlutter twilioFlutter;  // Use 'late' to tell Dart the variable will be initialized later

  @override
  void initState() {
    super.initState();

    // Initialize Twilio with your Twilio credentials
    twilioFlutter = TwilioFlutter(
      accountSid: 'your_account_sid',  // Replace with your Account SID from Twilio
      authToken: 'your_auth_token',    // Replace with your Auth Token from Twilio
      twilioNumber: 'your_twilio_number', // Replace with your Twilio phone number
    );
  }

  // Request permissions
  _getPermission() async {
    await [Permission.sms, Permission.location].request();
  }

  // Check if the SMS permission is granted
  _isPermissionGranted() async => await Permission.sms.status.isGranted;

  // Send SMS using Twilio
  _sendSms(String phoneNumber, String message) async {
    try {
      final messageSent = await twilioFlutter.sendSMS(
        toNumber: phoneNumber,  // The recipient's phone number
        messageBody: message,   // The message to send
      );
      Fluttertoast.showToast(msg: "Message sent: $messageSent");
    } catch (error) {
      Fluttertoast.showToast(msg: "Message failed: $error");
    }
  }

  // Get current location
  _getCurrentLocation() async {
    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      Fluttertoast.showToast(msg: "Location permission denied");
      if (permission == LocationPermission.deniedForever) {
        Fluttertoast.showToast(msg: "Location permission denied permanently");
      }
    }

    // Get current location after permission is granted
    Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
        forceAndroidLocationManager: true).then((Position position) {
      setState(() {
        _currentPosition = position;
      });
    }).catchError((e) {
      Fluttertoast.showToast(msg: "Failed to get location");
    });
  }

  // Show bottom sheet for sending location or alert
  showModelSafeHome(BuildContext context) {
    showModalBottomSheet(
      context: context,
      builder: (context) {
        return Container(
          height: MediaQuery.of(context).size.height / 1.4,
          child: Padding(
            padding: const EdgeInsets.all(14.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  "Send your current location immediately",
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 20),
                ),
                SizedBox(height: 10),
                PrimaryButton(
                  title: "GET LOCATION",
                  onPressed: () {
                    _getCurrentLocation();
                    if (_currentPosition != null) {
                      Fluttertoast.showToast(msg: "Location fetched");
                    } else {
                      Fluttertoast.showToast(msg: "Failed to fetch location");
                    }
                  },
                ),
                SizedBox(height: 10),
                PrimaryButton(
                  title: "SEND ALERT",
                  onPressed: () {
                    if (_currentPosition != null) {
                      String message =
                          "Emergency! My location is: Lat: ${_currentPosition?.latitude}, Long: ${_currentPosition?.longitude}";
                      _sendSms("8448018504", message);  // Replace with the recipient's phone number
                    } else {
                      Fluttertoast.showToast(msg: "Location not available yet");
                    }
                  },
                ),
              ],
            ),
          ),
          decoration: BoxDecoration(
              color: const Color.fromARGB(255, 240, 155, 205),
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(30),
                topRight: Radius.circular(20),
              )),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () => showModelSafeHome(context),
      child: Card(
        elevation: 5,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        child: Container(
          height: 180,
          width: MediaQuery.of(context).size.width * 0.7,
          decoration: BoxDecoration(),
          child: Row(
            children: [
              Expanded(
                  child: Column(
                children: [
                  ListTile(
                    title: Text("Send Location"),
                    subtitle: Text("Share Location"),
                  ),
                ],
              )),
              ClipRRect(
                  borderRadius: BorderRadius.circular(20),
                  child: Image.asset('assets/Safehome.jpg'))
            ],
          ),
        ),
      ),
    );
  }
}
