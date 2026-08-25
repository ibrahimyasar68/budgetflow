import 'package:flutter_test/flutter_test.dart';
import 'package:personal_finance_tracker/utils/recurring_service.dart';
import 'package:personal_finance_tracker/utils/budget_store.dart';

void main() {
  group('RecurringService.dueMonths', () {
    test('son üretilen aydan sonraki ayları içinde bulunulan aya kadar döner', () {
      final months = RecurringService.dueMonths(2026, 1, DateTime(2026, 4, 10));
      expect(months.length, 3); // Şub, Mar, Nis
      expect(months.first, DateTime(2026, 2));
      expect(months.last, DateTime(2026, 4));
    });

    test('aynı ay ise boş döner (çift üretim yok)', () {
      final months = RecurringService.dueMonths(2026, 4, DateTime(2026, 4, 30));
      expect(months, isEmpty);
    });

    test('yıl sınırını doğru aşar', () {
      final months = RecurringService.dueMonths(2025, 11, DateTime(2026, 2, 1));
      expect(months, [
        DateTime(2025, 12),
        DateTime(2026, 1),
        DateTime(2026, 2),
      ]);
    });

    test('bitiş ayı tavanı öne çeker (aralık sınırlı)', () {
      // Bugün Tem 2026, aralık Oca–Nis 2026 → yalnızca Şub..Nis üretilir.
      final months = RecurringService.dueMonths(
        2026, 1, DateTime(2026, 7, 15),
        endYear: 2026, endMonth: 4,
      );
      expect(months, [DateTime(2026, 2), DateTime(2026, 3), DateTime(2026, 4)]);
    });

    test('bitiş içinde bulunulan aydan sonraysa current tavan kalır', () {
      final months = RecurringService.dueMonths(
        2026, 5, DateTime(2026, 7, 15),
        endYear: 2026, endMonth: 12,
      );
      expect(months, [DateTime(2026, 6), DateTime(2026, 7)]);
    });

    test('bitiş geçmişteyse hiç üretmez', () {
      final months = RecurringService.dueMonths(
        2026, 6, DateTime(2026, 7, 15),
        endYear: 2026, endMonth: 5,
      );
      expect(months, isEmpty);
    });
  });

  group('RecurringService.clampDay', () {
    test('kısa ayda gün ayın son gününe kırpılır', () {
      expect(RecurringService.clampDay(31, 2026, 2), 28); // Şubat 2026
      expect(RecurringService.clampDay(31, 2024, 2), 29); // artık yıl
      expect(RecurringService.clampDay(31, 2026, 4), 30); // Nisan
    });

    test('normal gün değişmez', () {
      expect(RecurringService.clampDay(15, 2026, 3), 15);
    });
  });

  group('BudgetStore', () {
    test('kodlama/çözme round-trip korur', () {
      final map = {
        'market': const NoteBudget(key: 'market', label: 'Market', limit: 50000),
      };
      final decoded = BudgetStore.decode(BudgetStore.encode(map));
      expect(decoded['market']!.limit, 50000);
      expect(decoded['market']!.label, 'Market');
    });

    test('boş/bozuk girdi boş harita döner', () {
      expect(BudgetStore.decode(null), isEmpty);
      expect(BudgetStore.decode(''), isEmpty);
      expect(BudgetStore.decode('bozuk'), isEmpty);
    });

    test('normalize küçük harfe çevirir ve kırpar', () {
      expect(BudgetStore.normalize('  Market '), 'market');
    });
  });
}
