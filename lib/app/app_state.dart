import 'package:flutter/material.dart';

enum WeekStart { sunday, monday }

class AppState extends ChangeNotifier {
  static const supportedLocales = <Locale>[
    Locale('fr'),
    Locale('ar'),
    Locale('en'),
  ];

  Locale? _locale;
  WeekStart _weekStart = WeekStart.sunday;

  Locale? get locale => _locale;
  WeekStart get weekStart => _weekStart;

  void setLocale(Locale? locale) {
    _locale = locale;
    notifyListeners();
  }

  void setLocaleByCode(String code) {
    setLocale(Locale(code));
  }

  void setWeekStart(WeekStart v) {
    _weekStart = v;
    notifyListeners();
  }
}
