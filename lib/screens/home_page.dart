// lib/screens/home/home_page.dart
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:animated_bottom_navigation_bar/animated_bottom_navigation_bar.dart';

class HomePage extends StatefulWidget {
  final Widget child;

  const HomePage({
    Key? key,
    required this.child,
  }) : super(key: key);

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final List<String> _routePaths = [
    '/dashboard',
    '/riwayat',
    '/notifications',
    '/profile',
  ];

  final List<IconData> _iconList = [
    Icons.home_rounded,
    Icons.history_rounded,
    Icons.notifications_rounded,
    Icons.person_rounded,
  ];

  int _getCurrentIndex(BuildContext context) {
    final String location = GoRouterState.of(context).matchedLocation;
    int index = _routePaths.indexOf(location);
    return index < 0 ? 0 : index;
  }

  @override
  Widget build(BuildContext context) {
    final int currentIndex = _getCurrentIndex(context);

    return Scaffold(
      body: widget.child,
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.blue,
        elevation: 8,
        shape: const CircleBorder(),
        child: const Icon(
          Icons.location_on_rounded,
          color: Colors.white,
        ),
        onPressed: () {
          // Navigate to the absensi page using GoRouter
          context.push('/absensi');
        },
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      bottomNavigationBar: AnimatedBottomNavigationBar.builder(
        itemCount: _iconList.length,
        tabBuilder: (int index, bool isActive) {
          return Icon(
            _iconList[index],
            size: 24,
            color: isActive ? Colors.blue : Colors.grey,
          );
        },
        activeIndex: currentIndex,
        gapLocation: GapLocation.center,
        notchSmoothness: NotchSmoothness.smoothEdge,
        leftCornerRadius: 32,
        rightCornerRadius: 32,
        onTap: (index) => context.go(_routePaths[index]),
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