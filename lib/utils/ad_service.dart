import 'package:flutter/foundation.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:personal_finance_tracker/database/database_service.dart';

/// Reklam yükleme/gösterme mantığını tek yerde toplayan yardımcı sınıf.
/// Debug modda Google'ın test ID'lerini, release modda gerçek ID'leri kullanır.
/// [AdService.decideAfterSave] sonucu: reklam gösterilecek mi ve sayacın
/// yeni değeri ne olacak.
@immutable
class AdDecision {
  const AdDecision({required this.showAd, required this.nextCount});

  final bool showAd;
  final int nextCount;

  @override
  bool operator ==(Object other) =>
      other is AdDecision &&
      other.showAd == showAd &&
      other.nextCount == nextCount;

  @override
  int get hashCode => Object.hash(showAd, nextCount);

  @override
  String toString() => 'AdDecision(showAd: $showAd, nextCount: $nextCount)';
}

class AdService {
  AdService._();
  static final AdService instance = AdService._();

  /// Son reklamdan bu yana yapılan kayıt sayısı (settings tablosu).
  static const String saveCountKey = 'txSaveCountSinceAd';

  InterstitialAd? _interstitialAd;
  bool _interstitialLoading = false;

  // Release: AdMob panelindeki gerçek birimler. Debug: Google'ın test
  // birimleri — geliştirme sırasında gerçek reklam istenmez.
  static const String bannerAdUnitId = kReleaseMode
      ? 'ca-app-pub-2349446548941129/1913235472'
      : 'ca-app-pub-3940256099942544/9214589741';

  static const String _interstitialAdUnitId = kReleaseMode
      ? 'ca-app-pub-2349446548941129/6568007800'
      : 'ca-app-pub-3940256099942544/1033173712';

  /// Gerçek reklam birimleriyle test edilen cihazların reklam kimlikleri.
  ///
  /// Buradaki cihazlar release derlemesinde bile TEST reklamı görür, tıklamalar
  /// sayılmaz. **Kendi reklamına tıklamak AdMob hesabının kapatılmasına yol
  /// açabilir**, bu yüzden gerçek cihazda test etmeden önce cihazın kimliği
  /// buraya eklenmelidir. Emülatörler SDK tarafından otomatik test cihazı
  /// sayılır, listeye eklenmeleri gerekmez.
  ///
  /// Kimliği bulmak için: uygulamayı cihazda çalıştır ve logcat'te
  /// "Use RequestConfiguration.Builder().setTestDeviceIds(...)" satırını ara.
  static const List<String> testDeviceIds = <String>[
    // Samsung SM-A720F (Galaxy A7 2017) — gerçek cihaz testi.
    '1ECC546BBFAFD2B602198C87280DD133',
  ];

  Future<void> initialize() async {
    if (testDeviceIds.isNotEmpty) {
      await MobileAds.instance.updateRequestConfiguration(
        RequestConfiguration(testDeviceIds: testDeviceIds),
      );
    }
    await MobileAds.instance.initialize();
    _loadInterstitial();
  }

  void _loadInterstitial() {
    if (_interstitialLoading) return;
    _interstitialLoading = true;
    InterstitialAd.load(
      adUnitId: _interstitialAdUnitId,
      request: const AdRequest(),
      adLoadCallback: InterstitialAdLoadCallback(
        onAdLoaded: (ad) {
          _interstitialAd = ad;
          _interstitialLoading = false;
          ad.fullScreenContentCallback = FullScreenContentCallback(
            onAdDismissedFullScreenContent: (ad) {
              ad.dispose();
              _interstitialAd = null;
              _loadInterstitial();
            },
            onAdFailedToShowFullScreenContent: (ad, error) {
              ad.dispose();
              _interstitialAd = null;
              _loadInterstitial();
            },
          );
        },
        onAdFailedToLoad: (error) {
          _interstitialLoading = false;
          debugPrint('Interstitial yüklenemedi: $error');
        },
      ),
    );
  }

  /// Kayıt sonrası kararı hesaplar: reklam gösterilecek mi, sayaç ne olacak.
  ///
  /// Saf fonksiyon — ne reklam SDK'sına ne veritabanına dokunur, doğrudan test
  /// edilebilir. Sayaç [everyNSaves] değerinde kırpılır: reklam yüklenemediyse
  /// (uygulama çevrimdışı da çalıştığı için bu olağan bir durum) sayaç sınırsız
  /// büyümez, "sırası gelmiş" halde bekler ve reklam ilk uygun kayıtta çıkar.
  @visibleForTesting
  static AdDecision decideAfterSave({
    required String? rawCount,
    required bool adReady,
    bool skipThisRound = false,
    int everyNSaves = 4,
  }) {
    final stored = int.tryParse(rawCount ?? '0') ?? 0;
    final count = (stored < 0 ? 0 : stored) + 1;

    if (count >= everyNSaves && adReady && !skipThisRound) {
      return const AdDecision(showAd: true, nextCount: 0);
    }
    return AdDecision(
      showAd: false,
      nextCount: count < everyNSaves ? count : everyNSaves,
    );
  }

  /// Yeni bir işlem kaydından sonra çağrılır. Her kayıtta değil, yalnızca
  /// [everyNSaves] kayıtta bir gösterir. Sayaç DatabaseService üzerinden tutulur.
  ///
  /// [skipThisRound] true ise reklam bu turda gösterilmez — çağıran taraf
  /// ekranda okunması gereken bir bildirim (ör. bütçe aşım uyarısı) olduğunu
  /// bildirdiğinde kullanılır. Sayaç sırasını kaybetmez, reklam bir sonraki
  /// kayda kalır.
  Future<void> maybeShowInterstitialAfterSave(
    DatabaseService db, {
    int everyNSaves = 4,
    bool skipThisRound = false,
  }) async {
    final raw = await db.getSetting(saveCountKey);
    final ad = _interstitialAd;
    final decision = decideAfterSave(
      rawCount: raw,
      adReady: ad != null,
      skipThisRound: skipThisRound,
      everyNSaves: everyNSaves,
    );

    // Sayaç önce yazılır: gösterim sırasında bir hata olsa bile durum tutarlı
    // kalsın.
    await db.setSetting(saveCountKey, decision.nextCount.toString());
    if (decision.showAd && ad != null) {
      await ad.show();
    }
  }

  /// Her ekran kendi BannerAd örneğini bu metotla oluşturur (paylaşılmaz).
  ///
  /// Ekran genişliğine uyan anchored adaptive banner kullanılır: sabit 320×50
  /// yerine cihazın genişliğine göre boyutlanır. Boyut platform tarafından
  /// hesaplandığı için metot asenkron; boyut alınamazsa null döner ve reklam
  /// hiç oluşturulmaz.
  Future<BannerAd?> createBannerAd({
    required int width,
    required VoidCallback onLoaded,
  }) async {
    final size =
        await AdSize.getCurrentOrientationAnchoredAdaptiveBannerAdSize(width);
    if (size == null) {
      debugPrint('Adaptive banner boyutu alınamadı (genişlik: $width)');
      return null;
    }

    final ad = BannerAd(
      adUnitId: bannerAdUnitId,
      size: size,
      request: const AdRequest(),
      listener: BannerAdListener(
        onAdLoaded: (_) => onLoaded(),
        onAdFailedToLoad: (ad, error) {
          ad.dispose();
          debugPrint('Banner yüklenemedi: $error');
        },
      ),
    );
    ad.load();
    return ad;
  }
}
