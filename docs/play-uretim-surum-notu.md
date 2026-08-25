# Üretim Sürüm Notu — BudgetFlow 1.5.0 (versionCode 11)

> **TARİHSEL KAYIT — yeniden kullanma.** Bu not 1.5.0 yayınlanırken kullanıldı ve
> "reklamsız" ifadesi geçiyor; 1.6.0'dan itibaren doğru değil. Güncel metinler
> aşağıdaki 1.5.1 ve 1.6.0 bölümlerinde.

Üretim (production) sürümü, ilk kez geniş kitleye açıldığından, "neler değişti"
yerine uygulamayı tanıtan bir not daha uygundur.

## Play Console → Üretim sürüm notu (yapıştır)

```
<tr-TR>
BudgetFlow'a hoş geldin! Gelir ve giderini çevrimdışı, reklamsız ve gizli şekilde takip et.

• Gelir/gider ekle, notlarla sınıflandır
• Aylık ve tüm zamanlar özeti, grafikler
• Aylık ve etiket bazlı bütçe limitleri
• Tekrarlayan işlemler (ay aralığı seçilebilir)
• JSON/CSV yedekleme, cihaza kaydetme, geri yükleme
• Açık/Koyu/Sistem teması

Tüm verilerin yalnızca cihazında saklanır.
</tr-TR>
```

(Play sürüm notu dil başına 500 karakter sınırındadır; yukarısı sınır içinde.)

## Yalın alternatif (daha kısa)
```
<tr-TR>
Gelir ve giderini çevrimdışı takip et: notlarla sınıflandırma, grafikler, bütçe limitleri, tekrarlayan işlemler ve JSON/CSV yedekleme. Reklamsız; tüm verilerin cihazında kalır.
</tr-TR>
```

## Aşamalı yayın önerisi
İlk üretim yayınında %20 ile başlayıp sorun görülmezse birkaç günde %50 → %100'e
çıkar. Sürüm: versionName 1.5.0 / versionCode 11 (imzalı AAB hazır).

---

# Üretim Sürüm Notu — BudgetFlow 1.5.1 (versionCode 12)

1.5.0 zaten üretimde olduğu için bu sefer "neler değişti" biçiminde bir not uygun.

## Play Console → Üretim sürüm notu (yapıştır)

```
<tr-TR>
Bu sürümde:

• Yedekleme artık tekrarlayan işlem kurallarını da içeriyor. Telefon değiştirdiğinde ya da yedekten döndüğünde kuralların da geri geliyor.
• Açık temada durum çubuğu ve alt gezinme çubuğu artık temayla uyumlu görünüyor.
• Geri yükleme onayı, içe aktarılacak kural sayısını da gösteriyor.

Eski yedeklerin uyumlu: geri yüklediğinde mevcut kuralların korunur.
</tr-TR>
```

## Aşamalı yayın
%20 → sorun görülmezse birkaç gün içinde %50 → %100.
Sürüm: versionName 1.5.1 / versionCode 12.

---

# Üretim Sürüm Notu — BudgetFlow 1.6.0 (versionCode 13)

Reklamların geldiği sürüm. Kullanıcıya bunu açıkça söylemek doğru olur — güncelleme
sonrası sürpriz reklam, olumsuz yorumun en hızlı yolu.

## Play Console → Üretim sürüm notu (yapıştır)

```
<tr-TR>
Bu sürümde:

• BudgetFlow artık reklam içeriyor. Uygulamanın geliştirilmeye devam edebilmesi için alt tarafta bir banner ve arada bir tam ekran reklam gösteriliyor.
• Finansal verilerin eskisi gibi yalnızca cihazında kalıyor. İşlemlerin, notların ve bütçelerin hiçbir şekilde paylaşılmıyor.
• Bütçe limitini aştığın uyarı gösterilirken reklam çıkmıyor; uyarıyı kaçırmıyorsun.
</tr-TR>
```

## Aşamalı yayın
%20 ile başla ve en az birkaç gün bekle. İzlenecek iki şey:
- **Play vitals** — çökme/ANR artışı (reklam SDK'sı en sık burada sorun çıkarır).
- **AdMob doldurma oranı** — sıfıra yakınsa kimlikler ya da hesap onayı sorunlu.

Sorun yoksa %50 → %100.

## Yayın öncesi zorunlu
Bu sürüm notunu yapıştırmadan önce `docs/devam-notu.md` içindeki
"1.6.0 yayın kapısı" listesi kapatılmış olmalı — özellikle gerçek AdMob
kimlikleri, Veri Güvenliği formu, "Reklam içerir" beyanı ve dağıtımın
Türkiye ile sınırlanması.
