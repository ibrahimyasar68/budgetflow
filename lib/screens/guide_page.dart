import 'package:flutter/material.dart';

/// Uygulamanın amacını ve nasıl kullanılacağını anlatan kullanım kılavuzu.
/// Ayarlar sayfasından açılır.
class GuidePage extends StatelessWidget {
  const GuidePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(title: const Text('Kullanım Kılavuzu')),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
        children: const [
        _Intro(),
        SizedBox(height: 20),
        _SectionTitle('Nasıl Kullanılır?'),
        SizedBox(height: 12),
        _GuideStep(
          icon: Icons.add_rounded,
          title: 'İşlem Ekleme',
          description:
              'Ana sayfadaki + butonuna dokun. Gelir mi gider mi olduğunu '
              'seç, tutarı gir, dilersen bir not ekle ve tarihi belirle. '
              'Not boş bırakılırsa işlem otomatik olarak “Diğer” başlığı '
              'altında toplanır.',
        ),
        _GuideStep(
          icon: Icons.swipe_rounded,
          title: 'Düzenleme ve Silme',
          description:
              'Bir işlemi sağa kaydırarak düzenleyebilir, sola kaydırarak '
              'silebilirsin. İşleme dokunarak da düzenleme ekranını açabilirsin.',
        ),
        _GuideStep(
          icon: Icons.label_important_outline_rounded,
          title: 'Notlarla Sınıflandırma',
          description:
              'Not alanı, harcamalarını gruplamak için kullanılır. Örneğin '
              '“Akaryakıt” yazdığın tüm işlemler grafiklerde tek bir başlık '
              'altında toplanır. Büyük/küçük harf farkı önemsenmez.',
        ),
        _GuideStep(
          icon: Icons.pie_chart_outline_rounded,
          title: 'Grafikler',
          description:
              'Grafik sekmesinde gelir/gider dağılımını, son 6 ayın '
              'karşılaştırmasını ve notlara göre gider dökümünü görebilirsin. '
              'Üstteki ay seçici hem işlemleri hem grafikleri birlikte süzer.',
        ),
        _GuideStep(
          icon: Icons.savings_outlined,
          title: 'Bütçe Limitleri',
          description:
              'Ayarlar > Bütçeler’den aylık toplam bir gider limiti ve '
              'istersen her etiket (not) için ayrı limit belirleyebilirsin. '
              'Ana ekranda ne kadar harcadığını ve kalanı görür, limiti '
              'aşınca uyarı alırsın.',
        ),
        _GuideStep(
          icon: Icons.repeat_rounded,
          title: 'Tekrarlayan İşlemler',
          description:
              'İşlem eklerken “Her ay tekrarla”yı açtığında, o işlem her ay '
              'aynı gün otomatik eklenir. Başlangıç ve bitiş ayını seçerek '
              'bir aralık (ör. Ocak 2026 – Aralık 2026) belirleyebilir ya da '
              '“Süresiz”i açabilirsin. Ayarlar > Tekrarlayan İşlemler’den '
              'kuralları görüp durdurabilirsin.',
        ),
        _GuideStep(
          icon: Icons.search_rounded,
          title: 'Arama ve Filtreleme',
          description:
              'Ana sayfadaki arama kutusuyla notlara göre işlem arayabilir, '
              'Tümü / Gelir / Gider düğmeleriyle listeyi filtreleyebilirsin.',
        ),
        _GuideStep(
          icon: Icons.backup_outlined,
          title: 'Yedekleme ve Dışa Aktarma',
          description:
              'Ayarlar > Veri bölümünden tüm verini JSON olarak '
              'paylaşabilir veya “Cihaza Kaydet” ile doğrudan cihazına '
              'kaydedebilirsin. “Yedekten Geri Yükle” ile bir JSON '
              'yedeğinden geri alırsın. İşlemlerini hesap tablosu için CSV '
              'olarak da dışa aktarabilirsin.',
        ),
        _GuideStep(
          icon: Icons.palette_outlined,
          title: 'Tema',
          description:
              'Ayarlardan Sistem / Açık / Koyu tema seçebilirsin. Tercihin '
              'kaydedilir ve uygulamayı yeniden açtığında korunur.',
        ),
        SizedBox(height: 16),
        _PrivacyNote(),
        ],
      ),
    );
  }
}

class _Intro extends StatelessWidget {
  const _Intro();

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: scheme.primary.withValues(alpha: 0.14),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Icon(Icons.account_balance_wallet_rounded,
                      color: scheme.primary),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    'BudgetFlow Nedir?',
                    style: Theme.of(context)
                        .textTheme
                        .titleMedium
                        ?.copyWith(fontWeight: FontWeight.w700),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 14),
            Text(
              'BudgetFlow, gelir ve giderlerini hızlıca kaydedip takip '
              'etmeni sağlayan sade bir kişisel finans uygulamasıdır. '
              'Tüm verilerin yalnızca cihazında saklanır; hesap açmana '
              'veya internete bağlanmana gerek yoktur.',
              style: Theme.of(context)
                  .textTheme
                  .bodyMedium
                  ?.copyWith(height: 1.45),
            ),
          ],
        ),
      ),
    );
  }
}

class _SectionTitle extends StatelessWidget {
  final String text;
  const _SectionTitle(this.text);

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: Theme.of(context)
          .textTheme
          .titleMedium
          ?.copyWith(fontWeight: FontWeight.w700),
    );
  }
}

class _GuideStep extends StatelessWidget {
  final IconData icon;
  final String title;
  final String description;
  const _GuideStep({
    required this.icon,
    required this.title,
    required this.description,
  });

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: scheme.primary.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: scheme.primary, size: 20),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                        fontWeight: FontWeight.w700, fontSize: 15),
                  ),
                  const SizedBox(height: 5),
                  Text(
                    description,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        height: 1.4, color: scheme.onSurfaceVariant),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _PrivacyNote extends StatelessWidget {
  const _PrivacyNote();

  @override
  Widget build(BuildContext context) {
    final muted = Theme.of(context).colorScheme.onSurfaceVariant;
    return Row(
      children: [
        Icon(Icons.lock_outline_rounded, size: 16, color: muted),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            'Verilerin gizlidir ve yalnızca bu cihazda tutulur.',
            style: TextStyle(fontSize: 12, color: muted),
          ),
        ),
      ],
    );
  }
}
