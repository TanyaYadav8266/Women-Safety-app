import 'package:flutter/material.dart';
import 'package:flutter_direct_caller_plugin/flutter_direct_caller_plugin.dart';

class ArmyEmergency extends StatelessWidget {
  const ArmyEmergency({Key? key}) : super(key: key);

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
        onTap: () => FlutterDirectCallerPlugin.callNumber("100"),
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
                  Color.fromRGBO(76, 175, 80, 1),  // Army green
                  Color.fromRGBO(56, 142, 60, 1),   // Darker green
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
                          'assets/police-image.png', // Use appropriate army icon
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
                            'Police Emergency',
                            style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: cardWidth * 0.06,
                            ),
                          ),
                          SizedBox(height: cardHeight * 0.01),
                          Text(
                            'Call 100 for emergencies',
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
                        '100',
                        style: TextStyle(
                          color: Colors.green[800],
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