import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:package_info_plus/package_info_plus.dart';

import 'package:flutter_application_1/models/app_update_info.dart';
import 'package:flutter_application_1/services/update_service.dart';
import 'package:flutter_application_1/widgets/update_dialog.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('Semantic Version Comparison & Build Number Tests', () {
    // 8 Required Tests from User Specification
    test('1. v1.0.1 vs 1.0.1 -> no update', () {
      expect(AppUpdateInfo.isNewer('v1.0.1', '1.0.1'), isFalse);
      expect(AppUpdateInfo.compareVersions('v1.0.1', '1.0.1'), equals(0));
    });

    test('2. v1.0.2 vs 1.0.1 -> update', () {
      expect(AppUpdateInfo.isNewer('v1.0.2', '1.0.1'), isTrue);
      expect(AppUpdateInfo.compareVersions('v1.0.2', '1.0.1'), equals(1));
    });

    test('3. v1.0.3 vs 1.0.2 -> update', () {
      expect(AppUpdateInfo.isNewer('v1.0.3', '1.0.2'), isTrue);
      expect(AppUpdateInfo.compareVersions('v1.0.3', '1.0.2'), equals(1));
    });

    test('4. v1.0.3 vs 1.0.3 -> no update', () {
      expect(AppUpdateInfo.isNewer('v1.0.3', '1.0.3'), isFalse);
      expect(AppUpdateInfo.compareVersions('v1.0.3', '1.0.3'), equals(0));
    });

    test('5. 1.0.3+3 vs 1.0.3 -> no update', () {
      expect(AppUpdateInfo.isNewer('1.0.3+3', '1.0.3'), isFalse);
      expect(AppUpdateInfo.compareVersions('1.0.3+3', '1.0.3'), equals(0));
    });

    test('6. v1.0.3 vs 1.0.3+3 -> no update', () {
      expect(AppUpdateInfo.isNewer('v1.0.3', '1.0.3+3'), isFalse);
      expect(AppUpdateInfo.compareVersions('v1.0.3', '1.0.3+3'), equals(0));
    });

    test('7. v1.1.0 vs 1.0.9 -> update', () {
      expect(AppUpdateInfo.isNewer('v1.1.0', '1.0.9'), isTrue);
      expect(AppUpdateInfo.compareVersions('v1.1.0', '1.0.9'), equals(1));
    });

    test('8. v2.0.0 vs 1.9.9 -> update', () {
      expect(AppUpdateInfo.isNewer('v2.0.0', '1.9.9'), isTrue);
      expect(AppUpdateInfo.compareVersions('v2.0.0', '1.9.9'), equals(1));
    });

    test('Build numbers do not trigger false update prompts', () {
      expect(AppUpdateInfo.compareVersions('1.0.3+4', '1.0.3'), equals(0));
      expect(AppUpdateInfo.compareVersions('1.0.3', '1.0.3+4'), equals(0));
      expect(AppUpdateInfo.compareVersions('1.0.0+2', '1.0.0+1'), equals(0));
      expect(AppUpdateInfo.isNewer('1.0.0+2', '1.0.0+1'), isFalse);
    });

    test('detects older versions as not newer', () {
      expect(AppUpdateInfo.isNewer('1.0.0', '1.1.0'), isFalse);
      expect(AppUpdateInfo.isNewer('v0.9.5', '1.0.0'), isFalse);
      expect(AppUpdateInfo.compareVersions('1.0.0', '1.1.0'), equals(-1));
    });

    test('handles empty or invalid versions gracefully without false prompts', () {
      expect(AppUpdateInfo.isNewer('', '1.0.0'), isFalse);
      expect(AppUpdateInfo.isNewer('1.0.0', ''), isFalse);
      expect(AppUpdateInfo.isNewer('', ''), isFalse);
    });
  });

  group('GitHub Release Payload Parser Tests', () {
    final mockReleaseV103 = {
      'tag_name': 'v1.0.3',
      'name': 'Rehab v1.0.3',
      'body': '• Performance update\\n• Bug fixes',
      'published_at': '2026-09-02T12:00:00Z',
      'assets': [
        {
          'name': 'app-release.apk',
          'browser_download_url': 'https://github.com/masterCoder1624/physio-project/releases/download/v1.0.3/app-release.apk',
          'size': 44564480,
        }
      ]
    };

    test('v1.0.3 GitHub release vs installed 1.0.3 -> NO UPDATE AVAILABLE', () {
      final info = AppUpdateInfo.fromGitHubReleaseJson(
        mockReleaseV103,
        currentVersion: '1.0.3',
      );

      expect(info.latestVersion, equals('1.0.3'));
      expect(info.currentVersion, equals('1.0.3'));
      expect(info.isUpdateAvailable, isFalse);
    });

    test('v1.0.3 GitHub release vs installed 1.0.3+3 -> NO UPDATE AVAILABLE', () {
      final info = AppUpdateInfo.fromGitHubReleaseJson(
        mockReleaseV103,
        currentVersion: '1.0.3+3',
      );

      expect(info.latestVersion, equals('1.0.3'));
      expect(info.currentVersion, equals('1.0.3'));
      expect(info.isUpdateAvailable, isFalse);
    });

    test('v1.0.3 GitHub release vs installed 1.0.2 -> UPDATE AVAILABLE', () {
      final info = AppUpdateInfo.fromGitHubReleaseJson(
        mockReleaseV103,
        currentVersion: '1.0.2',
      );

      expect(info.latestVersion, equals('1.0.3'));
      expect(info.currentVersion, equals('1.0.2'));
      expect(info.isUpdateAvailable, isTrue);
      expect(info.apkFileName, equals('app-release.apk'));
      expect(info.downloadUrl, contains('app-release.apk'));
    });

    test('marks update as unavailable if no APK asset is found', () {
      final noApkJson = {
        'tag_name': 'v1.2.0',
        'name': 'Release without APK',
        'body': 'Notes',
        'assets': [
          {
            'name': 'readme.txt',
            'browser_download_url': 'https://github.com/dummy/readme.txt',
            'size': 100,
          }
        ]
      };

      final info = AppUpdateInfo.fromGitHubReleaseJson(
        noApkJson,
        currentVersion: '1.0.0',
      );

      expect(info.isUpdateAvailable, isFalse);
      expect(info.downloadUrl, isEmpty);
    });
  });

  group('UpdateService Dynamic Version Reading Tests', () {
    test('reads installed version dynamically from PackageInfo without stale caching', () async {
      PackageInfo.setMockInitialValues(
        appName: 'RehabZ',
        packageName: 'com.rehabz.app',
        version: '1.0.2',
        buildNumber: '2',
        buildSignature: '',
      );

      final version1 = await UpdateService.instance.getCurrentVersion();
      expect(version1, equals('1.0.2'));

      // Simulate APK update to 1.0.3:
      PackageInfo.setMockInitialValues(
        appName: 'RehabZ',
        packageName: 'com.rehabz.app',
        version: '1.0.3',
        buildNumber: '3',
        buildSignature: '',
      );

      final version2 = await UpdateService.instance.getCurrentVersion();
      expect(version2, equals('1.0.3'));
    });
  });

  group('UpdateDialog Widget Tests', () {
    const updateInfo = AppUpdateInfo(
      latestVersion: '1.1.0',
      rawTagName: 'v1.1.0',
      currentVersion: '1.0.0',
      releaseTitle: 'RehabZ v1.1.0',
      changelog: 'Added real-time messaging and speed improvements.',
      downloadUrl: 'https://example.com/RehabZ.apk',
      apkFileName: 'RehabZ.apk',
      fileSizeBytes: 44564480,
      isUpdateAvailable: true,
    );

    testWidgets('renders RehabZ-branded update dialog with details and buttons', (tester) async {
      bool dismissed = false;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Builder(
              builder: (context) => ElevatedButton(
                onPressed: () {
                  showDialog(
                    context: context,
                    builder: (_) => UpdateDialog(
                      updateInfo: updateInfo,
                      onDismiss: () => dismissed = true,
                    ),
                  );
                },
                child: const Text('Open Dialog'),
              ),
            ),
          ),
        ),
      );

      await tester.tap(find.text('Open Dialog'));
      await tester.pumpAndSettle();

      // Verify header and versions
      expect(find.text('New Update Available'), findsOneWidget);
      expect(find.text('RehabZ v1.1.0'), findsOneWidget);
      expect(find.textContaining('Current version: v1.0.0'), findsOneWidget);
      expect(find.textContaining('42.5 MB'), findsOneWidget);

      // Verify changelog
      expect(find.text('Added real-time messaging and speed improvements.'), findsOneWidget);

      // Verify action buttons
      expect(find.text('Update Now'), findsOneWidget);
      expect(find.text('Later'), findsOneWidget);

      // Dismiss dialog
      await tester.tap(find.text('Later'));
      await tester.pumpAndSettle();

      expect(dismissed, isTrue);
      expect(find.text('New Update Available'), findsNothing);
    });
  });
}
