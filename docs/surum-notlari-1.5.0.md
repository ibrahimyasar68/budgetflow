# Sürüm Notları — 1.5.0 (versionCode 11)

Testçi geri bildirimleri sonrası düzeltme + iyileştirme sürümü.

## Play Console'a yapıştırılacak metin

```
<tr-TR>
• Düzeltme: Yedekten geri yükleme artık güvenilir çalışıyor
• Yeni: Yedeği doğrudan cihaza kaydetme seçeneği
• Tekrarlayan işlemlere ay aralığı (başlangıç–bitiş) seçme
• İşlem listesinde tutar rengiyle uyumlu renkli etiket harfleri
• Küçük iyileştirmeler
</tr-TR>
```

(~215 karakter, sınır içinde.)

## Değişiklikler (teknik)

### 1. Yedekten geri yükleme hatası düzeltildi
- **Kök neden:** `FilePicker` Android'de `withData: true` ile bazı içerik sağlayıcılarından (Downloads, Drive vb.) dosyayı seçtiğinde `bytes` alanını `null` döndürüyordu; kod da `FormatException('Dosya okunamadı.')` fırlatıyordu. Ayrıca `FileType.custom` + `allowedExtensions: ['json']` bazı dosya yöneticilerinde seçimi engelliyordu.
- **Çözüm:** Tür filtresi kaldırıldı (herhangi bir dosya seçilebilir; içerik doğrulanıyor). `bytes` yoksa dosya `path`'ten okunuyor (web'i bozmadan koşullu import: `utils/file_bytes*.dart`). Olası UTF-8 BOM ayıklanıyor, hata mesajları netleştirildi. (`backup_service.dart`, `home_page.dart`)

### 2. Cihaza yerel kaydetme
- Ayarlar > Veri > **Cihaza Kaydet**: `FilePicker.saveFile` ile yedek JSON'u kullanıcının seçtiği konuma (Downloads vb.) yazılır — paylaşım gerektirmez. (`home_page.dart`, `settings_tab.dart`)

### 3. Tekrarlayan işlemlere ay aralığı
- İşlem eklerken "Her ay tekrarla" açılınca **Başlangıç ayı** ve **Bitiş ayı** seçilebiliyor (ör. Ocak 2026 – Aralık 2026); "Süresiz" seçeneği de var. Yeni ay-yıl seçici: `widgets/month_year_picker.dart`.
- Kural artık `endYear`/`endMonth` tutuyor (DB v10 migration, geriye dönük uyumlu — mevcut kurallar süresiz kalır). Üretim bitiş ayında durur. Tekrarlama artık seriyi aralık boyunca üretir (`recurring_service.dart`, `recurring_rule.dart`, `transaction_sheet.dart`, `recurring_page.dart` — aralık gösterimi).

### 4. Etiket harfi rengi
- İşlem listesindeki baş harf rozeti (A, M…) artık tutar rengiyle aynı: gelir yeşil, gider kırmızı. (`home_page.dart`)

## Doğrulama
- `flutter analyze`: temiz (0 sorun).
- `flutter test`: 32/32 geçti (yeni: tekrar aralık sınırı senaryoları).
- AAB: `build/app/outputs/bundle/release/app-release.aab` — versionName 1.5.0 / versionCode 11 (`flutter.versionCode=11` doğrulandı), imza doğrulandı ("jar verified"), 47,6 MB.

## Yükleme
Play Console → Kapalı test → Yeni sürüm → AAB'yi bırak → yukarıdaki notu yapıştır → İncele ve yayınla. "Version code 11 already used" derse pubspec'te `+12` yapıp yeniden derle.
