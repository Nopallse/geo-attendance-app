import '../models/office_model.dart';
import '../api/services/office_service.dart';

abstract class OfficeRepository {
  Future<Map<String, dynamic>> getOffices();
}


class OfficeRepositoryImpl implements OfficeRepository {
  final OfficeService _officeService = OfficeService();

  @override
  Future<Map<String, dynamic>> getOffices() async {
    return await _officeService.getOffices();
  }
}