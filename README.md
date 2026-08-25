# BudgetFlow

Gelir ve giderlerini hızlıca kaydedip takip edebileceğin minimal bir kişisel finans uygulaması. Flutter ile geliştirilmiştir; verilerini cihazda yerel olarak (SQLite) saklar — bulut, hesap ya da internet gerektirmez.

## Özellikler

- 💸 **Gelir / gider takibi** — tutar, tarih ve not ile işlem ekleme, düzenleme, silme
- 📊 **Grafikler** — gelir/gider pasta grafiği, son 6 ayın çubuk grafiği ve nota göre gider dağılımı
- 💰 **Anlık bakiye** — toplam gelir, gider ve bakiye özet kartı
- 🌗 **Açık / koyu tema** — seçim kalıcı olarak saklanır
- 📱 **Mobil + Web** — Android ve web (sqflite FFI) desteği
- 🔒 **Çevrimdışı & gizli** — tüm veriler yalnızca cihazda

Para birimi değerleri yuvarlama hatasını önlemek için **kuruş (tam sayı)** olarak saklanır.

## Teknolojiler

- [Flutter](https://flutter.dev) (Dart SDK ^3.9.2)
- [sqflite](https://pub.dev/packages/sqflite) — yerel veritabanı
- [fl_chart](https://pub.dev/packages/fl_chart) — grafikler
- [intl](https://pub.dev/packages/intl) — para/tarih biçimlendirme (tr_TR)
- [package_info_plus](https://pub.dev/packages/package_info_plus) — sürüm bilgisi

## Kurulum

```bash
flutter pub get
flutter run            # bağlı cihaz/emülatör
flutter run -d chrome  # web
```

## Test

```bash
flutter test
```

## Proje Yapısı

```
lib/
├── main.dart                 # uygulama girişi, tema ve onboarding yönlendirmesi
├── database/
│   └── database_service.dart # SQLite erişimi ve migration'lar
├── models/
│   └── transaction.dart      # İşlem modeli (tutar kuruş cinsinden)
├── screens/
│   ├── welcome_page.dart     # ilk açılış karşılama ekranı
│   ├── home_page.dart        # işlem listesi, grafikler, ayarlar
│   ├── transaction_sheet.dart# işlem ekleme/düzenleme alt sayfası
│   └── about.dart            # hakkında
└── utils/                    # tema, biçimlendiriciler, db init, yardımcılar
```

## Sürümleme

Sürüm `pubspec.yaml` içindeki `version` alanından gelir ve Hakkında ekranında
`package_info_plus` ile dinamik gösterilir.

---

Ibrahim YASAR — ibrahimyasar68@hotmail.com
