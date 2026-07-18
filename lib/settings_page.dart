


import 'dart:convert';
import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_spinbox/flutter_spinbox.dart';
import 'package:url_launcher/url_launcher.dart';

import 'main.dart';            // PlayPage
import 'competition_page.dart';
import 'listening_page.dart';
import 'l10n_simple.dart';

/// ---------------------------------------------------------------------------
/// Reciter model
/// ---------------------------------------------------------------------------
class Reciter {
  final String key;      // EveryAyah folder name
  final String nameEn;   // English display name
  final String nameAr;   // Arabic  display name

  const Reciter({
    required this.key,
    required this.nameEn,
    required this.nameAr,
  });

  String get url => 'https://everyayah.com/data/$key';
  String localizedName(String lang) => lang == 'ar' ? nameAr : nameEn;

  Reciter copyWith({String? nameEn, String? nameAr}) => Reciter(
        key: key,
        nameEn: nameEn ?? this.nameEn,
        nameAr: nameAr ?? this.nameAr,
      );
}

/// ---------------------------------------------------------------------------
/// Optional Arabic overrides for some folder keys (edit as you like)
/// (Top-level `final` to avoid the const/static build error)
/// ---------------------------------------------------------------------------
final Map<String, String> kArabicNameOverrides = {
  'Muhammad_Ayyoub_128kbps': 'محمد أيوب',
  'Muhammad_Jibreel_64kbps': 'محمد جبريل',
  'Abdul_Basit_Murattal_64kbps': 'عبد الباسط (مرتل)',
  'Abdul_Basit_Mujawwad_128kbps': 'عبد الباسط (مجود)',
  'MisharyRashidAlafasy_64kbps': 'مشاري راشد العفاسي',
  'Husary_128kbps': 'محمود خليل الحصري',
  'Abdurrahmaan_As-Sudais_192kbps': 'عبدالرحمن السديس',
};

/// ---------------------------------------------------------------------------
/// Built-in fallback reciters (used when JSON asset missing)
/// ---------------------------------------------------------------------------
const List<Reciter> kFallbackReciters = [
  Reciter(
    key: 'Abu_Bakr_Ash-Shaatree_128kbps',
    nameEn: 'Abu Bakr Al-Shatri',
    nameAr: 'أبو بكر الشاطري',
  ),
  Reciter(
    key: 'Husary_Muallim_128kbps',
    nameEn: 'Al-Husary (Teaching)',
    nameAr: 'الحصري (تعليمي)',
  ),
  Reciter(
    key: 'Minshawy_Mujawwad_192kbps',
    nameEn: 'Minshawy (Mujawwad)',
    nameAr: 'المنشاوي (مجود)',
  ),
  Reciter(
    key: 'Minshawy_Murattal_128kbps',
    nameEn: 'Minshawy (Murattal)',
    nameAr: 'المنشاوي (مرتل)',
  ),
  Reciter(
    key: 'Ghamadi_40kbps',
    nameEn: 'Saad Al-Ghamdi',
    nameAr: 'سعد الغامدي',
  ),
  Reciter(
    key: 'Saood_ash-Shuraym_128kbps',
    nameEn: 'Saood ash-Shuraym',
    nameAr: 'سعود الشريم',
  ),
  Reciter(
    key: 'Sahl_Yassin_128kbps',
    nameEn: 'Sahl Yaseen',
    nameAr: 'سهل ياسين',
  ),
  Reciter(
    key: 'Abdul_Basit_Mujawwad_128kbps',
    nameEn: 'Abdul Basit (Mujawwad)',
    nameAr: 'عبد الباسط (مجود)',
  ),
  Reciter(
    key: 'Abdul_Basit_Murattal_64kbps',
    nameEn: 'Abdul Basit (Murattal)',
    nameAr: 'عبد الباسط (مرتل)',
  ),
  Reciter(
    key: 'Abdurrahmaan_As-Sudais_192kbps',
    nameEn: 'Abdurrahmaan As-Sudais',
    nameAr: 'عبد الرحمن السديس',
  ),
  Reciter(
    key: 'Hudhaify_64kbps',
    nameEn: 'Ali Al-Hudhaify',
    nameAr: 'علي الحذيفي',
  ),
  Reciter(
    key: 'Ali_Jaber_64kbps',
    nameEn: 'Ali Jaber',
    nameAr: 'علي جابر',
  ),
  Reciter(
    key: 'Fares_Abbad_64kbps',
    nameEn: 'Fares Abbad',
    nameAr: 'فارس عباد',
  ),
  Reciter(
    key: 'Muhammad_Ayyoub_128kbps',
    nameEn: 'Muhammad Ayyoub',
    nameAr: 'محمد أيوب',
  ),
  Reciter(
    key: 'Muhammad_Jibreel_64kbps',
    nameEn: 'Muhammad Jibreel',
    nameAr: 'محمد جبريل',
  ),
  Reciter(
    key: 'Husary_128kbps',
    nameEn: 'Mahmoud Khalil Al-Husary',
    nameAr: 'محمود خليل الحصري',
  ),
  Reciter(
    key: 'Alafasy_128kbps',
    nameEn: 'Mishary Rashid Alafasy',
    nameAr: 'مشاري راشد العفاسي',
  ),
  Reciter(
    key: 'Nasser_Alqatami_128kbps',
    nameEn: 'Nasser Al-Qatami',
    nameAr: 'ناصر القطامي',
  ),
  Reciter(
    key: 'Hani_Rifai_64kbps',
    nameEn: 'Hani Ar-Rifai',
    nameAr: 'هاني الرفاعي',
  ),
  Reciter(
    key: 'Yasser_Ad-Dussary_128kbps',
    nameEn: 'Yasser Al-Dossari',
    nameAr: 'ياسر الدوسري',
  ),
];

/// ---------------------------------------------------------------------------
/// Settings page
/// ---------------------------------------------------------------------------
class SettingsPage extends StatefulWidget {
  const SettingsPage({Key? key}) : super(key: key);

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  String _usageMode = 'quiz';
  // Arabic→English names for Surahs (for EN UI)
  static const Map<String, String> kSurahNameEn = {
    "الفاتحة": "Al Fatihah",
    "البقرة": "Al Baqara",
    "آل عمران": "Al Imran",
    "النساء": "An Nisa",
    "المائدة": "Al Maida",
    "الأنعام": "Al Anam",
    "الأعراف": "Al Araf",
    "الأنفال": "Al Anfal",
    "التوبة": "At Tauba / Baraat",
    "يونس": "Yunus",
    "هود": "Hud",
    "يوسف": "Yusuf",
    "الرعد": "Ar Rad",
    "ابراهيم": "Ibrahim",
    "الحجر": "Al Hijr",
    "النحل": "An Nahl",
    "الإسراء": "Al Isra",
    "الكهف": "Al Kahf",
    "مريم": "Maryam",
    "طه": "Ta Ha",
    "الأنبياء": "Al Anbiya",
    "الحج": "Al Hajj",
    "المؤمنون": "Al Muminun",
    "النور": "An Nur",
    "الفرقان": "Al Furqan",
    "الشعراء": "Ash Shuara",
    "النمل": "An Naml",
    "القصص": "Al Qasas",
    "العنكبوت": "Al Ankabut",
    "الروم": "Ar Rum",
    "لقمان": "Luqman",
    "السجدة": "As Sajda",
    "الأحزاب": "Al Ahzab",
    "سبإ": "Saba",
    "فاطر": "Fatir",
    "يس": "Ya Sin",
    "الصافات": "As Saffat",
    "ص": "Sad",
    "الزمر": "Az Zumar",
    "غافر": "Ghafir",
    "فصلت": "Fussilat",
    "الشورى": "Ash Shura",
    "الزخرف": "Az Zukhruf",
    "الدخان": "Ad Dukhan",
    "الجاثية": "Al Jathiyah",
    "الأحقاف": "Al Ahqaf",
    "محمد": "Muhammad",
    "الفتح": "Al Fath",
    "الحجرات": "Al Hujurat",
    "ق": "Qaf",
    "الذاريات": "Adh Dhariyat",
    "الطور": "At Tur",
    "النجم": "An Najm",
    "القمر": "Al Qamar",
    "الرحمن": "Ar Rahman",
    "الواقعة": "Al Waqia",
    "الحديد": "Al Hadid",
    "المجادلة": "Al Mujadila",
    "الحشر": "Al Hashr",
    "الممتحنة": "Al Mumtahana",
    "الصف": "As Saff",
    "الجمعة": "Al Jumuah",
    "المنافقون": "Al Munafiqun",
    "التغابن": "At Taghabun",
    "الطلاق": "At Talaq",
    "التحريم": "At Tahrim",
    "الملك": "Al Mulk",
    "القلم": "Al Qalam",
    "الحاقة": "Al Haqqah",
    "المعارج": "Al Maarij",
    "نوح": "Nuh",
    "الجن": "Al Jinn",
    "المزمل": "Al Muzzammil",
    "المدثر": "Al Muddathir",
    "القيامة": "Al Qiyamah",
    "الانسان": "Al Insan",
    "المرسلات": "Al Mursalat",
    "النبإ": "An Naba",
    "النازعات": "An Naziat",
    "عبس": "Abasa",
    "التكوير": "At Takwir",
    "الإنفطار": "Al Infitar",
    "المطففين": "Al Mutaffifin",
    "الإنشقاق": "Al Inshiqaq",
    "البروج": "Al Buruj",
    "الطارق": "At Tariq",
    "الأعلى": "Al Ala",
    "الغاشية": "Al Ghashiyah",
    "الفجر": "Al Fajr",
    "البلد": "Al Balad",
    "الشمس": "Ash Shams",
    "الليل": "Al Layl",
    "الضحى": "Ad Duhaa",
    "الشرح": "Ash Sharh",
    "التين": "At Tin",
    "العلق": "Al Alaq",
    "القدر": "Al Qadr",
    "البينة": "Al Bayyinah",
    "الزلزلة": "Az Zalzalah",
    "العاديات": "Al Adiyat",
    "القارعة": "Al Qariah",
    "التكاثر": "At Takathur",
    "العصر": "Al Asr",
    "الهمزة": "Al Humazah",
    "الفيل": "Al Fil",
    "قريش": "Quraish",
    "الماعون": "Al Maun",
    "الكوثر": "Al Kawthar",
    "الكافرون": "Al Kafirun",
    "النصر": "An Nasr",
    "المسد": "Al Masad",
    "الإخلاص": "Al Ikhlas",
    "الفلق": "Al Falaq",
    "الناس": "An Nas",
  };

  // -- UI State --
  int _repeatCount = 5;
  int _ayahsAfter = 5;
  int _recitationDelay = 1;

  String _testMode = 'surah'; // surah, page, juz, hizb, rub
  int _selectedPageFrom = 1;
  int _selectedPageTo = 604;
  int _selectedJuzFrom = 1;
  int _selectedJuzTo = 30;
  int _selectedHizbFrom = 1;
  int _selectedHizbTo = 60;
  int _selectedRubFrom = 1;
  int _selectedRubTo = 240;

  List<String> _selectedSurahs = [];
  List<String> _allSurahs = [];
  String _searchQuery = "";

  // Reciters
  List<Reciter> _reciters = kFallbackReciters;
  Reciter _selectedReciter = kFallbackReciters.first;

  final TextEditingController _feedbackController = TextEditingController();

  String get _lang {
    try {
      return LangScope.of(context).lang;
    } catch (_) {
      return 'ar';
    }
  }
  String t(String k) => L10nSimple.t(_lang, k);
  String _displayName(String ar) => _lang == 'en' ? (kSurahNameEn[ar] ?? ar) : ar;

  String _surahHeaderText() =>
      _selectedSurahs.isEmpty
          ? "📖 ${t('pickSurahs')}"
          : "📖 ${t('selectedSurahs')} (${L10nSimple.digits(_lang, _selectedSurahs.length)})";

  String _modeLabel(String mode) {
    final isAr = _lang == 'ar';
    switch (mode) {
      case 'page':
        return isAr ? 'الصفحات' : 'Pages';
      case 'juz':
        return isAr ? 'الجزء' : 'Juz';
      case 'hizb':
        return isAr ? 'الحزب' : 'Hizb';
      case 'rub':
        return isAr ? 'الربع' : 'Quarter';
      case 'similarities':
        return isAr ? 'اختبار المتشابهات' : 'Similarities test';
      default:
        return isAr ? 'السور' : 'Surahs';
    }
  }

  String _rangeText(int from, int to) {
    final a = L10nSimple.digits(_lang, from);
    final b = L10nSimple.digits(_lang, to);
    return from == to ? a : '$a - $b';
  }

  String _modeSummaryText() {
    final isAr = _lang == 'ar';
    final listening = _usageMode == 'listening';
    switch (_testMode) {
      case 'page':
        return isAr
            ? '📄 ${listening ? 'استماع الصفحات' : 'اختبار الصفحات'} ${_rangeText(_selectedPageFrom, _selectedPageTo)}'
            : '📄 Pages ${_rangeText(_selectedPageFrom, _selectedPageTo)} ${listening ? 'listening' : 'test'}';
      case 'juz':
        return isAr
            ? '📖 ${listening ? 'استماع الجزء' : 'اختبار الجزء'} ${_rangeText(_selectedJuzFrom, _selectedJuzTo)}'
            : '📖 Juz ${_rangeText(_selectedJuzFrom, _selectedJuzTo)} ${listening ? 'listening' : 'test'}';
      case 'hizb':
        return isAr
            ? '📚 ${listening ? 'استماع الحزب' : 'اختبار الحزب'} ${_rangeText(_selectedHizbFrom, _selectedHizbTo)}'
            : '📚 Hizb ${_rangeText(_selectedHizbFrom, _selectedHizbTo)} ${listening ? 'listening' : 'test'}';
      case 'rub':
        return isAr
            ? '🕌 ${listening ? 'استماع الربع' : 'اختبار الربع'} ${_rangeText(_selectedRubFrom, _selectedRubTo)}'
            : '🕌 Quarter ${_rangeText(_selectedRubFrom, _selectedRubTo)} ${listening ? 'listening' : 'test'}';
      default:
        return _surahHeaderText();
    }
  }

  /// ===== Arabic-aware sorting helpers =====
  static final RegExp _arabicDiacritics =
      RegExp(r'[\u064B-\u065F\u0670\u06D6-\u06ED]');

  String _arSortKey(String s) {
    var t = s.replaceAll(_arabicDiacritics, '');
    t = t
        .replaceAll('أ', 'ا')
        .replaceAll('إ', 'ا')
        .replaceAll('آ', 'ا')
        .replaceAll('ى', 'ي')
        .replaceAll('ئ', 'ي')
        .replaceAll('ؤ', 'و')
        .replaceAll('ة', 'ه');
    return t;
  }

  int _compareReciters(Reciter a, Reciter b) {
    if (_lang == 'ar') {
      return _arSortKey(a.nameAr).compareTo(_arSortKey(b.nameAr));
    }
    return a.nameEn.toLowerCase().compareTo(b.nameEn.toLowerCase());
  }

  @override
  void initState() {
    super.initState();
    _loadSurahs();
    _loadReciters();
  }

  /// Load reciters from JSON (if present), merge with fallback, apply Arabic overrides
  Future<void> _loadReciters() async {
    List<Reciter> loaded = [];
    try {
      final jsonString = await rootBundle.loadString('assets/everyayah_reciters.json');
      final List<dynamic> arr = json.decode(jsonString) as List<dynamic>;
      loaded = arr.map((e) {
        final m = e as Map<String, dynamic>;
        final key = (m['key'] ?? '').toString().trim();
        final en = (m['name_en'] ?? m['name'] ?? key).toString().trim();
        final arFromJson = (m['name_ar'] ?? '').toString().trim();
        final arOverride = kArabicNameOverrides[key];
        final ar = (arOverride ?? (arFromJson.isNotEmpty ? arFromJson : en)).trim();
        return Reciter(key: key, nameEn: en, nameAr: ar);
      }).toList();
    } catch (_) {
      // asset missing or parsing failed -> use fallback only
    }

    // Merge: start with fallback then override by loaded (JSON preferred)
    final Map<String, Reciter> map = {
      for (final r in kFallbackReciters) r.key: r,
    };
    for (final r in loaded) {
      // apply overrides again to be safe
      final ar = kArabicNameOverrides[r.key] ?? r.nameAr;
      map[r.key] = r.copyWith(nameAr: ar);
    }

    final merged = map.values.toList()..sort(_compareReciters);

    setState(() {
      _reciters = merged;
      // Keep selection if possible
      final keep = _reciters.firstWhere(
        (r) => r.key == _selectedReciter.key,
        orElse: () => _reciters.first,
      );
      _selectedReciter = keep;
    });
  }

  @override
  void dispose() {
    _feedbackController.dispose();
    super.dispose();
  }

  Future<void> _loadSurahs() async {
    final jsonString = await rootBundle.loadString('assets/ayah_texts.json');
    final Map<String, dynamic> jsonData = json.decode(jsonString);

    // Canonical Quran order
    final List<String> quranOrder = [
      "الفاتحة", "البقرة", "آل عمران", "النساء", "المائدة", "الأنعام", "الأعراف",
      "الأنفال", "التوبة", "يونس", "هود", "يوسف", "الرعد", "ابراهيم", "الحجر", "النحل",
      "الإسراء", "الكهف", "مريم", "طه", "الأنبياء", "الحج", "المؤمنون", "النور", "الفرقان",
      "الشعراء", "النمل", "القصص", "العنكبوت", "الروم", "لقمان", "السجدة", "الأحزاب",
      "سبإ", "فاطر", "يس", "الصافات", "ص", "الزمر", "غافر", "فصلت", "الشورى", "الزخرف",
      "الدخان", "الجاثية", "الأحقاف", "محمد", "الفتح", "الحجرات", "ق", "الذاريات",
      "الطور", "النجم", "القمر", "الرحمن", "الواقعة", "الحديد", "المجادلة", "الحشر",
      "الممتحنة", "الصف", "الجمعة", "المنافقون", "التغابن", "الطلاق", "التحريم", "الملك",
      "القلم", "الحاقة", "المعارج", "نوح", "الجن", "المزمل", "المدثر", "القيامة",
      "الانسان", "المرسلات", "النبإ", "النازعات", "عبس", "التكوير", "الإنفطار",
      "المطففين", "الإنشقاق", "البروج", "الطارق", "الأعلى", "الغاشية", "الفجر",
      "البلد", "الشمس", "الليل", "الضحى", "الشرح", "التين", "العلق", "القدر", "البينة",
      "الزلزلة", "العاديات", "القارعة", "التكاثر", "العصر", "الهمزة", "الفيل", "قريش",
      "الماعون", "الكوثر", "الكافرون", "النصر", "المسد", "الإخلاص", "الفلق", "الناس"
    ];

    final Set<String> surahNames =
        jsonData.values.map((e) => e['surah'].toString().trim()).toSet();

    final ordered = quranOrder.where((name) => surahNames.contains(name)).toList();

    setState(() {
      _allSurahs = ordered;
      _selectedSurahs = List.from(ordered);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      bottomNavigationBar: _buildStartBar(context),
      body: Directionality(
        textDirection: L10nSimple.textDir(_lang),
        child: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [Color(0xFF2E7D32), Color(0xFFEFFDF5)],
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
            ),
          ),
          child: SafeArea(
            child: SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 170),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const SizedBox(height: 8),

                  // Language switch
                  Align(
                    alignment: AlignmentDirectional.topEnd,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.black.withOpacity(0.08),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: DropdownButtonHideUnderline(
                        child: DropdownButton<String>(
                          value: _lang,
                          icon: const Icon(Icons.language),
                          onChanged: (v) {
                            final scope = LangScope.of(context);
                            scope.onChange?.call(v ?? 'ar');
                            setState(() {
                              // resort reciters when language changes
                              _reciters.sort(_compareReciters);
                            });
                          },
                          items: const [
                            DropdownMenuItem(value: 'ar', child: Text('العربية')),
                            DropdownMenuItem(value: 'en', child: Text('English')),
                          ],
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 12),

                  _buildUsageModeSelector(),

                  const SizedBox(height: 12),

                  _buildReciterCard(),

                  const SizedBox(height: 12),

                  _buildTestModeSelector(),
                  const SizedBox(height: 12),

                  if (_testMode != 'surah') ...[
                    _buildModeSummaryCard(),
                    const SizedBox(height: 12),
                  ],

                  if (_testMode == 'page') ...[
                    _buildRangeInput(
                      fromLabel: _lang == 'ar' ? 'من صفحة' : 'From page',
                      toLabel: _lang == 'ar' ? 'إلى صفحة' : 'To page',
                      fromValue: _selectedPageFrom,
                      toValue: _selectedPageTo,
                      min: 1,
                      max: 604,
                      onFromChanged: (val) => setState(() {
                        _selectedPageFrom = val;
                        if (_selectedPageTo < val) _selectedPageTo = val;
                      }),
                      onToChanged: (val) => setState(() {
                        _selectedPageTo = val;
                        if (_selectedPageFrom > val) _selectedPageFrom = val;
                      }),
                    ),
                    const SizedBox(height: 12),
                  ],

                  if (_testMode == 'juz') ...[
                    _buildRangeInput(
                      fromLabel: _lang == 'ar' ? 'من جزء' : 'From juz',
                      toLabel: _lang == 'ar' ? 'إلى جزء' : 'To juz',
                      fromValue: _selectedJuzFrom,
                      toValue: _selectedJuzTo,
                      min: 1,
                      max: 30,
                      onFromChanged: (val) => setState(() {
                        _selectedJuzFrom = val;
                        if (_selectedJuzTo < val) _selectedJuzTo = val;
                      }),
                      onToChanged: (val) => setState(() {
                        _selectedJuzTo = val;
                        if (_selectedJuzFrom > val) _selectedJuzFrom = val;
                      }),
                    ),
                    const SizedBox(height: 12),
                  ],

                  if (_testMode == 'hizb') ...[
                    _buildRangeInput(
                      fromLabel: _lang == 'ar' ? 'من حزب' : 'From hizb',
                      toLabel: _lang == 'ar' ? 'إلى حزب' : 'To hizb',
                      fromValue: _selectedHizbFrom,
                      toValue: _selectedHizbTo,
                      min: 1,
                      max: 60,
                      onFromChanged: (val) => setState(() {
                        _selectedHizbFrom = val;
                        if (_selectedHizbTo < val) _selectedHizbTo = val;
                      }),
                      onToChanged: (val) => setState(() {
                        _selectedHizbTo = val;
                        if (_selectedHizbFrom > val) _selectedHizbFrom = val;
                      }),
                    ),
                    const SizedBox(height: 12),
                  ],

                  if (_testMode == 'rub') ...[
                    _buildRangeInput(
                      fromLabel: _lang == 'ar' ? 'من ربع' : 'From quarter',
                      toLabel: _lang == 'ar' ? 'إلى ربع' : 'To quarter',
                      fromValue: _selectedRubFrom,
                      toValue: _selectedRubTo,
                      min: 1,
                      max: 240,
                      onFromChanged: (val) => setState(() {
                        _selectedRubFrom = val;
                        if (_selectedRubTo < val) _selectedRubTo = val;
                      }),
                      onToChanged: (val) => setState(() {
                        _selectedRubTo = val;
                        if (_selectedRubFrom > val) _selectedRubFrom = val;
                      }),
                    ),
                    const SizedBox(height: 12),
                  ],

                  // Surah selector button
                  if (_testMode == 'surah')
                    ElevatedButton.icon(
                      icon: const Icon(Icons.menu_book),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF15803D),
                        foregroundColor: Colors.white,
                        elevation: 3,
                        shadowColor: const Color(0x3315803D),
                        padding: const EdgeInsets.symmetric(vertical: 17),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                      ),
                      onPressed: _openSurahSelector,
                      label: Text(
                        _surahHeaderText(),
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w800,
                          color: Colors.white,
                        ),
                      ),
                    ),

                  const SizedBox(height: 20),

                  if (_usageMode == 'quiz') ...[
                    _buildQuizSettingsCard(),
                    const SizedBox(height: 12),
                  ],
                  _buildCompetitionsCard(),
                  const SizedBox(height: 12),
                  _buildFeedbackCard(),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildReciterCard() {
    final isAr = _lang == 'ar';
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.96),
        borderRadius: BorderRadius.circular(16),
        boxShadow: const [
          BoxShadow(color: Color(0x18000000), blurRadius: 14, offset: Offset(0, 5)),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: const Color(0xFFEFFDF5),
              borderRadius: BorderRadius.circular(14),
            ),
            child: const Icon(Icons.mic_none, color: Color(0xFF15803D), size: 28),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment:
                  isAr ? CrossAxisAlignment.end : CrossAxisAlignment.start,
              children: [
                Text(
                  isAr ? 'اختر القارئ' : 'Choose reciter',
                  textAlign: isAr ? TextAlign.right : TextAlign.left,
                  style: const TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.w800,
                    color: Color(0xFF166534),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  isAr
                      ? (_usageMode == 'listening'
                          ? 'يمكنك تغيير صوت القارئ قبل الاستماع'
                          : 'يمكنك تغيير صوت التلاوة قبل الاختبار')
                      : (_usageMode == 'listening'
                          ? 'Choose the reciter before listening'
                          : 'Choose the recitation voice before the test'),
                  textAlign: isAr ? TextAlign.right : TextAlign.left,
                  style: const TextStyle(fontSize: 13, color: Color(0xFF6B7280)),
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            flex: 2,
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: _openReciterPicker,
                borderRadius: BorderRadius.circular(14),
                child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 13),
                decoration: BoxDecoration(
                  color: const Color(0xFFF8FAFC),
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: const Color(0xFFD1D5DB)),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.keyboard_arrow_down, color: Color(0xFF374151)),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        _selectedReciter.localizedName(_lang),
                        overflow: TextOverflow.ellipsis,
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          fontSize: 17,
                          fontWeight: FontWeight.w700,
                          color: Color(0xFF111827),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    const Icon(Icons.record_voice_over, color: Color(0xFF15803D)),
                  ],
                ),
              ),
            ),
          ),
          ),
        ],
      ),
    );
  }

  Widget _buildUsageModeSelector() {
    final isListening = _usageMode == 'listening';
    return Container(
      padding: const EdgeInsets.all(6),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.96),
        borderRadius: BorderRadius.circular(18),
        boxShadow: const [
          BoxShadow(color: Color(0x18000000), blurRadius: 12, offset: Offset(0, 4)),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: _usageModeButton(
              selected: !isListening,
              icon: Icons.quiz_rounded,
              label: _lang == 'ar' ? 'الاختبار' : 'Quiz',
              onTap: () => setState(() => _usageMode = 'quiz'),
            ),
          ),
          const SizedBox(width: 6),
          Expanded(
            child: _usageModeButton(
              selected: isListening,
              icon: Icons.headphones_rounded,
              label: _lang == 'ar' ? 'التلاوة والاستماع' : 'Recitation',
              onTap: () => setState(() => _usageMode = 'listening'),
            ),
          ),
        ],
      ),
    );
  }

  Widget _usageModeButton({
    required bool selected,
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return Material(
      color: selected ? const Color(0xFF15803D) : Colors.transparent,
      borderRadius: BorderRadius.circular(14),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(14),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 13),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, color: selected ? Colors.white : const Color(0xFF166534)),
              const SizedBox(width: 7),
              Flexible(
                child: Text(
                  label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: selected ? Colors.white : const Color(0xFF166534),
                    fontSize: 16,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  IconData _modeIcon(String mode) {
    switch (mode) {
      case 'page':
        return Icons.description_outlined;
      case 'juz':
        return Icons.mosque_outlined;
      case 'hizb':
        return Icons.menu_book_outlined;
      case 'rub':
        return Icons.bookmark_border;
      case 'similarities':
        return Icons.compare_arrows_rounded;
      default:
        return Icons.auto_stories_outlined;
    }
  }

  String _modeSubtitle(String mode) {
    final isAr = _lang == 'ar';
    switch (mode) {
      case 'page':
        return isAr ? 'من صفحة إلى صفحة' : 'From page to page';
      case 'juz':
        return isAr ? 'من جزء إلى جزء' : 'From juz to juz';
      case 'hizb':
        return isAr ? 'من حزب إلى حزب' : 'From hizb to hizb';
      case 'rub':
        return isAr ? 'من ربع إلى ربع' : 'From quarter to quarter';
      case 'similarities':
        return isAr ? 'قيد العمل • قريبًا' : 'In development • Coming soon';
      default:
        return isAr ? 'اختر سور محددة' : 'Choose specific surahs';
    }
  }

  Color _modeColor(String mode) {
    switch (mode) {
      case 'page':
        return const Color(0xFF7C3AED);
      case 'juz':
        return const Color(0xFFF59E0B);
      case 'hizb':
        return const Color(0xFF2563EB);
      case 'rub':
        return const Color(0xFF0D9488);
      case 'similarities':
        return const Color(0xFFB7791F);
      default:
        return const Color(0xFF16A34A);
    }
  }

  Widget _buildTestModeSelector() {
    final options = [
      'surah',
      'page',
      'juz',
      'hizb',
      'rub',
      if (_usageMode != 'listening') 'similarities',
    ];
    final isAr = _lang == 'ar';

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.96),
        borderRadius: BorderRadius.circular(16),
        boxShadow: const [
          BoxShadow(color: Color(0x18000000), blurRadius: 14, offset: Offset(0, 5)),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            textDirection: isAr ? TextDirection.rtl : TextDirection.ltr,
            children: [
              const Icon(Icons.tune, color: Color(0xFF15803D)),
              const SizedBox(width: 8),
              Text(
                isAr
                    ? (_usageMode == 'listening'
                        ? 'نطاق التلاوة والاستماع'
                        : 'نوع الاختبار')
                    : (_usageMode == 'listening'
                        ? 'Listening range'
                        : 'Test type'),
                style: const TextStyle(
                  fontSize: 19,
                  fontWeight: FontWeight.w800,
                  color: Color(0xFF166534),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          LayoutBuilder(
            builder: (context, constraints) {
              final wide = constraints.maxWidth > 760;
              final veryNarrow = constraints.maxWidth < 430;
              final itemWidth = wide
                  ? (constraints.maxWidth - (12 * (options.length - 1))) /
                      options.length
                  : (constraints.maxWidth - 12) / 2;

              return Wrap(
                spacing: 12,
                runSpacing: 12,
                children: options.map((mode) {
                  final selected = _testMode == mode;
                  final color = _modeColor(mode);
                  final underDevelopment = mode == 'similarities';

                  return SizedBox(
                    width: itemWidth,
                    child: Material(
                      color: Colors.transparent,
                      child: InkWell(
                        onTap: underDevelopment
                            ? () {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text(
                                      isAr
                                          ? 'اختبار المتشابهات قيد العمل وسيُضاف قريبًا بإذن الله.'
                                          : 'The similarities test is in development and will be available soon.',
                                      textAlign: TextAlign.center,
                                    ),
                                  ),
                                );
                              }
                            : () => setState(() => _testMode = mode),
                        borderRadius: BorderRadius.circular(16),
                        child: AnimatedContainer(
                        duration: const Duration(milliseconds: 180),
                        padding: EdgeInsets.symmetric(
                          horizontal: veryNarrow ? 8 : 10,
                          vertical: veryNarrow ? 10 : 14,
                        ),
                        decoration: BoxDecoration(
                          color: selected ? color.withOpacity(0.08) : Colors.white,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(
                            color: selected ? color : const Color(0xFFE5E7EB),
                            width: selected ? 1.6 : 1,
                          ),
                          boxShadow: selected
                              ? [BoxShadow(color: color.withOpacity(0.16), blurRadius: 12, offset: const Offset(0, 5))]
                              : const [],
                        ),
                        child: Stack(
                          clipBehavior: Clip.none,
                          children: [
                            if (underDevelopment)
                              Positioned(
                                top: -4,
                                left: isAr ? -2 : null,
                                right: isAr ? null : -2,
                                child: Icon(
                                  Icons.lock_clock_outlined,
                                  color: color,
                                  size: 20,
                                ),
                              ),
                            if (selected)
                              Positioned(
                                top: -22,
                                right: isAr ? -18 : null,
                                left: isAr ? null : -18,
                                child: CircleAvatar(
                                  radius: 14,
                                  backgroundColor: color,
                                  child: const Icon(Icons.check, color: Colors.white, size: 18),
                                ),
                              ),
                            Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(_modeIcon(mode), color: color, size: veryNarrow ? 28 : 34),
                                const SizedBox(height: 8),
                                Text(
                                  _modeLabel(mode),
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                    fontSize: veryNarrow ? 15 : 17,
                                    fontWeight: FontWeight.w800,
                                    color: selected ? color : const Color(0xFF111827),
                                  ),
                                ),
                                const SizedBox(height: 5),
                                Text(
                                  _modeSubtitle(mode),
                                  textAlign: TextAlign.center,
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                  style: TextStyle(fontSize: veryNarrow ? 11 : 12.5, color: const Color(0xFF6B7280)),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  );
                }).toList(),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildModeSummaryCard() {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 14),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF16A34A), Color(0xFF15803D)],
          begin: Alignment.centerRight,
          end: Alignment.centerLeft,
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: const [
          BoxShadow(color: Color(0x22000000), blurRadius: 12, offset: Offset(0, 4)),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.fact_check_outlined, color: Colors.white),
          const SizedBox(width: 8),
          Flexible(
            child: Text(
              _modeSummaryText(),
              textAlign: TextAlign.center,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w800,
                color: Colors.white,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRangeInput({
    required String fromLabel,
    required String toLabel,
    required int fromValue,
    required int toValue,
    required int min,
    required int max,
    required Function(int) onFromChanged,
    required Function(int) onToChanged,
  }) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.95),
        borderRadius: BorderRadius.circular(12),
        boxShadow: const [
          BoxShadow(color: Color(0x14000000), blurRadius: 8, offset: Offset(0, 2))
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: _buildCompactNumberInput(
              fromLabel,
              fromValue,
              min,
              max,
              onFromChanged,
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: _buildCompactNumberInput(
              toLabel,
              toValue,
              min,
              max,
              onToChanged,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCompactNumberInput(
      String label, int value, int min, int max, Function(int) onChanged) {
    return Column(
      children: [
        Text(label, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w700)),
        const SizedBox(height: 6),
        SpinBox(
          min: min.toDouble(),
          max: max.toDouble(),
          value: value.toDouble(),
          step: 1,
          decimals: 0,
          textStyle: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          onChanged: (val) => onChanged(val.toInt()),
        ),
      ],
    );
  }

  Widget _buildQuizSettingsCard() {
    final items = [
      _buildNumberInput(
        _lang == 'ar' ? 'عدد الأسئلة' : 'Number of questions',
        Icons.quiz_outlined,
        _repeatCount,
        1,
        100,
        (val) => setState(() => _repeatCount = val),
      ),
      _buildNumberInput(
        _lang == 'ar' ? 'عدد آيات الإجابة' : 'Answer ayahs',
        Icons.menu_book_rounded,
        _ayahsAfter,
        0,
        10,
        (val) => setState(() => _ayahsAfter = val),
      ),
      _buildNumberInput(
        t('examDurationMinutes'),
        Icons.timer_outlined,
        _recitationDelay,
        1,
        10,
        (val) => setState(() => _recitationDelay = val),
      ),
    ];

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.97),
        borderRadius: BorderRadius.circular(18),
        boxShadow: const [
          BoxShadow(color: Color(0x18000000), blurRadius: 14, offset: Offset(0, 5)),
        ],
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.tune_rounded, color: Color(0xFF15803D)),
              const SizedBox(width: 8),
              Text(
                _lang == 'ar' ? 'إعدادات الاختبار' : 'Test settings',
                style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w800),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              for (int i = 0; i < items.length; i++) ...[
                Expanded(child: items[i]),
                if (i != items.length - 1) const SizedBox(width: 6),
              ],
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildNumberInput(
      String label, IconData icon, int value, int min, int max, Function(int) onChanged) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 10),
      decoration: BoxDecoration(
        color: const Color(0xFFF4FBF6),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFD6EBDD)),
      ),
      child: Column(
        children: [
          SizedBox(
            height: 42,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(icon, color: const Color(0xFF15803D), size: 18),
                const SizedBox(width: 4),
                Flexible(
                  child: Text(
                    label,
                    textAlign: TextAlign.center,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 13,
                      height: 1.15,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 6),
          Container(
            height: 44,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: const Color(0xFFB7CCBE)),
            ),
            child: Row(
              children: [
                Expanded(
                  child: IconButton(
                    tooltip: _lang == 'ar' ? 'إنقاص' : 'Decrease',
                    padding: EdgeInsets.zero,
                    visualDensity: VisualDensity.compact,
                    onPressed: value > min ? () => onChanged(value - 1) : null,
                    icon: const Icon(Icons.remove_rounded, size: 20),
                  ),
                ),
                Text(
                  '$value',
                  style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w800),
                ),
                Expanded(
                  child: IconButton(
                    tooltip: _lang == 'ar' ? 'زيادة' : 'Increase',
                    padding: EdgeInsets.zero,
                    visualDensity: VisualDensity.compact,
                    onPressed: value < max ? () => onChanged(value + 1) : null,
                    icon: const Icon(Icons.add_rounded, size: 20),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }


  Widget _buildFeedbackCard() {
    final isAr = _lang == 'ar';

    return CustomPaint(
      painter: _DashedRRectPainter(
        color: const Color(0xFF22C55E).withOpacity(0.45),
        radius: 16,
        dashWidth: 7,
        dashGap: 5,
      ),
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: const Color(0xFFEFFDF5).withOpacity(0.78),
          borderRadius: BorderRadius.circular(16),
        ),
        child: LayoutBuilder(
          builder: (context, constraints) {
            final bool wide = constraints.maxWidth > 760;

            final info = Row(
              textDirection: isAr ? TextDirection.rtl : TextDirection.ltr,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Icon(
                  Icons.forum_outlined,
                  color: Color(0xFF15803D),
                  size: 32,
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment:
                        isAr ? CrossAxisAlignment.end : CrossAxisAlignment.start,
                    children: [
                      Text(
                        isAr ? 'ملاحظات واقتراحات' : 'Comments and suggestions',
                        textAlign: isAr ? TextAlign.right : TextAlign.left,
                        style: const TextStyle(
                          fontSize: 21,
                          fontWeight: FontWeight.w900,
                          color: Color(0xFF15803D),
                        ),
                      ),
                      const SizedBox(height: 7),
                      Text(
                        isAr
                            ? 'نرحب بملاحظاتك واقتراحاتك لتحسين التطبيق وتطويره'
                            : 'Send your notes or suggestions to help improve the app',
                        textAlign: isAr ? TextAlign.right : TextAlign.left,
                        style: const TextStyle(
                          fontSize: 14,
                          height: 1.45,
                          color: Color(0xFF4B5563),
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            );

            final input = Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                TextField(
                  controller: _feedbackController,
                  minLines: 2,
                  maxLines: 4,
                  textAlign: isAr ? TextAlign.right : TextAlign.left,
                  textDirection: isAr ? TextDirection.rtl : TextDirection.ltr,
                  decoration: InputDecoration(
                    hintText: isAr
                        ? 'اكتب ملاحظتك أو اقتراحك هنا...'
                        : 'Write your comment or suggestion here...',
                    hintStyle: const TextStyle(color: Color(0xFF9CA3AF)),
                    filled: true,
                    fillColor: Colors.white.withOpacity(0.93),
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 13,
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: const BorderSide(color: Color(0xFFD1D5DB)),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: const BorderSide(color: Color(0xFFD1D5DB)),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: const BorderSide(
                        color: Color(0xFF15803D),
                        width: 1.4,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 9),
                Align(
                  alignment:
                      isAr ? AlignmentDirectional.centerEnd : AlignmentDirectional.centerStart,
                  child: OutlinedButton.icon(
                    style: OutlinedButton.styleFrom(
                      foregroundColor: const Color(0xFF15803D),
                      side: const BorderSide(color: Color(0xFF15803D)),
                      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    onPressed: _sendFeedbackEmail,
                    icon: const Icon(Icons.mail_outline),
                    label: Text(
                      isAr ? 'إرسال الملاحظة' : 'Send comment',
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ),
                ),
              ],
            );

            if (wide) {
              return Row(
                textDirection: isAr ? TextDirection.rtl : TextDirection.ltr,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  SizedBox(width: 290, child: info),
                  const SizedBox(width: 18),
                  Expanded(child: input),
                ],
              );
            }

            return Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                info,
                const SizedBox(height: 12),
                input,
              ],
            );
          },
        ),
      ),
    );
  }

  Future<void> _sendFeedbackEmail() async {
    final message = _feedbackController.text.trim();

    if (message.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            _lang == 'ar'
                ? 'اكتب الملاحظة أولاً، البريد لا يقرأ النوايا بعد.'
                : 'Write a comment first.',
          ),
        ),
      );
      return;
    }

    const feedbackEmail = 'alsabiqoonsabiqoon@gmail.com'; // غيّر هذا إلى بريدك الحقيقي

    final uri = Uri(
      scheme: 'mailto',
      path: feedbackEmail,
      queryParameters: {
        'subject': _lang == 'ar'
            ? 'ملاحظة من تطبيق السابقون'
            : 'Feedback from Al-Sabiqoon app',
        'body': message,
      },
    );

    final opened = await launchUrl(uri, mode: LaunchMode.externalApplication);

    if (!opened && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            _lang == 'ar'
                ? 'لم أستطع فتح تطبيق البريد. التكنولوجيا قررت التظاهر بالنعاس.'
                : 'Could not open the email app.',
          ),
        ),
      );
    }
  }

  Widget _buildStartBar(BuildContext context) {
    final lang = _lang;
    String t(String k) => L10nSimple.t(lang, k);
    return SafeArea(
      top: false,
      child: Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          boxShadow: [BoxShadow(color: Color(0x1F000000), blurRadius: 12, offset: Offset(0, -3))],
        ),
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 14),
        child: SizedBox(
          width: double.infinity,
          height: 58,
          child: ElevatedButton.icon(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF15803D),
              foregroundColor: Colors.white,
              elevation: 0,
              shadowColor: Colors.transparent,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
            ),
            onPressed: _onStartPressed,
            icon: Icon(
              _usageMode == 'listening'
                  ? Icons.headphones_rounded
                  : Icons.rocket_launch_outlined,
            ),
            label: Text(
                _usageMode == 'listening'
                    ? (lang == 'ar' ? 'ابدأ الاستماع' : 'Start listening')
                    : (lang == 'ar' ? 'ابدأ الاختبار' : t('startQuiz')),
                style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w800)),
          ),
        ),
      ),
    );
  }

  Widget _buildCompetitionsCard() {
    final isArabic = _lang == 'ar';
    return Material(
      color: Colors.white,
      elevation: 2,
      borderRadius: BorderRadius.circular(20),
      child: InkWell(
        borderRadius: BorderRadius.circular(20),
        onTap: () {
          Navigator.of(context).push(
            MaterialPageRoute<void>(
              builder: (_) => const Directionality(
                textDirection: TextDirection.rtl,
                child: CompetitionListPage(),
              ),
            ),
          );
        },
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
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
                  Icons.emoji_events_rounded,
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
                      isArabic ? 'مسابقات القرآن الكريم' : 'Quran competitions',
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      isArabic
                          ? 'شاهد الأسئلة واختبر إجابتك'
                          : 'Watch questions and test your answer',
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
  }

  void _onStartPressed() {
    if (_testMode == 'surah' && _selectedSurahs.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(t('pleaseSelectAtLeastOne'))),
      );
      return;
    }
    if (_usageMode == 'listening') {
      Navigator.push(
        context,
        MaterialPageRoute<void>(
          builder: (_) => ListeningPage(
            mode: _testMode,
            selectedSurahs:
                _selectedSurahs.isEmpty ? _allSurahs : _selectedSurahs,
            pageFrom: _selectedPageFrom,
            pageTo: _selectedPageTo,
            juzFrom: _selectedJuzFrom,
            juzTo: _selectedJuzTo,
            hizbFrom: _selectedHizbFrom,
            hizbTo: _selectedHizbTo,
            rubFrom: _selectedRubFrom,
            rubTo: _selectedRubTo,
            reciterUrl: _selectedReciter.url,
            reciterName: _selectedReciter.localizedName(_lang),
          ),
        ),
      );
      return;
    }
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => PlayPage(
          repeatCount: _repeatCount,
          ayahsAfter: _ayahsAfter,
          delaySeconds: _recitationDelay,
          selectedSurahs: _selectedSurahs.isEmpty ? _allSurahs : _selectedSurahs,
          reciterKey: _selectedReciter.key,
          reciterUrl: _selectedReciter.url,
          reciterNameAr: _selectedReciter.nameAr,
          reciterNameEn: _selectedReciter.nameEn,
          testMode: _testMode,
          selectedPageFrom: _selectedPageFrom,
          selectedPageTo: _selectedPageTo,
          selectedJuzFrom: _selectedJuzFrom,
          selectedJuzTo: _selectedJuzTo,
          selectedHizbFrom: _selectedHizbFrom,
          selectedHizbTo: _selectedHizbTo,
          selectedRubFrom: _selectedRubFrom,
          selectedRubTo: _selectedRubTo,
        ),
      ),
    );
  }

  /// --------------------------- Pickers -------------------------------------

  Future<void> _openReciterPicker() async {
    await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        String query = '';
        Reciter current = _selectedReciter;

        return StatefulBuilder(
          builder: (context, setSB) {
            final filtered = _reciters.where((r) {
              final n = r.localizedName(_lang).toLowerCase();
              return n.contains(query.toLowerCase());
            }).toList()
              ..sort(_compareReciters); // ✅ sort filtered too

            return Container(
              height: MediaQuery.of(context).size.height * 0.85,
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
              ),
              child: Column(
                children: [
                  const SizedBox(height: 8),
                  Container(
                    width: 48, height: 5,
                    decoration: BoxDecoration(
                      color: Colors.grey.shade300,
                      borderRadius: BorderRadius.circular(3),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: TextField(
                      decoration: InputDecoration(
                        hintText: _lang == 'ar' ? 'ابحث عن قارئ' : 'Search reciter',
                        prefixIcon: const Icon(Icons.search),
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                        filled: true,
                        fillColor: Colors.grey[100],
                        contentPadding: const EdgeInsets.symmetric(vertical: 10, horizontal: 12),
                      ),
                      onChanged: (v) => setSB(() {
                        query = v;
                      }),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Expanded(
                    child: ListView.separated(
                      itemCount: filtered.length,
                      separatorBuilder: (_, __) => const Divider(height: 1),
                      itemBuilder: (context, i) {
                        final r = filtered[i];
                        final selected = r.key == current.key;
                        return Material(
                          color: Colors.white,
                          child: ListTile(
                            title: Text(
                              r.localizedName(_lang),
                              textAlign: TextAlign.center,
                              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                            ),
                            trailing: selected ? const Icon(Icons.check, color: Colors.green) : null,
                            onTap: () => setSB(() => current = r),
                          ),
                        );
                      },
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(12),
                    child: Row(
                      children: [
                        Expanded(
                          child: OutlinedButton(
                            onPressed: () => Navigator.pop(context),
                            child: Text(_lang == 'ar' ? 'إلغاء' : 'Cancel'),
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: ElevatedButton(
                            style: ElevatedButton.styleFrom(backgroundColor: Colors.blueAccent),
                            onPressed: () {
                              setState(() => _selectedReciter = current);
                              Navigator.pop(context);
                            },
                            child: Text(_lang == 'ar' ? 'اختيار' : 'Choose'),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
    setState(() {}); // refresh button text
  }

  void _openSurahSelector() async {
    bool? updated = await showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setStateSB) {
            final filteredSurahs = _allSurahs
                .where((s) => _displayName(s).toLowerCase().contains(_searchQuery.toLowerCase()))
                .toList();

            return Container(
              height: MediaQuery.of(context).size.height * 0.85,
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
              ),
              child: Column(
                children: [
                  const SizedBox(height: 8),
                  Container(
                    width: 48, height: 5,
                    decoration: BoxDecoration(
                      color: Colors.grey.shade300,
                      borderRadius: BorderRadius.circular(3),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: TextField(
                      decoration: InputDecoration(
                        hintText: t('searchHint'),
                        prefixIcon: const Icon(Icons.search),
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                        filled: true,
                        fillColor: Colors.grey[100],
                        contentPadding: const EdgeInsets.symmetric(vertical: 10, horizontal: 12),
                      ),
                      onChanged: (val) => setStateSB(() => _searchQuery = val),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    child: Row(
                      children: [
                        FilterChip(
                          label: Text("${t('selectedSurahs')} ${L10nSimple.digits(_lang, _selectedSurahs.length)}"),
                          onSelected: (_) {},
                        ),
                        const Spacer(),
                        TextButton.icon(
                          onPressed: () => setStateSB(() => _selectedSurahs = List.from(_allSurahs)),
                          icon: const Icon(Icons.done_all),
                          label: Text(t('selectAll')),
                        ),
                        const SizedBox(width: 6),
                        TextButton.icon(
                          onPressed: () => setStateSB(() => _selectedSurahs.clear()),
                          icon: const Icon(Icons.clear_all),
                          label: Text(t('clearAll')),
                        ),
                      ],
                    ),
                  ),
                  const Divider(height: 1),
                  Expanded(
                    child: ListView.builder(
                      itemCount: filteredSurahs.length,
                      itemBuilder: (context, index) {
                        final surah = filteredSurahs[index];
                        final selected = _selectedSurahs.contains(surah);
                        return Material(
                          color: Colors.white,
                          child: CheckboxListTile(
                            value: selected,
                            title: Text(
                              _displayName(surah),
                              textAlign: TextAlign.center,
                              style: const TextStyle(fontSize: 18),
                            ),
                            onChanged: (checked) {
                              setStateSB(() {
                                if (checked == true) {
                                  _selectedSurahs.add(surah);
                                } else {
                                  _selectedSurahs.remove(surah);
                                }
                              });
                            },
                            controlAffinity: ListTileControlAffinity.leading,
                          ),
                        );
                      },
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(12),
                    child: ElevatedButton(
                      onPressed: () => Navigator.pop(context, true),
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 12),
                        backgroundColor: Colors.blueAccent,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                      child: Text(t('done'), style: const TextStyle(fontSize: 18)),
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );

    if (updated == true) setState(() {});
  }
}

class _DashedRRectPainter extends CustomPainter {
  final Color color;
  final double radius;
  final double dashWidth;
  final double dashGap;

  const _DashedRRectPainter({
    required this.color,
    required this.radius,
    required this.dashWidth,
    required this.dashGap,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final rect = Offset.zero & size;
    final rrect = RRect.fromRectAndRadius(rect.deflate(1), Radius.circular(radius));
    final path = Path()..addRRect(rrect);
    final paint = Paint()
      ..color = color
      ..strokeWidth = 1.2
      ..style = PaintingStyle.stroke;

    for (final metric in path.computeMetrics()) {
      double distance = 0;
      while (distance < metric.length) {
        final next = math.min(distance + dashWidth, metric.length);
        canvas.drawPath(metric.extractPath(distance, next), paint);
        distance += dashWidth + dashGap;
      }
    }
  }

  @override
  bool shouldRepaint(covariant _DashedRRectPainter oldDelegate) {
    return oldDelegate.color != color ||
        oldDelegate.radius != radius ||
        oldDelegate.dashWidth != dashWidth ||
        oldDelegate.dashGap != dashGap;
  }
}
