import 'dart:convert';
import 'package:dio/dio.dart';
import '../config/api_config.dart';

class ApiService {
  final ApiConfig config;
  late final Dio _dio;

  ApiService(this.config) {
    // 确保 baseUrl 以 / 结尾
    String baseUrl = config.baseUrl.endsWith('/')
        ? config.baseUrl
        : '${config.baseUrl}/';

    // 确保有 v1/ 前缀
    if (!baseUrl.endsWith('v1/')) {
      baseUrl = '${baseUrl}v1/';
    }

    _dio = Dio(BaseOptions(
      baseUrl: baseUrl,
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer ${config.apiKey}',
      },
      connectTimeout: const Duration(seconds: 30),
      receiveTimeout: const Duration(seconds: 120),
    ));
  }

  Future<String> chat(List<Map<String, String>> messages, {String? model}) async {
    try {
      final response = await _dio.post(
        'chat/completions',
        data: {
          'model': model ?? config.model,
          'messages': messages,
          'temperature': 0.7,
          'max_tokens': 4096,
        },
      );

      final data = response.data;
      if (data is Map<String, dynamic>) {
        if (data.containsKey('choices')) {
          final choices = data['choices'] as List;
          if (choices.isNotEmpty) {
            final choice = choices[0];
            final message = choice['message'];
            if (message is Map<String, dynamic>) {
              // 优先取 content，如果为空则取 reasoning_content
              String content = message['content'] as String? ?? '';
              if (content.isEmpty) {
                content = message['reasoning_content'] as String? ?? '';
              }
              if (content.isNotEmpty) return content;
            }
          }
        }
        if (data.containsKey('content')) {
          return data['content'] as String? ?? '';
        }
        if (data.containsKey('response')) {
          return data['response'] as String? ?? '';
        }
      }
      throw Exception('无法解析 API 响应: $data');
    } on DioException catch (e) {
      if (e.response != null) {
        throw Exception('API 错误: ${e.response?.statusCode} - ${e.response?.data}');
      }
      throw Exception('网络错误: ${e.message}');
    }
  }

  Future<bool> testConnection() async {
    try {
      final response = await chat([
        {'role': 'user', 'content': '你好，请回复"连接成功"'}
      ]);
      return response.isNotEmpty;
    } catch (e) {
      return false;
    }
  }

  Future<String> generateImage(String prompt) async {
    if (config.imageModel.isEmpty) {
      throw Exception('未配置图片生成模型');
    }
    try {
      final response = await _dio.post(
        'images/generations',
        data: {
          'model': config.imageModel,
          'prompt': prompt,
          'n': 1,
          'size': '1024x1024',
        },
      );
      return response.data['data'][0]['url'] as String;
    } on DioException catch (e) {
      throw Exception('图片生成失败: ${e.message}');
    }
  }
}
