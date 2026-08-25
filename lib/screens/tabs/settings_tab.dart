import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:personal_finance_tracker/main.dart';
import 'package:personal_finance_tracker/screens/about.dart';
import 'package:personal_finance_tracker/screens/guide_page.dart';
import 'package:personal_finance_tracker/utils/fade_route.dart';
import 'package:personal_finance_tracker/utils/formatters.dart';

/// Ayarlar sekmesi. Veriye dokunan işlemler (bütçe, tekrar, yedek, CSV, çıkış)
/// üst ekranın geri çağrılarıyla yürütülür; salt gezinme (Hakkında, Kılavuz)
/// burada yapılır.
class SettingsTab extends StatelessWidget {
  final int? monthlyBudget;
  final Future<void> Function() onOpenBudgets;
  final Future<void> Function() onOpenRecurring;
  final VoidCallback onBackup;
  final VoidCallback onSaveLocal;
  final VoidCallback onRestore;
  final VoidCallback onExportCsv;
  final VoidCallback onExit;

  const SettingsTab({
    super.key,
    required this.monthlyBudget,
    required this.onOpenBudgets,
    required this.onOpenRecurring,
    required this.onBackup,
    required this.onSaveLocal,
    required this.onRestore,
    required this.onExportCsv,
    required this.onExit,
  });

  @override
  Widget build(BuildContext context) {
    final currentTheme = MyApp.of(context)?.themeMode ?? ThemeMode.system;
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Card(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 14, 16, 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Icon(Icons.palette_outlined),
                    const SizedBox(width: 12),
                    Text('Tema',
                        style: Theme.of(context).textTheme.titleMedium),
                  ],
                ),
                const SizedBox(height: 12),
                SizedBox(
                  width: double.infinity,
                  child: SegmentedButton<ThemeMode>(
                    segments: const [
                      ButtonSegment(
                        value: ThemeMode.system,
                        label: Text('Sistem'),
                        icon: Icon(Icons.brightness_auto_outlined),
                      ),
                      ButtonSegment(
                        value: ThemeMode.light,
                        label: Text('Açık'),
                        icon: Icon(Icons.light_mode_outlined),
                      ),
                      ButtonSegment(
                        value: ThemeMode.dark,
                        label: Text('Koyu'),
                        icon: Icon(Icons.dark_mode_outlined),
                      ),
                    ],
                    selected: {currentTheme},
                    showSelectedIcon: false,
                    onSelectionChanged: (selection) {
                      HapticFeedback.selectionClick();
                      MyApp.of(context)?.changeTheme(selection.first);
                    },
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 12),
        Card(
          child: ListTile(
            leading: const Icon(Icons.savings_outlined),
            title: const Text('Bütçeler'),
            subtitle: Text(
              monthlyBudget != null
                  ? 'Aylık ${AppFormatters.formatCurrency(monthlyBudget!)}'
                  : 'Aylık ve etiket bazlı limitler',
            ),
            trailing: const Icon(Icons.chevron_right),
            onTap: onOpenBudgets,
          ),
        ),
        const SizedBox(height: 12),
        Card(
          child: ListTile(
            leading: const Icon(Icons.repeat_rounded),
            title: const Text('Tekrarlayan İşlemler'),
            subtitle: const Text('Her ay otomatik eklenen işlemler'),
            trailing: const Icon(Icons.chevron_right),
            onTap: onOpenRecurring,
          ),
        ),
        const SizedBox(height: 24),
        _sectionLabel(context, 'Veri'),
        const SizedBox(height: 8),
        Card(
          child: Column(
            children: [
              ListTile(
                leading: const Icon(Icons.share_outlined),
                title: const Text('Yedeği Paylaş'),
                subtitle: const Text('Tüm veriyi JSON olarak paylaş'),
                onTap: onBackup,
              ),
              const Divider(height: 1),
              ListTile(
                leading: const Icon(Icons.save_alt_rounded),
                title: const Text('Cihaza Kaydet'),
                subtitle: const Text('Yedeği JSON dosyası olarak cihaza kaydet'),
                onTap: onSaveLocal,
              ),
              const Divider(height: 1),
              ListTile(
                leading: const Icon(Icons.restore_rounded),
                title: const Text('Yedekten Geri Yükle'),
                subtitle: const Text('Bir JSON yedeğinden içe aktar'),
                onTap: onRestore,
              ),
              const Divider(height: 1),
              ListTile(
                leading: const Icon(Icons.ios_share_rounded),
                title: const Text('CSV Olarak Dışa Aktar'),
                subtitle: const Text('Hesap tablosu için işlem listesi'),
                onTap: onExportCsv,
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),
        Card(
          child: ListTile(
            leading: const Icon(Icons.info_outline),
            title: const Text('Hakkında'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () => Navigator.push(context, fadeRoute(const AboutPage())),
          ),
        ),
        const SizedBox(height: 12),
        Card(
          child: ListTile(
            leading: const Icon(Icons.menu_book_outlined),
            title: const Text('Kullanım Kılavuzu'),
            subtitle: const Text('Uygulamanın amacı ve nasıl kullanılır'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () => Navigator.push(context, fadeRoute(const GuidePage())),
          ),
        ),
        if (!kIsWeb) ...[
          const SizedBox(height: 12),
          Card(
            child: ListTile(
              leading: const Icon(Icons.power_settings_new,
                  color: Colors.redAccent),
              title: const Text('Uygulamadan Çık'),
              onTap: onExit,
            ),
          ),
        ],
      ],
    );
  }

  Widget _sectionLabel(BuildContext context, String text) => Padding(
        padding: const EdgeInsets.only(left: 4),
        child: Text(
          text,
          style: TextStyle(
            fontSize: 12.5,
            fontWeight: FontWeight.w700,
            letterSpacing: 0.2,
            color: Theme.of(context).colorScheme.onSurfaceVariant,
          ),
        ),
      );
}
