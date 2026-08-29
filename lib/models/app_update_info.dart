/// Model representing GitHub Release update metadata and semantic versioning logic
class AppUpdateInfo {
  const AppUpdateInfo({
    required this.latestVersion,
    required this.rawTagName,
    required this.currentVersion,
    required this.releaseTitle,
    required this.changelog,
    required this.downloadUrl,
    required this.apkFileName,
    required this.fileSizeBytes,
    required this.isUpdateAvailable,
    this.publishedAt,
    this.isMandatory = false,
  });

  /// Semantic version string of the latest release (e.g. "1.1.0")
  final String latestVersion;

  /// Raw tag name from GitHub (e.g. "v1.1.0")
  final String rawTagName;

  /// Installed app version (e.g. "1.0.0")
  final String currentVersion;

  /// Name / Title of the release on GitHub
  final String releaseTitle;

  /// Release description / changelog body
  final String changelog;

  /// Direct APK browser download URL from GitHub release assets
  final String downloadUrl;

  /// Name of the APK file (e.g. "app-release.apk")
  final String apkFileName;

  /// File size of the APK in bytes
  final int fileSizeBytes;

  /// True if latestVersion is strictly newer than currentVersion
  final bool isUpdateAvailable;

  /// Release publication timestamp
  final DateTime? publishedAt;

  /// Whether this update is marked as mandatory (for future extension)
  final bool isMandatory;

  /// User-friendly formatted file size (e.g. "42.5 MB")
  String get formattedFileSize {
    if (fileSizeBytes <= 0) return '';
    final mb = fileSizeBytes / (1024 * 1024);
    if (mb >= 1.0) {
      return '${mb.toStringAsFixed(1)} MB';
    }
    final kb = fileSizeBytes / 1024;
    return '${kb.toStringAsFixed(0)} KB';
  }

  /// Parses GitHub Release JSON and matches an APK asset
  factory AppUpdateInfo.fromGitHubReleaseJson(
    Map<String, dynamic> json, {
    required String currentVersion,
    String? preferredApkName,
  }) {
    final rawTag = json['tag_name'] as String? ?? '';
    final cleanLatestVersion = cleanVersionString(rawTag);
    final cleanCurrentVersion = cleanVersionString(currentVersion);

    final title = json['name'] as String? ?? 'RehabZ Update $cleanLatestVersion';
    final body = json['body'] as String? ?? 'A new version of RehabZ is available with improvements and bug fixes.';
    final publishedStr = json['published_at'] as String?;
    final publishedAt = publishedStr != null ? DateTime.tryParse(publishedStr) : null;

    final assets = json['assets'] as List<dynamic>? ?? [];
    String downloadUrl = '';
    String apkFileName = 'app-release.apk';
    int fileSizeBytes = 0;

    // Look for APK asset:
    // 1. Check preferred asset name if specified
    // 2. Otherwise pick the first asset ending with .apk
    for (final asset in assets) {
      if (asset is Map<String, dynamic>) {
        final name = asset['name'] as String? ?? '';
        final url = asset['browser_download_url'] as String? ?? '';
        final size = asset['size'] as int? ?? 0;

        if (name.toLowerCase().endsWith('.apk')) {
          if (preferredApkName != null && name.toLowerCase() == preferredApkName.toLowerCase()) {
            downloadUrl = url;
            apkFileName = name;
            fileSizeBytes = size;
            break;
          } else if (downloadUrl.isEmpty) {
            downloadUrl = url;
            apkFileName = name;
            fileSizeBytes = size;
          }
        }
      }
    }

    final hasNewerVersion = isNewer(cleanLatestVersion, cleanCurrentVersion);
    final isAvailable = hasNewerVersion && downloadUrl.isNotEmpty;

    return AppUpdateInfo(
      latestVersion: cleanLatestVersion,
      rawTagName: rawTag,
      currentVersion: cleanCurrentVersion,
      releaseTitle: title,
      changelog: body.trim(),
      downloadUrl: downloadUrl,
      apkFileName: apkFileName,
      fileSizeBytes: fileSizeBytes,
      isUpdateAvailable: isAvailable,
      publishedAt: publishedAt,
      isMandatory: body.toLowerCase().contains('[mandatory]') || body.toLowerCase().contains('[force-update]'),
    );
  }

  /// Cleans raw version tags like "v1.2.3+4" or "V1.0.0-beta" into standard "1.2.3"
  static String cleanVersionString(String input) {
    var s = input.trim();
    if (s.startsWith('v') || s.startsWith('V')) {
      s = s.substring(1).trim();
    }
    // Remove pre-release tags or build numbers for base version extraction if attached via '-' or '+'
    return s;
  }

  /// Semantic Version Comparison:
  /// Returns > 0 if v1 > v2
  /// Returns 0 if v1 == v2
  /// Returns < 0 if v1 < v2
  static int compareVersions(String v1, String v2) {
    final v1Clean = cleanVersionString(v1);
    final v2Clean = cleanVersionString(v2);

    if (v1Clean == v2Clean) return 0;

    // Split base version and build number (+N)
    final v1PartsWithBuild = v1Clean.split('+');
    final v2PartsWithBuild = v2Clean.split('+');

    final v1Base = v1PartsWithBuild[0].split('-')[0];
    final v2Base = v2PartsWithBuild[0].split('-')[0];

    final v1Segments = v1Base.split('.').map((e) => int.tryParse(e) ?? 0).toList();
    final v2Segments = v2Base.split('.').map((e) => int.tryParse(e) ?? 0).toList();

    final maxLen = v1Segments.length > v2Segments.length ? v1Segments.length : v2Segments.length;

    for (var i = 0; i < maxLen; i++) {
      final seg1 = i < v1Segments.length ? v1Segments[i] : 0;
      final seg2 = i < v2Segments.length ? v2Segments[i] : 0;

      if (seg1 > seg2) return 1;
      if (seg1 < seg2) return -1;
    }

    // If semantic base numbers are equal, check build number if available (+1, +2)
    if (v1PartsWithBuild.length > 1 && v2PartsWithBuild.length > 1) {
      final b1 = int.tryParse(v1PartsWithBuild[1]) ?? 0;
      final b2 = int.tryParse(v2PartsWithBuild[1]) ?? 0;
      if (b1 > b2) return 1;
      if (b1 < b2) return -1;
    }

    return 0;
  }

  /// Helper to test if latest version is newer than current version
  static bool isNewer(String latest, String current) {
    return compareVersions(latest, current) > 0;
  }
}
