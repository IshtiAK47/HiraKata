/// Named route path constants for the HiraKata app.
///
/// Centralises all route paths to avoid magic strings.
class RouteNames {
  RouteNames._();

  static const String splash = '/';
  static const String home = '/home';
  static const String learn = '/learn/:type';
  static const String lesson = '/lesson/:type/:id';
  static const String practice = '/practice';
  static const String progress = '/progress';
  static const String settings = '/settings';
  static const String developerInfo = '/developer-info';

  // ── Helpers for parameterized routes ─────────────────────────────

  /// Build a learn route for [type] (hiragana or katakana).
  static String learnPath(String type) => '/learn/$type';

  /// Build a lesson route for a specific kana by [type] and [id].
  static String lessonPath(String type, String id) => '/lesson/$type/$id';
}
