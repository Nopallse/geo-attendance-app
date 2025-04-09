import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:location/location.dart';
import 'package:intl/intl.dart';
import 'dart:math' as math;
import 'package:provider/provider.dart';
import 'package:logger/logger.dart';
import 'package:safe_device/safe_device.dart';
import '../../providers/attendance_provider.dart';
import '../../providers/office_provider.dart';
import '../../data/models/office_model.dart';
import '../../data/models/attendance_model.dart';

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
  final logger = Logger();

  @override
  void initState() {
    super.initState();
    _initializeLocationAndMarkers();
    _checkMockLocation();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Load data from providers
    _loadInitialData();
  }

  Future<void> _checkMockLocation() async {
    try {
      bool isMockLocation = await SafeDevice.isMockLocation;
      setState(() {
        _isMockLocationDetected = isMockLocation;
      });
      logger.d("Mock location detected: $_isMockLocationDetected");

      if (_isMockLocationDetected) {
        // Show warning if mock location is detected
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Fake GPS terdeteksi! Anda tidak dapat melakukan absensi'),
              backgroundColor: Colors.red,
              duration: Duration(seconds: 5),
            ),
          );
        }
      }
    } catch (e) {
      logger.e("Error checking mock location: $e");
    }
  }

  Future<void> _loadInitialData() async {
    final officeProvider = Provider.of<OfficeProvider>(context, listen: false);
    final attendanceProvider = Provider.of<AttendanceProvider>(context, listen: false);

    // Load offices if not already loaded
    if (officeProvider.offices.isEmpty) {
      await officeProvider.getOffices();
    }

    // Get today's attendance
    await attendanceProvider.getTodayAttendance();

    // Check if within radius after loading data
    _checkIfWithinRadius();
  }

  Future<void> _initializeLocationAndMarkers() async {
    try {
      await _getCurrentLocation(); // Get location first
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

      // Pre-load marker icons to avoid race conditions
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

      // Add current location marker
      newMarkers.add(
        Marker(
          markerId: const MarkerId('current_location'),
          position: _currentPosition,
          icon: myLocationIcon,
          infoWindow: const InfoWindow(title: 'Lokasi Anda'),
        ),
      );

      // Add office markers
      for (var office in officeProvider.offices) {
        newMarkers.add(
          Marker(
            markerId: MarkerId('office_${office.id}'),
            position: office.position,
            infoWindow: InfoWindow(title: office.name),
            icon: officeIcon,
          ),
        );

        // Add circle for each office's radius
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

      // Only update state if the widget is still mounted
      if (mounted) {
        setState(() {
          _markers = newMarkers;
          _circles = newCircles;
          _checkIfWithinRadius(); // Check if within radius after updating markers
        });
      }
    } catch (e) {
      logger.e("Error in _updateMarkersAndCircles: $e");
    }
  }

  bool _isWithinAnyOfficeRadius(LatLng position) {
    final officeProvider = Provider.of<OfficeProvider>(context, listen: false);
    for (var office in officeProvider.offices) {
      double distance = _calculateDistance(
        position,
        office.position,
      );

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
        math.cos(lat1) * math.cos(lat2) *
            math.sin(dLon / 2) * math.sin(dLon / 2);
    double c = 2 * math.atan2(math.sqrt(a), math.sqrt(1 - a));
    return earthRadius * c;
  }

  Future<void> _getCurrentLocation() async {
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

    // Re-check for mock location when getting current location
    await _checkMockLocation();

    if (_mapController != null) {
      _mapController!.animateCamera(
          CameraUpdate.newLatLngZoom(_currentPosition, 18)
      );
    }
  }

  Future<void> _recordAttendance(bool isCheckIn) async {
    logger.d('Absen ${isCheckIn ? "masuk" : "keluar"}');

    // Check for mock location before proceeding
    await _checkMockLocation();

    if (_isMockLocationDetected) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Fake GPS terdeteksi! Anda tidak dapat melakukan absensi'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    if (!_isWithinRadius) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Anda harus berada dalam radius kantor untuk melakukan absensi'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    final attendanceProvider = Provider.of<AttendanceProvider>(context, listen: false);

    try {
      final success = await attendanceProvider.createAttendance(
        isCheckIn,
        _currentPosition,
      );

      if (success) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Berhasil melakukan absen ${isCheckIn ? "masuk" : "keluar"}'),
            backgroundColor: Colors.green,
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(attendanceProvider.errorMessage ?? 'Terjadi kesalahan'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      logger.e("Error saat absen: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Terjadi kesalahan: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  String? _formatDateTime(DateTime? dateTime) {
    if (dateTime == null) return null;
    return DateFormat('HH:mm:ss, dd MMM yyyy').format(dateTime);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      backgroundColor: Colors.blue[50],
      appBar: AppBar(
        title: const Text(
          'Absensi',
          style: TextStyle(fontWeight: FontWeight.w600),
        ),
        centerTitle: true,
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              _getCurrentLocation();
              Provider.of<AttendanceProvider>(context, listen: false).getTodayAttendance();
              Provider.of<OfficeProvider>(context, listen: false).getOffices();
            },
          ),
        ],
      ),
      body: Consumer2<AttendanceProvider, OfficeProvider>(
        builder: (context, attendanceProvider, officeProvider, child) {
          final isLoading = attendanceProvider.isLoading || officeProvider.isLoading;
          final todayAttendance = attendanceProvider.todayAttendance;

          return Stack(
            children: [
              Column(
                children: [
                  _buildMapSection(officeProvider),
                  _buildBottomSection(theme, todayAttendance),
                ],
              ),
              if (isLoading)
                Container(
                  color: Colors.black.withOpacity(0.5),
                  child: const Center(
                    child: CircularProgressIndicator(
                      color: Colors.white,
                    ),
                  ),
            ),
            ],
          );
        },
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
              color: Colors.grey.withOpacity(0.1),
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
              if (_markersInitialized) // Only show map when markers are ready
                GoogleMap(
                  initialCameraPosition: CameraPosition(
                    target: _currentPosition,
                    zoom: 18,
                  ),
                  onMapCreated: (GoogleMapController controller) {
                    _mapController = controller;
                    // Update markers once map is created
                    _updateMarkersAndCircles();
                  },
                  markers: _markers,
                  circles: _circles,
                  myLocationEnabled: false,
                  myLocationButtonEnabled: true,
                  zoomControlsEnabled: false,
                  mapToolbarEnabled: false,
                ),
              if (!_markersInitialized) // Show loading indicator while initializing
                const Center(
                  child: CircularProgressIndicator(),
                ),
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
          if (_isMockLocationDetected)
            Container(
              margin: const EdgeInsets.only(bottom: 8),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                color: Colors.red[600],
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: const Row(
                children: [
                  Icon(
                    Icons.location_off,
                    color: Colors.white,
                    size: 20,
                  ),
                  SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Fake GPS terdeteksi! Absensi tidak diizinkan',
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: _isWithinRadius ? Colors.green[400] : Colors.orange[400],
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
                  color: Colors.white,
                  size: 20,
                ),
                const SizedBox(width: 8),
                Text(
                  _isWithinRadius
                      ? 'Dalam radius kantor'
                      : 'Di luar radius kantor',
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBottomSection(ThemeData theme, Attendance? todayAttendance) {
    final checkInTime = todayAttendance?.checkInTime;
    final checkOutTime = todayAttendance?.checkOutTime;

    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
      ),
      padding: const EdgeInsets.all(24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          _buildAttendanceStatus(checkInTime, checkOutTime),
          const SizedBox(height: 24),
          _buildAttendanceButtons(checkInTime, checkOutTime),
        ],
      ),
    );
  }

  Widget _buildAttendanceStatus(DateTime? checkInTime, DateTime? checkOutTime) {
    final formattedCheckInTime = _formatDateTime(checkInTime);
    final formattedCheckOutTime = _formatDateTime(checkOutTime);

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.blue[50],
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: [
          _buildAttendanceRow(
            'Absen Masuk',
            formattedCheckInTime,
            Icons.login,
            Colors.green,
          ),
          if (formattedCheckInTime != null) ...[
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 8),
              child: Divider(),
            ),
            _buildAttendanceRow(
              'Absen Keluar',
              formattedCheckOutTime,
              Icons.logout,
              Colors.red,
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildAttendanceRow(
      String label,
      String? value,
      IconData icon,
      Color color,
      ) {
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
                style: const TextStyle(
                  fontSize: 14,
                  color: Colors.grey,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                value ?? "Belum absen",
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: value != null ? Colors.black87 : Colors.grey,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildAttendanceButtons(DateTime? checkInTime, DateTime? checkOutTime) {
    // Disable buttons if mock location is detected
    final bool disableButtons = _isMockLocationDetected;

    return Row(
      children: [
        Expanded(
          child: ElevatedButton.icon(
            onPressed: (checkInTime == null && !disableButtons)
                ? () => _recordAttendance(true)
                : null,
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.green[400],
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              elevation: 0,
            ),
            icon: const Icon(Icons.login),
            label: const Text(
              'Absen Masuk',
              style: TextStyle(fontWeight: FontWeight.w600),
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
              backgroundColor: Colors.red[400],
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              elevation: 0,
            ),
            icon: const Icon(Icons.logout),
            label: const Text(
              'Absen Keluar',
              style: TextStyle(fontWeight: FontWeight.w600),
            ),
          ),
        ),
      ],
    );
  }
}