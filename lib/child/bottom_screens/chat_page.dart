import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class ChatPage extends StatelessWidget {
  const ChatPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Select Guardian"),
        backgroundColor: Colors.pink,  // You can adjust the color to fit your theme
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('users')
            .where('type', isEqualTo: 'guardian')  // Query to fetch users with 'guardian' type
            .snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return Center(child: CircularProgressIndicator());
          }

          final guardians = snapshot.data!.docs;

          // Debug: Print number of guardians
          print('Found ${guardians.length} guardians');

          return ListView.builder(
            itemCount: guardians.length,
            itemBuilder: (context, index) {
              final guardian = guardians[index];
              final guardianName = guardian['name'];  // Assuming 'name' is the field for the guardian's name

              // Debug: Print each guardian's name
              print('Guardian: $guardianName');

              return Padding(
                padding: const EdgeInsets.all(8.0),
                child: Card(
                  color: Colors.pink[100],  // Guardian card color
                  child: ListTile(
                    title: Text(guardianName),
                    onTap: () {
                      // Handle guardian selection, you can pass guardian data to the next page
                      print('Selected Guardian: $guardianName');
                    },
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
