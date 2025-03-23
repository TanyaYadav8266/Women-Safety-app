import 'package:flutter/material.dart';
import 'crime_map_page.dart'; // Import the CrimeMapPage

class RiskAnalysis extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: 20),
      child: Column(
        children: [
          InkWell(
            onTap: () {
              // Navigate to CrimeMapPage when the button is tapped
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => CrimeMapPage()),
              );
            },
            child: Card(
              elevation: 3,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
              child: Container(
                height: 50,
                width: 50,
                child: Center(
                  child: Icon(
                    Icons.warning_amber_rounded, // Risk-related icon
                    size: 32,
                    color: Colors.black,
                  ),
                ),
              ),
            ),
          ),
          Text('Risk Analysis'),
        ],
      ),
    );
  }
}