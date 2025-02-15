import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:location/location.dart';
import 'package:intl/intl.dart';
import 'dart:math' as math;

class AbsensiPage extends StatefulWidget {
  const AbsensiPage({super.key});

  @override
  _AbsensiPageState createState() => _AbsensiPageState();
}

class _AbsensiPageState extends State<AbsensiPage> {
  GoogleMapController? _mapController;
  Location _location = Location();
  LatLng _currentPosition = const LatLng(-6.200000, 106.816666);
  String? _absenMasuk;
  String? _absenKeluar;
  Set<Marker> _markers = {};

  // Lokasi kantor (statis)
  final LatLng _officeLocation = const LatLng(-0.943739, 100.396090);
  final double _allowedRadius = 50; // dalam meter
  bool _isWithinRadius = false;

  @override
  void initState() {
    super.initState();
    _getCurrentLocation();
    // Tambahkan marker untuk lokasi kantor
    _markers.add(
      Marker(
        markerId: const MarkerId('office'),
        position: _officeLocation,
        infoWindow: const InfoWindow(title: "Lokasi Kantor"),
        icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueBlue),
      ),
    );
  }

  // Fungsi untuk menghitung jarak antara dua koordinat
  double _calculateDistance(LatLng point1, LatLng point2) {
    const double earthRadius = 6371000; // meter
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

    // Hitung jarak ke kantor
    double distance = _calculateDistance(newPosition, _officeLocation);
    bool isWithinRadius = distance <= _allowedRadius;

    setState(() {
      _currentPosition = newPosition;
      _isWithinRadius = isWithinRadius;
      _markers = {
        ..._markers,
        Marker(
          markerId: const MarkerId('currentLocation'),
          position: newPosition,
          infoWindow: const InfoWindow(title: "Lokasi Anda"),
          icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueRed),
        ),
      };
    });

    _mapController?.animateCamera(CameraUpdate.newLatLngZoom(newPosition, 18));
  }

  void _absen(bool isMasuk) {
    if (!_isWithinRadius) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Anda harus berada dalam radius kantor untuk melakukan absensi'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    String waktu = DateFormat('HH:mm:ss, dd MMM yyyy').format(DateTime.now());
    setState(() {
      if (isMasuk) {
        _absenMasuk = waktu;
      } else {
        _absenKeluar = waktu;
      }
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Berhasil melakukan absen ${isMasuk ? "masuk" : "keluar"}'),
        backgroundColor: Colors.green,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Absensi Karyawan'),
        backgroundColor: Colors.blue,
        elevation: 2,
      ),
      body: Column(
        children: [
          Expanded(
            flex: 2,
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
                      fillColor: Colors.blue.withOpacity(0.2),
                      strokeColor: Colors.blue,
                      strokeWidth: 1,
                    ),
                  },
                ),
                Positioned(
                  top: 16,
                  left: 16,
                  right: 16,
                  child: Card(
                    elevation: 4,
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Text(
                        _isWithinRadius
                            ? 'Anda berada dalam radius kantor'
                            : 'Anda berada di luar radius kantor',
                        style: TextStyle(
                          color: _isWithinRadius ? Colors.green : Colors.red,
                          fontWeight: FontWeight.bold,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          Container(
            decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.withOpacity(0.2),
                  spreadRadius: 1,
                  blurRadius: 5,
                  offset: const Offset(0, -2),
                ),
              ],
            ),
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 8.0),
                        child: ElevatedButton(
                          onPressed: () => _absen(true),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.green,
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                          child: const Text(
                            'Absen Masuk',
                            style: TextStyle(fontSize: 16),
                          ),
                        ),
                      ),
                    ),
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 8.0),
                        child: ElevatedButton(
                          onPressed: () => _absen(false),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.red,
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                          child: const Text(
                            'Absen Keluar',
                            style: TextStyle(fontSize: 16),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.grey[100],
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Column(
                    children: [
                      _buildAbsenInfo('Absen Masuk', _absenMasuk),
                      const SizedBox(height: 8),
                      _buildAbsenInfo('Absen Keluar', _absenKeluar),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _getCurrentLocation,
        backgroundColor: Colors.blue,
        child: const Icon(Icons.my_location),
      ),
    );
  }

  Widget _buildAbsenInfo(String label, String? value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
        Text(
          value ?? "Belum absen",
          style: TextStyle(
            fontSize: 16,
            color: value != null ? Colors.black : Colors.grey,
          ),
        ),
      ],
    );
  }
}