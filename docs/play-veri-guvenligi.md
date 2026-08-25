# Play Console — Veri Güvenliği Formu Yanıt Kağıdı (BudgetFlow)

> **Bu kağıt 1.6.0 (reklamlı) sürüm içindir.** 1.5.1 ve öncesi için geçerli olan
> "hiç veri toplanmıyor" yanıtları en altta arşivde duruyor.
>
> Uygulama 1.6.0'dan itibaren Google AdMob kullanıyor. Kullanıcının kendi
> finansal verisi (işlemler, notlar, bütçeler, tekrarlama kuralları) hâlâ
> **yalnızca cihazda** — o kısım değişmedi. Değişen şey, reklam SDK'sının
> cihaz/reklam kimliğini işlemesi ve bunun Google ile paylaşılması.
> **Beyanlar senin sorumluluğunda**; aşağısı kodun gerçek davranışını yansıtır.

## Veri toplama ve paylaşımı
- **Uygulamanız kullanıcı verisi topluyor veya paylaşıyor mu?**
  → **Evet.** (Uygulamanın kendisi değil, içindeki AdMob SDK'sı.)

## Toplanan ve paylaşılan veri türleri

### Cihaz veya diğer kimlikler — TOPLANIYOR ve PAYLAŞILIYOR
- **Ne:** Reklam kimliği (Advertising ID) ve reklam sunumu için gereken cihaz
  bilgileri.
- **Toplayan:** Google Mobile Ads SDK (`google_mobile_ads` 7.x).
- **Amaç:** **Reklamcılık veya pazarlama.**
- **Paylaşılıyor mu:** Evet — reklam sunumu için Google ile.
- **Zorunlu mu:** Evet, kullanıcı bunu kapatamaz (uygulama içinde reklamsız
  seçenek yok). "Kullanıcılar bu verinin toplanmasını seçebilir mi?" → Hayır.
- **Doğrulama:** Birleşmiş AndroidManifest'te SDK'nın kendi eklediği izinler:
  `com.google.android.gms.permission.AD_ID`,
  `android.permission.ACCESS_ADSERVICES_AD_ID`,
  `ACCESS_ADSERVICES_ATTRIBUTION`, `ACCESS_ADSERVICES_TOPICS`.

### 4. adım (Veri kullanımı ve işleme) — "Cihaz veya diğer kimlikler" yanıtları
| Soru | Yanıt |
|---|---|
| Toplanıyor mu | Evet |
| Paylaşılıyor mu | Evet (reklam sunumu için Google ile) |
| Geçici olarak mı işleniyor | Hayır |
| Kullanıcı seçebiliyor mu | Hayır — zorunlu (uygulamada reklamsız seçenek yok) |
| Amaç | Reklamcılık veya pazarlama |

> **Tuzak:** "neden toplanıyor" ve "neden paylaşılıyor" listeleri **birebir
> aynı** olmalı. Önizlemede paylaşım amacında fazladan bir madde görürsen
> (ör. sahtekarlık önleme) geri dönüp eşitle — veri, toplanmadığı bir amaçla
> paylaşılıyor görünmemeli.

### 3. adımda (Veri türleri) işaretlenen tek tür
**Cihaz veya diğer kimlikler.** Diğer tüm kategoriler 0 kalır — özellikle
**Finansal bilgiler 0/4**: girilen tutarlar cihazdan çıkmıyor, reklam ağına
gitmiyor. Bu, incelemede sorgulanabilecek yer olduğu için bilerek boş.

### Kontrol edilmesi gereken iki tür
AdMob yapılandırmasına göre bunların da işaretlenmesi gerekebilir. Formu
doldurmadan önce Google'ın AdMob yayıncıları için yayımladığı veri güvenliği
rehberine bak; orada hangi türlerin zorunlu olduğu güncel haliyle yazıyor.
- **Konum (yaklaşık):** AdMob IP adresinden ülke/bölge düzeyinde konum
  çıkarabiliyor.
- **Uygulama etkinliği / uygulama içi etkileşimler:** Reklam gösterimi ve
  tıklama ölçümü.

### Toplanmayan türler (işaretlenmez)
- **Finansal bilgiler** — girdiğin tutarlar cihazdan hiç çıkmıyor; banka, kart,
  ödeme veya kredi verisi yok. Bu, uygulamanın en önemli ayrımı: **reklam
  kimliği paylaşılıyor, finansal veri paylaşılmıyor.**
- Kişisel bilgiler (ad, e-posta, telefon) · Kişiler · Fotoğraf/video/ses ·
  Sağlık · Mesajlar · Takvim · Dosyalar

## Güvenlik uygulamaları
- **Veriler aktarımda şifreleniyor mu?** → **Evet.** AdMob istekleri HTTPS
  üzerinden gidiyor.
- **"Kullanıcıların, verilerinin silinmesini talep edebilecekleri bir yöntem
  sağlıyor musunuz?" (isteğe bağlı)** → **Hayır.**
  Bu soru, kullanıcının *senin tuttuğun* veriyi silmeni talep edebileceği bir
  mekanizmayı (pratikte bir silme talebi URL'si) soruyor. Hesap sistemi ve
  sunucu olmadığı için verilecek bir adres yok. Uygulamayı kaldırınca verinin
  gitmesi bu sorunun kapsamı değil.
  (2026-08-25 düzeltmesi: burada önce "Evet" yazıyordu; form gerçekte talep
  mekanizması soruyor, doğrusu "Hayır".)

## Formun 2. adımındaki diğer yanıtlar
- **Veri topluyor/paylaşıyor mu?** → Evet
- **Hesap oluşturma yöntemleri** → "Uygulamam kullanıcıların hesap
  oluşturmasına izin vermiyor"
- **Dışarıda oluşturulan hesapla giriş?** → Hayır
- **Ek rozetler** (bağımsız güvenlik değerlendirmesi / UPI) → hiçbiri;
  ilki ücretli üçüncü taraf denetimi (MASA), ikincisi Hindistan'a özgü.

## İlgili diğer beyanlar (Uygulama içeriği bölümü)
- **Reklamlar:** **Evet, uygulama reklam içeriyor.** (Banner + geçiş reklamı.)
- **İçerik derecelendirmesi:** Anket yeniden doldurulmalı — reklam sorusunun
  yanıtı değişti.
- **Uygulama erişimi:** Tüm işlevler özel erişim (giriş/hesap) olmadan
  kullanılabilir. Değişmedi.
- **Hedef kitle:** 18+ (veya 13+); çocuklara yönelik değil. Değişmedi —
  bu önemli, çünkü çocuklara yönelik olsaydı reklam kimliği kullanımı Families
  politikası altında ek kısıt getirirdi.
- **Finansal özellikler:** Gerçek para transferi, bankacılık, kredi, yatırım
  veya kripto işlemi yok; yalnızca kişisel gelir/gider kaydı. Değişmedi.
- **Devlet/sağlık/haber uygulaması:** Hayır.

## Dağıtım ve rıza yönetimi
Uygulamada UMP/CMP rıza akışı **yok**. Google'ın onaylı rıza mekanizması şartı
yalnızca **AEA ve Birleşik Krallık** kullanıcıları için geçerli.

**Hedeflenen ülkeler (2026-08-25'te doğrulandı): Azerbaycan, Türkiye,
Türkmenistan.** Üçü de AEA/BK dışında, dolayısıyla **ek bir dağıtım kısıtına
gerek yok**; sürümler "hedeflenen tüm ülkeler" ile yayınlanabilir.

> ⚠️ **Kalıcı kural:** Hedef listeye bir AEA veya Birleşik Krallık ülkesi
> eklenecekse, **önce UMP rıza akışı koda eklenmelidir**. Aksi halde reklamlı
> sürüm o ülkeye gittiği anda uyumsuz olur.
>
> (Önceki notlarda "dağıtımı Türkiye ile sınırla" yazıyordu; hedef ülkeler
> öğrenilince gereksiz olduğu görüldü ve kaldırıldı.)

---

## Arşiv — 1.5.1 ve öncesi için verilen yanıtlar
Reklam eklenmeden önceki gerçek durum; 1.5.1 üretimde olduğu sürece geçerli.

- **Kullanıcı verisi topluyor veya paylaşıyor mu?** → Hayır. (Veri cihazdan hiç
  ayrılmıyordu; yayın sürümünde hiç izin, internet bağlantısı ve üçüncü taraf
  SDK yoktu.)
- **Aktarımda şifreleme?** → Uygulanmaz; ağ aktarımı yoktu.
- **Silme talebi?** → Evet; işlem silme veya uygulamayı kaldırma.
- **Toplanan veri türleri:** Hiçbiri.
- **Reklamlar:** Hayır, uygulama reklam içermiyordu.
