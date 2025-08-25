
import 'package:flutter/widgets.dart';

class L10nSimple {
  L10nSimple._();
  static final supported = const ['en','ar'];

  static final Map<String, Map<String, String>> _t = {
    'en': {
      'appTitle': 'Quran Player',
      'settings': 'Settings',
      'startQuiz': 'Start',
      'saveSettings': 'Save Settings',
      'repeatCount': 'Question repeat count',
      'ayahsAfter': 'Answer ayahs count',
      'recitationDelay': 'Delay (seconds)',
      'selectedSurahs': 'Selected surahs',
      'language': 'Language',
      'arabic': 'Arabic',
      'english': 'English',
      'allSurahs': 'All surahs',
      'pleaseSelectAtLeastOne': 'Please select at least one surah',
      'selectAll': 'Select all',
      'clearAll': 'Clear all',
      'pickSurahs': 'Pick surahs',
      'searchHint': 'Search a surah',

      'examDurationMinutes': 'Exam duration (minutes)',
      'showAnswer': 'Show Answer',
      'skipQuestion': 'Skip Question',
      'playing': 'Playing',
      'paused': 'Paused',
      'countdown': 'Countdown',
      'finished': 'Finished',
      'hasbuk': 'Hasbuk',
      'nextQuestion': 'Next question',
      'pause': 'Pause',
      'resume': 'Resume',
      'newQuiz': 'New round',
      'surah': 'Surah',
      'ayah': 'Ayah',

    },
    'ar': {
      'appTitle': 'مشغل القرآن',
      'settings': 'الإعدادات',
      'startQuiz': 'ابدأ',
      'saveSettings': 'حفظ الإعدادات',
      'repeatCount': 'عدد تكرار السؤال',
      'ayahsAfter': 'عدد آيات الإجابة',
      'recitationDelay': 'مهلة القراءة (ثوانٍ)',
      'selectedSurahs': 'السور المختارة',
      'language': 'اللغة',
      'arabic': 'العربية',
      'english': 'الإنجليزية',
      'allSurahs': 'جميع السور',
      'pleaseSelectAtLeastOne': 'يرجى اختيار سورة واحدة على الأقل',
      'selectAll': 'تحديد الكل',
      'clearAll': 'مسح الكل',
      'pickSurahs': 'اختر السور',
      'searchHint': '🔍 ابحث عن سورة',

      'examDurationMinutes': 'مدة الاختبار (بالدقائق)',
      'showAnswer': 'عرض الإجابة',
      'skipQuestion': 'تخطي السؤال',
      'playing': 'تشغيل',
      'paused': 'إيقاف مؤقت',
      'countdown': 'العد التنازلي',
      'finished': 'انتهى',
      'hasbuk': 'حسبك',
      'nextQuestion': 'السؤال التالي',
      'pause': 'إيقاف مؤقت',
      'resume': 'تكملة المسابقة',
      'newQuiz': 'مسابقة جديدة',
      'surah': 'سورة',
      'ayah': 'الآية',

    },
  };

  static String t(String lang, String key) {
    final m = _t[lang] ?? _t['en']!;
    return m[key] ?? _t['en']![key] ?? key;
  }

  static TextDirection textDir(String lang) =>
      lang == 'ar' ? TextDirection.rtl : TextDirection.ltr;

  static String digits(String lang, Object number) {
    final s = number.toString();
    if (lang != 'ar') return s;
    const arabicDigits = ['٠','١','٢','٣','٤','٥','٦','٧','٨','٩'];
    final buf = StringBuffer();
    for (final ch in s.runes) {
      final c = String.fromCharCode(ch);
      final d = int.tryParse(c);
      if (d != null) {
        buf.write(arabicDigits[d]);
      } else {
        buf.write(c);
      }
    }
    return buf.toString();
  }
}

/// A tiny inherited widget to hold current language string.
class LangScope extends InheritedWidget {
  final String lang;
  final void Function(String lang)? onChange;

  const LangScope({
    super.key,
    required this.lang,
    this.onChange,
    required Widget child,
  }) : super(child: child);

  static LangScope of(BuildContext context) {
    final s = context.dependOnInheritedWidgetOfExactType<LangScope>();
    assert(s != null, 'LangScope not found in widget tree.');
    return s!;
  }

  @override
  bool updateShouldNotify(LangScope oldWidget) => lang != oldWidget.lang;
}
