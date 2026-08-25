import 'package:personal_finance_tracker/database/database_service.dart';
import 'package:personal_finance_tracker/models/transaction.dart';

/// Tekrarlayan işlem kurallarından vadesi gelen işlemleri üretir.
class RecurringService {
  final DatabaseService _db;
  RecurringService([DatabaseService? db]) : _db = db ?? DatabaseService();

  /// (lastYear, lastMonth)'dan sonraki aylardan tavan aya kadar (dahil)
  /// üretilmesi gereken ayları döner. Tavan = [current]'ın ayı; bir bitiş ayı
  /// verilmişse tavan min(current, bitiş) olur. Saf fonksiyon — test edilebilir.
  static List<DateTime> dueMonths(
    int lastYear,
    int lastMonth,
    DateTime current, {
    int? endYear,
    int? endMonth,
  }) {
    var ceilY = current.year;
    var ceilM = current.month;
    // Bitiş ayı, içinde bulunulan aydan önceyse tavanı öne çeker.
    if (endYear != null && endMonth != null) {
      if (endYear < ceilY || (endYear == ceilY && endMonth < ceilM)) {
        ceilY = endYear;
        ceilM = endMonth;
      }
    }

    final months = <DateTime>[];
    var y = lastYear;
    var m = lastMonth;
    // Güvenlik sınırı: en fazla 600 ay (50 yıl) ileri git.
    for (var guard = 0; guard < 600; guard++) {
      m++;
      if (m > 12) {
        m = 1;
        y++;
      }
      if (y > ceilY || (y == ceilY && m > ceilM)) break;
      months.add(DateTime(y, m));
    }
    return months;
  }

  /// Ayın gün sayısını aşan gün değerlerini o ayın son gününe kırpar.
  static int clampDay(int day, int year, int month) {
    final lastDay = DateTime(year, month + 1, 0).day; // ayın son günü
    if (day < 1) return 1;
    return day > lastDay ? lastDay : day;
  }

  /// Vadesi gelmiş tüm işlemleri üretir ve kaç işlem eklendiğini döner.
  Future<int> generateDue({DateTime? now}) async {
    final current = now ?? DateTime.now();
    final rules = await _db.getRecurringRules();
    var created = 0;
    for (final r in rules) {
      if (r.id == null) continue;
      final months = dueMonths(
        r.lastYear,
        r.lastMonth,
        current,
        endYear: r.endYear,
        endMonth: r.endMonth,
      );
      if (months.isEmpty) continue;
      for (final mo in months) {
        final day = clampDay(r.dayOfMonth, mo.year, mo.month);
        await _db.insertTransaction(Transaction(
          amount: r.amount,
          type: r.type,
          date: DateTime(mo.year, mo.month, day, 12),
          note: r.note,
        ));
        created++;
      }
      final last = months.last;
      await _db.updateRecurringLast(r.id!, last.year, last.month);
    }
    return created;
  }
}
