import 'package:flutter/material.dart';
import 'package:localstore/localstore.dart';
import 'event/event_view.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

void main() {
  runApp(const MainApp());
}

class MainApp extends StatefulWidget {
  const MainApp({super.key});

  @override
  // ignore: library_private_types_in_public_api
  _MainAppState createState() => _MainAppState();
}

class _MainAppState extends State<MainApp> {
  final db = Localstore.instance;
  Locale _locale = const Locale('vi'); // Mặc định Vietnamese

  @override
  void initState() {
    super.initState();
    _loadLocale();
  }

  Future<void> _loadLocale() async {
    final localeData = await db.collection('settings').doc('locale').get();
    if (localeData != null && localeData['language_code'] != null) {
      setState(() {
        _locale = Locale(localeData['language_code']);
      });
    }
  }

  void _changeLanguage(Locale locale) {
    setState(() {
      _locale = locale;
    });
    db.collection('settings').doc('locale').set({
      'language_code': locale.languageCode,
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      localizationsDelegates: const [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: const [
        Locale('en'), // English
        Locale('vi'), // Vietnamese
      ],
      locale: _locale,
      home: EventView(onLocaleChange: _changeLanguage),
    );
  }
}
