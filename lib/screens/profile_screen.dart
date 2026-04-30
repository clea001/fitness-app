import 'package:flutter/material.dart';
import '../models/user_profile.dart';
import '../theme/app_theme.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  late UserProfile _profile;
  bool _isLoading = true;

  final _goals = ['减脂塑形', '增肌增重', '提升体能', '保持健康', '改善体态'];
  final _allergies = ['乳糖不耐', '坚果过敏', '海鲜过敏', '麸质过敏', '鸡蛋过敏', '大豆过敏'];
  final _equipment = ['哑铃', '杠铃', '弹力带', '瑜伽垫', '跑步机', '动感单车', '引体向上杆', '壶铃', '跳绳'];
  final _courses = ['瑜伽课', '搏击操', '动感单车', '游泳课', '普拉提', '舞蹈课', 'CrossFit'];

  @override
  void initState() {
    super.initState();
    _loadProfile();
  }

  Future<void> _loadProfile() async {
    final profile = await UserProfile.load();
    setState(() {
      _profile = profile;
      _isLoading = false;
    });
  }

  Future<void> _save() async {
    await _profile.save();
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('个人信息已保存'),
          backgroundColor: AppColors.mint,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
      );
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator(color: AppColors.primary)));
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('个人信息'),
        actions: [
          TextButton(
            onPressed: _save,
            child: const Text('保存', style: TextStyle(color: AppColors.primary, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 头像区域
            Center(
              child: Column(
                children: [
                  Container(
                    width: 80,
                    height: 80,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: AppColors.primaryLight,
                      border: Border.all(color: AppColors.primary, width: 2),
                    ),
                    child: const Icon(Icons.person_rounded, size: 40, color: AppColors.primary),
                  ),
                  const SizedBox(height: 12),
                  SizedBox(
                    width: 160,
                    child: TextField(
                      textAlign: TextAlign.center,
                      decoration: const InputDecoration(
                        hintText: '输入昵称',
                        border: InputBorder.none,
                        hintStyle: TextStyle(color: AppColors.textHint),
                      ),
                      style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppColors.textPrimary),
                      onChanged: (v) => _profile.nickname = v,
                      controller: TextEditingController(text: _profile.nickname),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // 基础信息
            _buildSectionTitle('基础信息'),
            const SizedBox(height: 12),
            _buildInfoCard([
              _buildGenderSelector(),
              const Divider(color: AppColors.divider, height: 1),
              _buildNumberRow('年龄', _profile.age, '岁', (v) => setState(() => _profile.age = v), 10, 80),
              const Divider(color: AppColors.divider, height: 1),
              _buildNumberRow('身高', _profile.height.toInt(), 'cm', (v) => setState(() => _profile.height = v.toDouble()), 100, 220),
              const Divider(color: AppColors.divider, height: 1),
              _buildNumberRow('体重', _profile.weight.toInt(), 'kg', (v) => setState(() => _profile.weight = v.toDouble()), 30, 150),
              const Divider(color: AppColors.divider, height: 1),
              _buildBmiDisplay(),
            ]),
            const SizedBox(height: 20),

            // 训练水平
            _buildSectionTitle('训练水平'),
            const SizedBox(height: 10),
            _buildChipWrap(['初学者', '有基础', '进阶'], _profile.fitnessLevel, (v) => setState(() => _profile.fitnessLevel = v)),
            const SizedBox(height: 20),

            // 健身目标
            _buildSectionTitle('健身目标（可多选）'),
            const SizedBox(height: 10),
            _buildMultiChipWrap(_goals, _profile.goals, (v) => setState(() {
              if (_profile.goals.contains(v)) {
                _profile.goals = _profile.goals.where((g) => g != v).toList();
              } else {
                _profile.goals = [..._profile.goals, v];
              }
            })),
            const SizedBox(height: 20),

            // 忌口/过敏
            _buildSectionTitle('饮食忌口/过敏（可多选）'),
            const SizedBox(height: 10),
            _buildMultiChipWrap(_allergies, _profile.allergies, (v) => setState(() {
              if (_profile.allergies.contains(v)) {
                _profile.allergies = _profile.allergies.where((a) => a != v).toList();
              } else {
                _profile.allergies = [..._profile.allergies, v];
              }
            })),
            const SizedBox(height: 20),

            // 身边器材
            _buildSectionTitle('身边可用器材（可多选）'),
            const SizedBox(height: 10),
            _buildMultiChipWrap(_equipment, _profile.equipment, (v) => setState(() {
              if (_profile.equipment.contains(v)) {
                _profile.equipment = _profile.equipment.where((e) => e != v).toList();
              } else {
                _profile.equipment = [..._profile.equipment, v];
              }
            })),
            const SizedBox(height: 20),

            // 已报课程
            _buildSectionTitle('已报课程（可多选）'),
            const SizedBox(height: 10),
            _buildMultiChipWrap(_courses, _profile.courses, (v) => setState(() {
              if (_profile.courses.contains(v)) {
                _profile.courses = _profile.courses.where((c) => c != v).toList();
              } else {
                _profile.courses = [..._profile.courses, v];
              }
            })),
            const SizedBox(height: 20),

            // 健康备注
            _buildSectionTitle('健康备注'),
            const SizedBox(height: 10),
            TextField(
              maxLines: 3,
              decoration: const InputDecoration(hintText: '如有伤病、特殊身体状况请备注'),
              controller: TextEditingController(text: _profile.healthNotes),
              onChanged: (v) => _profile.healthNotes = v,
            ),
            const SizedBox(height: 32),

            // 保存按钮
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: _save,
                icon: const Icon(Icons.save_rounded),
                label: const Text('保存个人信息'),
              ),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(title, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: AppColors.textPrimary));
  }

  Widget _buildInfoCard(List<Widget> children) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 10, offset: const Offset(0, 3))],
      ),
      child: Column(children: children),
    );
  }

  Widget _buildGenderSelector() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      child: Row(
        children: [
          const Text('性别', style: TextStyle(fontSize: 14, color: AppColors.textBody)),
          const Spacer(),
          ...['女', '男', '不限'].map((g) {
            final isSelected = _profile.gender == g;
            return GestureDetector(
              onTap: () => setState(() => _profile.gender = g),
              child: Container(
                margin: const EdgeInsets.only(left: 8),
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                decoration: BoxDecoration(
                  color: isSelected ? AppColors.primary : AppColors.background,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Text(g, style: TextStyle(fontSize: 13, color: isSelected ? Colors.white : AppColors.textSecondary, fontWeight: isSelected ? FontWeight.bold : FontWeight.normal)),
              ),
            );
          }),
        ],
      ),
    );
  }

  Widget _buildNumberRow(String label, int value, String unit, ValueChanged<int> onChanged, int min, int max) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      child: Row(
        children: [
          Text(label, style: const TextStyle(fontSize: 14, color: AppColors.textBody)),
          const Spacer(),
          GestureDetector(
            onTap: value > min ? () => onChanged(value - 1) : null,
            child: Container(
              width: 32, height: 32,
              decoration: BoxDecoration(color: AppColors.background, borderRadius: BorderRadius.circular(8)),
              child: const Icon(Icons.remove, size: 18, color: AppColors.textSecondary),
            ),
          ),
          SizedBox(
            width: 60,
            child: Text(
              '$value',
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.primaryDark),
            ),
          ),
          Text(unit, style: const TextStyle(fontSize: 12, color: AppColors.textHint)),
          GestureDetector(
            onTap: value < max ? () => onChanged(value + 1) : null,
            child: Container(
              width: 32, height: 32,
              decoration: BoxDecoration(color: AppColors.background, borderRadius: BorderRadius.circular(8)),
              child: const Icon(Icons.add, size: 18, color: AppColors.textSecondary),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBmiDisplay() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      child: Row(
        children: [
          const Text('BMI', style: TextStyle(fontSize: 14, color: AppColors.textBody)),
          const Spacer(),
          Text(
            _profile.bmi.toStringAsFixed(1),
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.primaryDark),
          ),
          const SizedBox(width: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
            decoration: BoxDecoration(
              color: _bmiColor.withOpacity(0.15),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(_profile.bmiLevel, style: TextStyle(fontSize: 12, color: _bmiColor, fontWeight: FontWeight.w600)),
          ),
        ],
      ),
    );
  }

  Color get _bmiColor {
    if (_profile.bmi < 18.5) return AppColors.sky;
    if (_profile.bmi < 24) return AppColors.mint;
    if (_profile.bmi < 28) return AppColors.primary;
    return AppColors.primaryDark;
  }

  Widget _buildChipWrap(List<String> options, String selected, ValueChanged<String> onSelected) {
    return Wrap(
      spacing: 10, runSpacing: 10,
      children: options.map((option) {
        final isSelected = option == selected;
        return ChoiceChip(
          label: Text(option),
          selected: isSelected,
          onSelected: (_) => onSelected(option),
          selectedColor: AppColors.primary,
          backgroundColor: Colors.white,
          labelStyle: TextStyle(color: isSelected ? Colors.white : AppColors.textSecondary, fontWeight: isSelected ? FontWeight.bold : FontWeight.normal),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          side: BorderSide(color: isSelected ? AppColors.primary : AppColors.divider),
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        );
      }).toList(),
    );
  }

  Widget _buildMultiChipWrap(List<String> options, List<String> selected, ValueChanged<String> onSelected) {
    return Wrap(
      spacing: 10, runSpacing: 10,
      children: options.map((option) {
        final isSelected = selected.contains(option);
        return FilterChip(
          label: Text(option),
          selected: isSelected,
          onSelected: (_) => onSelected(option),
          selectedColor: AppColors.primary,
          backgroundColor: Colors.white,
          labelStyle: TextStyle(color: isSelected ? Colors.white : AppColors.textSecondary, fontWeight: isSelected ? FontWeight.bold : FontWeight.normal),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          side: BorderSide(color: isSelected ? AppColors.primary : AppColors.divider),
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
          showCheckmark: false,
        );
      }).toList(),
    );
  }
}
