import 'dart:async';
import 'dart:convert'; // For base64Encode and utf8
import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:provider/provider.dart';
import 'package:sensors_plus/sensors_plus.dart';
import 'package:title_proj/child/bottom_screens/profile_page.dart';
import 'package:title_proj/child/bottom_screens/theme_provider.dart';
import 'package:title_proj/widgets/home_widgets/SOSButton/emergency_service.dart';
import 'package:title_proj/widgets/home_widgets/emergency.dart';
import 'package:title_proj/widgets/home_widgets/safehome/SafeHome.dart';
import 'package:title_proj/widgets/live_safe.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  bool _isSosPressed = false;
  StreamSubscription<UserAccelerometerEvent>? _accelerometerSubscription;

  @override
  void initState() {
    super.initState();
    // Initialize shake detection (if still needed for other purposes)
    _initShakeDetection();
  }

  @override
  void dispose() {
    _accelerometerSubscription?.cancel();
    super.dispose();
  }

  void _initShakeDetection() {
    // Optional: Keep this if you need accelerometer for other features
    _accelerometerSubscription = userAccelerometerEvents.listen((event) {
      // No longer triggering emergency on shake
    });
  }

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final isDarkMode = themeProvider.themeMode == ThemeMode.dark;
    final colors = Theme.of(context).colorScheme;

    return Scaffold(
      body: Column(
        children: [
          // App Bar
          _buildAppBar(context, isDarkMode, themeProvider, colors),
          
          // SOS Button
          Container(
            height: 140,
            padding: const EdgeInsets.only(top: 20),
            child: GestureDetector(
              onTapDown: (_) => setState(() => _isSosPressed = true),
              onTapUp: (_) => setState(() => _isSosPressed = false),
              onTapCancel: () => setState(() => _isSosPressed = false),
              onTap: () async {
                await _handleEmergency(context);
              },
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                width: _isSosPressed ? 110 : 120,
                height: _isSosPressed ? 110 : 120,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: RadialGradient(
                    colors: [
                      Colors.red[800]!,
                      Colors.red[600]!,
                      Colors.red[400]!,
                    ],
                    stops: const [0.1, 0.6, 1.0],
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.red.withOpacity(0.4),
                      blurRadius: 15,
                      spreadRadius: _isSosPressed ? 2 : 5,
                    )
                  ],
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(
                      Icons.emergency,
                      color: Colors.white,
                      size: 40,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'SOS',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 1.5,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),

          // Main Content (Shake toggle removed)
          Expanded(
            child: CustomScrollView(
              physics: const BouncingScrollPhysics(),
              slivers: [
                SliverToBoxAdapter(
                  child: _buildSectionHeader(
                    context,
                    title: "Emergency Contacts",
                    icon: Icons.emergency_outlined,
                  ),
                ),
                SliverToBoxAdapter(
                  child: Emergency(
                    onSosPressed: () async {
                      await _handleEmergency(context);
                    },
                  ),
                ),
                const SliverToBoxAdapter(child: SizedBox(height: 24)),
                SliverToBoxAdapter(
                  child: _buildSectionHeader(
                    context,
                    title: "Explore Safety Features",
                    icon: Icons.explore_outlined,
                  ),
                ),
                SliverToBoxAdapter(
                  child: LiveSafe(),
                ),
                const SliverToBoxAdapter(child: SizedBox(height: 24)),
                SliverToBoxAdapter(
                  child: _buildSectionHeader(
                    context,
                    title: "Your Safe Spaces",
                    icon: Icons.home_work_outlined,
                  ),
                ),
                SliverToBoxAdapter(
                  child: SafeHome(),
                ),
                const SliverToBoxAdapter(child: SizedBox(height: 24)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ... (Keep _buildAppBar, _buildSectionHeader, _handleEmergency unchanged)
  Widget _buildAppBar(BuildContext context, bool isDarkMode, ThemeProvider themeProvider, ColorScheme colors) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [colors.primary, colors.secondary],
                ),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.security,
                color: Colors.white,
                size: 24,
              ),
            ),
            const SizedBox(width: 12),
            Text(
              'SHEild',
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
                foreground: Paint()
                  ..shader = LinearGradient(
                    colors: [colors.primary, colors.secondary],
                  ).createShader(const Rect.fromLTWH(0, 0, 200, 70)),
              ),
            ),
          ],
        ),
        Row(
          children: [
            IconButton(
              icon: Icon(
                isDarkMode ? Icons.light_mode : Icons.dark_mode,
                color: colors.onSurface,
              ),
              onPressed: () {
                themeProvider.toggleTheme(!isDarkMode);
              },
            ),
            const SizedBox(width: 8),
            GestureDetector(
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const ProfilePage()),
              ),
              child: Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: LinearGradient(
                    colors: [
                      colors.primary.withOpacity(0.8),
                      colors.secondary.withOpacity(0.8),
                    ],
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: colors.primary.withOpacity(0.2),
                      blurRadius: 8,
                      spreadRadius: 2,
                    )
                  ],
                ),
                child: Icon(
                  Icons.person_outline,
                  color: Colors.white,
                  size: 20,
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildSectionHeader(BuildContext context, {required String title, required IconData icon}) {
    final colors = Theme.of(context).colorScheme;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        children: [
          Icon(
            icon,
            color: colors.secondary,
            size: 28,
          ),
          const SizedBox(width: 12),
          Text(
            title,
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w600,
              color: colors.onSurface,
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _handleEmergency(BuildContext context) async {
    try {
      await EmergencyService().handleEmergency();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Emergency alert sent successfully!'),
            backgroundColor: Colors.green,
            duration: Duration(seconds: 3),
        ));
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to send alert: ${e.toString()}'),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 3),
          ),
        );
      }
    }
  }
}