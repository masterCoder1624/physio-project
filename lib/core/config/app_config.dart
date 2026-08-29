/// Centralized Application & GitHub Release Update Configuration for RehabZ
class AppConfig {
  /// GitHub repository owner / organization.
  /// Replace with your actual GitHub username/organization if different.
  static const String githubOwner = 'masterCoder1624';

  /// GitHub repository name.
  /// Replace with your actual GitHub repository name if different.
  static const String githubRepo = 'physio-project';

  /// The fallback / expected APK asset name in GitHub Releases.
  /// If empty, the updater automatically selects any asset ending with '.apk'.
  static const String defaultApkAssetName = 'app-release.apk';

  /// Minimum cooldown between automatic background update checks to avoid unnecessary API requests.
  static const Duration updateCheckCooldown = Duration(hours: 1);

  /// Network timeout for GitHub API queries and asset downloads.
  static const Duration networkTimeout = Duration(seconds: 30);

  /// Returns the public GitHub Releases API URL for the latest release.
  static String get latestReleaseApiUrl =>
      'https://api.github.com/repos/$githubOwner/$githubRepo/releases/latest';

  /// Returns the user-friendly GitHub Releases web page URL.
  static String get releasesWebUrl =>
      'https://github.com/$githubOwner/$githubRepo/releases';
}
