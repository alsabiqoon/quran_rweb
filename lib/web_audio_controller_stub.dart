class WebAudioController {
  static void ensureUnlocked() {}
  static Future<void> stop() async {}
  static Future<void> pause() async {}
  static Future<void> resume() async {}
  static Future<void> playUrlAndWait(
    String url, {
    Duration timeout = const Duration(seconds: 120),
    Duration? forceFinishAfter,
  }) async {}
}
