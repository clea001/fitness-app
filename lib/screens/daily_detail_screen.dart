import 'package:flutter/material.dart';
import '../models/daily_record.dart';
import '../models/goal_prediction.dart';
import '../services/storage_service.dart';
import '../widgets/goal_prediction_card.dart';
import '../theme/app_theme.dart';

class DailyDetailScreen extends StatefulWidget {
  final DateTime date;

  const DailyDetailScreen({super.key, required this.date});

  @override
  State<DailyDetailScreen> createState() => _DailyDetailScreenState();
}

class _DailyDetailScreenState extends State<DailyDetailScreen> {
  DailyRecord? _record;
  List<DailyRecord> _monthRecords = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadRecord();
  }

  Future<void> _loadRecord() async {
    final dateStr = _formatDate(widget.date);
    final record = await StorageService.getRecord(dateStr);
    final monthRecordsMap = await StorageService.getMonthRecords(widget.date.year, widget.date.month);
    setState(() {
      _record = record;
      _monthRecords = monthRecordsMap.values.toList();
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final dateStr = '${widget.date.year}年${widget.date.month}月${widget.date.day}日';
    final weekdays = ['周一', '周二', '周三', '周四', '周五', '周六', '周日'];
    final weekday = weekdays[widget.date.weekday - 1];

    return Scaffold(
      appBar: AppBar(title: Text('$dateStr $weekday')),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator(color: AppColors.primary))
          : _record == null
              ? _buildEmpty()
              : _buildContent(_record!),
    );
  }

  Widget _buildEmpty() {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text('🌸', style: TextStyle(fontSize: 56)),
          SizedBox(height: 16),
          Text('暂无计划记录', style: TextStyle(fontSize: 16, color: AppColors.textHint)),
          SizedBox(height: 6),
          Text('去生成健身或饮食计划吧~', style: TextStyle(fontSize: 13, color: AppColors.textHint)),
        ],
      ),
    );
  }

  Widget _buildContent(DailyRecord record) {
    final goal = record.fitnessPlan?.focus ?? record.dietPlan?.goal ?? '';
    final prediction = GoalPrediction.fromRecords(_monthRecords, goal);

    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildCalorieCard(record),
          const SizedBox(height: 16),
          if (prediction.milestones.isNotEmpty) ...[
            GoalPredictionCard(prediction: prediction),
            const SizedBox(height: 4),
          ],
          if (record.hasFitness) ...[
            _buildSectionTitle('健身计划', Icons.fitness_center_rounded, AppColors.primary),
            const SizedBox(height: 10),
            _buildFitnessCard(record.fitnessPlan!),
            const SizedBox(height: 16),
          ] else ...[
            _buildSectionTitle('健身计划', Icons.fitness_center_rounded, AppColors.textHint),
            const SizedBox(height: 10),
            _buildRestDayCard(),
            const SizedBox(height: 16),
          ],
          if (record.hasDiet) ...[
            _buildSectionTitle('饮食计划', Icons.restaurant_rounded, AppColors.mint),
            const SizedBox(height: 10),
            _buildDietCard(record.dietPlan!),
          ] else ...[
            _buildSectionTitle('饮食计划', Icons.restaurant_rounded, AppColors.textHint),
            const SizedBox(height: 10),
            _buildNoDietCard(),
          ],
        ],
      ),
    );
  }

  Widget _buildCalorieCard(DailyRecord record) {
    final consumed = record.consumedCalories;
    final burned = record.burnedCalories;
    final target = record.targetCalories;
    final net = consumed - burned;
    final progress = target > 0 ? (consumed / target).clamp(0.0, 1.5) : 0.0;

    Color progressColor;
    if (progress <= 0.7) {
      progressColor = AppColors.mint;
    } else if (progress <= 1.0) {
      progressColor = AppColors.primary;
    } else {
      progressColor = AppColors.primaryDark;
    }

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [progressColor.withOpacity(0.8), progressColor],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [BoxShadow(color: progressColor.withOpacity(0.25), blurRadius: 10, offset: const Offset(0, 4))],
      ),
      child: Column(
        children: [
          const Text('卡路里概览', style: TextStyle(fontSize: 13, color: Colors.white70)),
          const SizedBox(height: 16),
          SizedBox(
            width: 110,
            height: 110,
            child: Stack(
              alignment: Alignment.center,
              children: [
                SizedBox(
                  width: 110,
                  height: 110,
                  child: CircularProgressIndicator(
                    value: progress.toDouble(),
                    strokeWidth: 8,
                    backgroundColor: Colors.white24,
                    valueColor: const AlwaysStoppedAnimation<Color>(Colors.white),
                    strokeCap: StrokeCap.round,
                  ),
                ),
                Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text('$consumed', style: const TextStyle(fontSize: 26, fontWeight: FontWeight.bold, color: Colors.white)),
                    Text('/ $target kcal', style: TextStyle(fontSize: 10, color: Colors.white.withOpacity(0.7))),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _calorieStat('摄入', '$consumed', Icons.restaurant_rounded),
              _calorieStat('消耗', '$burned', Icons.local_fire_department_rounded),
              _calorieStat('净摄入', '$net', Icons.balance_rounded),
            ],
          ),
        ],
      ),
    );
  }

  Widget _calorieStat(String label, String value, IconData icon) {
    return Column(
      children: [
        Icon(icon, color: Colors.white70, size: 16),
        const SizedBox(height: 4),
        Text(value, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: Colors.white)),
        Text(label, style: TextStyle(fontSize: 10, color: Colors.white.withOpacity(0.7))),
      ],
    );
  }

  Widget _buildSectionTitle(String title, IconData icon, Color color) {
    return Row(
      children: [
        Icon(icon, color: color, size: 18),
        const SizedBox(width: 8),
        Text(title, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: AppColors.textPrimary)),
      ],
    );
  }

  Widget _buildFitnessCard(dynamic dayPlan) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 10, offset: const Offset(0, 3))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
            decoration: BoxDecoration(
              color: AppColors.primaryLight,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              dayPlan.focus ?? '',
              style: const TextStyle(fontSize: 12, color: AppColors.primaryDark, fontWeight: FontWeight.w600),
            ),
          ),
          const SizedBox(height: 12),
          ...((dayPlan.exercises ?? []) as List).map((e) => Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: Row(
                  children: [
                    Expanded(flex: 3, child: Text(e.name ?? '', style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500, color: AppColors.textPrimary))),
                    Expanded(flex: 2, child: Text('${e.sets ?? ''} × ${e.reps ?? ''}', style: const TextStyle(fontSize: 12, color: AppColors.textSecondary), textAlign: TextAlign.center)),
                    Expanded(flex: 2, child: Text('休息${e.rest ?? '60秒'}', style: const TextStyle(fontSize: 11, color: AppColors.textHint), textAlign: TextAlign.right)),
                  ],
                ),
              )),
          if ((dayPlan.tips ?? '').isNotEmpty) ...[
            const Divider(color: AppColors.divider, height: 20),
            Row(
              children: [
                const Icon(Icons.lightbulb_outline, size: 13, color: AppColors.cream),
                const SizedBox(width: 6),
                Expanded(child: Text(dayPlan.tips, style: const TextStyle(fontSize: 11, color: AppColors.textSecondary, fontStyle: FontStyle.italic))),
              ],
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildRestDayCard() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16)),
      child: const Center(
        child: Column(
          children: [
            Text('😴', style: TextStyle(fontSize: 28)),
            SizedBox(height: 8),
            Text('休息日', style: TextStyle(fontSize: 14, color: AppColors.textHint)),
            Text('让身体充分恢复', style: TextStyle(fontSize: 11, color: AppColors.textHint)),
          ],
        ),
      ),
    );
  }

  Widget _buildDietCard(dynamic dietPlan) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 10, offset: const Offset(0, 3))],
      ),
      child: Column(
        children: [
          ...((dietPlan.meals ?? []) as List).map((meal) {
            final mealIcons = {'早餐': '☀️', '午餐': '🌤', '晚餐': '🌙', '加餐': '🍎'};
            return Container(
              margin: const EdgeInsets.only(bottom: 10),
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppColors.background,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(mealIcons[meal.mealType] ?? '🍽️', style: const TextStyle(fontSize: 16)),
                      const SizedBox(width: 8),
                      Text(meal.mealType ?? '', style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: AppColors.textPrimary)),
                      const Spacer(),
                      if ((meal.calories ?? '').isNotEmpty)
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                          decoration: BoxDecoration(
                            color: AppColors.primaryLight,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(meal.calories, style: const TextStyle(fontSize: 10, color: AppColors.primaryDark, fontWeight: FontWeight.w600)),
                        ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Text(meal.menu ?? '', style: const TextStyle(fontSize: 12, color: AppColors.textBody)),
                  if ((meal.items ?? []).isNotEmpty) ...[
                    const SizedBox(height: 4),
                    Wrap(
                      spacing: 6,
                      runSpacing: 4,
                      children: (meal.items as List).map((item) => Text('• $item', style: const TextStyle(fontSize: 11, color: AppColors.textSecondary))).toList(),
                    ),
                  ],
                ],
              ),
            );
          }),
        ],
      ),
    );
  }

  Widget _buildNoDietCard() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16)),
      child: const Center(
        child: Column(
          children: [
            Text('🥗', style: TextStyle(fontSize: 28)),
            SizedBox(height: 8),
            Text('暂无饮食计划', style: TextStyle(fontSize: 14, color: AppColors.textHint)),
          ],
        ),
      ),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
  }
}
