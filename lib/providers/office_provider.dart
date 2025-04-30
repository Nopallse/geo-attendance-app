import 'package:flutter/foundation.dart';
import '../data/models/office_model.dart';
import '../data/repositories/office_repository.dart';

class OfficeProvider with ChangeNotifier {
  final OfficeRepository _officeRepository;

  // Dependency injection through constructor
  OfficeProvider({required OfficeRepository officeRepository})
      : _officeRepository = officeRepository;

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
      final result = await _officeRepository.getOffices();

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