// ignore_for_file: avoid_web_libraries_in_flutter
import 'dart:async';
import 'dart:html' as html;
import 'dart:web_audio' as webaudio;

class WebAudioController {
  static bool _unlocked = false;
  static webaudio.AudioContext? _ctx;
  static html.AudioElement? _audio;
  static Completer<void>? _activeCompleter;

  static Future<void> ensureUnlocked() async {
    if (_unlocked) return;
    try {
      _ctx ??= webaudio.AudioContext();
      final ctx = _ctx!;
      try {
        final r = ctx.resume();
        if (r is Future) await r;
      } catch (_) {}

      final num sr = (ctx.sampleRate ?? 44100);
      final buffer = ctx.createBuffer(1, 1, sr);
      final source = ctx.createBufferSource();
      source.buffer = buffer;
      source.connectNode(ctx.destination!);
      source.start(0);

      _audio ??= html.AudioElement();
      _audio!
        ..preload = 'auto'
        ..muted = true
        ..src = '';

      try {
        final result = _audio!.play();
        if (result is Future) await result;
      } catch (_) {}

      _audio!.pause();
      _audio!.muted = false;
      _unlocked = true;
    } catch (_) {}
  }

  static Future<void> stop() async {
    try {
      if (_activeCompleter != null && !_activeCompleter!.isCompleted) {
        _activeCompleter!.complete();
      }
    } catch (_) {}

    try {
      _audio?.pause();
      _audio?.currentTime = 0;
      _audio?.removeAttribute('src');
      _audio?.load();
    } catch (_) {}
  }


  static Future<void> pause() async {
    try {
      _audio?.pause();
    } catch (_) {}
  }

  static Future<void> resume() async {
    try {
      final audio = _audio;
      if (audio == null) return;
      final result = audio.play();
      if (result is Future) await result;
    } catch (_) {}
  }

  static Future<void> playUrlAndWait(
    String url, {
    Duration timeout = const Duration(seconds: 120),
    Duration? forceFinishAfter,
  }) async {
    await ensureUnlocked();

    final audio = _audio ??= html.AudioElement();
    final c = Completer<void>();
    _activeCompleter = c;

    StreamSubscription? endedSub;
    StreamSubscription? errorSub;

    void done() {
      if (!c.isCompleted) c.complete();
    }

    try {
      audio.pause();
      audio.src = url;
      audio.preload = 'auto';
      audio.load();

      endedSub = audio.onEnded.listen((_) => done());
      errorSub = audio.onError.listen((_) => done());

      await Future.delayed(const Duration(milliseconds: 250));
      final playResult = audio.play();
      if (playResult is Future) await playResult;

      if (forceFinishAfter != null) {
        await Future.any([c.future, Future.delayed(forceFinishAfter)]);
      } else {
        await c.future.timeout(timeout, onTimeout: () {});
      }
    } finally {
      if (identical(_activeCompleter, c)) {
        _activeCompleter = null;
      }
      try { await endedSub?.cancel(); } catch (_) {}
      try { await errorSub?.cancel(); } catch (_) {}
      try { audio.pause(); } catch (_) {}
    }
  }
}
