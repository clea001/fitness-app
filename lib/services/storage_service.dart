import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/daily_record.dart';
import '../models/fitness_plan.dart';
import '../models/diet_plan.dart';

class StorageService {
  static const String _prefix = 'daily_record_';
  static const String _recordDatesKey = 'record_dates';

  // 保存每日记录
  static Future<void> saveRecord(DailyRecord record) async {
    final prefs = await SharedPreferences.getInstance();
    final key = '$_prefix${record.date}';
    await prefs.setString(key, jsonEncode(record.toJson()));

    // 更新日期索引
    final dates = prefs.getStringList(_recordDatesKey) ?? [];
    if (!dates.contains(record.date)) {
      dates.add(record.date);
      await prefs.setStringList(_recordDatesKey, dates);
    }
  }

  // 获取某天的记录
  static Future<DailyRecord?> getRecord(String date) async {
    final prefs = await SharedPreferences.getInstance();
    final key = '$_prefix$date';
    final json = prefs.getString(key);
    if (json == null) return null;
    return DailyRecord.fromJson(jsonDecode(json));
  }

  // 获取所有有记录的日期
  static Future<List<String>> getRecordDates() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getStringList(_recordDatesKey) ?? [];
  }

  // 保存健身计划（映射到本周日期）
  static Future<void> saveFitnessPlan(FitnessPlan plan) async {
    final now = DateTime.now();
    // 找到本周一
    final monday = now.subtract(Duration(days: now.weekday - 1));

    final dayMap = {
      '周一': 0, '周二': 1, '周三': 2, '周四': 3,
      '周五': 4, '周六': 5, '周日': 6,
      '星期一': 0, '星期二': 1, '星期三': 2, '星期四': 3,
      '星期五': 4, '星期六': 5, '星期日': 6,
    };

    for (final dayPlan in plan.days) {
      final offset = dayMap[dayPlan.day];
      if (offset == null) continue;

      final date = monday.add(Duration(days: offset));
      final dateStr = _formatDate(date);

      // 获取已有记录或创建新记录
      var record = await getRecord(dateStr) ?? DailyRecord(date: dateStr);

      final burned = DailyRecord.estimateBurnedCalories(dayPlan);
      record = record.copyWith(
        fitnessPlan: dayPlan,
        burnedCalories: burned,
      );

      await saveRecord(record);
    }
  }

  // 保存饮食计划（保存到指定日期，默认今天）
  static Future<void> saveDietPlan(DietPlan plan, {String? date}) async {
    final dateStr = date ?? _formatDate(DateTime.now());
    var record = await getRecord(dateStr) ?? DailyRecord(date: dateStr);

    final consumed = DailyRecord.parseConsumedCalories(plan);
    final target = DailyRecord.parseTargetCalories(plan.goal);
    record = record.copyWith(
      dietPlan: plan,
      consumedCalories: consumed,
      targetCalories: target,
    );

    await saveRecord(record);
  }

  // 获取某月所有记录
  static Future<Map<String, DailyRecord>> getMonthRecords(int year, int month) async {
    final dates = await getRecordDates();
    final prefix = '${year.toString()}-${month.toString().padLeft(2, '0')}';
    final Map<String, DailyRecord> records = {};

    for (final date in dates) {
      if (date.startsWith(prefix)) {
        final record = await getRecord(date);
        if (record != null) {
          records[date] = record;
        }
      }
    }
    return records;
  }

  static String _formatDate(DateTime date) {
    return '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
  }
}
