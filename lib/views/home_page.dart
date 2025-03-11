import 'package:flutter/material.dart';
import 'package:animated_bottom_navigation_bar/animated_bottom_navigation_bar.dart';
import 'package:absensi_app/views/absensi/absensi_page.dart';
import 'package:absensi_app/views/dashboard/dashboard_page.dart';
import 'package:absensi_app/views/profile/profile_page.dart';
import 'package:absensi_app/views/riwayat/riwayat_page.dart';
import 'package:absensi_app/views/notification/notification_page.dart'; // New page

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _selectedIndex = 0;
  final List<IconData> _iconList = [
    Icons.home_rounded,
    Icons.history_rounded,
    Icons.notifications_rounded, // New icon for notifications
    Icons.person_rounded,
  ];

  // Updated to include 5 pages (with AbsensiPage accessed via FAB)
  static const List<Widget> _pages = <Widget>[
    DashboardPage(),
    RiwayatPage(),
    NotificationPage(), // New page
    ProfilePage(),
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _pages[_selectedIndex],
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.blue,

        elevation: 8,
        shape: const CircleBorder(),

        child: const Icon(
          Icons.location_on_rounded,
          color: Colors.white,
        ),
        onPressed: () {
          // Show AbsensiPage as a modal or navigate to it
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (context) => const AbsensiPage(),
            ),
          );
        },
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      bottomNavigationBar: AnimatedBottomNavigationBar(
        icons: _iconList,
        activeIndex: _selectedIndex,
        gapLocation: GapLocation.center,
        notchSmoothness: NotchSmoothness.smoothEdge,
        onTap: _onItemTapped,
        activeColor: Colors.blue,
        inactiveColor: Colors.grey,
        backgroundColor: Colors.white,
        elevation: 12,
        // Custom styling
        leftCornerRadius: 32,
        rightCornerRadius: 32,
        iconSize: 24,
        shadow: const BoxShadow(
          offset: Offset(0, 1),
          blurRadius: 12,
          spreadRadius: 0.5,
          color: Colors.black12,
        ),
      ),
    );
  }
}