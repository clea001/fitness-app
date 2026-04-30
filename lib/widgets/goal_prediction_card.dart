import 'package:flutter/material.dart';
import '../models/goal_prediction.dart';
import '../theme/app_theme.dart';

class GoalPredictionCard extends StatelessWidget {
  final GoalPrediction prediction;

  const GoalPredictionCard({super.key, required this.prediction});

  @override
  Widget build(BuildContext context) {
    if (prediction.milestones.isEmpty) return const SizedBox.shrink();

    final gradientColors = prediction.goalType == '减脂'
        ? [AppColors.primary, AppColors.primaryDark]
        : prediction.goalType == '增肌'
            ? [AppColors.lavender, const Color(0xFF9B8EC8)]
            : [AppColors.mint, const Color(0xFF7BC4A8)];

    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(colors: gradientColors, begin: Alignment.topLeft, end: Alignment.bottomRight),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [BoxShadow(color: gradientColors[0].withOpacity(0.25), blurRadius: 10, offset: const Offset(0, 4))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Padding(
            padding: const EdgeInsets.all(20),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    prediction.goalType == '减脂'
                        ? Icons.trending_down_rounded
                        : prediction.goalType == '增肌'
                            ? Icons.fitness_center_rounded
                            : Icons.favorite_rounded,
                    color: Colors.white,
                    size: 22,
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('📊 目标预测', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white)),
                      Text(
                        prediction.goalType == '减脂'
                            ? '基于你的卡路里缺口预测减脂进度'
                            : prediction.goalType == '增肌'
                                ? '基于你的训练和营养预测增肌进度'
                                : '基于你的健康习惯预测改善进度',
                        style: TextStyle(fontSize: 11, color: Colors.white.withOpacity(0.8)),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // Stats row
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              children: [
                _buildStatChip(
                  prediction.goalType == '减脂' ? '每周减重' : '每周增重',
                  prediction.weeklyWeightChange > 0 ? '${prediction.weeklyWeightChange.toStringAsFixed(1)} kg' : '0.0 kg',
                ),
                const SizedBox(width: 10),
                _buildStatChip(
                  prediction.goalType == '减脂' ? '每月减重' : '每月增重',
                  prediction.monthlyWeightChange > 0 ? '${prediction.monthlyWeightChange.toStringAsFixed(1)} kg' : '0.0 kg',
                ),
                const SizedBox(width: 10),
                _buildStatChip('力量提升', '${prediction.strengthIncreasePercent.toInt()}%'),
              ],
            ),
          ),
          const SizedBox(height: 16),

          // Milestones
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 16),
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.15),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('🎯 里程碑预测', style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: Colors.white)),
                const SizedBox(height: 10),
                ...prediction.milestones.map((m) => _buildMilestone(m)),
              ],
            ),
          ),
          const SizedBox(height: 14),

          // Motivation tip
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 20),
            child: Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.15),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                children: [
                  const Text('💡', style: TextStyle(fontSize: 16)),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      prediction.motivationTip,
                      style: TextStyle(fontSize: 12, color: Colors.white.withOpacity(0.9), height: 1.4),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatChip(String label, String value) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 10),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.15),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          children: [
            Text(value, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: Colors.white)),
            const SizedBox(height: 2),
            Text(label, style: TextStyle(fontSize: 9, color: Colors.white.withOpacity(0.7)), textAlign: TextAlign.center),
          ],
        ),
      ),
    );
  }

  Widget _buildMilestone(Milestone m) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          Text(m.icon, style: const TextStyle(fontSize: 18)),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(m.title, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: Colors.white)),
                Text(m.description, style: TextStyle(fontSize: 10, color: Colors.white.withOpacity(0.7))),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text('约${m.weeks}周', style: const TextStyle(fontSize: 10, color: Colors.white, fontWeight: FontWeight.w600)),
          ),
        ],
      ),
    );
  }
}
