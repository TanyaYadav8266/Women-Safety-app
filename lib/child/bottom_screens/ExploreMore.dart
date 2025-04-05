import 'package:flutter/material.dart';
import 'package:title_proj/widgets/home_widgets/CustomCarouel.dart';
import 'package:title_proj/widgets/home_widgets/listview/DetectCamera.dart';
import 'package:title_proj/widgets/home_widgets/listview/RiskAnalysis.dart';
import 'package:title_proj/widgets/home_widgets/listview/SelfDefence.dart';

class ExploreMorePage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFFF5F5F5),
      body: CustomScrollView(
        slivers: [
          // App Bar with gradient
          SliverAppBar(
            expandedHeight: 120,
            flexibleSpace: FlexibleSpaceBar(
              title: Text('Explore Safety',
                  style: TextStyle(color: Colors.white, fontSize: 24)),
              background: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      Color(0xFFEC407A),
                      Color(0xFFAB47BC),
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                ),
              ),
            ),
            pinned: true,
            actions: [
              IconButton(
                icon: Icon(Icons.search, color: Colors.white),
                onPressed: () {},
              ),
            ],
          ),

          // Content
          SliverList(
            delegate: SliverChildListDelegate([
              // Custom Carousel
              Padding(
                padding: EdgeInsets.symmetric(vertical: 20, horizontal: 10),
                child: CustomCarouel(),
              ),

              // Safety Tools Section
              Padding(
                padding: EdgeInsets.fromLTRB(20, 10, 20, 10),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Safety Tools',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF333333),
                      ),
                    ),
                    SizedBox(height: 12),
                    Container(
                      height: 180,
                      child: ListView(
                        scrollDirection: Axis.horizontal,
                        children: [
                          SizedBox(width: 5),
                          DetectCameras(),
                          SizedBox(width: 15),
                          RiskAnalysis(),
                          SizedBox(width: 15),
                          SelfDefence(),
                          SizedBox(width: 5),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              // Safety Guides Section
              Padding(
                padding: EdgeInsets.fromLTRB(20, 0, 20, 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Safety Guides',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF333333),
                      ),
                    ),
                    SizedBox(height: 12),
                    GridView.count(
                      shrinkWrap: true,
                      physics: NeverScrollableScrollPhysics(),
                      crossAxisCount: 2,
                      childAspectRatio: 1.3,
                      crossAxisSpacing: 15,
                      mainAxisSpacing: 15,
                      children: [
                        _buildResourceCard(
                          Icons.self_improvement,
                          'Self Defense Tips',
                          Color(0xFFEC407A),
                        ),
                        _buildResourceCard(
                          Icons.security,
                          'Risk Prevention',
                          Color(0xFFAB47BC),
                        ),
                        _buildResourceCard(
                          Icons.camera_alt,
                          'Camera Safety',
                          Color(0xFF7E57C2),
                        ),
                        _buildResourceCard(
                          Icons.emergency,
                          'Emergency Prep',
                          Color(0xFFF06292),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              // Quick Contacts Section
              Padding(
                padding: EdgeInsets.fromLTRB(20, 0, 20, 40),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Quick Contacts',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF333333),
                      ),
                    ),
                    SizedBox(height: 15),
                    Container(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(15),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.grey.withOpacity(0.2),
                            blurRadius: 10,
                            offset: Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Column(
                        children: [
                          _buildContactTile(
                            Icons.local_police,
                            'Police',
                            '100',
                            Color(0xFFEC407A),
                          ),
                          Divider(height: 1, indent: 20),
                          _buildContactTile(
                            Icons.local_hospital,
                            'Ambulance',
                            '108',
                            Color(0xFFAB47BC),
                          ),
                          Divider(height: 1, indent: 20),
                          _buildContactTile(
                            Icons.woman,
                            'Women\'s Helpline',
                            '1091',
                            Color(0xFF7E57C2),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ]),
          ),
        ],
      ),
    );
  }

  // Resource Card Widget
  Widget _buildResourceCard(IconData icon, String title, Color color) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.2),
            blurRadius: 10,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(15),
          onTap: () {
            // Add navigation to respective feature
          },
          child: Padding(
            padding: EdgeInsets.all(15),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  padding: EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: color.withOpacity(0.1),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(icon, color: color, size: 30),
                ),
                SizedBox(height: 12),
                Text(
                  title,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF333333),
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // Contact Tile Widget
  Widget _buildContactTile(IconData icon, String title, String number, Color color) {
    return ListTile(
      leading: Container(
        padding: EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          shape: BoxShape.circle,
        ),
        child: Icon(icon, color: color),
      ),
      title: Text(title, style: TextStyle(fontWeight: FontWeight.bold)),
      subtitle: Text(number),
      trailing: IconButton(
        icon: Icon(Icons.phone, color: color),
        onPressed: () {
          // Implement call functionality
        },
      ),
    );
  }
}
