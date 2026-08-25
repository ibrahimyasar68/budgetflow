import 'package:flutter_test/flutter_test.dart';
import 'package:personal_finance_tracker/utils/formatters.dart';

void main() {
  group('parseAmountCents', () {
    test('düz tam sayıyı kuruşa çevirir', () {
      expect(AppFormatters.parseAmountCents('10'), 1000);
    });

    test('virgüllü ondalığı (tr) kuruşa çevirir', () {
      expect(AppFormatters.parseAmountCents('10,50'), 1050);
    });

    test('binlik ayraçlı tr biçimini çözer', () {
      expect(AppFormatters.parseAmountCents('1.250,75'), 125075);
    });

    test('nokta ondalığı kabul eder', () {
      expect(AppFormatters.parseAmountCents('1250.75'), 125075);
    });

    test('₺ sembolünü ve boşlukları yok sayar', () {
      expect(AppFormatters.parseAmountCents(' ₺ 10,50 '), 1050);
    });

    test('boş veya geçersiz giriş null döner', () {
      expect(AppFormatters.parseAmountCents(''), isNull);
      expect(AppFormatters.parseAmountCents('abc'), isNull);
    });

    test('yuvarlama hatası olmadan kuruşa yuvarlar', () {
      expect(AppFormatters.parseAmountCents('0,1'), 10);
      expect(AppFormatters.parseAmountCents('0,01'), 1);
    });
  });

  group('centsToInput / round-trip', () {
    test('kuruşu düzenleme metnine çevirir', () {
      expect(AppFormatters.centsToInput(1050), '10,50');
      expect(AppFormatters.centsToInput(100000), '1000,00');
    });

    test('parse ve centsToInput tutarlıdır', () {
      const cents = 125075;
      final text = AppFormatters.centsToInput(cents);
      expect(AppFormatters.parseAmountCents(text), cents);
    });
  });
}
