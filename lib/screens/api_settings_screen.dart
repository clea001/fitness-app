import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../config/api_config.dart';
import '../providers/api_provider.dart';
import '../theme/app_theme.dart';

class ApiSettingsScreen extends StatefulWidget {
  const ApiSettingsScreen({super.key});

  @override
  State<ApiSettingsScreen> createState() => _ApiSettingsScreenState();
}

class _ApiSettingsScreenState extends State<ApiSettingsScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _baseUrlController;
  late TextEditingController _apiKeyController;
  late TextEditingController _modelController;
  late TextEditingController _imageModelController;
  bool _isSaving = false;
  bool _isTesting = false;
  String? _testResult;

  @override
  void initState() {
    super.initState();
    final config = context.read<ApiProvider>().config;
    _baseUrlController = TextEditingController(text: config.baseUrl);
    _apiKeyController = TextEditingController(text: config.apiKey);
    _modelController = TextEditingController(text: config.model);
    _imageModelController = TextEditingController(text: config.imageModel);
  }

  @override
  void dispose() {
    _baseUrlController.dispose();
    _apiKeyController.dispose();
    _modelController.dispose();
    _imageModelController.dispose();
    super.dispose();
  }

  ApiConfig _buildConfig() {
    return ApiConfig(
      baseUrl: _baseUrlController.text.trim(),
      apiKey: _apiKeyController.text.trim(),
      model: _modelController.text.trim(),
      imageModel: _imageModelController.text.trim(),
    );
  }

  Future<void> _testConnection() async {
    setState(() {
      _isTesting = true;
      _testResult = null;
    });

    try {
      final apiProvider = context.read<ApiProvider>();
      await apiProvider.updateConfig(_buildConfig());
      final result = await apiProvider.testConnection();
      if (!mounted) return;
      setState(() {
        _isTesting = false;
        _testResult = result ? '连接成功！' : '连接失败，请检查配置';
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _isTesting = false;
        _testResult = '测试出错: $e';
      });
    }
  }

  Future<void> _saveConfig() async {
    if (_isSaving) return;
    setState(() => _isSaving = true);

    try {
      final apiProvider = context.read<ApiProvider>();
      await apiProvider.updateConfig(_buildConfig());
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('配置已保存'),
          backgroundColor: AppColors.mint,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
      );
      Navigator.pop(context);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('保存失败: $e'),
          backgroundColor: AppColors.primaryDark,
        ),
      );
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('API 配置')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
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
                        '支持所有 OpenAI 兼容接口，如 DeepSeek、ChatGPT、通义千问等',
                        style: TextStyle(fontSize: 12, color: AppColors.textBody),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              _buildLabel('API 地址'),
              const SizedBox(height: 8),
              TextFormField(
                controller: _baseUrlController,
                decoration: const InputDecoration(
                  hintText: 'https://token-plan-cn.xiaomimimo.com',
                  prefixIcon: Icon(Icons.link_rounded),
                ),
              ),
              const SizedBox(height: 20),

              _buildLabel('API Key'),
              const SizedBox(height: 8),
              TextFormField(
                controller: _apiKeyController,
                obscureText: true,
                decoration: const InputDecoration(
                  hintText: '输入你的 API Key',
                  prefixIcon: Icon(Icons.key_rounded),
                ),
              ),
              const SizedBox(height: 20),

              _buildLabel('对话模型'),
              const SizedBox(height: 8),
              TextFormField(
                controller: _modelController,
                decoration: const InputDecoration(
                  hintText: 'mimo-v2.5-pro',
                  prefixIcon: Icon(Icons.smart_toy_rounded),
                ),
              ),
              const SizedBox(height: 20),

              _buildLabel('图片生成模型（可选）'),
              const SizedBox(height: 8),
              TextFormField(
                controller: _imageModelController,
                decoration: const InputDecoration(
                  hintText: '留空则使用内置模板',
                  prefixIcon: Icon(Icons.image_rounded),
                ),
              ),
              const SizedBox(height: 12),

              TextButton.icon(
                onPressed: () {
                  _baseUrlController.text = ApiConfig.defaultBaseUrl;
                  _apiKeyController.text = ApiConfig.defaultApiKey;
                  _modelController.text = ApiConfig.defaultModel;
                  _imageModelController.text = ApiConfig.defaultImageModel;
                },
                icon: const Icon(Icons.restore_rounded, size: 16),
                label: const Text('恢复默认配置（MiMo）', style: TextStyle(fontSize: 12)),
                style: TextButton.styleFrom(foregroundColor: AppColors.textSecondary),
              ),
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

              OutlinedButton.icon(
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
              const SizedBox(height: 12),

              ElevatedButton.icon(
                onPressed: _isSaving ? null : _saveConfig,
                icon: _isSaving
                    ? const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                    : const Icon(Icons.save_rounded),
                label: Text(_isSaving ? '保存中...' : '保存配置'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLabel(String text) {
    return Text(text, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: AppColors.textPrimary));
  }
}
