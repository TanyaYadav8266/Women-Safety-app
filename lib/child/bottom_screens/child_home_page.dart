import 'dart:async';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:provider/provider.dart';
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
  final EmergencyService _emergencyService = EmergencyService();

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final isDarkMode = themeProvider.themeMode == ThemeMode.dark;
    final colors = Theme.of(context).colorScheme;

    return Scaffold(
      body: Column(
        children: [
          _buildAppBar(context, isDarkMode, themeProvider, colors),
          Expanded(
            child: CustomScrollView(
              physics: const BouncingScrollPhysics(),
              slivers: [
                // Emergency Contacts Section
                SliverToBoxAdapter(
                  child: _buildSectionHeader(
                    context,
                    title: "Emergency Contacts",
                    icon: Icons.emergency_outlined,
                  ),
                ),
                SliverToBoxAdapter(
                  child: Emergency(
                    onSosPressed: () => _handleEmergency(context),
                  ),
                ),
                const SliverToBoxAdapter(child: SizedBox(height: 16)),

                // SOS Button Section
                SliverToBoxAdapter(
                  child: Column(
                    children: [
                      GestureDetector(
                        onTapDown: (_) => setState(() => _isSosPressed = true),
                        onTapUp: (_) => setState(() => _isSosPressed = false),
                        onTapCancel: () => setState(() => _isSosPressed = false),
                        onTap: () => _handleEmergency(context),
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 200),
                          width: _isSosPressed ? 120 : 130,
                          height: _isSosPressed ? 140 : 150,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: Color(0xFFEC407A),
                            // RGB(216, 68, 173)
                   // RGB(248, 7, 89)
                            boxShadow: [
                              BoxShadow(
                                color:  Color.fromARGB(255, 240, 56, 117),
                                
                                blurRadius: 20,
                                spreadRadius: _isSosPressed ? 5 : 10,
                              )
                            ],
                          ),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                'SOS',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 36,
                                  fontWeight: FontWeight.bold,
                                  letterSpacing: 2,
                                ),
                              ),
                              const SizedBox(height: 4),
                              
                              
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 20),
                    ],
                  ),
                ),

                // Explore Safety Features Section
                SliverToBoxAdapter(
                  child: _buildSectionHeader(
                    context,
                    title: "Explore Safety Features",
                    icon: Icons.explore_outlined,
                  ),
                ),
                SliverToBoxAdapter(child: LiveSafe()),
                const SliverToBoxAdapter(child: SizedBox(height: 8)),

                // Your Safe Spaces Section
                SliverToBoxAdapter(
                  child: _buildSectionHeader(
                    context,
                    title: "Your Safe Spaces",
                    icon: Icons.home_work_outlined,
                  ),
                ),
                SliverToBoxAdapter(child: SafeHome()),
                const SliverToBoxAdapter(child: SizedBox(height: 24)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAppBar(BuildContext context, bool isDarkMode, ThemeProvider themeProvider, ColorScheme colors) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
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
                  child: const Icon(
                    Icons.person_outline,
                    color: Colors.white,
                    size: 20,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(BuildContext context, {required String title, required IconData icon}) {
    final colors = Theme.of(context).colorScheme;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
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
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => const AlertDialog(
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              CircularProgressIndicator(),
              SizedBox(height: 16),
              Text('Getting your location...'),
            ],
          ),
        ),
      );

      final permissionStatus = await Permission.location.request();
      if (!permissionStatus.isGranted) {
        Navigator.pop(context);
        _showPermissionDeniedDialog(context);
        return;
      }

      final isLocationEnabled = await Geolocator.isLocationServiceEnabled();
      if (!isLocationEnabled) {
        Navigator.pop(context);
        _showLocationServicesDialog(context);
        return;
      }

      final position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      ).timeout(const Duration(seconds: 15));

      await _emergencyService.handleEmergency(position);

      Navigator.pop(context);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Emergency alert sent successfully!'),
            backgroundColor: Colors.green,
            duration: Duration(seconds: 3),
          ),
        );
      }
    } on TimeoutException {
      Navigator.pop(context);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Location timeout - please try again in an open area'),
            backgroundColor: Colors.red,
            duration: Duration(seconds: 3),
          ),
        );
      }
    } catch (e) {
      Navigator.pop(context);
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

  void _showPermissionDeniedDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Location Permission Required'),
        content: const Text('Please enable location permissions in app settings'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => openAppSettings(),
            child: const Text('Open Settings'),
          ),
        ],
      ),
    );
  }

  void _showLocationServicesDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Location Services Disabled'),
        content: const Text('Please enable location services'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Geolocator.openLocationSettings(),
            child: const Text('Enable Location'),
          ),
        ],
      ),
    );
  }
}