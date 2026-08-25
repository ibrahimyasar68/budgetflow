# BudgetFlow — Gizlilik Politikası

**Son güncelleme:** 25 Ağustos 2026
**Uygulama:** BudgetFlow (paket adı: `com.ibrahimyasar.budgetflow`)
**Geliştirici:** İbrahim Yaşar — iletişim: ibrahimyasar68@hotmail.com

## Özet
BudgetFlow kişisel bir finans (gelir/gider) takip uygulamasıdır. Girdiğiniz **tüm finansal veriler yalnızca kendi cihazınızda** saklanır; sunucuya gönderilmez, üçüncü taraflarla paylaşılmaz. Uygulamanın tüm özellikleri çevrimdışı çalışır.

**Sürüm 1.6.0'dan itibaren** uygulama reklam içerir. Reklamlar Google AdMob üzerinden sunulur ve bunun için reklam kimliğiniz işlenir. Bu, aşağıda "Reklamlar" bölümünde ayrıntılı açıklanmıştır. **Finansal verileriniz reklam ağıyla paylaşılmaz.**

## Topladığımız veriler
Uygulamanın kendisi **hiçbir kişisel veri toplamaz**: hesap oluşturmanızı istemez, ad/e-posta/telefon gibi kimlik bilgileri toplamaz, kesin konum bilgisi almaz ve kullanım/analiz aracı içermez.

İçindeki reklam bileşeni (Google AdMob) ise reklam gösterebilmek için **reklam kimliğinizi (Advertising ID)** ve reklam sunumu için gereken cihaz bilgilerini işler. Ayrıntı için "Reklamlar" bölümüne bakın.

## Verilerinizin saklanması
Eklediğiniz işlemler (tutar, tür, tarih, not) ve ayarlarınız (tema, bütçe limitleri, tekrarlayan işlem kuralları) cihazınızdaki yerel bir veritabanında (SQLite) tutulur. Bu verilere yalnızca sizin cihazınızdan erişilebilir; geliştirici dahil hiç kimse bu verilere erişemez.

## İzinler
Uygulama, reklamların yüklenebilmesi için **internet izni** (`INTERNET`) ve reklam kimliği izni (`AD_ID`) kullanır. Bunun dışında hassas bir Android izni (konum, kişiler, kamera, mikrofon, depolama vb.) talep etmez. Yedekleme sırasında dosya oluşturma/seçme işlemleri, Android'in standart sistem dosya seçici ekranı üzerinden yapılır; uygulama depolamanıza doğrudan erişmez.

## Reklamlar
Sürüm 1.6.0'dan itibaren uygulama **Google AdMob** ile reklam gösterir.

- **İşlenen veri:** Reklam kimliği (Advertising ID) ve reklam sunumu için gereken cihaz bilgileri. AdMob, IP adresinizden ülke/bölge düzeyinde yaklaşık konum da çıkarabilir.
- **Amaç:** Yalnızca reklam sunumu ve ölçümü.
- **Paylaşım:** Bu veriler reklam sunumu için Google ile paylaşılır. Google'ın bu verileri nasıl kullandığı: https://policies.google.com/technologies/partner-sites
- **Paylaşılmayan:** İşlemleriniz, tutarlar, notlar, bütçe limitleriniz ve tekrarlayan işlem kurallarınız reklam ağına **hiçbir şekilde gönderilmez**. Bu veriler cihazınızdaki veritabanından hiç çıkmaz.
- **Denetiminiz:** Reklam kimliğinizi Android → Ayarlar → Gizlilik → Reklamlar bölümünden sıfırlayabilir veya silebilirsiniz.
- **Dağıtım:** Uygulama yalnızca Türkiye'de dağıtılmaktadır.

## İnternet ve üçüncü taraflar
Uygulamanın internet bağlantısı yalnızca reklam yüklemek için kullanılır. Kayıt tutma, grafikler, bütçeler, yedekleme ve diğer tüm özellikler çevrimdışı çalışır. Google AdMob dışında üçüncü taraf SDK (analiz, izleme, çökme raporlama vb.) **kullanılmaz**.

## Verileriniz üzerindeki denetiminiz
- **Dışa aktarma / yedekleme:** Verilerinizi istediğiniz zaman JSON (tam yedek) veya CSV olarak dışa aktarabilir ya da cihazınıza kaydedebilirsiniz.
- **Silme:** İşlemleri tek tek silebilir veya uygulamayı kaldırarak cihazınızdaki tüm uygulama verilerini kalıcı olarak silebilirsiniz. Verileriniz yalnızca cihazınızda tutulduğundan, kaldırma işlemi tüm verileri yok eder.

## Çocuklar
Uygulama çocuklara yönelik değildir ve çocuklardan bilerek veri toplamaz.

## Değişiklikler
Bu politika güncellenirse, güncel sürüm bu sayfada yayımlanır ve "Son güncelleme" tarihi değiştirilir.

## İletişim
Sorularınız için: **ibrahimyasar68@hotmail.com**

---

# BudgetFlow — Privacy Policy (English)

**Last updated:** August 25, 2026
**App:** BudgetFlow (package: `com.ibrahimyasar.budgetflow`)
**Developer:** İbrahim Yaşar — contact: ibrahimyasar68@hotmail.com

BudgetFlow is a personal finance (income/expense) tracker. All **financial data you enter is stored only on your device**; it is never transmitted to a server or shared with third parties. Every feature works offline.

**Starting with version 1.6.0**, the app displays ads served through Google AdMob, which processes your advertising ID. See "Ads" below. **Your financial data is never shared with the ad network.**

**Data we collect:** The app itself collects no personal data — no account, no identity data, no precise location, no analytics. The bundled ad component (Google AdMob) processes your **advertising ID** and device information needed to serve ads.

**Storage:** Your transactions (amount, type, date, note) and settings (theme, budget limits, recurring rules) are stored in a local SQLite database on your device. No one, including the developer, can access this data.

**Permissions:** The app uses the `INTERNET` and `AD_ID` permissions so ads can load. It requests no other sensitive permissions (location, contacts, camera, microphone, storage). Backup file operations use Android's standard system file picker.

**Ads:** From version 1.6.0 the app shows ads via **Google AdMob**. AdMob processes your advertising ID and device information required to serve and measure ads, and may derive approximate (country/region level) location from your IP address. This data is shared with Google for ad serving — see https://policies.google.com/technologies/partner-sites. Your transactions, amounts, notes, budgets, and recurring rules are **never** sent to the ad network. You can reset or delete your advertising ID under Android → Settings → Privacy → Ads. The app is distributed in Türkiye only.

**Internet & third parties:** The app's internet access is used solely to load ads. Recording transactions, charts, budgets, and backups all work offline. No third-party SDK other than Google AdMob (no analytics, tracking, or crash reporting) is used.

**Your control:** You can export/back up your data (JSON or CSV) at any time, delete transactions individually, or uninstall the app to permanently erase all data.

**Children:** The app is not directed to children and does not knowingly collect data from them.

**Contact:** ibrahimyasar68@hotmail.com
