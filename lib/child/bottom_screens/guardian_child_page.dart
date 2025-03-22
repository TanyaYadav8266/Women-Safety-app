import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class GuardianChildrenPage extends StatelessWidget {
  final String guardianEmail;

  const GuardianChildrenPage({super.key, required this.guardianEmail});

  @override
  Widget build(BuildContext context) {
    print('Guardian email passed: $guardianEmail');  // Debugging print to check the email passed

    return Scaffold(
      appBar: AppBar(
        title: Text("Children of Guardian"),
        backgroundColor: Colors.pink,
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('users')  // Query from 'users' collection
            .where('guardiantEmail', isEqualTo: guardianEmail)  // Filter children by guardian's email
            .where('type', isEqualTo: 'child')  // Only fetch documents with type 'child'
            .snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return Center(child: CircularProgressIndicator());
          }

          final children = snapshot.data!.docs;

          if (children.isEmpty) {
            return Center(child: Text("No children found for this guardian."));
          }

          return ListView.builder(
            itemCount: children.length,
            itemBuilder: (context, index) {
              final child = children[index];
              final childName = child['name'];  // Get the child's name

              return Padding(
                padding: const EdgeInsets.all(8.0),
                child: Card(
                  color: Colors.pink[100],  // Child card color
                  child: ListTile(
                    title: Text(childName),
                    onTap: () {
                      print('Selected Child: $childName');
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
