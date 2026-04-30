import 'dart:convert';
import 'dart:io';
import 'package:path_provider/path_provider.dart';

class ApiConfig {
  static const String defaultBaseUrl = 'https://token-plan-cn.xiaomimimo.com/v1';
  static const String defaultApiKey = '';
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

  static String? _cachedPath;

  static Future<String> _getFilePath() async {
    if (_cachedPath != null) return _cachedPath!;
    final dir = await getApplicationDocumentsDirectory();
    _cachedPath = '${dir.path}/api_config.json';
    return _cachedPath!;
  }

  Future<void> save() async {
    try {
      final path = await _getFilePath();
      final file = File(path);
      await file.writeAsString(jsonEncode(toJson()));
    } catch (_) {}
  }

  static Future<ApiConfig> load() async {
    try {
      final path = await _getFilePath();
      final file = File(path);
      if (!await file.exists()) return ApiConfig();
      final jsonStr = await file.readAsString();
      if (jsonStr.isEmpty) return ApiConfig();
      final json = jsonDecode(jsonStr) as Map<String, dynamic>;
      return ApiConfig(
        baseUrl: json['baseUrl']?.toString() ?? defaultBaseUrl,
        apiKey: json['apiKey']?.toString() ?? defaultApiKey,
        model: json['model']?.toString() ?? defaultModel,
        imageModel: json['imageModel']?.toString() ?? defaultImageModel,
      );
    } catch (_) {
      return ApiConfig();
    }
  }

  Map<String, dynamic> toJson() => {
        'baseUrl': baseUrl,
        'apiKey': apiKey,
        'model': model,
        'imageModel': imageModel,
      };
}
