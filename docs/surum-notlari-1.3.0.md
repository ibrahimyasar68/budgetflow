# Sürüm Notları — 1.3.0 (versionCode 11)

İkinci iterasyon güncellemesi. Yeni özellik: **Aylık Bütçe Limiti**.

## Play Console'a yapıştırılacak metin

```
<tr-TR>
• Yeni: Aylık bütçe limiti belirle, harcamanı takip et
• Ana ekranda bütçe ilerleme çubuğu ve kalan tutar
• Limit aşıldığında uyarı
• Ayarlar > Aylık Bütçe Limiti'nden aç/kapat
• Küçük iyileştirmeler
</tr-TR>
```

(~190 karakter, 500 sınırının içinde.)

## Bu sürümdeki değişiklikler (teknik)

- **Aylık bütçe limiti** — Ayarlar > "Aylık Bütçe Limiti" ile bir üst sınır belirlenir; `settings` tablosunda `budgetLimit` anahtarıyla kuruş cinsinden saklanır (bildirim izni gerektirmez, çevrimdışı). (`database_service.dart` — `deleteSetting` eklendi)
- **Bütçe kartı** — Ana ekranda, belirli bir ay seçiliyken ve limit tanımlıyken görünür: harcanan / limit, animasyonlu ilerleme çubuğu, kalan (veya aşılan) tutar ve yüzde. Renk kademeli: %85 altı yeşil, %85–100 turuncu, üstü kırmızı. Kart tıklanınca limit düzenlenir. (`home_page.dart` — `_buildBudgetCard`, `_budgetColor`, `_editBudget`)
- **Limit aşım uyarısı** — Bir işlem, içinde bulunulan ayın giderini limiti *ilk kez* aşacak şekilde eklendiğinde snackbar + haptic uyarı. Tekrarlayan işlemlerde spam yapmaz (aşım eşiği yalnızca geçiş anında tetiklenir). (`home_page.dart` — `_openSheet`, `_expenseForMonth`)
- **Bütçe düzenleme diyaloğu** — Tutar girişi, "Kaldır" ve "Kaydet"; geçersiz tutar için satır içi hata. (`budget_dialog.dart` — yeni dosya)

Not: "Tüm Zamanlar" kapsamı seçiliyken bütçe kartı gizlenir (aylık limit tüm zamanlara uygulanmaz).

## Doğrulama

- `flutter analyze`: temiz (0 sorun).
- `flutter test`: 17/17 geçti.
- AAB: `build/app/outputs/bundle/release/app-release.aab` — versionName 1.3.0 / versionCode 11, imza doğrulandı (jarsigner: "jar verified").

## Yükleme

Adımlar önceki sürümlerle aynı (Kapalı test → Yeni sürüm → AAB'yi bırak → notları yapıştır → İncele ve yayınla). "Version code already used" hatasında pubspec'te build numarasını App bundle explorer'daki en yüksek koda +1 yap.

## Testçilere sorulabilecek anket sorusu

- "Aylık bütçe limiti özelliğini kullandınız mı? İlerleme çubuğu ve uyarı işinize yaradı mı?"
