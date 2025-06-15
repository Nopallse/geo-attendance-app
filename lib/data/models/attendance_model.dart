class Attendance {
  final int absenId;
  final String absenNip;
  final int lokasiId;
  final DateTime? absenTgl;
  final DateTime? absenTglJam;
  final String? absenCheckIn;
  final String? absenCheckOut;
  final String? absenKat;
  final String? absenApel;
  final String? absenSore;
  final LocationModel? lokasi; // Ganti Location menjadi LocationModel

  Attendance({
    required this.absenId,
    required this.absenNip,
    required this.lokasiId,
    this.absenTgl,
    this.absenTglJam,
    this.absenCheckIn,
    this.absenCheckOut,
    this.absenKat,
    this.absenApel,
    this.absenSore,
    this.lokasi,
  });

  factory Attendance.fromJson(Map<String, dynamic> json) {
    return Attendance(
      absenId: json['absen_id'] ?? 0,
      absenNip: json['absen_nip'].toString(),
      lokasiId: json['lokasi_id'] ?? 0,
      absenTgl: json['absen_tgl'] != null ? DateTime.tryParse(json['absen_tgl']) : null,
      absenTglJam: json['absen_tgljam'] != null ? DateTime.tryParse(json['absen_tgljam']) : null,
      absenCheckIn: json['absen_checkin'],
      absenCheckOut: json['absen_checkout'],
      absenKat: json['absen_kat'],
      absenApel: json['absen_apel'],
      absenSore: json['absen_sore'],
      lokasi: json['lokasi'] != null ? LocationModel.fromJson(json['lokasi']) : null,
    );
  }



  Map<String, dynamic> toJson() {
    return {
      'absen_id': absenId,
      'absen_nip': absenNip,
      'lokasi_id': lokasiId,
      'absen_tgl': absenTgl?.toIso8601String(),
      'absen_tgljam': absenTglJam?.toIso8601String(),
      'absen_checkin': absenCheckIn,
      'absen_checkout': absenCheckOut,
      'absen_kat': absenKat,
      'absen_apel': absenApel,
      'absen_sore': absenSore,
      'Lokasi': lokasi?.toJson(),
    };
  }

  @override
  String toString() {
    return 'Attendance(absenId: $absenId, absenNip: $absenNip, lokasiId: $lokasiId, '
        'absenTgl: $absenTgl, absenTglJam: $absenTglJam, absenCheckIn: $absenCheckIn, '
        'absenCheckOut: $absenCheckOut, absenKat: $absenKat, absenApel: $absenApel, '
        'absenSore: $absenSore, lokasi: $lokasi)';
  }
}

class LocationModel {  // Mengganti Location menjadi LocationModel
  final double lat;
  final double lng;
  final String ket;

  LocationModel({
    required this.lat,
    required this.lng,
    required this.ket,
  });

  factory LocationModel.fromJson(Map<String, dynamic> json) {
    return LocationModel(
      lat: (json['lat'] ?? 0).toDouble(),
      lng: (json['lng'] ?? 0).toDouble(),
      ket: json['keterangan'] ?? '', // Perbaiki dari 'ket' ke 'keterangan'
    );
  }


  Map<String, dynamic> toJson() {
    return {
      'lat': lat,
      'lng': lng,
      'ket': ket,
    };
  }

  @override
  String toString() {
    return 'LocationModel(lat: $lat, lng: $lng, ket: $ket)';
  }
}
