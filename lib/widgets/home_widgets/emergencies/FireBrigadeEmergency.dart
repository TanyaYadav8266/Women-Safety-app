import 'package:flutter/material.dart';
import 'package:flutter_direct_caller_plugin/flutter_direct_caller_plugin.dart';

class FireBrigadeEmergency extends StatelessWidget {
  const FireBrigadeEmergency({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: 10.0, bottom: 5),
      child: GestureDetector(
        onTap: () {
          FlutterDirectCallerPlugin.callNumber("101");
        },
        child: Card(
          elevation: 5,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          child: Container(
            height: 160, // Same as PoliceEmergency
            width: MediaQuery.of(context).size.width * 0.7,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(20),
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
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                CircleAvatar(
                  radius: 25,
                  backgroundColor: Colors.white.withOpacity(0.5),
                  child: Image.asset('assets/flame.png'),
                ),
                const SizedBox(height: 10),
                Text(
                  'Fire Emergency',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: MediaQuery.of(context).size.width * 0.06,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Call 101 for Fire Emergency',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: MediaQuery.of(context).size.width * 0.045,
                  ),
                ),
                const Spacer(),
                Container(
                  height: 30,
                  width: 80,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Center(
                    child: Text(
                      '101',
                      style: TextStyle(
                        color: Colors.red[300],
                        fontWeight: FontWeight.bold,
                        fontSize: MediaQuery.of(context).size.width * 0.055,
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
