import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:title_proj/widgets/home_widgets/CustomCarouel.dart';
import 'package:title_proj/widgets/home_widgets/listview/DetectCamera.dart';
import 'package:title_proj/widgets/home_widgets/listview/MagnetometerPage.dart';
import 'package:title_proj/widgets/home_widgets/listview/RiskAnalysis.dart';
import 'package:title_proj/widgets/home_widgets/listview/SelfDefencePage.dart';
import 'package:title_proj/widgets/home_widgets/listview/community_forum.dart';
import 'package:title_proj/widgets/home_widgets/listview/crime_map_page.dart';
import 'package:title_proj/widgets/home_widgets/listview/mental_health_chat.dart';
import 'package:title_proj/widgets/home_widgets/listview/period_tracker.dart';

class ExploreMorePage extends StatefulWidget {
  @override
  _ExploreMorePageState createState() => _ExploreMorePageState();
}

class _ExploreMorePageState extends State<ExploreMorePage> {
  String _locationMessage = "Getting your location...";
  bool _isLoadingLocation = true;

  @override
  void initState() {
    super.initState();
    _getCurrentLocation();
  }

  Future<void> _getCurrentLocation() async {
    try {
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        setState(() {
          _locationMessage = "Enable location services to see nearby services";
          _isLoadingLocation = false;
        });
        return;
      }

      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          setState(() {
            _locationMessage = "Location permissions denied";
            _isLoadingLocation = false;
          });
          return;
        }
      }

      if (permission == LocationPermission.deniedForever) {
        setState(() {
          _locationMessage = "Location permissions permanently denied";
          _isLoadingLocation = false;
        });
        return;
      }

      Position position = await Geolocator.getCurrentPosition();
      setState(() {
        _locationMessage = "Location services active";
        _isLoadingLocation = false;
      });
    } catch (e) {
      setState(() {
        _locationMessage = "Error getting location";
        _isLoadingLocation = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFFF5F5F5),
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 110, // Reduced expanded height
            flexibleSpace: FlexibleSpaceBar(
              titlePadding: EdgeInsets.only(left: 20, bottom: 16), // Adjusted title padding
              title: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Explore Safety',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 24, // Reduced font size
                      fontWeight: FontWeight.bold,
                      shadows: [
                        Shadow(
                          blurRadius: 4,
                          color: Colors.black.withOpacity(0.3),
                          offset: Offset(1, 1),
                        ),
                      ],
                    ),
                  ),
                  Text(
                    'Your comprehensive safety toolkit',
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.9),
                      fontSize: 12, // Reduced font size
                      shadows: [
                        Shadow(
                          blurRadius: 2,
                          color: Colors.black.withOpacity(0.2),
                          offset: Offset(1, 1),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
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

          SliverList(
            delegate: SliverChildListDelegate([
              // Custom Carousel
              Padding(
                padding: EdgeInsets.symmetric(vertical: 10, horizontal: 10), // Reduced vertical padding
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
                        fontSize: 20, // Reduced font size
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF333333),
                      ),
                    ),
                    SizedBox(height: 10), // Reduced spacing
                    Container(
                      height: 160, // Reduced height
                      child: ListView(
                        scrollDirection: Axis.horizontal,
                        children: [
                          SizedBox(width: 5),
                          _buildSafetyTool(
                            context,
                            Icons.camera_alt,
                            'Detect Camera',
                            Color(0xFFEC407A),
                            DetectCameraIntroPage(),
                          ),
                          SizedBox(width: 15),
                          _buildSafetyTool(
                            context,
                            Icons.analytics,
                            'Risk Analysis',
                            Color(0xFFAB47BC),
                            RiskAnalysisIntroPage(),
                          ),
                          SizedBox(width: 5),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              // Health & Wellbeing Section
              Padding(
                padding: EdgeInsets.fromLTRB(20, 0, 20, 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Health & Wellbeing',
                      style: TextStyle(
                        fontSize: 20, // Reduced font size
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF333333),
                      ),
                    ),
                    SizedBox(height: 10), // Reduced spacing
                    GridView.count(
                      shrinkWrap: true,
                      physics: NeverScrollableScrollPhysics(),
                      crossAxisCount: 2,
                      childAspectRatio: 1.1, // Adjusted aspect ratio to reduce overflow
                      crossAxisSpacing: 10, // Reduced spacing
                      mainAxisSpacing: 10, // Reduced spacing
                      padding: EdgeInsets.zero, // Remove default padding
                      children: [
                        _buildResourceCard(
                          context,
                          Icons.calendar_today,
                          'Period Tracker',
                          Color(0xFFF06292),
                          PeriodTrackerIntroPage(),
                        ),
                        _buildResourceCard(
                          context,
                          Icons.psychology,
                          'Mental Health',
                          Color(0xFF26C6DA),
                          MentalHealthChatIntroPage(),
                        ),
                        _buildResourceCard(
                          context,
                          Icons.forum,
                          'Community',
                          Color(0xFF66BB6A),
                          CommunityForumIntroPage(),
                        ),
                        _buildResourceCard(
                          context,
                          Icons.security,
                          'Self Defence',
                          Color(0xFF7E57C2),
                          SelfDefenceIntroPage(),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              // Nearby Services Section
              Padding(
                padding: EdgeInsets.fromLTRB(20, 0, 20, 40),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Nearby Services',
                      style: TextStyle(
                        fontSize: 20, // Reduced font size
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF333333),
                      ),
                    ),
                    SizedBox(height: 10),
                    _isLoadingLocation
                        ? Row(
                            children: [
                              CircularProgressIndicator(),
                              SizedBox(width: 10),
                              Text("Finding your location..."),
                            ],
                          )
                        : Text(
                            _locationMessage,
                            style: TextStyle(color: Colors.grey[600]),
                          ),
                    SizedBox(height: 15),
                    _buildNearbyService(
                      'Police Stations',
                      Icons.local_police,
                      Color(0xFFEC407A),
                    ),
                    SizedBox(height: 10),
                    _buildNearbyService(
                      'Hospitals',
                      Icons.local_hospital,
                      Color(0xFFAB47BC),
                    ),
                    SizedBox(height: 10),
                    _buildNearbyService(
                      'Women\'s Shelters',
                      Icons.security,
                      Color(0xFF7E57C2),
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

  Widget _buildSafetyTool(BuildContext context, IconData icon, String title, Color color, Widget page) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12), // Reduced border radius
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: () => Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => page),
        ),
        child: Container(
          width: 140, // Reduced width
          padding: EdgeInsets.all(12), // Reduced padding
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: EdgeInsets.all(10), // Reduced padding
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(icon, color: color, size: 28), // Reduced icon size
              ),
              SizedBox(height: 8), // Reduced spacing
              Text(
                title,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF333333),
                  fontSize: 12, // Reduced font size
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildResourceCard(BuildContext context, IconData icon, String title, Color color, Widget page) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12), // Reduced border radius
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: () => Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => page),
        ),
        child: Padding(
          padding: EdgeInsets.all(12), // Reduced padding
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: EdgeInsets.all(10), // Reduced padding
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(icon, color: color, size: 28), // Reduced icon size
              ),
              SizedBox(height: 8), // Reduced spacing
              Text(
                title,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF333333),
                  fontSize: 12, // Reduced font size
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildNearbyService(String title, IconData icon, Color color) {
    return Card(
      margin: EdgeInsets.symmetric(vertical: 5), // Added margin for spacing
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10),
      ),
      child: ListTile(
        onTap: () {
          // Implement navigation to map with filtered services
        },
        leading: Container(
          padding: EdgeInsets.all(8), // Reduced padding
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            shape: BoxShape.circle,
          ),
          child: Icon(icon, color: color, size: 20), // Reduced icon size
        ),
        title: Text(title, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)), // Reduced font size
        subtitle: Text('View nearby locations', style: TextStyle(fontSize: 12)), // Reduced font size
        trailing: Icon(Icons.arrow_forward, color: color, size: 20), // Reduced icon size
      ),
    );
  }
}

// Intro Pages with Start Buttons
class DetectCameraIntroPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Camera Detection'),
        backgroundColor: Color(0xFFEC407A),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.camera_alt, size: 70, color: Color(0xFFEC407A)), // Reduced icon size
            SizedBox(height: 15), // Reduced spacing
            Text(
              'Hidden Camera Detection',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold), // Reduced font size
            ),
            SizedBox(height: 15), // Reduced spacing
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 30), // Reduced padding
              child: Text(
                'Scan your surroundings for hidden cameras using your device sensors',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 14), // Reduced font size
              ),
            ),
            SizedBox(height: 25), // Reduced spacing
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                iconColor: Color(0xFFEC407A),
                padding: EdgeInsets.symmetric(horizontal: 25, vertical: 12), // Reduced padding
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(18), // Reduced border radius
                ),
              ),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => MagnetometerPage()),
                );
              },
              child: Text('START DETECTION', style: TextStyle(fontSize: 14)), // Reduced font size
            ),
          ],
        ),
      ),
    );
  }
}

class RiskAnalysisIntroPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Risk Analysis'),
        backgroundColor: Color(0xFFAB47BC),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.analytics, size: 70, color: Color(0xFFAB47BC)), // Reduced icon size
            SizedBox(height: 15), // Reduced spacing
            Text(
              'Safety Risk Analysis',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold), // Reduced font size
            ),
            SizedBox(height: 15), // Reduced spacing
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 30), // Reduced padding
              child: Text(
                'Assess potential risks in your current location or planned route',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 14), // Reduced font size
              ),
            ),
            SizedBox(height: 25), // Reduced spacing
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                iconColor: Color(0xFFAB47BC),
                padding: EdgeInsets.symmetric(horizontal: 25, vertical: 12), // Reduced padding
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(18), // Reduced border radius
                ),
              ),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => CrimeMapPage()),
                );
              },
              child: Text('START ANALYSIS', style: TextStyle(fontSize: 14)), // Reduced font size
            ),
          ],
        ),
      ),
    );
  }
}


class SelfDefenceIntroPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Self Defence'),
        backgroundColor: Color(0xFF7E57C2),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.self_improvement, size: 80, color: Color(0xFF7E57C2)),
            SizedBox(height: 20),
            Text(
              'Self Defence Training',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 20),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 40),
              child: Text(
                'Learn essential self-defence techniques and practice virtually',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 16),
              ),
            ),
            SizedBox(height: 30),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                iconColor: Color(0xFF7E57C2),
                padding: EdgeInsets.symmetric(horizontal: 30, vertical: 15),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
              ),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => SelfDefencePage()),
                );
              },
              child: Text('START TRAINING'),
            ),
          ],
        ),
      ),
    );
  }
}

class PeriodTrackerIntroPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Period Tracker'),
        backgroundColor: Color(0xFFF06292),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.calendar_today, size: 80, color: Color(0xFFF06292)),
            SizedBox(height: 20),
            Text(
              'Period & Health Tracker',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 20),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 40),
              child: Text(
                'Track your menstrual cycle and receive predictions and health insights',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 16),
              ),
            ),
            SizedBox(height: 30),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                iconColor: Color(0xFFF06292),
                padding: EdgeInsets.symmetric(horizontal: 30, vertical: 15),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
              ),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => PeriodTrackerPage(),
                  ),
                );
              },
              child: Text('START TRACKING'),
            ),
          ],
        ),
      ),
    );
  }
}

class MentalHealthChatIntroPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Mental Health Support'),
        backgroundColor: Color(0xFF26C6DA),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.psychology, size: 80, color: Color(0xFF26C6DA)),
            SizedBox(height: 20),
            Text(
              'Mental Wellbeing Chat',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 20),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 40),
              child: Text(
                'Talk to our supportive chatbot about your mental health concerns',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 16),
              ),
            ),
            SizedBox(height: 30),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                iconColor: Color(0xFF26C6DA),
                padding: EdgeInsets.symmetric(horizontal: 30, vertical: 15),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
              ),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => MentalHealthChat()),
                );
              },
              child: Text('START CHAT'),
            ),
          ],
        ),
      ),
    );
  }
}

class CommunityForumIntroPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Community Forum'),
        backgroundColor: Color(0xFF66BB6A),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.forum, size: 80, color: Color(0xFF66BB6A)),
            SizedBox(height: 20),
            Text(
              'Safety Community',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 20),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 40),
              child: Text(
                'Connect with others, share experiences and safety tips',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 16),
              ),
            ),
            SizedBox(height: 30),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                iconColor: Color(0xFF66BB6A),
                padding: EdgeInsets.symmetric(horizontal: 30, vertical: 15),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
              ),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => CommunityForum()),
                );
              },
              child: Text('VIEW FORUM'),
            ),
          ],
        ),
      ),
    );
  }
}