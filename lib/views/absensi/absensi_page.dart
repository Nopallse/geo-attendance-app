  import 'package:flutter/material.dart';
  import 'package:google_maps_flutter/google_maps_flutter.dart';
  import 'package:location/location.dart';
  import 'package:intl/intl.dart';
  import 'dart:math' as math;
  import 'package:absensi_app/services/absen_service.dart';
  import 'package:logger/logger.dart';

  class AbsensiPage extends StatefulWidget {
    const AbsensiPage({super.key});

    @override
    _AbsensiPageState createState() => _AbsensiPageState();
  }

  class _AbsensiPageState extends State<AbsensiPage> {
    final AbsenService _absenService = AbsenService();
    GoogleMapController? _mapController;
    Location _location = Location();
    LatLng _currentPosition = const LatLng(-6.200000, 106.816666);
    String? _absenMasuk;
    String? _absenKeluar;
    Set<Marker> _markers = {};
    bool _isLoading = false;

    // Lokasi kantor (statis)
    final LatLng _officeLocation = const LatLng(-0.943739, 100.396090);
    final double _allowedRadius = 50; // dalam meter
    bool _isWithinRadius = false;
    final logger = Logger();

    @override
    void initState() {
      super.initState();
      _getCurrentLocation();
      _loadTodayAbsen();
      _initMarkers();
      _markers.add(
        Marker(
          markerId: const MarkerId('office'),
          position: _officeLocation,
          infoWindow: const InfoWindow(title: "Lokasi Kantor"),
          icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueBlue),
        ),
      );
    }

    Future<void> _loadTodayAbsen() async {
      final result = await _absenService.getAbsenToday();
      bool isSuccess = result['success'] ?? false; // Hindari error null

      if (isSuccess) {
        logger.d('Successss: $result >>>>>>>');

        final todayAbsen = result['data'];
        logger.d("Today Absen: $todayAbsen");

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

    Future<void> _initMarkers() async {
      BitmapDescriptor officeIcon = await BitmapDescriptor.fromAssetImage(
        const ImageConfiguration(size: Size(48, 48)), // Ukuran gambar marker
        'assets/images/office_marker.png',
      );

      setState(() {
        _markers.add(
          Marker(
            markerId: const MarkerId('office'),
            position: _officeLocation,
            infoWindow: const InfoWindow(title: "Lokasi Kantor"),
            icon: officeIcon, // Pakai ikon kustom
          ),
        );
      });
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

      double distance = _calculateDistance(newPosition, _officeLocation);
      bool isWithinRadius = distance <= _allowedRadius;

      setState(() {
        _currentPosition = newPosition;
        _isWithinRadius = isWithinRadius;
      });

      // Otomatis arahkan ke lokasi terbaru
      _mapController?.animateCamera(CameraUpdate.newLatLngZoom(newPosition, 18));
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
                GoogleMap(
                  initialCameraPosition: CameraPosition(
                    target: _currentPosition,
                    zoom: 18,
                  ),
                  onMapCreated: (GoogleMapController controller) {
                    _mapController = controller;
                    _getCurrentLocation();
                  },
                  markers: _markers,
                  circles: {
                    Circle(
                      circleId: const CircleId('officeRadius'),
                      center: _officeLocation,
                      radius: _allowedRadius,
                      fillColor: Colors.blue.withOpacity(0.1),
                      strokeColor: Colors.blue[300]!,
                      strokeWidth: 2,
                    ),
                  },
                  myLocationEnabled: true,
                  myLocationButtonEnabled: false,
                  zoomControlsEnabled: false,
                  mapToolbarEnabled: false,
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