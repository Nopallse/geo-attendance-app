import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:location/location.dart';
import 'package:intl/intl.dart';
import 'dart:math' as math;
import 'package:provider/provider.dart';
import 'package:logger/logger.dart';
import 'package:safe_device/safe_device.dart';
import 'package:awesome_snackbar_content/awesome_snackbar_content.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import '../../providers/attendance_provider.dart';
import '../../providers/office_provider.dart';
import 'package:go_router/go_router.dart';
import '../../data/models/attendance_model.dart';
import '../../styles/colors.dart';
import '../../styles/typography.dart';

class AbsensiPage extends StatefulWidget {
  const AbsensiPage({super.key});

  @override
  _AbsensiPageState createState() => _AbsensiPageState();
}

class _AbsensiPageState extends State<AbsensiPage> {
  GoogleMapController? _mapController;
  Location _location = Location();
  LatLng _currentPosition = const LatLng(-6.200000, 106.816666);
  Set<Marker> _markers = {};
  Set<Circle> _circles = {};
  bool _markersInitialized = false;
  bool _isWithinRadius = false;
  bool _isMockLocationDetected = false;
  bool _isEmulatorDetected = false;
  final logger = Logger();

  // Responsive breakpoints
  static const double mobileBreakpoint = 768;
  static const double tabletBreakpoint = 1024;

  @override
  void initState() {
    super.initState();
    _initializeLocationAndMarkers();
    _checkDeviceSafety();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _loadInitialData();
  }

  bool get _isMobile => MediaQuery.of(context).size.width < mobileBreakpoint;
  bool get _isTablet => MediaQuery.of(context).size.width >= mobileBreakpoint && 
                       MediaQuery.of(context).size.width < tabletBreakpoint;
  bool get _isDesktop => MediaQuery.of(context).size.width >= tabletBreakpoint;

  Future<void> _checkDeviceSafety() async {
    try {
      bool isMockLocation = await SafeDevice.isMockLocation;
      bool isRealDevice = await SafeDevice.isRealDevice;

      setState(() {
        _isMockLocationDetected = isMockLocation;
        _isEmulatorDetected = !isRealDevice;
      });
    } catch (e) {
      logger.e("Error checking device safety: $e");
    }
  }

  void _showAwesomeSnackBar({
    required String title,
    required String message,
    required ContentType contentType,
  }) {
    final snackBar = SnackBar(
      elevation: 0,
      behavior: SnackBarBehavior.floating,
      backgroundColor: Colors.transparent,
      duration: const Duration(seconds: 4),
      margin: EdgeInsets.only(
        top: kToolbarHeight + 20, 
        left: _isMobile ? 20 : 40, 
        right: _isMobile ? 20 : 40, 
        bottom: 0
      ),
      content: AwesomeSnackbarContent(
        title: title,
        message: message,
        contentType: contentType,
      ),
    );

    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(snackBar);
  }

  Future<void> _loadInitialData() async {
    final officeProvider = Provider.of<OfficeProvider>(context, listen: false);
    final attendanceProvider = Provider.of<AttendanceProvider>(context, listen: false);

    if (officeProvider.offices.isEmpty) {
      await officeProvider.getOffices();
    }

    await attendanceProvider.getTodayAttendance();
    _checkIfWithinRadius();
  }

  Future<void> _initializeLocationAndMarkers() async {
    try {
      if (kIsWeb) {
        // For web platform, we'll use a default position initially
        setState(() {
          _currentPosition = const LatLng(-6.200000, 106.816666);
          _markersInitialized = true;
        });
      }
      await _getCurrentLocation();
      setState(() {
        _markersInitialized = true;
      });
    } catch (e) {
      logger.e("Error during initialization: $e");
    }
  }

  Future<void> _updateMarkersAndCircles() async {
    try {
      final officeProvider = Provider.of<OfficeProvider>(context, listen: false);
      Set<Marker> newMarkers = {};
      Set<Circle> newCircles = {};

      final BitmapDescriptor myLocationIcon = await BitmapDescriptor.fromAssetImage(
        const ImageConfiguration(devicePixelRatio: 2.5),
        'assets/images/my_location_marker.png',
      ).catchError((error) {
        logger.e("Error loading my_location_marker: $error");
        return BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueBlue);
      });

      final BitmapDescriptor officeIcon = await BitmapDescriptor.fromAssetImage(
        const ImageConfiguration(devicePixelRatio: 2),
        'assets/images/office_marker.png',
      ).catchError((error) {
        logger.e("Error loading office_marker: $error");
        return BitmapDescriptor.defaultMarker;
      });

      newMarkers.add(
        Marker(
          markerId: const MarkerId('current_location'),
          position: _currentPosition,
          icon: myLocationIcon,
          infoWindow: const InfoWindow(title: 'Lokasi Anda'),
        ),
      );

      for (var office in officeProvider.offices) {
        newMarkers.add(
          Marker(
            markerId: MarkerId('office_${office.id}'),
            position: office.position,
            infoWindow: InfoWindow(title: office.name),
            icon: officeIcon,
          ),
        );

        newCircles.add(
          Circle(
            circleId: CircleId('radius_${office.id}'),
            center: office.position,
            radius: office.radius,
            fillColor: Colors.blue.withOpacity(0.1),
            strokeColor: Colors.blue[300]!,
            strokeWidth: 2,
          ),
        );
      }

      if (mounted) {
        setState(() {
          _markers = newMarkers;
          _circles = newCircles;
          _checkIfWithinRadius();
        });
      }
    } catch (e) {
      logger.e("Error in _updateMarkersAndCircles: $e");
    }
  }

  bool _isWithinAnyOfficeRadius(LatLng position) {
    final officeProvider = Provider.of<OfficeProvider>(context, listen: false);
    for (var office in officeProvider.offices) {
      double distance = _calculateDistance(position, office.position);
      if (distance <= office.radius) {
        return true;
      }
    }
    return false;
  }

  void _checkIfWithinRadius() {
    setState(() {
      _isWithinRadius = _isWithinAnyOfficeRadius(_currentPosition);
    });
  }

  double _calculateDistance(LatLng point1, LatLng point2) {
    const double earthRadius = 6371000;
    double lat1 = point1.latitude * math.pi / 180;
    double lat2 = point2.latitude * math.pi / 180;
    double lon1 = point1.longitude * math.pi / 180;
    double lon2 = point2.longitude * math.pi / 180;

    double dLat = lat2 - lat1;
    double dLon = lon2 - lon1;

    double a = math.sin(dLat / 2) * math.sin(dLat / 2) +
        math.cos(lat1) * math.cos(lat2) * math.sin(dLon / 2) * math.sin(dLon / 2);
    double c = 2 * math.atan2(math.sqrt(a), math.sqrt(1 - a));
    return earthRadius * c;
  }

  Future<void> _getCurrentLocation() async {
    if (kIsWeb) {
      // For web platform, we'll use browser's geolocation
      try {
        var locationData = await _location.getLocation();
        if (locationData.latitude == null || locationData.longitude == null) return;

        LatLng newPosition = LatLng(locationData.latitude!, locationData.longitude!);

        setState(() {
          _currentPosition = newPosition;
        });

        _updateMarkersAndCircles();
        await _checkDeviceSafety();

        if (_mapController != null) {
          _mapController!.animateCamera(
              CameraUpdate.newLatLngZoom(_currentPosition, 18));
        }
      } catch (e) {
        logger.e("Error getting location on web: $e");
      }
      return;
    }

    // Original mobile platform code
    bool serviceEnabled;
    PermissionStatus permissionGranted;

    serviceEnabled = await _location.serviceEnabled();
    if (!serviceEnabled) {
      serviceEnabled = await _location.requestService();
      if (!serviceEnabled) return;
    }

    permissionGranted = await _location.hasPermission();
    if (permissionGranted == PermissionStatus.denied) {
      permissionGranted = await _location.requestPermission();
      if (permissionGranted != PermissionStatus.granted) return;
    }

    var locationData = await _location.getLocation();
    if (locationData.latitude == null || locationData.longitude == null) return;

    LatLng newPosition = LatLng(locationData.latitude!, locationData.longitude!);

    setState(() {
      _currentPosition = newPosition;
    });

    _updateMarkersAndCircles();
    await _checkDeviceSafety();

    if (_mapController != null) {
      _mapController!.animateCamera(
          CameraUpdate.newLatLngZoom(_currentPosition, 18));
    }
  }

  Future<void> _recordAttendance(bool isCheckIn) async {
    logger.d('Absen ${isCheckIn ? "masuk" : "keluar"}');

    await _checkDeviceSafety();

    if (!_isWithinRadius) {
      _showAwesomeSnackBar(
        title: 'Di Luar Radius',
        message: 'Anda harus berada dalam radius kantor untuk melakukan absensi',
        contentType: ContentType.warning,
      );
      return;
    }

    final attendanceProvider = Provider.of<AttendanceProvider>(context, listen: false);

    try {
      int? _getNearbyOfficeId() {
        final officeProvider = Provider.of<OfficeProvider>(context, listen: false);
        for (var office in officeProvider.offices) {
          double distance = _calculateDistance(_currentPosition, office.position);
          if (distance <= office.radius) {
            return office.id;
          }
        }
        return null;
      }

      final lokasiId = _getNearbyOfficeId();
      if (lokasiId == null) {
        _showAwesomeSnackBar(
          title: 'Tidak Ada Kantor Terdekat',
          message: 'Tidak ditemukan kantor dalam radius yang ditentukan',
          contentType: ContentType.warning,
        );
        return;
      }

      final success = await attendanceProvider.createAttendance(
        isCheckIn,
        _currentPosition,
        lokasiId,
      );

      if (success) {
        _showAwesomeSnackBar(
          title: 'Berhasil',
          message: 'Berhasil melakukan absen ${isCheckIn ? "masuk" : "keluar"}',
          contentType: ContentType.success,
        );
      } else {
        _showAwesomeSnackBar(
          title: 'Gagal',
          message: attendanceProvider.errorMessage ?? 'Terjadi kesalahan',
          contentType: ContentType.failure,
        );
      }
    } catch (e) {
      logger.e("Error saat absen: $e");
      _showAwesomeSnackBar(
        title: 'Error',
        message: 'Terjadi kesalahan: $e',
        contentType: ContentType.failure,
      );
    }
  }

  String? _formatDateTime(DateTime? dateTime) {
    if (dateTime == null) return null;
    return DateFormat('HH:mm:ss, dd MMM yyyy').format(dateTime);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: _buildAppBar(),
      body: Consumer2<AttendanceProvider, OfficeProvider>(
        builder: (context, attendanceProvider, officeProvider, child) {
          final isLoading = attendanceProvider.isLoading || officeProvider.isLoading;
          final todayAttendance = attendanceProvider.todayAttendance;

          return Stack(
            children: [
              _buildResponsiveBody(officeProvider, todayAttendance),
              if (isLoading) _buildLoadingOverlay(),
            ],
          );
        },
      ),
    );
  }

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      title: Text(
        'Absensi',
        style: AppTypography.headline6.copyWith(
          color: AppColors.textPrimary,
        ),
      ),
      centerTitle: true,
      backgroundColor: AppColors.white,
      elevation: 0,
      leading: IconButton(
        icon: const Icon(Icons.arrow_back_ios_new, color: AppColors.primary),
        onPressed: () => context.pop(),
      ),
      actions: [
        IconButton(
          icon: const Icon(Icons.refresh, color: AppColors.primary),
          onPressed: () {
            _getCurrentLocation();
            Provider.of<AttendanceProvider>(context, listen: false).getTodayAttendance();
            Provider.of<OfficeProvider>(context, listen: false).getOffices();
          },
        ),
      ],
    );
  }

  Widget _buildLoadingOverlay() {
    return Container(
      color: Colors.black.withOpacity(0.5),
      child: const Center(
        child: CircularProgressIndicator(
          color: AppColors.primary,
        ),
      ),
    );
  }

  Widget _buildResponsiveBody(OfficeProvider officeProvider, Attendance? todayAttendance) {
    if (_isMobile) {
      return _buildMobileLayout(officeProvider, todayAttendance);
    } else {
      return _buildDesktopLayout(officeProvider, todayAttendance);
    }
  }

  Widget _buildMobileLayout(OfficeProvider officeProvider, Attendance? todayAttendance) {
    return Column(
      children: [
        _buildMapSection(officeProvider),
        _buildBottomSection(todayAttendance),
      ],
    );
  }

  Widget _buildDesktopLayout(OfficeProvider officeProvider, Attendance? todayAttendance) {
    return Padding(
      padding: EdgeInsets.all(_isDesktop ? 32 : 16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Map Section - Left side
          Expanded(
            flex: 2,
            child: _buildDesktopMapSection(officeProvider),
          ),
          SizedBox(width: _isDesktop ? 32 : 16),
          // Control Panel - Right side
          Expanded(
            flex: 1,
            child: _buildDesktopControlPanel(todayAttendance),
          ),
        ],
      ),
    );
  }

  Widget _buildDesktopMapSection(OfficeProvider officeProvider) {
    return Container(
      height: MediaQuery.of(context).size.height - 120,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            spreadRadius: 2,
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(24),
        child: Stack(
          children: [
            if (_markersInitialized)
              GoogleMap(
                initialCameraPosition: CameraPosition(
                  target: _currentPosition,
                  zoom: 18,
                ),
                onMapCreated: (GoogleMapController controller) {
                  _mapController = controller;
                  _updateMarkersAndCircles();
                },
                markers: _markers,
                circles: _circles,
                myLocationEnabled: false,
                myLocationButtonEnabled: true,
                zoomControlsEnabled: true,
                mapToolbarEnabled: false,
              ),
            if (!_markersInitialized)
              const Center(child: CircularProgressIndicator()),
            _buildLocationStatus(),
          ],
        ),
      ),
    );
  }

  Widget _buildDesktopControlPanel(Attendance? todayAttendance) {
    return Container(
      height: MediaQuery.of(context).size.height - 120,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Title Card
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: AppColors.white,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  spreadRadius: 1,
                  blurRadius: 4,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: AppColors.primary.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Icon(
                        Icons.access_time,
                        color: AppColors.primary,
                        size: 24,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Absensi Hari Ini',
                            style: AppTypography.headline6.copyWith(
                              color: AppColors.textPrimary,
                            ),
                          ),
                          Text(
                            DateFormat('EEEE, dd MMMM yyyy', 'id_ID').format(DateTime.now()),
                            style: AppTypography.subtitle2.copyWith(
                              color: AppColors.textSecondary,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
          
          // Attendance Status
          Expanded(
            child: Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: AppColors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    spreadRadius: 1,
                    blurRadius: 4,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Status Absensi',
                    style: AppTypography.subtitle1.copyWith(
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 20),
                  Expanded(
                    child: _buildDesktopAttendanceStatus(
                      todayAttendance?.absenCheckIn,
                      todayAttendance?.absenCheckOut,
                    ),
                  ),
                  const SizedBox(height: 20),
                  _buildDesktopAttendanceButtons(
                    todayAttendance?.absenCheckIn,
                    todayAttendance?.absenCheckOut,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMapSection(OfficeProvider officeProvider) {
    return Expanded(
      flex: 2,
      child: Container(
        margin: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(24),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              spreadRadius: 2,
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(24),
          child: Stack(
            children: [
              if (_markersInitialized)
                GoogleMap(
                  initialCameraPosition: CameraPosition(
                    target: _currentPosition,
                    zoom: 18,
                  ),
                  onMapCreated: (GoogleMapController controller) {
                    _mapController = controller;
                    _updateMarkersAndCircles();
                  },
                  markers: _markers,
                  circles: _circles,
                  myLocationEnabled: false,
                  myLocationButtonEnabled: true,
                  zoomControlsEnabled: false,
                  mapToolbarEnabled: false,
                ),
              if (!_markersInitialized)
                const Center(child: CircularProgressIndicator()),
              _buildLocationStatus(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLocationStatus() {
    return Positioned(
      top: 16,
      left: 16,
      right: 16,
      child: Column(
        children: [
          if (_isMockLocationDetected || _isEmulatorDetected)
            Container(
              margin: const EdgeInsets.only(bottom: 8),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                color: AppColors.error,
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Row(
                children: [
                  const Icon(Icons.location_off, color: AppColors.white, size: 20),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      _isMockLocationDetected
                          ? 'Fake GPS terdeteksi! Absensi tidak diizinkan'
                          : 'Aplikasi berjalan di emulator! Absensi tidak diizinkan',
                      style: AppTypography.subtitle2.copyWith(
                        color: AppColors.white,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: _isWithinRadius ? AppColors.success : AppColors.warning,
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Row(
              children: [
                Icon(
                  _isWithinRadius ? Icons.check_circle : Icons.warning,
                  color: AppColors.white,
                  size: 20,
                ),
                const SizedBox(width: 8),
                Text(
                  _isWithinRadius ? 'Dalam radius kantor' : 'Di luar radius kantor',
                  style: AppTypography.subtitle2.copyWith(
                    color: AppColors.white,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBottomSection(Attendance? todayAttendance) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(32)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 4,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      padding: const EdgeInsets.all(24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          _buildAttendanceStatus(
            todayAttendance?.absenCheckIn,
            todayAttendance?.absenCheckOut,
          ),
          const SizedBox(height: 24),
          _buildAttendanceButtons(
            todayAttendance?.absenCheckIn,
            todayAttendance?.absenCheckOut,
          ),
        ],
      ),
    );
  }

  Widget _buildDesktopAttendanceStatus(String? checkInTime, String? checkOutTime) {
    return Column(
      children: [
        _buildAttendanceCard(
          'Absen Masuk',
          checkInTime,
          Icons.login,
          AppColors.success,
          true,
        ),
        const SizedBox(height: 16),
        _buildAttendanceCard(
          'Absen Keluar',
          checkOutTime,
          Icons.logout,
          AppColors.error,
          checkInTime != null,
        ),
      ],
    );
  }

  Widget _buildAttendanceCard(
    String label,
    String? value,
    IconData icon,
    Color color,
    bool isEnabled,
  ) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isEnabled ? color.withOpacity(0.05) : AppColors.background,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isEnabled ? color.withOpacity(0.2) : AppColors.divider,
        ),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: isEnabled ? color.withOpacity(0.1) : AppColors.background,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              icon,
              color: isEnabled ? color : AppColors.textHint,
              size: 20,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: AppTypography.subtitle2.copyWith(
                    color: isEnabled ? AppColors.textSecondary : AppColors.textHint,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  value ?? "Belum absen",
                  style: AppTypography.bodyText1.copyWith(
                    fontWeight: FontWeight.w600,
                    color: value != null ? AppColors.textPrimary : AppColors.textHint,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAttendanceStatus(String? checkInTime, String? checkOutTime) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.primary.withOpacity(0.05),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: [
          _buildAttendanceRow('Absen Masuk', checkInTime, Icons.login, AppColors.success),
          if (checkInTime != null) ...[
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 8),
              child: Divider(color: AppColors.divider),
            ),
            _buildAttendanceRow('Absen Keluar', checkOutTime, Icons.logout, AppColors.error),
          ],
        ],
      ),
    );
  }

  Widget _buildAttendanceRow(String label, String? value, IconData icon, Color color) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, color: color, size: 20),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: AppTypography.subtitle2.copyWith(
                  color: AppColors.textSecondary,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                value ?? "Belum absen",
                style: AppTypography.bodyText1.copyWith(
                  fontWeight: FontWeight.w600,
                  color: value != null ? AppColors.textPrimary : AppColors.textHint,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildAttendanceButtons(String? checkInTime, String? checkOutTime) {
    final bool disableButtons = _isMockLocationDetected;

    return Row(
      children: [
        Expanded(
          child: ElevatedButton.icon(
            onPressed: (checkInTime == null && !disableButtons)
                ? () => _recordAttendance(true)
                : null,
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.success,
              foregroundColor: AppColors.white,
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              elevation: 0,
              disabledBackgroundColor: AppColors.disabledButton,
            ),
            icon: const Icon(Icons.login),
            label: Text(
              'Absen Masuk',
              style: AppTypography.buttonText,
            ),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: ElevatedButton.icon(
            onPressed: (checkInTime != null && checkOutTime == null && !disableButtons)
                ? () => _recordAttendance(false)
                : null,
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.error,
              foregroundColor: AppColors.white,
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              elevation: 0,
              disabledBackgroundColor: AppColors.disabledButton,
            ),
            icon: const Icon(Icons.logout),
            label: Text(
              'Absen Keluar',
              style: AppTypography.buttonText,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildDesktopAttendanceButtons(String? checkInTime, String? checkOutTime) {
    final bool disableButtons = _isMockLocationDetected;

    return Column(
      children: [
        SizedBox(
          width: double.infinity,
          child: ElevatedButton.icon(
            onPressed: (checkInTime == null && !disableButtons)
                ? () => _recordAttendance(true)
                : null,
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.success,
              foregroundColor: AppColors.white,
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              elevation: 0,
              disabledBackgroundColor: AppColors.disabledButton,
            ),
            icon: const Icon(Icons.login),
            label: Text(
              'Absen Masuk',
              style: AppTypography.buttonText,
            ),
          ),
        ),
        const SizedBox(height: 12),
        SizedBox(
          width: double.infinity,
          child: ElevatedButton.icon(
            onPressed: (checkInTime != null && checkOutTime == null && !disableButtons)
                ? () => _recordAttendance(false)
                : null,
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.error,
              foregroundColor: AppColors.white,
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              elevation: 0,
              disabledBackgroundColor: AppColors.disabledButton,
            ),
            icon: const Icon(Icons.logout),
            label: Text(
              'Absen Keluar',
              style: AppTypography.buttonText,
            ),
          ),
        ),
      ],
    );
  }
}