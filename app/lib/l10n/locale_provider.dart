import 'package:flutter/material.dart';
import '../services/storage_service.dart';

class LocaleProvider with ChangeNotifier {
  Locale _locale = const Locale('ko');
  final StorageService _storageService = StorageService();

  Locale get locale => _locale;

  LocaleProvider() {
    _loadLocale();
  }

  Future<void> _loadLocale() async {
    final languageCode = await _storageService.loadLanguage();
    _locale = Locale(languageCode);
    notifyListeners();
  }

  Future<void> setLocale(Locale locale) async {
    if (_locale == locale) return;
    _locale = locale;
    await _storageService.saveLanguage(locale.languageCode);
    notifyListeners();
  }

  void toggleLocale() {
    final newLocale = _locale.languageCode == 'ko' ? const Locale('en') : const Locale('ko');
    setLocale(newLocale);
  }
}
