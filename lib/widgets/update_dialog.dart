import 'package:flutter/material.dart';
import '../services/update_service.dart';
import '../theme/app_theme.dart';

class UpdateDialog extends StatefulWidget {
  final UpdateInfo updateInfo;

  const UpdateDialog({super.key, required this.updateInfo});

  static Future<void> showIfNeeded(BuildContext context) async {
    final updateInfo = await UpdateService.checkForUpdate();
    if (updateInfo != null && context.mounted) {
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (_) => UpdateDialog(updateInfo: updateInfo),
      );
    }
  }

  @override
  State<UpdateDialog> createState() => _UpdateDialogState();
}

class _UpdateDialogState extends State<UpdateDialog> {
  bool _isDownloading = false;
  double _progress = 0;
  String? _error;

  Future<void> _startDownload() async {
    setState(() {
      _isDownloading = true;
      _progress = 0;
      _error = null;
    });

    try {
      final filePath = await UpdateService.downloadApk(
        widget.updateInfo.downloadUrl,
        (p) => setState(() => _progress = p),
      );

      if (filePath != null && mounted) {
        Navigator.pop(context);
        await UpdateService.installApk(filePath);
      }
    } catch (e) {
      setState(() {
        _error = '下载失败，尝试浏览器下载';
        _isDownloading = false;
      });
    }
  }

  void _openBrowser() {
    UpdateService.openInBrowser(widget.updateInfo.downloadUrl);
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 64,
              height: 64,
              decoration: BoxDecoration(
                gradient: const LinearGradient(colors: [AppColors.primary, AppColors.primaryDark]),
                borderRadius: BorderRadius.circular(16),
              ),
              child: const Icon(Icons.system_update_rounded, color: Colors.white, size: 32),
            ),
            const SizedBox(height: 16),
            const Text(
              '发现新版本',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: AppColors.textPrimary),
            ),
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
              decoration: BoxDecoration(
                color: AppColors.primaryLight,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                'v${widget.updateInfo.version}',
                style: const TextStyle(fontSize: 13, color: AppColors.primaryDark, fontWeight: FontWeight.w600),
              ),
            ),
            const SizedBox(height: 16),

            // 更新内容
            if (!_isDownloading && widget.updateInfo.releaseNotes.isNotEmpty) ...[
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: AppColors.background,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('更新内容', style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: AppColors.textPrimary)),
                    const SizedBox(height: 8),
                    Text(
                      widget.updateInfo.releaseNotes,
                      style: const TextStyle(fontSize: 12, color: AppColors.textBody, height: 1.5),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),
            ],

            // 下载进度
            if (_isDownloading) ...[
              const SizedBox(height: 8),
              LinearProgressIndicator(
                value: _progress,
                backgroundColor: AppColors.divider,
                valueColor: const AlwaysStoppedAnimation<Color>(AppColors.primary),
                borderRadius: BorderRadius.circular(4),
                minHeight: 6,
              ),
              const SizedBox(height: 10),
              Text(
                _progress > 0 ? '下载中 ${(_progress * 100).toInt()}%' : '正在连接...',
                style: const TextStyle(fontSize: 13, color: AppColors.textSecondary),
              ),
              const SizedBox(height: 20),
            ],

            // 错误提示
            if (_error != null) ...[
              Text(_error!, style: const TextStyle(fontSize: 12, color: AppColors.primaryDark)),
              const SizedBox(height: 12),
            ],

            // 按钮
            if (_isDownloading)
              OutlinedButton(
                onPressed: () => Navigator.pop(context),
                style: OutlinedButton.styleFrom(
                  foregroundColor: AppColors.textSecondary,
                  side: const BorderSide(color: AppColors.divider),
                  padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 32),
                ),
                child: const Text('后台下载'),
              )
            else if (_error != null)
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: _openBrowser,
                      style: OutlinedButton.styleFrom(
                        foregroundColor: AppColors.textSecondary,
                        side: const BorderSide(color: AppColors.divider),
                        padding: const EdgeInsets.symmetric(vertical: 12),
                      ),
                      child: const Text('浏览器下载'),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: _startDownload,
                      style: ElevatedButton.styleFrom(padding: const EdgeInsets.symmetric(vertical: 12)),
                      child: const Text('重试'),
                    ),
                  ),
                ],
              )
            else
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => Navigator.pop(context),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: AppColors.textSecondary,
                        side: const BorderSide(color: AppColors.divider),
                        padding: const EdgeInsets.symmetric(vertical: 12),
                      ),
                      child: const Text('稍后再说'),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: _startDownload,
                      style: ElevatedButton.styleFrom(padding: const EdgeInsets.symmetric(vertical: 12)),
                      child: const Text('立即更新'),
                    ),
                  ),
                ],
              ),
          ],
        ),
      ),
    );
  }
}
