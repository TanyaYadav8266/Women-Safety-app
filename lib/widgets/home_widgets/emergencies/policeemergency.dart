import 'package:flutter/material.dart';
import 'package:flutter_direct_caller_plugin/flutter_direct_caller_plugin.dart';

class PoliceEmergency extends StatelessWidget {
  const PoliceEmergency({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;
    final cardWidth = screenSize.width * 0.8;  // Slightly narrower
    final cardHeight = screenSize.height * 0.16;  // More compact height

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
      child: GestureDetector(
        onTap: () => FlutterDirectCallerPlugin.callNumber("181"),
        child: Card(
          elevation: 5,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),  // Slightly smaller radius
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
                  Color.fromRGBO(216, 68, 173, 1),
                  Color.fromRGBO(248, 7, 89, 1),
                ],
              ),
            ),
            padding: const EdgeInsets.all(12.0),
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
                        radius: cardHeight * 0.2,  // Relative to card height
                        backgroundColor: Colors.white.withOpacity(0.5),
                        child: Image.asset(
                          'assets/alert.png',
                          width: cardHeight * 0.3,
                          height: cardHeight * 0.3,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            'Women Helpline',
                            style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: cardWidth * 0.05,  // Responsive font
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'Call 181 for assistance',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: cardWidth * 0.035,  // Slightly smaller
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
                        '181',
                        style: TextStyle(
                          color: Colors.red[300],
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