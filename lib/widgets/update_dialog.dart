import 'dart:io';
import 'package:flutter/material.dart';

import '../constants/patient_theme.dart';
import '../models/app_update_info.dart';
import '../services/update_service.dart';

/// Professional RehabZ-branded In-App APK Update Dialog
class UpdateDialog extends StatefulWidget {
  const UpdateDialog({
    super.key,
    required this.updateInfo,
    this.onDismiss,
  });

  final AppUpdateInfo updateInfo;
  final VoidCallback? onDismiss;

  @override
  State<UpdateDialog> createState() => _UpdateDialogState();
}

class _UpdateDialogState extends State<UpdateDialog> {
  bool _isDownloading = false;
  double _progress = 0.0;
  String _progressText = '0%';
  String _sizeText = '';
  String? _errorMessage;
  File? _downloadedApk;
  bool _isCancelled = false;

  Future<void> _startDownloadAndInstall() async {
    setState(() {
      _isDownloading = true;
      _progress = 0.0;
      _progressText = '0%';
      _sizeText = '';
      _errorMessage = null;
      _isCancelled = false;
    });

    try {
      final apkFile = await UpdateService.instance.downloadApk(
        widget.updateInfo.downloadUrl,
        targetVersion: widget.updateInfo.latestVersion,
        onProgress: (received, total) {
          if (!mounted) return;
          setState(() {
            if (total > 0) {
              _progress = (received / total).clamp(0.0, 1.0);
              _progressText = '${(_progress * 100).toInt()}%';
              final recMB = (received / (1024 * 1024)).toStringAsFixed(1);
              final totMB = (total / (1024 * 1024)).toStringAsFixed(1);
              _sizeText = '$recMB MB / $totMB MB';
            } else {
              final recMB = (received / (1024 * 1024)).toStringAsFixed(1);
              _sizeText = '$recMB MB';
              _progressText = 'Downloading...';
            }
          });
        },
        isCancelled: () => _isCancelled,
      );

      if (!mounted) return;

      setState(() {
        _downloadedApk = apkFile;
        _isDownloading = false;
      });

      // Launch native Android installer intent
      await UpdateService.instance.installApk(apkFile.path);
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _isDownloading = false;
        _errorMessage = e.toString().replaceFirst('UpdateException: ', '');
      });
    }
  }

  void _cancelDownload() {
    setState(() {
      _isCancelled = true;
      _isDownloading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final info = widget.updateInfo;

    return PopScope(
      canPop: !info.isMandatory && !_isDownloading,
      onPopInvokedWithResult: (didPop, result) {
        if (didPop) {
          widget.onDismiss?.call();
        }
      },
      child: Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
        elevation: 12,
        backgroundColor: Colors.white,
        insetPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(22, 24, 22, 20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Header Icon Badge
              Container(
                width: 56,
                height: 56,
                decoration: BoxDecoration(
                  color: PatientTheme.primaryTealLight,
                  shape: BoxShape.circle,
                  border: Border.all(color: const Color(0xFFC7EDE8), width: 1.5),
                ),
                child: const Icon(
                  Icons.rocket_launch_rounded,
                  color: PatientTheme.primaryTeal,
                  size: 28,
                ),
              ),
              const SizedBox(height: 16),

              // Title
              const Text(
                'New Update Available',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w800,
                  color: PatientTheme.textDark,
                  letterSpacing: -0.3,
                ),
              ),
              const SizedBox(height: 8),

              // Version Pill
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                decoration: BoxDecoration(
                  color: PatientTheme.primaryTealLight,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  'RehabZ v${info.latestVersion}',
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w800,
                    color: PatientTheme.primaryTealDark,
                  ),
                ),
              ),
              const SizedBox(height: 6),

              // Current Version & Size
              Text(
                'Current version: v${info.currentVersion}${info.formattedFileSize.isNotEmpty ? ' • ${info.formattedFileSize}' : ''}',
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 12,
                  color: PatientTheme.textSecondary,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 16),

              // Changelog Box
              Container(
                width: double.infinity,
                constraints: const BoxConstraints(maxHeight: 140),
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: PatientTheme.pageBg,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: PatientTheme.border),
                ),
                child: SingleChildScrollView(
                  physics: const BouncingScrollPhysics(),
                  child: Text(
                    info.changelog.isNotEmpty
                        ? info.changelog
                        : 'A new version of RehabZ is available with performance improvements and bug fixes.',
                    style: const TextStyle(
                      fontSize: 12.5,
                      height: 1.4,
                      color: PatientTheme.textDark,
                    ),
                  ),
                ),
              ),

              // Error Message Section
              if (_errorMessage != null) ...[
                const SizedBox(height: 12),
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: PatientTheme.errorRedBg,
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: const Color(0xFFFECACA)),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.error_outline_rounded, color: PatientTheme.errorRed, size: 18),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          _errorMessage!,
                          style: const TextStyle(fontSize: 11.5, color: PatientTheme.errorRed, fontWeight: FontWeight.w600),
                        ),
                      ),
                    ],
                  ),
                ),
              ],

              // Downloading Progress Section
              if (_isDownloading) ...[
                const SizedBox(height: 18),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'Downloading update...',
                          style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: PatientTheme.textDark),
                        ),
                        Text(
                          _progressText,
                          style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: PatientTheme.primaryTeal),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: LinearProgressIndicator(
                        value: _progress > 0 ? _progress : null,
                        backgroundColor: const Color(0xFFE2E8F0),
                        valueColor: const AlwaysStoppedAnimation<Color>(PatientTheme.primaryTeal),
                        minHeight: 7,
                      ),
                    ),
                    if (_sizeText.isNotEmpty) ...[
                      const SizedBox(height: 6),
                      Align(
                        alignment: Alignment.centerRight,
                        child: Text(
                          _sizeText,
                          style: const TextStyle(fontSize: 11, color: PatientTheme.textSecondary),
                        ),
                      ),
                    ],
                  ],
                ),
              ],

              const SizedBox(height: 22),

              // Action Buttons
              if (_isDownloading) ...[
                SizedBox(
                  width: double.infinity,
                  height: 46,
                  child: OutlinedButton(
                    onPressed: _cancelDownload,
                    style: OutlinedButton.styleFrom(
                      foregroundColor: PatientTheme.textSecondary,
                      side: const BorderSide(color: PatientTheme.border),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                    ),
                    child: const Text('Cancel Download', style: TextStyle(fontWeight: FontWeight.w600)),
                  ),
                ),
              ] else ...[
                // Primary Action Button (Update Now / Retry / Install)
                SizedBox(
                  width: double.infinity,
                  height: 48,
                  child: ElevatedButton(
                    onPressed: () {
                      if (_downloadedApk != null && _errorMessage == null) {
                        UpdateService.instance.installApk(_downloadedApk!.path);
                      } else {
                        _startDownloadAndInstall();
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: PatientTheme.primaryTeal,
                      foregroundColor: Colors.white,
                      elevation: 0,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          _downloadedApk != null ? Icons.install_mobile_rounded : Icons.download_rounded,
                          size: 20,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          _downloadedApk != null
                              ? 'Install Now'
                              : (_errorMessage != null ? 'Retry Download' : 'Update Now'),
                          style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                  ),
                ),

                // Later / Dismiss Button (if optional update)
                if (!info.isMandatory) ...[
                  const SizedBox(height: 10),
                  SizedBox(
                    width: double.infinity,
                    height: 40,
                    child: TextButton(
                      onPressed: () {
                        widget.onDismiss?.call();
                        Navigator.of(context).pop();
                      },
                      style: TextButton.styleFrom(
                        foregroundColor: PatientTheme.textSecondary,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                      ),
                      child: const Text(
                        'Later',
                        style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
                      ),
                    ),
                  ),
                ],
              ],
            ],
          ),
        ),
      ),
    );
  }
}
