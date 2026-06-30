import 'package:flutter/material.dart';

class AppLocalizations {
  final Locale locale;

  AppLocalizations(this.locale);

  static AppLocalizations of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations)!;
  }

  static const LocalizationsDelegate<AppLocalizations> delegate = _AppLocalizationsDelegate();

  Map<String, String>? _translations;

  String get _languageCode => locale.languageCode;

  static final Map<String, Map<String, String>> _localizedValues = {
    'en': {
      'appTitle': 'ERP Dreen',
      'mobileERPSolution': 'Mobile ERP Solution',
      'connectToServer': 'Connect to your server',
      'connect': 'Connect',
      'pleaseEnterURL': 'Please enter server URL',
      'connectionFailed': 'Connection failed: ',
    },
    'ar': {
      'appTitle': 'ERP Dreen',
      'mobileERPSolution': 'حل ERP للجوال',
      'connectToServer': 'الاتصال بالخادم',
      'connect': 'اتصال',
      'pleaseEnterURL': 'الرجاء إدخال رابط الخادم',
      'connectionFailed': 'فشل الاتصال: ',
    },
  };

  String translate(String key) {
    return _localizedValues[_languageCode]?[key] ?? _localizedValues['en']?[key] ?? key;
  }
}

class _AppLocalizationsDelegate extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  bool isSupported(Locale locale) => ['en', 'ar'].contains(locale.languageCode);

  @override
  Future<AppLocalizations> load(Locale locale) => Future.value(AppLocalizations(locale));

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}
