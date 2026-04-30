import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/api_provider.dart';
import '../providers/plan_provider.dart';
import '../models/user_profile.dart';
import '../theme/app_theme.dart';

class DietInputScreen extends StatefulWidget {
  const DietInputScreen({super.key});

  @override
  State<DietInputScreen> createState() => _DietInputScreenState();
}

class _DietInputScreenState extends State<DietInputScreen> {
  final _controller = TextEditingController();
  String _selectedGoal = '减脂';
  String _selectedDiet = '普通饮食';
  String _selectedCalorie = '1500-1800大卡';
  String _selectedAllergy = '无';

  final _goals = ['减脂', '增肌', '维持体重', '改善体质'];
  final _diets = ['普通饮食', '低碳水', '高蛋白', '素食', '地中海饮食'];
  final _calories = ['1200-1500大卡', '1500-1800大卡', '1800-2200大卡', '2200大卡以上'];
  final _allergies = ['无', '乳糖不耐', '坚果过敏', '海鲜过敏', '麸质过敏'];

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _generate() async {
    final apiProvider = context.read<ApiProvider>();
    if (!apiProvider.isConfigured) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('请先配置 API'), backgroundColor: AppColors.mint),
      );
      return;
    }

    final profile = await UserProfile.load();
    final request = StringBuffer();
    request.writeln('请为我制定一份每日饮食计划：');
    request.writeln('- 饮食目标：$_selectedGoal');
    request.writeln('- 饮食类型：$_selectedDiet');
    request.writeln('- 每日热量：$_selectedCalorie');
    request.writeln('- 过敏/限制：$_selectedAllergy');
    if (_controller.text.isNotEmpty) {
      request.writeln('- 其他需求：${_controller.text}');
    }

    context.read<PlanProvider>().generateDietPlan(
      apiProvider.planGenerator!,
      request.toString(),
      userProfile: profile.toPromptString(),
    );

    Navigator.pushNamed(context, '/diet-result');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('饮食计划')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 72,
                height: 72,
                decoration: BoxDecoration(
                  color: AppColors.mint.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: const Icon(Icons.restaurant_rounded, size: 36, color: AppColors.mint),
              ),
            ),
            const SizedBox(height: 24),

            _buildSectionTitle('饮食目标'),
            const SizedBox(height: 10),
            _buildChipWrap(_goals, _selectedGoal, (v) => setState(() => _selectedGoal = v)),
            const SizedBox(height: 20),

            _buildSectionTitle('饮食类型'),
            const SizedBox(height: 10),
            _buildChipWrap(_diets, _selectedDiet, (v) => setState(() => _selectedDiet = v)),
            const SizedBox(height: 20),

            _buildSectionTitle('每日热量'),
            const SizedBox(height: 10),
            _buildChipWrap(_calories, _selectedCalorie, (v) => setState(() => _selectedCalorie = v)),
            const SizedBox(height: 20),

            _buildSectionTitle('过敏/饮食限制'),
            const SizedBox(height: 10),
            _buildChipWrap(_allergies, _selectedAllergy, (v) => setState(() => _selectedAllergy = v)),
            const SizedBox(height: 20),

            _buildSectionTitle('其他需求（可选）'),
            const SizedBox(height: 10),
            TextFormField(
              controller: _controller,
              maxLines: 3,
              decoration: const InputDecoration(hintText: '例如：希望多一些中式家常菜，方便准备'),
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
                    label: Text(planProvider.isGenerating ? '生成中...' : '🥗 生成饮食计划'),
                    style: ElevatedButton.styleFrom(backgroundColor: AppColors.mint),
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
          selectedColor: AppColors.mint,
          backgroundColor: Colors.white,
          labelStyle: TextStyle(
            color: isSelected ? Colors.white : AppColors.textSecondary,
            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
          ),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          side: BorderSide(color: isSelected ? AppColors.mint : AppColors.divider),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        );
      }).toList(),
    );
  }
}
