# Sürüm Notları — 1.2.1 (versionCode 10)

İlk iterasyon güncellemesi. Kullanıcının göreceği 5 iyileştirme; hepsi düşük riskli.

## Play Console'a yapıştırılacak metin

```
<tr-TR>
• Tarih seçici artık tamamen Türkçe
• Grafik sekmesi seçilen ay ile tutarlı çalışıyor
• Tema seçimi: Sistem / Açık / Koyu
• Not önerileri büyük-küçük harf ayrımı olmadan birleşiyor
• Küçük düzeltmeler ve iyileştirmeler
</tr-TR>
```

(~200 karakter, 500 sınırının içinde.)

## Bu sürümdeki değişiklikler (teknik)

1. **Türkçe yerelleştirme** — `flutter_localizations` eklendi; `MaterialApp` artık `Locale('tr')` kullanıyor. Tarih seçici, takvim ve sistem diyalogları Türkçe. (`main.dart`, `pubspec.yaml`)
2. **Grafik kapsam tutarlılığı** — Grafik sekmesi işlem sekmesiyle aynı ay/kapsam seçicisini paylaşıyor. Pasta ve gider dağılımı aynı veri kümesinden hesaplanıyor; yüzdeler artık %100'ü aşmıyor. Seçili ayda veri yoksa "başka ay seç" yönlendirmesi görünüyor. (`home_page.dart`)
3. **Üçlü tema seçimi** — Ayarlar'daki açık/koyu anahtarı, `SegmentedButton` ile Sistem/Açık/Koyu seçenekli hale geldi; kullanıcı "Sistem" moduna geri dönebiliyor. (`home_page.dart`)
4. **Not önerisi birleştirme** — `getDistinctNotes` büyük/küçük harf ve boşluk duyarsız grupluyor; her grup için en sık kullanılan yazımı gösteriyor. (`database_service.dart`)
5. **Etiket & renk düzeltmeleri** — "Bu Hafta" → "Son 7 Gün"; gider dağılımı renkleri liste rozetleriyle eşitlendi (aynı etiket her yerde aynı renk). (`home_page.dart`)

## Doğrulama

- `flutter analyze`: temiz (0 sorun).
- `flutter test`: 17/17 geçti.
- AAB: `build/app/outputs/bundle/release/app-release.aab` — versionName 1.2.1 / versionCode 10, imza doğrulandı (jarsigner: "jar verified").

## Yükleme

Adımlar `docs/surum-notlari-1.2.0.md` ile aynı (Kapalı test → Yeni sürüm → AAB'yi bırak → notları yapıştır → İncele ve yayınla). "Version code already used" hatasında pubspec'te build numarasını App bundle explorer'daki en yüksek koda +1 yap.
