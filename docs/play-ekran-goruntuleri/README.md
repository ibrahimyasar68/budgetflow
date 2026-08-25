# Play Store Ekran Görüntüleri — BudgetFlow 1.5.0

8 adet telefon ekran görüntüsü (Play'in izin verdiği üst sınır). Play Console →
Ana mağaza girişi → Telefon ekran görüntüleri bölümüne **bu sırayla** yüklenir
(ilk 2-3 kare listede en çok görülendir).

| # | Dosya | Ekran |
|---|-------|-------|
| 1 | `01-giris.png` | Giriş/karşılama: marka, slogan, öne çıkan üç özellik |
| 2 | `02-ana-sayfa.png` | Aylık özet kartı + bütçe ilerlemesi |
| 3 | `03-grafik.png` | Gelir/gider halkası + Son 6 Ay çubuk grafiği |
| 4 | `04-butceler.png` | Aylık toplam + etiket bazlı limitler |
| 5 | `05-tekrarlayan.png` | Tekrarlayan işlemler (ay aralığı / süresiz) |
| 6 | `06-yeni-islem.png` | İşlem ekleme, "Her ay tekrarla" seçeneği |
| 7 | `07-ayarlar.png` | Tema seçimi + yedekleme/dışa aktarma |
| 8 | `08-koyu-tema.png` | Koyu tema |

Giriş ekranı başa kondu: marka ve değer önerisini taşıdığı için kapak karesi
gibi çalışıyor. Uygulamayı iş başında gösteren kareyle açmak istersen sırayı
Play Console'da sürükleyerek değiştirebilirsin — dosyaları yeniden adlandırmak
gerekmez.

Giriş ekranı yalnızca ilk kurulumda göründüğü için çekimde `settings` tablosundan
`onboardingSeen` satırı silinip uygulama yeniden başlatıldı.

## Teknik özellikler (Play şartlarına uygun)

- 1080 × 1920 px, **9:16** en-boy oranı
- 24-bit PNG, alfa kanalı yok
- Her biri < 200 KB (sınır 8 MB)
- Durum çubuğu demo modunda: saat 9:41, pil dolu, Wi-Fi tam

## Nasıl üretildi

Android emülatörde (Android 14) 1.5.0 / versionCode 11 çalıştırıldı; ekran
1080×1920'ye, yoğunluk 360'a ayarlandı; uygulama veritabanına Mart–Ağustos 2026
arası 124 işlemlik gerçekçi demo verisi yazıldı (aylık limit ₺40.000, kullanım %68).

Yeniden çekmek için emülatörü aynı duruma getir:

```
adb shell wm size 1080x1920
adb shell wm density 360
adb shell settings put global sysui_demo_allowed 1
adb shell am broadcast -a com.android.systemui.demo -e command enter
adb shell am broadcast -a com.android.systemui.demo -e command clock -e hhmm 0941
adb shell am broadcast -a com.android.systemui.demo -e command battery -e level 100 -e plugged false
adb shell am broadcast -a com.android.systemui.demo -e command network -e wifi show -e level 4 -e fully true
adb shell am broadcast -a com.android.systemui.demo -e command notifications -e visible false
```

Varsayılana dönmek için: `adb shell wm size reset && adb shell wm density reset`
ve `adb shell am broadcast -a com.android.systemui.demo -e command exit`.

Emülatördeki önceki test veritabanı `/data/local/tmp/financeDb.onceki.bak`
yolunda yedeklendi.

## Sürüm notu

Kareler, sistem çubuğu düzeltmesi (1.5.1) uygulandıktan sonra çekildi: açık temada
durum çubuğu simgeleri koyu ve okunur, alt gezinme çubuğu siyah değil. Uygulama
içeriği 1.5.0 ile aynıdır. Ayrıntı: `docs/surum-notlari-1.5.1.md`.
