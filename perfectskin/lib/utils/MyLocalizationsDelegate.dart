import 'dart:async' show Future;
import 'package:flutter/foundation.dart' show SynchronousFuture;
import 'package:flutter/material.dart';
import './constant.dart' show languages;

class MyLocalizations {
  final Map<String, Map<String, String>> localizedValues;
  MyLocalizations(this.locale, this.localizedValues);

  final Locale locale;

  static MyLocalizations of(BuildContext context) {
    return Localizations.of<MyLocalizations>(context, MyLocalizations);
  }

  String getText(String frase) {
    return localizedValues[locale.languageCode][frase];
  }
}

class MyLocalizationsDelegate extends LocalizationsDelegate<MyLocalizations> {
  Map<String, Map<String, String>> localizedValues;

  MyLocalizationsDelegate(this.localizedValues);

  @override
  bool isSupported(Locale locale) => languages.contains(locale.languageCode);

  @override
  Future<MyLocalizations> load(Locale locale) {
    return SynchronousFuture<MyLocalizations>(
        MyLocalizations(locale, localizedValues));
  }

  @override
  bool shouldReload(MyLocalizationsDelegate old) => false;
}
