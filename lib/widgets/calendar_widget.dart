import 'package:flutter/material.dart';
import '../models/daily_record.dart';
import '../theme/app_theme.dart';

class CalendarWidget extends StatelessWidget {
  final DateTime currentMonth;
  final Map<String, DailyRecord> records;
  final ValueChanged<DateTime> onDayTap;

  const CalendarWidget({
    super.key,
    required this.currentMonth,
    required this.records,
    required this.onDayTap,
  });

  @override
  Widget build(BuildContext context) {
    final daysInMonth = DateTime(currentMonth.year, currentMonth.month + 1, 0).day;
    final firstDayWeekday = DateTime(currentMonth.year, currentMonth.month, 1).weekday;
    final today = DateTime.now();

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 10, offset: const Offset(0, 3))],
      ),
      child: Column(
        children: [
          // 星期头
          Row(
            children: ['一', '二', '三', '四', '五', '六', '日'].map((d) =>
              Expanded(
                child: Center(
                  child: Text(d, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: AppColors.textSecondary)),
                ),
              ),
            ).toList(),
          ),
          const SizedBox(height: 8),

          // 日期网格
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 7,
              childAspectRatio: 0.85,
            ),
            itemCount: (firstDayWeekday - 1) + daysInMonth,
            itemBuilder: (context, index) {
              if (index < firstDayWeekday - 1) return const SizedBox.shrink();

              final day = index - (firstDayWeekday - 1) + 1;
              final date = DateTime(currentMonth.year, currentMonth.month, day);
              final dateStr = _formatDate(date);
              final record = records[dateStr];
              final isToday = date.year == today.year && date.month == today.month && date.day == today.day;

              return _DayCell(
                day: day,
                isToday: isToday,
                hasFitness: record?.hasFitness ?? false,
                hasDiet: record?.hasDiet ?? false,
                onTap: () => onDayTap(date),
              );
            },
          ),
        ],
      ),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
  }
}

class _DayCell extends StatelessWidget {
  final int day;
  final bool isToday;
  final bool hasFitness;
  final bool hasDiet;
  final VoidCallback onTap;

  const _DayCell({
    required this.day,
    required this.isToday,
    required this.hasFitness,
    required this.hasDiet,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.all(2),
        decoration: BoxDecoration(
          color: isToday ? AppColors.primaryLight : Colors.transparent,
          borderRadius: BorderRadius.circular(10),
          border: isToday ? Border.all(color: AppColors.primary, width: 1.5) : null,
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              '$day',
              style: TextStyle(
                fontSize: 14,
                fontWeight: isToday ? FontWeight.bold : FontWeight.normal,
                color: isToday ? AppColors.primaryDark : AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 4),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                if (hasFitness)
                  Container(
                    width: 6,
                    height: 6,
                    margin: const EdgeInsets.symmetric(horizontal: 1),
                    decoration: const BoxDecoration(color: AppColors.primary, shape: BoxShape.circle),
                  ),
                if (hasDiet)
                  Container(
                    width: 6,
                    height: 6,
                    margin: const EdgeInsets.symmetric(horizontal: 1),
                    decoration: const BoxDecoration(color: AppColors.mint, shape: BoxShape.circle),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
