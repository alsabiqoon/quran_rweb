import 'dart:async';
import 'dart:io';
import 'package:dio/dio.dart';
import 'package:path_provider/path_provider.dart';
import 'package:audioplayers/audioplayers.dart';

class AudioService {
  AudioService._() {
    _player.setReleaseMode(ReleaseMode.stop);
    _player.setPlayerMode(PlayerMode.mediaPlayer);
  }
  static final AudioService I = AudioService._();

  final Dio _dio = Dio();
  final AudioPlayer _player = AudioPlayer();

  CancelToken? _currentDownload;
  Completer<void>? _playCompleter;

  /// Example default: https://everyayah.com/data/Muhammad_Ayyoub_128kbps
  String _baseUrl = 'https://everyayah.com/data/Muhammad_Ayyoub_128kbps';
  String get baseUrl => _baseUrl;

  /// Call from UI after selecting a reciter
  void setReciter(String url) {
    _baseUrl = url.endsWith('/') ? url.substring(0, url.length - 1) : url;
  }

  // -------- Naming --------
  static String buildEveryAyahFileName(int surah, int ayah) {
    final s = surah.toString().padLeft(3, '0');
    final a = ayah.toString().padLeft(3, '0');
    return '$s$a.mp3';
  }

  // -------- Paths / cache --------
  Future<Directory> _appDir() => getApplicationDocumentsDirectory();

  Future<File> _localFile(String fileName) async {
    final fixed = _normalizeName(fileName);
    final dir = await _appDir();
    final f = File('${dir.path}/quran/$fixed');
    await f.parent.create(recursive: true);
    return f;
  }

  String _normalizeName(String name) {
    var n = name.trim();
    if (!n.endsWith('.mp3')) n = '$n.mp3';
    return n;
  }

  String _buildUrl(String fileName) {
    final fixed = _normalizeName(fileName);
    return '$_baseUrl/$fixed';
  }

  Future<bool> existsLocal(String fileName) async {
    final f = await _localFile(fileName);
    return f.exists();
  }

  Future<File> downloadIfNeeded(String fileName) async {
    final f = await _localFile(fileName);
    if (await f.exists()) return f;

    _currentDownload?.cancel('new download started');
    _currentDownload = CancelToken();

    final url = _buildUrl(fileName);
    await _dio.download(
      url,
      f.path,
      cancelToken: _currentDownload,
      options: Options(
        receiveTimeout: const Duration(minutes: 5),
        sendTimeout: const Duration(minutes: 1),
        followRedirects: true,
        validateStatus: (s) => s != null && s >= 200 && s < 400,
        headers: const {'User-Agent': 'QuranPlayer/1.0 (+everyayah.com)'},
      ),
    );
    return f;
  }

  // -------- Playback --------
  Future<void> _exclusiveStart() async {
    _playCompleter?.complete();
    _playCompleter = null;

    _currentDownload?.cancel('play interrupted');
    _currentDownload = null;

    try { await _player.stop(); } catch (_) {}
    try { await _player.release(); } catch (_) {}
    _player.setReleaseMode(ReleaseMode.stop);
  }

  Future<void> play(String fileName) async {
    await _exclusiveStart();
    final f = await downloadIfNeeded(fileName);
    await _player.play(DeviceFileSource(f.path));
  }

  Future<void> playAndWait(String fileName) async {
    await _exclusiveStart();
    final f = await downloadIfNeeded(fileName);

    final c = Completer<void>();
    _playCompleter = c;

    await _player.play(DeviceFileSource(f.path));

    late final StreamSubscription sub;
    sub = _player.onPlayerComplete.listen((_) {
      if (!c.isCompleted) c.complete();
      sub.cancel();
    });

    try {
      await c.future;
    } finally {
      try { await sub.cancel(); } catch (_) {}
      if (_playCompleter == c) _playCompleter = null;
    }
  }

  Future<void> stop() async {
    _currentDownload?.cancel('stopped');
    _currentDownload = null;

    try { await _player.stop(); } catch (_) {}
    try { await _player.release(); } catch (_) {}

    if (_playCompleter != null && !_playCompleter!.isCompleted) {
      _playCompleter!.complete();
    }
    _playCompleter = null;
  }

  Future<void> pause() async {
    try { await _player.pause(); } catch (_) {}
  }

  Future<void> resume() async {
    try { await _player.resume(); } catch (_) {}
  }

  // -------- High-level ayah helpers --------
  Future<void> playAyah(int surah, int ayah) {
    final file = buildEveryAyahFileName(surah, ayah);
    return play(file);
  }

  Future<void> playAyahAndWait(int surah, int ayah) {
    final file = buildEveryAyahFileName(surah, ayah);
    return playAndWait(file);
  }

  // -------- Utilities --------
  Future<void> bulkDownload(
    List<String> fileNames, {
    Function(int done, int total)? onProgress,
  }) async {
    int done = 0;
    for (final name in fileNames) {
      await downloadIfNeeded(name);
      done++;
      onProgress?.call(done, fileNames.length);
    }
  }

  Future<void> purgeAll() async {
    final dir = await _appDir();
    final q = Directory('${dir.path}/quran');
    if (await q.exists()) {
      await q.delete(recursive: true);
    }
  }

  Future<int> usedBytes() async {
    final dir = await _appDir();
    final q = Directory('${dir.path}/quran');
    if (!await q.exists()) return 0;
    int total = 0;
    await for (final ent in q.list(recursive: true, followLinks: false)) {
      if (ent is File) total += await ent.length();
    }
    return total;
  }

  Stream<void> get onComplete => _player.onPlayerComplete;
}






