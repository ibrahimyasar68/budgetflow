import 'package:flutter_test/flutter_test.dart';
import 'package:personal_finance_tracker/utils/ad_service.dart';

void main() {
  group('AdService.decideAfterSave', () {
    test('sırası gelmemişse sayaç artar, reklam çıkmaz', () {
      final d = AdService.decideAfterSave(rawCount: '1', adReady: true);
      expect(d.showAd, isFalse);
      expect(d.nextCount, 2);
    });

    test('dördüncü kayıtta reklam çıkar ve sayaç sıfırlanır', () {
      final d = AdService.decideAfterSave(rawCount: '3', adReady: true);
      expect(d.showAd, isTrue);
      expect(d.nextCount, 0);
    });

    test('ilk kayıtta reklam çıkmaz (kutlama anı korunur)', () {
      final d = AdService.decideAfterSave(rawCount: null, adReady: true);
      expect(d.showAd, isFalse);
      expect(d.nextCount, 1);
    });

    test('reklam hazır değilse sayaç eşikte kırpılır, sınırsız büyümez', () {
      // Çevrimdışı kullanım: sırası gelmiş ama reklam yok.
      var d = AdService.decideAfterSave(rawCount: '3', adReady: false);
      expect(d.showAd, isFalse);
      expect(d.nextCount, 4);

      // Peş peşe kayıtlarda 4'te kalır (5, 6, 7... diye birikmez).
      d = AdService.decideAfterSave(rawCount: '4', adReady: false);
      expect(d.nextCount, 4);
      d = AdService.decideAfterSave(rawCount: '4', adReady: false);
      expect(d.nextCount, 4);
    });

    test('kırpılan sayaç bağlantı gelince ilk kayıtta reklamı gösterir', () {
      final d = AdService.decideAfterSave(rawCount: '4', adReady: true);
      expect(d.showAd, isTrue);
      expect(d.nextCount, 0);
    });

    test('skipThisRound reklamı erteler, sıra kaybolmaz', () {
      // Bütçe aşım uyarısı gösterildiği için bu tur atlanır.
      final skipped = AdService.decideAfterSave(
        rawCount: '3',
        adReady: true,
        skipThisRound: true,
      );
      expect(skipped.showAd, isFalse);
      expect(skipped.nextCount, 4);

      // Bir sonraki kayıtta reklam çıkar.
      final next = AdService.decideAfterSave(rawCount: '4', adReady: true);
      expect(next.showAd, isTrue);
      expect(next.nextCount, 0);
    });

    test('bozuk veya negatif sayaç değeri sıfırdan sayılır', () {
      expect(
        AdService.decideAfterSave(rawCount: 'abc', adReady: true).nextCount,
        1,
      );
      expect(
        AdService.decideAfterSave(rawCount: '-7', adReady: true).nextCount,
        1,
      );
    });

    test('everyNSaves değiştirilebilir', () {
      final d = AdService.decideAfterSave(
        rawCount: '1',
        adReady: true,
        everyNSaves: 2,
      );
      expect(d.showAd, isTrue);
      expect(d.nextCount, 0);
    });
  });
}
