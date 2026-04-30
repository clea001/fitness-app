import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/plan_provider.dart';
import '../providers/calendar_provider.dart';
import '../models/fitness_plan.dart';
import '../services/storage_service.dart';
import '../theme/app_theme.dart';
import 'export_screen.dart';

class FitnessResultScreen extends StatefulWidget {
  const FitnessResultScreen({super.key});

  @override
  State<FitnessResultScreen> createState() => _FitnessResultScreenState();
}

class _FitnessResultScreenState extends State<FitnessResultScreen> {
  bool _saved = false;

  Future<void> _savePlan(FitnessPlan plan) async {
    await StorageService.saveFitnessPlan(plan);
    if (mounted) {
      context.read<CalendarProvider>().refresh();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('计划已保存到日历'),
          backgroundColor: AppColors.mint,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('健身计划'),
        actions: [
          Consumer<PlanProvider>(
            builder: (context, provider, _) {
              if (provider.fitnessPlan != null &&
                  provider.fitnessPlan!.days.isNotEmpty) {
                if (!_saved) {
                  _saved = true;
                  WidgetsBinding.instance.addPostFrameCallback((_) {
                    _savePlan(provider.fitnessPlan!);
                  });
                }
                return IconButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => ExportScreen(
                          planType: 'fitness',
                          fitnessPlan: provider.fitnessPlan,
                        ),
                      ),
                    );
                  },
                  icon: const Icon(Icons.image_rounded),
                  tooltip: '导出图片',
                );
              }
              return const SizedBox.shrink();
            },
          ),
        ],
      ),
      body: Consumer<PlanProvider>(
        builder: (context, provider, _) {
          if (provider.isGenerating) return _buildLoading();
          if (provider.error != null) return _buildError(provider.error!);
          final plan = provider.fitnessPlan;
          if (plan == null || plan.days.isEmpty) return _buildEmpty();
          return _buildPlan(context, plan);
        },
      ),
    );
  }

  Widget _buildLoading() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              color: AppColors.primaryLight,
              shape: BoxShape.circle,
            ),
            child: const Center(
              child: CircularProgressIndicator(color: AppColors.primary, strokeWidth: 3),
            ),
          ),
          const SizedBox(height: 20),
          const Text(
            '正在为你定制健身计划...',
            style: TextStyle(fontSize: 16, color: AppColors.textSecondary),
          ),
          const SizedBox(height: 8),
          const Text(
            'AI 教练正在思考中 ✨',
            style: TextStyle(fontSize: 13, color: AppColors.textHint),
          ),
        ],
      ),
    );
  }

  Widget _buildError(String error) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline_rounded, size: 56, color: AppColors.primaryDark),
            const SizedBox(height: 16),
            const Text('生成失败', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.textPrimary)),
            const SizedBox(height: 8),
            Text(
              error.contains('解析') ? error : '网络或服务异常，请检查 API 配置后重试',
              textAlign: TextAlign.center,
              style: const TextStyle(color: AppColors.textSecondary),
            ),
            const SizedBox(height: 20),
            ElevatedButton.icon(
              onPressed: () => Navigator.pop(context),
              icon: const Icon(Icons.refresh_rounded),
              label: const Text('返回重试'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmpty() {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text('🌸', style: TextStyle(fontSize: 48)),
          SizedBox(height: 12),
          Text('暂无计划', style: TextStyle(fontSize: 16, color: AppColors.textHint)),
          SizedBox(height: 4),
          Text('去生成一个健身计划吧~', style: TextStyle(fontSize: 13, color: AppColors.textHint)),
        ],
      ),
    );
  }

  Widget _buildPlan(BuildContext context, FitnessPlan plan) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 目标卡片
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [AppColors.primary, AppColors.primaryDark],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '🎯 ${plan.goal}',
                  style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white),
                ),
                const SizedBox(height: 8),
                Text(
                  plan.summary,
                  style: TextStyle(fontSize: 13, color: Colors.white.withOpacity(0.9)),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),

          // 自动保存提示
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: AppColors.mint.withOpacity(0.15),
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.check_circle_outline, size: 14, color: AppColors.mint),
                SizedBox(width: 6),
                Text('已自动保存到日历', style: TextStyle(fontSize: 11, color: AppColors.mint)),
              ],
            ),
          ),
          const SizedBox(height: 20),

          // 每日计划
          ...plan.days.map((day) => _buildDayCard(day)),
        ],
      ),
    );
  }

  Widget _buildDayCard(DayPlan day) {
    final isRestDay = day.exercises.isEmpty;
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 10, offset: const Offset(0, 3)),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: isRestDay ? AppColors.divider : AppColors.primaryLight,
              borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
            ),
            child: Row(
              children: [
                Text(
                  day.day,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: isRestDay ? AppColors.textSecondary : AppColors.primaryDark,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    day.focus,
                    style: const TextStyle(fontSize: 13, color: AppColors.textSecondary),
                  ),
                ),
              ],
            ),
          ),
          if (isRestDay)
            const Padding(
              padding: EdgeInsets.all(20),
              child: Center(
                child: Text('😴 休息日 - 让身体恢复', style: TextStyle(fontSize: 14, color: AppColors.textHint)),
              ),
            )
          else
            Padding(
              padding: const EdgeInsets.all(14),
              child: Column(
                children: [
                  ...day.exercises.map((e) => _buildExerciseRow(e)),
                  if (day.tips.isNotEmpty) ...[
                    const Divider(color: AppColors.divider, height: 20),
                    Row(
                      children: [
                        const Icon(Icons.lightbulb_outline, size: 14, color: AppColors.cream),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            day.tips,
                            style: const TextStyle(fontSize: 12, color: AppColors.textSecondary, fontStyle: FontStyle.italic),
                          ),
                        ),
                      ],
                    ),
                  ],
                ],
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildExerciseRow(Exercise exercise) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5),
      child: Row(
        children: [
          Expanded(
            flex: 3,
            child: Text(exercise.name, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: AppColors.textPrimary)),
          ),
          Expanded(
            flex: 2,
            child: Text(
              '${exercise.sets} × ${exercise.reps}',
              style: const TextStyle(fontSize: 12, color: AppColors.textSecondary),
              textAlign: TextAlign.center,
            ),
          ),
          Expanded(
            flex: 2,
            child: Text(
              '休息${exercise.rest}',
              style: const TextStyle(fontSize: 11, color: AppColors.textHint),
              textAlign: TextAlign.right,
            ),
          ),
        ],
      ),
    );
  }
}
