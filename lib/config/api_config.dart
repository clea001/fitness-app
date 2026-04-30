import 'package:shared_preferences/shared_preferences.dart';

class ApiConfig {
  static const String _keyBaseUrl = 'api_base_url';
  static const String _keyApiKey = 'api_key';
  static const String _keyModel = 'api_model';
  static const String _keyImageModel = 'api_image_model';

  static const String defaultBaseUrl = 'https://token-plan-cn.xiaomimimo.com/v1';
  static const String defaultApiKey = '';  // 不再内置，需要用户手动配置
  static const String defaultModel = 'mimo-v2.5-pro';
  static const String defaultImageModel = '';

  String baseUrl;
  String apiKey;
  String model;
  String imageModel;

  ApiConfig({
    this.baseUrl = defaultBaseUrl,
    this.apiKey = defaultApiKey,
    this.model = defaultModel,
    this.imageModel = defaultImageModel,
  });

  bool get isConfigured => apiKey.isNotEmpty;

  Future<void> save() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_keyBaseUrl, baseUrl);
    await prefs.setString(_keyApiKey, apiKey);
    await prefs.setString(_keyModel, model);
    await prefs.setString(_keyImageModel, imageModel);
  }

  static Future<ApiConfig> load() async {
    final prefs = await SharedPreferences.getInstance();
    return ApiConfig(
      baseUrl: prefs.getString(_keyBaseUrl) ?? defaultBaseUrl,
      apiKey: prefs.getString(_keyApiKey) ?? defaultApiKey,
      model: prefs.getString(_keyModel) ?? defaultModel,
      imageModel: prefs.getString(_keyImageModel) ?? defaultImageModel,
    );
  }
}
