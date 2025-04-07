import 'package:flutter/material.dart';
import 'package:flutter_direct_caller_plugin/flutter_direct_caller_plugin.dart';

class AmbulanceEmergency extends StatelessWidget {
  const AmbulanceEmergency({Key? key}) : super(key: key);

  // Colors as constants
  static const _tealColor = Color.fromRGBO(0, 150, 136, 1);
  static const _darkTealColor = Color.fromRGBO(0, 121, 107, 1);
  static const _badgeTextColor = Color.fromRGBO(0, 77, 64, 1);

  Future<void> _callAmbulance(BuildContext context) async {
    try {
      await FlutterDirectCallerPlugin.callNumber("108");
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Could not initiate call. Please try again.'),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;
    final cardWidth = screenSize.width * 0.95;
    final cardHeight = screenSize.height * 0.22;

    return Padding(
      padding: EdgeInsets.symmetric(
        horizontal: screenSize.width * 0.02,
        vertical: screenSize.height * 0.01,
      ),
      child: Semantics(
        button: true,
        label: 'Medical Emergency, call 108 for Ambulance',
        child: InkWell(
          onTap: () => _callAmbulance(context),
          borderRadius: BorderRadius.circular(18),
          splashColor: Colors.white.withOpacity(0.2),
          highlightColor: Colors.white.withOpacity(0.1),
          child: Card(
            elevation: 6,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(18),
            ),
            child: Container(
              width: cardWidth,
              height: cardHeight,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(18),
                gradient: const LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    _tealColor,
                    _darkTealColor,
                  ],
                ),
              ),
              padding: EdgeInsets.all(screenSize.width * 0.04),
              child: Row(
                children: [
                  // Ambulance Icon
                  CircleAvatar(
                    radius: cardHeight * 0.22,
                    backgroundColor: Colors.white.withOpacity(0.4),
                    child: Image.asset(
                      'assets/ambulance.png',
                      width: cardHeight * 0.3,
                      height: cardHeight * 0.3,
                      fit: BoxFit.contain,
                      semanticLabel: 'Ambulance Icon',
                    ),
                  ),
                  SizedBox(width: cardWidth * 0.04),

                  // Texts
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          'Medical Emergency',
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: cardWidth * 0.05,
                          ),
                        ),
                        SizedBox(height: cardHeight * 0.02),
                        Text(
                          'Call 108 for Ambulance',
                          style: TextStyle(
                            color: Colors.white70,
                            fontSize: cardWidth * 0.038,
                          ),
                        ),
                      ],
                    ),
                  ),

                  // Number Badge
                  Container(
                    width: cardWidth * 0.16,
                    height: cardHeight * 0.26,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: const [
                        BoxShadow(
                          color: Colors.black26,
                          blurRadius: 4,
                          offset: Offset(2, 2),
                        ),
                      ],
                    ),
                    child: Center(
                      child: Text(
                        '108',
                        style: TextStyle(
                          color: _badgeTextColor,
                          fontWeight: FontWeight.bold,
                          fontSize: cardWidth * 0.055,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}