import 'package:flutter/material.dart';
import 'package:aurora/core/storage.dart';

class LocaleProvider extends ChangeNotifier {
  Locale _locale = const Locale('en');

  Locale get locale => _locale;

  Future<void> init() async {
    final code = await Storage.getLanguageCode();
    _locale = Locale(code);
    notifyListeners();
  }

  Future<void> setLocale(Locale locale) async {
    _locale = locale;
    await Storage.saveLanguageCode(locale.languageCode);
    notifyListeners();
  }
}
