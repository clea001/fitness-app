import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/api_provider.dart';
import '../theme/app_theme.dart';

class ApiSettingsScreen extends StatelessWidget {
  const ApiSettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final config = context.read<ApiProvider>().config;

    return Scaffold(
      appBar: AppBar(title: const Text('设置')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: AppColors.mint.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Row(
                children: [
                  Icon(Icons.check_circle_outline, color: AppColors.mint, size: 20),
                  SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      'API 已内置配置，开箱即用',
                      style: TextStyle(fontSize: 12, color: AppColors.textBody),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            _buildInfoCard([
              _buildInfoRow('API 地址', config.baseUrl),
              const Divider(color: AppColors.divider, height: 1),
              _buildInfoRow('对话模型', config.model),
              const Divider(color: AppColors.divider, height: 1),
              _buildInfoRow('状态', config.isConfigured ? '已配置' : '未配置'),
            ]),
            const SizedBox(height: 24),

            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: AppColors.background,
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('使用说明', style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: AppColors.textPrimary)),
                  SizedBox(height: 8),
                  Text('1. 首页生成健身/饮食计划', style: TextStyle(fontSize: 12, color: AppColors.textBody)),
                  SizedBox(height: 4),
                  Text('2. 日历查看每日计划和卡路里', style: TextStyle(fontSize: 12, color: AppColors.textBody)),
                  SizedBox(height: 4),
                  Text('3. 菜谱板块查看今日菜品做法', style: TextStyle(fontSize: 12, color: AppColors.textBody)),
                  SizedBox(height: 4),
                  Text('4. 我的页面配置个人信息', style: TextStyle(fontSize: 12, color: AppColors.textBody)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
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

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      child: Row(
        children: [
          Text(label, style: const TextStyle(fontSize: 13, color: AppColors.textSecondary)),
          const Spacer(),
          Flexible(
            child: Text(
              value,
              style: const TextStyle(fontSize: 13, color: AppColors.textPrimary, fontWeight: FontWeight.w500),
              textAlign: TextAlign.right,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }
}
