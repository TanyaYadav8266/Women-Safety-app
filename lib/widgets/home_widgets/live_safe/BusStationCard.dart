import 'package:flutter/material.dart';

class BusStationCard extends StatelessWidget {
  final Function(String) onMapFunction;
  final bool isDarkMode;
  
  const BusStationCard({
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
            borderRadius: BorderRadius.circular(20),
            onTap: () => onMapFunction('Bus Stations near me'),
            child: Card(
              elevation: 4,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
              color: isDarkMode ? Colors.grey[800] : Colors.white,
              child: Container(
                width: 70,
                height: 70,
                padding: const EdgeInsets.all(12),
                child: Icon(
                  Icons.directions_bus,
                  size: 32,
                  color: isDarkMode ? Colors.blue[200] : Colors.blue[800],
                ),
              ),
            ),
          ),
          const SizedBox(height: 6),
          Text(
            'Bus Stops',
            style: TextStyle(
              color: isDarkMode ? Colors.white : Colors.black,
              fontSize: 12,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}