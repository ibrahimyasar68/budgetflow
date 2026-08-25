import 'package:flutter_test/flutter_test.dart';
import 'package:personal_finance_tracker/models/transaction.dart';

void main() {
  group('Transaction map dönüşümü', () {
    test('toMap / fromMap round-trip verileri korur', () {
      final date = DateTime(2026, 6, 23, 14, 30);
      final tx = Transaction(
        id: 7,
        amount: 12345,
        type: TransactionType.gider,
        date: date,
        note: 'Market',
      );

      final restored = Transaction.fromMap(tx.toMap());

      expect(restored.id, 7);
      expect(restored.amount, 12345);
      expect(restored.type, TransactionType.gider);
      expect(restored.date, date);
      expect(restored.note, 'Market');
    });

    test('type enum index olarak saklanır', () {
      final map = Transaction(
        amount: 100,
        type: TransactionType.gelir,
        date: DateTime(2026),
      ).toMap();

      expect(map['type'], TransactionType.gelir.index);
    });

    test('copyWith yalnızca verilen alanları değiştirir', () {
      final tx = Transaction(
        amount: 100,
        type: TransactionType.gelir,
        date: DateTime(2026),
        note: 'eski',
      );

      final updated = tx.copyWith(amount: 200, note: 'yeni');

      expect(updated.amount, 200);
      expect(updated.note, 'yeni');
      expect(updated.type, TransactionType.gelir);
      expect(updated.date, tx.date);
    });
  });
}
