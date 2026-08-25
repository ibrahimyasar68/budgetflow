import 'package:flutter_test/flutter_test.dart';
import 'package:personal_finance_tracker/models/recurring_rule.dart';
import 'package:personal_finance_tracker/models/transaction.dart';
import 'package:personal_finance_tracker/utils/backup_service.dart';

void main() {
  group('BackupService round-trip', () {
    test('işlemleri ve ayarları kayıpsız yedekler/geri okur', () {
      final txs = [
        Transaction(
            amount: 12345,
            type: TransactionType.gelir,
            date: DateTime(2026, 3, 5, 12),
            note: 'Maaş'),
        Transaction(
            amount: 500,
            type: TransactionType.gider,
            date: DateTime(2026, 3, 6),
            note: 'Market, süt'),
      ];
      final json =
          BackupService.buildJson(txs, settings: {'budgetLimit': '50000'});
      final data = BackupService.parseJson(json);

      expect(data.transactions.length, 2);
      expect(data.transactions[0].amount, 12345);
      expect(data.transactions[0].type, TransactionType.gelir);
      expect(data.transactions[0].note, 'Maaş');
      expect(data.transactions[1].note, 'Market, süt');
      expect(data.settings['budgetLimit'], '50000');
    });

    test('BudgetFlow olmayan JSON reddedilir', () {
      expect(() => BackupService.parseJson('{"app":"Other"}'),
          throwsFormatException);
    });

    test('bozuk JSON reddedilir', () {
      expect(() => BackupService.parseJson('{ değil json'),
          throwsFormatException);
    });

    test('eksik alanlı işlemler atlanır, geçerliler kalır', () {
      const json = '''
      {"app":"BudgetFlow","transactions":[
        {"amount":100,"type":1,"date":1000},
        {"amount":null,"type":1,"date":1000},
        {"type":0}
      ]}''';
      final data = BackupService.parseJson(json);
      expect(data.transactions.length, 1);
      expect(data.transactions[0].amount, 100);
    });
  });

  group('BackupService tekrarlama kuralları', () {
    RecurringRule rule({
      int amount = 125000,
      String? note = 'Kira',
      int? endYear,
      int? endMonth,
    }) =>
        RecurringRule(
          amount: amount,
          type: TransactionType.gider,
          note: note,
          dayOfMonth: 3,
          startYear: 2026,
          startMonth: 1,
          lastYear: 2026,
          lastMonth: 8,
          endYear: endYear,
          endMonth: endMonth,
        );

    test('kurallar kayıpsız yedeklenir ve geri okunur', () {
      final json = BackupService.buildJson(
        const [],
        recurring: [
          rule(),
          rule(amount: 25000, note: 'Abonelik', endYear: 2026, endMonth: 12),
        ],
      );
      final rules = BackupService.parseJson(json).recurring;

      expect(rules, isNotNull);
      expect(rules!.length, 2);
      expect(rules[0].amount, 125000);
      expect(rules[0].note, 'Kira');
      expect(rules[0].dayOfMonth, 3);
      expect(rules[0].startMonth, 1);
      expect(rules[0].lastMonth, 8);
      expect(rules[0].hasEnd, isFalse);
      expect(rules[1].note, 'Abonelik');
      expect(rules[1].endYear, 2026);
      expect(rules[1].endMonth, 12);
    });

    test('yeni yedek schema 2 olarak yazılır', () {
      final json = BackupService.buildJson(const []);
      expect(json, contains('"schema": 2'));
      expect(BackupService.schemaVersion, 2);
    });

    test('eski (schema 1) yedekte bölüm yoksa null döner — mevcut kurallar korunur',
        () {
      const json = '{"app":"BudgetFlow","schema":1,"transactions":[]}';
      expect(BackupService.parseJson(json).recurring, isNull);
    });

    test('boş liste null değildir — geri yükleme kuralları temizler', () {
      const json =
          '{"app":"BudgetFlow","schema":2,"transactions":[],"recurring":[]}';
      final rules = BackupService.parseJson(json).recurring;
      expect(rules, isNotNull);
      expect(rules, isEmpty);
    });

    test('geçersiz kurallar atlanır, geçerliler kalır', () {
      const json = '''
      {"app":"BudgetFlow","schema":2,"transactions":[],"recurring":[
        {"amount":1000,"type":1,"dayOfMonth":5,"startYear":2026,"startMonth":1,
         "lastYear":2026,"lastMonth":8},
        {"amount":1000,"type":1,"dayOfMonth":45,"startYear":2026,"startMonth":1,
         "lastYear":2026,"lastMonth":8},
        {"amount":1000,"type":9,"dayOfMonth":5,"startYear":2026,"startMonth":1,
         "lastYear":2026,"lastMonth":8},
        {"amount":1000,"type":1,"dayOfMonth":5}
      ]}''';
      final rules = BackupService.parseJson(json).recurring;
      expect(rules!.length, 1);
      expect(rules[0].dayOfMonth, 5);
    });

    test('yarım bitiş bilgisi süresiz sayılır', () {
      const json = '''
      {"app":"BudgetFlow","schema":2,"transactions":[],"recurring":[
        {"amount":1000,"type":1,"dayOfMonth":5,"startYear":2026,"startMonth":1,
         "lastYear":2026,"lastMonth":8,"endYear":2026}
      ]}''';
      final rules = BackupService.parseJson(json).recurring;
      expect(rules!.single.hasEnd, isFalse);
    });
  });
}
