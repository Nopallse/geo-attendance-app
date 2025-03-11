  import 'package:flutter/material.dart';
  import 'package:google_maps_flutter/google_maps_flutter.dart';
  import 'package:location/location.dart';
  import 'package:intl/intl.dart';
  import 'dart:math' as math;
  import 'package:absensi_app/services/absen_service.dart';
  import 'package:absensi_app/services/kantor_service.dart';
  import 'package:logger/logger.dart';

  class AbsensiPage extends StatefulWidget {
    const AbsensiPage({super.key});

    @override
    _AbsensiPageState createState() => _AbsensiPageState();
  }

  class _AbsensiPageState extends State<AbsensiPage> {
    final AbsenService _absenService = AbsenService();
    final KantorService _kantorService = KantorService();
    GoogleMapController? _mapController;
    Location _location = Location();
    LatLng _currentPosition = const LatLng(-6.200000, 106.816666);
    String? _absenMasuk;
    String? _absenKeluar;
    Set<Marker> _markers = {};
    Set<Circle> _circles = {};
    bool _isLoading = false;
    bool _markersInitialized = false;
    bool _isWithinRadius = false;
    List<Map<String, dynamic>> _officeLocations = [];
    final logger = Logger();

    @override
    void initState() {
      super.initState();
      _getCurrentLocation();
      _loadTodayAbsen();
      _loadOfficeLocations();
      _initializeLocationAndMarkers();
    }

    Future<void> _initializeLocationAndMarkers() async {
      setState(() => _isLoading = true);
      try {
        await _getCurrentLocation(); // Get location first
        await _loadOfficeLocations(); // Then load office locations
        await _loadTodayAbsen(); // Load attendance data
      } catch (e) {
        logger.e("Error during initialization: $e");
      } finally {
        setState(() {
          _isLoading = false;
          _markersInitialized = true;
        });
      }
    }

    Future<void> _loadOfficeLocations() async {
      setState(() => _isLoading = true);
      try {
        final result = await _kantorService.getKantor();
        logger.d('Hasil Load Office Locations: $result');
        if (result['success']) {
          final officeData = result['data']['data'] as List;
          _officeLocations = officeData.map((office) => {
            'id': office['id'],
            'name': office['name'],
            'position': LatLng(
              double.parse(office['latitude'].toString()),
              double.parse(office['longitude'].toString()),
            ),
            'radius': double.parse(office['radius'].toString()),
          }).toList();

          _updateMarkersAndCircles();
          if (_mapController != null) {
            _mapController!.animateCamera(
                CameraUpdate.newLatLngZoom(_currentPosition, 18)
            );
          }
        }
      } catch (e) {
        logger.e("Error loading office locations: $e");
      } finally {
        setState(() => _isLoading = false);
      }
    }

    Future<void> _updateMarkersAndCircles() async {
      try {
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
        if (_currentPosition != null) {
          newMarkers.add(
            Marker(
              markerId: const MarkerId('current_location'),
              position: _currentPosition,
              icon: myLocationIcon,
              infoWindow: const InfoWindow(title: 'Lokasi Anda'),
            ),
          );
        }

        // Add office markers
        for (var office in _officeLocations) {
          newMarkers.add(
            Marker(
              markerId: MarkerId('office_${office['id']}'),
              position: office['position'] as LatLng,
              infoWindow: InfoWindow(title: office['name']),
              icon: officeIcon,
            ),
          );

          // Add circle for each office's radius
          newCircles.add(
            Circle(
              circleId: CircleId('radius_${office['id']}'),
              center: office['position'] as LatLng,
              radius: office['radius'],
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
          });
        }
      } catch (e) {
        logger.e("Error in _updateMarkersAndCircles: $e");
        // Fallback to default markers if custom markers fail
        _updateMarkersWithDefault();
      }
    }

// Fallback method using default markers
    void _updateMarkersWithDefault() {
      if (!mounted) return;

      Set<Marker> newMarkers = {};
      Set<Circle> newCircles = {};

      // Add current location with default blue marker
      newMarkers.add(
        Marker(
          markerId: const MarkerId('current_location'),
          position: _currentPosition,
          icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueBlue),
          infoWindow: const InfoWindow(title: 'Lokasi Anda'),
        ),
      );

      // Add office locations with default red markers
      for (var office in _officeLocations) {
        newMarkers.add(
          Marker(
            markerId: MarkerId('office_${office['id']}'),
            position: office['position'] as LatLng,
            infoWindow: InfoWindow(title: office['name']),
            icon: BitmapDescriptor.defaultMarker,
          ),
        );

        newCircles.add(
          Circle(
            circleId: CircleId('radius_${office['id']}'),
            center: office['position'] as LatLng,
            radius: office['radius'],
            fillColor: Colors.blue.withOpacity(0.1),
            strokeColor: Colors.blue[300]!,
            strokeWidth: 2,
          ),
        );
      }

      setState(() {
        _markers = newMarkers;
        _circles = newCircles;
      });
    }

    Future<void> _loadTodayAbsen() async {
      final result = await _absenService.getAbsenToday();
      bool isSuccess = result['success'] ?? false; // Hindari error null

      if (isSuccess) {
        final todayAbsen = result['data'];
        setState(() {
          _absenMasuk = todayAbsen['jam_masuk'] != null
              ? DateFormat('HH:mm:ss, dd MMM yyyy')
              .format(DateTime.parse(todayAbsen['jam_masuk']))
              : null;
          _absenKeluar = todayAbsen['jam_keluar'] != null
              ? DateFormat('HH:mm:ss, dd MMM yyyy')
              .format(DateTime.parse(todayAbsen['jam_keluar']))
              : null;
        });
      } else {
        setState(() {
          _absenMasuk = null;
          _absenKeluar = null;
        });
      }
    }


    bool _isWithinAnyOfficeRadius(LatLng position) {
      for (var office in _officeLocations) {
        double distance = _calculateDistance(
          position,
          office['position'] as LatLng,
        );
        if (distance <= office['radius']) {
          return true;
        }
      }
      return false;
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
      LatLng newPosition = LatLng(locationData.latitude!, locationData.longitude!);

      setState(() {
        _currentPosition = newPosition;
        _isWithinRadius = _isWithinAnyOfficeRadius(newPosition);
      });
    }


    Future<void> _absen(bool isMasuk) async {
      logger.d('Absen $isMasuk');
      if (!_isWithinRadius) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Anda harus berada dalam radius kantor untuk melakukan absensi'),
            backgroundColor: Colors.red,
          ),
        );
        return;
      }

      setState(() => _isLoading = true);

      try {
        final result = await _absenService.createAbsen(
          isMasuk,
          _currentPosition.latitude,
          _currentPosition.longitude,
        );

        logger.d('Hasil Absen: $result >>>>>>>');
        if (result['success']) {
          await _loadTodayAbsen(); // Reload absen data
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Berhasil melakukan absen ${isMasuk ? "masuk" : "keluar"}'),
              backgroundColor: Colors.green,
            ),
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(result['message'] ?? 'Unknown error'),
              backgroundColor: Colors.red,
            ),
          );
        }
      } catch (e) {
        logger.e("Error saat absen: $e");
      } finally {
        setState(() => _isLoading = false);
      }
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
        ),
        body: Stack(
          children: [
            Column(
              children: [
                _buildMapSection(),
                _buildBottomSection(theme),
              ],
            ),
            if (_isLoading)
              Container(
                color: Colors.black.withOpacity(0.5),
                child: const Center(
                  child: CircularProgressIndicator(
                    color: Colors.white,
                  ),
                ),
              ),
          ],
        ),

      );
    }

    Widget _buildMapSection() {
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
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: BoxDecoration(
            color: _isWithinRadius ? Colors.green[400] : Colors.red[400],
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
      );
    }

    Widget _buildBottomSection(ThemeData theme) {
      return Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
        ),
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildAttendanceStatus(),
            const SizedBox(height: 24),
            _buildAttendanceButtons(theme),
          ],
        ),
      );
    }

    Widget _buildAttendanceStatus() {
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
              _absenMasuk,
              Icons.login,
              Colors.green,
            ),
            if (_absenMasuk != null) ...[
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 8),
                child: Divider(),
              ),
              _buildAttendanceRow(
                'Absen Keluar',
                _absenKeluar,
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

    Widget _buildAttendanceButtons(ThemeData theme) {
      return Row(
        children: [
          Expanded(
            child: ElevatedButton.icon(
              onPressed: _absenMasuk == null ? () => _absen(true) : null,
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
              onPressed: _absenMasuk != null && _absenKeluar == null
                  ? () => _absen(false)
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