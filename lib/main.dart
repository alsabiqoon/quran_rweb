// main.dart
import 'dart:async';
import 'dart:convert';
import 'dart:math';

import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle;

import 'web_audio_controller_stub.dart'
    if (dart.library.html) 'web_audio_controller.dart' as webaudio;

import 'audio_service.dart';
import 'l10n_simple.dart';
import 'settings_page.dart';

void main() => runApp(MyApp());

class MyApp extends StatefulWidget {
  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  String _lang = 'ar';
  void _setLang(String v) => setState(() => _lang = v);

  @override
  Widget build(BuildContext context) {
    return LangScope(
      lang: _lang,
      onChange: _setLang,
      child: Directionality(
        textDirection: L10nSimple.textDir(_lang),
        child: MaterialApp(
          title: L10nSimple.t(_lang, 'appTitle'),
          home: const SettingsPage(),
          debugShowCheckedModeBanner: false,
        ),
      ),
    );
  }
}

String convertToArabicNumber(int number) {
  const digits = ['٠', '١', '٢', '٣', '٤', '٥', '٦', '٧', '٨', '٩'];
  return number.toString().split('').map((c) => digits[int.parse(c)]).join();
}

// Arabic → English Surah names (fallback)
const Map<String, String> kSurahArToEn = {
  "الفاتحة": "Al-Fatihah",
  "البقرة": "Al-Baqarah",
  "آل عمران": "Aal-Imran",
  "النساء": "An-Nisa",
  "المائدة": "Al-Ma'idah",
  "الأنعام": "Al-An'am",
  "الأعراف": "Al-A'raf",
  "الأنفال": "Al-Anfal",
  "التوبة": "At-Tawbah",
  "يونس": "Yunus",
  "هود": "Hud",
  "يوسف": "Yusuf",
  "الرعد": "Ar-Ra'd",
  "إبراهيم": "Ibrahim",
  "ابراهيم": "Ibrahim",
  "الحجر": "Al-Hijr",
  "النحل": "An-Nahl",
  "الإسراء": "Al-Isra",
  "الكهف": "Al-Kahf",
  "مريم": "Maryam",
  "طه": "Ta-Ha",
  "الأنبياء": "Al-Anbiya",
  "الحج": "Al-Hajj",
  "المؤمنون": "Al-Mu'minun",
  "النور": "An-Nur",
  "الفرقان": "Al-Furqan",
  "الشعراء": "Ash-Shu'ara",
  "النمل": "An-Naml",
  "القصص": "Al-Qasas",
  "العنكبوت": "Al-Ankabut",
  "الروم": "Ar-Rum",
  "لقمان": "Luqman",
  "السجدة": "As-Sajdah",
  "الأحزاب": "Al-Ahzab",
  "سبأ": "Saba",
  "سبإ": "Saba",
  "فاطر": "Fatir",
  "يس": "Ya-Sin",
  "يسۤ": "Ya-Sin",
  "الصافات": "As-Saffat",
  "ص": "Sad",
  "الزمر": "Az-Zumar",
  "غافر": "Ghafir",
  "فصلت": "Fussilat",
  "الشورى": "Ash-Shura",
  "الزخرف": "Az-Zukhruf",
  "الدخان": "Ad-Dukhan",
  "الجاثية": "Al-Jathiyah",
  "الأحقاف": "Al-Ahqaf",
  "محمد": "Muhammad",
  "الفتح": "Al-Fath",
  "الحجرات": "Al-Hujurat",
  "ق": "Qaf",
  "الذاريات": "Adh-Dhariyat",
  "الطور": "At-Tur",
  "النجم": "An-Najm",
  "القمر": "Al-Qamar",
  "الرحمن": "Ar-Rahman",
  "الواقعة": "Al-Waqi'ah",
  "الحديد": "Al-Hadid",
  "المجادلة": "Al-Mujadila",
  "الحشر": "Al-Hashr",
  "الممتحنة": "Al-Mumtahanah",
  "الصف": "As-Saff",
  "الجمعة": "Al-Jumu'ah",
  "المنافقون": "Al-Munafiqun",
  "التغابن": "At-Taghabun",
  "الطلاق": "At-Talaq",
  "التحريم": "At-Tahrim",
  "الملك": "Al-Mulk",
  "القلم": "Al-Qalam",
  "الحاقة": "Al-Haqqah",
  "المعارج": "Al-Ma'arij",
  "نوح": "Nuh",
  "الجن": "Al-Jinn",
  "المزمل": "Al-Muzzammil",
  "المدثر": "Al-Muddaththir",
  "القيامة": "Al-Qiyamah",
  "الإنسان": "Al-Insan",
  "المرسلات": "Al-Mursalat",
  "النبإ": "An-Naba",
  "النازعات": "An-Nazi'at",
  "عبس": "Abasa",
  "التكوير": "At-Takwir",
  "الإنفطار": "Al-Infitar",
  "المطففين": "Al-Mutaffifin",
  "الانشقاق": "Al-Inshiqaq",
  "البروج": "Al-Buruj",
  "الطارق": "At-Tariq",
  "الأعلى": "Al-A'la",
  "الغاشية": "Al-Ghashiyah",
  "الفجر": "Al-Fajr",
  "البلد": "Al-Balad",
  "الشمس": "Ash-Shams",
  "الليل": "Al-Layl",
  "الضحى": "Ad-Duha",
  "الشرح": "Ash-Sharh",
  "التين": "At-Tin",
  "العلق": "Al-Alaq",
  "القدر": "Al-Qadr",
  "البينة": "Al-Bayyinah",
  "الزلزلة": "Az-Zalzalah",
  "العاديات": "Al-Adiyat",
  "القارعة": "Al-Qari'ah",
  "التكاثر": "At-Takathur",
  "العصر": "Al-Asr",
  "الهمزة": "Al-Humazah",
  "الفيل": "Al-Fil",
  "قريش": "Quraish",
  "الماعون": "Al-Ma'un",
  "الكوثر": "Al-Kawthar",
  "الكافرون": "Al-Kafirun",
  "النصر": "An-Nasr",
  "المسد": "Al-Masad",
  "الإخلاص": "Al-Ikhlas",
  "الفلق": "Al-Falaq",
  "الناس": "An-Nas",
};

enum RoundPhase { idle, question, answer }

class PlayPage extends StatefulWidget {
  final int repeatCount;
  final int ayahsAfter;
  final int delaySeconds; // minutes
  final List<String> selectedSurahs;

  // Passed from SettingsPage
  final String reciterKey;
  final String reciterUrl;

  const PlayPage({
    Key? key,
    required this.repeatCount,
    required this.ayahsAfter,
    required this.delaySeconds,
    required this.selectedSurahs,
    required this.reciterKey,
    required this.reciterUrl,
  }) : super(key: key);

  @override
  _PlayPageState createState() => _PlayPageState();
}

class _PlayPageState extends State<PlayPage> with SingleTickerProviderStateMixin {
  String get _lang {
    try {
      return LangScope.of(context).lang;
    } catch (_) {
      return 'ar';
    }
  }

  String t(String k) => L10nSimple.t(_lang, k);

  final AudioPlayer _player = AudioPlayer();

  // Quran files (filtered)
  List<String> _files = [];
  Set<String> _played = {};
  // Map: numeric main index (e.g. 001234) -> file key
  final Map<int, String> _numToFile = {};

  int _currentIndex = 0;
  int _countdown = 0;
  bool _playing = false;
  bool _stopRequested = false;

  bool _canPressAnswer = false;
  bool _answerPlayed = false;
  int _currentMainNumber = 0;
  bool _answeredManually = false;
  Completer<void>? _waitForAnswer;

  Map<String, dynamic> _ayahJson = {};
  Map<String, dynamic>? _questionAyah;
  Map<String, dynamic>? _currentAnswerAyah;

  bool _skipped = false;
  Timer? _hasbukTimer;

  // --- Round timing & summary ---
  DateTime? _roundStart;
  Duration _roundElapsed = Duration.zero;

  // Full summary for the dialog
  final List<Map<String, Object>> _roundSummary = [];

  String? _lastQuestionSurahAr;
  int? _lastQuestionAyahNum;

  bool _paused = false;
  Completer<void>? _pauseCompleter;
  bool _isPlayingAyah = false;

  RoundPhase _phase = RoundPhase.idle;

  bool _jumping = false;
  int _roundId = 0;

  int _answeredManuallyCount = 0;
  int _autoSkippedCount = 0;
  int _skippedManuallyCount = 0;

  // --- START / HASBUK shuffled queues ---
  List<String> _startFiles = [];
  List<String> _hasbukFiles = [];
  List<String> _startQueue = [];
  List<String> _hasbukQueue = [];
  String? _lastStart, _lastHasbuk;

  // play ta'awwudh once (assets/begin/001000 & 001001)
  bool _taawudhPlayed = false;

  // Animated bar under the Answer card
  late final AnimationController _answerBarController;

  @override
  void initState() {
    super.initState();
    AudioService.I.setReciter(widget.reciterUrl);

    _answerBarController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1800),
      lowerBound: 0.0,
      upperBound: 1.0,
    );

    _loadFileList();
  }

  @override
  void dispose() {
    _hardStop();
    try {
      _answerBarController.dispose();
    } catch (_) {}
    super.dispose();
  }

  // Extract 6-digit main number from filename/path
  int? _parseMainNumber(String s) {
    final m = RegExp(r'(\d{6})').firstMatch(s);
    if (m == null) return null;
    return int.tryParse(m.group(1)!);
  }

  // Web must be "unlocked" by user gesture before audio can play.
  void _unlockIfWeb() {
    if (kIsWeb) {
      webaudio.WebAudioController.ensureUnlocked();
    }
  }

  // Stop/cancel everything and invalidate the current round.
  Future<void> _killAllAudioAndInvalidateRound() async {
    _stopRequested = true;
    _roundId++;

    try {
      _hasbukTimer?.cancel();
    } catch (_) {}
    _hasbukTimer = null;

    try {
      _pauseCompleter?.complete();
    } catch (_) {}
    _pauseCompleter = null;

    try {
      _waitForAnswer?.complete();
    } catch (_) {}
    _waitForAnswer = null;

    try {
      await _player.stop();
    } catch (_) {}
    try {
      await _player.release();
    } catch (_) {}
    try {
      await AudioService.I.stop();
    } catch (_) {}

    _isPlayingAyah = false;
  }

  // =============== HARD STOP HELPERS =================
  Future<void> _hardStop() async {
    _stopRequested = true;

    try {
      _hasbukTimer?.cancel();
    } catch (_) {}
    _hasbukTimer = null;

    try {
      if (_pauseCompleter != null && !_pauseCompleter!.isCompleted) {
        _pauseCompleter!.complete();
      }
    } catch (_) {}
    _pauseCompleter = null;
    _paused = false;

    try {
      if (_waitForAnswer != null && !_waitForAnswer!.isCompleted) {
        _waitForAnswer!.complete();
      }
    } catch (_) {}
    _waitForAnswer = null;

    try {
      await _player.stop();
    } catch (_) {}
    try {
      await _player.release();
    } catch (_) {}
    try {
      await AudioService.I.stop();
    } catch (_) {}

    _isPlayingAyah = false;
    _playing = false;

    // Guard stop() against disposed ticker
    try {
      if (mounted && _answerBarController.isAnimating) {
        _answerBarController.stop();
      }
    } catch (_) {}
  }

  Future<void> _hardStopAndGoHome() async {
    await _hardStop();
    if (!mounted) return;
    setState(() {
      _phase = RoundPhase.idle;
      _canPressAnswer = false;
      _answerPlayed = false;
      _questionAyah = null;
      _currentAnswerAyah = null;
      _countdown = 0;
    });
    if (Navigator.canPop(context)) {
      Navigator.pop(context);
    } else {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const SettingsPage()),
      );
    }
  }

  Future<void> _loadFileList() async {
    final manifestStr = await rootBundle.loadString('AssetManifest.json');
    final Map<String, dynamic> manifest =
        json.decode(manifestStr) as Map<String, dynamic>;

    // We only use assets for start/hasbuk (local)
    final allMp3 = manifest.keys.where((k) => k.endsWith('.mp3')).toList();

    final jsonString = await rootBundle.loadString('assets/ayah_texts.json');
    _ayahJson = json.decode(jsonString) as Map<String, dynamic>;

    // Normalize selected surah names (both AR & EN supported)
    final selected = widget.selectedSurahs.map((s) => s.trim()).toSet();
    final bool selectAll = selected.isEmpty;

    _files.clear();
    _numToFile.clear();

    for (final entry in _ayahJson.entries) {
      final fileKey = entry.key; // e.g. "001234.mp3"
      final info = entry.value; // { text, surah, ayah, ... }
      if (info is! Map) continue;

      final surahAr =
          (info['surah'] ?? info['surah_ar'] ?? info['surahName'] ?? '')
              .toString()
              .trim();
      final surahEn = (info['surah_en'] ??
              info['surahEn'] ??
              kSurahArToEn[surahAr] ??
              surahAr)
          .toString()
          .trim();

      final include =
          selectAll || selected.contains(surahAr) || selected.contains(surahEn);

      if (include) {
        _files.add(fileKey);
        final n = _parseMainNumber(fileKey);
        if (n != null) _numToFile[n] = fileKey;
      }
    }

    // Start/hasbuk local assets
    _startFiles =
        allMp3.where((p) => p.startsWith('assets/start/')).toList()..sort();
    _hasbukFiles =
        allMp3.where((p) => p.startsWith('assets/hasbuk/')).toList()..sort();
    _reshuffleQueue(_startFiles, _startQueue);
    _reshuffleQueue(_hasbukFiles, _hasbukQueue);

    if (!mounted) return;

    if (_files.isEmpty) {
      // Visible hint if filtering produced nothing — and DO NOT start questions.
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            _lang == 'ar'
                ? 'لا توجد آيات ضمن السور المحددة. يرجى اختيار سور أخرى من الإعدادات.'
                : 'No ayahs matched the selected surahs. Please pick other surahs in Settings.',
          ),
        ),
      );
      setState(() {});
      return;
    }

    setState(() {});
    _startQuestions();
  }

  void _reshuffleQueue(List<String> src, List<String> dst, {String? avoid}) {
    dst
      ..clear()
      ..addAll(src);
    dst.shuffle(Random());
    if (avoid != null && dst.length > 1 && dst.first == avoid) {
      final first = dst.removeAt(0);
      dst.add(first);
    }
  }

  String? _nextFromQueue(List<String> src, List<String> queue, {String? avoid}) {
    if (src.isEmpty) return null;
    if (queue.isEmpty) _reshuffleQueue(src, queue, avoid: avoid);
    return queue.removeAt(0);
  }

  Future<void> _playShuffledStart(int rid) async {
    final p = _nextFromQueue(_startFiles, _startQueue, avoid: _lastStart) ??
        'assets/start/1.mp3';
    _lastStart = p;
    await _playAssetG(p, rid);
  }

  Future<void> _playShuffledHasbuk(int rid) async {
    final p = _nextFromQueue(_hasbukFiles, _hasbukQueue, avoid: _lastHasbuk) ??
        'assets/hasbuk/1.mp3';
    _lastHasbuk = p;
    await _playAssetG(p, rid);
  }

  /// taʿawwudh once from assets
  Future<void> _playTaawudhOnce(int rid) async {
    if (_taawudhPlayed) return;
    Future<void> _try(String path) async {
      try {
        await _playAssetG(path, rid);
      } catch (_) {}
    }

    await _try('assets/begin/001000.mp3');
    await _try('assets/begin/001001.mp3');
    _taawudhPlayed = true;
  }

  Future<void> _checkPause() async {
    while (_paused) {
      _pauseCompleter = Completer<void>();
      await _pauseCompleter!.future;
    }
  }

  Future<void> _playAssetG(String path, int rid) async {
    if (_stopRequested || rid != _roundId) return;
    await _checkPause();
    if (!mounted || rid != _roundId) return;
    setState(() => _isPlayingAyah = true);

    await _player.stop();
    await _player.play(AssetSource(path.replaceFirst('assets/', '')));
    await _player.onPlayerComplete.first;

    if (!mounted || rid != _roundId) return;
    setState(() => _isPlayingAyah = false);
  }

  // Build a full URL from reciter base + file name (ensures single '/')
  String _buildReciterUrl(String base, String fileName) {
    final b = base.endsWith('/') ? base.substring(0, base.length - 1) : base;
    return '$b/$fileName';
  }

  /// Plays an ayah online.
  ///   1) AudioService (primary).
  ///   2) Fallback to audioplayers UrlSource.
  Future<void> _playAyahOnline(String assetLikePathOrFileName, int rid) async {
    if (_stopRequested || rid != _roundId) return;
    await _checkPause();
    if (!mounted || rid != _roundId) return;
    setState(() => _isPlayingAyah = true);

    final fileName = assetLikePathOrFileName.split('/').last;

    try {
      _unlockIfWeb();
      await AudioService.I.playAndWait(fileName);
    } catch (_) {
      final url = _buildReciterUrl(widget.reciterUrl, fileName);
      try {
        await _player.stop();
        await _player.play(UrlSource(url));
        await _player.onPlayerComplete.first;
      } catch (_) {}
    }

    if (!mounted || rid != _roundId) return;
    setState(() => _isPlayingAyah = false);
  }

  Future<void> _startCountdown() async {
    int totalSeconds = widget.delaySeconds * 60;
    if (!mounted) return;
    setState(() => _countdown = totalSeconds);
    for (int i = totalSeconds; i > 0; i--) {
      if (_stopRequested || _answeredManually || _answerPlayed || _skipped) return;
      await _checkPause();
      await Future.delayed(const Duration(seconds: 1));
      if (!mounted) return;
      setState(() => _countdown--);
    }
  }

  Future<void> _startQuestions() async {
    if (_playing || _files.isEmpty) return;

    if (!mounted) return;
    setState(() {
      _playing = true;
      _stopRequested = false;
      _currentIndex = 0;
      _answeredManuallyCount = 0;
      _autoSkippedCount = 0;
      _skippedManuallyCount = 0;
      _phase = RoundPhase.idle;
      _roundSummary.clear();
    });

    _roundStart = DateTime.now();
    for (int i = 0; i < widget.repeatCount; i++) {
      if (_stopRequested) break;
      await _checkPause();

      _roundId++;
      final int rid = _roundId;

      _waitForAnswer = Completer<void>();
      _answeredManually = false;
      _skipped = false;
      _hasbukTimer?.cancel();

      if (!mounted || rid != _roundId) return;
      setState(() {
        _currentIndex = i + 1;
        _answerPlayed = false;
        _canPressAnswer = false;
        _questionAyah = null;
        _currentAnswerAyah = null;
        _phase = RoundPhase.question;
        _jumping = false;
      });

      if (_played.length == _files.length) _played.clear();
      final remaining = _files.where((f) => !_played.contains(f)).toList();
      final randomFile = remaining[Random().nextInt(remaining.length)];
      final baseName = randomFile.split('/').last.replaceAll('.mp3', '');
      _currentMainNumber =
          int.tryParse(baseName) ?? (_parseMainNumber(randomFile) ?? 0);
      _played.add(randomFile);

      final fileName = randomFile.split('/').last;
      final info = _ayahJson[fileName] ?? _ayahJson[randomFile];

      // Always set a safe question card so UI shows even if info is missing
      if (info is Map) {
        final String surahAr = (info["surah"] ?? "").toString();
        final String surahEn = kSurahArToEn[surahAr] ?? "";
        final int ayah = int.tryParse("${info["ayah"] ?? "0"}") ?? 0;

        _questionAyah = {
          "text": info["text"] ?? "",
          "surah": surahAr,
          "ayah": ayah,
        };

        _roundSummary.add({
          "index": i + 1,
          "surahAr": surahAr,
          "surahEn": surahEn,
          "ayah": ayah,
        });
      } else {
        _questionAyah = {"text": '', "surah": '', "ayah": 0};
      }

      _lastQuestionSurahAr = (_questionAyah?["surah"] ?? "").toString();
      _lastQuestionAyahNum =
          int.tryParse((_questionAyah?["ayah"] ?? "0").toString()) ?? 0;

      try {
        _unlockIfWeb(); // must happen before first play on web
        await _playShuffledStart(rid);
        if (i == 0) await _playTaawudhOnce(rid);
        await _playAyahOnline(randomFile, rid);

        if (!mounted || rid != _roundId) return;
        setState(() {
          _canPressAnswer = true;
        });

        await _startCountdown();

        _hasbukTimer = Timer(const Duration(seconds: 5), () async {
          if (rid != _roundId) return;
          if (_waitForAnswer == null || _waitForAnswer!.isCompleted) return;
          if (!_skipped && !_answeredManually && !_answerPlayed && !_stopRequested) {
            if (!mounted || rid != _roundId) return;
            setState(() {
              _canPressAnswer = false;
              _phase = RoundPhase.idle;
            });
            _autoSkippedCount++;
            await _playShuffledHasbuk(rid);
            if (!_waitForAnswer!.isCompleted) _waitForAnswer!.complete();
          }
        });

        await _waitForAnswer!.future;
      } catch (_) {}
    }

    if (!mounted) return;

    // stop absolutely everything BEFORE dialog
    await _killAllAudioAndInvalidateRound();

    setState(() {
      _playing = false;
      _phase = RoundPhase.idle;
    });

    _showFinishDialog();
  }

  void _togglePause() {
    setState(() => _paused = !_paused);
    if (!_paused && _pauseCompleter != null && !_pauseCompleter!.isCompleted) {
      _pauseCompleter!.complete();
    }
  }

  void _skipToNextRound() async {
    if (_jumping) return;
    if (_waitForAnswer == null || _waitForAnswer!.isCompleted) return;

    _jumping = true;
    _hasbukTimer?.cancel();
    _skipped = true;
    _skippedManuallyCount++;

    try {
      await _player.stop();
    } catch (_) {}
    try {
      await _player.release();
    } catch (_) {}
    try {
      await AudioService.I.stop();
    } catch (_) {}

    try {
      if (mounted && _answerBarController.isAnimating) {
        _answerBarController.stop();
      }
    } catch (_) {}

    if (!mounted) return;
    setState(() {
      _countdown = 0;
      _canPressAnswer = false;
      _answerPlayed = false;
      _questionAyah = null;
      _currentAnswerAyah = null;
      _phase = RoundPhase.idle;
    });

    if (!_waitForAnswer!.isCompleted) _waitForAnswer!.complete();
  }

  void _showFinishDialog() {
    final total = widget.repeatCount;
    final manualAnswers = _answeredManuallyCount;
    final autoHasbuk = _autoSkippedCount;
    final skipped = _skippedManuallyCount;
    final unanswered = total - manualAnswers - autoHasbuk - skipped;

    final now = DateTime.now();
    if (_roundStart != null) {
      _roundElapsed = now.difference(_roundStart!);
    }
    final mins = _roundElapsed.inMinutes;
    final secs = _roundElapsed.inSeconds % 60;
    final elapsedStr = _lang == 'ar'
        ? "${convertToArabicNumber(mins)}:${convertToArabicNumber(secs)} دقيقة"
        : "${mins.toString().padLeft(2, '0')}:${secs.toString().padLeft(2, '0')} min";

    String digits(Object n) =>
        _lang == 'ar' ? convertToArabicNumber(int.tryParse(n.toString()) ?? 0) : n.toString();

    final items = _roundSummary.map((m) {
      final idx = m["index"] as int? ?? 0;
      final surahAr = (m["surahAr"] as String? ?? "").trim();
      final surahEn = (m["surahEn"] as String? ?? "").trim();
      final ayah = m["ayah"] as int? ?? 0;
      final surahDisplay =
          _lang == 'ar' ? (surahAr.isNotEmpty ? surahAr : surahEn) : (surahEn.isNotEmpty ? surahEn : surahAr);
      final qLabel = _lang == 'ar' ? "السؤال ${digits(idx)}" : "Q${digits(idx)}";
      final ayahLabel = _lang == 'ar' ? "الآية" : "Ayah";
      return "$qLabel: $surahDisplay — $ayahLabel ${digits(ayah)}";
    }).toList();

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) {
        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: Column(
            children: const [
              Icon(Icons.check_circle, size: 44),
              SizedBox(height: 8),
            ],
          ),
          content: SingleChildScrollView(
            primary: false,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  _lang == 'ar' ? "✅ انتهت المسابقة" : "✅ Round finished",
                  textAlign: TextAlign.center,
                  style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),

                // ✅ SAFE SCROLLABLE LIST FOR DIALOG (no ListView)
                if (items.isNotEmpty)
                  Container(
                    padding: const EdgeInsets.all(10),
                    margin: const EdgeInsets.only(bottom: 10),
                    decoration: BoxDecoration(
                      color: Colors.black12.withOpacity(0.05),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: ConstrainedBox(
                      constraints: const BoxConstraints(maxHeight: 260),
                      child: Scrollbar(
                        thumbVisibility: true,
                        child: SingleChildScrollView(
                          primary: false,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              for (final s in items)
                                Padding(
                                  padding: const EdgeInsets.symmetric(vertical: 3.0),
                                  child: Text(s, style: const TextStyle(fontSize: 15)),
                                ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),

                Row(children: [
                  const Icon(Icons.query_stats),
                  const SizedBox(width: 8),
                  Text(
                    _lang == 'ar' ? "عدد الأسئلة: ${digits(total)}" : "Questions: ${digits(total)}",
                    style: const TextStyle(fontSize: 16),
                  ),
                ]),
                Row(children: [
                  const Icon(Icons.touch_app),
                  const SizedBox(width: 8),
                  Text(
                    _lang == 'ar'
                        ? "إجابات يدوية: ${digits(manualAnswers)}"
                        : "Manual answers: ${digits(manualAnswers)}",
                    style: const TextStyle(fontSize: 16),
                  ),
                ]),
                Row(children: [
                  const Icon(Icons.volume_mute),
                  const SizedBox(width: 8),
                  Text(
                    _lang == 'ar'
                        ? "أُجيبت تلقائيًا (حسبك): ${digits(autoHasbuk)}"
                        : "Auto (Hasbuk): ${digits(autoHasbuk)}",
                    style: const TextStyle(fontSize: 16),
                  ),
                ]),
                Row(children: [
                  const Icon(Icons.skip_next),
                  const SizedBox(width: 8),
                  Text(
                    _lang == 'ar'
                        ? "تم التخطي يدويًا: ${digits(skipped)}"
                        : "Manually skipped: ${digits(skipped)}",
                    style: const TextStyle(fontSize: 16),
                  ),
                ]),
                if (unanswered > 0)
                  Row(children: [
                    const Icon(Icons.help_outline),
                    const SizedBox(width: 8),
                    Text(
                      _lang == 'ar'
                          ? "غير مُجاب: ${digits(unanswered)}"
                          : "Unanswered: ${digits(unanswered)}",
                      style: const TextStyle(fontSize: 16),
                    ),
                  ]),
                const Divider(height: 18),
                Row(children: [
                  const Icon(Icons.timer),
                  const SizedBox(width: 8),
                  Text(
                    _lang == 'ar' ? "المدة: $elapsedStr" : "Time spent: $elapsedStr",
                    style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                  ),
                ]),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () async {
                await _killAllAudioAndInvalidateRound();
                if (context.mounted) Navigator.pop(context);
              },
              child: Text(_lang == 'ar' ? "إغلاق" : "Close", style: const TextStyle(fontSize: 16)),
            ),
            TextButton(
              onPressed: () async {
                await _killAllAudioAndInvalidateRound();
                if (!context.mounted) return;
                Navigator.pop(context);
                _stopRequested = false;
                _playing = false;
                _answerPlayed = false;
                _taawudhPlayed = false;
                _roundStart = DateTime.now();
                _startQuestions();
              },
              child: Text(_lang == 'ar' ? "إعادة البدء" : "Restart",
                  style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
            ),
          ],
        );
      },
    );
  }

  Future<void> _playAnswerAyahs() async {
    if (!_canPressAnswer || _answerPlayed) return;

    _hasbukTimer?.cancel();

    try {
      await _player.stop();
    } catch (_) {}
    try {
      await _player.release();
    } catch (_) {}
    try {
      await AudioService.I.stop();
    } catch (_) {}

    _answeredManually = true;
    _answeredManuallyCount++;
    final int rid = _roundId;

    if (!mounted || rid != _roundId) return;
    setState(() {
      _countdown = 0;
      _canPressAnswer = false;
      _answerPlayed = true;
      _phase = RoundPhase.answer;
    });

    try {
      _answerBarController
        ..reset()
        ..repeat();
    } catch (_) {}

    int played = 0;
    while (played < widget.ayahsAfter && !_stopRequested && rid == _roundId) {
      await _checkPause();

      // Prefer direct numeric lookup (faster & exact)
      String? next;
      for (int offset = 1; offset < 2000; offset++) {
        final n = _currentMainNumber + offset;
        final candidate = _numToFile[n];
        if (candidate != null) {
          next = candidate;
          _currentMainNumber = n;
          break;
        }
      }
      if (next == null) break;

      final key = next.split('/').last;
      final info = _ayahJson[key] ?? _ayahJson[next];

      if (info is Map) {
        if (!mounted || rid != _roundId) return;
        setState(() {
          _currentAnswerAyah = {
            "text": info["text"] ?? "",
            "surah": info["surah"] ?? "",
            "ayah": info["ayah"] ?? 0,
          };
        });
      } else {
        setState(() {
          _currentAnswerAyah = {"text": '', "surah": '', "ayah": 0};
        });
      }
      _played.add(next);

      _unlockIfWeb();
      await _playAyahOnline(next, rid);
      played++;
    }

    if (!_stopRequested && rid == _roundId) {
      await _playShuffledHasbuk(rid);
    }

    try {
      if (mounted && _answerBarController.isAnimating) {
        _answerBarController.stop();
      }
    } catch (_) {}

    if (_waitForAnswer != null && !_waitForAnswer!.isCompleted) {
      _waitForAnswer!.complete();
    }
  }

  double _measureHeight(
      String text, double maxWidth, double fontSize, double lineHeight) {
    final tp = TextPainter(
      text: TextSpan(
        text: text,
        style: TextStyle(
          fontSize: fontSize,
          height: lineHeight,
          fontWeight: FontWeight.bold,
        ),
      ),
      textAlign: TextAlign.center,
      textDirection: L10nSimple.textDir(_lang),
      maxLines: null,
    )..layout(maxWidth: maxWidth);
    return tp.size.height;
  }

  Widget _buildAyahCard(
    Map<String, dynamic> ayahData,
    Color bgColor, {
    double? progress,
  }) {
    final ayahText = (ayahData["text"] ?? "").toString();

    final surahNameAr =
        (ayahData["surah"] ?? ayahData["surah_ar"] ?? ayahData["surahName"] ?? "")
            .toString();

    final surahNameEnRaw =
        (ayahData["surah_en"] ?? ayahData["surahEn"] ?? "").toString();
    final String surahNameForEn =
        surahNameEnRaw.isNotEmpty ? surahNameEnRaw : (kSurahArToEn[surahNameAr] ?? surahNameAr);

    final ayahNum = (ayahData["ayah"] is int)
        ? ayahData["ayah"] as int
        : int.tryParse("${ayahData["ayah"]}") ?? 0;

    final String subtitle = _lang == 'ar'
        ? "سورة $surahNameAr - الآية ${convertToArabicNumber(ayahNum)}"
        : "Surah $surahNameForEn - Ayah $ayahNum";

    const double lineHeight = 1.6;
    const double footerHeight = 36;

    return Card(
      color: bgColor.withOpacity(0.95),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
      child: Padding(
        padding: const EdgeInsets.all(10),
        child: LayoutBuilder(
          builder: (context, constraints) {
            final double maxTextArea =
                (constraints.maxHeight - footerHeight - 4).clamp(120.0, constraints.maxHeight);

            final double baseFont = (constraints.maxWidth / 11).clamp(22.0, 34.0);

            final double h =
                _measureHeight(ayahText, constraints.maxWidth, baseFont, lineHeight);
            final bool isOverflowing = h > maxTextArea;

            final textWidget = Text(
              ayahText,
              textAlign: TextAlign.center,
              softWrap: true,
              style: TextStyle(
                fontSize: baseFont,
                height: lineHeight,
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            );

            return Stack(
              children: [
                Padding(
                  padding: const EdgeInsets.only(bottom: footerHeight + 4),
                  child: SizedBox(
                    height: maxTextArea,
                    child: isOverflowing
                        ? Scrollbar(
                            thumbVisibility: true,
                            child: SingleChildScrollView(
                              primary: false, // avoid PrimaryScrollController warnings
                              physics: const BouncingScrollPhysics(),
                              child: textWidget,
                            ),
                          )
                        : Center(child: textWidget),
                  ),
                ),
                if (isOverflowing)
                  Positioned(
                    left: 0,
                    right: 0,
                    bottom: footerHeight + 3,
                    height: 20,
                    child: IgnorePointer(
                      child: Container(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                            colors: [
                              bgColor.withOpacity(0.0),
                              bgColor.withOpacity(0.95)
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                Positioned(
                  left: 0,
                  right: 0,
                  bottom: 0,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        height: footerHeight,
                        decoration: BoxDecoration(
                          color: Colors.black.withOpacity(0.25),
                          borderRadius: BorderRadius.only(
                            topLeft: const Radius.circular(14),
                            topRight: const Radius.circular(14),
                            bottomLeft: Radius.circular(progress == null ? 14 : 0),
                            bottomRight: Radius.circular(progress == null ? 14 : 0),
                          ),
                        ),
                        alignment: Alignment.center,
                        padding: const EdgeInsets.symmetric(horizontal: 8),
                        child: Directionality(
                          textDirection: L10nSimple.textDir(_lang),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Flexible(
                                child: Text(
                                  subtitle,
                                  textAlign: TextAlign.center,
                                  overflow: TextOverflow.ellipsis,
                                  style: const TextStyle(
                                    fontSize: 19,
                                    color: Colors.white70,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                              if (isOverflowing) ...[
                                const SizedBox(width: 6),
                                const Icon(Icons.swap_vert, size: 18, color: Colors.white70),
                              ],
                            ],
                          ),
                        ),
                      ),
                      ClipRRect(
                        borderRadius: const BorderRadius.only(
                          bottomLeft: Radius.circular(14),
                          bottomRight: Radius.circular(14),
                        ),
                        child: progress != null
                            ? LinearProgressIndicator(
                                value: progress.clamp(0.0, 1.0),
                                minHeight: 5,
                                backgroundColor: Colors.white.withOpacity(0.18),
                              )
                            : AnimatedBuilder(
                                animation: _answerBarController,
                                builder: (context, _) {
                                  return LinearProgressIndicator(
                                    value: _answerBarController.value,
                                    minHeight: 5,
                                    backgroundColor: Colors.white.withOpacity(0.18),
                                  );
                                },
                              ),
                      ),
                    ],
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    double? qProgress;
    if (_phase == RoundPhase.question) {
      final total = widget.delaySeconds * 60;
      if (total > 0 && _countdown >= 0) {
        qProgress = 1.0 - (_countdown / total);
      }
    }

    Widget? qCard, aCard;
    if (_phase == RoundPhase.question && _questionAyah != null) {
      qCard = _buildAyahCard(_questionAyah!, Colors.green.shade900, progress: qProgress);
    }
    if (_phase == RoundPhase.answer && _currentAnswerAyah != null) {
      aCard = _buildAyahCard(_currentAnswerAyah!, Colors.blueGrey.shade900);
    }

    final bool nextButtonActive = _playing &&
        !_paused &&
        !_jumping &&
        ((_phase == RoundPhase.answer) || (_phase == RoundPhase.question && _canPressAnswer));

    return Directionality(
      textDirection: L10nSimple.textDir(_lang),
      child: Scaffold(
        body: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [Colors.green.shade700, Colors.yellow.shade200],
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
            ),
          ),
          child: SafeArea(
            top: true,
            bottom: true,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(14, 6, 14, 10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  // Logo
                  Padding(
                    padding: const EdgeInsets.only(top: 6, bottom: 6),
                    child: LayoutBuilder(
                      builder: (context, constraints) {
                        final w = MediaQuery.of(context).size.width;
                        final double logoH = (w * 0.24).clamp(100.0, 160.0);
                        return Image.asset(
                          'assets/logo.png',
                          height: logoH,
                          fit: BoxFit.contain,
                          errorBuilder: (_, __, ___) => const SizedBox.shrink(),
                        );
                      },
                    ),
                  ),
                  // Counter
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        _lang == 'ar'
                            ? "السؤال رقم ${L10nSimple.digits(_lang, _currentIndex)} / ${L10nSimple.digits(_lang, widget.repeatCount)}"
                            : "Question $_currentIndex / ${widget.repeatCount}",
                        style: const TextStyle(
                          fontSize: 22,
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  // Cards
                  Expanded(
                    child: LayoutBuilder(
                      builder: (context, constraints) {
                        final double avail = constraints.maxHeight;
                        final bool hasQ = qCard != null;
                        final bool hasA = aCard != null;

                        final double qH =
                            hasQ ? (hasA ? avail * 0.64 : avail * 0.84).clamp(210.0, avail - 80.0) : 0.0;
                        final double gap = (hasQ && hasA) ? 4.0 : 0.0;
                        final double aH =
                            hasA ? (avail - qH - gap).clamp(140.0, avail - 130.0) : 0.0;

                        return Column(
                          children: [
                            if (hasQ)
                              Padding(
                                padding: const EdgeInsets.only(bottom: 2),
                                child: SizedBox(height: qH, child: qCard),
                              ),
                            if (hasA) ...[
                              if (gap > 0) SizedBox(height: gap),
                              SizedBox(height: aH, child: aCard),
                            ],
                          ],
                        );
                      },
                    ),
                  ),
                  const SizedBox(height: 6),
                  // Controls (no overflow: Wrap with fixed heights)
                  LayoutBuilder(
                    builder: (context, cons) {
                      final double gap = 12;
                      final double runGap = 10;
                      final double w = cons.maxWidth;
                      final double itemW = (w - gap) / 2;
                      const double itemH = 64;

                      Widget buildBtn({
                        required Color color,
                        required IconData icon,
                        required String label,
                        required VoidCallback? onPressed,
                      }) {
                        return SizedBox(
                          width: itemW,
                          height: itemH,
                          child: ElevatedButton.icon(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: color,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(26),
                              ),
                              padding: const EdgeInsets.symmetric(vertical: 12),
                            ),
                            icon: Icon(icon, color: Colors.white, size: 26),
                            label: Text(
                              label,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: 18,
                              ),
                            ),
                            onPressed: onPressed,
                          ),
                        );
                      }

                      return Wrap(
                        alignment: WrapAlignment.spaceBetween,
                        spacing: gap,
                        runSpacing: runGap,
                        children: [
                          buildBtn(
                            color: Colors.lightBlue,
                            icon: Icons.play_arrow,
                            label: t('showAnswer'),
                            onPressed: _paused ? null : (_canPressAnswer ? _playAnswerAyahs : null),
                          ),
                          buildBtn(
                            color: Colors.orangeAccent,
                            icon: Icons.fast_forward,
                            label: t('nextQuestion'),
                            onPressed: nextButtonActive ? _skipToNextRound : null,
                          ),
                          buildBtn(
                            color: _paused ? Colors.green : Colors.red,
                            icon: _paused ? Icons.play_arrow : Icons.pause,
                            label: _paused ? t('resume') : t('pause'),
                            onPressed: _togglePause,
                          ),
                          buildBtn(
                            color: Colors.purpleAccent,
                            icon: Icons.refresh,
                            label: t('newQuiz'),
                            onPressed: () async {
                              await _killAllAudioAndInvalidateRound();
                              await _hardStopAndGoHome();
                            },
                          ),
                        ],
                      );
                    },
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}


