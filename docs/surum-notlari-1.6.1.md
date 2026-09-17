# BudgetFlow 1.6.1 — Teknik Sürüm Notları

Sürüm: versionName **1.6.1** / versionCode **14**. Veritabanı şeması (10) ve
yedek dosyası şeması (2) değişmedi; reklam mantığına dokunulmadı.

## 1. Android 15+ gezinme çubuğu içeriği örtüyordu
targetSdk 36 olduğu için Android 15 ve üstünde uygulama sistem gezinme
çubuğunun **altına** çiziliyor. 3 düğmeli gezinme kullanan cihazlarda bu çubuk
48 dp yer kaplıyor ve şu yerlerin altını örtüyordu:

- **Yeni İşlem / İşlemi Düzenle** sayfası — Kaydet düğmesinin alt yarısı çubuğun
  altında kalıyordu (en görünür sorun).
- **Hakkında, Kullanım Kılavuzu, Tekrarlayan İşlemler, Bütçeler** — listenin
  son öğeleri çubuğun arkasına giriyordu.

Sebep: `Scaffold.bottomNavigationBar`, `SafeArea` ve padding'i verilmemiş
`ListView` sistem çubuğunu kendisi hesaplar; **elle `padding` verilen
`ListView`'ler ve modal bottom sheet'ler hesaplamaz.**

Çözüm: bu beş yerde alt boşluğa `MediaQuery.paddingOf(context).bottom`
eklendi. Klavye açıkken Flutter bu değeri 0'a indirdiği için çift boşluk
oluşmuyor. Ana sayfa sekmeleri (işlemler, grafik, ayarlar)
`bottomNavigationBar`'lı Scaffold içinde olduğundan değişmedi.

Önceki "uçtan uca ekran uyarısı gerçek kusur değil" değerlendirmesi hareketli
gezinmeyle yapılmıştı; ince tutamaç sorunu gizliyordu.

Doğrulama: Android 16 emülatörü, 1080×1920, 3 düğmeli gezinme — önce/sonra
ekran görüntüsü, uzun liste (Kılavuz) sonu ve klavye açık işlem sayfası.
Android 8'deki gerçek cihazda sorun zaten görünmüyordu.

## 2. "Uygulamadan Çık" kaldırıldı
Ayarlar'ın sonundaki öğe, onay penceresi ve `SystemNavigator.pop()` çağrısı
silindi (`SettingsTab.onExit`, `HomePage._confirmExit`). Android'de uygulamayı
koddan kapatmak önerilmiyor; çıkış telefonun geri / ana ekran tuşuyla yapılıyor.
`settings_tab.dart`'taki gereksiz hale gelen `foundation.dart` importu da
kaldırıldı.

## 3. Yeni İşlem sayfasında Gider önce ve varsayılan
- Tür seçicide **Gider solda**, Gelir sağda.
- Yeni işlem **Gider** seçili açılıyor (kayıtların çoğu harcama).
- Düzenlemede işlemin kendi türü korunuyor (`e?.type ?? TransactionType.gider`),
  yani mevcut bir gelir kaydı yanlışlıkla gidere dönmüyor.

## 4. Gerçek cihaz test kimliği
`AdService.testDeviceIds` içine Samsung SM-A720F'nin kimliği eklendi. Bu
kimlik cihaza değil **kuruluma** bağlı (app set ID); uygulama kaldırılıp
yeniden kurulursa değişir. Ayrıntı: `docs/devam-notu.md` → AdMob.

## Test
`flutter analyze` temiz, `flutter test` **46/46**. Değişiklikler yerleşim ve
varsayılan değer düzeyinde olduğu için yeni birim testi eklenmedi; emülatörde
gözle doğrulandı.

## Mağaza görselleri
`docs/play-ekran-goruntuleri/` altındaki işlem sayfası karesi Gelir'i seçili
ve solda gösteriyor. İsteğe bağlı olarak yenilenebilir; zorunlu değil.
