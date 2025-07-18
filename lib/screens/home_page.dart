// lib/screens/home/home_page.dart
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:animated_bottom_navigation_bar/animated_bottom_navigation_bar.dart';
import '../../utils/responsive_utils.dart';
import '../../styles/colors.dart';

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

  final List<String> _labelList = [
    'Dashboard',
    'Riwayat',
    'Notifikasi',
    'Profil',
  ];

  int _getCurrentIndex(BuildContext context) {
    final String location = GoRouterState.of(context).matchedLocation;
    int index = _routePaths.indexOf(location);
    return index < 0 ? 0 : index;
  }

  @override
  Widget build(BuildContext context) {
    final int currentIndex = _getCurrentIndex(context);
    final bool isWeb = ResponsiveUtils.isWeb(context);

    return ResponsiveLayout(
      mobile: _buildMobileLayout(currentIndex),
      tablet: _buildTabletLayout(currentIndex),
      desktop: _buildDesktopLayout(currentIndex),
    );
  }

  // Mobile Layout (unchanged)
  Widget _buildMobileLayout(int currentIndex) {
    return Scaffold(
      body: widget.child,
      floatingActionButton: FloatingActionButton(
        backgroundColor: AppColors.primary,
        elevation: 8,
        shape: const CircleBorder(),
        child: const Icon(
          Icons.location_on_rounded,
          color: Colors.white,
        ),
        onPressed: () => context.push('/absensi'),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      bottomNavigationBar: AnimatedBottomNavigationBar.builder(
        itemCount: _iconList.length,
        tabBuilder: (int index, bool isActive) {
          return Icon(
            _iconList[index],
            size: 24,
            color: isActive ? AppColors.primary : Colors.grey,
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

  // Tablet Layout with side navigation
  Widget _buildTabletLayout(int currentIndex) {
    return Scaffold(
      body: Row(
        children: [
          _buildSideNavigation(currentIndex, false),
          Expanded(
            child: widget.child,
          ),
        ],
      ),
    );
  }

  // Desktop Layout with extended side navigation
  Widget _buildDesktopLayout(int currentIndex) {
    return Scaffold(
      body: Row(
        children: [
          _buildSideNavigation(currentIndex, true),
          Expanded(
            child: Container(
              decoration: BoxDecoration(
                color: AppColors.background,
                border: Border(
                  left: BorderSide(
                    color: AppColors.divider,
                    width: 1,
                  ),
                ),
              ),
              child: widget.child,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSideNavigation(int currentIndex, bool isExtended) {
    return Container(
      width: isExtended ? 280 : 80,
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(2, 0),
          ),
        ],
      ),
      child: Column(
        children: [
          // Header
          Container(
            height: 100,
            padding: const EdgeInsets.all(20),
            child: Row(
              children: [
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: AppColors.primary,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(
                    Icons.business,
                    color: Colors.white,
                    size: 24,
                  ),
                ),
                if (isExtended) ...[
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          'Absensi App',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: AppColors.textPrimary,
                          ),
                        ),
                        Text(
                          'Management System',
                          style: TextStyle(
                            fontSize: 12,
                            color: AppColors.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ],
            ),
          ),
          const Divider(height: 1),
          
          // Navigation Items
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.symmetric(vertical: 20),
              itemCount: _iconList.length,
              itemBuilder: (context, index) {
                final bool isActive = index == currentIndex;
                
                return Container(
                  margin: EdgeInsets.symmetric(
                    horizontal: isExtended ? 12 : 8,
                    vertical: 4,
                  ),
                  child: Material(
                    color: Colors.transparent,
                    child: InkWell(
                      onTap: () => context.go(_routePaths[index]),
                      borderRadius: BorderRadius.circular(12),
                      child: Container(
                        height: 56,
                        padding: EdgeInsets.symmetric(
                          horizontal: isExtended ? 16 : 18,
                        ),
                        decoration: BoxDecoration(
                          color: isActive ? AppColors.primary.withOpacity(0.1) : null,
                          borderRadius: BorderRadius.circular(12),
                          border: isActive ? Border.all(
                            color: AppColors.primary.withOpacity(0.3),
                          ) : null,
                        ),
                        child: Row(
                          children: [
                            Icon(
                              _iconList[index],
                              size: 24,
                              color: isActive ? AppColors.primary : AppColors.textSecondary,
                            ),
                            if (isExtended) ...[
                              const SizedBox(width: 16),
                              Expanded(
                                child: Text(
                                  _labelList[index],
                                  style: TextStyle(
                                    fontSize: 14,
                                    fontWeight: isActive ? FontWeight.w600 : FontWeight.normal,
                                    color: isActive ? AppColors.primary : AppColors.textPrimary,
                                  ),
                                ),
                              ),
                            ],
                          ],
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
          
          // Absensi Button
          Container(
            margin: EdgeInsets.all(isExtended ? 16 : 6),
            child: SizedBox(
              width: double.infinity,
              height: 48,
              child: ElevatedButton(
                onPressed: () => context.push('/absensi'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  elevation: 0,
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.location_on_rounded, size: 20),
                    if (isExtended) ...[
                      const SizedBox(width: 8),
                      const Text('Absensi'),
                    ],
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}