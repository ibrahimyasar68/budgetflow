import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:personal_finance_tracker/screens/home_page.dart';
import 'package:personal_finance_tracker/screens/welcome_page.dart';
import 'package:personal_finance_tracker/utils/app_theme.dart';

/// Açılışta ~2 saniye gösterilen animasyonlu marka ekranı ("Flow Bars").
/// Grafik çubukları sırayla yükselir, üstte cüzdan ve isim belirir; sonra
/// onboarding durumuna göre Karşılama veya Ana Sayfa'ya geçilir.
class SplashScreen extends StatefulWidget {
  final bool showOnboarding;
  const SplashScreen({super.key, required this.showOnboarding});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _c;
  bool _navigated = false;

  // Yükselen grafik çubukları (yükseklik, renk, animasyon aralığı).
  static const List<_Bar> _bars = [
    _Bar(46, Color(0xFF7CFFC4), 0.00, 0.42),
    _Bar(76, Colors.white, 0.12, 0.54),
    _Bar(34, Color(0xFFFF9AA8), 0.24, 0.66),
    _Bar(62, Color(0xFF7CFFC4), 0.36, 0.78),
  ];

  @override
  void initState() {
    super.initState();
    _c = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1800),
    )..forward();
    _c.addStatusListener((status) {
      if (status == AnimationStatus.completed) _goNext();
    });
  }

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  Future<void> _goNext() async {
    if (_navigated) return;
    _navigated = true;
    // Animasyonun son karesi kısa süre görünsün, sonra geçiş yap.
    await Future<void>.delayed(const Duration(milliseconds: 250));
    if (!mounted) return;
    final next = widget.showOnboarding ? const WelcomePage() : const HomePage();
    Navigator.of(context).pushReplacement(
      PageRouteBuilder(
        transitionDuration: const Duration(milliseconds: 450),
        pageBuilder: (_, __, ___) => next,
        transitionsBuilder: (_, anim, __, child) =>
            FadeTransition(opacity: anim, child: child),
      ),
    );
  }

  double _interval(double start, double end, Curve curve) {
    return Interval(start, end, curve: curve).transform(_c.value);
  }

  @override
  Widget build(BuildContext context) {
    const maxBarHeight = 76.0;
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: AppTheme.brandOverlayStyle,
      child: Scaffold(
        body: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [Color(0xFF6C5CE7), Color(0xFF8E2DE2)],
            ),
          ),
          child: Center(
            child: AnimatedBuilder(
              animation: _c,
              builder: (context, _) {
                final top = _interval(
                  0.55,
                  0.95,
                  Curves.easeOut,
                ).clamp(0.0, 1.0);
                return Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Cüzdan + marka adı
                    Opacity(
                      opacity: top,
                      child: Transform.translate(
                        offset: Offset(0, (1 - top) * 14),
                        child: Column(
                          children: [
                            Container(
                              width: 60,
                              height: 60,
                              decoration: BoxDecoration(
                                color: Colors.white.withValues(alpha: 0.16),
                                borderRadius: BorderRadius.circular(18),
                                border: Border.all(
                                  color: Colors.white.withValues(alpha: 0.28),
                                ),
                              ),
                              child: const Icon(
                                Icons.account_balance_wallet_rounded,
                                color: Colors.white,
                                size: 30,
                              ),
                            ),
                            const SizedBox(height: 14),
                            const Text(
                              'BudgetFlow',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 24,
                                fontWeight: FontWeight.w800,
                                letterSpacing: -0.5,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 28),
                    // Yükselen çubuklar
                    SizedBox(
                      height: maxBarHeight,
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          for (final b in _bars) ...[
                            Container(
                              width: 14,
                              height:
                                  b.height *
                                  _interval(
                                    b.start,
                                    b.end,
                                    Curves.easeOutCubic,
                                  ),
                              decoration: BoxDecoration(
                                color: b.color,
                                borderRadius: BorderRadius.circular(4),
                              ),
                            ),
                            const SizedBox(width: 8),
                          ],
                        ],
                      ),
                    ),
                  ],
                );
              },
            ),
          ),
        ),
      ),
    );
  }
}

class _Bar {
  final double height;
  final Color color;
  final double start;
  final double end;
  const _Bar(this.height, this.color, this.start, this.end);
}
