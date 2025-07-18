# Implementasi Fitur Permohonan Keterlambatan

## Overview

Fitur Permohonan Keterlambatan memungkinkan pengguna untuk mengajukan permohonan datang terlambat sebelum hari kejadian. Jika permohonan disetujui, sistem akan menggunakan jam yang direncanakan sebagai batas toleransi keterlambatan.

## Struktur File

### Models
- `lib/data/models/late_arrival_request_model.dart` - Model untuk permohonan keterlambatan
  - `LateArrivalRequest` - Model utama
  - `CreateLateArrivalRequest` - Model untuk membuat permohonan baru
  - `LateArrivalRequestsResponse` - Model untuk response list permohonan
  - `PaginationInfo` - Model untuk informasi pagination

### Repository
- `lib/data/repositories/late_arrival_repository.dart` - Repository untuk API calls
  - `createLateArrivalRequest()` - Membuat permohonan baru
  - `getMyLateArrivalRequests()` - Mengambil daftar permohonan user
  - `getTodayLateArrivalRequest()` - Mengambil permohonan hari ini
  - `deleteLateArrivalRequest()` - Menghapus permohonan

### Provider
- `lib/providers/late_arrival_provider.dart` - State management untuk fitur late arrival
  - State management untuk daftar permohonan
  - Validasi dan error handling
  - Statistik permohonan

### Services
- `lib/services/late_arrival_service.dart` - Business logic service
  - `getTodayApprovedRequest()` - Mengambil permohonan yang disetujui hari ini
  - `calculateAttendanceStatus()` - Menghitung status kehadiran berdasarkan permohonan
  - `getAttendanceStatusMessage()` - Pesan status kehadiran
  - `validateNewRequest()` - Validasi permohonan baru

### UI Screens
- `lib/screens/leave/create_late_arrival_request_page.dart` - Form pembuatan permohonan
- `lib/screens/leave/late_arrival_requests_page.dart` - Daftar permohonan user

### Widgets
- `lib/widgets/dashboard/late_arrival_button.dart` - Button di dashboard
- `lib/widgets/custom_button.dart` - Custom button component
- `lib/widgets/custom_text_field.dart` - Custom text field component

## Endpoints API

### 1. Buat Permohonan Keterlambatan
```
POST /permohonan-terlambat/
```

**Request Body:**
```json
{
  "tanggal_terlambat": "2025-07-01",
  "jam_datang_rencana": "08:30",
  "alasan": "Ada urusan keluarga yang tidak bisa ditunda"
}
```

**Response Success (201):**
```json
{
  "success": true,
  "message": "Permohonan keterlambatan berhasil diajukan",
  "data": {
    "id": 1,
    "user_nip": "12345",
    "tanggal_terlambat": "2025-07-01",
    "jam_datang_rencana": "08:30:00",
    "alasan": "Ada urusan keluarga yang tidak bisa ditunda",
    "status": "pending",
    "created_at": "2025-06-30T04:10:00.000Z",
    "updated_at": "2025-06-30T04:10:00.000Z"
  }
}
```

### 2. Lihat Permohonan Milik User
```
GET /permohonan-terlambat/my-requests?page=1&limit=10
```

### 3. Cek Permohonan Keterlambatan Hari Ini
```
GET /permohonan-terlambat/today
```

## Validasi

### Tanggal Terlambat
- Harus tanggal yang valid
- Minimal besok (tidak bisa hari ini atau kemarin)

### Jam Datang Rencana
- Format HH:MM
- Maksimal jam 10:00

### Alasan
- Minimal 10 karakter

## Logika Integrasi dengan Sistem Absensi

### Tanpa Permohonan Keterlambatan
- Datang sebelum 07:45 → Status: "hadir"
- Datang setelah 07:45 → Status: "telat"

### Dengan Permohonan Keterlambatan yang Disetujui
- Datang sebelum jam yang direncanakan → Status: "hadir"
- Datang setelah jam yang direncanakan → Status: "telat"

## Cara Penggunaan

### 1. Akses dari Dashboard
- User dapat melihat button "Permohonan Keterlambatan" di dashboard
- Button menampilkan jumlah permohonan pending (jika ada)
- Menampilkan status permohonan hari ini (jika ada)

### 2. Membuat Permohonan Baru
1. Tap button "+" di halaman daftar permohonan atau FAB
2. Pilih tanggal (minimal besok)
3. Pilih jam datang rencana (maksimal 10:00)
4. Isi alasan (minimal 10 karakter)
5. Submit permohonan

### 3. Melihat Daftar Permohonan
- Menampilkan semua permohonan user dengan pagination
- Filter berdasarkan status (pending, approved, rejected)
- Statistik permohonan
- Detail permohonan dalam bottom sheet

### 4. Menghapus Permohonan
- Hanya permohonan dengan status "pending" yang bisa dihapus
- Konfirmasi dialog sebelum menghapus

## State Management

### LateArrivalProvider
```dart
// State variables
List<LateArrivalRequest> requests
LateArrivalRequest? todayRequest
bool isLoading
String? errorMessage
String? successMessage

// Methods
createLateArrivalRequest(CreateLateArrivalRequest request)
getMyRequests({bool refresh = false})
getTodayRequest()
deleteLateArrivalRequest(int id)
getStatistics()
canCreateRequestForDate(DateTime date)
```

## Error Handling

### Client-side Validation
- Validasi format tanggal dan waktu
- Validasi panjang alasan
- Validasi tanggal minimal besok
- Validasi jam maksimal 10:00

### Server-side Error Handling
- Network errors dengan pesan user-friendly
- API errors dengan pesan dari server
- Loading states untuk UX yang baik
- Retry functionality

## Styling

Menggunakan design system yang konsisten:
- `AppColors` untuk warna
- `CustomButton` dan `CustomTextField` untuk komponen
- Material Design 3 guidelines
- Responsive layout

## Testing

### Unit Tests yang Diperlukan
1. Model validation tests
2. Repository API call tests
3. Provider state management tests
4. Service business logic tests

### Integration Tests
1. End-to-end flow pembuatan permohonan
2. Integration dengan attendance system
3. UI interaction tests

## Deployment

### Langkah-langkah
1. Pastikan backend API sudah implement endpoints
2. Update base URL di `ApiEndpoints`
3. Test di environment development
4. Deploy ke production

### Monitoring
- Monitor API call success rates
- Track user adoption metrics
- Monitor error rates dan crashes

## Maintenance

### Potential Improvements
1. Push notifications untuk status permohonan
2. Bulk approval untuk admin
3. Recurring late arrival requests
4. Integration dengan calendar
5. Analytics dashboard untuk admin

### Performance Considerations
- Pagination untuk large datasets
- Cache for frequently accessed data
- Optimistic updates untuk better UX
- Image optimization for attachments (future feature)

## Security

### Data Protection
- Input sanitization dan validation
- Secure API endpoints dengan authentication
- Rate limiting untuk prevent abuse
- Audit trail untuk admin actions

### Privacy
- Personal data handling sesuai regulasi
- User consent untuk data collection
- Data retention policies
