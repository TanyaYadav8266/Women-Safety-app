import 'package:flutter/material.dart';
import 'package:title_proj/child/bottom_screens/chat_page.dart';
import 'package:title_proj/child/bottom_screens/child_home_page.dart';
import 'package:title_proj/child/bottom_screens/contacts_page.dart';
import 'package:title_proj/child/bottom_screens/profile_page.dart';
import 'package:title_proj/child/bottom_screens/review_page.dart';

class BottomPage extends StatefulWidget {
  const BottomPage({super.key});

  @override
  State<BottomPage> createState() => _BottomPageState();
}

class _BottomPageState extends State<BottomPage> {
  // List of pages for the navigation
  List<Widget> pages = [
    HomeScreen(),
    ContactsPage(),
    ChatPage(),
    ProfilePage(),
    ReviewPage(),
  ];

  // Current selected index for the navigation
  int _currentIndex = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: pages[_currentIndex], // Display the page based on the selected index
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex, // Set the current selected index
        onTap: (index) {
          setState(() {
            _currentIndex = index; // Update the selected index when the user taps an item
          });
        },
        items: const [
          BottomNavigationBarItem(
            label: 'Home',
            icon: Icon(Icons.home),
          ),
          BottomNavigationBarItem(
            label: 'Contacts',
            icon: Icon(Icons.contacts),
          ),
          BottomNavigationBarItem(
            label: 'Chats',
            icon: Icon(Icons.chat),
          ),
          BottomNavigationBarItem(
            label: 'Profile',
            icon: Icon(Icons.account_circle),
          ),
          BottomNavigationBarItem(
            label: 'Reviews',
            icon: Icon(Icons.rate_review),
          ),
        ],
      ),
    );
  }
}
