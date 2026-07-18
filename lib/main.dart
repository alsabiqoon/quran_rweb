// main.dart
import 'dart:async';
import 'dart:convert';
import 'dart:math';

import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
// import 'package:flutter/services.dart' show rootBundle;
import 'package:flutter/services.dart' show rootBundle, AssetManifest;

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

  // Test filter mode from SettingsPage
  final String testMode; // surah, page, juz, hizb, rub
  final int selectedPageFrom;
  final int selectedPageTo;
  final int selectedJuzFrom;
  final int selectedJuzTo;
  final int selectedHizbFrom;
  final int selectedHizbTo;
  final int selectedRubFrom;
  final int selectedRubTo;

  // Passed from SettingsPage
  final String reciterKey;
  final String reciterUrl;
  final String reciterNameAr;
  final String reciterNameEn;

  const PlayPage({
    Key? key,
    required this.repeatCount,
    required this.ayahsAfter,
    required this.delaySeconds,
    required this.selectedSurahs,
    required this.testMode,
    required this.selectedPageFrom,
    required this.selectedPageTo,
    required this.selectedJuzFrom,
    required this.selectedJuzTo,
    required this.selectedHizbFrom,
    required this.selectedHizbTo,
    required this.selectedRubFrom,
    required this.selectedRubTo,
    required this.reciterKey,
    required this.reciterUrl,
    required this.reciterNameAr,
    required this.reciterNameEn,
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
  final ScrollController _ayahScrollController = ScrollController();
  String? _lastScrolledAyahKey;

  // Quran files (filtered)
  List<String> _files = [];
  Set<String> _played = {};
  // Map: numeric main index (e.g. 001234) -> file key
  final Map<int, String> _numToFile = {};

  int _currentIndex = 0;
  int _countdown = 0;
  static const int _answerReviewSeconds = 4;
  bool _playing = false;
  bool _stopRequested = false;

  bool _canPressAnswer = false;
  bool _answerPlayed = false;
  bool _showAyahInfo = false;
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

  // Start the first question immediately after entering the quiz page.
  bool _quizStarted = true;

  // Animated bar under the Answer card
  late final AnimationController _answerBarController;

  @override
  void initState() {
    super.initState();
    AudioService.I.setReciter(widget.reciterUrl);
    _player.setReleaseMode(ReleaseMode.stop);
    _player.setPlayerMode(PlayerMode.mediaPlayer);

    _answerBarController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1800),
      lowerBound: 0.0,
      upperBound: 1.0,
    );

    _loadFileList().then((_) {
      if (!mounted || _files.isEmpty) return;
      Future.microtask(() {
        if (mounted && !_playing) {
          _startQuestions();
        }
      });
    });
  }

  @override
  void dispose() {
    _hardStop();
    try {
      _answerBarController.dispose();
    } catch (_) {}
    _ayahScrollController.dispose();
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
      await webaudio.WebAudioController.stop();
    } catch (_) {}
    try {
      await AudioService.I.stop();
    } catch (_) {}

    _isPlayingAyah = false;
  }

  Future<void> _stopCurrentAudioNow() async {
    try {
      await webaudio.WebAudioController.stop();
    } catch (_) {}
    try {
      await _player.stop();
    } catch (_) {}
    try {
      await webaudio.WebAudioController.stop();
    } catch (_) {}
    try {
      await AudioService.I.stop();
    } catch (_) {}
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
      await webaudio.WebAudioController.stop();
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
      _showAyahInfo = false;
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
    final manifest = await AssetManifest.loadFromAssetBundle(rootBundle);

    // We only use assets for start/hasbuk (local).
    // Do NOT read AssetManifest.bin.json manually; in newer Flutter it is encoded.
    final allMp3 = manifest
        .listAssets()
        .where((k) => k.endsWith('.mp3'))
        .toList();

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

      bool include = false;

      if (widget.testMode == 'surah') {
        include =
            selectAll || selected.contains(surahAr) || selected.contains(surahEn);
      } else if (widget.testMode == 'page') {
        final page = int.tryParse('${info['page']}');
        include = page != null &&
            page >= widget.selectedPageFrom &&
            page <= widget.selectedPageTo;
      } else if (widget.testMode == 'juz') {
        final juz = int.tryParse('${info['juz']}');
        include = juz != null &&
            juz >= widget.selectedJuzFrom &&
            juz <= widget.selectedJuzTo;
      } else if (widget.testMode == 'hizb') {
        final hizb = int.tryParse('${info['hizb']}');
        include = hizb != null &&
            hizb >= widget.selectedHizbFrom &&
            hizb <= widget.selectedHizbTo;
      } else if (widget.testMode == 'rub') {
        final rub = int.tryParse('${info['rub']}');
        include = rub != null &&
            rub >= widget.selectedRubFrom &&
            rub <= widget.selectedRubTo;
      }

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
  }

  void _beginQuizFromUserTap() {
    if (_quizStarted || _files.isEmpty) return;
    _unlockIfWeb();
    setState(() {
      _quizStarted = true;
    });
    _startQuestions();
  }

  String _webAssetUrl(String assetKey) {
    final key = assetKey.startsWith('assets/') ? assetKey : 'assets/$assetKey';
    return Uri.base.resolve('assets/$key').toString();
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
    if (_stopRequested || rid != _roundId) return;

    // iPhone Safari sometimes does not fire the ended event for very short files.
    // Forced durations prevent the round from freezing after ta'awwudh.
    await _playAssetG(
      'assets/begin/001000.mp3',
      rid,
      forcedDuration: const Duration(seconds: 4),
    );

    await Future.delayed(const Duration(milliseconds: 350));
    if (_stopRequested || rid != _roundId) return;

    await _playAssetG(
      'assets/begin/001001.mp3',
      rid,
      forcedDuration: const Duration(seconds: 5),
    );

    _taawudhPlayed = true;
  }

  Future<void> _checkPause() async {
    while (_paused) {
      _pauseCompleter = Completer<void>();
      await _pauseCompleter!.future;
    }
  }

  Future<void> _playAssetG(
    String path,
    int rid, {
    Duration? forcedDuration,
  }) async {
    if (_stopRequested || rid != _roundId) return;
    await _checkPause();
    if (!mounted || rid != _roundId) return;

    setState(() => _isPlayingAyah = true);

    try {
      _unlockIfWeb();

      if (kIsWeb) {
        await webaudio.WebAudioController.playUrlAndWait(
          _webAssetUrl(path),
          timeout: forcedDuration ?? const Duration(seconds: 25),
          forceFinishAfter: forcedDuration,
        );
      } else {
        final c = Completer<void>();
        late final StreamSubscription<void> sub;

        await _player.stop();
        await Future.delayed(const Duration(milliseconds: 150));

        sub = _player.onPlayerComplete.listen((_) {
          if (!c.isCompleted) c.complete();
        });

        await _player.setReleaseMode(ReleaseMode.stop);
        await _player.setSource(AssetSource(path.replaceFirst('assets/', '')));
        await Future.delayed(const Duration(milliseconds: 200));
        await _player.resume();

        if (forcedDuration != null) {
          await Future.any([c.future, Future.delayed(forcedDuration)]);
        } else {
          await c.future.timeout(const Duration(seconds: 25), onTimeout: () {});
        }
        try { await sub.cancel(); } catch (_) {}
      }
    } catch (_) {
      // Never freeze the quiz because of a short local prompt audio.
    } finally {
      try {
        if (!kIsWeb) await _player.stop();
      } catch (_) {}

      if (mounted && rid == _roundId) {
        setState(() => _isPlayingAyah = false);
      }
    }
  }

  // Build a full URL from reciter base + file name (ensures single '/')
  String _buildReciterUrl(String base, String fileName) {
    final b = base.endsWith('/') ? base.substring(0, base.length - 1) : base;
    return '$b/$fileName';
  }

  /// Plays an ayah online.
  /// On iPhone Safari web, skip AudioService and use one HTML audio element.
  Future<void> _playAyahOnline(String assetLikePathOrFileName, int rid) async {
    if (_stopRequested || rid != _roundId) return;
    await _checkPause();
    if (!mounted || rid != _roundId) return;

    setState(() => _isPlayingAyah = true);

    final fileName = assetLikePathOrFileName.split('/').last;
    final url = _buildReciterUrl(widget.reciterUrl, fileName);

    try {
      _unlockIfWeb();

      if (kIsWeb) {
        await webaudio.WebAudioController.playUrlAndWait(
          url,
          timeout: const Duration(seconds: 120),
        );
      } else {
        await AudioService.I.playAndWait(fileName);
      }
    } catch (_) {
      try {
        if (kIsWeb) {
          await webaudio.WebAudioController.playUrlAndWait(
            url,
            timeout: const Duration(seconds: 120),
          );
        } else {
          final c = Completer<void>();
          late final StreamSubscription<void> sub;
          await _player.stop();
          sub = _player.onPlayerComplete.listen((_) {
            if (!c.isCompleted) c.complete();
          });
          await _player.setSource(UrlSource(url));
          await Future.delayed(const Duration(milliseconds: 200));
          await _player.resume();
          await c.future.timeout(const Duration(seconds: 120), onTimeout: () {});
          try { await sub.cancel(); } catch (_) {}
        }
      } catch (_) {}
    } finally {
      if (mounted && rid == _roundId) {
        setState(() => _isPlayingAyah = false);
      }
    }
  }

  Future<void> _startCountdown() async {
    final int totalSeconds = max(1, widget.delaySeconds * 60);
    if (!mounted) return;
    setState(() => _countdown = totalSeconds);

    for (int remaining = totalSeconds; remaining > 0; remaining--) {
      if (_stopRequested || _answeredManually || _answerPlayed || _skipped) {
        if (mounted) setState(() => _countdown = 0);
        return;
      }

      await _checkPause();
      await Future.delayed(const Duration(seconds: 1));

      if (!mounted) return;
      if (_stopRequested || _answeredManually || _answerPlayed || _skipped) {
        setState(() => _countdown = 0);
        return;
      }

      setState(() => _countdown = remaining - 1);
    }
  }

  Future<void> _answerReviewDelay(int rid) async {
    if (!mounted || rid != _roundId) return;

    setState(() => _countdown = _answerReviewSeconds);

    for (int remaining = _answerReviewSeconds; remaining > 0; remaining--) {
      if (_stopRequested || _skipped || rid != _roundId) {
        if (mounted) setState(() => _countdown = 0);
        return;
      }

      await _checkPause();
      await Future.delayed(const Duration(seconds: 1));

      if (!mounted || _stopRequested || _skipped || rid != _roundId) return;
      setState(() => _countdown = remaining - 1);
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
      _showAyahInfo = false;
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
        _showAyahInfo = false;
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

  Future<void> _togglePause() async {
    if (_paused) {
      // Resume from the same audio position. Do not restart the ayah.
      try {
        if (kIsWeb) {
          await webaudio.WebAudioController.resume();
        } else {
          await _player.resume();
          await AudioService.I.resume();
        }
      } catch (_) {}

      if (!mounted) return;
      setState(() => _paused = false);

      if (_pauseCompleter != null && !_pauseCompleter!.isCompleted) {
        _pauseCompleter!.complete();
      }

      try {
        if (_answerPlayed && !_answerBarController.isAnimating) {
          _answerBarController.repeat();
        }
      } catch (_) {}
      return;
    }

    // Pause only. Do not stop, complete, or reset the active audio.
    // Stopping here makes the current ayah finish logically and corrupts the next question.
    if (!mounted) return;
    setState(() => _paused = true);

    try {
      if (_answerBarController.isAnimating) {
        _answerBarController.stop();
      }
    } catch (_) {}

    try {
      if (kIsWeb) {
        await webaudio.WebAudioController.pause();
      } else {
        await _player.pause();
        await AudioService.I.pause();
      }
    } catch (_) {}
  }

  void _skipToNextRound() async {
    if (_jumping) return;
    if (_waitForAnswer == null || _waitForAnswer!.isCompleted) return;

    _jumping = true;
    _hasbukTimer?.cancel();

    // If the user already displayed the answer, pressing Next is normal navigation,
    // not a skipped question.
    final bool wasAnswered = _answerPlayed || _answeredManually;
    if (!wasAnswered) {
      _skipped = true;
      _skippedManuallyCount++;
    }

    try {
      await _player.stop();
    } catch (_) {}
    try {
      await _player.release();
    } catch (_) {}
    try {
      await webaudio.WebAudioController.stop();
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
      _showAyahInfo = false;
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
    final unanswered = max(0, total - manualAnswers - autoHasbuk - skipped);

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
                  _lang == 'ar' ? "🎉 أحسنت" : "🎉 Well done",
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
                _showAyahInfo = false;
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
      await webaudio.WebAudioController.stop();
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
      _showAyahInfo = true;
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

    // Keep the answer visible briefly, show a countdown, then move automatically.
    // This prevents the screen from looking frozen after "عرض الإجابة".
    if (mounted && rid == _roundId) {
      setState(() {
        _phase = RoundPhase.answer;
        _canPressAnswer = false;
      });

      await _answerReviewDelay(rid);

      if (mounted &&
          rid == _roundId &&
          _waitForAnswer != null &&
          !_waitForAnswer!.isCompleted) {
        _waitForAnswer!.complete();
      }
    }
  }

  double _measureHeight(
      String text, double maxWidth, double fontSize, double lineHeight) {
    final tp = TextPainter(
      text: TextSpan(
        text: text,
        style: TextStyle(
          fontFamily: 'amiriQuran',
          fontSize: fontSize,
          height: lineHeight,
          fontWeight: FontWeight.normal,
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
    final ayahText = (ayahData["text"] ?? "")
        .toString()
        .replaceFirst(RegExp(r'^\s*۞\s*'), '');

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

    final scrollAyahKey = '$surahNameAr-$ayahNum-${_phase.name}';
    if (_lastScrolledAyahKey != scrollAyahKey) {
      _lastScrolledAyahKey = scrollAyahKey;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (_ayahScrollController.hasClients) {
          _ayahScrollController.jumpTo(0);
        }
      });
    }

    final String subtitle = _lang == 'ar'
        ? "سورة $surahNameAr - الآية ${convertToArabicNumber(ayahNum)}"
        : "Surah $surahNameForEn - Ayah $ayahNum";

    const double lineHeight = 1.95;
    const double footerHeight = 58;

    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topRight,
          end: Alignment.bottomLeft,
          colors: [
            bgColor.withOpacity(0.99),
            Color.lerp(bgColor, Colors.black, 0.16)!.withOpacity(0.99),
          ],
        ),
        borderRadius: BorderRadius.circular(22),
        border: Border.all(
          color: const Color(0xFFD4AF37).withOpacity(0.72),
          width: 1.6,
        ),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFFD4AF37).withOpacity(0.24),
            blurRadius: 22,
            spreadRadius: 1,
            offset: const Offset(0, 8),
          ),
          BoxShadow(
            color: Colors.black.withOpacity(0.24),
            blurRadius: 18,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: LayoutBuilder(
          builder: (context, constraints) {
            final double maxTextArea =
                (constraints.maxHeight - footerHeight - 4).clamp(120.0, constraints.maxHeight);

            const double baseFont = 32.0;

            final double h = _measureHeight(
              ayahText,
              (constraints.maxWidth - 42).clamp(80.0, constraints.maxWidth),
              baseFont,
              lineHeight,
            );
            final double usableTextHeight =
                (maxTextArea - 20).clamp(80.0, maxTextArea);
            final bool isOverflowing = h > usableTextHeight;

            final textWidget = Text(
              ayahText,
              textAlign: TextAlign.center,
              softWrap: true,
              style: TextStyle(
                fontFamily: 'amiriQuran',
                fontSize: baseFont,
                height: lineHeight,
                color: Colors.white,
                fontWeight: FontWeight.normal,
              ),
            );

            return Stack(
              children: [
                Padding(
                  padding: const EdgeInsets.only(bottom: footerHeight + 4),
                  child: SizedBox(
                    height: maxTextArea,
                    child: Container(
                      margin: const EdgeInsets.all(3),
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
                      decoration: BoxDecoration(
                        gradient: RadialGradient(
                          colors: [
                            Colors.white.withOpacity(0.075),
                            Colors.transparent,
                          ],
                          radius: 0.95,
                        ),
                        borderRadius: BorderRadius.circular(18),
                        border: Border.all(
                          color: const Color(0xFFF1D77A).withOpacity(0.28),
                        ),
                      ),
                      child: isOverflowing
                          ? SingleChildScrollView(
                              controller: _ayahScrollController,
                              primary: false,
                              physics: const BouncingScrollPhysics(),
                              child: textWidget,
                            )
                          : Center(child: textWidget),
                    ),
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
                        decoration: BoxDecoration(
                          color: const Color(0xFF184B26).withOpacity(0.96),
                          borderRadius: BorderRadius.circular(18),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.16),
                              blurRadius: 8,
                              offset: const Offset(0, 3),
                            ),
                          ],
                        ),
                        padding: const EdgeInsets.fromLTRB(14, 10, 14, 8),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Directionality(
                              textDirection: L10nSimple.textDir(_lang),
                              child: InkWell(
                                borderRadius: BorderRadius.circular(14),
                                onTap: () {
                                  if (_phase == RoundPhase.answer) return;
                                  setState(() {
                                    _showAyahInfo = !_showAyahInfo;
                                  });
                                },
                                child: AnimatedContainer(
                                  duration: const Duration(milliseconds: 220),
                                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
                                  decoration: BoxDecoration(
                                    color: _showAyahInfo || _phase == RoundPhase.answer
                                        ? Colors.white.withOpacity(0.08)
                                        : Colors.transparent,
                                    borderRadius: BorderRadius.circular(14),
                                    border: _showAyahInfo || _phase == RoundPhase.answer
                                        ? null
                                        : Border.all(color: Colors.white.withOpacity(0.36)),
                                  ),
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Icon(
                                        _showAyahInfo || _phase == RoundPhase.answer
                                            ? Icons.visibility_off_rounded
                                            : Icons.visibility_rounded,
                                        size: 18,
                                        color: Colors.white70,
                                      ),
                                      const SizedBox(width: 7),
                                      Flexible(
                                        child: AnimatedSwitcher(
                                          duration: const Duration(milliseconds: 180),
                                          child: Text(
                                            _showAyahInfo || _phase == RoundPhase.answer
                                                ? subtitle
                                                : (_lang == 'ar'
                                                    ? 'اضغط لإظهار اسم السورة والآية'
                                                    : 'Tap to show surah and ayah'),
                                            key: ValueKey<bool>(_showAyahInfo || _phase == RoundPhase.answer),
                                            textAlign: TextAlign.center,
                                            overflow: TextOverflow.ellipsis,
                                            style: const TextStyle(
                                              fontSize: 15,
                                              color: Color(0xE6FFFFFF),
                                              fontWeight: FontWeight.w700,
                                              height: 1.1,
                                            ),
                                          ),
                                        ),
                                      ),
                                      if (isOverflowing) ...[
                                        const SizedBox(width: 6),
                                        const Icon(Icons.swap_vert, size: 16, color: Colors.white70),
                                      ],
                                    ],
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(height: 7),
                            ClipRRect(
                              borderRadius: BorderRadius.circular(999),
                              child: progress != null
                                  ? LinearProgressIndicator(
                                      value: progress.clamp(0.0, 1.0),
                                      minHeight: 6,
                                      backgroundColor: Colors.white24,
                                      valueColor: const AlwaysStoppedAnimation<Color>(
                                        Color(0xFF81C784),
                                      ),
                                    )
                                  : AnimatedBuilder(
                                      animation: _answerBarController,
                                      builder: (context, _) {
                                        return LinearProgressIndicator(
                                          value: _answerBarController.value,
                                          minHeight: 6,
                                          backgroundColor: Colors.white24,
                                          valueColor: const AlwaysStoppedAnimation<Color>(
                                            Color(0xFF81C784),
                                          ),
                                        );
                                      },
                                    ),
                            ),
                          ],
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


  String _reciterDisplayName() {
    final directName = _lang == 'ar' ? widget.reciterNameAr : widget.reciterNameEn;
    if (directName.trim().isNotEmpty) return directName.trim();

    // Fallback only if an old caller did not pass the display names.
    const arNames = <String, String>{
      'Abu_Bakr_Ash-Shaatree_128kbps': 'أبو بكر الشاطري',
      'Husary_Muallim_128kbps': 'الحصري (تعليمي)',
      'Minshawy_Mujawwad_192kbps': 'المنشاوي (مجود)',
      'Minshawy_Murattal_128kbps': 'المنشاوي (مرتل)',
      'Ghamadi_40kbps': 'سعد الغامدي',
      'Saood_ash-Shuraym_128kbps': 'سعود الشريم',
      'Sahl_Yassin_128kbps': 'سهل ياسين',
      'Abdul_Basit_Mujawwad_128kbps': 'عبد الباسط (مجود)',
      'Abdul_Basit_Murattal_64kbps': 'عبد الباسط (مرتل)',
      'Abdurrahmaan_As-Sudais_192kbps': 'عبد الرحمن السديس',
      'Hudhaify_64kbps': 'علي الحذيفي',
      'Ali_Jaber_64kbps': 'علي جابر',
      'Fares_Abbad_64kbps': 'فارس عباد',
      'Muhammad_Ayyoub_128kbps': 'محمد أيوب',
      'Muhammad_Jibreel_64kbps': 'محمد جبريل',
      'Husary_128kbps': 'محمود خليل الحصري',
      'Alafasy_128kbps': 'مشاري راشد العفاسي',
      'MisharyRashidAlafasy_64kbps': 'مشاري راشد العفاسي',
    };
    const enNames = <String, String>{
      'Abu_Bakr_Ash-Shaatree_128kbps': 'Abu Bakr Al-Shatri',
      'Husary_Muallim_128kbps': 'Al-Husary (Teaching)',
      'Minshawy_Mujawwad_192kbps': 'Minshawy (Mujawwad)',
      'Minshawy_Murattal_128kbps': 'Minshawy (Murattal)',
      'Ghamadi_40kbps': 'Saad Al-Ghamdi',
      'Saood_ash-Shuraym_128kbps': 'Saood ash-Shuraym',
      'Sahl_Yassin_128kbps': 'Sahl Yaseen',
      'Abdul_Basit_Mujawwad_128kbps': 'Abdul Basit (Mujawwad)',
      'Abdul_Basit_Murattal_64kbps': 'Abdul Basit (Murattal)',
      'Abdurrahmaan_As-Sudais_192kbps': 'Abdurrahmaan As-Sudais',
      'Hudhaify_64kbps': 'Ali Al-Hudhaify',
      'Ali_Jaber_64kbps': 'Ali Jaber',
      'Fares_Abbad_64kbps': 'Fares Abbad',
      'Muhammad_Ayyoub_128kbps': 'Muhammad Ayyoub',
      'Muhammad_Jibreel_64kbps': 'Muhammad Jibreel',
      'Husary_128kbps': 'Mahmoud Khalil Al-Husary',
      'Alafasy_128kbps': 'Mishary Rashid Alafasy',
      'MisharyRashidAlafasy_64kbps': 'Mishary Rashid Alafasy',
    };

    final map = _lang == 'ar' ? arNames : enNames;
    return map[widget.reciterKey] ??
        widget.reciterKey
            .replaceAll('_128kbps', '')
            .replaceAll('_192kbps', '')
            .replaceAll('_64kbps', '')
            .replaceAll('_40kbps', '')
            .replaceAll('_', ' ');
  }

  String _modeTitle() {
    if (_lang != 'ar') {
      switch (widget.testMode) {
        case 'page':
          return 'Pages test';
        case 'juz':
          return 'Juz test';
        case 'hizb':
          return 'Hizb test';
        case 'rub':
          return 'Rub test';
        default:
          return 'Surahs test';
      }
    }
    switch (widget.testMode) {
      case 'page':
        return 'اختبار الصفحات';
      case 'juz':
        return 'اختبار الأجزاء';
      case 'hizb':
        return 'اختبار الأحزاب';
      case 'rub':
        return 'اختبار الأرباع';
      default:
        return 'اختبار السور';
    }
  }

  String _rangeTitle() {
    String d(int v) => L10nSimple.digits(_lang, v);
    if (widget.testMode == 'page') {
      return _lang == 'ar'
          ? 'من الصفحة ${d(widget.selectedPageFrom)} إلى ${d(widget.selectedPageTo)}'
          : 'Pages ${widget.selectedPageFrom} - ${widget.selectedPageTo}';
    }
    if (widget.testMode == 'juz') {
      return _lang == 'ar'
          ? 'من الجزء ${d(widget.selectedJuzFrom)} إلى ${d(widget.selectedJuzTo)}'
          : 'Juz ${widget.selectedJuzFrom} - ${widget.selectedJuzTo}';
    }
    if (widget.testMode == 'hizb') {
      return _lang == 'ar'
          ? 'من الحزب ${d(widget.selectedHizbFrom)} إلى ${d(widget.selectedHizbTo)}'
          : 'Hizb ${widget.selectedHizbFrom} - ${widget.selectedHizbTo}';
    }
    if (widget.testMode == 'rub') {
      return _lang == 'ar'
          ? 'من الربع ${d(widget.selectedRubFrom)} إلى ${d(widget.selectedRubTo)}'
          : 'Rub ${widget.selectedRubFrom} - ${widget.selectedRubTo}';
    }
    return _lang == 'ar'
        ? '${d(widget.selectedSurahs.length)} سورة مختارة'
        : '${widget.selectedSurahs.length} selected surahs';
  }

  Widget _progressDots() {
    final int total = widget.repeatCount <= 0 ? 1 : widget.repeatCount;
    final int current = _currentIndex <= 0 ? 1 : _currentIndex.clamp(1, total);
    final double progress = (current / total).clamp(0.0, 1.0);

    return Directionality(
      textDirection: TextDirection.ltr,
      child: TweenAnimationBuilder<double>(
        duration: const Duration(milliseconds: 380),
        tween: Tween<double>(begin: 0, end: progress),
        builder: (context, value, _) {
          return ClipRRect(
            borderRadius: BorderRadius.circular(999),
            child: LinearProgressIndicator(
              minHeight: 10,
              value: value,
              backgroundColor: Colors.white.withOpacity(0.25),
              valueColor: const AlwaysStoppedAnimation<Color>(Colors.white),
            ),
          );
        },
      ),
    );
  }

  Widget _infoPill({
    required IconData icon,
    required String title,
    required String value,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 9),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.16),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withOpacity(0.18)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: Colors.white, size: 18),
          const SizedBox(width: 6),
          Flexible(
            child: Text(
              value,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 13,
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _preStartCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.18),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: Colors.white.withOpacity(0.22)),
        boxShadow: const [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 14,
            offset: Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            _lang == 'ar' ? 'استعد للاختبار' : 'Get ready',
            style: const TextStyle(
              color: Colors.white,
              fontSize: 24,
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 14),
          Wrap(
            alignment: WrapAlignment.center,
            spacing: 8,
            runSpacing: 8,
            children: [
              _infoPill(
                icon: Icons.menu_book_rounded,
                title: _lang == 'ar' ? 'النوع' : 'Type',
                value: _modeTitle(),
              ),
              _infoPill(
                icon: Icons.my_library_books_rounded,
                title: _lang == 'ar' ? 'النطاق' : 'Range',
                value: _rangeTitle(),
              ),
              _infoPill(
                icon: Icons.record_voice_over_rounded,
                title: _lang == 'ar' ? 'القارئ' : 'Reciter',
                value: _reciterDisplayName(),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _topQuizHeader() {
    final int totalQuestions = widget.repeatCount <= 0 ? 1 : widget.repeatCount;
    final int safeIndex = _currentIndex <= 0 ? 1 : _currentIndex.clamp(1, totalQuestions).toInt();
    final title = _lang == 'ar'
        ? '${L10nSimple.digits(_lang, safeIndex)} / ${L10nSimple.digits(_lang, totalQuestions)}'
        : '$safeIndex / $totalQuestions';

    return Column(
      children: [
        Text(
          _modeTitle(),
          textAlign: TextAlign.center,
          style: const TextStyle(
            color: Colors.white70,
            fontSize: 15,
            fontWeight: FontWeight.w800,
          ),
        ),
        const SizedBox(height: 3),
        Text(
          title,
          textAlign: TextAlign.center,
          style: const TextStyle(
            fontSize: 32,
            color: Colors.white,
            fontWeight: FontWeight.w900,
          ),
        ),
        const SizedBox(height: 8),
        SizedBox(width: 230, child: _progressDots()),
        const SizedBox(height: 10),
        Wrap(
          alignment: WrapAlignment.center,
          spacing: 8,
          runSpacing: 8,
          children: [
            _infoPill(
              icon: Icons.record_voice_over_rounded,
              title: _lang == 'ar' ? 'القارئ' : 'Reciter',
              value: _reciterDisplayName(),
            ),
            if (_countdown > 0)
              _infoPill(
                icon: _phase == RoundPhase.answer
                    ? Icons.skip_next_rounded
                    : Icons.timer_rounded,
                title: _phase == RoundPhase.answer
                    ? (_lang == 'ar' ? 'التالي خلال' : 'Next in')
                    : (_lang == 'ar' ? 'مؤقت السؤال' : 'Question timer'),
                value: _phase == RoundPhase.answer
                    ? L10nSimple.digits(_lang, _countdown)
                    : '${L10nSimple.digits(_lang, (_countdown ~/ 60))}:${L10nSimple.digits(_lang, (_countdown % 60).toString().padLeft(2, '0'))}',
              ),
          ],
        ),
      ],
    );
  }


  String _formatCountdownText() {
    final int seconds = _countdown < 0 ? 0 : _countdown;
    if (_phase == RoundPhase.answer) {
      return _lang == 'ar'
          ? 'التالي خلال ${L10nSimple.digits(_lang, seconds)}'
          : 'Next in $seconds';
    }

    final int minutes = seconds ~/ 60;
    final int remain = seconds % 60;
    final String mm = _lang == 'ar'
        ? L10nSimple.digits(_lang, minutes)
        : minutes.toString().padLeft(2, '0');
    final String ssRaw = remain.toString().padLeft(2, '0');
    final String ss = _lang == 'ar'
        ? L10nSimple.digits(_lang, ssRaw)
        : ssRaw;

    return '$mm:$ss';
  }

  Widget _questionTimerPill() {
    final bool showCountdown = _countdown > 0;
    final bool isAnswerPhase = _phase == RoundPhase.answer;
    final int totalQuestions = widget.repeatCount <= 0 ? 1 : widget.repeatCount;
    final int questionNumber = _currentIndex <= 0
        ? 1
        : _currentIndex.clamp(1, totalQuestions).toInt();
    return SizedBox(
      height: 54,
      child: Center(
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 220),
          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 9),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(isAnswerPhase ? 0.22 : 0.18),
            borderRadius: BorderRadius.circular(999),
            border: Border.all(color: Colors.white.withOpacity(0.28)),
            boxShadow: const [
              BoxShadow(
                color: Colors.black12,
                blurRadius: 10,
                offset: Offset(0, 4),
              ),
            ],
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                showCountdown
                    ? (isAnswerPhase
                        ? Icons.skip_next_rounded
                        : Icons.timer_rounded)
                    : Icons.donut_large_rounded,
                color: Colors.white,
                size: 20,
              ),
              const SizedBox(width: 7),
              Text(
                showCountdown
                    ? _formatCountdownText()
                    : (_lang == 'ar'
                        ? 'السؤال ${convertToArabicNumber(questionNumber)} من ${convertToArabicNumber(totalQuestions)}'
                        : 'Question $questionNumber of $totalQuestions'),
                textDirection: showCountdown ? TextDirection.ltr : null,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.w900,
                  height: 1.1,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }


  @override
  Widget build(BuildContext context) {
    // تقدم الأسئلة وليس تقدم الوقت. يظهر أسفل اسم السورة داخل البطاقة.
    final int totalQuestions = widget.repeatCount <= 0 ? 1 : widget.repeatCount;
    final int safeQuestionIndex = _currentIndex <= 0
        ? 1
        : _currentIndex.clamp(1, totalQuestions).toInt();
    final double questionProgress = (safeQuestionIndex / totalQuestions).clamp(0.0, 1.0);

    Widget? qCard, aCard;
    if (_phase == RoundPhase.question && _questionAyah != null) {
      qCard = _buildAyahCard(_questionAyah!, const Color(0xFF1B5E20), progress: questionProgress);
    }
    if (_phase == RoundPhase.answer && _currentAnswerAyah != null) {
      aCard = _buildAyahCard(_currentAnswerAyah!, const Color(0xFF2F3A3F), progress: questionProgress);
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
              colors: [
                const Color(0xFF2E7D32),
                const Color(0xFFA5D66A),
                const Color(0xFFFFF59D),
              ],
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
            ),
          ),
          child: SafeArea(
            top: true,
            bottom: true,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(14, 8, 14, 10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    padding: EdgeInsets.only(top: _quizStarted ? 2 : 8, bottom: _quizStarted ? 3 : 8),
                    child: Image.asset(
                      'assets/logo.png',
                      height: _quizStarted ? 62 : 130,
                      fit: BoxFit.contain,
                      errorBuilder: (_, __, ___) => const SizedBox.shrink(),
                    ),
                  ),
                  // تم حذف عنوان نوع الاختبار وعدّاد السؤال العلوي وشريطه.
                  // يظهر المؤقت فقط عند انتظار إجابة المستخدم أو مراجعة الإجابة.
                  _questionTimerPill(),
                  Expanded(
                    child: LayoutBuilder(
                      builder: (context, constraints) {
                        final double avail = constraints.maxHeight;
                        final bool hasQ = qCard != null;
                        final bool hasA = aCard != null;

                        if (!_quizStarted) {
                          return Center(child: _preStartCard());
                        }

                        final double minQuestionHeight = min(230.0, avail);
                        final double qH = hasQ
                            ? (hasA ? avail * 0.62 : avail)
                                .clamp(minQuestionHeight, avail)
                                .toDouble()
                            : 0.0;
                        final double gap = (hasQ && hasA) ? 8.0 : 0.0;
                        final double remainingForAnswer = max(0.0, avail - qH - gap);
                        final double minAnswerHeight = min(130.0, remainingForAnswer);
                        final double aH = hasA
                            ? remainingForAnswer
                                .clamp(minAnswerHeight, remainingForAnswer)
                                .toDouble()
                            : 0.0;

                        return SingleChildScrollView(
                          padding: EdgeInsets.zero,
                          child: ConstrainedBox(
                            constraints: BoxConstraints(minHeight: avail),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                if (hasQ)
                                  SizedBox(
                                    height: qH,
                                    width: double.infinity,
                                    child: qCard,
                                  ),
                                if (hasA) ...[
                                  SizedBox(height: gap),
                                  SizedBox(
                                    height: aH,
                                    width: double.infinity,
                                    child: aCard,
                                  ),
                                ],
                              ],
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                  const SizedBox(height: 8),
                  LayoutBuilder(
                    builder: (context, cons) {
                      final double gap = 12;
                      final double runGap = 10;
                      final double w = cons.maxWidth;
                      final double itemW = (w - gap) / 2;
                      const double itemH = 58;

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
                              disabledBackgroundColor: color.withOpacity(0.38),
                              elevation: onPressed == null ? 0 : 5,
                              shadowColor: Colors.black26,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(24),
                              ),
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 10),
                            ),
                            icon: Icon(icon, color: Colors.white, size: 23),
                            label: Text(
                              label,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: 17,
                              ),
                            ),
                            onPressed: onPressed,
                          ),
                        );
                      }

                      if (!_quizStarted) {
                        return SizedBox(
                          width: w,
                          height: 66,
                          child: ElevatedButton.icon(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.green.shade700,
                              disabledBackgroundColor: Colors.green.shade300,
                              elevation: 6,
                              shadowColor: Colors.black26,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(28),
                              ),
                              padding: const EdgeInsets.symmetric(vertical: 12),
                            ),
                            icon: const Icon(Icons.play_arrow_rounded, color: Colors.white, size: 30),
                            label: Text(
                              _lang == 'ar' ? 'ابدأ السؤال' : 'Start question',
                              style: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: 21,
                              ),
                            ),
                            onPressed: _files.isEmpty ? null : _beginQuizFromUserTap,
                          ),
                        );
                      }

                      final bool canShowAnswer = !_paused && _canPressAnswer;
                      Widget fullBtn({
                        required Color color,
                        required IconData icon,
                        required String label,
                        required VoidCallback? onPressed,
                        double height = 60,
                        double fontSize = 18,
                      }) {
                        return SizedBox(
                          width: w,
                          height: height,
                          child: ElevatedButton.icon(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: color,
                              disabledBackgroundColor: color.withOpacity(0.36),
                              elevation: onPressed == null ? 0 : 5,
                              shadowColor: Colors.black26,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(24),
                              ),
                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
                            ),
                            icon: Icon(icon, color: Colors.white, size: 24),
                            label: Text(
                              label,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: fontSize,
                              ),
                            ),
                            onPressed: onPressed,
                          ),
                        );
                      }

                      return Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          fullBtn(
                            color: Colors.green.shade800,
                            icon: Icons.visibility_rounded,
                            label: t('showAnswer'),
                            onPressed: canShowAnswer ? _playAnswerAyahs : null,
                            height: 60,
                            fontSize: 19,
                          ),
                          SizedBox(height: runGap),
                          Row(
                            children: [
                              Expanded(
                                child: SizedBox(
                                  height: itemH,
                                  child: ElevatedButton.icon(
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: Colors.green.shade700,
                                      disabledBackgroundColor: Colors.green.shade700.withOpacity(0.36),
                                      elevation: nextButtonActive ? 5 : 0,
                                      shadowColor: Colors.black26,
                                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
                                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 10),
                                    ),
                                    icon: const Icon(Icons.skip_next_rounded, color: Colors.white, size: 24),
                                    label: Text(
                                      _lang == 'ar' ? 'التالي' : 'Next',
                                      overflow: TextOverflow.ellipsis,
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontWeight: FontWeight.bold,
                                        fontSize: 18,
                                      ),
                                    ),
                                    onPressed: nextButtonActive ? _skipToNextRound : null,
                                  ),
                                ),
                              ),
                              SizedBox(width: gap),
                              Expanded(
                                child: SizedBox(
                                  height: itemH,
                                  child: ElevatedButton.icon(
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: _paused ? Colors.green.shade700 : Colors.orange.shade700,
                                      disabledBackgroundColor: Colors.orange.shade700.withOpacity(0.36),
                                      elevation: 5,
                                      shadowColor: Colors.black26,
                                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
                                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 10),
                                    ),
                                    icon: Icon(_paused ? Icons.play_arrow_rounded : Icons.pause_rounded, color: Colors.white, size: 24),
                                    label: Text(
                                      _paused ? t('resume') : t('pause'),
                                      overflow: TextOverflow.ellipsis,
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontWeight: FontWeight.bold,
                                        fontSize: 18,
                                      ),
                                    ),
                                    onPressed: _togglePause,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          SizedBox(height: runGap),
                          fullBtn(
                            color: Colors.purple.shade500,
                            icon: Icons.refresh_rounded,
                            label: _lang == 'ar'
                                ? 'إنهاء وبدء مسابقة جديدة'
                                : 'Finish and start a new quiz',
                            onPressed: () async {
                              final confirmed = await showDialog<bool>(
                                context: context,
                                builder: (dialogContext) => AlertDialog(
                                  title: Text(
                                    _lang == 'ar'
                                        ? 'إنهاء المسابقة؟'
                                        : 'Finish the quiz?',
                                  ),
                                  content: Text(
                                    _lang == 'ar'
                                        ? 'سيتم إيقاف المسابقة الحالية والعودة إلى الصفحة الرئيسية.'
                                        : 'The current quiz will stop and return to the home page.',
                                  ),
                                  actions: [
                                    TextButton(
                                      onPressed: () => Navigator.pop(dialogContext, false),
                                      child: Text(_lang == 'ar' ? 'إلغاء' : 'Cancel'),
                                    ),
                                    FilledButton(
                                      onPressed: () => Navigator.pop(dialogContext, true),
                                      child: Text(_lang == 'ar' ? 'إنهاء' : 'Finish'),
                                    ),
                                  ],
                                ),
                              );
                              if (confirmed != true || !mounted) return;
                              await _stopCurrentAudioNow();
                              await _killAllAudioAndInvalidateRound();
                              await _hardStopAndGoHome();
                            },
                            height: 58,
                            fontSize: 18,
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
