import 'daily_record.dart';

class GoalPrediction {
  final String goalType; // '减脂' or '增肌'
  final double weeklyWeightChange; // kg per week (negative for loss)
  final double monthlyWeightChange; // kg per month
  final List<Milestone> milestones;
  final double strengthIncreasePercent;
  final String motivationTip;

  GoalPrediction({
    required this.goalType,
    required this.weeklyWeightChange,
    required this.monthlyWeightChange,
    required this.milestones,
    required this.strengthIncreasePercent,
    required this.motivationTip,
  });

  static GoalPrediction fromRecords(List<DailyRecord> records, String goal) {
    if (records.isEmpty) return _empty(goal);

    final isFatLoss = goal.contains('减') || goal.contains('瘦') || goal.contains('脂');
    final isMuscleGain = goal.contains('增') || goal.contains('肌') || goal.contains('练');

    // Calculate average daily calorie deficit/surplus
    int totalDeficit = 0;
    int daysWithData = 0;
    for (final r in records) {
      if (r.consumedCalories > 0 || r.burnedCalories > 0) {
        totalDeficit += (r.consumedCalories - r.burnedCalories - r.targetCalories);
        daysWithData++;
      }
    }

    if (daysWithData == 0) return _empty(goal);

    final avgDailyDeficit = totalDeficit / daysWithData;
    // 1kg fat ≈ 7700 kcal
    final weeklyChange = (avgDailyDeficit * 7) / 7700;
    final monthlyChange = weeklyChange * 4.33;

    if (isFatLoss) {
      return _buildFatLossPrediction(avgDailyDeficit, weeklyChange, monthlyChange);
    } else if (isMuscleGain) {
      return _buildMuscleGainPrediction(avgDailyDeficit, weeklyChange, monthlyChange);
    }
    return _buildGeneralPrediction(avgDailyDeficit, weeklyChange, monthlyChange);
  }

  static GoalPrediction _buildFatLossPrediction(double avgDeficit, double weekly, double monthly) {
    final effectiveWeekly = weekly.abs();
    final effectiveMonthly = monthly.abs();

    List<Milestone> milestones = [];
    if (effectiveWeekly > 0) {
      final weeksTo5kg = effectiveWeekly > 0 ? (5 / effectiveWeekly).ceil() : 99;
      final weeksTo10kg = effectiveWeekly > 0 ? (10 / effectiveWeekly).ceil() : 99;
      final weeksToBellyFat = effectiveWeekly > 0 ? (3 / effectiveWeekly).ceil() : 99;

      milestones = [
        Milestone(
          title: '减掉3kg',
          description: '腰围明显缩小，衣服变松',
          weeks: weeksToBellyFat,
          icon: '🎯',
        ),
        Milestone(
          title: '减掉5kg',
          description: '面部轮廓更清晰，精神更好',
          weeks: weeksTo5kg,
          icon: '✨',
        ),
        Milestone(
          title: '减掉10kg',
          description: '体型明显变化，健康指标改善',
          weeks: weeksTo10kg,
          icon: '🏆',
        ),
      ];
    }

    String tip;
    if (avgDeficit < -500) {
      tip = '很棒！你每天的卡路里缺口约${avgDeficit.abs().toInt()}大卡，继续保持这个节奏！';
    } else if (avgDeficit < 0) {
      tip = '卡路里缺口较小，可以适当增加运动量或减少摄入来加速减脂。';
    } else {
      tip = '当前摄入略高于消耗，建议减少高热量食物或增加运动频率。';
    }

    return GoalPrediction(
      goalType: '减脂',
      weeklyWeightChange: -effectiveWeekly,
      monthlyWeightChange: -effectiveMonthly,
      milestones: milestones,
      strengthIncreasePercent: effectiveWeekly > 0 ? (effectiveWeekly * 10).clamp(0, 50) : 0,
      motivationTip: tip,
    );
  }

  static GoalPrediction _buildMuscleGainPrediction(double avgDeficit, double weekly, double monthly) {
    // For muscle gain, surplus is needed
    final surplus = avgDeficit > 0 ? avgDeficit : 0;
    final weeklyGain = surplus > 0 ? (surplus * 7 / 7700 * 0.5) : 0.2; // half goes to muscle
    final monthlyGain = weeklyGain * 4.33;

    List<Milestone> milestones = [
      Milestone(
        title: '力量提升10%',
        description: '神经适应期，动作更标准',
        weeks: 3,
        icon: '💪',
      ),
      Milestone(
        title: '胸肌轮廓初现',
        description: '胸部开始有型，穿衣服更好看',
        weeks: 8,
        icon: '🏋️',
      ),
      Milestone(
        title: '腹肌隐约可见',
        description: '体脂降低，核心力量增强',
        weeks: 12,
        icon: '🔥',
      ),
      Milestone(
        title: '肱二头肌明显',
        description: '手臂围度增加，线条清晰',
        weeks: 16,
        icon: '💪',
      ),
      Milestone(
        title: '整体肌肉线条',
        description: '全身肌肉协调增长，体态改善',
        weeks: 24,
        icon: '🏆',
      ),
    ];

    String tip;
    if (surplus > 200) {
      tip = '热量盈余充足，配合训练可以有效增肌。记得每餐摄入足够蛋白质！';
    } else if (surplus > 0) {
      tip = '热量盈余较小，建议适当增加蛋白质和碳水摄入以支持肌肉生长。';
    } else {
      tip = '当前处于热量缺口状态，增肌效果会受限。建议适当增加饮食摄入。';
    }

    return GoalPrediction(
      goalType: '增肌',
      weeklyWeightChange: weeklyGain,
      monthlyWeightChange: monthlyGain,
      milestones: milestones,
      strengthIncreasePercent: surplus > 0 ? (surplus * 0.05).clamp(5, 60) : 10,
      motivationTip: tip,
    );
  }

  static GoalPrediction _buildGeneralPrediction(double avgDeficit, double weekly, double monthly) {
    return GoalPrediction(
      goalType: '健康',
      weeklyWeightChange: weekly.abs(),
      monthlyWeightChange: monthly.abs(),
      milestones: [
        Milestone(title: '体能提升', description: '日常活动更轻松', weeks: 2, icon: '⚡'),
        Milestone(title: '体型改善', description: '身体线条更匀称', weeks: 6, icon: '✨'),
        Milestone(title: '健康达标', description: '各项指标趋于正常', weeks: 12, icon: '🏆'),
      ],
      strengthIncreasePercent: 15,
      motivationTip: '坚持运动和合理饮食，身体会给你惊喜！',
    );
  }

  static GoalPrediction _empty(String goal) {
    return GoalPrediction(
      goalType: goal,
      weeklyWeightChange: 0,
      monthlyWeightChange: 0,
      milestones: [],
      strengthIncreasePercent: 0,
      motivationTip: '开始记录你的训练和饮食，AI 将为你预测目标达成时间！',
    );
  }
}

class Milestone {
  final String title;
  final String description;
  final int weeks;
  final String icon;

  Milestone({
    required this.title,
    required this.description,
    required this.weeks,
    required this.icon,
  });
}
