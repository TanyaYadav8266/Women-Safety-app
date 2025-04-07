import 'package:flutter/material.dart';

class PoliceStationCard extends StatelessWidget {
  final Function(String) onMapFunction;
  final bool isDarkMode;
  
  const PoliceStationCard({
    Key? key,
    required this.onMapFunction,
    required this.isDarkMode,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8),
      child: Column(
        children: [
          InkWell(
            onTap: () => onMapFunction('Police stations near me'),
            child: Card(
              elevation: 4,
              color: isDarkMode ? Colors.grey[800] : Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
              child: Container(
                width: 70,
                height: 70,
                padding: const EdgeInsets.all(12),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // Option 1: Using Icon (works without assets)
                    Icon(
                      Icons.local_police,
                      size: 32,
                      color: isDarkMode ? Colors.blue[200] : Colors.blue[800],
                    ),
                    
                    // OR Option 2: Using Image (if you have assets)
                    // Image.asset(
                    //   'assets/police.png',
                    //   color: isDarkMode ? Colors.blue[200] : Colors.blue[800],
                    // ),
                  ],
                ),
              ),
            ),
          ),
          const SizedBox(height: 6),
          Text(
            'Police',
            style: TextStyle(
              color: isDarkMode ? Colors.white : Colors.black,
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }
}