import 'package:flutter/material.dart';

class PharmacyCard extends StatelessWidget {
  final Function(String) onMapFunction;
  final bool isDarkMode;
  
  const PharmacyCard({
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
            onTap: () => onMapFunction('Pharmacies near me'),
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
                  Icons.local_pharmacy,
                  size: 32,
                  color: isDarkMode ? Colors.green[200] : Colors.green[800],
                ),
              ),
            ),
          ),
          const SizedBox(height: 6),
          Text(
            'Pharmacies',
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