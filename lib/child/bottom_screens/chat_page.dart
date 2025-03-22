import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:title_proj/child/bottom_screens/guardian_child_page.dart';
  // Correct import for GuardianChildrenPage

class ChatPage extends StatelessWidget {
  const ChatPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Select Guardian"),
        backgroundColor: Colors.pink,
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('users')
            .where('type', isEqualTo: 'guardian')  // Fetch guardians from Firestore
            .snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return Center(child: CircularProgressIndicator());
          }

          final guardians = snapshot.data!.docs;

          return ListView.builder(
            itemCount: guardians.length,
            itemBuilder: (context, index) {
              final guardian = guardians[index];
              final guardianName = guardian['name'];
              final guardianEmail = guardian['guardiantEmail'];  // Corrected field name

              return Padding(
                padding: const EdgeInsets.all(8.0),
                child: Card(
                  color: Colors.pink[100],
                  child: ListTile(
                    title: Text(guardianName),
                    onTap: () {
                      // Pass the guardian's email to the next page
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => GuardianChildrenPage(guardianEmail: guardianEmail),
                        ),
                      );
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
