import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:personal_finance_tracker/database/database_service.dart';
import 'package:personal_finance_tracker/screens/splash_screen.dart';
import 'package:personal_finance_tracker/utils/app_theme.dart';
import 'package:personal_finance_tracker/utils/db_init.dart';
import 'package:personal_finance_tracker/utils/recurring_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await initDatabase();
  final db = DatabaseService();
  // Vadesi gelmiş tekrarlayan işlemleri açılışta üret.
  await RecurringService(db).generateDue();
  final saved = await db.getSetting('themeMode');
  // Karşılama ekranı yalnızca ilk açılışta gösterilir.
  final onboardingSeen = await db.getSetting('onboardingSeen') == 'true';
  runApp(MyApp(
    initialThemeMode: _parseThemeMode(saved),
    showOnboarding: !onboardingSeen,
  ));
}

ThemeMode _parseThemeMode(String? value) {
  switch (value) {
    case 'light':
      return ThemeMode.light;
    case 'dark':
      return ThemeMode.dark;
    default:
      return ThemeMode.system;
  }
}

class MyApp extends StatefulWidget {
  final ThemeMode initialThemeMode;
  final bool showOnboarding;
  const MyApp({
    super.key,
    this.initialThemeMode = ThemeMode.system,
    this.showOnboarding = true,
  });

  static MyAppState? of(BuildContext context) =>
      context.findAncestorStateOfType<MyAppState>();

  @override
  State<MyApp> createState() => MyAppState();
}

class MyAppState extends State<MyApp> {
  late ThemeMode _themeMode = widget.initialThemeMode;
  ThemeMode get themeMode => _themeMode;

  void changeTheme(ThemeMode mode) {
    setState(() {
      _themeMode = mode;
    });
    // Tercihi kalıcı olarak sakla (SQLite settings tablosu).
    DatabaseService().setSetting('themeMode', mode.name);
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'BudgetFlow',
      themeMode: _themeMode,
      theme: AppTheme.light(),
      darkTheme: AppTheme.dark(),
      // Uygulama tamamen Türkçe: tarih seçici, takvim ve sistem diyalogları
      // da Türkçe görünsün.
      locale: const Locale('tr'),
      supportedLocales: const [Locale('tr')],
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      home: SplashScreen(showOnboarding: widget.showOnboarding),
    );
  }
}
