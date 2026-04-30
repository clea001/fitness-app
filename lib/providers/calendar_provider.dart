import 'package:flutter/material.dart';
import '../models/daily_record.dart';
import '../services/storage_service.dart';

class CalendarProvider extends ChangeNotifier {
  DateTime _currentMonth = DateTime.now();
  Map<String, DailyRecord> _monthRecords = {};
  bool _isLoading = false;

  DateTime get currentMonth => _currentMonth;
  Map<String, DailyRecord> get monthRecords => _monthRecords;
  bool get isLoading => _isLoading;

  // 当月总卡路里统计
  int get totalConsumed => _monthRecords.values
      .fold(0, (sum, r) => sum + r.consumedCalories);
  int get totalBurned => _monthRecords.values
      .fold(0, (sum, r) => sum + r.burnedCalories);
  int get daysWithRecords => _monthRecords.length;

  Future<void> loadMonth(int year, int month) async {
    _isLoading = true;
    notifyListeners();

    _currentMonth = DateTime(year, month);
    _monthRecords = await StorageService.getMonthRecords(year, month);

    _isLoading = false;
    notifyListeners();
  }

  void previousMonth() {
    final prev = DateTime(_currentMonth.year, _currentMonth.month - 1);
    loadMonth(prev.year, prev.month);
  }

  void nextMonth() {
    final next = DateTime(_currentMonth.year, _currentMonth.month + 1);
    loadMonth(next.year, next.month);
  }

  void goToToday() {
    final now = DateTime.now();
    loadMonth(now.year, now.month);
  }

  Future<DailyRecord?> getRecordForDate(DateTime date) async {
    final dateStr = _formatDate(date);
    if (_monthRecords.containsKey(dateStr)) {
      return _monthRecords[dateStr];
    }
    return await StorageService.getRecord(dateStr);
  }

  Future<void> refresh() async {
    await loadMonth(_currentMonth.year, _currentMonth.month);
  }

  String _formatDate(DateTime date) {
    return '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
  }
}
