import 'package:personal_finance_tracker/models/transaction.dart';

/// Her ay otomatik işlem üreten tekrarlama kuralı.
///
/// `last*` alanları, o kural için en son üretilmiş ayı tutar; üretim bu aydan
/// sonraki aylardan içinde bulunulan aya kadar devam eder (çift kayıt olmaz).
class RecurringRule {
  final int? id;
  final int amount; // kuruş
  final TransactionType type;
  final String? note;
  final int dayOfMonth; // 1-31 (ay kısaysa ayın son gününe kırpılır)
  final int startYear;
  final int startMonth;
  final int lastYear;
  final int lastMonth;

  /// Bitiş ayı (dahil). null ise süresiz tekrarlar.
  final int? endYear;
  final int? endMonth;

  const RecurringRule({
    this.id,
    required this.amount,
    required this.type,
    required this.note,
    required this.dayOfMonth,
    required this.startYear,
    required this.startMonth,
    required this.lastYear,
    required this.lastMonth,
    this.endYear,
    this.endMonth,
  });

  bool get hasEnd => endYear != null && endMonth != null;

  RecurringRule copyWith({int? lastYear, int? lastMonth}) => RecurringRule(
        id: id,
        amount: amount,
        type: type,
        note: note,
        dayOfMonth: dayOfMonth,
        startYear: startYear,
        startMonth: startMonth,
        lastYear: lastYear ?? this.lastYear,
        lastMonth: lastMonth ?? this.lastMonth,
        endYear: endYear,
        endMonth: endMonth,
      );

  factory RecurringRule.fromMap(Map<String, dynamic> map) => RecurringRule(
        id: map['id'] as int?,
        amount: (map['amount'] as num).round(),
        type: TransactionType.values[map['type'] as int],
        note: map['note'] as String?,
        dayOfMonth: map['dayOfMonth'] as int,
        startYear: map['startYear'] as int,
        startMonth: map['startMonth'] as int,
        lastYear: map['lastYear'] as int,
        lastMonth: map['lastMonth'] as int,
        endYear: map['endYear'] as int?,
        endMonth: map['endMonth'] as int?,
      );

  Map<String, dynamic> toMap() => {
        'id': id,
        'amount': amount,
        'type': type.index,
        'note': note,
        'dayOfMonth': dayOfMonth,
        'startYear': startYear,
        'startMonth': startMonth,
        'lastYear': lastYear,
        'lastMonth': lastMonth,
        'endYear': endYear,
        'endMonth': endMonth,
      };
}
