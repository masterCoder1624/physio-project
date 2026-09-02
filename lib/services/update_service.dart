import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import 'package:package_info_plus/package_info_plus.dart';
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../core/config/app_config.dart';
import '../models/app_update_info.dart';
import '../widgets/update_dialog.dart';

/// Exception thrown when update checking, downloading, or installation fails
class UpdateException implements Exception {
  UpdateException(this.message);
  final String message;

  @override
  String toString() => message;
}

/// Centralized Service for In-App APK Updates via GitHub Releases
class UpdateService {
  UpdateService._internal();
  static final UpdateService instance = UpdateService._internal();
  factory UpdateService() => instance;

  static const MethodChannel _channel = MethodChannel('com.rehabz.app/updater');
  static const String _keyLastCheck = 'rehabz_last_update_check_time';

  bool _isChecking = false;
  String? _sessionDismissedVersion;

  /// Returns the current installed application version from package manager.
  /// Does NOT cache permanently so that post-update checks read the new version.
  Future<String> getCurrentVersion() async {
    try {
      final info = await PackageInfo.fromPlatform();
      final version = info.version.trim();
      if (version.isNotEmpty) {
        return version;
      }
    } catch (e) {
      if (kDebugMode) {
        debugPrint('[UpdateService] Failed to read PackageInfo: $e');
      }
    }
    throw UpdateException('Unable to determine installed application version.');
  }

  /// Checks GitHub Releases for a newer version.
  /// If [force] is true, ignores the time-based cooldown.
  Future<AppUpdateInfo?> checkForUpdate({bool force = false}) async {
    if (_isChecking) return null;

    // Check cooldown unless it's a user-initiated manual check
    if (!force) {
      final canCheck = await _canPerformAutoCheck();
      if (!canCheck) {
        return null;
      }
    }

    _isChecking = true;

    try {
      final packageInfo = await PackageInfo.fromPlatform();
      final installedVersion = packageInfo.version.trim();
      final installedBuildNumber = packageInfo.buildNumber.trim();

      if (installedVersion.isEmpty) {
        if (kDebugMode) {
          debugPrint('[UpdateService] Installed version is empty, skipping update check.');
        }
        return null;
      }

      final uri = Uri.parse(AppConfig.latestReleaseApiUrl);

      final response = await http.get(
        uri,
        headers: {
          'Accept': 'application/vnd.github.v3+json',
          'User-Agent': 'RehabZ-App',
        },
      ).timeout(AppConfig.networkTimeout);

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = json.decode(response.body) as Map<String, dynamic>;
        final updateInfo = AppUpdateInfo.fromGitHubReleaseJson(
          data,
          currentVersion: installedVersion,
          preferredApkName: AppConfig.defaultApkAssetName,
        );

        final rawTag = data['tag_name'] as String? ?? '';
        final cleanLatestVersion = AppUpdateInfo.cleanVersionString(rawTag);
        final cleanCurrentVersion = AppUpdateInfo.cleanVersionString(installedVersion);
        final comparisonResult = AppUpdateInfo.compareVersions(cleanLatestVersion, cleanCurrentVersion);
        final hasNewerVersion = AppUpdateInfo.isNewer(cleanLatestVersion, cleanCurrentVersion);

        if (kDebugMode) {
          debugPrint('[UpdateService] Installed version: $installedVersion');
          debugPrint('[UpdateService] Installed build number: $installedBuildNumber');
          debugPrint('[UpdateService] GitHub tag: $rawTag');
          debugPrint('[UpdateService] Clean GitHub version: $cleanLatestVersion');
          debugPrint('[UpdateService] Clean installed version: $cleanCurrentVersion');
          debugPrint('[UpdateService] Comparison result: $comparisonResult');
          debugPrint('[UpdateService] hasNewerVersion: $hasNewerVersion');
        }

        await _recordCheckTimestamp();
        return updateInfo;
      } else if (response.statusCode == 404) {
        // No releases found on GitHub repo yet
        return null;
      } else {
        // Other GitHub API status
        return null;
      }
    } catch (e) {
      if (kDebugMode) {
        debugPrint('[UpdateService] Error during auto update check: $e');
      }
      return null;
    } finally {
      _isChecking = false;
    }
  }

  /// Manual update check that throws [UpdateException] on network or API errors,
  /// allowing the caller to distinguish between "no update available" and "check failed".
  /// Always bypasses the automatic cooldown.
  Future<AppUpdateInfo?> checkForUpdateManual() async {
    if (_isChecking) {
      throw UpdateException('Update check already in progress.');
    }

    _isChecking = true;

    try {
      final packageInfo = await PackageInfo.fromPlatform();
      final installedVersion = packageInfo.version.trim();
      final installedBuildNumber = packageInfo.buildNumber.trim();

      if (installedVersion.isEmpty) {
        throw UpdateException('Unable to determine installed application version.');
      }

      final uri = Uri.parse(AppConfig.latestReleaseApiUrl);

      final response = await http.get(
        uri,
        headers: {
          'Accept': 'application/vnd.github.v3+json',
          'User-Agent': 'RehabZ-App',
        },
      ).timeout(AppConfig.networkTimeout);

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = json.decode(response.body) as Map<String, dynamic>;
        final updateInfo = AppUpdateInfo.fromGitHubReleaseJson(
          data,
          currentVersion: installedVersion,
          preferredApkName: AppConfig.defaultApkAssetName,
        );

        final rawTag = data['tag_name'] as String? ?? '';
        final cleanLatestVersion = AppUpdateInfo.cleanVersionString(rawTag);
        final cleanCurrentVersion = AppUpdateInfo.cleanVersionString(installedVersion);
        final comparisonResult = AppUpdateInfo.compareVersions(cleanLatestVersion, cleanCurrentVersion);
        final hasNewerVersion = AppUpdateInfo.isNewer(cleanLatestVersion, cleanCurrentVersion);

        if (kDebugMode) {
          debugPrint('[UpdateService] Installed version: $installedVersion');
          debugPrint('[UpdateService] Installed build number: $installedBuildNumber');
          debugPrint('[UpdateService] GitHub tag: $rawTag');
          debugPrint('[UpdateService] Clean GitHub version: $cleanLatestVersion');
          debugPrint('[UpdateService] Clean installed version: $cleanCurrentVersion');
          debugPrint('[UpdateService] Comparison result: $comparisonResult');
          debugPrint('[UpdateService] hasNewerVersion: $hasNewerVersion');
        }

        await _recordCheckTimestamp();
        return updateInfo;
      } else if (response.statusCode == 404) {
        return null;
      } else if (response.statusCode == 403) {
        throw UpdateException('GitHub API rate limit exceeded. Please try again later.');
      } else {
        throw UpdateException(
            'GitHub returned an unexpected error (HTTP ${response.statusCode}).');
      }
    } on UpdateException {
      rethrow;
    } catch (e) {
      if (kDebugMode) {
        debugPrint('[UpdateService] Error during manual update check: $e');
      }
      throw UpdateException(
          'Unable to check for updates. Please check your internet connection and try again.');
    } finally {
      _isChecking = false;
    }
  }

  /// Streams and downloads the APK file from GitHub release with live progress reporting.
  Future<File> downloadApk(
    String downloadUrl, {
    required String targetVersion,
    required void Function(int receivedBytes, int totalBytes) onProgress,
    bool Function()? isCancelled,
  }) async {
    if (downloadUrl.isEmpty) {
      throw UpdateException('Download URL is empty or invalid.');
    }

    final tempDir = await getTemporaryDirectory();
    final updateFolder = Directory('${tempDir.path}/rehabz_updates');
    if (!await updateFolder.exists()) {
      await updateFolder.create(recursive: true);
    }

    final cleanVersion = AppUpdateInfo.cleanVersionString(targetVersion);
    final targetFile = File('${updateFolder.path}/RehabZ_v$cleanVersion.apk');
    final tempFile = File('${updateFolder.path}/RehabZ_v$cleanVersion.apk.tmp');

    // Clean up any stale partial download
    if (await tempFile.exists()) {
      await tempFile.delete();
    }

    final client = http.Client();
    IOSink? sink;

    try {
      final request = http.Request('GET', Uri.parse(downloadUrl));
      request.headers['User-Agent'] = 'RehabZ-App';

      final response = await client.send(request);

      if (response.statusCode != 200) {
        throw UpdateException('Failed to download update (HTTP ${response.statusCode}).');
      }

      final totalBytes = response.contentLength ?? 0;
      int receivedBytes = 0;

      sink = tempFile.openWrite();

      await for (final chunk in response.stream) {
        if (isCancelled != null && isCancelled()) {
          await sink.close();
          if (await tempFile.exists()) await tempFile.delete();
          throw UpdateException('Download cancelled by user.');
        }

        sink.add(chunk);
        receivedBytes += chunk.length;
        onProgress(receivedBytes, totalBytes);
      }

      await sink.flush();
      await sink.close();
      sink = null;

      // Rename temp file to final APK
      if (await targetFile.exists()) {
        await targetFile.delete();
      }
      await tempFile.rename(targetFile.path);

      return targetFile;
    } catch (e) {
      if (sink != null) {
        try {
          await sink.close();
        } catch (_) {}
      }
      if (await tempFile.exists()) {
        try {
          await tempFile.delete();
        } catch (_) {}
      }
      if (e is UpdateException) rethrow;
      throw UpdateException('Failed to download APK update: $e');
    } finally {
      client.close();
    }
  }

  /// Triggers the native Android Package Installer flow
  Future<bool> installApk(String filePath) async {
    if (!Platform.isAndroid) {
      throw UpdateException('In-app APK installation is only supported on Android devices.');
    }

    final file = File(filePath);
    if (!await file.exists()) {
      throw UpdateException('APK file not found at $filePath');
    }

    _sessionDismissedVersion = null;

    try {
      final bool? result = await _channel.invokeMethod<bool>('installApk', {
        'filePath': file.path,
      });
      return result ?? true;
    } on PlatformException catch (e) {
      throw UpdateException('Installation error: ${e.message}');
    } catch (e) {
      throw UpdateException('Could not launch installer: $e');
    }
  }

  /// Checks for update and automatically displays the RehabZ-branded update dialog if available.
  /// [isManual] is true when triggered by a button press (e.g. Settings -> "Check for Updates").
  Future<void> checkAndPromptUpdate(
    BuildContext context, {
    bool isManual = false,
  }) async {
    final updateInfo = await checkForUpdate(force: isManual);

    if (!context.mounted) return;

    if (updateInfo != null && updateInfo.isUpdateAvailable) {
      // Check if user dismissed this update during current app session
      if (!isManual && _sessionDismissedVersion == updateInfo.latestVersion) {
        return;
      }

      showDialog(
        context: context,
        barrierDismissible: !updateInfo.isMandatory,
        builder: (ctx) => UpdateDialog(
          updateInfo: updateInfo,
          onDismiss: () {
            _sessionDismissedVersion = updateInfo.latestVersion;
          },
        ),
      );
    } else if (isManual) {
      final currentVersion = await getCurrentVersion();
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('RehabZ is up to date (v$currentVersion).'),
          duration: const Duration(seconds: 3),
        ),
      );
    }
  }

  Future<bool> _canPerformAutoCheck() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final lastCheckMs = prefs.getInt(_keyLastCheck) ?? 0;
      if (lastCheckMs == 0) return true;

      final lastCheckTime = DateTime.fromMillisecondsSinceEpoch(lastCheckMs);
      final difference = DateTime.now().difference(lastCheckTime);
      return difference >= AppConfig.updateCheckCooldown;
    } catch (_) {
      return true;
    }
  }

  Future<void> _recordCheckTimestamp() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setInt(_keyLastCheck, DateTime.now().millisecondsSinceEpoch);
    } catch (_) {}
  }
}
