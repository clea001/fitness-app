import 'package:flutter/material.dart';
import 'package:screenshot/screenshot.dart';
import '../models/fitness_plan.dart';
import '../models/diet_plan.dart';
import '../services/image_export_service.dart';
import '../theme/app_theme.dart';

class ExportScreen extends StatefulWidget {
  final String planType;
  final FitnessPlan? fitnessPlan;
  final DietPlan? dietPlan;

  const ExportScreen({
    super.key,
    required this.planType,
    this.fitnessPlan,
    this.dietPlan,
  });

  @override
  State<ExportScreen> createState() => _ExportScreenState();
}

class _ExportScreenState extends State<ExportScreen> {
  int _selectedTemplate = 0;
  final ScreenshotController _screenshotController = ScreenshotController();
  bool _isSaving = false;

  Future<void> _saveImage() async {
    setState(() => _isSaving = true);
    try {
      final imageBytes = await _screenshotController.capture();
      if (imageBytes == null) throw Exception('截图失败');

      final service = ImageExportService();
      final name = DateTime.now().millisecondsSinceEpoch.toString();
      await service.saveToGallery(imageBytes, name);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('已保存到相册'),
            backgroundColor: AppColors.mint,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('保存失败: $e'), backgroundColor: AppColors.primary),
        );
      }
    } finally {
      setState(() => _isSaving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final templates = ImageExportService.templates;
    final currentTemplate = templates[_selectedTemplate];

    return Scaffold(
      appBar: AppBar(
        title: const Text('导出图片'),
        actions: [
          TextButton.icon(
            onPressed: _isSaving ? null : _saveImage,
            icon: _isSaving
                ? const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2))
                : const Icon(Icons.save_alt_rounded),
            label: Text(_isSaving ? '保存中' : '保存'),
          ),
        ],
      ),
      body: Column(
        children: [
          SizedBox(
            height: 70,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              itemCount: templates.length,
              itemBuilder: (context, index) {
                final t = templates[index];
                final isSelected = index == _selectedTemplate;
                return GestureDetector(
                  onTap: () => setState(() => _selectedTemplate = index),
                  child: Container(
                    width: 72,
                    margin: const EdgeInsets.only(right: 10),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(colors: t.gradient),
                      borderRadius: BorderRadius.circular(12),
                      border: isSelected ? Border.all(color: AppColors.textPrimary, width: 2.5) : null,
                      boxShadow: isSelected ? [BoxShadow(color: t.gradient[0].withOpacity(0.3), blurRadius: 8, offset: const Offset(0, 3))] : null,
                    ),
                    child: Center(
                      child: Text(t.name, style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Colors.white)),
                    ),
                  ),
                );
              },
            ),
          ),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Screenshot(
                controller: _screenshotController,
                child: Container(
                  width: double.infinity,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(colors: currentTemplate.gradient, begin: Alignment.topLeft, end: Alignment.bottomRight),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(24),
                    child: widget.planType == 'fitness' ? _buildFitnessExport() : _buildDietExport(),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFitnessExport() {
    final plan = widget.fitnessPlan!;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Center(
          child: Column(
            children: [
              const Text('💪', style: TextStyle(fontSize: 36)),
              const SizedBox(height: 8),
              const Text('我的健身计划', style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.white)),
              const SizedBox(height: 4),
              Text(plan.goal, style: TextStyle(fontSize: 13, color: Colors.white.withOpacity(0.8))),
            ],
          ),
        ),
        const SizedBox(height: 8),
        Center(child: Text(plan.summary, textAlign: TextAlign.center, style: TextStyle(fontSize: 11, color: Colors.white.withOpacity(0.7)))),
        const SizedBox(height: 20),
        ...plan.days.map((day) => Container(
              margin: const EdgeInsets.only(bottom: 10),
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(color: Colors.white.withOpacity(0.15), borderRadius: BorderRadius.circular(12)),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(children: [
                    Text(day.day, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.white)),
                    const SizedBox(width: 8),
                    Text(day.focus, style: TextStyle(fontSize: 12, color: Colors.white.withOpacity(0.8))),
                  ]),
                  if (day.exercises.isNotEmpty) ...[
                    const SizedBox(height: 8),
                    ...day.exercises.map((e) => Padding(
                          padding: const EdgeInsets.only(bottom: 3),
                          child: Row(children: [
                            Expanded(child: Text('• ${e.name}', style: TextStyle(fontSize: 11, color: Colors.white.withOpacity(0.9)))),
                            Text('${e.sets}×${e.reps}', style: TextStyle(fontSize: 11, color: Colors.white.withOpacity(0.7))),
                          ]),
                        )),
                  ] else
                    Text('休息日 😴', style: TextStyle(fontSize: 11, color: Colors.white.withOpacity(0.7))),
                ],
              ),
            )),
        const SizedBox(height: 12),
        Center(child: Text('由 AI 健身助手生成', style: TextStyle(fontSize: 10, color: Colors.white.withOpacity(0.5)))),
      ],
    );
  }

  Widget _buildDietExport() {
    final plan = widget.dietPlan!;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Center(
          child: Column(
            children: [
              const Text('🥗', style: TextStyle(fontSize: 36)),
              const SizedBox(height: 8),
              const Text('我的饮食计划', style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.white)),
              const SizedBox(height: 4),
              Text(plan.goal, style: TextStyle(fontSize: 13, color: Colors.white.withOpacity(0.8))),
              if (plan.dailyCalories.isNotEmpty) ...[
                const SizedBox(height: 4),
                Text('🔥 ${plan.dailyCalories}', style: TextStyle(fontSize: 11, color: Colors.white.withOpacity(0.7))),
              ],
            ],
          ),
        ),
        const SizedBox(height: 8),
        Center(child: Text(plan.summary, textAlign: TextAlign.center, style: TextStyle(fontSize: 11, color: Colors.white.withOpacity(0.7)))),
        const SizedBox(height: 20),
        ...plan.meals.map((meal) => Container(
              margin: const EdgeInsets.only(bottom: 10),
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(color: Colors.white.withOpacity(0.15), borderRadius: BorderRadius.circular(12)),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(children: [
                    Text(meal.mealType, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.white)),
                    const Spacer(),
                    if (meal.calories.isNotEmpty) Text(meal.calories, style: TextStyle(fontSize: 11, color: Colors.white.withOpacity(0.7))),
                  ]),
                  const SizedBox(height: 6),
                  Text(meal.menu, style: TextStyle(fontSize: 12, color: Colors.white.withOpacity(0.9))),
                  if (meal.items.isNotEmpty) ...[
                    const SizedBox(height: 6),
                    Wrap(
                      spacing: 6,
                      runSpacing: 4,
                      children: meal.items.map((item) => Text('• $item', style: TextStyle(fontSize: 10, color: Colors.white.withOpacity(0.7)))).toList(),
                    ),
                  ],
                ],
              ),
            )),
        const SizedBox(height: 12),
        Center(child: Text('由 AI 健身助手生成', style: TextStyle(fontSize: 10, color: Colors.white.withOpacity(0.5)))),
      ],
    );
  }
}
