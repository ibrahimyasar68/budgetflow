# BudgetFlow 1.6.0 — Teknik Sürüm Notları

> **Durum:** kod tarafı tamam — gerçek AdMob kimlikleri yerleştirildi
> (2026-08-25). Kalan iş Play Console beyanları ve dağıtım kısıtı;
> `docs/devam-notu.md` → "1.6.0 yayın kapısı".

Bu sürümün tek işlevsel değişikliği reklam entegrasyonu. Bütçe, arama, silme/geri
alma, yedekleme ve tekrarlayan işlem mantığına dokunulmadı.

## 1. Google AdMob entegrasyonu
- `google_mobile_ads` ^7.0.0 eklendi (yanında 4 webview paketi geliyor).
- `lib/utils/ad_service.dart` — reklam mantığının tek toplandığı yer.
  `DatabaseService` gibi factory-singleton deseninde.
- Ana ekranın alt gezinme çubuğunun üstünde banner (`AdSize.banner`, 320×50).
  Reklam yüklenene kadar yer kaplamaz — `_isBannerLoaded` false iken `Column`
  yalnızca `_buildBottomNav()` döndürür.
- Geçiş reklamı: yalnızca **yeni** işlem kaydından sonra, dört kayıtta bir.
  Düzenlemede hiç gösterilmez.
- `AndroidManifest.xml`: `INTERNET` izni ve AdMob `APPLICATION_ID` meta-data'sı.
- Debug derlemelerde Google'ın test reklam birimleri, release'de gerçek
  birimler (`kReleaseMode` ayrımı).

## 2. Bütçe uyarısı reklamın altında kaybolmuyor
Sorun: dördüncü kayıt aynı zamanda aylık limiti aşan kayıtsa, uyarı snackbar'ı
gösteriliyor ve hemen ardından tam ekran reklam üstünü kapatıyordu. Snackbar'ın
4 saniyelik sayacı reklam açıkken işlemeye devam ettiği için kullanıcı reklamı
kapattığında uyarı çoktan sönmüş oluyordu — bütçe uygulamasının en kritik
bildirimi görülmeden geçiyordu.

Çözüm: `_openSheet` içinde `showedNotice` bayrağı tutuluyor. Ekranda okunması
gereken bir bildirim (ilk işlem kutlaması veya bütçe aşım uyarısı) gösterildiyse
`maybeShowInterstitialAfterSave(..., skipThisRound: true)` çağrılıyor. Reklam o
turu atlıyor ama **sırasını kaybetmiyor**: sayaç eşikte kalıyor ve reklam bir
sonraki kayıtta çıkıyor.

## 3. Sayaç mantığı saf fonksiyona ayrıldı ve kırpıldı
Önceki hâlde sayaç yalnızca reklam elde hazırken sıfırlanıyordu. Reklam
yüklenememişse (uygulama çevrimdışı da çalıştığı için bu olağan durum) sayaç
sınırsız büyüyordu: 4, 5, 12, 30... Sonuç, kullanıcı uzun süre çevrimdışı
kaydettikten sonra ilk kez bağlandığında bir sonraki kayıtta anında reklam
görmesiydi.

- `AdService.decideAfterSave` — saf, statik, `@visibleForTesting` karar
  fonksiyonu. `RecurringService.dueMonths` / `clampDay` desenini izliyor.
  Sonucu `AdDecision(showAd, nextCount)` olarak döndürüyor.
- Sayaç `everyNSaves` değerinde kırpılıyor: sırası gelen sayaç "sırası gelmiş"
  halde bekliyor, birikmiyor.
- Bozuk ya da negatif sayaç değeri sıfırdan sayılıyor.
- Sayaç önce yazılıyor, reklam sonra gösteriliyor — gösterimde hata olsa bile
  durum tutarlı kalıyor.
- Sayaç anahtarı `AdService.saveCountKey` sabitine taşındı.

## 4. Test
`test/ad_service_test.dart` — 8 yeni birim testi: normal artış, dördüncü kayıtta
gösterim, ilk kayıtta gösterilmeme, çevrimdışı kırpma, kırpılan sayacın bağlantı
gelince tetiklenmesi, `skipThisRound` ertelemesi, bozuk/negatif değer,
`everyNSaves` değiştirilebilirliği.

Toplam: **46/46 test geçiyor**, `flutter analyze` temiz.

## 5. Dağıtım kararı — yalnızca Türkiye
Uygulamada UMP/CMP rıza akışı **yok**. AEA ve Birleşik Krallık kullanıcılarına
kişiselleştirilmiş reklam göstermek Google onaylı bir rıza mekanizması
gerektirdiğinden, dağıtım Play Console'dan **yalnızca Türkiye** ile
sınırlanacak. İleride başka ülke açılacaksa önce UMP akışının koda eklenmesi
gerekir.

## 6. Ana ekran: kartlar listeyle birlikte kayıyor
Reklam banner'ı 50 dp aldığında zaten dar olan işlem listesi iyice sıkıştı —
sabit başlık (ay seçici + özet kartı + bütçe kartı + arama + filtre çipleri)
ekranın üstünü tuttuğu için listeye yalnızca ~2 satır kalıyordu.

`_buildTransactionTab` sabit `Column` + `Expanded(ListView)` yapısından
`CustomScrollView`'a geçirildi: başlık içeriği `SliverList` içinde, işlem listesi
`_buildTransactionSliver()` olarak aynı kaydırma alanını paylaşıyor. Kullanıcı
kaydırdığı anda kartlar yukarı çekiliyor ve liste ekranın tamamını kullanıyor.

- Emülatörde (Android 14, 1080×2400) ölçüldü: kaydırma sonrası **2 satır yerine
  8 satır** görünüyor.
- Filtre sonucu boşsa `SliverFillRemaining` ile "Sonuç Yok" ortalanıyor.
- Hiç işlem yokken eski sade düzen korunuyor (kaydırılacak bir şey yok).
- `RefreshIndicator` ve giriş animasyonu korundu.
- Ödünleşme: arama/filtre artık sabit değil, listeyle birlikte kayıyor. Filtre
  değiştirmek için yukarı kaydırmak gerekiyor. Sabitlemek için
  `SliverPersistentHeader` gerekirdi, o da yazı tipi ölçeğine göre değişen
  sabit bir yükseklik değeri istiyor — kırılgan olduğu için tercih edilmedi.

## 7. Adaptive banner
`AdSize.banner` (her cihazda sabit 320×50) yerine anchored adaptive banner:
`AdSize.getCurrentOrientationAnchoredAdaptiveBannerAdSize(width)`. Boyut platform
tarafından hesaplandığı için `createBannerAd` asenkron oldu ve genişlik
parametresi alıyor; `MediaQuery` gerektiğinden yükleme `initState` yerine ilk
kareden sonra (`addPostFrameCallback`) yapılıyor. Boyut alınamazsa reklam hiç
oluşturulmuyor.

Emülatörde doğrulandı: banner artık ekranın tam genişliğini kaplıyor
(1080 pikselin 1078'i), öncesinde 840 piksel (320 dp) idi.

## 8. AdMob kimlikleri (2026-08-25)
| Ne | Değer | Nerede |
|---|---|---|
| App ID | `ca-app-pub-2349446548941129~6555651080` | `AndroidManifest.xml` |
| Banner | `ca-app-pub-2349446548941129/1913235472` | `ad_service.dart` release dalı |
| Geçiş | `ca-app-pub-2349446548941129/6568007800` | `ad_service.dart` release dalı |

Debug derlemeleri Google'ın test birimlerini kullanmaya devam ediyor. Release
APK derlenip birleşmiş manifest okunarak App ID'nin doğru geçtiği doğrulandı.

## Bilinen açık noktalar
- **Test cihazı kimliği boş.** `AdService.testDeviceIds` altyapısı hazır ama
  liste boş. Gerçek telefonda release derlemesi denenecekse cihaz kimliği
  eklenmeli — **kendi reklamına tıklamak AdMob hesabını kapattırabilir.**
  Emülatörler otomatik test cihazı sayıldığı için onlarda gerekmiyor.
- **Sayaç yedeğe giriyor.** `getAllSettings()` tüm ayarları döndürdüğü için
  `txSaveCountSinceAd` kullanıcının JSON yedeğine yazılıyor. Zararsız.
- ~~Sürüm numarası yükseltilmedi.~~ **TAMAM (2026-08-25):** `pubspec.yaml`
  `1.6.0+13`. Bekleyen reklamsız 1.5.1 AAB'si etkilenmedi (sürüm dosyaya
  gömülü).
