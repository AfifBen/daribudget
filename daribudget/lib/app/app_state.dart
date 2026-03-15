import 'package:flutter/material.dart';

class AppState extends ChangeNotifier {
  static const supportedLocales = <Locale>[
    Locale('fr'),
    Locale('ar'),
    Locale('en'),
  ];

  Locale? _locale;

  Locale? get locale => _locale;

  void setLocale(Locale? locale) {
    _locale = locale;
    notifyListeners();
  }

  void setLocaleByCode(String code) {
    setLocale(Locale(code));
  }
}
