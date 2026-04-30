import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/plan_provider.dart';
import '../providers/calendar_provider.dart';
import '../models/diet_plan.dart';
import '../services/storage_service.dart';
import '../theme/app_theme.dart';
import 'export_screen.dart';

class DietResultScreen extends StatefulWidget {
  const DietResultScreen({super.key});

  @override
  State<DietResultScreen> createState() => _DietResultScreenState();
}

class _DietResultScreenState extends State<DietResultScreen> {
  bool _saved = false;

  Future<void> _savePlan(DietPlan plan) async {
    await StorageService.saveDietPlan(plan);
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
        title: const Text('饮食计划'),
        actions: [
          Consumer<PlanProvider>(
            builder: (context, provider, _) {
              if (provider.dietPlan != null &&
                  provider.dietPlan!.meals.isNotEmpty) {
                if (!_saved) {
                  _saved = true;
                  WidgetsBinding.instance.addPostFrameCallback((_) {
                    _savePlan(provider.dietPlan!);
                  });
                }
                return IconButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => ExportScreen(
                          planType: 'diet',
                          dietPlan: provider.dietPlan,
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
          final plan = provider.dietPlan;
          if (plan == null || plan.meals.isEmpty) return _buildEmpty();
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
            decoration: const BoxDecoration(
              color: AppColors.mint,
              shape: BoxShape.circle,
            ),
            child: const Center(
              child: CircularProgressIndicator(color: Colors.white, strokeWidth: 3),
            ),
          ),
          const SizedBox(height: 20),
          const Text(
            '正在为你定制饮食计划...',
            style: TextStyle(fontSize: 16, color: AppColors.textSecondary),
          ),
          const SizedBox(height: 8),
          const Text(
            'AI 营养师正在思考中 🥗',
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
            const Icon(Icons.error_outline_rounded, size: 56, color: AppColors.mint),
            const SizedBox(height: 16),
            const Text('生成失败', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.textPrimary)),
            const SizedBox(height: 8),
            Text(error, textAlign: TextAlign.center, style: const TextStyle(color: AppColors.textSecondary)),
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
          Text('🥗', style: TextStyle(fontSize: 48)),
          SizedBox(height: 12),
          Text('暂无计划', style: TextStyle(fontSize: 16, color: AppColors.textHint)),
          SizedBox(height: 4),
          Text('去生成一个饮食计划吧~', style: TextStyle(fontSize: 13, color: AppColors.textHint)),
        ],
      ),
    );
  }

  Widget _buildPlan(BuildContext context, DietPlan plan) {
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
                colors: [AppColors.mint, Color(0xFF44B09E)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '🥗 ${plan.goal}',
                  style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white),
                ),
                const SizedBox(height: 8),
                Text(
                  plan.summary,
                  style: TextStyle(fontSize: 13, color: Colors.white.withOpacity(0.9)),
                ),
                if (plan.dailyCalories.isNotEmpty) ...[
                  const SizedBox(height: 12),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Text(
                      '🔥 ${plan.dailyCalories}',
                      style: const TextStyle(fontSize: 12, color: Colors.white, fontWeight: FontWeight.w600),
                    ),
                  ),
                ],
              ],
            ),
          ),
          const SizedBox(height: 20),

          // 每餐计划
          ...plan.meals.map((meal) => _buildMealCard(meal)),
        ],
      ),
    );
  }

  Widget _buildMealCard(MealPlan meal) {
    final mealIcons = {
      '早餐': '☀️',
      '午餐': '🌤',
      '晚餐': '🌙',
      '加餐': '🍎',
    };

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
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
          Row(
            children: [
              Text(mealIcons[meal.mealType] ?? '🍽️', style: const TextStyle(fontSize: 20)),
              const SizedBox(width: 10),
              Text(
                meal.mealType,
                style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppColors.textPrimary),
              ),
              const Spacer(),
              if (meal.calories.isNotEmpty)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: AppColors.primaryLight,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    meal.calories,
                    style: const TextStyle(fontSize: 11, color: AppColors.primaryDark, fontWeight: FontWeight.w600),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            meal.menu,
            style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: AppColors.textBody),
          ),
          if (meal.items.isNotEmpty) ...[
            const SizedBox(height: 10),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: meal.items
                  .map((item) => Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color: AppColors.background,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Text(item, style: const TextStyle(fontSize: 12, color: AppColors.textSecondary)),
                      ))
                  .toList(),
            ),
          ],
          if (meal.tips.isNotEmpty) ...[
            const SizedBox(height: 12),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Icon(Icons.tips_and_updates_outlined, size: 14, color: AppColors.cream),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    meal.tips,
                    style: const TextStyle(fontSize: 12, color: AppColors.textSecondary, fontStyle: FontStyle.italic),
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }
}
