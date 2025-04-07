import 'package:flutter/material.dart';
import 'package:flutter_direct_caller_plugin/flutter_direct_caller_plugin.dart';

class FireBrigadeEmergency extends StatelessWidget {
  const FireBrigadeEmergency({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;
    final cardWidth = screenSize.width * 0.7;
    final cardHeight = screenSize.height * 0.18;

    return Padding(
      padding: EdgeInsets.symmetric(
        horizontal: screenSize.width * 0.03,
        vertical: screenSize.height * 0.01,
      ),
      child: GestureDetector(
        onTap: () => FlutterDirectCallerPlugin.callNumber("101"),
        child: Card(
          elevation: 5,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          child: Container(
            width: cardWidth,
            height: cardHeight,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
              gradient: const LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  Color.fromRGBO(255, 87, 34, 1),  // Orange
                  Color.fromRGBO(244, 67, 54, 1),  // Red
                ],
              ),
            ),
            padding: EdgeInsets.all(screenSize.width * 0.04),
            child: Stack(
              children: [
                // Icon and Text
                Positioned(
                  left: 8,
                  top: 8,
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      CircleAvatar(
                        radius: cardHeight * 0.2,
                        backgroundColor: Colors.white.withOpacity(0.5),
                        child: Image.asset(
                          'assets/flame.png',
                          width: cardHeight * 0.3,
                          height: cardHeight * 0.3,
                        ),
                      ),
                      SizedBox(width: cardWidth * 0.04),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            'Fire Emergency',
                            style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: cardWidth * 0.06,
                            ),
                          ),
                          SizedBox(height: cardHeight * 0.01),
                          Text(
                            'Call 101 for emergencies',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: cardWidth * 0.04,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                // Number Badge
                Positioned(
                  right: 12,
                  bottom: 12,
                  child: Container(
                    width: cardWidth * 0.2,
                    height: cardHeight * 0.25,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Center(
                      child: Text(
                        '101',
                        style: TextStyle(
                          color: Colors.red[400],
                          fontWeight: FontWeight.bold,
                          fontSize: cardWidth * 0.06,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}