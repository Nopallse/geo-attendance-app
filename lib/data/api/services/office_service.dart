import '../../api/api_service.dart';
import '../../api/endpoints.dart';

class OfficeService {
  final ApiService _apiService = ApiService();

  Future<Map<String, dynamic>> getOffices() async {
    try {
      return await _apiService.get(ApiEndpoints.offices);
    } catch (e) {
      return {"success": false, "message": "Failed to get office locations: $e"};
    }
  }
}