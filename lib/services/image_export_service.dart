import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:screenshot/screenshot.dart';
import 'package:path_provider/path_provider.dart';
import 'package:gal/gal.dart';

class ImageExportService {
  final ScreenshotController _controller = ScreenshotController();

  ScreenshotController get controller => _controller;

  Future<String?> saveToGallery(Uint8List imageBytes, String name) async {
    try {
      // 保存到临时文件
      final tempDir = await getTemporaryDirectory();
      final file = File('${tempDir.path}/fitness_plan_$name.png');
      await file.writeAsBytes(imageBytes);

      // 使用 gal 保存到相册
      await Gal.putImage(file.path, album: 'AI健身助手');

      return file.path;
    } catch (e) {
      throw Exception('保存失败: $e');
    }
  }

  // 模板列表
  static const List<ExportTemplate> templates = [
    ExportTemplate(
      name: '活力橙',
      gradient: [Color(0xFFFF6B35), Color(0xFFFF8E53)],
      textColor: Colors.white,
    ),
    ExportTemplate(
      name: '薄荷绿',
      gradient: [Color(0xFF4ECDC4), Color(0xFF44B09E)],
      textColor: Colors.white,
    ),
    ExportTemplate(
      name: '梦幻紫',
      gradient: [Color(0xFF9B59B6), Color(0xFF8E44AD)],
      textColor: Colors.white,
    ),
    ExportTemplate(
      name: '天空蓝',
      gradient: [Color(0xFF3498DB), Color(0xFF2980B9)],
      textColor: Colors.white,
    ),
    ExportTemplate(
      name: '樱花粉',
      gradient: [Color(0xFFFFB6C1), Color(0xFFFF69B4)],
      textColor: Colors.white,
    ),
  ];
}

class ExportTemplate {
  final String name;
  final List<Color> gradient;
  final Color textColor;

  const ExportTemplate({
    required this.name,
    required this.gradient,
    required this.textColor,
  });
}
