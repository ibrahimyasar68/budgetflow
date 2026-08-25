# Sürüm Notları — BudgetFlow 1.5.1 (versionCode 12)

Düzeltme sürümü. Veritabanı şeması değişmedi (v10); **yedek dosyası biçimi
schema 1 → 2'ye çıktı** (eski yedekler okunmaya devam eder).

## Düzeltilen 1 — Yedek, tekrarlayan işlem kurallarını içermiyordu

Ayarlar'da "Tüm veriyi JSON olarak paylaş" yazmasına rağmen yedek yalnızca
işlemleri ve ayarları taşıyordu. Telefon değiştiren veya uygulamayı yeniden
kuran kullanıcı **tekrarlama kurallarını sessizce kaybediyordu**.

- Yedeğe `recurring` bölümü eklendi (`schemaVersion` 2).
- Geri yükleme kuralları `DatabaseService.replaceAllRecurringRules` ile tek
  işlemde yazar; yarım kalmış geri yükleme oluşmaz.
- **Eski yedeklerde veri kaybı yok:** `recurring` bölümü hiç yoksa
  `BackupData.recurring` `null` döner ve mevcut kurallara dokunulmaz. Boş liste
  ise (schema 2, kural yokken alınmış yedek) kurallar temizlenir.
- Bozuk kayıtlar atlanır (geçersiz gün/ay/tür); yarım bitiş bilgisi süresiz sayılır.
- Yedek artık yalnızca kuralı olup hiç işlemi olmayan kullanıcıda da alınabilir
  (önceden "Yedeklenecek işlem yok" diyerek engelliyordu).

Geri yükleme onayı da düzeltildi: "mevcut tüm işlemlerin bununla değiştirilecek"
→ "mevcut veriler bununla değiştirilecek", ve içe aktarılacak kural sayısı gösteriliyor.

## Düzeltilen 2 — Sistem çubukları temayla uyumsuzdu

- Açık temada durum çubuğu saati ve simgeleri (Wi-Fi, pil, sinyal) **beyaz**
  kalıyordu; açık gri zeminde neredeyse okunmuyordu.
- Açık temada alt sistem gezinme çubuğu **siyah** bir şerit olarak duruyordu,
  uygulamanın açık zeminiyle uyuşmuyordu.

Kök neden: `AppBarTheme.backgroundColor` şeffaf olduğu için Flutter simge
parlaklığını arka plandan doğru türetemiyordu ve uygulamada hiçbir yerde
`SystemUiOverlayStyle` verilmemişti.

## Değişen dosyalar

- `lib/utils/app_theme.dart`
  - `background(Brightness)` — zemin rengi tek kaynağa taşındı (Scaffold ve
    sistem gezinme çubuğu aynı rengi kullanıyor).
  - `overlayStyle(Brightness)` — durum ve gezinme çubuğu simge parlaklığını
    temaya göre verir; `AppBarTheme.systemOverlayStyle` olarak bağlandı, böylece
    AppBar'lı tüm ekranlar (ana sayfa, bütçeler, tekrarlayan, kılavuz, hakkında)
    otomatik olarak doğru görünür.
  - `brandOverlayStyle` — mor gradyanlı ekranlar için beyaz simge sabiti.
- `lib/screens/splash_screen.dart`, `lib/screens/welcome_page.dart`
  - AppBar kullanmadıkları için `AnnotatedRegion<SystemUiOverlayStyle>` ile
    sarıldı; mor zeminde simgeler beyaz kalır.

## Not — Android 15+ davranışı

`systemNavigationBarColor` Android 15 ve sonrasında yok sayılır (sistem çubuğu
şeffaf çizilir). Bu ayar yalnızca Android 14 ve öncesinde siyah şeridi kaldırır;
yeni sürümlerde zaten sorun oluşmuyor. Play Console'un "uçtan uca ekran"
uyarıları aynı kökten geliyor ve ayrı bir iş olarak ele alınabilir.

## Doğrulama

- `flutter analyze` — temiz
- `flutter test` — 38/38 geçti (yedek kuralları için 6 yeni test)
- Emülatörde (Android 14) açık ve koyu temada elle doğrulandı: açık temada
  simgeler koyu, gezinme çubuğu açık; koyu temada simgeler beyaz.
- Yedek/geri yükleme uçtan uca gerçek cihazda denendi:
  - "Cihaza Kaydet" ile alınan yedek: schema 2, 124 işlem, 3 kural (bitiş
    aralığı dahil doğru).
  - Kurallar silinip yedek geri yüklendi → 3 kural geri geldi.
  - Schema 1 yedeği geri yüklendi → işlemler değişti, **mevcut 3 kural korundu**.
- Android 16 (API 36) emülatöründe uçtan uca ekran davranışı kontrol edildi:
  başlık, alt gezinme çubuğu ve modal sayfadaki "Kaydet" butonu sistem
  çubuklarıyla çakışmıyor — Play'in uyarıları görünür bir kusura yol açmıyor.

## Mağaza görselleri

`docs/play-ekran-goruntuleri/` altındaki 7 ekran görüntüsü bu düzeltmeden sonra
yeniden çekildi.
