import 'package:flutter/foundation.dart';
import '../data/api/services/office_service.dart';
import '../data/models/office_model.dart';

class OfficeProvider with ChangeNotifier {
  final OfficeService _officeService = OfficeService();

  List<Office> _offices = [];
  bool _isLoading = false;
  String? _errorMessage;

  List<Office> get offices => _offices;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  // Get all office locations
  Future<void> getOffices() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final result = await _officeService.getOffices();

      if (result['success']) {
        final List<dynamic> data = result['data']['data'];
        _offices = data.map((item) => Office.fromJson(item)).toList();
      } else {
        _errorMessage = result['message'];
      }
    } catch (e) {
      _errorMessage = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }
}