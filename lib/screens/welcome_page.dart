import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:personal_finance_tracker/database/database_service.dart';
import 'package:personal_finance_tracker/screens/home_page.dart';
import 'package:personal_finance_tracker/utils/app_theme.dart';

class WelcomePage extends StatelessWidget {
  const WelcomePage({super.key});

  Future<void> _start(BuildContext context) async {
    // Karşılama ekranının bir daha gösterilmemesi için işaretle.
    await DatabaseService().setSetting('onboardingSeen', 'true');
    if (!context.mounted) return;
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (_) => const HomePage()),
    );
  }

  @override
  Widget build(BuildContext context) {
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
          child: SafeArea(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(28, 32, 28, 28),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Spacer(flex: 2),

                  // Marka simgesi
                  Container(
                    width: 88,
                    height: 88,
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.16),
                      borderRadius: BorderRadius.circular(26),
                      border: Border.all(
                        color: Colors.white.withValues(alpha: 0.25),
                        width: 1,
                      ),
                    ),
                    child: const Icon(
                      Icons.account_balance_wallet_rounded,
                      color: Colors.white,
                      size: 44,
                    ),
                  ),
                  const SizedBox(height: 28),

                  const Text(
                    'BudgetFlow',
                    style: TextStyle(
                      fontSize: 40,
                      fontWeight: FontWeight.w800,
                      color: Colors.white,
                      letterSpacing: -1,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'Bütçeni düzenle.\nHayatını sadeleştir.',
                    style: TextStyle(
                      fontSize: 17,
                      height: 1.4,
                      color: Colors.white.withValues(alpha: 0.85),
                    ),
                  ),

                  const SizedBox(height: 40),

                  // Öne çıkan özellikler
                  _Feature(
                    icon: Icons.flash_on_rounded,
                    text: 'Gelir ve giderini saniyeler içinde kaydet',
                  ),
                  const SizedBox(height: 16),
                  _Feature(
                    icon: Icons.insights_rounded,
                    text: 'Grafiklerle harcamalarını anla',
                  ),
                  const SizedBox(height: 16),
                  _Feature(
                    icon: Icons.lock_outline_rounded,
                    text: 'Verilerin çevrimdışı ve yalnızca sende',
                  ),

                  const Spacer(flex: 3),

                  // Başla butonu
                  SizedBox(
                    width: double.infinity,
                    height: 56,
                    child: FilledButton.icon(
                      style: FilledButton.styleFrom(
                        backgroundColor: Colors.white,
                        foregroundColor: AppTheme.seed,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(18),
                        ),
                      ),
                      onPressed: () => _start(context),
                      icon: const Icon(Icons.arrow_forward_rounded),
                      label: const Text(
                        'Hemen Başla',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _Feature extends StatelessWidget {
  final IconData icon;
  final String text;
  const _Feature({required this.icon, required this.text});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 42,
          height: 42,
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.16),
            borderRadius: BorderRadius.circular(13),
          ),
          child: Icon(icon, color: Colors.white, size: 21),
        ),
        const SizedBox(width: 14),
        Expanded(
          child: Text(
            text,
            style: TextStyle(
              fontSize: 15,
              height: 1.3,
              color: Colors.white.withValues(alpha: 0.92),
            ),
          ),
        ),
      ],
    );
  }
}
