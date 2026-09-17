# BudgetFlow — Devam Notu

Proje: `~/Desktop/calismalar/yayim/budgetflow` (Flutter, Android; kişisel gelir/gider takip uygulaması, tüm veri cihazda SQLite). Arayüz Türkçe, para birimi ₺, font Manrope, tema indigo-mor (#6C5CE7).

## Güncel durum (2026-09-17)

- **Play üretim:** **14 (1.6.1) yayında, %100** (2026-09-17'de gönderildi, aşamalı sunum yapılmadan doğrudan %100). 13 (1.6.0) ve 12 (1.5.1) sürümlerinin yerini aldı; tüm kullanıcılar reklamlı sürüme geçiyor.
- Gönderimde çıkan iki bildirim beklenen türdendi: AD_ID hatası → **"İzin olmadan yayınla"**, kod gösterme dosyası uyarısı → yok sayıldı (ikisi de aşağıda *Play Console* bölümünde).
- **Sürüm tek kaynağı:** `pubspec.yaml` → **`1.6.1+14`**. 14 yüklendi → sıradaki versionCode **15**.
- **AAB:** ana klasörde `build/app/outputs/bundle/release/app-release.aab` — **1.6.1 / 14**, 52,9 MB, yüklendi.
- **Kaynak kodu:** https://github.com/ibrahimyasar68/budgetflow (**public**), 1.6.1 commit'i `c71fcdf` push edildi (2026-09-17).
- **Gizlilik politikası:** https://ibrahimyasar68.github.io/budgetflow-privacy/ — AdMob bölümü eklenmiş sürüm yayında, `docs/privacy/index.html` ile birebir aynı.
- **Hedeflenen ülkeler:** Azerbaycan, Türkiye, Türkmenistan.
- **Gerçek cihaz testi (2026-08-26):** Samsung SM-A720F (Android 8.0, arm64) üzerinde 1.6.0 **release** derlemesi denendi. Banner ve dört kayıtta bir geçiş reklamı ikisi de **"Test Reklamı"** etiketiyle geldi, logcat *"This request is sent from a test device"* dedi; çökme/ANR yok. Cihaz kimliği `AdService.testDeviceIds`'e yazıldı.
- **Sağlık:** `flutter analyze` temiz, `flutter test` **46/46**. DB şema sürümü **10**, yedek dosyası şeması **2**. targetSdk/compileSdk 36, minSdk 24.

## Sıradaki işler

1. **1.6.1'i izle** (%100'de olduğu için geri dönüş ancak yeni sürümle olur): ilk günlerde Play vitals (çökme/ANR) ve AdMob doldurma oranı / gelir. Sorun çıkarsa hızlı düzeltme için sıradaki versionCode **15**.
   Bir sonraki gönderimde AD_ID hatası **çıkmamalı** — reklamsız sürüm artık üretimde etkin değil. Çıkarsa sebep kapalı/dahili test kanallarında hâlâ etkin olan eski reklamsız bir sürümdür: o kanalı duraklat ya da güncelle.
2. **`app-ads.txt` kur.** Reklam birimi kimlikleri artık public repoda görünür; bu dosya envanteri sahte satıcılara karşı korur. Gerektirdiği: `ibrahimyasar68.github.io` adında **yeni bir repo** ve kökünde tek satırlık `app-ads.txt`. İçeriği AdMob → Uygulamalar → app-ads.txt altında hazır.
3. ~~Test cihazı kimliği~~ — **tamam.** SM-A720F'nin kimliği `AdService.testDeviceIds`'te. Başka bir cihaz eklenecekse aşağıdaki AdMob bölümündeki **app set ID** tuzağını oku. **Kendi reklamına tıklamak AdMob hesabını kapattırabilir.**
4. ~~1.6.1'i yükle ve push et~~ — **tamam (2026-09-17).** İsteğe bağlı kalan: mağaza görsellerindeki işlem sayfası karesi Gelir'i seçili ve solda gösteriyor, yenilenebilir.
5. İstenirse fikir havuzundan bir sonraki tur.

## Kritik kurallar / tuzaklar

**Uygulama**
- **Kategori özelliği YOK** — sınıflandırma **not/etiket** alanıyla yapılır (boş not → "Diğer"). Metinlerde asla "kategori" yazma.
- **Yedek geri uyumluluğu:** `BackupData.recurring` **nullable**. `null` = schema 1 yedeği, `recurring` bölümü yok → mevcut kurallara **dokunma**. Boş liste = schema 2, kural yokken alınmış → kuralları temizle. Bu ayrım kaldırılırsa eski yedek geri yüklemek kuralları siler.

- **Android 15+ kenardan kenara (edge-to-edge):** targetSdk ≥ 35 olduğu için Android 15+ cihazlarda uygulama sistem gezinme çubuğunun **altına** çizilir. `Scaffold.bottomNavigationBar`, `SafeArea` ve padding'siz `ListView` bunu kendisi hesaplar; **elle `padding` verilen `ListView`'ler ve modal bottom sheet'ler hesaplamaz**. Kural: böyle bir yerde alt boşluğa `MediaQuery.paddingOf(context).bottom` ekle (klavye açıkken 0 olur, çift boşluk yapmaz). 2026-09-15'te düzeltilenler: `transaction_sheet.dart`, `about.dart`, `guide_page.dart`, `recurring_page.dart`, `budgets_page.dart`. Ana sayfa sekmeleri (işlemler/grafik/ayarlar) `bottomNavigationBar`'lı Scaffold içinde, onlara gerek yok. Android 8'deki A7'de görünmez — test için Android 15+ ve **3 düğmeli gezinme** şart.

**Depo ve imza**
- Proje **public** (`github.com/ibrahimyasar68/budgetflow`). Güvenliği `.gitignore`'a bağlı: `android/app/upload-keystore.jks` (alias `upload`) ve parolaları düz metin tutan `android/key.properties` dışlanıyor. **Bu iki dosya asla commit edilmemeli** — bir kez girerse silinse bile git geçmişinde kalır.
- **Git worktree'de release derlemesi çalışmaz:** `android/key.properties` ve `android/app/upload-keystore.jks` `android/.gitignore` kapsamında olduğu için worktree'ye kopyalanmaz, `flutter build apk --release` imzalama hatası verir. Ana checkout'tan elle kopyala; gitignore orada da geçerli, commit'e girmezler.
- `docs/iletisim-yerel.md` (telefon, ikinci e-posta, Forms düzenleme bağlantısı) ve `docs/test.txt` de yok sayılıyor. Testçilere metin gönderirken gerçek değerleri `docs/iletisim-yerel.md`'den al; `docs/test-gorev-metni.md`'deki karşılıkları maskeli.
- AdMob kimlikleri gizli değil (her APK'dan çıkarılabiliyor), public repoda bulunmaları sorun değil.
- `gh` CLI yok. Push SSH ile çalışıyor (`~/.ssh/id_ed25519_skorekran`, GitHub'da `ibrahimyasar68`); remote'lar **SSH URL** olmalı, HTTPS kimlik sorar.

**Play Console**
- **versionCode her yüklemede artmalı.** Zaten yüklü bir kodu tekrar yüklersen *"… sürüm kodu daha önce kullanıldı"* hatası gelir; o durumda "Kitaplıktan ekle" kullanılır, yeniden yükleme değil.
- **"AD_ID izni yok" hatası yanıltıcıdır.** 1.6.0 ve 1.6.1'in manifestinde izin var (AAB'den doğrulandı); hata üretimde hâlâ etkin olan reklamsız versionCode 12 yüzünden — Play, uygulama düzeyindeki beyanı **tüm etkin yapılarla** karşılaştırıyor. Çözüm: **"İzin olmadan yayınla"**. "Beyanı güncelle" seçilmemeli. Reklamlı bir sürüm %100'e ulaşınca hata kaybolur. 1.6.0 ve 1.6.1 gönderimlerinde aynı hata çıktı, ikisinde de bu yolla geçildi.
- **Mağaza girişi ayrı bir inceleme kalemi** — metni değiştirdikten sonra "Değişiklikleri gönder"e basmazsan yayına girmez, sürüm yüklemesiyle otomatik gitmez.
- **Veri Güvenliği formu:** toplama ve paylaşma amaçları **birebir aynı** olmalı; önizlemede biri fazladan madde gösteriyorsa tutarsızdır.
- **Rıza yönetimi (UMP) yok.** Google'ın CMP şartı yalnızca AEA/BK için geçerli, hedef ülkelerin üçü de dışında. **Kalıcı kural: hedef listeye bir AEA/BK ülkesi eklenecekse önce UMP rıza akışı koda eklenmeli.**
- Play'in "uçtan uca ekran" uyarısının **deprecated API kısmı** Flutter motorundan geliyor, uygulama kodu değil. **Ama yerleşim sorunu gerçekti:** önceki kontrol hareketli gezinmeyle yapılmıştı (ince tutamaç), 3 düğmeli gezinmede işlem sayfasının Kaydet düğmesi çubuğun altında kalıyordu. Ayrıntı ve kural aşağıda *Uygulama* bölümünde.
- "Kod gösterme dosyası yok" uyarısı geçersiz: `build.gradle`'da `minifyEnabled false`, karartma yok. `minifyEnabled true` yapılırsa her sürümde `build/app/outputs/mapping/release/mapping.txt` de yüklenmeli.

**AdMob**
- Reklam birimi oluştururken **"İş ortağı teklifli sistem"** kutusu işaretli bırakılırsa birim AdMob talebiyle dolmaz ve **sonradan değiştirilemez**.
- **Test cihazı kimliği kuruluma bağlı, cihaza değil.** GMA SDK'sı kimliği *app set ID*'den türetiyor; uygulamayı **kaldırıp yeniden kurmak kimliği değiştirir** (aynı telefonda debug kurulumu `0E44…`, ardından gelen release kurulumu `1ECC…` verdi). Doğru sıra: test edilecek derlemeyi kur → logcat'ten kimliği oku → koda yaz → **`pm install -r` ile üzerine kur** (kaldırma yok, kimlik korunur). Arada `adb uninstall` yaparsan kimlik yine değişir ve gerçek reklam gösterilir.
- Kimlik doğru yazıldıysa logcat'teki `setTestDeviceIds` **ipucu satırı kaybolur** ve yerine *"This request is sent from a test device."* gelir. Reklamların üstünde "Test Reklamı" etiketi görünür.
- Yeni birimlerin reklam vermeye başlaması bir saat kadar sürebilir; yeni uygulama onayı da birkaç gün alabilir. Boş banner'da ilk şüphelenilecek şey kimlik hatası değil, bunlar.

**GitHub web arayüzüyle dosya yükleme** (gizlilik sayfası üç denemede oturdu)
- Dosyayı tarayıcıda/önizlemede açıp kopyalamak HTML etiketlerini yok eder → sayfa düz metin yığını olarak yayınlanır. **Add file → Upload files** ile Finder'dan sürükle.
- Yükleme ekranında dosyayı sürüklemek yetmez, altındaki **"Commit changes"** düğmesine basmak şart.
- `index.html` repo kökünde yoksa GitHub Pages **README.md**'yi render eder.
- Doğrularken URL'ye `?v=2` gibi bir parametre ekle, tarayıcı/CDN önbelleği yanıltmasın.

**Gerçek cihaz (SM-A720F, 1080×1920)**
- USB bağlantısı kararsız: `adb push`/`install` sık sık *"device not found"* / *"error: closed"* ile düşüyor. Büyük APK'yı `adb install` yerine **`adb push` + `adb shell pm install`** ile kurmak daha güvenilir; komutları yeniden deneme sarmalına al.
- Debug APK 152 MB (tüm ABI'ler), release `--target-platform android-arm64` ile 29 MB.
- UI otomasyon koordinatları: FAB (964, 1460), işlem sayfası +100 (310, 965), Kaydet (540, 1790), karşılama "Hemen Başla" (540, 1775).
- Debug derlemesi `DEBUGGABLE` olduğu için `run-as … cat databases/financeDb.db` ile DB yedeklenebilir; release'te çalışmaz. Debug→release geçişi imza değiştirdiği için `adb uninstall` gerektirir ve **veriyi siler**.

**Emülatör**
- **3 düğmeli gezinmeye geçiş** (kenar sorunlarını görmek için; hareketli gezinme sorunu gizler): `adb shell cmd overlay enable-exclusive --category com.android.internal.systemui.navbar.threebutton`. Geri almak için aynı komutta `navbar.gestural`.
- `flutter_emulator` (Android 16) AVD'sinde **release imzalı 1.5.0** kurulu, veri yedeklenemiyor (`run-as` çalışmaz) — debug kurulumu imza hatası verir, kaldırmak veriyi siler. Temiz testler için ayrı **`bf_kenar_test`** AVD'si (Android 16, 1080×1920, 420 dpi) oluşturuldu.
- Taze açılan emülatörde "Digital Wellbeing isn't responding" penceresi dokunuşları yutabiliyor; önce "Wait"e bas.
- `adb` PATH'te değil: `export PATH="$PATH:$HOME/Library/Android/sdk/platform-tools"`.
- `adb install -r` "signatures do not match" derse `adb uninstall` + temiz kurulum gerekir (DB gider).
- Debug derlemesi Google test reklam birimlerini kullanır, emülatörde gerçek test reklamı yüklenir. Emülatör otomatik test cihazı olduğu için yanlışlıkla reklama tıklamak risk değil.
- UI otomasyonunda banner yüklendikten sonra FAB yukarı kayar: banner varken ≈ (964, 1876), yokken ≈ (964, 2044) (1080×2400). İşlem sayfası: Gider (809, 1012), +50 (128, 1381), +500 (502, 1381), Kaydet (539, 2204).
- Demo veri gerekirse `run-as com.ibrahimyasar.budgetflow sqlite3 …` ile INSERT çalışıyor; test öncesi DB'yi kopyalayıp sonra geri yükle.

## Ekran görüntüleri

`docs/play-ekran-goruntuleri/` — 8 kare, 1080×1920 (9:16), 24-bit PNG, alfa yok. Sıra ve yeniden üretme komutları klasördeki `README.md`'de. Emülatörde `wm size 1080x1920` + `wm density 360`, SystemUI demo modu (saat 9:41) ve 124 işlemlik demo veri ile çekildi. Karşılama ekranı için `settings` tablosundan `onboardingSeen` silinip uygulama yeniden başlatılır.

> **Not:** Kareler 1.5.x arayüzüne ait. 1.6.0'da ana ekrana banner eklendi ve kartlar listeyle birlikte kayacak şekilde değişti; mağaza görselleri bir tur yenilenebilir.

## Sürüm geçmişi

- **1.2.1:** Türkçe tarih seçici, grafik kapsam tutarlılığı, üçlü tema, not önerisi harf-duyarsız birleştirme, "Son 7 Gün", etiket renk tutarlılığı.
- **1.3.0:** Aylık bütçe limiti + ana ekran bütçe kartı + aşım uyarısı.
- **1.4.0:** JSON yedekleme/geri yükleme, etiket bazlı bütçeler, tekrarlayan işlemler, home_page refactor.
- **1.5.0:** Yedekten geri yükleme hatası (FilePicker `bytes=null` + `FileType.custom`), cihaza kaydetme, tekrarlayan işlemlere ay aralığı (DB v10), liste rozeti rengi.
- **1.5.1:** Yedek tekrarlama kurallarını taşımıyordu (veri kaybı düzeltmesi, backup şeması 1→2), sistem çubuğu tema uyumu, geri yükleme onay metni. `docs/surum-notlari-1.5.1.md`.
- **1.6.0:** AdMob entegrasyonu (adaptive banner + dört kayıtta bir geçiş reklamı), bütçe uyarısı × reklam çakışması düzeltmesi, sayaç saf fonksiyona ayrıldı + kırpıldı, ana ekran `CustomScrollView`'a taşındı (görünen satır 2 → 8). `docs/surum-notlari-1.6.0.md`.
- **1.6.1:** Android 15+ gezinme çubuğunun Kaydet düğmesini ve liste sonlarını örtmesi düzeltildi, "Uygulamadan Çık" kaldırıldı, Yeni İşlem'de Gider solda ve varsayılan, gerçek cihaz test kimliği. `docs/surum-notlari-1.6.1.md`.

## docs/ altındaki hazır metinler

- `play-magaza-metni.md` — uygulama adı, kısa (≤80) + tam açıklama. **1.6.0 için güncellendi:** "reklamsız/reklam yok" ifadeleri kaldırıldı.
- `play-veri-guvenligi.md` — Veri Güvenliği formu yanıt kağıdı. **1.6.0 için güncellendi:** cihaz kimliği toplanıyor/paylaşılıyor, amaç reklamcılık. 1.5.1 ve öncesinin yanıtları dosyanın altında arşivde.
- `play-uretim-surum-notu.md` — üretim sürüm notları (`<tr-TR>`), 1.5.0 / 1.5.1 / 1.6.0 / 1.6.1 bölümleri.
- `surum-notlari-1.5.0.md`, `surum-notlari-1.5.1.md`, `surum-notlari-1.6.0.md`, `surum-notlari-1.6.1.md` — teknik notlar. AdMob kimlikleri 1.6.0'ın §8'inde.
- `privacy/index.html` — gizlilik sayfasının proje içindeki kopyası. Değiştirirsen `budgetflow-privacy` reposundakini de güncelle, **birebir aynı kalmalı**.
- `test-gorev-metni.md`, `geri-bildirim-anketi.md` — testçi belgeleri.

## Fikir havuzu

- **`app-ads.txt`** (yukarıda 2. madde) — en somut olanı.
- Hatırlatma/bütçe bildirimi (izin gerektirir).
- İşlem sekmesini ayrı widget'a taşıma (`home_page.dart` ~1130 satır).
- Widget testleri (şu an tümü birim testi).
- Banner'ı ana ekran yerine grafik/ayarlar sekmesine almak — liste alanı kaydırma refaktörüyle rahatladı ama banner hâlâ 50 dp yer kaplıyor.
- `txSaveCountSinceAd` kullanıcı yedeğine giriyor (`getAllSettings()` hepsini alıyor); zararsız ama ayıklanabilir.
- Flutter sürümünü yükseltip edge-to-edge deprecated API uyarılarını kapatma.
- `minifyEnabled true` ile APK boyutunu küçültme (1.6.0 indirme boyutunu 13 → 18 MB'a çıkardı).

## Arşiv — üretim erişimi başvurusu cevapları

(Başvuru onaylandı; ileride benzer bir form çıkarsa diye duruyor.)

- **Testçileri nereden buldun:** Aile, yakın arkadaş çevresi ve tanıdıklar; Android'i olan, kişisel bütçeye ilgili kişilere tanıtıldı; ücretli sağlayıcı kullanılmadı.
- **Test kullanıcısı bulmak ne kadar kolaydı:** Ne zor ne de kolay.
- **Testçilerden nasıl etkileşim:** "Uygulama sade olduğu için kullanıcılar özelliklerin tümünü denedi: gelir/gider ekleme, notla sınıflandırma, aylık ve etiket bazlı bütçe limitleri, tekrarlayan işlemler, grafikler ve yedekleme. Kullanım beklediğim gibiydi; uygulama stabil çalıştı, çökme yaşanmadı."
- **Geri bildirim özeti:** "Geri bildirimi yüz yüze görüşme ve mesajlaşmayla topladım. Öneriler doğrultusunda birkaç güncelleme yaptım: tarih seçiciyi Türkçeleştirdim, tema seçeneklerini artırdım, bütçe limiti ve tekrarlayan işlem ekledim, yedekten geri yükleme sorununu düzelttim ve menü erişimini sadeleştirdim."
- **Hedef kitle:** Bireysel kullanıcılar; öğrenci/çalışan/ev bütçesi yönetenler; muhasebe bilgisi gerektirmez.
- **Değer önermesi:** "Gelir ve giderleri hızlıca kaydedip notlara göre gruplar; grafikler, bütçe limitleri ve tekrarlayan işlemlerle takibi kolaylaştırır. Veriler yalnızca cihazda saklanır; internet gerektirmez, gizlilik korunur. Sade arayüzüyle herkes için erişilebilir."
- **İlk yıl yükleme beklentisi:** 0–10 bin.
- **Hangi değişiklikleri yaptın:** "Kullanıcı geri bildirimlerine göre birçok güncelleme yaptım: tarih seçiciyi Türkçeleştirdim, açık/koyu/sistem teması ekledim, aylık ve etiket bazlı bütçe limitleri ile tekrarlayan işlemler ekledim, yedekleme/geri yüklemeyi getirip bir hatayı düzelttim ve arayüzü sadeleştirdim."
- **Üretime hazır olduğuna nasıl karar verdin:** "Test sürecinde uygulama stabil çalıştı, çökme yaşanmadı. Tüm özellikler beklendiği gibi çalıştı. Kullanıcı geri bildirimlerini uyguladıktan sonra olumlu sonuçlar aldım. Bu gözlemlere dayanarak yayına hazır olduğuna karar verdim."
- **Ek test — "Bu sefer neleri farklı yaptınız?":** "Bu turda testçilerin bildirdiği yedekten geri yükleme hatasını giderdim ve düzeltmeyi yeniden test ettirdim. Ayrıca yedeği doğrudan cihaza kaydetme seçeneği ekledim, tekrarlayan işlemlere başlangıç-bitiş ayı aralığı getirdim ve liste görünümünde küçük iyileştirmeler yaptım."
