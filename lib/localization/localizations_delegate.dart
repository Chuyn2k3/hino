import 'package:flutter/material.dart';
import 'package:hino/localization/language/language_vi.dart';
import 'language/language_en.dart';
import 'language/languages.dart';

class AppLocalizationsDelegate extends LocalizationsDelegate<Languages> {

  const AppLocalizationsDelegate();

  @override
  bool isSupported(Locale locale) =>
      ['en', 'vi'].contains(locale.languageCode);

  @override
  Future<Languages> load(Locale locale) => _load(locale);

  static Future<Languages> _load(Locale locale) async {
    switch (locale.languageCode) {
      case 'en':
        return LanguageEn();
      case 'vi':
        return LanguageVi();
      default:
        return LanguageVi();
    }
  }

  @override
  bool shouldReload(LocalizationsDelegate<Languages> old) => false;
}
