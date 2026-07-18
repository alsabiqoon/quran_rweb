import 'dart:async';
import 'dart:convert';
import 'dart:ui' show FontFeature;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:youtube_player_iframe/youtube_player_iframe.dart';

class CompetitionYearInfo {
  final String id;
  final String label;
  final String episodesFile;

  const CompetitionYearInfo({
    required this.id,
    required this.label,
    required this.episodesFile,
  });

  factory CompetitionYearInfo.fromJson(Map<String, dynamic> json) {
    return CompetitionYearInfo(
      id: (json['id'] as String? ?? '').trim(),
      label: (json['label'] as String? ?? '').trim(),
      episodesFile: (json['episodesFile'] as String? ?? '').trim(),
    );
  }
}

class CompetitionInfo {
  final String id;
  final String name;
  final String episodesFile;
  final String country;
  final String yearLabel;
  final bool available;
  final List<CompetitionYearInfo> years;

  const CompetitionInfo({
    required this.id,
    required this.name,
    required this.episodesFile,
    required this.country,
    required this.yearLabel,
    required this.available,
    required this.years,
  });

  factory CompetitionInfo.fromJson(Map<String, dynamic> json) {
    final years = (json['years'] as List<dynamic>? ?? const [])
        .whereType<Map<String, dynamic>>()
        .map(CompetitionYearInfo.fromJson)
        .where((year) => year.id.isNotEmpty && year.episodesFile.isNotEmpty)
        .toList();
    final episodesFile = (json['episodesFile'] as String? ?? '').trim();
    if (years.isEmpty && episodesFile.isNotEmpty) {
      years.add(
        CompetitionYearInfo(
          id: 'current',
          label: (json['yearLabel'] as String? ?? 'الحلقات الحالية').trim(),
          episodesFile: episodesFile,
        ),
      );
    }

    return CompetitionInfo(
      id: (json['id'] as String? ?? '').trim(),
      name: (json['name'] as String? ?? 'مسابقة القرآن الكريم').trim(),
      episodesFile: episodesFile,
      country: (json['country'] as String? ?? '').trim(),
      yearLabel: (json['yearLabel'] as String? ?? 'سنوات متعددة').trim(),
      available: json['available'] as bool? ?? true,
      years: years,
    );
  }
}

class EpisodeInfo {
  final String id;
  final String title;
  final String contestant;
  final String videoId;
  final String jsonFile;

  const EpisodeInfo({
    required this.id,
    required this.title,
    required this.contestant,
    required this.videoId,
    required this.jsonFile,
  });

  factory EpisodeInfo.fromJson(Map<String, dynamic> json) {
    return EpisodeInfo(
      id: (json['id'] as String? ?? '').trim(),
      title: (json['title'] as String? ?? 'حلقة').trim(),
      contestant: (json['contestant'] as String? ?? '').trim(),
      videoId: (json['videoId'] as String? ?? '').trim(),
      jsonFile: (json['jsonFile'] as String? ?? '').trim(),
    );
  }
}

class CompetitionListPage extends StatefulWidget {
  const CompetitionListPage({super.key});

  @override
  State<CompetitionListPage> createState() => _CompetitionListPageState();
}

class _CompetitionListPageState extends State<CompetitionListPage> {
  late Future<List<CompetitionInfo>> _futureCompetitions;
  String? _selectedCompetitionId;
  String? _selectedYearId;

  @override
  void initState() {
    super.initState();
    _futureCompetitions = _loadCompetitions();
  }

  Future<List<CompetitionInfo>> _loadCompetitions() async {
    final raw = await rootBundle.loadString(
      'assets/youtube_competitions/competitions_index.json',
    );

    final decoded = json.decode(raw) as Map<String, dynamic>;
    final items = decoded['competitions'] as List<dynamic>? ?? [];

    return items
        .whereType<Map<String, dynamic>>()
        .map(CompetitionInfo.fromJson)
        .where((item) => item.id.isNotEmpty)
        .toList();
  }

  void _reload() {
    setState(() {
      _futureCompetitions = _loadCompetitions();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'اختر المسابقة',
          style: TextStyle(fontWeight: FontWeight.w800),
        ),
        centerTitle: true,
        backgroundColor: const Color(0xFF166534),
        foregroundColor: Colors.white,
      ),
      body: FutureBuilder<List<CompetitionInfo>>(
        future: _futureCompetitions,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return _SelectionError(
              message: 'تعذر تحميل قائمة المسابقات\n${snapshot.error}',
              onRetry: _reload,
            );
          }

          final competitions = snapshot.data ?? const <CompetitionInfo>[];

          if (competitions.isEmpty) {
            return _SelectionError(
              message: 'لا توجد مسابقات مضافة حالياً.',
              onRetry: _reload,
            );
          }

          final selectedCompetition = competitions
              .where((item) => item.id == _selectedCompetitionId)
              .firstOrNull;
          final years = selectedCompetition?.years ?? const <CompetitionYearInfo>[];
          final selectedYear = years
              .where((item) => item.id == _selectedYearId)
              .firstOrNull;
          final canOpen = selectedCompetition?.available == true &&
              selectedYear != null;

          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: const Color(0xFFFFF7E6),
                  borderRadius: BorderRadius.circular(18),
                  border: Border.all(color: const Color(0xFFF2C66D)),
                ),
                child: const Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(Icons.construction_rounded, color: Color(0xFFB7791F)),
                    SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        'قسم المسابقات قيد العمل والتطوير. نضيف الدول والسنوات والحلقات تباعاً، وقد لا تتوفر بعض المسابقات حالياً.',
                        style: TextStyle(
                          color: Color(0xFF7A4B00),
                          fontSize: 15,
                          height: 1.45,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: const [
                    BoxShadow(
                      color: Color(0x16000000),
                      blurRadius: 16,
                      offset: Offset(0, 6),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const Text(
                      'اختر المسابقة والسنة',
                      style: TextStyle(fontSize: 19, fontWeight: FontWeight.w800),
                    ),
                    const SizedBox(height: 14),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          flex: 2,
                          child: DropdownButtonFormField<String>(
                            value: _selectedCompetitionId,
                            isExpanded: true,
                            decoration: const InputDecoration(
                              labelText: 'اسم المسابقة',
                              prefixIcon: Icon(Icons.emoji_events_rounded),
                              border: OutlineInputBorder(),
                            ),
                            items: competitions.map((competition) {
                              return DropdownMenuItem<String>(
                                value: competition.id,
                                child: Text(
                                  competition.name,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              );
                            }).toList(),
                            onChanged: (value) {
                              final competition = competitions
                                  .where((item) => item.id == value)
                                  .firstOrNull;
                              setState(() {
                                _selectedCompetitionId = value;
                                _selectedYearId = competition?.years.isNotEmpty == true
                                    ? competition!.years.first.id
                                    : null;
                              });
                            },
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: DropdownButtonFormField<String>(
                            value: _selectedYearId,
                            isExpanded: true,
                            decoration: const InputDecoration(
                              labelText: 'السنة',
                              prefixIcon: Icon(Icons.calendar_month_rounded),
                              border: OutlineInputBorder(),
                            ),
                            items: years.map((year) {
                              return DropdownMenuItem<String>(
                                value: year.id,
                                child: Text(year.label),
                              );
                            }).toList(),
                            onChanged: selectedCompetition?.available == true
                                ? (value) => setState(() => _selectedYearId = value)
                                : null,
                          ),
                        ),
                      ],
                    ),
                    if (selectedCompetition != null &&
                        !selectedCompetition.available) ...[
                      const SizedBox(height: 12),
                      const Text(
                        'هذه المسابقة قيد العمل وستتوفر قريباً بإذن الله.',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: Color(0xFF9A6700),
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
                    const SizedBox(height: 16),
                    FilledButton.icon(
                      onPressed: canOpen
                          ? () {
                              Navigator.of(context).push(
                                MaterialPageRoute<void>(
                                  builder: (_) => Directionality(
                                    textDirection: TextDirection.rtl,
                                    child: EpisodeListPage(
                                      competition: selectedCompetition!,
                                      episodesFile: selectedYear!.episodesFile,
                                      yearLabel: selectedYear!.label,
                                    ),
                                  ),
                                ),
                              );
                            }
                          : null,
                      icon: const Icon(Icons.playlist_play_rounded),
                      label: const Text('عرض الحلقات'),
                      style: FilledButton.styleFrom(
                        backgroundColor: const Color(0xFF166534),
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        textStyle: const TextStyle(
                          fontSize: 17,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

class _CompetitionTag extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool pending;

  const _CompetitionTag({
    required this.icon,
    required this.label,
    this.pending = false,
  });

  @override
  Widget build(BuildContext context) {
    final color = pending ? const Color(0xFF9A6700) : const Color(0xFF166534);
    final background = pending ? const Color(0xFFFFF3CD) : const Color(0xFFE8F5EC);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 5),
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 15, color: color),
          const SizedBox(width: 5),
          Text(
            label,
            style: TextStyle(
              color: color,
              fontSize: 12,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}

class CompetitionYearsPage extends StatelessWidget {
  final CompetitionInfo competition;

  const CompetitionYearsPage({
    super.key,
    required this.competition,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          competition.name,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: const TextStyle(fontWeight: FontWeight.w800),
        ),
        centerTitle: true,
        backgroundColor: const Color(0xFF166534),
        foregroundColor: Colors.white,
      ),
      body: ListView.separated(
        padding: const EdgeInsets.all(16),
        itemCount: competition.years.length,
        separatorBuilder: (_, __) => const SizedBox(height: 12),
        itemBuilder: (context, index) {
          final year = competition.years[index];
          return Material(
            color: Colors.white,
            elevation: 2,
            borderRadius: BorderRadius.circular(20),
            child: InkWell(
              borderRadius: BorderRadius.circular(20),
              onTap: () {
                Navigator.of(context).push(
                  MaterialPageRoute<void>(
                    builder: (_) => Directionality(
                      textDirection: TextDirection.rtl,
                      child: EpisodeListPage(
                        competition: competition,
                        episodesFile: year.episodesFile,
                        yearLabel: year.label,
                      ),
                    ),
                  ),
                );
              },
              child: Padding(
                padding: const EdgeInsets.all(18),
                child: Row(
                  children: [
                    Container(
                      width: 58,
                      height: 58,
                      decoration: BoxDecoration(
                        color: const Color(0xFFE8F5EC),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: const Icon(
                        Icons.calendar_month_rounded,
                        color: Color(0xFF166534),
                        size: 32,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'دورة ${year.label}',
                            style: const TextStyle(
                              fontSize: 19,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                          const SizedBox(height: 4),
                          const Text(
                            'اضغط لعرض حلقات هذه السنة',
                            style: TextStyle(
                              color: Color(0xFF64748B),
                              fontSize: 14,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const Icon(Icons.chevron_left_rounded),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

class EpisodeListPage extends StatefulWidget {
  final CompetitionInfo competition;
  final String episodesFile;
  final String yearLabel;

  const EpisodeListPage({
    super.key,
    required this.competition,
    required this.episodesFile,
    required this.yearLabel,
  });

  @override
  State<EpisodeListPage> createState() => _EpisodeListPageState();
}

class _EpisodeListPageState extends State<EpisodeListPage> {
  late Future<List<EpisodeInfo>> _futureEpisodes;

  @override
  void initState() {
    super.initState();
    _futureEpisodes = _loadEpisodes();
  }

  Future<List<EpisodeInfo>> _loadEpisodes() async {
    final raw = await rootBundle.loadString(widget.episodesFile);
    final decoded = json.decode(raw) as Map<String, dynamic>;
    final items = decoded['episodes'] as List<dynamic>? ?? [];

    return items
        .whereType<Map<String, dynamic>>()
        .map(EpisodeInfo.fromJson)
        .where((item) => item.jsonFile.isNotEmpty)
        .toList();
  }

  void _reload() {
    setState(() {
      _futureEpisodes = _loadEpisodes();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          '${widget.competition.name} • ${widget.yearLabel}',
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: const TextStyle(fontWeight: FontWeight.w800),
        ),
        centerTitle: true,
        backgroundColor: const Color(0xFF166534),
        foregroundColor: Colors.white,
      ),
      body: FutureBuilder<List<EpisodeInfo>>(
        future: _futureEpisodes,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return _SelectionError(
              message: 'تعذر تحميل حلقات المسابقة\n${snapshot.error}',
              onRetry: _reload,
            );
          }

          final episodes = snapshot.data ?? const <EpisodeInfo>[];

          if (episodes.isEmpty) {
            return _SelectionError(
              message: 'لا توجد حلقات داخل هذه المسابقة.',
              onRetry: _reload,
            );
          }

          return ListView.separated(
            padding: const EdgeInsets.all(16),
            itemCount: episodes.length,
            separatorBuilder: (_, __) => const SizedBox(height: 12),
            itemBuilder: (context, index) {
              final episode = episodes[index];
              final subtitle = episode.contestant.isNotEmpty
                  ? episode.contestant
                  : 'اضغط لفتح الحلقة';

              return Material(
                color: Colors.white,
                elevation: 1.5,
                borderRadius: BorderRadius.circular(18),
                child: InkWell(
                  borderRadius: BorderRadius.circular(18),
                  onTap: () {
                    Navigator.of(context).push(
                      MaterialPageRoute<void>(
                        builder: (_) => Directionality(
                          textDirection: TextDirection.rtl,
                          child: YoutubeQuizPage(
                            jsonAssetPath: episode.jsonFile,
                          ),
                        ),
                      ),
                    );
                  },
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 14,
                    ),
                    child: Row(
                      children: [
                        Container(
                          width: 54,
                          height: 54,
                          decoration: BoxDecoration(
                            color: const Color(0xFFEFF6FF),
                            borderRadius: BorderRadius.circular(15),
                          ),
                          child: const Icon(
                            Icons.play_circle_fill_rounded,
                            color: Color(0xFF2563EB),
                            size: 32,
                          ),
                        ),
                        const SizedBox(width: 14),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                episode.title,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(
                                  fontSize: 17,
                                  fontWeight: FontWeight.w800,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                subtitle,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(
                                  color: Color(0xFF64748B),
                                  fontSize: 14,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const Icon(Icons.chevron_left_rounded),
                      ],
                    ),
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}

class _SelectionError extends StatelessWidget {
  final String message;
  final VoidCallback onRetry;

  const _SelectionError({
    required this.message,
    required this.onRetry,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              Icons.error_outline_rounded,
              size: 54,
              color: Color(0xFFB91C1C),
            ),
            const SizedBox(height: 14),
            Text(
              message,
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 16),
            FilledButton.icon(
              onPressed: onRetry,
              icon: const Icon(Icons.refresh_rounded),
              label: const Text('إعادة المحاولة'),
            ),
          ],
        ),
      ),
    );
  }
}

class CompetitionQuestion {
  final int id;
  final int questionStart;
  final int questionEnd;
  final int answerStart;
  final int answerEnd;

  const CompetitionQuestion({
    required this.id,
    required this.questionStart,
    required this.questionEnd,
    required this.answerStart,
    required this.answerEnd,
  });

  int get questionDuration =>
      (questionEnd - questionStart).clamp(1, 99999);

  int get answerDuration =>
      (answerEnd - answerStart).clamp(1, 99999);
}

class CompetitionData {
  final String competition;
  final String videoId;
  final List<CompetitionQuestion> questions;

  const CompetitionData({
    required this.competition,
    required this.videoId,
    required this.questions,
  });

  factory CompetitionData.fromJson(Map<String, dynamic> json) {
    final rawQuestions = (json['questions'] as List<dynamic>? ?? [])
        .cast<Map<String, dynamic>>();

    final parsed = <CompetitionQuestion>[];

    for (int i = 0; i < rawQuestions.length; i++) {
      final q = rawQuestions[i];

      final questionStart =
          (q['questionStart'] as num?)?.toInt() ??
              (q['start'] as num?)?.toInt() ??
              0;

      final questionEnd =
          (q['questionEnd'] as num?)?.toInt() ??
              (q['end'] as num?)?.toInt() ??
              questionStart + 15;

      final answerStart =
          (q['answerStart'] as num?)?.toInt() ?? questionEnd;

      final answerEnd =
          (q['answerEnd'] as num?)?.toInt() ?? answerStart + 60;

      parsed.add(
        CompetitionQuestion(
          id: (q['id'] as num?)?.toInt() ?? i + 1,
          questionStart: questionStart,
          questionEnd: questionEnd,
          answerStart: answerStart,
          answerEnd: answerEnd,
        ),
      );
    }

    return CompetitionData(
      competition: json['competition'] as String? ?? 'مسابقة القرآن الكريم',
      videoId: json['videoId'] as String? ?? '',
      questions: parsed,
    );
  }
}

enum PlayerPhase {
  ready,
  questionPlaying,
  contestantAnswering,
  answerPlaying,
  finished,
}

class YoutubeQuizPage extends StatefulWidget {
  final String jsonAssetPath;

  const YoutubeQuizPage({
    super.key,
    required this.jsonAssetPath,
  });

  @override
  State<YoutubeQuizPage> createState() => _YoutubeQuizPageState();
}

class _YoutubeQuizPageState extends State<YoutubeQuizPage> {
  CompetitionData? _competition;
  YoutubePlayerController? _controller;

  int _currentQuestionIndex = 0;
  int _countdown = 0;
  int _answerDuration = 1;
  int _segmentElapsed = 0;
  int _segmentDuration = 1;
  bool _videoPaused = false;
  bool _commandBusy = false;
  bool _showOverlay = true;
  bool _autoStartTried = false;
  bool _autoStartBlocked = false;

  Timer? _videoWatchTimer;
  Timer? _answerTimer;

  bool _loading = true;
  bool _timerPaused = false;
  bool _showVideoControls = true;
  Timer? _hideControlsTimer;
  PlayerPhase _phase = PlayerPhase.ready;

  CompetitionQuestion? get _currentQuestion {
    final data = _competition;
    if (data == null || data.questions.isEmpty) return null;
    if (_currentQuestionIndex < 0 ||
        _currentQuestionIndex >= data.questions.length) {
      return null;
    }
    return data.questions[_currentQuestionIndex];
  }

  bool get _isRunning =>
      _phase == PlayerPhase.questionPlaying ||
      _phase == PlayerPhase.contestantAnswering ||
      _phase == PlayerPhase.answerPlaying;

  @override
  void initState() {
    super.initState();
    _loadCompetition();
  }

  @override
  void dispose() {
    _videoWatchTimer?.cancel();
    _answerTimer?.cancel();
    _hideControlsTimer?.cancel();
    _controller?.close();
    super.dispose();
  }

  Future<void> _loadCompetition() async {
    try {
      final raw = await rootBundle.loadString(
        widget.jsonAssetPath,
      );

 
      final data = CompetitionData.fromJson(
        json.decode(raw) as Map<String, dynamic>,
      );

      final controller = YoutubePlayerController.fromVideoId(
        videoId: data.videoId,
        autoPlay: false,
        params: const YoutubePlayerParams(
          showControls: false,
          showFullscreenButton: false,
          playsInline: true,
          strictRelatedVideos: true,
          pointerEvents: PointerEvents.none,
        ),
      );

      if (!mounted) return;
      setState(() {
        _competition = data;
        _controller = controller;
        _loading = false;
        _showOverlay = true;
      });

      // نحاول تشغيل السؤال الأول تلقائياً بعد تجهيز الواجهة.
      // إذا منع Chrome التشغيل التلقائي، يبقى الغطاء ويكفي ضغط المستخدم مرة واحدة.
      WidgetsBinding.instance.addPostFrameCallback((_) {
        Future<void>.delayed(const Duration(milliseconds: 900), () async {
          if (!mounted || _autoStartTried) return;

          setState(() {
            _autoStartTried = true;
            _autoStartBlocked = false;
          });

          await _runCommand(
            () => _playQuestion(automaticAttempt: true),
          );
        });
      });
    } catch (e) {
      if (!mounted) return;
      setState(() => _loading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('خطأ في تحميل المسابقة: $e')),
      );
    }
  }

  Future<void> _runCommand(Future<void> Function() action) async {
    if (_commandBusy) return;

    if (mounted) {
      setState(() => _commandBusy = true);
    }

    try {
      await action();
    } finally {
      if (mounted) {
        setState(() => _commandBusy = false);
      }
    }
  }

  Future<int> _currentVideoSecond() async {
    final controller = _controller;
    if (controller == null) return 0;

    try {
      return (await controller.currentTime).floor();
    } catch (_) {
      return 0;
    }
  }

  Future<bool> _loadAndStartAt(int second) async {
    final controller = _controller;
    final competition = _competition;
    if (controller == null || competition == null) return false;

    try {
      // نبقي الغطاء ظاهراً حتى يبدأ YouTube فعلياً بعرض المقطع.
      if (mounted) {
        setState(() => _showOverlay = true);
      }

      await controller.loadVideoById(
        videoId: competition.videoId,
        startSeconds: second.toDouble(),
      );
      await controller.playVideo();

      // ننتظر حتى يصبح المشغل جاهزاً ويصل إلى موضع البداية.
      for (int i = 0; i < 24; i++) {
        await Future.delayed(const Duration(milliseconds: 150));
        final current = await _currentVideoSecond();

        if (current >= second) {
          if (mounted) {
            setState(() => _showOverlay = false);
          }
          return true;
        }
      }

      return false;
    } catch (_) {
      return false;
    }
  }

  Future<void> _playQuestion({bool automaticAttempt = false}) async {
    final question = _currentQuestion;
    final controller = _controller;
    if (question == null || controller == null) return;

    _videoWatchTimer?.cancel();
    _answerTimer?.cancel();

    setState(() {
      _phase = PlayerPhase.questionPlaying;
      _countdown = 0;
      _segmentElapsed = 0;
      _segmentDuration = question.questionDuration.clamp(1, 99999);
      _videoPaused = false;
    });

    final started = await _loadAndStartAt(question.questionStart);
    if (!started) {
      if (!mounted) return;

      setState(() {
        _phase = PlayerPhase.ready;
        _videoPaused = false;
        _showOverlay = true;
        _autoStartBlocked = automaticAttempt;
      });

      if (!automaticAttempt) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('تعذر تشغيل السؤال. اضغط التشغيل مرة أخرى.'),
          ),
        );
      }
      return;
    }

    if (mounted) {
      setState(() => _autoStartBlocked = false);
    }

    _videoWatchTimer = Timer.periodic(
      const Duration(milliseconds: 250),
      (_) async {
        final current = await _currentVideoSecond();
        final elapsed = (current - question.questionStart)
            .clamp(0, _segmentDuration);
        if (mounted && elapsed != _segmentElapsed) {
          setState(() => _segmentElapsed = elapsed);
        }

        if (current >= question.questionEnd) {
          _videoWatchTimer?.cancel();

          try {
            await controller.pauseVideo();
          } catch (_) {}

          if (!mounted) return;
          _startContestantCountdown(question.answerDuration);
        }
      },
    );
  }

  void _startContestantCountdown(int seconds) {
    _answerTimer?.cancel();

    setState(() {
      _phase = PlayerPhase.contestantAnswering;
      _answerDuration = seconds.clamp(1, 99999);
      _countdown = seconds.clamp(1, 99999);
      _timerPaused = false;
      _showOverlay = true;
    });

    _answerTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!mounted) return;

      if (_timerPaused) return;

      if (_countdown <= 1) {
        timer.cancel();
        setState(() => _countdown = 0);
        return;
      }

      setState(() => _countdown--);
    });
  }

  void _toggleTimerPause() {
    if (_phase != PlayerPhase.contestantAnswering) return;
    setState(() => _timerPaused = !_timerPaused);
  }

  Future<void> _toggleVideoPlayback() async {
    final controller = _controller;
    if (controller == null) return;
    if (_phase != PlayerPhase.questionPlaying &&
        _phase != PlayerPhase.answerPlaying) {
      return;
    }

    if (_videoPaused) {
      await controller.playVideo();
      if (!mounted) return;
      setState(() {
        _videoPaused = false;
        _showOverlay = false;
      });
    } else {
      await controller.pauseVideo();
      if (!mounted) return;
      setState(() {
        _videoPaused = true;
        _showOverlay = true;
      });
    }
  }

  Future<void> _showAnswer() async {
    final question = _currentQuestion;
    final controller = _controller;
    if (question == null || controller == null) return;

    _answerTimer?.cancel();
    _videoWatchTimer?.cancel();

    setState(() {
      _phase = PlayerPhase.answerPlaying;
      _timerPaused = false;
      _videoPaused = false;
      _segmentElapsed = 0;
      _segmentDuration = question.answerDuration.clamp(1, 99999);
    });

    final started = await _loadAndStartAt(question.answerStart);
    if (!started) {
      if (!mounted) return;
      _startContestantCountdown(question.answerDuration);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('تعذر تشغيل الإجابة. حاول مرة أخرى.')),
      );
      return;
    }

    _videoWatchTimer = Timer.periodic(
      const Duration(milliseconds: 250),
      (_) async {
        final current = await _currentVideoSecond();
        final elapsed = (current - question.answerStart)
            .clamp(0, _segmentDuration);
        if (mounted && elapsed != _segmentElapsed) {
          setState(() => _segmentElapsed = elapsed);
        }
        if (current >= question.answerEnd) {
          _videoWatchTimer?.cancel();
          try {
            await controller.pauseVideo();
          } catch (_) {}
          if (!mounted) return;
          await _goToNextQuestion(autoStart: true);
        }
      },
    );
  }

  Future<void> _goToNextQuestion({bool autoStart = false}) async {
    final data = _competition;
    final controller = _controller;
    if (data == null || controller == null) return;

    _videoWatchTimer?.cancel();
    _answerTimer?.cancel();

    final nextIndex = _currentQuestionIndex + 1;

    if (nextIndex >= data.questions.length) {
      await controller.pauseVideo();
      if (!mounted) return;

      setState(() {
        _phase = PlayerPhase.finished;
        _countdown = 0;
        _showOverlay = true;
      });

      _showFinishedDialog();
      return;
    }

    final nextQuestion = data.questions[nextIndex];

    setState(() {
      _currentQuestionIndex = nextIndex;
      _phase = PlayerPhase.ready;
      _countdown = 0;
      _timerPaused = false;
      _videoPaused = false;
      _segmentElapsed = 0;
      _showOverlay = true;
    });

    if (autoStart && mounted) {
      await _playQuestion();
    } else {
      await controller.seekTo(
        seconds: nextQuestion.questionStart.toDouble(),
      );
      await controller.pauseVideo();
    }
  }

  Future<void> _goToPreviousQuestion() async {
    final data = _competition;
    final controller = _controller;
    if (data == null || controller == null || _currentQuestionIndex == 0) return;

    _videoWatchTimer?.cancel();
    _answerTimer?.cancel();

    final previousIndex = _currentQuestionIndex - 1;
    final previousQuestion = data.questions[previousIndex];

    setState(() {
      _currentQuestionIndex = previousIndex;
      _phase = PlayerPhase.ready;
      _countdown = 0;
      _timerPaused = false;
      _videoPaused = false;
      _segmentElapsed = 0;
      _showOverlay = true;
    });

    // عند الانتقال إلى السؤال السابق يبدأ السؤال مباشرة.
    if (mounted) {
      await _playQuestion();
    }
  }

  Future<void> _restartCurrentQuestion() async {
    await _playQuestion();
  }

  void _showFinishedDialog() {
    showDialog<void>(
      context: context,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(22),
        ),
        title: const Text('انتهت المسابقة'),
        content: const Text('تم الانتهاء من جميع الأسئلة.'),
        actionsAlignment: MainAxisAlignment.center,
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('البقاء هنا'),
          ),
          FilledButton.icon(
            onPressed: () {
              Navigator.pop(context);
              _exitEpisode();
            },
            icon: const Icon(Icons.home_rounded),
            label: const Text('العودة إلى الصفحة الرئيسية'),
          ),
        ],
      ),
    );
  }

  String _formatSeconds(int totalSeconds) {
    final minutes = totalSeconds ~/ 60;
    final seconds = totalSeconds % 60;
    return '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
  }

  String _statusText() {
    switch (_phase) {
      case PlayerPhase.ready:
        return 'اضغط لبدء السؤال';
      case PlayerPhase.questionPlaying:
        return 'استمع جيداً للسؤال';
      case PlayerPhase.contestantAnswering:
        return _timerPaused ? 'المؤقت متوقف' : 'أجب الآن';
      case PlayerPhase.answerPlaying:
        return 'عرض الإجابة';
      case PlayerPhase.finished:
        return 'انتهت المسابقة';
    }
  }

  IconData _statusIcon() {
    switch (_phase) {
      case PlayerPhase.ready:
        return Icons.play_arrow_rounded;
      case PlayerPhase.questionPlaying:
        return Icons.hearing_rounded;
      case PlayerPhase.contestantAnswering:
        return _timerPaused ? Icons.pause_circle_rounded : Icons.timer_rounded;
      case PlayerPhase.answerPlaying:
        return Icons.visibility_rounded;
      case PlayerPhase.finished:
        return Icons.emoji_events_rounded;
    }
  }

  Color _statusColor() {
    switch (_phase) {
      case PlayerPhase.ready:
        return const Color(0xFF15803D);
      case PlayerPhase.questionPlaying:
        return const Color(0xFF2563EB);
      case PlayerPhase.contestantAnswering:
        return const Color(0xFFF59E0B);
      case PlayerPhase.answerPlaying:
        return const Color(0xFF2563EB);
      case PlayerPhase.finished:
        return const Color(0xFF7C3AED);
    }
  }

  double get _answerProgress {
    if (_phase != PlayerPhase.contestantAnswering || _answerDuration <= 0) {
      return 1;
    }
    return (_countdown / _answerDuration).clamp(0.0, 1.0);
  }

  Future<void> _exitEpisode() async {
    _videoWatchTimer?.cancel();
    _answerTimer?.cancel();
    _hideControlsTimer?.cancel();

    try {
      await _controller?.pauseVideo();
    } catch (_) {}

    if (!mounted) return;

    Navigator.of(context).popUntil((route) => route.isFirst);
  }

  @override
  Widget build(BuildContext context) {
    final data = _competition;
    final controller = _controller;

    return Scaffold(
      body: SafeArea(
        child: Stack(
          children: [
            Positioned.fill(
              child: _loading
                  ? const Center(child: CircularProgressIndicator())
                  : data == null || controller == null
                      ? const Center(child: Text('تعذر تحميل المسابقة'))
                      : LayoutBuilder(
                          builder: (context, constraints) {
                            final isWide = constraints.maxWidth >= 950;

                            return SingleChildScrollView(
                              padding: EdgeInsets.symmetric(
                                horizontal: isWide ? 24 : 12,
                                vertical: 12,
                              ),
                              child: Center(
                                child: ConstrainedBox(
                                  constraints:
                                      const BoxConstraints(maxWidth: 1280),
                                  child: Column(
                                    children: [
                                      _buildCompactHeader(data),
                                      const SizedBox(height: 14),
                                      _buildInteractiveVideo(controller, data),
                                    ],
                                  ),
                                ),
                              ),
                            );
                          },
                        ),
            ),

          ],
        ),
      ),
    );
  }

  Widget _buildCompactHeader(CompetitionData data) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
      decoration: BoxDecoration(
        color: const Color(0xFF166534),
        borderRadius: BorderRadius.circular(18),
      ),
      child: Text(
        data.competition.trim().isEmpty ||
                data.competition.toLowerCase().contains('dubai quran')
            ? 'مسابقة دبي الدولية للقرآن الكريم'
            : data.competition,
        textAlign: TextAlign.center,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: const TextStyle(
          color: Colors.white,
          fontSize: 20,
          fontWeight: FontWeight.w800,
        ),
      ),
    );
  }

  void _revealVideoControls({bool autoHide = true}) {
    _hideControlsTimer?.cancel();
    if (!_showVideoControls && mounted) {
      setState(() => _showVideoControls = true);
    }

    if (autoHide && _phase != PlayerPhase.ready) {
      _hideControlsTimer = Timer(const Duration(seconds: 3), () {
        if (mounted) setState(() => _showVideoControls = false);
      });
    }
  }

  void _hideVideoControlsNow() {
    _hideControlsTimer?.cancel();
    if (mounted && _phase != PlayerPhase.ready) {
      setState(() => _showVideoControls = false);
    }
  }

  double _videoProgressValue() {
    if (_phase == PlayerPhase.questionPlaying ||
        _phase == PlayerPhase.answerPlaying) {
      if (_segmentDuration <= 0) return 0;
      return (_segmentElapsed / _segmentDuration).clamp(0.0, 1.0);
    }

    if (_phase == PlayerPhase.contestantAnswering) {
      if (_answerDuration <= 0) return 0;
      return (1 - (_countdown / _answerDuration)).clamp(0.0, 1.0);
    }

    return 0;
  }

  Widget _buildYoutubeCover(String videoId) {
    final maxRes = 'https://img.youtube.com/vi/$videoId/maxresdefault.jpg';
    final fallback = 'https://img.youtube.com/vi/$videoId/hqdefault.jpg';

    return Image.network(
      maxRes,
      fit: BoxFit.cover,
      errorBuilder: (_, __, ___) {
        return Image.network(
          fallback,
          fit: BoxFit.cover,
          errorBuilder: (_, __, ___) {
            return const ColoredBox(color: Colors.black);
          },
        );
      },
    );
  }

  Widget _buildInteractiveVideo(
    YoutubePlayerController controller,
    CompetitionData data,
  ) {
    final isFirst = _currentQuestionIndex == 0;
    final isLast = _currentQuestionIndex == data.questions.length - 1;
    final canShowAnswer = _phase == PlayerPhase.contestantAnswering;
    final canPauseTimer = _phase == PlayerPhase.contestantAnswering;

    String compactStatus() {
      if (_phase == PlayerPhase.contestantAnswering) {
        return _formatSeconds(_countdown);
      }
      return '';
    }

    Color phaseColor() {
      switch (_phase) {
        case PlayerPhase.ready:
        case PlayerPhase.questionPlaying:
          return const Color(0xFF15803D);
        case PlayerPhase.contestantAnswering:
          return const Color(0xFFF59E0B);
        case PlayerPhase.answerPlaying:
          return const Color(0xFF2563EB);
        case PlayerPhase.finished:
          return const Color(0xFF7C3AED);
      }
    }

    Widget iconAction({
      required String tooltip,
      required IconData icon,
      required VoidCallback? onPressed,
      Color? activeColor,
      bool emphasized = false,
    }) {
      final effectiveOnPressed = _commandBusy ? null : onPressed;
      final enabled = effectiveOnPressed != null;
      final color = activeColor ?? const Color(0xFF334155);

      return Tooltip(
        message: tooltip,
        waitDuration: const Duration(milliseconds: 300),
        child: Material(
          color: enabled
              ? (emphasized ? color : Colors.transparent)
              : Colors.transparent,
          borderRadius: BorderRadius.circular(14),
          child: InkWell(
            onTap: effectiveOnPressed,
            borderRadius: BorderRadius.circular(14),
            child: SizedBox(
              width: emphasized ? 58 : 50,
              height: 50,
              child: Icon(
                icon,
                size: emphasized ? 30 : 26,
                color: enabled
                    ? (emphasized ? Colors.white : color)
                    : Colors.grey.shade300,
              ),
            ),
          ),
        ),
      );
    }

    Widget mainAction() {
      if (_phase == PlayerPhase.ready) {
        return iconAction(
          tooltip: 'تشغيل السؤال',
          icon: Icons.play_arrow_rounded,
          onPressed: () => _runCommand(() => _playQuestion()),
          activeColor: const Color(0xFF15803D),
          emphasized: true,
        );
      }

      if (_phase == PlayerPhase.contestantAnswering) {
        return iconAction(
          tooltip: _timerPaused ? 'استئناف المؤقت' : 'إيقاف المؤقت',
          icon: _timerPaused ? Icons.play_arrow_rounded : Icons.pause_rounded,
          onPressed: _commandBusy ? null : _toggleTimerPause,
          activeColor: const Color(0xFFF59E0B),
          emphasized: true,
        );
      }

      if (_phase == PlayerPhase.questionPlaying ||
          _phase == PlayerPhase.answerPlaying) {
        return iconAction(
          tooltip: _videoPaused ? 'استئناف الفيديو' : 'إيقاف الفيديو',
          icon: _videoPaused ? Icons.play_arrow_rounded : Icons.pause_rounded,
          onPressed: () => _runCommand(_toggleVideoPlayback),
          activeColor: _phase == PlayerPhase.answerPlaying
              ? const Color(0xFF2563EB)
              : const Color(0xFF15803D),
          emphasized: true,
        );
      }

      return iconAction(
        tooltip: 'انتهت المسابقة',
        icon: Icons.stop_rounded,
        onPressed: null,
        activeColor: phaseColor(),
        emphasized: true,
      );
    }

    final buttons = <Widget>[
      iconAction(
        tooltip: 'العودة إلى الصفحة الرئيسية',
        icon: Icons.home_rounded,
        onPressed: _exitEpisode,
        activeColor: const Color(0xFF166534),
      ),
      iconAction(
        tooltip: 'السابق',
        icon: Icons.skip_previous_rounded,
        onPressed: isFirst ? null : () => _runCommand(_goToPreviousQuestion),
      ),
      iconAction(
        tooltip: 'إعادة السؤال',
        icon: Icons.replay_rounded,
        onPressed: () => _runCommand(_restartCurrentQuestion),
      ),
      mainAction(),
      iconAction(
        tooltip: 'عرض الإجابة',
        icon: Icons.visibility_rounded,
        onPressed: canShowAnswer ? () => _runCommand(_showAnswer) : null,
        activeColor: const Color(0xFF2563EB),
      ),
      iconAction(
        tooltip: isLast ? 'إنهاء' : 'التالي',
        icon: isLast ? Icons.stop_circle_outlined : Icons.skip_next_rounded,
        onPressed: () => _runCommand(() => _goToNextQuestion(autoStart: true)),
      ),
    ];

    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(6),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(22),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.08),
                blurRadius: 22,
                offset: const Offset(0, 9),
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(17),
            child: AspectRatio(
              aspectRatio: 16 / 9,
              child: Stack(
                fit: StackFit.expand,
                children: [
                  // يبقى YouTube مباشراً، لكن المستخدم لا يستطيع لمس أي عنصر داخله.
                  AbsorbPointer(
                    absorbing: true,
                    child: YoutubePlayer(controller: controller),
                  ),

                  // غطاء كامل فوق YouTube في الاستعداد، وقت إجابة المتسابق،
                  // الإيقاف المؤقت، والانتهاء. هذا يخفي زر YouTube الأحمر
                  // وWatch on YouTube والشريط وروابط المشغّل.
                  if (_showOverlay || _commandBusy)
                    Positioned.fill(
                      child: Stack(
                        fit: StackFit.expand,
                        children: [
                          _buildYoutubeCover(data.videoId),
                          Container(
                            color: Colors.black.withOpacity(
                              _phase == PlayerPhase.contestantAnswering
                                  ? 0.62
                                  : 0.36,
                            ),
                          ),

                          if (_phase == PlayerPhase.ready &&
                              !_commandBusy &&
                              _autoStartBlocked)
                            const Positioned(
                              left: 20,
                              right: 20,
                              bottom: 28,
                              child: Text(
                                'اضغط زر التشغيل لبدء المسابقة',
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 16,
                                  fontWeight: FontWeight.w800,
                                  shadows: [
                                    Shadow(
                                      color: Colors.black,
                                      blurRadius: 5,
                                    ),
                                  ],
                                ),
                              ),
                            ),

                          if (_phase == PlayerPhase.ready && !_commandBusy)
                            Center(
                              child: Material(
                                color: const Color(0xFF15803D),
                                elevation: 5,
                                borderRadius: BorderRadius.circular(22),
                                child: InkWell(
                                  borderRadius: BorderRadius.circular(22),
                                  onTap: () => _runCommand(() => _playQuestion()),
                                  child: const SizedBox(
                                    width: 94,
                                    height: 72,
                                    child: Icon(
                                      Icons.play_arrow_rounded,
                                      color: Colors.white,
                                      size: 56,
                                    ),
                                  ),
                                ),
                              ),
                            ),

                          if (_phase == PlayerPhase.contestantAnswering)
                            Center(
                              child: Icon(
                                _timerPaused
                                    ? Icons.pause_circle_filled_rounded
                                    : Icons.timer_rounded,
                                color: Colors.white.withOpacity(0.94),
                                size: 64,
                              ),
                            ),

                          if (_videoPaused)
                            Center(
                              child: Icon(
                                Icons.pause_circle_filled_rounded,
                                color: Colors.white.withOpacity(0.94),
                                size: 66,
                              ),
                            ),

                          if (_commandBusy)
                            const Center(
                              child: SizedBox(
                                width: 42,
                                height: 42,
                                child: CircularProgressIndicator(
                                  strokeWidth: 4,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                        ],
                      ),
                    ),

                  // عداد الأسئلة في زاوية هادئة، وشريط الزمن في أسفل الفيديو تماماً.
                  IgnorePointer(
                    child: Stack(
                      children: [
                        Positioned(
                          right: 12,
                          bottom: 18,
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 10,
                              vertical: 5,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.black.withOpacity(0.72),
                              borderRadius: BorderRadius.circular(16),
                            ),
                            child: Text(
                              '${_currentQuestionIndex + 1} / ${data.questions.length}',
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 13,
                                fontWeight: FontWeight.w800,
                                fontFeatures: [FontFeature.tabularFigures()],
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
                              if (_phase == PlayerPhase.questionPlaying ||
                                  _phase == PlayerPhase.answerPlaying)
                                Padding(
                                  padding: const EdgeInsets.only(
                                    left: 12,
                                    right: 12,
                                    bottom: 5,
                                  ),
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Text(
                                        '${_formatSeconds(_segmentElapsed)} / ${_formatSeconds(_segmentDuration)}',
                                        style: const TextStyle(
                                          color: Colors.white,
                                          fontSize: 13,
                                          fontWeight: FontWeight.w800,
                                          shadows: [
                                            Shadow(
                                              color: Colors.black,
                                              blurRadius: 4,
                                            ),
                                          ],
                                          fontFeatures: [
                                            FontFeature.tabularFigures(),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                )
                              else if (_phase == PlayerPhase.contestantAnswering)
                                Padding(
                                  padding: const EdgeInsets.only(bottom: 5),
                                  child: Text(
                                    _formatSeconds(_countdown),
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 14,
                                      fontWeight: FontWeight.w900,
                                      shadows: [
                                        Shadow(
                                          color: Colors.black,
                                          blurRadius: 4,
                                        ),
                                      ],
                                      fontFeatures: [
                                        FontFeature.tabularFigures(),
                                      ],
                                    ),
                                  ),
                                ),
                              LinearProgressIndicator(
                                minHeight: 4,
                                value: _videoProgressValue(),
                                backgroundColor: Colors.white38,
                                valueColor: const AlwaysStoppedAnimation<Color>(
                                  Color(0xFFFF0000),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
        const SizedBox(height: 10),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: const Color(0xFFE2E8F0)),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.045),
                blurRadius: 14,
                offset: const Offset(0, 5),
              ),
            ],
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: buttons,
          ),
        ),
      ],
    );
  }


}
