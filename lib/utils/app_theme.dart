import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// Merkezi tema — tek bir marka renginden hem açık hem koyu tema türetilir.
class AppTheme {
  // Marka rengi: modern indigo-mor (mevcut bakiye kartı gradyanıyla uyumlu)
  static const Color seed = Color(0xFF6C5CE7);

  // Bakiye kartı gradyanı (seed ile aynı dilden)
  static const List<Color> balanceGradient = [
    Color(0xFF6C5CE7),
    Color(0xFF8E2DE2),
  ];

  static const Color incomeColor = Color(0xFF2BC48A);
  static const Color expenseColor = Color(0xFFFF5A6E);

  /// Para tutarlarında rakamların hizalı (eş genişlikli) görünmesi için.
  static const List<FontFeature> tabularFigures = [
    FontFeature.tabularFigures(),
  ];

  static ThemeData light() => _base(Brightness.light);
  static ThemeData dark() => _base(Brightness.dark);

  /// Uygulamanın zemin rengi (Scaffold ve sistem gezinme çubuğu ortak kullanır).
  static Color background(Brightness brightness) =>
      brightness == Brightness.dark
      ? const Color(0xFF0E0F15)
      : const Color(0xFFF6F7FB);

  /// Mor gradyanlı ekranlar (splash, karşılama) için: simgeler her zaman beyaz.
  /// Bu ekranlarda AppBar yok, o yüzden stil AnnotatedRegion ile verilir.
  static const SystemUiOverlayStyle brandOverlayStyle = SystemUiOverlayStyle(
    statusBarColor: Colors.transparent,
    statusBarIconBrightness: Brightness.light,
    statusBarBrightness: Brightness.dark,
    systemNavigationBarColor: Color(0xFF8E2DE2),
    systemNavigationBarIconBrightness: Brightness.light,
  );

  /// Durum çubuğu ve sistem gezinme çubuğu simgelerini temayla uyumlu kılar.
  /// Açıkça verilmezse AppBar arka planı şeffaf olduğu için parlaklık yanlış
  /// türetiliyor ve açık temada simgeler beyaz kalıyordu.
  static SystemUiOverlayStyle overlayStyle(Brightness brightness) {
    final isDark = brightness == Brightness.dark;
    final iconBrightness = isDark ? Brightness.light : Brightness.dark;
    return SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      // Android: simge rengi; iOS: arka plan parlaklığı (ters mantık).
      statusBarIconBrightness: iconBrightness,
      statusBarBrightness: brightness,
      // Android 15+ gezinme çubuğu rengini yok sayar (şeffaf çizer); bu ayar
      // yalnızca eski sürümlerde etkilidir ve orada siyah şeridi kaldırır.
      systemNavigationBarColor: background(brightness),
      systemNavigationBarIconBrightness: iconBrightness,
    );
  }

  static ThemeData _base(Brightness brightness) {
    final isDark = brightness == Brightness.dark;
    final scheme = ColorScheme.fromSeed(
      seedColor: seed,
      brightness: brightness,
    );
    final base = ThemeData(
      useMaterial3: true,
      colorScheme: scheme,
      brightness: brightness,
      fontFamily: 'Manrope',
    );

    final bg = background(brightness);
    final surface = isDark ? const Color(0xFF1A1C26) : Colors.white;
    final field = isDark ? const Color(0xFF222533) : const Color(0xFFEFF1F7);

    final textTheme = _textTheme(base.textTheme);

    return base.copyWith(
      scaffoldBackgroundColor: bg,
      textTheme: textTheme,
      appBarTheme: AppBarTheme(
        backgroundColor: Colors.transparent,
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: false,
        titleTextStyle: textTheme.titleLarge,
        systemOverlayStyle: overlayStyle(brightness),
      ),
      cardTheme: CardThemeData(
        elevation: 0,
        color: surface,
        clipBehavior: Clip.antiAlias,
        margin: EdgeInsets.zero,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(22),
          // Koyu temada kartları arka plandan ince bir çizgiyle ayır.
          side: isDark
              ? BorderSide(color: Colors.white.withValues(alpha: 0.06))
              : BorderSide.none,
        ),
      ),
      navigationBarTheme: NavigationBarThemeData(
        elevation: 0,
        height: 68,
        backgroundColor: isDark ? const Color(0xFF14161F) : Colors.white,
        indicatorColor: scheme.primary.withValues(alpha: 0.16),
        labelTextStyle: WidgetStateProperty.all(
          const TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: field,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(color: scheme.primary, width: 1.6),
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          elevation: 0,
          padding: const EdgeInsets.symmetric(vertical: 14),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
        ),
      ),
      chipTheme: base.chipTheme.copyWith(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
      dividerTheme: DividerThemeData(
        color: scheme.outlineVariant.withValues(alpha: 0.4),
      ),
    );
  }

  static TextTheme _textTheme(TextTheme base) {
    return base.copyWith(
      displayLarge: base.displayLarge?.copyWith(
        fontWeight: FontWeight.w800,
        letterSpacing: -1,
      ),
      headlineMedium: base.headlineMedium?.copyWith(
        fontWeight: FontWeight.w800,
        letterSpacing: -0.5,
      ),
      titleLarge: base.titleLarge?.copyWith(
        fontWeight: FontWeight.w700,
        letterSpacing: -0.3,
      ),
      titleMedium: base.titleMedium?.copyWith(fontWeight: FontWeight.w600),
      bodyMedium: base.bodyMedium?.copyWith(letterSpacing: 0.1),
    );
  }
}
