import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:url_launcher/url_launcher.dart';

class UpdateInfo {
  final String version;
  final String downloadUrl;
  final String releaseNotes;
  final String publishedAt;

  UpdateInfo({
    required this.version,
    required this.downloadUrl,
    required this.releaseNotes,
    required this.publishedAt,
  });
}

class UpdateService {
  static const String _owner = 'clea001';
  static const String _repo = 'fitness-app';
  static const String _apiUrl = 'https://api.github.com/repos/$_owner/$_repo/releases/latest';

  static Future<UpdateInfo?> checkForUpdate() async {
    try {
      final packageInfo = await PackageInfo.fromPlatform();
      final currentVersion = packageInfo.version;

      final dio = Dio(BaseOptions(
        headers: {'Accept': 'application/vnd.github.v3+json'},
        connectTimeout: const Duration(seconds: 10),
      ));

      final response = await dio.get(_apiUrl);
      final data = response.data as Map<String, dynamic>;

      final tagName = (data['tag_name'] as String?)?.replaceAll('v', '') ?? '';
      final body = data['body'] as String? ?? '';
      final publishedAt = data['published_at'] as String? ?? '';

      // 查找 APK 下载链接
      String apkUrl = '';
      final assets = data['assets'] as List? ?? [];
      for (final asset in assets) {
        final name = asset['name'] as String? ?? '';
        if (name.endsWith('.apk')) {
          apkUrl = asset['browser_download_url'] as String? ?? '';
          break;
        }
      }

      if (tagName.isEmpty || apkUrl.isEmpty) return null;

      // 比较版本
      if (_isNewerVersion(currentVersion, tagName)) {
        return UpdateInfo(
          version: tagName,
          downloadUrl: apkUrl,
          releaseNotes: body,
          publishedAt: publishedAt,
        );
      }
      return null;
    } catch (e) {
      return null;
    }
  }

  static bool _isNewerVersion(String current, String latest) {
    final currentParts = current.split('.').map(int.tryParse).toList();
    final latestParts = latest.split('.').map(int.tryParse).toList();

    for (int i = 0; i < 3; i++) {
      final c = (i < currentParts.length) ? (currentParts[i] ?? 0) : 0;
      final l = (i < latestParts.length) ? (latestParts[i] ?? 0) : 0;
      if (l > c) return true;
      if (l < c) return false;
    }
    return false;
  }

  static Future<void> downloadUpdate(String url) async {
    final uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }
}
