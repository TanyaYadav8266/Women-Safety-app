import 'package:flutter/material.dart';
import 'package:title_proj/child/bottom_screens/ExploreMore.dart';
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
    ExploreMorePage(),
    ReviewPage(),
  ];

  // Current selected index
  int _currentIndex = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(child: pages[_currentIndex]),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.3),
              blurRadius: 10,
              offset: Offset(0, -5),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.vertical(top: Radius.circular(15)),
          child: BottomNavigationBar(
            type: BottomNavigationBarType.fixed,
            backgroundColor: Colors.white,
            currentIndex: _currentIndex,
            selectedItemColor: Colors.deepPurple,
            unselectedItemColor: Colors.grey,
            selectedLabelStyle: TextStyle(fontWeight: FontWeight.bold),
            showSelectedLabels: true,
            showUnselectedLabels: true,
            onTap: (index) {
              setState(() {
                _currentIndex = index;
              });
            },
            items: const [
              BottomNavigationBarItem(
                label: 'Home',
                icon: Icon(Icons.home_outlined),
                activeIcon: Icon(Icons.home),
              ),
              BottomNavigationBarItem(
                label: 'Contacts',
                icon: Icon(Icons.contacts_outlined),
                activeIcon: Icon(Icons.contacts),
              ),
              BottomNavigationBarItem(
                label: 'Chats',
                icon: Icon(Icons.chat_outlined),
                activeIcon: Icon(Icons.chat),
              ),
              BottomNavigationBarItem(
                label: 'Explore',
                icon: Icon(Icons.explore_outlined),
                activeIcon: Icon(Icons.explore),
              ),
              BottomNavigationBarItem(
                label: 'Reviews',
                icon: Icon(Icons.reviews_outlined),
                activeIcon: Icon(Icons.reviews),
              ),
            ],
          ),
        ),
      ),
    );
  }
}