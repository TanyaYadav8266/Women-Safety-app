import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';

import 'package:geolocator/geolocator.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'dart:convert';

import 'package:latlong2/latlong.dart';

class CrimeMapPage extends StatefulWidget {
  @override
  _CrimeMapPageState createState() => _CrimeMapPageState();
}

class _CrimeMapPageState extends State<CrimeMapPage> {
  List<dynamic> crimeData = []; // Stores crime data
  Set<Marker> _markers = {}; // Stores map markers
  LatLng? _userLocation; // Stores the user's location
  String _userRiskLevel = "Safe Zone"; // Default risk level

  @override
  void initState() {
    super.initState();
    _loadData(); // Load crime data
    _getUserLocation(); // Fetch user's location
  }

  // Function to load crime data from JSON
  Future<void> _loadData() async {
    String jsonString = await rootBundle.loadString('assets/crime.json');
    List<dynamic> data = jsonDecode(jsonString);

    // Print loaded data
    print("Loaded Data: $data");

    // Add risk_level to each entry based on total_crimes
    for (var entry in data) {
      entry['risk_level'] = _categorizeRisk(entry['total_crimes'].toInt()); // Convert to int
    }

    setState(() {
      crimeData = data;
      _addMarkers(crimeData);
    });
  }

  // Function to categorize risk based on total_crimes
String _categorizeRisk(int totalCrimes) {
  if (totalCrimes > 5000) {
    return 'Extremely Risky';
  } else if (totalCrimes > 1000) {
    return 'High Risk';
  } else if (totalCrimes > 500) {
    return 'Medium Risk';
  } else {
    return 'Low Risk';
  }
}

  // Function to add markers to the map
  void _addMarkers(List<dynamic> crimeData) {
    print("Adding Markers: $crimeData"); // Print markers data
    for (var entry in crimeData) {
      _markers.add(
        Marker(
          point: LatLng(entry['Latitude'], entry['Longitude']),
          width: 40.0,
          height: 40.0,
          child: Icon(
            Icons.location_on,
            color: _getMarkerColor(entry['risk_level']),
            size: 40,
          ),
        ),
      );
    }
  }

  // Function to get marker color based on risk level
  Color _getMarkerColor(String riskLevel) {
    switch (riskLevel) {
      case 'Extremely Risky':
        return Colors.purple; // Use purple for extremely risky zones
      case 'High Risk':
        return Colors.red;
      case 'Medium Risk':
        return Colors.orange;
      case 'Low Risk':
        return Colors.green;
      default:
        return Colors.blue;
    }
  }

  // Function to fetch the user's location and check risk level
  Future<void> _getUserLocation() async {
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      throw 'Location services are disabled.';
    }

    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        throw 'Location permissions are denied';
      }
    }

    Position position = await Geolocator.getCurrentPosition();
    setState(() {
      _userLocation = LatLng(position.latitude, position.longitude);
      _checkRiskLevel(); // Check for nearby crime spots
    });
  }

  // Function to check risk level based on crime locations within 5km
  void _checkRiskLevel() {
    if (_userLocation == null || crimeData.isEmpty) return;

    double alertRadius = 5000; // 5km in meters
    String riskZone = "Safe Zone";

    for (var entry in crimeData) {
      double distance = Geolocator.distanceBetween(
        _userLocation!.latitude,
        _userLocation!.longitude,
        entry['Latitude'],
        entry['Longitude'],
      );

      if (distance <= alertRadius) {
        if (entry['risk_level'] == 'Extremely Risky') {
          riskZone = "Extremely Risky Zone";
          break; // Immediately stop if an extremely risky zone is found
        } else if (entry['risk_level'] == 'High Risk') {
          riskZone = "High Risk Zone";
        } else if (entry['risk_level'] == 'Medium Risk') {
          riskZone = "Medium Risk Zone";
        } else if (entry['risk_level'] == 'Low Risk') {
          riskZone = "Low Risk Zone";
        }
      }
    }

    setState(() {
      _userRiskLevel = riskZone;
    });

    _showAlert(riskZone);
  }

  // Function to show an alert based on the risk zone
  void _showAlert(String riskZone) {
    String message = (riskZone == "Safe Zone")
        ? "You are in a Safe Zone."
        : "Warning: You are in a $riskZone! Stay alert.";

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text("Safety Alert"),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text("OK"),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Crime Map"),
        backgroundColor: Color.fromRGBO(255, 33, 117, 1), // Your primary color
      ),
      body: Stack(
        children: [
          FlutterMap(
            options: MapOptions(
              initialCenter: _userLocation ?? LatLng(20.5937, 78.9629), // Default to India's center
              initialZoom: 5.0,
            ),
            children: [
              TileLayer(
                urlTemplate: "https://tile.openstreetmap.org/{z}/{x}/{y}.png",
                // Remove subdomains
              ),
              MarkerLayer(
                markers: _markers.toList(),
              ),
            ],
          ),
          
          // Display risk level at the bottom
          Positioned(
            bottom: 20,
            left: 20,
            right: 20,
            child: Container(
              padding: EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.9),
                borderRadius: BorderRadius.circular(10),
                boxShadow: [BoxShadow(color: Colors.black26, blurRadius: 5)],
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.warning, color: _getMarkerColor(_userRiskLevel)),
                  SizedBox(width: 10),
                  Text(
                    "Zone: $_userRiskLevel",
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: _getMarkerColor(_userRiskLevel),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}