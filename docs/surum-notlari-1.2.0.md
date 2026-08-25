# Sürüm Notları — 1.2.0 (versionCode 9)

## Play Console'a yapıştırılacak metin

Play Console → sürüm notları alanına aşağıdaki bloğu **etiketleriyle birlikte** yapıştır:

```
<tr-TR>
• Yeni: Kullanım Kılavuzu eklendi (Ayarlar > Kullanım Kılavuzu)
• Yeni: Animasyonlu açılış ekranı
• Yenilenen tema ve yazı tipi (Manrope) ile daha modern görünüm
• İşlem ekleme ekranında iyileştirmeler
• Hata düzeltmeleri ve performans iyileştirmeleri
</tr-TR>
```

(Karakter sınırı dil başına 500'dür; yukarıdaki metin ~280 karakter, sınırın içinde.)

## Yükleme adımları (Closed testing)

1. [play.google.com/console](https://play.google.com/console) → BudgetFlow uygulaması.
2. Sol menü: **Test et ve yayınla → Test → Kapalı test** (Closed testing) → mevcut kanal → **Yeni sürüm oluştur** (Create new release).
3. App bundle alanına şu dosyayı sürükle-bırak:
   `build/app/outputs/bundle/release/app-release.aab` (1.2.0 / versionCode 9, imza doğrulandı)
4. "Version code already used" hatası gelirse: **App bundle explorer**'daki en yüksek koda bak, `pubspec.yaml` içinde build numarasını ona +1 yap (örn. `1.2.0+10`), `flutter build appbundle --release` ile yeniden derle, tekrar yükle.
5. Sürüm notlarını yukarıdaki bloktan yapıştır.
6. **İncele ve yayınla** (Review release) → uyarı yoksa **Kullanıma sunmayı başlat** (Start rollout).
7. Yükleme sonrası kontrol: App bundle explorer'da 9 (veya yeni kod) görünmeli; testçilere güncelleme birkaç saat içinde düşer.

## Sonrası

- Testçilere duyuru: `docs/test-gorev-metni.md` içindeki görev metni + anket bağlantısını gönder.
- 14 günlük aktif test sürecinde 1-2 küçük güncelleme planla (Google'ın iterasyon kanıtı için) — fikir havuzu: bütçe limiti/uyarı, hatırlatma bildirimi, tekrarlayan işlem, yedekleme.
