import 'package:flutter/material.dart';
import 'package:title_proj/widgets/home_widgets/listview/SelfDefencePage.dart'; // Import the SelfDefencePage

class SelfDefence extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: 20), // Match the padding
      child: Column(
        children: [
          InkWell(
            onTap: () {
              // Navigate to the SelfDefencePage
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => SelfDefencePage()),
              );
            },
            child: Card(
              elevation: 3, // Match the elevation
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20), // Match the border radius
              ),
              child: Container(
                height: 50, // Match the height
                width: 50, // Match the width
                child: Center(
                  child: Icon(
                    Icons.self_improvement, // Self Defence-related icon
                    size: 32, // Match the icon size
                    color: Colors.black, // Match the icon color
                  ),
                ),
              ),
            ),
          ),
          Text('Self Defence'), // Match the text below the button
        ],
      ),
    );
  }
}