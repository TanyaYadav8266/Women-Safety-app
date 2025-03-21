import 'package:flutter/material.dart';
import 'package:title_proj/child/bottom_screens/add_contacts.dart';
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
  // List of pages for navigation
  final List<Widget> pages = [
    HomeScreen(),
    AddContactsPage(),
    ChatPage(),
    ProfilePage(),
    ReviewPage(),
  ];

  // Current selected index
  int _currentIndex = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(child: pages[_currentIndex]), // Prevents UI from being hidden
      bottomNavigationBar: Padding(
        padding: EdgeInsets.only(bottom: MediaQuery.of(context).padding.bottom),
        child: BottomNavigationBar(
          type: BottomNavigationBarType.fixed, // Fixes shifting issue
          currentIndex: _currentIndex,
          selectedItemColor: Colors.deepPurple,
          unselectedItemColor: Colors.grey,
          showUnselectedLabels: true,
          onTap: (index) {
            setState(() {
              _currentIndex = index;
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
      ),
    );
  }
}
