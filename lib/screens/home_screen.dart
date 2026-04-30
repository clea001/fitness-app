import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/api_provider.dart';
import '../theme/app_theme.dart';
import '../widgets/update_dialog.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      UpdateDialog.showIfNeeded(context);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 问候区域
              _buildGreeting(),
              const SizedBox(height: 24),

              // API 状态提示
              Consumer<ApiProvider>(
                builder: (context, apiProvider, _) {
                  if (!apiProvider.isConfigured) {
                    return _buildApiWarning(context);
                  }
                  return const SizedBox.shrink();
                },
              ),

              // 今日进度卡片
              _buildTodayCard(context),
              const SizedBox(height: 20),

              // 功能入口
              _buildSectionTitle('快捷功能'),
              const SizedBox(height: 12),
              _buildQuickActions(context),
              const SizedBox(height: 20),

              // 功能卡片
              _buildSectionTitle('AI 计划生成'),
              const SizedBox(height: 12),
              _buildFeatureCard(
                context,
                icon: Icons.directions_run_rounded,
                title: '生成健身计划',
                subtitle: '根据你的目标定制每周训练方案',
                color: AppColors.primary,
                onTap: () => Navigator.pushNamed(context, '/fitness-input'),
              ),
              const SizedBox(height: 12),
              _buildFeatureCard(
                context,
                icon: Icons.restaurant_rounded,
                title: '生成饮食计划',
                subtitle: '科学搭配营养，健康饮食',
                color: AppColors.mint,
                onTap: () => Navigator.pushNamed(context, '/diet-input'),
              ),
              const SizedBox(height: 20),

              // 底部提示
              _buildBottomTip(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildGreeting() {
    final hour = DateTime.now().hour;
    String greeting;
    if (hour < 12) {
      greeting = '早上好';
    } else if (hour < 18) {
      greeting = '下午好';
    } else {
      greeting = '晚上好';
    }

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Hi~ $greeting 💕',
              style: const TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 4),
            const Text(
              '今天也要元气满满哦',
              style: TextStyle(
                fontSize: 13,
                color: AppColors.textHint,
              ),
            ),
          ],
        ),
        Container(
          width: 44,
          height: 44,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(color: AppColors.primaryLight, width: 2),
            color: AppColors.primaryLight,
          ),
          child: const Icon(
            Icons.person_rounded,
            color: AppColors.primary,
            size: 24,
          ),
        ),
      ],
    );
  }

  Widget _buildApiWarning(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 20),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFFFF3CD),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          const Icon(Icons.warning_amber_rounded, color: Color(0xFFFF6B35)),
          const SizedBox(width: 12),
          const Expanded(
            child: Text(
              '请先配置 API 才能使用',
              style: TextStyle(color: Color(0xFF856404)),
            ),
          ),
          TextButton(
            onPressed: () => Navigator.pushNamed(context, '/settings'),
            child: const Text('去配置'),
          ),
        ],
      ),
    );
  }

  Widget _buildTodayCard(BuildContext context) {
    final now = DateTime.now();
    final weekdays = ['周一', '周二', '周三', '周四', '周五', '周六', '周日'];
    final weekday = weekdays[now.weekday - 1];

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '${now.month}月${now.day}日 $weekday',
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textPrimary,
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: AppColors.primaryLight,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Text(
                  '今天',
                  style: TextStyle(
                    fontSize: 12,
                    color: AppColors.primaryDark,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          // 进度条
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: 0.38,
              minHeight: 8,
              backgroundColor: AppColors.divider,
              valueColor: AlwaysStoppedAnimation<Color>(AppColors.primary),
            ),
          ),
          const SizedBox(height: 12),
          const Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('今日进度', style: TextStyle(fontSize: 13, color: AppColors.textSecondary)),
              Text('38%', style: TextStyle(fontSize: 13, color: AppColors.primaryDark, fontWeight: FontWeight.w600)),
            ],
          ),
          const SizedBox(height: 16),
          // 体重信息
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.background,
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                Column(
                  children: [
                    Text('目标体重', style: TextStyle(fontSize: 11, color: AppColors.textSecondary)),
                    SizedBox(height: 4),
                    Text('48 kg', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppColors.textPrimary)),
                  ],
                ),
                SizedBox(width: 1, height: 30, child: ColoredBox(color: AppColors.divider)),
                Column(
                  children: [
                    Text('当前体重', style: TextStyle(fontSize: 11, color: AppColors.textSecondary)),
                    SizedBox(height: 4),
                    Text('52.5 kg', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppColors.primaryDark)),
                  ],
                ),
                SizedBox(width: 1, height: 30, child: ColoredBox(color: AppColors.divider)),
                Column(
                  children: [
                    Text('已减重', style: TextStyle(fontSize: 11, color: AppColors.textSecondary)),
                    SizedBox(height: 4),
                    Text('-2.5 kg', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppColors.mint)),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: const TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.bold,
        color: AppColors.textPrimary,
      ),
    );
  }

  Widget _buildQuickActions(BuildContext context) {
    return Row(
      children: [
        _buildActionItem(
          icon: Icons.restaurant_rounded,
          label: '记录饮食',
          color: AppColors.primary,
          onTap: () => Navigator.pushNamed(context, '/diet-input'),
        ),
        const SizedBox(width: 12),
        _buildActionItem(
          icon: Icons.fitness_center_rounded,
          label: '记录运动',
          color: AppColors.lavender,
          onTap: () => Navigator.pushNamed(context, '/fitness-input'),
        ),
        const SizedBox(width: 12),
        _buildActionItem(
          icon: Icons.calendar_month_rounded,
          label: '打卡日历',
          color: AppColors.sky,
          onTap: () => Navigator.pushNamed(context, '/calendar'),
        ),
        const SizedBox(width: 12),
        _buildActionItem(
          icon: Icons.bar_chart_rounded,
          label: '本周报告',
          color: AppColors.cream,
          onTap: () {},
        ),
      ],
    );
  }

  Widget _buildActionItem({
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onTap,
  }) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: Column(
          children: [
            Container(
              width: 56,
              height: 56,
              decoration: BoxDecoration(
                color: color.withOpacity(0.15),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: color, size: 24),
            ),
            const SizedBox(height: 8),
            Text(
              label,
              style: const TextStyle(fontSize: 12, color: AppColors.textBody),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFeatureCard(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String subtitle,
    required Color color,
    required VoidCallback onTap,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.04),
                blurRadius: 12,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Row(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: color.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Icon(icon, color: color, size: 24),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      subtitle,
                      style: const TextStyle(
                        fontSize: 13,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
              const Icon(
                Icons.arrow_forward_ios_rounded,
                size: 16,
                color: AppColors.textSecondary,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildBottomTip() {
    return Center(
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              color: AppColors.primaryLight,
              borderRadius: BorderRadius.circular(20),
            ),
            child: const Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.smart_toy_rounded, size: 14, color: AppColors.primary),
                SizedBox(width: 6),
                Text(
                  '默认使用 MiMo 大模型',
                  style: TextStyle(
                    fontSize: 11,
                    color: AppColors.primaryDark,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 6),
          const Text(
            '支持 DeepSeek / ChatGPT / 通义千问 等 OpenAI 兼容接口',
            style: TextStyle(fontSize: 10, color: AppColors.textHint),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}
