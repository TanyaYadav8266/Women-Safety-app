import 'package:flutter/material.dart';
import 'package:title_proj/widgets/home_widgets/emergencies.dart/FireBrigadeEmergency.dart';
import 'package:title_proj/widgets/home_widgets/emergencies/AmbulanceEmergency.dart';
import 'package:title_proj/widgets/home_widgets/emergencies/ArmyEmergency.dart';
import 'package:title_proj/widgets/home_widgets/emergencies/policeemergency.dart';

class Emergency extends StatelessWidget {
  const Emergency({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: MediaQuery.of(context).size.width,
      height: 180,
      child: ListView(
        physics: BouncingScrollPhysics(),
        scrollDirection: Axis.horizontal,
        children: [
          PoliceEmergency(),
          AmbulanceEmergency(),
          FireBrigadeEmergency(), // Fixed naming
          ArmyEmergency(),
        ],
      ),
    );
  }
}
