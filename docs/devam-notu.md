# BudgetFlow — Devam Notu

Proje: `~/Desktop/calismalar/yayim/budgetflow` (Flutter, Android; kişisel gelir/gider takip uygulaması, tamamen çevrimdışı, tüm veri cihazda SQLite). Arayüz Türkçe, para birimi ₺, font Manrope, tema indigo-mor (#6C5CE7).

## Güncel durum (2026-08-20)

- **Play'de YAYINDA:** 1.5.0 / versionCode **11** üretim kanalında. Üretim erişimi başvurusu onaylandı.
- **Sürüm tek kaynağı:** `pubspec.yaml` → şu an **`1.5.1+12`** (kod hazır, **Play'e yüklenmedi**).
- **AAB hazır (2026-08-20):** `build/app/outputs/bundle/release/app-release.aab` — 1.5.1 / versionCode 12, imzalı, 47,6 MB. Play'e yüklenmeyi bekliyor.
- **Gizlilik politikası YAYINDA:** https://ibrahimyasar68.github.io/budgetflow-privacy/
- **Sağlık:** `flutter analyze` temiz, `flutter test` **46/46** geçiyor. DB şema sürümü **10** (değişmedi). Yedek dosyası şeması **2**. targetSdk/compileSdk 36.
- **DİKKAT — çalışma dizininde reklam kodu var (commit edilmedi).** `pubspec.yaml` artık **`1.6.0+13`** (2026-08-25'te yükseltildi). Bundan sonraki her derleme 1.6.0/13 üretir. **Bekleyen reklamsız 1.5.1 AAB'si etkilenmedi** — sürümü dosyaya gömülü: `build/app/outputs/bundle/release/app-release.aab`, 20 Ağustos, 1.5.1/versionCode 12.
- **Play'de üretim durumu:** **12 (1.5.1) YAYINDA** — 2026-08-25 18:38'de gönderildi, 18:55'te yayınlandı (Gönderim 11). Aşamalı değil, **doğrudan tam kullanıma sunuldu (%100)**. Dağıtım **3 ülke/bölge**.

## SIRADAKİ İŞLER

1. ~~Ekran görüntülerini Play'e yükle~~ — **TAMAM (2026-08-20).** `docs/play-ekran-goruntuleri/` altındaki 8 kare (01-giris … 08-koyu-tema) Ana mağaza girişi → Telefon ekran görüntüleri alanına yüklendi.
2. ~~1.5.1'i yayınla~~ — **TAMAM (2026-08-25).** versionCode 12 üretimde, %100.
3. **1.6.0'ı (reklamlı) yayınla** — aşağıdaki yayın kapısı listesi.

## 1.6.0 yayın kapısı

Reklam kodu yazıldı ve test edildi ama **yayına hazır değil**. Sırayla:

**AdMob hesabı (senin)**
1. AdMob'da uygulamayı `com.ibrahimyasar.budgetflow` ile oluştur → **App ID**.
2. İki reklam birimi aç: Banner + Geçiş → **2 Ad Unit ID**.
3. Test cihazının reklam kimliğini not al.

**Kod**
4. ~~Gerçek App ID + iki Ad Unit ID~~ — **TAMAM (2026-08-25).** Kimlikler `docs/surum-notlari-1.6.0.md` §8'de; release manifest'ten doğrulandı.
5. Test cihazı kimliği — `AdService.testDeviceIds` altyapısı hazır, **liste boş**. Gerçek telefonda release denenecekse doldurulmalı. **Kendi reklamına tıklamak AdMob hesabını kapattırabilir.** Emülatörde gerekmiyor.
6. ~~Sürümü `1.6.0+13` yap~~ — **TAMAM.**

**Play Console (AAB yüklemeden önce)**
7. ~~Dağıtımı yalnızca Türkiye ile sınırla~~ — **GEREKSİZ (2026-08-25).** Hedef ülkeler: **Azerbaycan, Türkiye, Türkmenistan** — üçü de AEA/BK dışında, Google'ın CMP/UMP şartı geçerli değil. Sürüm "hedeflenen tüm ülkeler" ile yayınlanabilir. **Kalıcı kural: hedef listeye bir AEA/BK ülkesi eklenecekse önce UMP rıza akışı koda eklenmeli.**
8. Uygulama içeriği → **Reklam Kimliği** beyanı: "Uygulamanız reklam kimliği kullanıyor mu?" → **Evet**, amaç olarak **Reklam veya pazarlama** (istersen + sahtekarlık önleme). Alttaki "AD_ID iznini eklememenin sonuçlarını anlıyorum / sürüm hatalarını kaldır" kutusu **işaretlenmez** — izin zaten SDK tarafından manifest'e ekleniyor (release manifest'inden doğrulandı). ~~TAMAM (2026-08-25)~~
9. Uygulama içeriği → **Reklamlar** → "Evet, uygulamamda reklam var". (Reklam Kimliği beyanından ayrı bir kalem.)
10. Veri Güvenliği formunu güncelle (`docs/play-veri-guvenligi.md` yanıt kağıdı hazır). **Toplama ve paylaşma amaçları birebir aynı olmalı** — önizlemede biri "Reklam veya pazarlama", diğeri "Sahtekarlığı önleme + Reklam veya pazarlama" çıkarsa tutarsızdır.
11. İçerik derecelendirme anketini yeniden doldur (reklam sorusunun cevabı değişti).
12. Mağaza girişini `docs/play-magaza-metni.md`'deki yeni metinle güncelle → **Değişiklikleri gönder** (ayrı inceleme kalemi; basmazsan mağazada hâlâ "Reklamsız" yazar).
13. ~~Gizlilik politikasını `budgetflow-privacy` reposunda güncelle~~ — **TAMAM (2026-08-25).** Canlı sayfa `docs/privacy/index.html` ile birebir aynı, doğrulandı. (Eski hali: gizlilik politikasını `budgetflow-privacy` reposunda güncelle — `docs/privacy/index.html` ile **birebir aynı** olmalı. **Bunu Veri Güvenliği formunu göndermeden ÖNCE yap:** formun önizlemesi bu URL'yi gösteriyor, sayfa hâlâ "internete bağlanmaz, reklam ağı kullanılmaz" derken formda "reklam kimliği toplanıyor/paylaşılıyor" demek doğrudan çelişki olur. Metin sürümlendiği için ("1.6.0'dan itibaren") erken yayınlamak sorun değil.)

    **Yükleme tuzakları** (üç denemede öğrenildi): dosyayı tarayıcıda açıp kopyalama — etiketler kayboluyor; **Add file → Upload files** ile Finder'dan sürükle. Yükleme ekranının altındaki **"Commit changes"** düğmesine basmayı unutma. `index.html` kökte yoksa Pages README.md'yi render eder. Doğrularken URL'ye `?v=2` ekle, önbellek yanıltmasın.

**Doğrulama ve yayın**
13. ~~Cihazda uçtan uca dene~~ — **TAMAM (2026-08-25).** Emülatörde (Android 14) senaryo çalıştırıldı: limit ₺3.500, üç ₺50 gider (sayaç 1→3), sonra ₺500 gider → limit aşıldı, **uyarı snackbar'ı göründü ve reklam ÇIKMADI**, sayaç 4'te bekledi; beşinci kayıtta geçiş reklamı açıldı (`com.google.android.gms.ads.AdActivity`) ve sayaç 0'a döndü. Banner tam genişlikte, kaydırma refaktörü sorunsuz.
14. ~~`flutter build appbundle --release`~~ — **TAMAM.** `build/app/outputs/bundle/release/app-release.aab`, 52,9 MB, 1.6.0 / versionCode 13, AAB manifest'inde gerçek AdMob App ID doğrulandı.
15. **KALAN:** AAB'yi üretime yükle (ülke kısıtı gerekmiyor) → %20 → %50 → %100.

> **Yükleme sırasında çıkan "AD_ID izni yok" hatası yanıltıcıdır.** 1.6.0'ın manifestinde izin var (AAB baytlarından doğrulandı); hata üretimde hâlâ etkin olan reklamsız versionCode 12 yüzünden. Çözüm: **"İzin olmadan yayınla"**. "Beyanı güncelle" seçilmemeli — 1.6.0 gerçekten reklam kimliği kullanıyor. 1.6.0 %100'e ulaşınca hata kaybolur.

4. İstenirse fikir havuzundan bir sonraki iyileştirme turu.

## 1.5.1'de ne var (yayınlanmayı bekliyor)

Ayrıntı: `docs/surum-notlari-1.5.1.md`

1. **Yedek, tekrarlayan işlem kurallarını içermiyordu — veri kaybı düzeltmesi.** Ayarlar'da "tüm veri" denmesine rağmen yedek yalnızca işlem + ayar taşıyordu; telefon değiştiren kullanıcı kurallarını sessizce kaybediyordu. Yedeğe `recurring` bölümü eklendi (`BackupService.schemaVersion` 1→2), geri yükleme `DatabaseService.replaceAllRecurringRules` ile tek işlemde yazıyor. Yalnızca kuralı olup işlemi olmayan kullanıcı da artık yedek alabiliyor.
2. **Sistem çubukları temayla uyumsuzdu.** Açık temada durum çubuğu saati/simgeleri beyaz kalıyordu (okunmuyordu) ve alt gezinme çubuğu siyah şerit olarak duruyordu. `app_theme.dart`'a `background(Brightness)` + `overlayStyle(Brightness)` (→ `AppBarTheme.systemOverlayStyle`) + `brandOverlayStyle` eklendi; splash ve welcome `AnnotatedRegion` ile sarıldı.
3. **Geri yükleme onay metni:** "mevcut tüm işlem**lerin** bununla değiştirilecek" → "mevcut veriler bununla değiştirilecek"; içe aktarılacak kural sayısı da gösteriliyor.

Doğrulama: cihazda uçtan uca denendi — yedek al (schema 2, 124 işlem + 3 kural) → kuralları sil → geri yükle → 3 kural döndü; schema 1 yedeği geri yüklendiğinde mevcut kurallar korundu.

## Kritik kurallar / tuzaklar

- **Kategori özelliği YOK** — sınıflandırma **not/etiket** alanıyla yapılır (boş not → "Diğer"). Metinlerde asla "kategori" yazma.
- **versionCode her yüklemede artmalı.** Play'de en yüksek **11** → sıradaki **12**. Zaten yüklü bir kodu tekrar yüklemeye çalışırsan *"11 sürüm kodu daha önce kullanıldı"* hatası gelir; o durumda **"Kitaplıktan ekle"** (veya kapalı testten "Promote") kullanılır, yeniden yükleme değil.
- **Yedek geri uyumluluğu:** `BackupData.recurring` **nullable**. `null` = yedekte `recurring` bölümü yok (schema 1) → mevcut kurallara **dokunma**. Boş liste = schema 2, kural yokken alınmış → kuralları temizle. Bu ayrım kaldırılırsa eski yedek geri yüklemek kuralları siler.
- **Finans kategorisi** → gizlilik politikası URL'si zorunlu (girildi).
- **İmza:** `android/app/upload-keystore.jks`, alias `upload`; parolalar `android/key.properties` içinde **düz metin**. Bu proje **asla** public repoya konmamalı. Gizlilik sayfası bu yüzden ayrı repoda: `github.com/ibrahimyasar68/budgetflow-privacy`.
- **Emülatörde imza uyuşmazlığı:** `adb install -r` "signatures do not match" derse `adb uninstall` + temiz kurulum gerekir (veritabanı gider, `seed.sql` ile yeniden basılır).
- **Play'in "uçtan uca ekran" uyarıları gerçek kusur değil** — Android 16 (API 36) emülatöründe kontrol edildi: başlık, alt gezinme çubuğu ve modal "Kaydet" butonu sistem çubuklarıyla çakışmıyor. Uyarı Flutter motorunun deprecated API kullanımından geliyor.

## Ekran görüntüleri

`docs/play-ekran-goruntuleri/` — 8 kare, 1080×1920 (9:16), 24-bit PNG, alfa yok. Sıra ve yeniden üretme komutları klasördeki `README.md`'de. Emülatörde `wm size 1080x1920` + `wm density 360`, SystemUI demo modu (saat 9:41, pil dolu, Wi-Fi `fully true`) ve 124 işlemlik demo veri ile çekildi. Karşılama ekranı için `settings` tablosundan `onboardingSeen` silinip uygulama yeniden başlatılır.

## Sürüm geçmişi (iterasyon kanıtı)

- **1.2.1:** Türkçe tarih seçici (flutter_localizations), grafik kapsam tutarlılığı, üçlü tema (Sistem/Açık/Koyu), not önerisi harf-duyarsız birleştirme, "Son 7 Gün", etiket renk tutarlılığı.
- **1.3.0:** Aylık bütçe limiti + ana ekran bütçe kartı + aşım uyarısı.
- **1.4.0:** JSON yedekleme/geri yükleme, not(etiket) bazlı bütçeler, tekrarlayan işlemler, home_page refactor (sekmeler ayrı dosyalara).
- **1.5.0:** (a) Yedekten geri yükleme hatası düzeltildi — kök neden FilePicker'ın Android'de `withData` ile `bytes=null` döndürmesi + `FileType.custom` filtresi; çözüm: filtre kaldırıldı + path fallback (`utils/file_bytes*.dart` koşullu import) + BOM ayıklama. (b) Yedeği doğrudan **cihaza kaydetme** (FilePicker.saveFile). (c) Tekrarlayan işlemlere **başlangıç-bitiş ay aralığı** + "Süresiz" (DB v10, endYear/endMonth, `month_year_picker.dart`). (d) İşlem listesinde baş harf rozeti tutar rengiyle uyumlu.
- **1.5.1 (yayınlanmadı):** yukarıdaki üç düzeltme.

## Play Console — hazır metinler (docs/ altında)

- `docs/play-magaza-metni.md` — uygulama adı, kısa (≤80) + tam açıklama.
- `docs/play-veri-guvenligi.md` — Veri Güvenliği formu yanıtları. **1.6.0 için güncellendi:** reklam kimliği toplanıyor/paylaşılıyor, "Reklam içerir" evet, dağıtım Türkiye ile sınırlı. 1.5.1 ve öncesinin "hiç veri toplanmıyor" yanıtları dosyanın altında arşivde.
- `docs/play-uretim-surum-notu.md` — üretim sürüm notu (`<tr-TR>`).
- `docs/surum-notlari-1.5.0.md`, `docs/surum-notlari-1.5.1.md` — teknik notlar.
- `docs/privacy/index.html` — gizlilik sayfasının proje içindeki kopyası. Değiştirirsen `budgetflow-privacy` reposundakini de güncelle.

## Arşiv — üretim erişimi başvurusunda kullanılan cevaplar

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

## Fikir havuzu (yayın sonrası)

- Hatırlatma/bütçe bildirimi (izin gerektirir).
- İşlem sekmesini ayrı widget'a taşıma (`home_page.dart` hâlâ ~900 satır).
- Widget testleri (şu an tümü birim testi).
- Ana ekranda işlem listesine ayrılan alan dar (kartlar + arama + filtre çipleri sonrası ~2 satır görünüyor); liste sayfası veya daraltılabilir başlık düşünülebilir.
- Flutter sürümünü yükseltip Play'in edge-to-edge deprecated API uyarılarını kapatma.
