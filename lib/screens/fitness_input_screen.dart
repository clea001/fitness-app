import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/api_provider.dart';
import '../providers/plan_provider.dart';
import '../models/user_profile.dart';
import '../theme/app_theme.dart';

class FitnessInputScreen extends StatefulWidget {
  const FitnessInputScreen({super.key});

  @override
  State<FitnessInputScreen> createState() => _FitnessInputScreenState();
}

class _FitnessInputScreenState extends State<FitnessInputScreen> {
  final _controller = TextEditingController();
  String _selectedGoal = '减脂塑形';
  String _selectedLevel = '初学者';
  String _selectedDays = '3-4天';
  String _selectedTime = '30-60分钟';

  final _goals = ['减脂塑形', '增肌增重', '提升体能', '保持健康', '康复训练'];
  final _levels = ['初学者', '有一定基础', '进阶训练者', '高级训练者'];
  final _days = ['1-2天', '3-4天', '5-6天', '每天'];
  final _times = ['30分钟以内', '30-60分钟', '60-90分钟', '90分钟以上'];

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _generate() async {
    final apiProvider = context.read<ApiProvider>();
    if (!apiProvider.isConfigured) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('请先配置 API'), backgroundColor: AppColors.primary),
      );
      return;
    }

    final profile = await UserProfile.load();
    final request = StringBuffer();
    request.writeln('请为我制定一份每周健身计划：');
    request.writeln('- 健身目标：$_selectedGoal');
    request.writeln('- 训练水平：$_selectedLevel');
    request.writeln('- 每周训练天数：$_selectedDays');
    request.writeln('- 每次训练时长：$_selectedTime');
    if (_controller.text.isNotEmpty) {
      request.writeln('- 其他需求：${_controller.text}');
    }

    context.read<PlanProvider>().generateFitnessPlan(
      apiProvider.planGenerator!,
      request.toString(),
      userProfile: profile.toPromptString(),
    );

    Navigator.pushNamed(context, '/fitness-result');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('健身计划')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 顶部图标
            Center(
              child: Container(
                width: 72,
                height: 72,
                decoration: BoxDecoration(
                  color: AppColors.primaryLight,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: const Icon(Icons.fitness_center_rounded, size: 36, color: AppColors.primary),
              ),
            ),
            const SizedBox(height: 24),

            _buildSectionTitle('健身目标'),
            const SizedBox(height: 10),
            _buildChipWrap(_goals, _selectedGoal, (v) => setState(() => _selectedGoal = v)),
            const SizedBox(height: 20),

            _buildSectionTitle('训练水平'),
            const SizedBox(height: 10),
            _buildChipWrap(_levels, _selectedLevel, (v) => setState(() => _selectedLevel = v)),
            const SizedBox(height: 20),

            _buildSectionTitle('每周训练天数'),
            const SizedBox(height: 10),
            _buildChipWrap(_days, _selectedDays, (v) => setState(() => _selectedDays = v)),
            const SizedBox(height: 20),

            _buildSectionTitle('每次训练时长'),
            const SizedBox(height: 10),
            _buildChipWrap(_times, _selectedTime, (v) => setState(() => _selectedTime = v)),
            const SizedBox(height: 20),

            _buildSectionTitle('其他需求（可选）'),
            const SizedBox(height: 10),
            TextFormField(
              controller: _controller,
              maxLines: 3,
              decoration: const InputDecoration(hintText: '例如：膝盖有伤，避免深蹲类动作'),
            ),
            const SizedBox(height: 28),

            SizedBox(
              width: double.infinity,
              child: Consumer<PlanProvider>(
                builder: (context, planProvider, _) {
                  return ElevatedButton.icon(
                    onPressed: planProvider.isGenerating ? null : _generate,
                    icon: planProvider.isGenerating
                        ? const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                        : const Icon(Icons.auto_awesome_rounded),
                    label: Text(planProvider.isGenerating ? '生成中...' : '✨ 生成健身计划'),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: AppColors.textPrimary),
    );
  }

  Widget _buildChipWrap(List<String> options, String selected, ValueChanged<String> onSelected) {
    return Wrap(
      spacing: 10,
      runSpacing: 10,
      children: options.map((option) {
        final isSelected = option == selected;
        return ChoiceChip(
          label: Text(option),
          selected: isSelected,
          onSelected: (_) => onSelected(option),
          selectedColor: AppColors.primary,
          backgroundColor: Colors.white,
          labelStyle: TextStyle(
            color: isSelected ? Colors.white : AppColors.textSecondary,
            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
          ),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          side: BorderSide(color: isSelected ? AppColors.primary : AppColors.divider),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        );
      }).toList(),
    );
  }
}
