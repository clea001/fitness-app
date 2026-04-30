import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/calendar_provider.dart';
import '../models/goal_prediction.dart';
import '../widgets/calendar_widget.dart';
import '../widgets/goal_prediction_card.dart';
import '../theme/app_theme.dart';
import 'daily_detail_screen.dart';

class CalendarScreen extends StatefulWidget {
  const CalendarScreen({super.key});

  @override
  State<CalendarScreen> createState() => _CalendarScreenState();
}

class _CalendarScreenState extends State<CalendarScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<CalendarProvider>().goToToday();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('打卡日历')),
      body: Consumer<CalendarProvider>(
        builder: (context, provider, _) {
          return Column(
            children: [
              _buildHeader(provider),
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Column(
                    children: [
                      CalendarWidget(
                        currentMonth: provider.currentMonth,
                        records: provider.monthRecords,
                        onDayTap: (date) => _onDayTap(context, date, provider),
                      ),
                      const SizedBox(height: 16),
                      _buildLegend(),
                      const SizedBox(height: 16),
                      _buildMonthStats(provider),
                      const SizedBox(height: 16),
                      _buildGoalPrediction(provider),
                      const SizedBox(height: 24),
                    ],
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildHeader(CalendarProvider provider) {
    final monthNames = ['', '一月', '二月', '三月', '四月', '五月', '六月', '七月', '八月', '九月', '十月', '十一月', '十二月'];

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          IconButton(
            onPressed: provider.previousMonth,
            icon: const Icon(Icons.chevron_left_rounded, size: 28),
            style: IconButton.styleFrom(backgroundColor: Colors.white),
          ),
          GestureDetector(
            onTap: provider.goToToday,
            child: Column(
              children: [
                Text(
                  '${provider.currentMonth.year}年${monthNames[provider.currentMonth.month]}',
                  style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.textPrimary),
                ),
                const Text('点击回到今天', style: TextStyle(fontSize: 10, color: AppColors.textHint)),
              ],
            ),
          ),
          IconButton(
            onPressed: provider.nextMonth,
            icon: const Icon(Icons.chevron_right_rounded, size: 28),
            style: IconButton.styleFrom(backgroundColor: Colors.white),
          ),
        ],
      ),
    );
  }

  Widget _buildLegend() {
    return const Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        _LegendItem(color: AppColors.primary, label: '健身计划'),
        SizedBox(width: 24),
        _LegendItem(color: AppColors.mint, label: '饮食计划'),
      ],
    );
  }

  Widget _buildMonthStats(CalendarProvider provider) {
    if (provider.daysWithRecords == 0) {
      return Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
        ),
        child: const Center(
          child: Column(
            children: [
              Text('🌸', style: TextStyle(fontSize: 32)),
              SizedBox(height: 8),
              Text('本月暂无计划记录', style: TextStyle(fontSize: 14, color: AppColors.textHint)),
              SizedBox(height: 4),
              Text('去生成健身或饮食计划吧~', style: TextStyle(fontSize: 12, color: AppColors.textHint)),
            ],
          ),
        ),
      );
    }

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 10, offset: const Offset(0, 3))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('本月统计', style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: AppColors.textPrimary)),
          const SizedBox(height: 16),
          Row(
            children: [
              _statItem('记录天数', '${provider.daysWithRecords}', Icons.calendar_today_rounded, AppColors.primary),
              _statItem('总摄入', '${provider.totalConsumed}', Icons.restaurant_rounded, AppColors.mint),
              _statItem('总消耗', '${provider.totalBurned}', Icons.local_fire_department_rounded, AppColors.primaryDark),
            ],
          ),
        ],
      ),
    );
  }

  Widget _statItem(String label, String value, IconData icon, Color color) {
    return Expanded(
      child: Column(
        children: [
          Icon(icon, color: color, size: 22),
          const SizedBox(height: 6),
          Text(value, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.textPrimary)),
          Text(label, style: const TextStyle(fontSize: 10, color: AppColors.textHint)),
        ],
      ),
    );
  }

  Widget _buildGoalPrediction(CalendarProvider provider) {
    if (provider.monthRecords.isEmpty) return const SizedBox.shrink();

    final records = provider.monthRecords.values.toList();
    String goal = '';
    for (final r in records) {
      if (r.fitnessPlan != null && r.fitnessPlan!.focus.isNotEmpty) {
        goal = r.fitnessPlan!.focus;
        break;
      }
      if (r.dietPlan != null && r.dietPlan!.goal.isNotEmpty) {
        goal = r.dietPlan!.goal;
        break;
      }
    }
    if (goal.isEmpty) goal = '健康生活';

    final prediction = GoalPrediction.fromRecords(records, goal);
    return GoalPredictionCard(prediction: prediction);
  }

  void _onDayTap(BuildContext context, DateTime date, CalendarProvider provider) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => DailyDetailScreen(date: date)),
    ).then((_) => provider.refresh());
  }
}

class _LegendItem extends StatelessWidget {
  final Color color;
  final String label;

  const _LegendItem({required this.color, required this.label});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 8,
          height: 8,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        ),
        const SizedBox(width: 6),
        Text(label, style: const TextStyle(fontSize: 12, color: AppColors.textSecondary)),
      ],
    );
  }
}
