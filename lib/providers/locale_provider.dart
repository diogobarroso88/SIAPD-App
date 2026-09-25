import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class LocaleProvider extends ChangeNotifier {
  static const String _localeKey = 'language';

  final FlutterSecureStorage _storage =
  const FlutterSecureStorage();

  Locale _locale = const Locale('pt', 'PT');

  Locale get locale => _locale;

  Future<void> loadLocale() async {
    final savedLanguage = await _storage.read(
      key: _localeKey,
    );

    if (savedLanguage == null) {
      return;
    }

    switch (savedLanguage) {
      case 'pt':
        _locale = const Locale('pt', 'PT');
        break;
      case 'en':
        _locale = const Locale('en', 'GB');
        break;
      case 'es':
        _locale = const Locale('es', 'ES');
        break;
    }

    notifyListeners();
  }

  Future<void> setLocale(Locale locale) async {
    _locale = locale;

    await _storage.write(
      key: _localeKey,
      value: locale.languageCode,
    );

    notifyListeners();
  }
}