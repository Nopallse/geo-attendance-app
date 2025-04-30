import 'package:flutter/material.dart';
import 'package:animated_bottom_navigation_bar/animated_bottom_navigation_bar.dart';
import 'package:absensi_app/screens/absensi/absensi_page.dart';
import 'package:absensi_app/screens/dashboard/dashboard_page.dart';
import 'package:absensi_app/screens/profile/profile_page.dart';
import 'package:absensi_app/screens/riwayat/riwayat_page.dart';
import 'package:absensi_app/screens/notification/notification_page.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _bottomNavIndex = 0;
  final List<IconData> iconList = [
    Icons.home_rounded,
    Icons.history_rounded,
    Icons.notifications_rounded,
    Icons.person_rounded,
  ];

  // Pages for each tab
  static const List<Widget> _pages = <Widget>[
    DashboardPage(),
    RiwayatPage(),
    NotificationPage(),
    ProfilePage(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _pages[_bottomNavIndex],
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
      bottomNavigationBar: AnimatedBottomNavigationBar.builder(
        itemCount: iconList.length,
        tabBuilder: (int index, bool isActive) {
          return Icon(
            iconList[index],
            size: 24,
            color: isActive ? Colors.blue : Colors.grey,
          );
        },
        activeIndex: _bottomNavIndex,
        gapLocation: GapLocation.center,
        notchSmoothness: NotchSmoothness.smoothEdge,
        leftCornerRadius: 32,
        rightCornerRadius: 32,
        onTap: (index) => setState(() => _bottomNavIndex = index),
        backgroundColor: Colors.white,
        elevation: 12,
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