import 'dart:async';
import 'dart:convert';

import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:just_audio/just_audio.dart' as ja;

class ListeningPage extends StatefulWidget {
  final String mode;
  final List<String> selectedSurahs;
  final int pageFrom;
  final int pageTo;
  final int juzFrom;
  final int juzTo;
  final int hizbFrom;
  final int hizbTo;
  final int rubFrom;
  final int rubTo;
  final String reciterUrl;
  final String reciterName;

  const ListeningPage({
    super.key,
    required this.mode,
    required this.selectedSurahs,
    required this.pageFrom,
    required this.pageTo,
    required this.juzFrom,
    required this.juzTo,
    required this.hizbFrom,
    required this.hizbTo,
    required this.rubFrom,
    required this.rubTo,
    required this.reciterUrl,
    required this.reciterName,
  });

  @override
  State<ListeningPage> createState() => _ListeningPageState();
}

class _ListeningAyah {
  final String fileName;
  final String text;
  final String surah;
  final int ayah;
  final int page;
  final int juz;
  final int hizb;
  final int rub;

  const _ListeningAyah({
    required this.fileName,
    required this.text,
    required this.surah,
    required this.ayah,
    required this.page,
    required this.juz,
    required this.hizb,
    required this.rub,
  });
}

class _ListeningPageState extends State<ListeningPage> {
  static const int _webPlaylistRepeats = 5;
  final AudioPlayer _player = AudioPlayer();
  final AudioPlayer _introPlayer = AudioPlayer();
  final ja.AudioPlayer _webPlayer = ja.AudioPlayer();
  StreamSubscription<void>? _completeSub;
  StreamSubscription<void>? _introCompleteSub;
  StreamSubscription<Duration>? _positionSub;
  StreamSubscription<Duration>? _durationSub;
  StreamSubscription<Duration?>? _webDurationSub;
  StreamSubscription<int?>? _webIndexSub;
  StreamSubscription<ja.PlayerState>? _webStateSub;
  List<_ListeningAyah> _ayahs = const [];
  int _index = 0;
  bool _loading = true;
  bool _playing = false;
  bool _paused = false;
  bool _playingTaawudh = false;
  bool _playingBismillah = false;
  bool _taawudhPlayed = false;
  bool _bismillahPlayed = false;
  bool _initialAudioPrepared = false;
  bool _iosUnlockingAyah = false;
  bool _awaitingIosAyahTap = false;
  bool _webPlaylistReady = false;
  int _repeatCount = 1;
  int _repeatIteration = 0;
  Duration _position = Duration.zero;
  Duration _duration = Duration.zero;
  bool _draggingProgress = false;
  double _dragProgress = 0;
  String? _error;

  _ListeningAyah? get _current => _ayahs.isEmpty ? null : _ayahs[_index];
  // Browsers may mask the iPhone platform (especially in installed PWAs),
  // so apply the user-gesture-safe path to every web build.
  bool get _requiresInitialTap => kIsWeb;

  @override
  void initState() {
    super.initState();
    // Keep the same media element alive between ta'awwudh, basmala and ayahs.
    // Safari on iOS loses the user-granted playback permission if the player is
    // released after every source, so the first ayah would wait for another tap.
    _player.setReleaseMode(ReleaseMode.stop);
    _player.setPlayerMode(PlayerMode.mediaPlayer);
    if (kIsWeb) {
      _positionSub = _webPlayer.positionStream.listen((position) {
        if (mounted) setState(() => _position = position);
      });
      _webDurationSub = _webPlayer.durationStream.listen((duration) {
        if (mounted) setState(() => _duration = duration ?? Duration.zero);
      });
      _webIndexSub = _webPlayer.currentIndexStream.listen((index) async {
        if (!mounted || index == null) return;
        if (index >= 2 && _ayahs.isNotEmpty) {
          final repeatedIndex = index - 2;
          final ayahIndex = repeatedIndex ~/ _webPlaylistRepeats;
          final iteration = repeatedIndex % _webPlaylistRepeats;
          if (iteration >= _repeatCount) {
            final nextAyah = ayahIndex + 1;
            if (nextAyah < _ayahs.length) {
              await _webPlayer.seek(
                Duration.zero,
                index: _webPlaylistIndexForAyah(nextAyah),
              );
            } else {
              await _webPlayer.pause();
            }
            return;
          }
        }
        setState(() {
          if (index == 0) {
            _playingTaawudh = true;
            _playingBismillah = false;
          } else if (index == 1) {
            _playingTaawudh = false;
            _taawudhPlayed = true;
            _playingBismillah = true;
          } else {
            _playingTaawudh = false;
            _playingBismillah = false;
            _taawudhPlayed = true;
            _bismillahPlayed = true;
            final repeatedIndex = index - 2;
            _index = (repeatedIndex ~/ _webPlaylistRepeats)
                .clamp(0, _ayahs.length - 1)
                .toInt();
            _repeatIteration = repeatedIndex % _webPlaylistRepeats;
          }
        });
      });
      _webStateSub = _webPlayer.playerStateStream.listen((state) {
        if (!mounted) return;
        setState(() {
          _playing = state.playing;
          _paused = !state.playing &&
              state.processingState != ja.ProcessingState.completed;
        });
      });
    } else {
      _completeSub = _player.onPlayerComplete.listen((_) => _handleComplete());
      _positionSub = _player.onPositionChanged.listen((position) {
        if (mounted) setState(() => _position = position);
      });
      _durationSub = _player.onDurationChanged.listen((duration) {
        if (mounted) setState(() => _duration = duration);
      });
    }
    _introPlayer.setReleaseMode(ReleaseMode.stop);
    _introPlayer.setPlayerMode(PlayerMode.mediaPlayer);
    _introCompleteSub =
        _introPlayer.onPlayerComplete.listen((_) => _handleIosIntroComplete());
    _loadAyahs();
  }

  @override
  void dispose() {
    _completeSub?.cancel();
    _introCompleteSub?.cancel();
    _positionSub?.cancel();
    _durationSub?.cancel();
    _webDurationSub?.cancel();
    _webIndexSub?.cancel();
    _webStateSub?.cancel();
    _player.dispose();
    _introPlayer.dispose();
    _webPlayer.dispose();
    super.dispose();
  }

  int _int(dynamic value) => int.tryParse('$value') ?? 0;

  bool _include(Map<String, dynamic> info) {
    switch (widget.mode) {
      case 'page':
        final value = _int(info['page']);
        return value >= widget.pageFrom && value <= widget.pageTo;
      case 'juz':
        final value = _int(info['juz']);
        return value >= widget.juzFrom && value <= widget.juzTo;
      case 'hizb':
        final value = _int(info['hizb']);
        return value >= widget.hizbFrom && value <= widget.hizbTo;
      case 'rub':
        final value = _int(info['rub']);
        return value >= widget.rubFrom && value <= widget.rubTo;
      default:
        return widget.selectedSurahs.contains('${info['surah']}'.trim());
    }
  }

  Future<void> _loadAyahs() async {
    try {
      final raw = await rootBundle.loadString('assets/ayah_texts.json');
      final decoded = json.decode(raw) as Map<String, dynamic>;
      final items = <_ListeningAyah>[];
      for (final entry in decoded.entries) {
        final info = Map<String, dynamic>.from(entry.value as Map);
        if (!_include(info)) continue;
        items.add(
          _ListeningAyah(
            fileName: entry.key,
            text: '${info['text'] ?? ''}',
            surah: '${info['surah'] ?? ''}',
            ayah: _int(info['ayah']),
            page: _int(info['page']),
            juz: _int(info['juz']),
            hizb: _int(info['hizb']),
            rub: _int(info['rub']),
          ),
        );
      }
      items.sort((a, b) => a.fileName.compareTo(b.fileName));
      if (!mounted) return;
      setState(() {
        _ayahs = items;
        _loading = false;
        if (items.isEmpty) _error = 'لا توجد آيات ضمن النطاق المحدد.';
      });
      if (items.isNotEmpty && mounted) {
        if (kIsWeb) {
          await _prepareWebPlaylist();
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (mounted) _tryAutoStartWeb();
          });
        } else {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (mounted && !_playing) _playTaawudhThenCurrent();
          });
        }
      }
    } catch (error) {
      if (!mounted) return;
      setState(() {
        _loading = false;
        _error = 'تعذر تحميل بيانات الآيات: $error';
      });
    }
  }

  String _urlFor(String fileName) {
    final base = widget.reciterUrl.endsWith('/')
        ? widget.reciterUrl.substring(0, widget.reciterUrl.length - 1)
        : widget.reciterUrl;
    return '$base/$fileName';
  }

  Future<void> _prepareWebPlaylist() async {
    try {
      final sources = <ja.AudioSource>[
        ja.AudioSource.asset('assets/begin/001000.mp3'),
        ja.AudioSource.asset('assets/begin/001001.mp3'),
        for (final ayah in _ayahs)
          for (var repeat = 0; repeat < _webPlaylistRepeats; repeat++)
            ja.AudioSource.uri(Uri.parse(_urlFor(ayah.fileName))),
      ];
      await _webPlayer.setAudioSources(
        sources,
        initialIndex: 0,
        initialPosition: Duration.zero,
      );
      _taawudhPlayed = false;
      _bismillahPlayed = false;
      _webPlaylistReady = true;
    } catch (error) {
      _webPlaylistReady = false;
      if (mounted) {
        setState(() => _error = 'تعذر تجهيز قائمة التلاوة: $error');
      }
    }
  }

  int _webPlaylistIndexForAyah(int ayahIndex) {
    return 2 + (ayahIndex * _webPlaylistRepeats);
  }

  Future<void> _changeRepeatCount(int value) async {
    final newRepeatCount = value.clamp(1, _webPlaylistRepeats).toInt();
    if (!mounted) return;
    setState(() {
      _repeatCount = newRepeatCount;
      _repeatIteration = 0;
    });
    if (kIsWeb && _webPlaylistReady && _ayahs.isNotEmpty) {
      await _webPlayer.seek(
        Duration.zero,
        index: _webPlaylistIndexForAyah(_index),
      );
      await _webPlayer.play();
    }
  }

  Future<void> _tryAutoStartWeb() async {
    if (!_webPlaylistReady || !mounted) return;
    try {
      unawaited(
        _webPlayer.play().catchError((_) {
          _showTapToPlayMessage();
        }),
      );
      await Future<void>.delayed(const Duration(milliseconds: 700));
      if (!_webPlayer.playing) _showTapToPlayMessage();
    } catch (_) {
      _showTapToPlayMessage();
    }
  }

  bool _isPlaybackPermissionError(Object error) {
    final message = error.toString().toLowerCase();
    return message.contains('notallowederror') ||
        message.contains('not allowed by the user agent') ||
        message.contains('denied permission');
  }

  void _showTapToPlayMessage() {
    if (!mounted) return;
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        const SnackBar(
          content: Text(
            'على الآيفون اضغط زر التشغيل لبدء التلاوة',
            textAlign: TextAlign.center,
          ),
          duration: Duration(seconds: 4),
        ),
      );
  }

  void _resetAfterBlockedPlayback() {
    _playingTaawudh = false;
    _playingBismillah = false;
    _iosUnlockingAyah = false;
    _awaitingIosAyahTap = false;
    if (mounted) {
      setState(() {
        _playing = false;
        _paused = false;
        _position = Duration.zero;
        _duration = Duration.zero;
      });
    }
    _showTapToPlayMessage();
  }

  Future<void> _prepareInitialAudioForIos() async {
    try {
      final ayah = _current;
      if (ayah == null) return;
      await _player.setReleaseMode(ReleaseMode.stop);
      await _player.setVolume(1);
      await _player.setSource(UrlSource(_urlFor(ayah.fileName)));
      _initialAudioPrepared = true;
    } catch (_) {
      _initialAudioPrepared = false;
    }
    _showTapToPlayMessage();
  }

  Future<void> _playTaawudhThenCurrent() async {
    if (_taawudhPlayed) return _playBismillahThenCurrent();
    try {
      _playingTaawudh = true;
      if (mounted) {
        setState(() {
          _position = Duration.zero;
          _duration = Duration.zero;
          _playing = true;
          _paused = false;
        });
      }
      if (_initialAudioPrepared) {
        _initialAudioPrepared = false;
        _iosUnlockingAyah = true;
        final ayahUnlock = _player.resume();
        final introStart = _introPlayer.resume();
        await Future.wait([ayahUnlock, introStart]);
      } else {
        await _player.play(AssetSource('begin/001000.mp3'));
      }
    } catch (error) {
      if (_isPlaybackPermissionError(error)) {
        _resetAfterBlockedPlayback();
        return;
      }
      _playingTaawudh = false;
      _taawudhPlayed = true;
      await _playBismillahThenCurrent();
    }
  }

  Future<void> _handleIosIntroComplete() async {
    if (!_requiresInitialTap) return;
    if (_playingTaawudh) {
      _playingTaawudh = false;
      _taawudhPlayed = true;
      _playingBismillah = true;
      if (mounted) setState(() {});
      try {
        await _introPlayer.play(AssetSource('begin/001001.mp3'));
      } catch (error) {
        if (_isPlaybackPermissionError(error)) {
          _resetAfterBlockedPlayback();
        }
      }
      return;
    }
    if (_playingBismillah) {
      _playingBismillah = false;
      _bismillahPlayed = true;
      try {
        await _player.pause();
        await _player.seek(Duration.zero);
        await _player.setReleaseMode(ReleaseMode.stop);
        await _player.setVolume(1);
        _iosUnlockingAyah = false;
        _awaitingIosAyahTap = true;
        if (mounted) {
          setState(() {
            _position = Duration.zero;
            _playing = false;
            _paused = false;
          });
          ScaffoldMessenger.of(context)
            ..hideCurrentSnackBar()
            ..showSnackBar(
              const SnackBar(
                content: Text(
                  'اضغط زر التشغيل لبدء صوت الآيات',
                  textAlign: TextAlign.center,
                ),
                duration: Duration(seconds: 6),
              ),
            );
        }
      } catch (error) {
        if (_isPlaybackPermissionError(error)) {
          _resetAfterBlockedPlayback();
        }
      }
    }
  }

  Future<void> _playBismillahThenCurrent() async {
    if (_bismillahPlayed) return _playCurrent();
    try {
      _playingBismillah = true;
      if (mounted) {
        setState(() {
          _position = Duration.zero;
          _duration = Duration.zero;
          _playing = true;
          _paused = false;
        });
      }
      await _player.play(AssetSource('begin/001001.mp3'));
    } catch (error) {
      if (_isPlaybackPermissionError(error)) {
        _resetAfterBlockedPlayback();
        return;
      }
      _playingBismillah = false;
      _bismillahPlayed = true;
      await _playCurrent(stopFirst: false);
    }
  }

  double get _overallProgress {
    if (_ayahs.isEmpty) return 0;
    if (_playingTaawudh || _playingBismillah) return 0;
    final ayahProgress = _duration.inMilliseconds > 0
        ? (_position.inMilliseconds / _duration.inMilliseconds).clamp(0.0, 1.0)
        : 0.0;
    return ((_index + ayahProgress) / _ayahs.length)
        .clamp(0.0, 1.0)
        .toDouble();
  }

  String _displayText(_ListeningAyah ayah) {
    if (_playingTaawudh) return 'أَعُوذُ بِاللَّهِ مِنَ الشَّيْطَانِ الرَّجِيمِ';
    if (_playingBismillah) return 'بِسْمِ اللَّهِ الرَّحْمَنِ الرَّحِيمِ';
    return ayah.text.replaceFirst(RegExp(r'^\s*۞\s*'), '');
  }

  String _displayCaption(_ListeningAyah ayah) {
    if (_playingTaawudh) return 'الاستعاذة';
    if (_playingBismillah) return 'البسملة';
    return 'سورة ${ayah.surah} - الآية ${ayah.ayah}';
  }

  Future<void> _seekAcrossRecitation(double progress) async {
    if (_ayahs.isEmpty) return;
    _playingTaawudh = false;
    _playingBismillah = false;
    _taawudhPlayed = true;
    _bismillahPlayed = true;

    final scaled =
        (progress.clamp(0.0, 1.0) * _ayahs.length).toDouble();
    final targetIndex =
        scaled.floor().clamp(0, _ayahs.length - 1).toInt();
    final fraction = targetIndex == _ayahs.length - 1 && progress >= 1
        ? 1.0
        : (scaled - targetIndex).clamp(0.0, 1.0).toDouble();
    if (kIsWeb) {
      final playlistIndex = _webPlaylistIndexForAyah(targetIndex);
      await _webPlayer.seek(Duration.zero, index: playlistIndex);
      final duration = _webPlayer.duration;
      if (duration != null && duration.inMilliseconds > 0) {
        await _webPlayer.seek(
          Duration(milliseconds: (duration.inMilliseconds * fraction).round()),
          index: playlistIndex,
        );
      }
      await _webPlayer.play();
      return;
    }
    setState(() => _index = targetIndex);
    await _playCurrent();
    final duration = await _player.getDuration();
    if (duration != null && duration.inMilliseconds > 0) {
      await _player.seek(
        Duration(milliseconds: (duration.inMilliseconds * fraction).round()),
      );
    }
  }

  Future<void> _playCurrent({bool stopFirst = true}) async {
    final ayah = _current;
    if (ayah == null) return;
    try {
      if (stopFirst) await _player.stop();
      if (mounted) {
        setState(() {
          _position = Duration.zero;
          _duration = Duration.zero;
        });
      }
      await _player.play(UrlSource(_urlFor(ayah.fileName)));
      if (mounted) setState(() { _playing = true; _paused = false; });
    } catch (error) {
      if (_isPlaybackPermissionError(error)) {
        _resetAfterBlockedPlayback();
        return;
      }
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('تعذر تشغيل الآية: $error')),
        );
      }
    }
  }

  Future<void> _togglePlayback() async {
    if (kIsWeb) {
      if (!_webPlaylistReady) return;
      if (_webPlayer.playing) {
        await _webPlayer.pause();
      } else {
        if (_webPlayer.processingState == ja.ProcessingState.completed) {
          await _webPlayer.seek(Duration.zero, index: 0);
        }
        await _webPlayer.play();
      }
      return;
    }
    if (_requiresInitialTap && !_taawudhPlayed && !_bismillahPlayed) {
      _initialAudioPrepared = false;
      _taawudhPlayed = true;
      _bismillahPlayed = true;
      // Use exactly the same stop + load + play path that succeeds when the
      // user presses next/previous on Safari, while keeping the current ayah.
      return _playCurrent();
    }
    if (_awaitingIosAyahTap) {
      _awaitingIosAyahTap = false;
      try {
        await _player.resume();
        if (mounted) {
          setState(() {
            _playing = true;
            _paused = false;
          });
        }
      } catch (error) {
        _awaitingIosAyahTap = true;
        if (_isPlaybackPermissionError(error)) {
          _showTapToPlayMessage();
        }
      }
      return;
    }
    if (!_playing) {
      if (!_taawudhPlayed || !_bismillahPlayed) {
        return _playTaawudhThenCurrent();
      }
      return _playCurrent();
    }
    if (_paused) {
      await _player.resume();
    } else {
      await _player.pause();
    }
    if (mounted) setState(() => _paused = !_paused);
  }

  Future<void> _handleComplete() async {
    if (_requiresInitialTap && _iosUnlockingAyah) {
      // The first ayah is deliberately running muted to unlock Safari audio.
      // Its completion must not advance the visible recitation.
      return;
    }
    if (_playingTaawudh) {
      _playingTaawudh = false;
      _taawudhPlayed = true;
      await _playBismillahThenCurrent();
      return;
    }
    if (_playingBismillah) {
      _playingBismillah = false;
      _bismillahPlayed = true;
      await _playCurrent(stopFirst: false);
      return;
    }
    if (_repeatIteration + 1 < _repeatCount) {
      _repeatIteration++;
      await _playCurrent();
      return;
    }
    _repeatIteration = 0;
    await _next(autoPlay: true);
  }

  Future<void> _next({bool autoPlay = false}) async {
    if (_ayahs.isEmpty) return;
    if (kIsWeb) {
      if (_index < _ayahs.length - 1) {
        _repeatIteration = 0;
        await _webPlayer.seek(
          Duration.zero,
          index: _webPlaylistIndexForAyah(_index + 1),
        );
        await _webPlayer.play();
      }
      return;
    }
    if (_index >= _ayahs.length - 1) {
      await _player.stop();
      if (mounted) setState(() { _playing = false; _paused = false; });
      return;
    }
    _repeatIteration = 0;
    setState(() => _index++);
    if (autoPlay || _playing) await _playCurrent();
  }

  Future<void> _previous() async {
    if (_ayahs.isEmpty || _index == 0) return;
    if (kIsWeb) {
      if (_index > 0) {
        _repeatIteration = 0;
        await _webPlayer.seek(
          Duration.zero,
          index: _webPlaylistIndexForAyah(_index - 1),
        );
        await _webPlayer.play();
      }
      return;
    }
    _repeatIteration = 0;
    setState(() => _index--);
    if (_playing) await _playCurrent();
  }

  Widget _buildListeningAyahCard(_ListeningAyah ayah) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF1B5E20), Color(0xFF12451F)],
          begin: Alignment.topRight,
          end: Alignment.bottomLeft,
        ),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: const Color(0xFFD4AF37), width: 1.5),
      ),
      child: Stack(
        children: [
          Positioned.fill(
            child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(18),
                border: Border.all(color: const Color(0x55F1D77A)),
              ),
            ),
          ),
          Positioned.fill(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
              child: Center(
                child: SingleChildScrollView(
                  child: Text(
                    _displayText(ayah),
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      color: Colors.white,
                      fontFamily: 'amiriQuran',
                      fontSize: 32,
                      height: 1.9,
                      fontWeight: FontWeight.normal,
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSurahProgressCard(_ListeningAyah ayah) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(12, 9, 12, 8),
      decoration: BoxDecoration(
        color: const Color(0xFF123F22),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: const Color(0x66D4AF37)),
        boxShadow: const [
          BoxShadow(
            color: Color(0x22000000),
            blurRadius: 10,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.09),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Text(
              _displayCaption(ayah),
              textAlign: TextAlign.center,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
          const SizedBox(height: 6),
          SizedBox(
            height: 20,
            child: Directionality(
              textDirection: TextDirection.rtl,
              child: SliderTheme(
                data: SliderTheme.of(context).copyWith(
                  trackHeight: 6,
                  activeTrackColor: const Color(0xFF81C784),
                  inactiveTrackColor: Colors.white24,
                  thumbColor: const Color(0xFFA5D6A7),
                  overlayColor: const Color(0x3381C784),
                  thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 7),
                  overlayShape: const RoundSliderOverlayShape(overlayRadius: 15),
                ),
                child: Slider(
                  min: 0,
                  max: 1,
                  value: _draggingProgress ? _dragProgress : _overallProgress,
                  onChangeStart: (value) {
                    setState(() {
                      _draggingProgress = true;
                      _dragProgress = value;
                    });
                  },
                  onChanged: (value) => setState(() => _dragProgress = value),
                  onChangeEnd: (value) {
                    setState(() {
                      _draggingProgress = false;
                      _dragProgress = value;
                    });
                    _seekAcrossRecitation(value);
                  },
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final ayah = _current;
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('التلاوة والاستماع'),
          centerTitle: true,
          backgroundColor: const Color(0xFF166534),
          foregroundColor: Colors.white,
        ),
        body: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [Color(0xFF2E7D32), Color(0xFFEFFDF5)],
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
            ),
          ),
          child: SafeArea(
            child: _loading
                ? const Center(child: CircularProgressIndicator(color: Colors.white))
                : _error != null
                    ? Center(child: Text(_error!, textAlign: TextAlign.center))
                    : Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          children: [
                            Image.asset(
                              'assets/logo.png',
                              height: 72,
                              fit: BoxFit.contain,
                              errorBuilder: (_, __, ___) => const SizedBox.shrink(),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              widget.reciterName,
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 18,
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                            const SizedBox(height: 14),
                            Expanded(
                              child: _buildListeningAyahCard(ayah!),
                            ),
                            const SizedBox(height: 10),
                            _buildSurahProgressCard(ayah!),
                            const SizedBox(height: 10),
                            Container(
                              padding: const EdgeInsets.symmetric(vertical: 8),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                children: [
                                  IconButton(
                                    tooltip: 'السابق',
                                    onPressed: _index == 0 ? null : _previous,
                                    icon: const Icon(Icons.skip_previous_rounded),
                                  ),
                                  FilledButton(
                                    onPressed: _togglePlayback,
                                    style: FilledButton.styleFrom(
                                      backgroundColor: const Color(0xFF15803D),
                                      shape: const CircleBorder(),
                                      padding: const EdgeInsets.all(18),
                                    ),
                                    child: Icon(
                                      _playing && !_paused
                                          ? Icons.pause_rounded
                                          : Icons.play_arrow_rounded,
                                      size: 32,
                                    ),
                                  ),
                                  IconButton(
                                    tooltip: 'التالي',
                                    onPressed: _index == _ayahs.length - 1 ? null : _next,
                                    icon: const Icon(Icons.skip_next_rounded),
                                  ),
                                  PopupMenuButton<int>(
                                    tooltip: 'تكرار الآية',
                                    initialValue: _repeatCount,
                                    onSelected: _changeRepeatCount,
                                    itemBuilder: (_) => const [
                                      PopupMenuItem(value: 1, child: Text('مرة واحدة')),
                                      PopupMenuItem(value: 2, child: Text('مرتان')),
                                      PopupMenuItem(value: 3, child: Text('٣ مرات')),
                                      PopupMenuItem(value: 5, child: Text('٥ مرات')),
                                    ],
                                    child: Padding(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 10,
                                        vertical: 8,
                                      ),
                                      child: Column(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          const Icon(Icons.repeat_rounded),
                                          Text(
                                            '×$_repeatCount',
                                            style: const TextStyle(
                                              fontSize: 12,
                                              fontWeight: FontWeight.w800,
                                            ),
                                          ),
                                        ],
                                      ),
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
      ),
    );
  }
}
