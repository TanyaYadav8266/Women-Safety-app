import 'package:flutter/material.dart';
import 'package:title_proj/widgets/home_widgets/emergencies/FireBrigadeEmergency.dart';
import 'package:title_proj/widgets/home_widgets/emergencies/AmbulanceEmergency.dart';
import 'package:title_proj/widgets/home_widgets/emergencies/ArmyEmergency.dart';
import 'package:title_proj/widgets/home_widgets/emergencies/PoliceEmergency.dart';

class Emergency extends StatelessWidget {
  const Emergency({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: MediaQuery.of(context).size.width,
      height: 200, // Increased height to avoid clipping
      child: ListView(
        physics: const BouncingScrollPhysics(),
        scrollDirection: Axis.horizontal,
        children: const [
          PoliceEmergency(),
          AmbulanceEmergency(),
          FireBrigadeEmergency(),
          ArmyEmergency(),
        ],
      ),
    );
  }
}
