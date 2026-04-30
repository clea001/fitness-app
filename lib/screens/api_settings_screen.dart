import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/api_provider.dart';
import '../theme/app_theme.dart';

class ApiSettingsScreen extends StatefulWidget {
  const ApiSettingsScreen({super.key});

  @override
  State<ApiSettingsScreen> createState() => _ApiSettingsScreenState();
}

class _ApiSettingsScreenState extends State<ApiSettingsScreen> {
  bool _isTesting = false;
  String? _testResult;

  Future<void> _testConnection() async {
    setState(() {
      _isTesting = true;
      _testResult = null;
    });

    try {
      final apiProvider = context.read<ApiProvider>();
      final result = await apiProvider.testConnection();
      if (!mounted) return;
      setState(() {
        _isTesting = false;
        _testResult = result ? '连接成功！' : '连接失败，请检查网络';
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _isTesting = false;
        _testResult = '测试出错: $e';
      });
    }
  }

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
                  Icon(Icons.info_outline, color: AppColors.mint, size: 20),
                  SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      'API 已内置配置，无需手动设置。如需更换请联系开发者。',
                      style: TextStyle(fontSize: 12, color: AppColors.textBody),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            _buildInfoRow('API 地址', config.baseUrl),
            _buildInfoRow('模型', config.model),
            _buildInfoRow('API Key', '${config.apiKey.substring(0, 8)}****'),
            const SizedBox(height: 24),

            if (_testResult != null)
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: _testResult!.contains('成功') ? AppColors.mint.withOpacity(0.1) : AppColors.primaryLight,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  _testResult!,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: _testResult!.contains('成功') ? const Color(0xFF2E7D32) : AppColors.primaryDark,
                  ),
                ),
              ),
            if (_testResult != null) const SizedBox(height: 16),

            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                onPressed: _isTesting ? null : _testConnection,
                icon: _isTesting
                    ? const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2))
                    : const Icon(Icons.wifi_tethering_rounded),
                label: Text(_isTesting ? '测试中...' : '测试连接'),
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  foregroundColor: AppColors.mint,
                  side: const BorderSide(color: AppColors.mint),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 70,
            child: Text(label, style: const TextStyle(fontSize: 13, color: AppColors.textSecondary)),
          ),
          Expanded(
            child: Text(value, style: const TextStyle(fontSize: 13, color: AppColors.textPrimary, fontWeight: FontWeight.w500)),
          ),
        ],
      ),
    );
  }
}
