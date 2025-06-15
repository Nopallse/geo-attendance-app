import 'package:flutter/material.dart';
import '../data/models/leave_model.dart';
import '../data/repositories/leave_repository.dart';

class LeaveProvider extends ChangeNotifier {
  final LeaveRepository _leaveRepository;
  List<LeaveModel> _leaves = [];
  bool _isLoading = false;
  String? _error;
  Map<String, dynamic>? _pagination;

  LeaveProvider(this._leaveRepository);

  List<LeaveModel> get leaves => _leaves;
  bool get isLoading => _isLoading;
  String? get error => _error;
  Map<String, dynamic>? get pagination => _pagination;

  Future<void> getLeaves({int page = 1, int limit = 10}) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final result = await _leaveRepository.getLeaves(page: page, limit: limit);
      if (result['success']) {
        _leaves = result['data'];
        _pagination = result['pagination'];
      } else {
        _error = result['message'];
      }
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> createLeave({
    required DateTime startDate,
    required DateTime endDate,
    required String category,
    required String description,
  }) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final result = await _leaveRepository.createLeave(
        startDate: startDate,
        endDate: endDate,
        category: category,
        description: description,
      );

      if (result['success']) {
        await getLeaves(); // Refresh the list
        return true;
      } else {
        _error = result['message'];
        return false;
      }
    } catch (e) {
      _error = e.toString();
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<LeaveModel?> getLeaveDetail(int id) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final result = await _leaveRepository.getLeaveDetail(id);
      if (result['success']) {
        return result['data'];
      } else {
        _error = result['message'];
        return null;
      }
    } catch (e) {
      _error = e.toString();
      return null;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
} 