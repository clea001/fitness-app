import 'fitness_plan.dart';
import 'diet_plan.dart';

class DailyRecord {
  final String date; // "2026-04-30"
  final DayPlan? fitnessPlan;
  final DietPlan? dietPlan;
  final int targetCalories;
  final int consumedCalories;
  final int burnedCalories;

  DailyRecord({
    required this.date,
    this.fitnessPlan,
    this.dietPlan,
    this.targetCalories = 2000,
    this.consumedCalories = 0,
    this.burnedCalories = 0,
  });

  int get netCalories => consumedCalories - burnedCalories;
  double get calorieProgress =>
      targetCalories > 0 ? consumedCalories / targetCalories : 0;
  bool get hasFitness => fitnessPlan != null;
  bool get hasDiet => dietPlan != null;

  factory DailyRecord.fromJson(Map<String, dynamic> json) {
    return DailyRecord(
      date: json['date'] ?? '',
      fitnessPlan: json['fitnessPlan'] != null
          ? DayPlan.fromJson(json['fitnessPlan'])
          : null,
      dietPlan: json['dietPlan'] != null
          ? DietPlan.fromJson(json['dietPlan'])
          : null,
      targetCalories: json['targetCalories'] ?? 2000,
      consumedCalories: json['consumedCalories'] ?? 0,
      burnedCalories: json['burnedCalories'] ?? 0,
    );
  }

  Map<String, dynamic> toJson() => {
        'date': date,
        'fitnessPlan': fitnessPlan?.toJson(),
        'dietPlan': dietPlan?.toJson(),
        'targetCalories': targetCalories,
        'consumedCalories': consumedCalories,
        'burnedCalories': burnedCalories,
      };

  DailyRecord copyWith({
    DayPlan? fitnessPlan,
    DietPlan? dietPlan,
    int? targetCalories,
    int? consumedCalories,
    int? burnedCalories,
  }) {
    return DailyRecord(
      date: date,
      fitnessPlan: fitnessPlan ?? this.fitnessPlan,
      dietPlan: dietPlan ?? this.dietPlan,
      targetCalories: targetCalories ?? this.targetCalories,
      consumedCalories: consumedCalories ?? this.consumedCalories,
      burnedCalories: burnedCalories ?? this.burnedCalories,
    );
  }

  // 卡路里消耗估算（基于运动类型、组数、次数）
  static int estimateBurnedCalories(DayPlan dayPlan) {
    int total = 0;
    for (final exercise in dayPlan.exercises) {
      final rate = _calorieBurnRates[exercise.name] ?? 6;
      final sets = int.tryParse(exercise.sets.replaceAll(RegExp(r'[^0-9]'), '')) ?? 3;
      final reps = int.tryParse(exercise.reps.replaceAll(RegExp(r'[^0-9]'), '')) ?? 10;
      // 每次动作约3-5秒，每组时间 = 次数 × 4秒，加上组间休息30-60秒
      final secondsPerSet = reps * 4 + 45; // 动作时间 + 休息
      final totalMinutes = (sets * secondsPerSet) / 60;
      total += (rate * totalMinutes).round();
    }
    return total;
  }

  // 从饮食计划解析摄入卡路里
  static int parseConsumedCalories(DietPlan dietPlan) {
    // 先尝试解析 dailyCalories
    if (dietPlan.dailyCalories.isNotEmpty) {
      final match = RegExp(r'(\d+)').firstMatch(dietPlan.dailyCalories);
      if (match != null) return int.parse(match.group(1)!);
    }
    // 累加每餐卡路里
    int total = 0;
    for (final meal in dietPlan.meals) {
      if (meal.calories.isNotEmpty) {
        final match = RegExp(r'(\d+)').firstMatch(meal.calories);
        if (match != null) total += int.parse(match.group(1)!);
      }
    }
    return total;
  }

  // 从目标描述估算目标卡路里
  static int parseTargetCalories(String goalDescription) {
    if (goalDescription.contains('减脂') || goalDescription.contains('减肥')) return 1600;
    if (goalDescription.contains('增肌')) return 2500;
    if (goalDescription.contains('维持')) return 2000;
    return 2000;
  }

  static const Map<String, int> _calorieBurnRates = {
    '跑步': 10, '慢跑': 9, '快走': 5,
    '深蹲': 8, '杠铃深蹲': 9, '箭步蹲': 8, '弓步蹲': 8,
    '俯卧撑': 7, '跪姿俯卧撑': 6,
    '平板支撑': 5,
    '卧推': 6, '杠铃卧推': 7, '哑铃卧推': 6,
    '硬拉': 8, '杠铃硬拉': 9,
    '引体向上': 8,
    '波比跳': 12,
    '跳绳': 11,
    '游泳': 9,
    '骑自行车': 7, '动感单车': 8,
    '瑜伽': 4, '拉伸': 3,
    '仰卧起坐': 6, '卷腹': 6,
    '哑铃弯举': 5, '二头弯举': 5,
    '三头下压': 5, '臂屈伸': 6,
    '肩推': 6, '侧平举': 5, '前平举': 5,
    '划船': 7, '坐姿划船': 6,
    '高位下拉': 6,
    '腿举': 7, '腿屈伸': 6, '腿弯举': 6,
  };
}
