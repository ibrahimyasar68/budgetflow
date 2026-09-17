import 'package:flutter/material.dart';
import 'package:package_info_plus/package_info_plus.dart';

class AboutPage extends StatefulWidget {
  const AboutPage({super.key});

  @override
  State<AboutPage> createState() => _AboutPageState();
}

class _AboutPageState extends State<AboutPage> {
  // pubspec'teki sürümle çakışmasın diye uygulama paketinden okunur.
  String _version = '';

  @override
  void initState() {
    super.initState();
    _loadVersion();
  }

  Future<void> _loadVersion() async {
    final info = await PackageInfo.fromPlatform();
    if (!mounted) return;
    setState(() => _version = '${info.version} (${info.buildNumber})');
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(title: const Text('Hakkında')),
      body: ListView(
        padding: EdgeInsets.fromLTRB(
            16, 16, 16, 24 + MediaQuery.paddingOf(context).bottom),
        children: [
          // Uygulama kimliği
          Column(
            children: [
              Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(26),
                  gradient: const LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [Color(0xFF6C5CE7), Color(0xFF8E2DE2)],
                  ),
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(20),
                  child: Image.asset('assets/icon/app_icon.png',
                      width: 84, height: 84, fit: BoxFit.cover),
                ),
              ),
              const SizedBox(height: 14),
              const Text('BudgetFlow',
                  style:
                      TextStyle(fontSize: 24, fontWeight: FontWeight.w800)),
              const SizedBox(height: 4),
              Text(
                'Kişisel Finans Takipçisi',
                style: TextStyle(color: scheme.onSurfaceVariant),
              ),
              const SizedBox(height: 6),
              Text(
                _version.isEmpty ? 'Sürüm yükleniyor…' : 'Sürüm $_version',
                style: TextStyle(
                    fontSize: 12, color: scheme.onSurfaceVariant),
              ),
            ],
          ),
          const SizedBox(height: 28),

          Card(
            child: Column(
              children: [
                ListTile(
                  leading: const Icon(Icons.code_rounded),
                  title: const Text('Geliştirici'),
                  subtitle: const Text('İbrahim YAŞAR'),
                ),
                Divider(
                    height: 1,
                    indent: 16,
                    endIndent: 16,
                    color: scheme.outlineVariant.withValues(alpha: 0.4)),
                const ListTile(
                  leading: Icon(Icons.mail_outline_rounded),
                  title: Text('İletişim'),
                  subtitle: Text('ibrahimyasar68@hotmail.com'),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),

          Center(
            child: Text(
              'IY Labs · Flutter ile geliştirildi',
              style: TextStyle(fontSize: 12, color: scheme.onSurfaceVariant),
            ),
          ),
        ],
      ),
    );
  }
}
