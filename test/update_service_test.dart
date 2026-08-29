import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:flutter_application_1/models/app_update_info.dart';
import 'package:flutter_application_1/widgets/update_dialog.dart';

void main() {
  group('Semantic Version Comparison Tests', () {
    test('detects newer minor and patch versions', () {
      expect(AppUpdateInfo.isNewer('1.1.0', '1.0.0'), isTrue);
      expect(AppUpdateInfo.isNewer('v1.0.1', '1.0.0'), isTrue);
      expect(AppUpdateInfo.isNewer('2.0.0', '1.9.9'), isTrue);
      expect(AppUpdateInfo.isNewer('v1.2.3', '1.2.2'), isTrue);
    });

    test('detects identical versions as not newer', () {
      expect(AppUpdateInfo.isNewer('1.0.0', '1.0.0'), isFalse);
      expect(AppUpdateInfo.isNewer('v1.0.0', '1.0.0'), isFalse);
      expect(AppUpdateInfo.isNewer('V1.0.0', 'v1.0.0'), isFalse);
      expect(AppUpdateInfo.compareVersions('1.0.0', '1.0.0'), equals(0));
    });

    test('detects older versions as not newer', () {
      expect(AppUpdateInfo.isNewer('1.0.0', '1.1.0'), isFalse);
      expect(AppUpdateInfo.isNewer('v0.9.5', '1.0.0'), isFalse);
      expect(AppUpdateInfo.compareVersions('1.0.0', '1.1.0'), equals(-1));
    });

    test('handles build number comparisons correctly', () {
      expect(AppUpdateInfo.compareVersions('1.0.0+2', '1.0.0+1'), equals(1));
      expect(AppUpdateInfo.compareVersions('1.0.0+1', '1.0.0+2'), equals(-1));
      expect(AppUpdateInfo.compareVersions('1.0.0+1', '1.0.0+1'), equals(0));
    });
  });

  group('GitHub Release Payload Parser Tests', () {
    final mockReleaseJson = {
      'tag_name': 'v1.1.0',
      'name': 'RehabZ v1.1.0 - Major Performance Update',
      'body': '• Added in-app APK updater\n• Improved recovery charts\n• Bug fixes',
      'published_at': '2026-08-29T12:00:00Z',
      'assets': [
        {
          'name': 'app-release.apk',
          'browser_download_url': 'https://github.com/masterCoder1624/physio-project/releases/download/v1.1.0/app-release.apk',
          'size': 44564480, // ~42.5 MB
        },
        {
          'name': 'source-code.zip',
          'browser_download_url': 'https://github.com/masterCoder1624/physio-project/archive/v1.1.0.zip',
          'size': 1024000,
        }
      ]
    };

    test('parses release payload and identifies APK asset', () {
      final info = AppUpdateInfo.fromGitHubReleaseJson(
        mockReleaseJson,
        currentVersion: '1.0.0',
      );

      expect(info.latestVersion, equals('1.1.0'));
      expect(info.currentVersion, equals('1.0.0'));
      expect(info.isUpdateAvailable, isTrue);
      expect(info.apkFileName, equals('app-release.apk'));
      expect(info.downloadUrl, contains('app-release.apk'));
      expect(info.formattedFileSize, equals('42.5 MB'));
      expect(info.changelog, contains('Added in-app APK updater'));
    });

    test('marks update as unavailable when installed version is identical', () {
      final info = AppUpdateInfo.fromGitHubReleaseJson(
        mockReleaseJson,
        currentVersion: '1.1.0',
      );

      expect(info.isUpdateAvailable, isFalse);
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
