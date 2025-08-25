

// import 'package:flutter/material.dart';
// import 'package:flutter/services.dart';
// import 'dart:convert';
// import 'package:flutter_spinbox/flutter_spinbox.dart';
// import 'main.dart'; // for PlayPage
// import 'l10n_simple.dart';

// class SettingsPage extends StatefulWidget {
//   const SettingsPage({Key? key}) : super(key: key);

//   @override
//   _SettingsPageState createState() => _SettingsPageState();
// }

// class _SettingsPageState extends State<SettingsPage> {
//   // English names for the 114 surahs, keyed by Arabic canonical names.
//   static const Map<String, String> kSurahNameEn = {
//     "الفاتحة": "Al Fatihah",
//     "البقرة": "Al Baqara",
//     "آل عمران": "Al Imran",
//     "النساء": "An Nisa",
//     "المائدة": "Al Maida",
//     "الأنعام": "Al Anam",
//     "الأعراف": "Al Araf",
//     "الأنفال": "Al Anfal",
//     "التوبة": "At Tauba / Baraat",
//     "يونس": "Yunus",
//     "هود": "Hud",
//     "يوسف": "Yusuf",
//     "الرعد": "Ar Rad",
//     "ابراهيم": "Ibrahim",
//     "الحجر": "Al Hijr",
//     "النحل": "An Nahl",
//     "الإسراء": "Al Isra",
//     "الكهف": "Al Kahf",
//     "مريم": "Maryam",
//     "طه": "Ta Ha",
//     "الأنبياء": "Al Anbiya",
//     "الحج": "Al Hajj",
//     "المؤمنون": "Al Muminun",
//     "النور": "An Nur",
//     "الفرقان": "Al Furqan",
//     "الشعراء": "Ash Shuara",
//     "النمل": "An Naml",
//     "القصص": "Al Qasas",
//     "العنكبوت": "Al Ankabut",
//     "الروم": "Ar Rum",
//     "لقمان": "Luqman",
//     "السجدة": "As Sajda",
//     "الأحزاب": "Al Ahzab",
//     "سبإ": "Saba",
//     "فاطر": "Fatir",
//     "يس": "Ya Sin",
//     "الصافات": "As Saffat",
//     "ص": "Sad",
//     "الزمر": "Az Zumar",
//     "غافر": "Ghafir",
//     "فصلت": "Fussilat",
//     "الشورى": "Ash Shura",
//     "الزخرف": "Az Zukhruf",
//     "الدخان": "Ad Dukhan",
//     "الجاثية": "Al Jathiyah",
//     "الأحقاف": "Al Ahqaf",
//     "محمد": "Muhammad",
//     "الفتح": "Al Fath",
//     "الحجرات": "Al Hujurat",
//     "ق": "Qaf",
//     "الذاريات": "Adh Dhariyat",
//     "الطور": "At Tur",
//     "النجم": "An Najm",
//     "القمر": "Al Qamar",
//     "الرحمن": "Ar Rahman",
//     "الواقعة": "Al Waqia",
//     "الحديد": "Al Hadid",
//     "المجادلة": "Al Mujadila",
//     "الحشر": "Al Hashr",
//     "الممتحنة": "Al Mumtahana",
//     "الصف": "As Saff",
//     "الجمعة": "Al Jumuah",
//     "المنافقون": "Al Munafiqun",
//     "التغابن": "At Taghabun",
//     "الطلاق": "At Talaq",
//     "التحريم": "At Tahrim",
//     "الملك": "Al Mulk",
//     "القلم": "Al Qalam",
//     "الحاقة": "Al Haqqah",
//     "المعارج": "Al Maarij",
//     "نوح": "Nuh",
//     "الجن": "Al Jinn",
//     "المزمل": "Al Muzzammil",
//     "المدثر": "Al Muddathir",
//     "القيامة": "Al Qiyamah",
//     "الانسان": "Al Insan",
//     "المرسلات": "Al Mursalat",
//     "النبإ": "An Naba",
//     "النازعات": "An Naziat",
//     "عبس": "Abasa",
//     "التكوير": "At Takwir",
//     "الإنفطار": "Al Infitar",
//     "المطففين": "Al Mutaffifin",
//     "الإنشقاق": "Al Inshiqaq",
//     "البروج": "Al Buruj",
//     "الطارق": "At Tariq",
//     "الأعلى": "Al Ala",
//     "الغاشية": "Al Ghashiyah",
//     "الفجر": "Al Fajr",
//     "البلد": "Al Balad",
//     "الشمس": "Ash Shams",
//     "الليل": "Al Layl",
//     "الضحى": "Ad Duhaa",
//     "الشرح": "Ash Sharh",
//     "التين": "At Tin",
//     "العلق": "Al Alaq",
//     "القدر": "Al Qadr",
//     "البينة": "Al Bayyinah",
//     "الزلزلة": "Az Zalzalah",
//     "العاديات": "Al Adiyat",
//     "القارعة": "Al Qariah",
//     "التكاثر": "At Takathur",
//     "العصر": "Al Asr",
//     "الهمزة": "Al Humazah",
//     "الفيل": "Al Fil",
//     "قريش": "Quraish",
//     "الماعون": "Al Maun",
//     "الكوثر": "Al Kawthar",
//     "الكافرون": "Al Kafirun",
//     "النصر": "An Nasr",
//     "المسد": "Al Masad",
//     "الإخلاص": "Al Ikhlas",
//     "الفلق": "Al Falaq",
//     "الناس": "An Nas",
//   };

//   int _repeatCount = 3;
//   int _ayahsAfter = 2;
//   int _recitationDelay = 5;
//   List<String> _selectedSurahs = [];
//   List<String> _allSurahs = [];
//   String _searchQuery = "";

//   String get _lang {
//     try {
//       return LangScope.of(context).lang;
//     } catch (e) {
//       return 'ar';
//     }
//   }

//   String t(String k) => L10nSimple.t(_lang, k);

//   String _displayName(String ar) {
//     return _lang == 'en' ? (kSurahNameEn[ar] ?? ar) : ar;
//   }

//   String _surahHeaderText() {
//     if (_selectedSurahs.isEmpty) {
//       return "📖 ${t('pickSurahs')}";
//     } else {
//       return "📖 ${t('selectedSurahs')} (${L10nSimple.digits(_lang, _selectedSurahs.length)})";
//     }
//   }

//   @override
//   void initState() {
//     super.initState();
//     _loadSurahs();
//   }

//   Future<void> _loadSurahs() async {
//     final jsonString = await rootBundle.loadString('assets/ayah_texts.json');
//     final Map<String, dynamic> jsonData = json.decode(jsonString);

//     final List<String> quranOrder = [
//       "الفاتحة", "البقرة", "آل عمران", "النساء", "المائدة", "الأنعام", "الأعراف",
//       "الأنفال", "التوبة", "يونس", "هود", "يوسف", "الرعد", "ابراهيم", "الحجر", "النحل",
//       "الإسراء", "الكهف", "مريم", "طه", "الأنبياء", "الحج", "المؤمنون", "النور", "الفرقان",
//       "الشعراء", "النمل", "القصص", "العنكبوت", "الروم", "لقمان", "السجدة", "الأحزاب",
//       "سبإ", "فاطر", "يس", "الصافات", "ص", "الزمر", "غافر", "فصلت", "الشورى", "الزخرف",
//       "الدخان", "الجاثية", "الأحقاف", "محمد", "الفتح", "الحجرات", "ق", "الذاريات",
//       "الطور", "النجم", "القمر", "الرحمن", "الواقعة", "الحديد", "المجادلة", "الحشر",
//       "الممتحنة", "الصف", "الجمعة", "المنافقون", "التغابن", "الطلاق", "التحريم", "الملك",
//       "القلم", "الحاقة", "المعارج", "نوح", "الجن", "المزمل", "المدثر", "القيامة",
//       "الانسان", "المرسلات", "النبإ", "النازعات", "عبس", "التكوير", "الإنفطار",
//       "المطففين", "الإنشقاق", "البروج", "الطارق", "الأعلى", "الغاشية", "الفجر",
//       "البلد", "الشمس", "الليل", "الضحى", "الشرح", "التين", "العلق", "القدر", "البينة",
//       "الزلزلة", "العاديات", "القارعة", "التكاثر", "العصر", "الهمزة", "الفيل", "قريش",
//       "الماعون", "الكوثر", "الكافرون", "النصر", "المسد", "الإخلاص", "الفلق", "الناس"
//     ];

//     final Set<String> surahNames = jsonData.values
//         .map((e) => e['surah'].toString().trim())
//         .toSet();

//     final ordered = quranOrder.where((name) => surahNames.contains(name)).toList();

//     setState(() {
//       _allSurahs = ordered;
//       _selectedSurahs = List.from(ordered);
//     });
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       bottomNavigationBar: _buildStartBar(context),
//       body: Directionality(
//         textDirection: L10nSimple.textDir(_lang),
//         child: Container(
//           decoration: BoxDecoration(
//             gradient: LinearGradient(
//               colors: [Colors.green.shade700, Colors.yellow.shade200],
//               begin: Alignment.topCenter,
//               end: Alignment.bottomCenter,
//             ),
//           ),
//           child: SafeArea(
//             child: SingleChildScrollView(
//               padding: const EdgeInsets.fromLTRB(16, 16, 16, 120),
//               child: Column(
//                 crossAxisAlignment: CrossAxisAlignment.stretch,
//                 children: [
//                   const SizedBox(height: 8),
//                   // (Logo removed)
//                   Align(
//                     alignment: AlignmentDirectional.topEnd,
//                     child: Container(
//                       padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
//                       decoration: BoxDecoration(
//                         color: Colors.black.withOpacity(0.08),
//                         borderRadius: BorderRadius.circular(8),
//                       ),
//                       child: DropdownButtonHideUnderline(
//                         child: DropdownButton<String>(
//                           value: _lang,
//                           icon: const Icon(Icons.language),
//                           onChanged: (v) {
//                             final scope = LangScope.of(context);
//                             scope.onChange?.call(v ?? 'ar');
//                             setState(() {});
//                           },
//                           items: const [
//                             DropdownMenuItem(value: 'ar', child: Text('العربية')),
//                             DropdownMenuItem(value: 'en', child: Text('English')),
//                           ],
//                         ),
//                       ),
//                     ),
//                   ),
//                   const SizedBox(height: 12),
//                   ElevatedButton.icon(
//                     icon: const Icon(Icons.menu_book),
//                     style: ElevatedButton.styleFrom(
//                       backgroundColor: Colors.blueAccent,
//                       padding: const EdgeInsets.symmetric(vertical: 16),
//                       shape: RoundedRectangleBorder(
//                         borderRadius: BorderRadius.circular(12),
//                       ),
//                     ),
//                     onPressed: _openSurahSelector,
//                     label: Text(
//                       _surahHeaderText(),
//                       overflow: TextOverflow.ellipsis,
//                       style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white),
//                     ),
//                   ),
//                   const SizedBox(height: 20),
//                   _buildNumberInput(t('repeatCount'), _repeatCount, 1, 100, (val) => setState(() => _repeatCount = val)),
//                   const SizedBox(height: 12),
//                   _buildNumberInput(t('ayahsAfter'), _ayahsAfter, 0, 10, (val) => setState(() => _ayahsAfter = val)),
//                   const SizedBox(height: 12),
//                   _buildNumberInput(t('examDurationMinutes'), _recitationDelay, 1, 10, (val) => setState(() => _recitationDelay = val)),
//                 ],
//               ),
//             ),
//           ),
//         ),
//       ),
//     );
//   }

//   Widget _buildNumberInput(String label, int value, int min, int max, Function(int) onChanged) {
//     return Container(
//       padding: const EdgeInsets.all(12),
//       decoration: BoxDecoration(
//         color: Colors.white.withOpacity(0.95),
//         borderRadius: BorderRadius.circular(12),
//         boxShadow: const [BoxShadow(color: Color(0x14000000), blurRadius: 8, offset: Offset(0, 2))],
//       ),
//       child: Column(
//         children: [
//           Text(label, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
//           const SizedBox(height: 8),
//           SizedBox(
//             width: 160,
//             child: SpinBox(
//               min: min.toDouble(),
//               max: max.toDouble(),
//               value: value.toDouble(),
//               step: 1,
//               decimals: 0,
//               textStyle: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
//               onChanged: (val) => onChanged(val.toInt()),
//             ),
//           ),
//         ],
//       ),
//     );
//   }

//   Widget _buildStartBar(BuildContext context) {
//     final lang = _lang;
//     String t(String k) => L10nSimple.t(lang, k);
//     return SafeArea(
//       top: false,
//       child: Container(
//         decoration: const BoxDecoration(
//           color: Colors.white,
//           boxShadow: [BoxShadow(color: Color(0x1F000000), blurRadius: 12, offset: Offset(0, -3))],
//         ),
//         padding: const EdgeInsets.fromLTRB(16, 10, 16, 16),
//         child: SizedBox(
//           width: double.infinity,
//           height: 56,
//           child: ElevatedButton(
//             style: ElevatedButton.styleFrom(
//               backgroundColor: const Color(0xFF22C55E),
//               foregroundColor: Colors.white,
//               elevation: 0,
//               shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
//             ),
//             onPressed: _onStartPressed,
//             child: Text(t('startQuiz'), style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w700)),
//           ),
//         ),
//       ),
//     );
//   }

//   void _onStartPressed() {
//     final lang = _lang;
//     String t(String k) => L10nSimple.t(lang, k);
//     if (_selectedSurahs.isEmpty) {
//       ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(t('pleaseSelectAtLeastOne'))));
//       return;
//     }
//     Navigator.push(
//       context,
//       MaterialPageRoute(
//         builder: (_) => PlayPage(
//           repeatCount: _repeatCount,
//           ayahsAfter: _ayahsAfter,
//           delaySeconds: _recitationDelay,
//           selectedSurahs: _selectedSurahs.isEmpty ? _allSurahs : _selectedSurahs,
//         ),
//       ),
//     );
//   }

//   void _openSurahSelector() async {
//     bool? updated = await showModalBottomSheet<bool>(
//       context: context,
//       isScrollControlled: true,
//       backgroundColor: Colors.transparent,
//       builder: (context) {
//         return StatefulBuilder(
//           builder: (context, setStateSB) {
//             final filteredSurahs = _allSurahs.where(
//               (s) => _displayName(s).toLowerCase().contains(_searchQuery.toLowerCase()),
//             ).toList();
//             return Container(
//               height: MediaQuery.of(context).size.height * 0.85,
//               decoration: const BoxDecoration(
//                 color: Colors.white,
//                 borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
//               ),
//               child: Column(
//                 children: [
//                   const SizedBox(height: 8),
//                   Container(
//                     width: 48,
//                     height: 5,
//                     decoration: BoxDecoration(
//                       color: Colors.grey.shade300,
//                       borderRadius: BorderRadius.circular(3),
//                     ),
//                   ),
//                   const SizedBox(height: 12),
//                   Padding(
//                     padding: const EdgeInsets.symmetric(horizontal: 16),
//                     child: TextField(
//                       decoration: InputDecoration(
//                         hintText: t('searchHint'),
//                         prefixIcon: const Icon(Icons.search),
//                         border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
//                         filled: true,
//                         fillColor: Colors.grey[100],
//                         contentPadding: const EdgeInsets.symmetric(vertical: 10, horizontal: 12),
//                       ),
//                       onChanged: (val) => setStateSB(() => _searchQuery = val),
//                     ),
//                   ),
//                   const SizedBox(height: 8),
//                   Padding(
//                     padding: const EdgeInsets.symmetric(horizontal: 12),
//                     child: Row(
//                       children: [
//                         FilterChip(
//                           label: Text("${t('selectedSurahs')} ${L10nSimple.digits(_lang, _selectedSurahs.length)}"),
//                           onSelected: (_) {},
//                         ),
//                         const Spacer(),
//                         TextButton.icon(
//                           onPressed: () => setStateSB(() => _selectedSurahs = List.from(_allSurahs)),
//                           icon: const Icon(Icons.done_all),
//                           label: Text(t('selectAll')),
//                         ),
//                         const SizedBox(width: 6),
//                         TextButton.icon(
//                           onPressed: () => setStateSB(() => _selectedSurahs.clear()),
//                           icon: const Icon(Icons.clear_all),
//                           label: Text(t('clearAll')),
//                         ),
//                       ],
//                     ),
//                   ),
//                   const Divider(height: 1),
//                   Expanded(
//                     child: ListView.builder(
//                       itemCount: filteredSurahs.length,
//                       itemBuilder: (context, index) {
//                         final surah = filteredSurahs[index];
//                         final selected = _selectedSurahs.contains(surah);
//                         return CheckboxListTile(
//                           value: selected,
//                           title: Text(_displayName(surah), textAlign: TextAlign.center, style: const TextStyle(fontSize: 18)),
//                           onChanged: (checked) {
//                             setStateSB(() {
//                               if (checked == true) {
//                                 _selectedSurahs.add(surah);
//                               } else {
//                                 _selectedSurahs.remove(surah);
//                               }
//                             });
//                           },
//                           controlAffinity: ListTileControlAffinity.leading,
//                         );
//                       },
//                     ),
//                   ),
//                   Padding(
//                     padding: const EdgeInsets.all(12),
//                     child: ElevatedButton(
//                       onPressed: () => Navigator.pop(context, true),
//                       style: ElevatedButton.styleFrom(
//                         padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 12),
//                         backgroundColor: Colors.blueAccent,
//                         foregroundColor: Colors.white,
//                         shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
//                       ),
//                       child: Text(t('done'), style: const TextStyle(fontSize: 18)),
//                     ),
//                   ),
//                 ],
//               ),
//             );
//           },
//         );
//       },
//     );

//     if (updated == true) {
//       setState(() {});
//     }
//   }
// }












import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_spinbox/flutter_spinbox.dart';

import 'main.dart';            // PlayPage
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
  int _repeatCount = 3;
  int _ayahsAfter = 2;
  int _recitationDelay = 5;

  List<String> _selectedSurahs = [];
  List<String> _allSurahs = [];
  String _searchQuery = "";

  // Reciters
  List<Reciter> _reciters = kFallbackReciters;
  Reciter _selectedReciter = kFallbackReciters.first;

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
              colors: [Colors.green.shade700, Colors.yellow.shade200],
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
            ),
          ),
          child: SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 120),
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

                  // Reciter picker (shows only the localized name)
                  ElevatedButton.icon(
                    icon: const Icon(Icons.record_voice_over),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.white.withOpacity(0.95),
                      foregroundColor: Colors.black87,
                      padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 12),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      elevation: 0,
                    ),
                    onPressed: _openReciterPicker,
                    label: Row(
                      children: [
                        Expanded(
                          child: Text(
                            _selectedReciter.localizedName(_lang),
                            overflow: TextOverflow.ellipsis,
                            textAlign: TextAlign.center,
                            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
                          ),
                        ),
                        const Icon(Icons.expand_more),
                      ],
                    ),
                  ),

                  const SizedBox(height: 12),

                  // Surah selector button
                  ElevatedButton.icon(
                    icon: const Icon(Icons.menu_book),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blueAccent,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    onPressed: _openSurahSelector,
                    label: Text(
                      _surahHeaderText(),
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ),

                  const SizedBox(height: 20),

                  _buildNumberInput(t('repeatCount'), _repeatCount, 1, 100,
                      (val) => setState(() => _repeatCount = val)),
                  const SizedBox(height: 12),
                  _buildNumberInput(t('ayahsAfter'), _ayahsAfter, 0, 10,
                      (val) => setState(() => _ayahsAfter = val)),
                  const SizedBox(height: 12),
                  _buildNumberInput(t('examDurationMinutes'), _recitationDelay, 1, 10,
                      (val) => setState(() => _recitationDelay = val)),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildNumberInput(
      String label, int value, int min, int max, Function(int) onChanged) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.95),
        borderRadius: BorderRadius.circular(12),
        boxShadow: const [
          BoxShadow(color: Color(0x14000000), blurRadius: 8, offset: Offset(0, 2))
        ],
      ),
      child: Column(
        children: [
          Text(label, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          SizedBox(
            width: 160,
            child: SpinBox(
              min: min.toDouble(),
              max: max.toDouble(),
              value: value.toDouble(),
              step: 1,
              decimals: 0,
              textStyle: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
              onChanged: (val) => onChanged(val.toInt()),
            ),
          ),
        ],
      ),
    );
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
        padding: const EdgeInsets.fromLTRB(16, 10, 16, 16),
        child: SizedBox(
          width: double.infinity,
          height: 56,
          child: ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF22C55E),
              foregroundColor: Colors.white,
              elevation: 0,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            ),
            onPressed: _onStartPressed,
            child: Text(t('startQuiz'),
                style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w700)),
          ),
        ),
      ),
    );
  }

  void _onStartPressed() {
    if (_selectedSurahs.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(t('pleaseSelectAtLeastOne'))),
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
                        return ListTile(
                          title: Text(
                            r.localizedName(_lang),
                            textAlign: TextAlign.center,
                            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                          ),
                          trailing: selected ? const Icon(Icons.check, color: Colors.green) : null,
                          onTap: () => setSB(() => current = r),
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
                        return CheckboxListTile(
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











// import 'dart:convert';
// import 'package:flutter/material.dart';
// import 'package:flutter/services.dart';
// import 'package:flutter_spinbox/flutter_spinbox.dart';

// import 'main.dart';            // PlayPage
// import 'l10n_simple.dart';

// /// ---------------------------------------------------------------------------
// /// Reciter model
// /// ---------------------------------------------------------------------------
// class Reciter {
//   final String key;      // EveryAyah folder name
//   final String nameEn;   // English display name
//   final String nameAr;   // Arabic  display name

//   const Reciter({
//     required this.key,
//     required this.nameEn,
//     required this.nameAr,
//   });

//   String get url => 'https://everyayah.com/data/$key';
//   String localizedName(String lang) => lang == 'ar' ? nameAr : nameEn;

//   Reciter copyWith({String? nameEn, String? nameAr}) => Reciter(
//         key: key,
//         nameEn: nameEn ?? this.nameEn,
//         nameAr: nameAr ?? this.nameAr,
//       );
// }

// /// ---------------------------------------------------------------------------
// /// Optional Arabic overrides for some folder keys (edit as you like)
// /// (Top-level `final` to avoid the const/static build error)
// /// ---------------------------------------------------------------------------
// final Map<String, String> kArabicNameOverrides = {
//   'Muhammad_Ayyoub_128kbps': 'محمد أيوب',
//   'Abdul_Basit_Murattal_64kbps': 'عبد الباسط (مرتل)',
//   'Abdul_Basit_Mujawwad_128kbps': 'عبد الباسط (مجود)',
//   'MisharyRashidAlafasy_64kbps': 'مشاري راشد العفاسي',
//   'MaherAlMuaiqly_64kbps': 'ماهر المعيقلي',
//   'Husary_128kbps': 'محمود خليل الحصري',
//   'Abdurrahmaan_As-Sudais_192kbps': 'عبدالرحمن السديس',
// };

// /// ---------------------------------------------------------------------------
// /// Built-in fallback reciters (used when JSON asset missing)
// /// ---------------------------------------------------------------------------

// const List<Reciter> kFallbackReciters = [
//   Reciter(
//     key: 'Abu_Bakr_Ash-Shaatree_128kbps',
//     nameEn: 'Abu Bakr Al-Shatri',
//     nameAr: 'أبو بكر الشاطري',
//   ),
//   Reciter(
//     key: 'Husary_Muallim_128kbps',
//     nameEn: 'Al-Husary (Teaching)',
//     nameAr: 'الحصري (تعليمي)',
//   ),
//   Reciter(
//     key: 'Minshawy_Mujawwad_192kbps',
//     nameEn: 'Minshawy (Mujawwad)',
//     nameAr: 'المنشاوي (مجود)',
//   ),
//   Reciter(
//     key: 'Minshawy_Murattal_128kbps',
//     nameEn: 'Minshawy (Murattal)',
//     nameAr: 'المنشاوي (مرتل)',
//   ),
//   Reciter(
//     key: 'Khalefa_Al-Tunaiji_64kbps',
//     nameEn: 'Khalifa Al-Tunaiji',
//     nameAr: 'خليفة الطنيجي',
//   ),
//   Reciter(
//     key: 'Ghamadi_40kbps',
//     nameEn: 'Saad Al-Ghamdi',
//     nameAr: 'سعد الغامدي',
//   ),
//   Reciter(
//     key: 'Saood_ash-Shuraym_128kbps',
//     nameEn: 'Saood ash-Shuraym',
//     nameAr: 'سعود الشريم',
//   ),
//   Reciter(
//     key: 'Sahl_Yassin_128kbps',
//     nameEn: 'Sahl Yaseen',
//     nameAr: 'سهل ياسين',
//   ),
//   Reciter(
//     key: 'Abdul_Basit_Mujawwad_128kbps',
//     nameEn: 'Abdul Basit (Mujawwad)',
//     nameAr: 'عبد الباسط (مجود)',
//   ),
//   Reciter(
//     key: 'Abdul_Basit_Murattal_64kbps',
//     nameEn: 'Abdul Basit (Murattal)',
//     nameAr: 'عبد الباسط (مرتل)',
//   ),
//   Reciter(
//     key: 'Abdurrahmaan_As-Sudais_192kbps',
//     nameEn: 'Abdurrahmaan As-Sudais',
//     nameAr: 'عبد الرحمن السديس',
//   ),
//   Reciter(
//     key: 'Hudhaify_64kbps',
//     nameEn: 'Ali Al-Hudhaify',
//     nameAr: 'علي الحذيفي',
//   ),
//   Reciter(
//     key: 'Ali_Jaber_64kbps',
//     nameEn: 'Ali Jaber',
//     nameAr: 'علي جابر',
//   ),
//   Reciter(
//     key: 'Fares_Abbad_64kbps',
//     nameEn: 'Fares Abbad',
//     nameAr: 'فارس عباد',
//   ),
//   Reciter(
//     key: 'MaherAlMuaiqly_64kbps',
//     nameEn: 'Maher Al-Muaiqly',
//     nameAr: 'ماهر المعيقلي',
//   ),
//   Reciter(
//     key: 'Muhammad_Ayyoub_128kbps',
//     nameEn: 'Muhammad Ayyoub',
//     nameAr: 'محمد أيوب',
//   ),
//   Reciter(
//     key: 'Muhammad_Jibreel_64kbps',
//     nameEn: 'Muhammad Jibreel',
//     nameAr: 'محمد جبريل',
//   ),
//   Reciter(
//     key: 'Husary_128kbps',
//     nameEn: 'Mahmoud Khalil Al-Husary',
//     nameAr: 'محمود خليل الحصري',
//   ),
//     Reciter(
//     key: 'Alafasy_128kbps',
//     nameEn: 'Mishary Rashid Alafasy',
//     nameAr: 'مشاري راشد العفاسي',
//   ),
//   Reciter(
//     key: 'Nasser_Alqatami_128kbps',
//     nameEn: 'Nasser Al-Qatami',
//     nameAr: 'ناصر القطامي',
//   ),
//   Reciter(
//     key: 'Hani_Rifai_64kbps',
//     nameEn: 'Hani Ar-Rifai',
//     nameAr: 'هاني الرفاعي',
//   ),
//   Reciter(
//     key: 'Yasser_Ad-Dussary_128kbps',
//     nameEn: 'Yasser Al-Dossari',
//     nameAr: 'ياسر الدوسري',
//   ),
// ];

// // 
// // // const List<Reciter> kFallbackReciters = [
// //   Reciter(
// //     key: 'Muhammad_Ayyoub_128kbps',
// //     nameEn: 'Muhammad Ayyoub (128 kbps)',
// //     nameAr: 'محمد أيوب (128 ك.بت)',
// //   ),
// //   Reciter(
// //     key: 'Abdul_Basit_Mujawwad_128kbps',
// //     nameEn: 'Abdul Basit – Mujawwad (128 kbps)',
// //     nameAr: 'عبدالباسط – مجود (128 ك.بت)',
// //   ),
// //   Reciter(
// //     key: 'MisharyRashidAlafasy_64kbps',
// //     nameEn: 'Mishary Rashid Alafasy (64 kbps)',
// //     nameAr: 'مشاري راشد العفاسي (64 ك.بت)',
// //   ),
// //   Reciter(
// //     key: 'MaherAlMuaiqly_64kbps',
// //     nameEn: 'Maher Al‑Muaiqly (64 kbps)',
// //     nameAr: 'ماهر المعيقلي ',
// //   ),
// //   Reciter(
// //     key: 'Husary_128kbps',
// //     nameEn: 'Mahmoud Khalil Al‑Husary (128 kbps)',
// //     nameAr: 'محمود خليل الحصري (128 ك.بت)',
// //   ),
// //   Reciter(
// //     key: 'Abdurrahmaan_As-Sudais_192kbps',
// //     nameEn: 'Abdurrahmaan As‑Sudais (192 kbps)',
// //     nameAr: 'عبدالرحمن السديس (192 ك.بت)',
// //   ),
// // // ];

// /// ---------------------------------------------------------------------------
// /// Settings page
// /// ---------------------------------------------------------------------------
// class SettingsPage extends StatefulWidget {
//   const SettingsPage({Key? key}) : super(key: key);

//   @override
//   State<SettingsPage> createState() => _SettingsPageState();
// }

// class _SettingsPageState extends State<SettingsPage> {
//   // Arabic→English names for Surahs (for EN UI)
//   static const Map<String, String> kSurahNameEn = {
//     "الفاتحة": "Al Fatihah",
//     "البقرة": "Al Baqara",
//     "آل عمران": "Al Imran",
//     "النساء": "An Nisa",
//     "المائدة": "Al Maida",
//     "الأنعام": "Al Anam",
//     "الأعراف": "Al Araf",
//     "الأنفال": "Al Anfal",
//     "التوبة": "At Tauba / Baraat",
//     "يونس": "Yunus",
//     "هود": "Hud",
//     "يوسف": "Yusuf",
//     "الرعد": "Ar Rad",
//     "ابراهيم": "Ibrahim",
//     "الحجر": "Al Hijr",
//     "النحل": "An Nahl",
//     "الإسراء": "Al Isra",
//     "الكهف": "Al Kahf",
//     "مريم": "Maryam",
//     "طه": "Ta Ha",
//     "الأنبياء": "Al Anbiya",
//     "الحج": "Al Hajj",
//     "المؤمنون": "Al Muminun",
//     "النور": "An Nur",
//     "الفرقان": "Al Furqan",
//     "الشعراء": "Ash Shuara",
//     "النمل": "An Naml",
//     "القصص": "Al Qasas",
//     "العنكبوت": "Al Ankabut",
//     "الروم": "Ar Rum",
//     "لقمان": "Luqman",
//     "السجدة": "As Sajda",
//     "الأحزاب": "Al Ahzab",
//     "سبإ": "Saba",
//     "فاطر": "Fatir",
//     "يس": "Ya Sin",
//     "الصافات": "As Saffat",
//     "ص": "Sad",
//     "الزمر": "Az Zumar",
//     "غافر": "Ghafir",
//     "فصلت": "Fussilat",
//     "الشورى": "Ash Shura",
//     "الزخرف": "Az Zukhruf",
//     "الدخان": "Ad Dukhan",
//     "الجاثية": "Al Jathiyah",
//     "الأحقاف": "Al Ahqaf",
//     "محمد": "Muhammad",
//     "الفتح": "Al Fath",
//     "الحجرات": "Al Hujurat",
//     "ق": "Qaf",
//     "الذاريات": "Adh Dhariyat",
//     "الطور": "At Tur",
//     "النجم": "An Najm",
//     "القمر": "Al Qamar",
//     "الرحمن": "Ar Rahman",
//     "الواقعة": "Al Waqia",
//     "الحديد": "Al Hadid",
//     "المجادلة": "Al Mujadila",
//     "الحشر": "Al Hashr",
//     "الممتحنة": "Al Mumtahana",
//     "الصف": "As Saff",
//     "الجمعة": "Al Jumuah",
//     "المنافقون": "Al Munafiqun",
//     "التغابن": "At Taghabun",
//     "الطلاق": "At Talaq",
//     "التحريم": "At Tahrim",
//     "الملك": "Al Mulk",
//     "القلم": "Al Qalam",
//     "الحاقة": "Al Haqqah",
//     "المعارج": "Al Maarij",
//     "نوح": "Nuh",
//     "الجن": "Al Jinn",
//     "المزمل": "Al Muzzammil",
//     "المدثر": "Al Muddathir",
//     "القيامة": "Al Qiyamah",
//     "الانسان": "Al Insan",
//     "المرسلات": "Al Mursalat",
//     "النبإ": "An Naba",
//     "النازعات": "An Naziat",
//     "عبس": "Abasa",
//     "التكوير": "At Takwir",
//     "الإنفطار": "Al Infitar",
//     "المطففين": "Al Mutaffifin",
//     "الإنشقاق": "Al Inshiqaq",
//     "البروج": "Al Buruj",
//     "الطارق": "At Tariq",
//     "الأعلى": "Al Ala",
//     "الغاشية": "Al Ghashiyah",
//     "الفجر": "Al Fajr",
//     "البلد": "Al Balad",
//     "الشمس": "Ash Shams",
//     "الليل": "Al Layl",
//     "الضحى": "Ad Duhaa",
//     "الشرح": "Ash Sharh",
//     "التين": "At Tin",
//     "العلق": "Al Alaq",
//     "القدر": "Al Qadr",
//     "البينة": "Al Bayyinah",
//     "الزلزلة": "Az Zalzalah",
//     "العاديات": "Al Adiyat",
//     "القارعة": "Al Qariah",
//     "التكاثر": "At Takathur",
//     "العصر": "Al Asr",
//     "الهمزة": "Al Humazah",
//     "الفيل": "Al Fil",
//     "قريش": "Quraish",
//     "الماعون": "Al Maun",
//     "الكوثر": "Al Kawthar",
//     "الكافرون": "Al Kafirun",
//     "النصر": "An Nasr",
//     "المسد": "Al Masad",
//     "الإخلاص": "Al Ikhlas",
//     "الفلق": "Al Falaq",
//     "الناس": "An Nas",
//   };

//   // -- UI State --
//   int _repeatCount = 3;
//   int _ayahsAfter = 2;
//   int _recitationDelay = 5;

//   List<String> _selectedSurahs = [];
//   List<String> _allSurahs = [];
//   String _searchQuery = "";

//   // Reciters
//   List<Reciter> _reciters = kFallbackReciters;
//   Reciter _selectedReciter = kFallbackReciters.first;

//   String get _lang {
//     try {
//       return LangScope.of(context).lang;
//     } catch (_) {
//       return 'ar';
//     }
//   }
//   String t(String k) => L10nSimple.t(_lang, k);
//   String _displayName(String ar) => _lang == 'en' ? (kSurahNameEn[ar] ?? ar) : ar;

//   String _surahHeaderText() =>
//       _selectedSurahs.isEmpty
//           ? "📖 ${t('pickSurahs')}"
//           : "📖 ${t('selectedSurahs')} (${L10nSimple.digits(_lang, _selectedSurahs.length)})";

//   @override
//   void initState() {
//     super.initState();
//     _loadSurahs();
//     _loadReciters();
//   }

//   /// Load reciters from JSON (if present), merge with fallback, apply Arabic overrides
//   Future<void> _loadReciters() async {
//     List<Reciter> loaded = [];
//     try {
//       final jsonString = await rootBundle.loadString('assets/everyayah_reciters.json');
//       final List<dynamic> arr = json.decode(jsonString) as List<dynamic>;
//       loaded = arr.map((e) {
//         final m = e as Map<String, dynamic>;
//         final key = (m['key'] ?? '').toString().trim();
//         final en = (m['name_en'] ?? m['name'] ?? key).toString().trim();
//         final arFromJson = (m['name_ar'] ?? '').toString().trim();
//         final arOverride = kArabicNameOverrides[key];
//         final ar = (arOverride ?? (arFromJson.isNotEmpty ? arFromJson : en)).trim();
//         return Reciter(key: key, nameEn: en, nameAr: ar);
//       }).toList();
//     } catch (_) {
//       // asset missing or parsing failed -> stick with fallback
//     }

//     // Merge: prefer loaded (JSON) by key, then fallback for missing ones
//     final Map<String, Reciter> byKey = {
//       for (final r in loaded) r.key: r,
//       for (final r in kFallbackReciters) r.key: byKeyContains(loaded, r.key) ? byKeyGet(loaded, r.key) : r,
//     };

//     final merged = byKey.values.toList()
//       ..sort((a, b) => a.nameEn.toLowerCase().compareTo(b.nameEn.toLowerCase()));

//     setState(() {
//       _reciters = merged;
//       // Keep selection if possible
//       final keep = _reciters.firstWhere(
//         (r) => r.key == _selectedReciter.key,
//         orElse: () => _reciters.first,
//       );
//       _selectedReciter = keep;
//     });
//   }

//   // tiny helpers for the merge above
//   bool byKeyContains(List<Reciter> list, String key) => list.any((r) => r.key == key);
//   Reciter byKeyGet(List<Reciter> list, String key) => list.firstWhere((r) => r.key == key);

//   Future<void> _loadSurahs() async {
//     final jsonString = await rootBundle.loadString('assets/ayah_texts.json');
//     final Map<String, dynamic> jsonData = json.decode(jsonString);

//     // Canonical Quran order
//     final List<String> quranOrder = [
//       "الفاتحة", "البقرة", "آل عمران", "النساء", "المائدة", "الأنعام", "الأعراف",
//       "الأنفال", "التوبة", "يونس", "هود", "يوسف", "الرعد", "ابراهيم", "الحجر", "النحل",
//       "الإسراء", "الكهف", "مريم", "طه", "الأنبياء", "الحج", "المؤمنون", "النور", "الفرقان",
//       "الشعراء", "النمل", "القصص", "العنكبوت", "الروم", "لقمان", "السجدة", "الأحزاب",
//       "سبإ", "فاطر", "يس", "الصافات", "ص", "الزمر", "غافر", "فصلت", "الشورى", "الزخرف",
//       "الدخان", "الجاثية", "الأحقاف", "محمد", "الفتح", "الحجرات", "ق", "الذاريات",
//       "الطور", "النجم", "القمر", "الرحمن", "الواقعة", "الحديد", "المجادلة", "الحشر",
//       "الممتحنة", "الصف", "الجمعة", "المنافقون", "التغابن", "الطلاق", "التحريم", "الملك",
//       "القلم", "الحاقة", "المعارج", "نوح", "الجن", "المزمل", "المدثر", "القيامة",
//       "الانسان", "المرسلات", "النبإ", "النازعات", "عبس", "التكوير", "الإنفطار",
//       "المطففين", "الإنشقاق", "البروج", "الطارق", "الأعلى", "الغاشية", "الفجر",
//       "البلد", "الشمس", "الليل", "الضحى", "الشرح", "التين", "العلق", "القدر", "البينة",
//       "الزلزلة", "العاديات", "القارعة", "التكاثر", "العصر", "الهمزة", "الفيل", "قريش",
//       "الماعون", "الكوثر", "الكافرون", "النصر", "المسد", "الإخلاص", "الفلق", "الناس"
//     ];

//     final Set<String> surahNames =
//         jsonData.values.map((e) => e['surah'].toString().trim()).toSet();

//     final ordered = quranOrder.where((name) => surahNames.contains(name)).toList();

//     setState(() {
//       _allSurahs = ordered;
//       _selectedSurahs = List.from(ordered);
//     });
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       bottomNavigationBar: _buildStartBar(context),
//       body: Directionality(
//         textDirection: L10nSimple.textDir(_lang),
//         child: Container(
//           decoration: BoxDecoration(
//             gradient: LinearGradient(
//               colors: [Colors.green.shade700, Colors.yellow.shade200],
//               begin: Alignment.topCenter,
//               end: Alignment.bottomCenter,
//             ),
//           ),
//           child: SafeArea(
//             child: SingleChildScrollView(
//               padding: const EdgeInsets.fromLTRB(16, 16, 16, 120),
//               child: Column(
//                 crossAxisAlignment: CrossAxisAlignment.stretch,
//                 children: [
//                   const SizedBox(height: 8),

//                   // Language switch
//                   Align(
//                     alignment: AlignmentDirectional.topEnd,
//                     child: Container(
//                       padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
//                       decoration: BoxDecoration(
//                         color: Colors.black.withOpacity(0.08),
//                         borderRadius: BorderRadius.circular(8),
//                       ),
//                       child: DropdownButtonHideUnderline(
//                         child: DropdownButton<String>(
//                           value: _lang,
//                           icon: const Icon(Icons.language),
//                           onChanged: (v) {
//                             final scope = LangScope.of(context);
//                             scope.onChange?.call(v ?? 'ar');
//                             setState(() {}); // rebuild localized labels
//                           },
//                           items: const [
//                             DropdownMenuItem(value: 'ar', child: Text('العربية')),
//                             DropdownMenuItem(value: 'en', child: Text('English')),
//                           ],
//                         ),
//                       ),
//                     ),
//                   ),

//                   const SizedBox(height: 12),

//                   // Reciter picker (shows only the localized name)
//                   ElevatedButton.icon(
//                     icon: const Icon(Icons.record_voice_over),
//                     style: ElevatedButton.styleFrom(
//                       backgroundColor: Colors.white.withOpacity(0.95),
//                       foregroundColor: Colors.black87,
//                       padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 12),
//                       shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
//                       elevation: 0,
//                     ),
//                     onPressed: _openReciterPicker,
//                     label: Row(
//                       children: [
//                         Expanded(
//                           child: Text(
//                             _selectedReciter.localizedName(_lang),
//                             overflow: TextOverflow.ellipsis,
//                             textAlign: TextAlign.center,
//                             style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
//                           ),
//                         ),
//                         const Icon(Icons.expand_more),
//                       ],
//                     ),
//                   ),

//                   const SizedBox(height: 12),

//                   // Surah selector button
//                   ElevatedButton.icon(
//                     icon: const Icon(Icons.menu_book),
//                     style: ElevatedButton.styleFrom(
//                       backgroundColor: Colors.blueAccent,
//                       padding: const EdgeInsets.symmetric(vertical: 16),
//                       shape: RoundedRectangleBorder(
//                         borderRadius: BorderRadius.circular(12),
//                       ),
//                     ),
//                     onPressed: _openSurahSelector,
//                     label: Text(
//                       _surahHeaderText(),
//                       overflow: TextOverflow.ellipsis,
//                       style: const TextStyle(
//                         fontSize: 20,
//                         fontWeight: FontWeight.bold,
//                         color: Colors.white,
//                       ),
//                     ),
//                   ),

//                   const SizedBox(height: 20),

//                   _buildNumberInput(t('repeatCount'), _repeatCount, 1, 100,
//                       (val) => setState(() => _repeatCount = val)),
//                   const SizedBox(height: 12),
//                   _buildNumberInput(t('ayahsAfter'), _ayahsAfter, 0, 10,
//                       (val) => setState(() => _ayahsAfter = val)),
//                   const SizedBox(height: 12),
//                   _buildNumberInput(t('examDurationMinutes'), _recitationDelay, 1, 10,
//                       (val) => setState(() => _recitationDelay = val)),
//                 ],
//               ),
//             ),
//           ),
//         ),
//       ),
//     );
//   }

//   Widget _buildNumberInput(
//       String label, int value, int min, int max, Function(int) onChanged) {
//     return Container(
//       padding: const EdgeInsets.all(12),
//       decoration: BoxDecoration(
//         color: Colors.white.withOpacity(0.95),
//         borderRadius: BorderRadius.circular(12),
//         boxShadow: const [
//           BoxShadow(color: Color(0x14000000), blurRadius: 8, offset: Offset(0, 2))
//         ],
//       ),
//       child: Column(
//         children: [
//           Text(label, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
//           const SizedBox(height: 8),
//           SizedBox(
//             width: 160,
//             child: SpinBox(
//               min: min.toDouble(),
//               max: max.toDouble(),
//               value: value.toDouble(),
//               step: 1,
//               decimals: 0,
//               textStyle: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
//               onChanged: (val) => onChanged(val.toInt()),
//             ),
//           ),
//         ],
//       ),
//     );
//   }

//   Widget _buildStartBar(BuildContext context) {
//     final lang = _lang;
//     String t(String k) => L10nSimple.t(lang, k);
//     return SafeArea(
//       top: false,
//       child: Container(
//         decoration: const BoxDecoration(
//           color: Colors.white,
//           boxShadow: [BoxShadow(color: Color(0x1F000000), blurRadius: 12, offset: Offset(0, -3))],
//         ),
//         padding: const EdgeInsets.fromLTRB(16, 10, 16, 16),
//         child: SizedBox(
//           width: double.infinity,
//           height: 56,
//           child: ElevatedButton(
//             style: ElevatedButton.styleFrom(
//               backgroundColor: const Color(0xFF22C55E),
//               foregroundColor: Colors.white,
//               elevation: 0,
//               shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
//             ),
//             onPressed: _onStartPressed,
//             child: Text(t('startQuiz'),
//                 style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w700)),
//           ),
//         ),
//       ),
//     );
//   }

//   void _onStartPressed() {
//     if (_selectedSurahs.isEmpty) {
//       ScaffoldMessenger.of(context).showSnackBar(
//         SnackBar(content: Text(t('pleaseSelectAtLeastOne'))),
//       );
//       return;
//     }
//     Navigator.push(
//       context,
//       MaterialPageRoute(
//         builder: (_) => PlayPage(
//           repeatCount: _repeatCount,
//           ayahsAfter: _ayahsAfter,
//           delaySeconds: _recitationDelay,
//           selectedSurahs: _selectedSurahs.isEmpty ? _allSurahs : _selectedSurahs,
//           reciterKey: _selectedReciter.key,
//           reciterUrl: _selectedReciter.url,
//         ),
//       ),
//     );
//   }

//   /// --------------------------- Pickers -------------------------------------

//   Future<void> _openReciterPicker() async {
//     await showModalBottomSheet(
//       context: context,
//       isScrollControlled: true,
//       backgroundColor: Colors.transparent,
//       builder: (context) {
//         String query = '';
//         Reciter current = _selectedReciter;

//         return StatefulBuilder(
//           builder: (context, setSB) {
//             final filtered = _reciters.where((r) {
//               final n = r.localizedName(_lang).toLowerCase();
//               return n.contains(query.toLowerCase());
//             }).toList();

//             return Container(
//               height: MediaQuery.of(context).size.height * 0.85,
//               decoration: const BoxDecoration(
//                 color: Colors.white,
//                 borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
//               ),
//               child: Column(
//                 children: [
//                   const SizedBox(height: 8),
//                   Container(
//                     width: 48, height: 5,
//                     decoration: BoxDecoration(
//                       color: Colors.grey.shade300,
//                       borderRadius: BorderRadius.circular(3),
//                     ),
//                   ),
//                   const SizedBox(height: 12),
//                   Padding(
//                     padding: const EdgeInsets.symmetric(horizontal: 16),
//                     child: TextField(
//                       decoration: InputDecoration(
//                         hintText: _lang == 'ar' ? 'ابحث عن قارئ' : 'Search reciter',
//                         prefixIcon: const Icon(Icons.search),
//                         border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
//                         filled: true,
//                         fillColor: Colors.grey[100],
//                         contentPadding: const EdgeInsets.symmetric(vertical: 10, horizontal: 12),
//                       ),
//                       onChanged: (v) => setSB(() => query = v),
//                     ),
//                   ),
//                   const SizedBox(height: 8),
//                   Expanded(
//                     child: ListView.separated(
//                       itemCount: filtered.length,
//                       separatorBuilder: (_, __) => const Divider(height: 1),
//                       itemBuilder: (context, i) {
//                         final r = filtered[i];
//                         final selected = r.key == current.key;
//                         return ListTile(
//                           title: Text(
//                             r.localizedName(_lang),
//                             textAlign: TextAlign.center,
//                             style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
//                           ),
//                           trailing: selected ? const Icon(Icons.check, color: Colors.green) : null,
//                           onTap: () => setSB(() => current = r),
//                         );
//                       },
//                     ),
//                   ),
//                   Padding(
//                     padding: const EdgeInsets.all(12),
//                     child: Row(
//                       children: [
//                         Expanded(
//                           child: OutlinedButton(
//                             onPressed: () => Navigator.pop(context),
//                             child: Text(_lang == 'ar' ? 'إلغاء' : 'Cancel'),
//                           ),
//                         ),
//                         const SizedBox(width: 10),
//                         Expanded(
//                           child: ElevatedButton(
//                             style: ElevatedButton.styleFrom(backgroundColor: Colors.blueAccent),
//                             onPressed: () {
//                               setState(() => _selectedReciter = current);
//                               Navigator.pop(context);
//                             },
//                             child: Text(_lang == 'ar' ? 'اختيار' : 'Choose'),
//                           ),
//                         ),
//                       ],
//                     ),
//                   ),
//                 ],
//               ),
//             );
//           },
//         );
//       },
//     );
//     setState(() {}); // refresh button text
//   }

//   void _openSurahSelector() async {
//     bool? updated = await showModalBottomSheet<bool>(
//       context: context,
//       isScrollControlled: true,
//       backgroundColor: Colors.transparent,
//       builder: (context) {
//         return StatefulBuilder(
//           builder: (context, setStateSB) {
//             final filteredSurahs = _allSurahs
//                 .where((s) => _displayName(s).toLowerCase().contains(_searchQuery.toLowerCase()))
//                 .toList();

//             return Container(
//               height: MediaQuery.of(context).size.height * 0.85,
//               decoration: const BoxDecoration(
//                 color: Colors.white,
//                 borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
//               ),
//               child: Column(
//                 children: [
//                   const SizedBox(height: 8),
//                   Container(
//                     width: 48, height: 5,
//                     decoration: BoxDecoration(
//                       color: Colors.grey.shade300,
//                       borderRadius: BorderRadius.circular(3),
//                     ),
//                   ),
//                   const SizedBox(height: 12),
//                   Padding(
//                     padding: const EdgeInsets.symmetric(horizontal: 16),
//                     child: TextField(
//                       decoration: InputDecoration(
//                         hintText: t('searchHint'),
//                         prefixIcon: const Icon(Icons.search),
//                         border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
//                         filled: true,
//                         fillColor: Colors.grey[100],
//                         contentPadding: const EdgeInsets.symmetric(vertical: 10, horizontal: 12),
//                       ),
//                       onChanged: (val) => setStateSB(() => _searchQuery = val),
//                     ),
//                   ),
//                   const SizedBox(height: 8),
//                   Padding(
//                     padding: const EdgeInsets.symmetric(horizontal: 12),
//                     child: Row(
//                       children: [
//                         FilterChip(
//                           label: Text("${t('selectedSurahs')} ${L10nSimple.digits(_lang, _selectedSurahs.length)}"),
//                           onSelected: (_) {},
//                         ),
//                         const Spacer(),
//                         TextButton.icon(
//                           onPressed: () => setStateSB(() => _selectedSurahs = List.from(_allSurahs)),
//                           icon: const Icon(Icons.done_all),
//                           label: Text(t('selectAll')),
//                         ),
//                         const SizedBox(width: 6),
//                         TextButton.icon(
//                           onPressed: () => setStateSB(() => _selectedSurahs.clear()),
//                           icon: const Icon(Icons.clear_all),
//                           label: Text(t('clearAll')),
//                         ),
//                       ],
//                     ),
//                   ),
//                   const Divider(height: 1),
//                   Expanded(
//                     child: ListView.builder(
//                       itemCount: filteredSurahs.length,
//                       itemBuilder: (context, index) {
//                         final surah = filteredSurahs[index];
//                         final selected = _selectedSurahs.contains(surah);
//                         return CheckboxListTile(
//                           value: selected,
//                           title: Text(
//                             _displayName(surah),
//                             textAlign: TextAlign.center,
//                             style: const TextStyle(fontSize: 18),
//                           ),
//                           onChanged: (checked) {
//                             setStateSB(() {
//                               if (checked == true) {
//                                 _selectedSurahs.add(surah);
//                               } else {
//                                 _selectedSurahs.remove(surah);
//                               }
//                             });
//                           },
//                           controlAffinity: ListTileControlAffinity.leading,
//                         );
//                       },
//                     ),
//                   ),
//                   Padding(
//                     padding: const EdgeInsets.all(12),
//                     child: ElevatedButton(
//                       onPressed: () => Navigator.pop(context, true),
//                       style: ElevatedButton.styleFrom(
//                         padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 12),
//                         backgroundColor: Colors.blueAccent,
//                         foregroundColor: Colors.white,
//                         shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
//                       ),
//                       child: Text(t('done'), style: const TextStyle(fontSize: 18)),
//                     ),
//                   ),
//                 ],
//               ),
//             );
//           },
//         );
//       },
//     );

//     if (updated == true) setState(() {});
//   }
// }











// import 'package:flutter/material.dart';
// import 'package:flutter/services.dart';
// import 'dart:convert';
// import 'package:flutter_spinbox/flutter_spinbox.dart';
// import 'main.dart'; // for PlayPage
// import 'l10n_simple.dart';

// /// ===== Reciter model + predefined EveryAyah folders =====
// class Reciter {
//   final String key;   // EveryAyah folder name
//   final String name;  // Display name
//   const Reciter(this.key, this.name);
//   String get url => 'https://everyayah.com/data/$key';
// }

// // Popular EveryAyah folders (you can add more)
// const List<Reciter> kReciters = [
//   Reciter('Abdurrahmaan_As-Sudais_192kbps', 'Abdurrahmaan As‑Sudais (192 kbps)'),
//   Reciter('MisharyRashidAlafasy_64kbps',   'Mishary Rashid Alafasy (64 kbps)'),
//   Reciter('MaherAlMuaiqly_64kbps',         'Maher Al‑Muaiqly (64 kbps)'),
//   Reciter('Husary_128kbps',                'Mahmoud Khalil Al‑Husary (128 kbps)'),
//   Reciter('Abdul_Basit_Mujawwad_128kbps',  'Abdul Basit – Mujawwad (128 kbps)'),
// ];

// class SettingsPage extends StatefulWidget {
//   const SettingsPage({Key? key}) : super(key: key);

//   @override
//   _SettingsPageState createState() => _SettingsPageState();
// }

// class _SettingsPageState extends State<SettingsPage> {
//   // English names for the 114 surahs, keyed by Arabic canonical names.
//   static const Map<String, String> kSurahNameEn = {
//     "الفاتحة": "Al Fatihah",
//     "البقرة": "Al Baqara",
//     "آل عمران": "Al Imran",
//     "النساء": "An Nisa",
//     "المائدة": "Al Maida",
//     "الأنعام": "Al Anam",
//     "الأعراف": "Al Araf",
//     "الأنفال": "Al Anfal",
//     "التوبة": "At Tauba / Baraat",
//     "يونس": "Yunus",
//     "هود": "Hud",
//     "يوسف": "Yusuf",
//     "الرعد": "Ar Rad",
//     "ابراهيم": "Ibrahim",
//     "الحجر": "Al Hijr",
//     "النحل": "An Nahl",
//     "الإسراء": "Al Isra",
//     "الكهف": "Al Kahf",
//     "مريم": "Maryam",
//     "طه": "Ta Ha",
//     "الأنبياء": "Al Anbiya",
//     "الحج": "Al Hajj",
//     "المؤمنون": "Al Muminun",
//     "النور": "An Nur",
//     "الفرقان": "Al Furqan",
//     "الشعراء": "Ash Shuara",
//     "النمل": "An Naml",
//     "القصص": "Al Qasas",
//     "العنكبوت": "Al Ankabut",
//     "الروم": "Ar Rum",
//     "لقمان": "Luqman",
//     "السجدة": "As Sajda",
//     "الأحزاب": "Al Ahzab",
//     "سبإ": "Saba",
//     "فاطر": "Fatir",
//     "يس": "Ya Sin",
//     "الصافات": "As Saffat",
//     "ص": "Sad",
//     "الزمر": "Az Zumar",
//     "غافر": "Ghafir",
//     "فصلت": "Fussilat",
//     "الشورى": "Ash Shura",
//     "الزخرف": "Az Zukhruf",
//     "الدخان": "Ad Dukhan",
//     "الجاثية": "Al Jathiyah",
//     "الأحقاف": "Al Ahqaf",
//     "محمد": "Muhammad",
//     "الفتح": "Al Fath",
//     "الحجرات": "Al Hujurat",
//     "ق": "Qaf",
//     "الذاريات": "Adh Dhariyat",
//     "الطور": "At Tur",
//     "النجم": "An Najm",
//     "القمر": "Al Qamar",
//     "الرحمن": "Ar Rahman",
//     "الواقعة": "Al Waqia",
//     "الحديد": "Al Hadid",
//     "المجادلة": "Al Mujadila",
//     "الحشر": "Al Hashr",
//     "الممتحنة": "Al Mumtahana",
//     "الصف": "As Saff",
//     "الجمعة": "Al Jumuah",
//     "المنافقون": "Al Munafiqun",
//     "التغابن": "At Taghabun",
//     "الطلاق": "At Talaq",
//     "التحريم": "At Tahrim",
//     "الملك": "Al Mulk",
//     "القلم": "Al Qalam",
//     "الحاقة": "Al Haqqah",
//     "المعارج": "Al Maarij",
//     "نوح": "Nuh",
//     "الجن": "Al Jinn",
//     "المزمل": "Al Muzzammil",
//     "المدثر": "Al Muddathir",
//     "القيامة": "Al Qiyamah",
//     "الانسان": "Al Insan",
//     "المرسلات": "Al Mursalat",
//     "النبإ": "An Naba",
//     "النازعات": "An Naziat",
//     "عبس": "Abasa",
//     "التكوير": "At Takwir",
//     "الإنفطار": "Al Infitar",
//     "المطففين": "Al Mutaffifin",
//     "الإنشقاق": "Al Inshiqaq",
//     "البروج": "Al Buruj",
//     "الطارق": "At Tariq",
//     "الأعلى": "Al Ala",
//     "الغاشية": "Al Ghashiyah",
//     "الفجر": "Al Fajr",
//     "البلد": "Al Balad",
//     "الشمس": "Ash Shams",
//     "الليل": "Al Layl",
//     "الضحى": "Ad Duhaa",
//     "الشرح": "Ash Sharh",
//     "التين": "At Tin",
//     "العلق": "Al Alaq",
//     "القدر": "Al Qadr",
//     "البينة": "Al Bayyinah",
//     "الزلزلة": "Az Zalzalah",
//     "العاديات": "Al Adiyat",
//     "القارعة": "Al Qariah",
//     "التكاثر": "At Takathur",
//     "العصر": "Al Asr",
//     "الهمزة": "Al Humazah",
//     "الفيل": "Al Fil",
//     "قريش": "Quraish",
//     "الماعون": "Al Maun",
//     "الكوثر": "Al Kawthar",
//     "الكافرون": "Al Kafirun",
//     "النصر": "An Nasr",
//     "المسد": "Al Masad",
//     "الإخلاص": "Al Ikhlas",
//     "الفلق": "Al Falaq",
//     "الناس": "An Nas",
//   };

//   int _repeatCount = 3;
//   int _ayahsAfter = 2;
//   int _recitationDelay = 5;
//   List<String> _selectedSurahs = [];
//   List<String> _allSurahs = [];
//   String _searchQuery = "";

//   // Language from scope
//   String get _lang {
//     try {
//       return LangScope.of(context).lang;
//     } catch (e) {
//       return 'ar';
//     }
//   }

//   // NEW: selected reciter
//   Reciter _selectedReciter = kReciters.first;

//   String t(String k) => L10nSimple.t(_lang, k);

//   String _displayName(String ar) {
//     return _lang == 'en' ? (kSurahNameEn[ar] ?? ar) : ar;
//   }

//   String _surahHeaderText() {
//     if (_selectedSurahs.isEmpty) {
//       return "📖 ${t('pickSurahs')}";
//     } else {
//       return "📖 ${t('selectedSurahs')} (${L10nSimple.digits(_lang, _selectedSurahs.length)})";
//     }
//   }

//   @override
//   void initState() {
//     super.initState();
//     _loadSurahs();
//   }

//   Future<void> _loadSurahs() async {
//     final jsonString = await rootBundle.loadString('assets/ayah_texts.json');
//     final Map<String, dynamic> jsonData = json.decode(jsonString);

//     final List<String> quranOrder = [
//       "الفاتحة", "البقرة", "آل عمران", "النساء", "المائدة", "الأنعام", "الأعراف",
//       "الأنفال", "التوبة", "يونس", "هود", "يوسف", "الرعد", "ابراهيم", "الحجر", "النحل",
//       "الإسراء", "الكهف", "مريم", "طه", "الأنبياء", "الحج", "المؤمنون", "النور", "الفرقان",
//       "الشعراء", "النمل", "القصص", "العنكبوت", "الروم", "لقمان", "السجدة", "الأحزاب",
//       "سبإ", "فاطر", "يس", "الصافات", "ص", "الزمر", "غافر", "فصلت", "الشورى", "الزخرف",
//       "الدخان", "الجاثية", "الأحقاف", "محمد", "الفتح", "الحجرات", "ق", "الذاريات",
//       "الطور", "النجم", "القمر", "الرحمن", "الواقعة", "الحديد", "المجادلة", "الحشر",
//       "الممتحنة", "الصف", "الجمعة", "المنافقون", "التغابن", "الطلاق", "التحريم", "الملك",
//       "القلم", "الحاقة", "المعارج", "نوح", "الجن", "المزمل", "المدثر", "القيامة",
//       "الانسان", "المرسلات", "النبإ", "النازعات", "عبس", "التكوير", "الإنفطار",
//       "المطففين", "الإنشقاق", "البروج", "الطارق", "الأعلى", "الغاشية", "الفجر",
//       "البلد", "الشمس", "الليل", "الضحى", "الشرح", "التين", "العلق", "القدر", "البينة",
//       "الزلزلة", "العاديات", "القارعة", "التكاثر", "العصر", "الهمزة", "الفيل", "قريش",
//       "الماعون", "الكوثر", "الكافرون", "النصر", "المسد", "الإخلاص", "الفلق", "الناس"
//     ];

//     final Set<String> surahNames = jsonData.values
//         .map((e) => e['surah'].toString().trim())
//         .toSet();

//     final ordered = quranOrder.where((name) => surahNames.contains(name)).toList();

//     setState(() {
//       _allSurahs = ordered;
//       _selectedSurahs = List.from(ordered);
//     });
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       bottomNavigationBar: _buildStartBar(context),
//       body: Directionality(
//         textDirection: L10nSimple.textDir(_lang),
//         child: Container(
//           decoration: BoxDecoration(
//             gradient: LinearGradient(
//               colors: [Colors.green.shade700, Colors.yellow.shade200],
//               begin: Alignment.topCenter,
//               end: Alignment.bottomCenter,
//             ),
//           ),
//           child: SafeArea(
//             child: SingleChildScrollView(
//               padding: const EdgeInsets.fromLTRB(16, 16, 16, 120),
//               child: Column(
//                 crossAxisAlignment: CrossAxisAlignment.stretch,
//                 children: [
//                   const SizedBox(height: 8),
//                   // Language dropdown (kept as-is)
//                   Align(
//                     alignment: AlignmentDirectional.topEnd,
//                     child: Container(
//                       padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
//                       decoration: BoxDecoration(
//                         color: Colors.black.withOpacity(0.08),
//                         borderRadius: BorderRadius.circular(8),
//                       ),
//                       child: DropdownButtonHideUnderline(
//                         child: DropdownButton<String>(
//                           value: _lang,
//                           icon: const Icon(Icons.language),
//                           onChanged: (v) {
//                             final scope = LangScope.of(context);
//                             scope.onChange?.call(v ?? 'ar');
//                             setState(() {}); // rebuild for language-dependent labels
//                           },
//                           items: const [
//                             DropdownMenuItem(value: 'ar', child: Text('العربية')),
//                             DropdownMenuItem(value: 'en', child: Text('English')),
//                           ],
//                         ),
//                       ),
//                     ),
//                   ),

//                   const SizedBox(height: 12),

//                   /// ===== NEW: Reciter dropdown (EveryAyah) =====
//                   Container(
//                     padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
//                     decoration: BoxDecoration(
//                       color: Colors.black.withOpacity(0.08),
//                       borderRadius: BorderRadius.circular(8),
//                     ),
//                     child: DropdownButtonHideUnderline(
//                       child: DropdownButton<Reciter>(
//                         value: _selectedReciter,
//                         icon: const Icon(Icons.record_voice_over),
//                         isExpanded: true,
//                         onChanged: (r) => setState(() {
//                           if (r != null) _selectedReciter = r;
//                         }),
//                         items: kReciters
//                             .map((r) => DropdownMenuItem(
//                                   value: r,
//                                   child: Text(
//                                     // Show English label regardless of UI lang; change if you want localized names.
//                                     _lang == 'ar' ? 'القارئ: ${r.name}' : 'Reciter: ${r.name}',
//                                     overflow: TextOverflow.ellipsis,
//                                   ),
//                                 ))
//                             .toList(),
//                       ),
//                     ),
//                   ),

//                   const SizedBox(height: 12),

//                   // Surah selector button
//                   ElevatedButton.icon(
//                     icon: const Icon(Icons.menu_book),
//                     style: ElevatedButton.styleFrom(
//                       backgroundColor: Colors.blueAccent,
//                       padding: const EdgeInsets.symmetric(vertical: 16),
//                       shape: RoundedRectangleBorder(
//                         borderRadius: BorderRadius.circular(12),
//                       ),
//                     ),
//                     onPressed: _openSurahSelector,
//                     label: Text(
//                       _surahHeaderText(),
//                       overflow: TextOverflow.ellipsis,
//                       style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white),
//                     ),
//                   ),

//                   const SizedBox(height: 20),

//                   _buildNumberInput(t('repeatCount'), _repeatCount, 1, 100, (val) => setState(() => _repeatCount = val)),
//                   const SizedBox(height: 12),
//                   _buildNumberInput(t('ayahsAfter'), _ayahsAfter, 0, 10, (val) => setState(() => _ayahsAfter = val)),
//                   const SizedBox(height: 12),
//                   _buildNumberInput(t('examDurationMinutes'), _recitationDelay, 1, 10, (val) => setState(() => _recitationDelay = val)),
//                 ],
//               ),
//             ),
//           ),
//         ),
//       ),
//     );
//   }

//   Widget _buildNumberInput(String label, int value, int min, int max, Function(int) onChanged) {
//     return Container(
//       padding: const EdgeInsets.all(12),
//       decoration: BoxDecoration(
//         color: Colors.white.withOpacity(0.95),
//         borderRadius: BorderRadius.circular(12),
//         boxShadow: const [BoxShadow(color: Color(0x14000000), blurRadius: 8, offset: Offset(0, 2))],
//       ),
//       child: Column(
//         children: [
//           Text(label, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
//           const SizedBox(height: 8),
//           SizedBox(
//             width: 160,
//             child: SpinBox(
//               min: min.toDouble(),
//               max: max.toDouble(),
//               value: value.toDouble(),
//               step: 1,
//               decimals: 0,
//               textStyle: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
//               onChanged: (val) => onChanged(val.toInt()),
//             ),
//           ),
//         ],
//       ),
//     );
//   }

//   Widget _buildStartBar(BuildContext context) {
//     final lang = _lang;
//     String t(String k) => L10nSimple.t(lang, k);
//     return SafeArea(
//       top: false,
//       child: Container(
//         decoration: const BoxDecoration(
//           color: Colors.white,
//           boxShadow: [BoxShadow(color: Color(0x1F000000), blurRadius: 12, offset: Offset(0, -3))],
//         ),
//         padding: const EdgeInsets.fromLTRB(16, 10, 16, 16),
//         child: SizedBox(
//           width: double.infinity,
//           height: 56,
//           child: ElevatedButton(
//             style: ElevatedButton.styleFrom(
//               backgroundColor: const Color(0xFF22C55E),
//               foregroundColor: Colors.white,
//               elevation: 0,
//               shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
//             ),
//             onPressed: _onStartPressed,
//             child: Text(t('startQuiz'), style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w700)),
//           ),
//         ),
//       ),
//     );
//   }

//   void _onStartPressed() {
//     final lang = _lang;
//     String t(String k) => L10nSimple.t(lang, k);
//     if (_selectedSurahs.isEmpty) {
//       ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(t('pleaseSelectAtLeastOne'))));
//       return;
//     }
//     Navigator.push(
//       context,
//       MaterialPageRoute(
//         builder: (_) => PlayPage(
//           repeatCount: _repeatCount,
//           ayahsAfter: _ayahsAfter,
//           delaySeconds: _recitationDelay,
//           selectedSurahs: _selectedSurahs.isEmpty ? _allSurahs : _selectedSurahs,
//           // NEW: pass reciter choice to the player
//           reciterKey: _selectedReciter.key,
//           reciterUrl: _selectedReciter.url,
//         ),
//       ),
//     );
//   }

//   void _openSurahSelector() async {
//     bool? updated = await showModalBottomSheet<bool>(
//       context: context,
//       isScrollControlled: true,
//       backgroundColor: Colors.transparent,
//       builder: (context) {
//         return StatefulBuilder(
//           builder: (context, setStateSB) {
//             final filteredSurahs = _allSurahs.where(
//               (s) => _displayName(s).toLowerCase().contains(_searchQuery.toLowerCase()),
//             ).toList();
//             return Container(
//               height: MediaQuery.of(context).size.height * 0.85,
//               decoration: const BoxDecoration(
//                 color: Colors.white,
//                 borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
//               ),
//               child: Column(
//                 children: [
//                   const SizedBox(height: 8),
//                   Container(
//                     width: 48,
//                     height: 5,
//                     decoration: BoxDecoration(
//                       color: Colors.grey.shade300,
//                       borderRadius: BorderRadius.circular(3),
//                     ),
//                   ),
//                   const SizedBox(height: 12),
//                   Padding(
//                     padding: const EdgeInsets.symmetric(horizontal: 16),
//                     child: TextField(
//                       decoration: InputDecoration(
//                         hintText: t('searchHint'),
//                         prefixIcon: const Icon(Icons.search),
//                         border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
//                         filled: true,
//                         fillColor: Colors.grey[100],
//                         contentPadding: const EdgeInsets.symmetric(vertical: 10, horizontal: 12),
//                       ),
//                       onChanged: (val) => setStateSB(() => _searchQuery = val),
//                     ),
//                   ),
//                   const SizedBox(height: 8),
//                   Padding(
//                     padding: const EdgeInsets.symmetric(horizontal: 12),
//                     child: Row(
//                       children: [
//                         FilterChip(
//                           label: Text("${t('selectedSurahs')} ${L10nSimple.digits(_lang, _selectedSurahs.length)}"),
//                           onSelected: (_) {},
//                         ),
//                         const Spacer(),
//                         TextButton.icon(
//                           onPressed: () => setStateSB(() => _selectedSurahs = List.from(_allSurahs)),
//                           icon: const Icon(Icons.done_all),
//                           label: Text(t('selectAll')),
//                         ),
//                         const SizedBox(width: 6),
//                         TextButton.icon(
//                           onPressed: () => setStateSB(() => _selectedSurahs.clear()),
//                           icon: const Icon(Icons.clear_all),
//                           label: Text(t('clearAll')),
//                         ),
//                       ],
//                     ),
//                   ),
//                   const Divider(height: 1),
//                   Expanded(
//                     child: ListView.builder(
//                       itemCount: filteredSurahs.length,
//                       itemBuilder: (context, index) {
//                         final surah = filteredSurahs[index];
//                         final selected = _selectedSurahs.contains(surah);
//                         return CheckboxListTile(
//                           value: selected,
//                           title: Text(_displayName(surah), textAlign: TextAlign.center, style: const TextStyle(fontSize: 18)),
//                           onChanged: (checked) {
//                             setStateSB(() {
//                               if (checked == true) {
//                                 _selectedSurahs.add(surah);
//                               } else {
//                                 _selectedSurahs.remove(surah);
//                               }
//                             });
//                           },
//                           controlAffinity: ListTileControlAffinity.leading,
//                         );
//                       },
//                     ),
//                   ),
//                   Padding(
//                     padding: const EdgeInsets.all(12),
//                     child: ElevatedButton(
//                       onPressed: () => Navigator.pop(context, true),
//                       style: ElevatedButton.styleFrom(
//                         padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 12),
//                         backgroundColor: Colors.blueAccent,
//                         foregroundColor: Colors.white,
//                         shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
//                       ),
//                       child: Text(t('done'), style: const TextStyle(fontSize: 18)),
//                     ),
//                   ),
//                 ],
//               ),
//             );
//           },
//         );
//       },
//     );

//     if (updated == true) {
//       setState(() {});
//     }
//   }
// }


// above work