// ignore_for_file: avoid_web_libraries_in_flutter
import 'dart:web_audio' as webaudio;

class WebAudioController {
  static bool _unlocked = false;
  static webaudio.AudioContext? _ctx;

  static Future<void> ensureUnlocked() async {
    if (_unlocked) return;
    try {
      _ctx ??= webaudio.AudioContext();
      final ctx = _ctx!;

      // لو الحالة معلقة، جرّب استئنافها (بعض المتصفحات تتطلب تفاعل المستخدم)
      try {
        // resume() موجودة في web audio وقد تكون Future
        final r = ctx.resume();
        if (r is Future) await r;
      } catch (_) {}

      // sampleRate قد يكون nullable — وفّر قيمة افتراضية
      final num sr = (ctx.sampleRate ?? 44100);

      // بافر صامت: قناة واحدة، طول 1 عينة، sampleRate معروف
      final buffer = ctx.createBuffer(1, 1, sr);
      final source = ctx.createBufferSource();
      source.buffer = buffer;

      // destination قد يكون nullable — استخدم !
      source.connectNode(ctx.destination!);

      // تشغيل فوري (صامت) لرفع حظر الصوت
      source.start(0);

      _unlocked = true;
    } catch (_) {
      // لو فشل، سنحاول مرة أخرى عند أي ضغطة لاحقة
    }
  }
}
