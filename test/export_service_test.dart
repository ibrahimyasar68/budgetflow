import 'package:flutter_test/flutter_test.dart';
import 'package:personal_finance_tracker/models/transaction.dart';
import 'package:personal_finance_tracker/utils/export_service.dart';

void main() {
  group('ExportService.buildCsv', () {
    final txs = [
      Transaction(
        amount: 125075,
        type: TransactionType.gider,
        date: DateTime(2026, 6, 23),
        note: 'Akaryakıt',
      ),
      Transaction(
        amount: 500000,
        type: TransactionType.gelir,
        date: DateTime(2026, 6, 1),
        note: 'Maaş',
      ),
    ];

    test('başlık satırı içerir', () {
      final csv = ExportService.buildCsv(txs);
      expect(csv.split('\r\n').first, 'Tarih,Tür,Not,Tutar');
    });

    test('tutarı nokta ondalıklı kuruşsuz yazar', () {
      final csv = ExportService.buildCsv(txs);
      expect(csv, contains('1250.75'));
      expect(csv, contains('5000.00'));
    });

    test('notu ve tarihi yazar', () {
      final csv = ExportService.buildCsv(txs);
      expect(csv, contains('2026-06-23'));
      expect(csv, contains('Akaryakıt'));
      expect(csv, contains('Maaş'));
    });

    test('notu boş kayıtlara "Diğer" yazar', () {
      final csv = ExportService.buildCsv([
        Transaction(
          amount: 100,
          type: TransactionType.gider,
          date: DateTime(2026, 1, 1),
          note: '   ',
        ),
      ]);
      expect(csv, contains('Diğer'));
    });

    test('virgül içeren notları tırnak içine alır', () {
      final csv = ExportService.buildCsv([
        Transaction(
          amount: 100,
          type: TransactionType.gider,
          date: DateTime(2026, 1, 1),
          note: 'Kahve, çay',
        ),
      ]);
      expect(csv, contains('"Kahve, çay"'));
    });
  });
}
