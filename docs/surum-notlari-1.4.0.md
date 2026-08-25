# Sürüm Notları — 1.4.0 (versionCode 10)

> Not: Bu AAB, Play'de yüklü olan versionCode 9'un ardından **versionCode 10** olarak hazırlandı. Güncelleme 1+2+3'ün tamamını (birikmiş özellikler) içerir; tek yüklemede hepsi yayına girer.

Üçüncü iterasyon. Üç yeni özellik + iç mimari düzenlemesi.

## Play Console'a yapıştırılacak metin

```
<tr-TR>
• Yeni: Yedekleme ve geri yükleme (JSON) — verini taşı, koru
• Yeni: Etiket bazlı bütçe limitleri (Ayarlar > Bütçeler)
• Yeni: Tekrarlayan işlemler — her ay otomatik ekleme
• Kullanım kılavuzu yeni özelliklerle güncellendi
• Performans ve kod iyileştirmeleri
</tr-TR>
```

(~215 karakter, 500 sınırının içinde.)

## Bu sürümdeki değişiklikler (teknik)

### 1. Yedekleme / Geri Yükleme
- Ayarlar > Veri > **Yedek Oluştur**: tüm işlemler + bütçe ayarları JSON olarak paylaşılır (`budgetflow_yedek_<tarih>.json`). Cihazdan bağımsız; başka kuruluma taşınabilir.
- **Yedekten Geri Yükle**: `file_picker` ile JSON seçilir, onay sonrası tüm işlemler değiştirilir (tek SQLite işleminde). Bozuk/yabancı dosyalar anlamlı hata mesajıyla reddedilir.
- Yeni: `lib/utils/backup_service.dart` (saf, test edilir), `DatabaseService.replaceAllTransactions`, `getAllSettings`. Yeni bağımlılık: `file_picker`.

### 2. Etiket (not) bazlı bütçeler
- Ayarlar > **Bütçeler** ekranı: aylık toplam limit + her etiket için ayrı limit. İçinde bulunulan ayın harcamasına göre ilerleme çubuğu ve kalan/aşım.
- Limitler `settings.noteBudgets` içinde JSON olarak saklanır (`lib/utils/budget_store.dart`, test edilir). Yeni ekran: `lib/screens/budgets_page.dart`.

### 3. Tekrarlayan işlemler
- İşlem eklerken **"Her ay tekrarla"**; kural `recurring` tablosunda tutulur (DB v9 migration). Açılışta ve işlem sonrası vadesi gelen aylar otomatik üretilir (çift kayıt olmaz; kısa aylarda gün kırpılır).
- Ayarlar > **Tekrarlayan İşlemler** ekranından kurallar görülüp durdurulur (geçmiş işlemler korunur).
- Yeni: `lib/models/recurring_rule.dart`, `lib/utils/recurring_service.dart` (saf `dueMonths`/`clampDay` test edilir), `lib/screens/recurring_page.dart`.

### 4. Refactor (davranış değişmeden)
- 1620 satırlık `home_page.dart` → ~900 satırlık kabuk (yalnızca İşlem sekmesi + gezinme). Grafik ve Ayarlar sekmeleri ayrı widget'lara taşındı: `lib/screens/tabs/chart_tab.dart`, `settings_tab.dart`.
- Ortak parçalar paylaşılır hale getirildi: `widgets/empty_state.dart`, `widgets/month_selector.dart`, `utils/label_color.dart`, `utils/month_names.dart`, `utils/fade_route.dart`.

## Doğrulama

- `flutter analyze`: temiz (0 sorun).
- `flutter test`: 29/29 geçti (yeni: backup round-trip, recurring dueMonths/clampDay, budget store).
- AAB: `build/app/outputs/bundle/release/app-release.aab` — versionName 1.4.0 / versionCode 10, imza doğrulandı (jarsigner: "jar verified"). 47,6 MB. (`flutter.versionCode=10` doğrulandı.)

## Yükleme

Adımlar önceki sürümlerle aynı (Kapalı test → Yeni sürüm → AAB'yi bırak → notları yapıştır → İncele ve yayınla). Bu AAB önceki tüm güncellemeleri (1.2.1, 1.3.0) kapsar.

## Testçilere sorulabilecek anket soruları
- "Yedekleme/geri yükleme işine yaradı mı, kolay mıydı?"
- "Etiket bazlı bütçe limitlerini kullandınız mı?"
- "Tekrarlayan işlem özelliğini denediniz mi?"
