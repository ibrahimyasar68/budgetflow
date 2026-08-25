enum TransactionType { gelir, gider }

class Transaction {
  final int? id;

  /// Tutar kuruş cinsinden saklanır (örn. 1050 = ₺10,50).
  /// Kayan nokta yuvarlama hatasını önlemek için int kullanılır.
  final int amount;
  final TransactionType type;
  final DateTime date;

  /// İşlem açıklaması. Sınıflandırmada başlık olarak kullanılır;
  /// boş bırakılırsa 'Diğer' atanır.
  final String? note;

  Transaction({
    this.id,
    required this.amount,
    required this.type,
    required this.date,
    this.note,
  });

  Transaction copyWith({
    int? id,
    int? amount,
    TransactionType? type,
    DateTime? date,
    String? note,
  }) {
    return Transaction(
      id: id ?? this.id,
      amount: amount ?? this.amount,
      type: type ?? this.type,
      date: date ?? this.date,
      note: note ?? this.note,
    );
  }

  factory Transaction.fromMap(Map<String, dynamic> map) {
    return Transaction(
      id: map['id'],
      amount: (map['amount'] as num).round(),
      type: TransactionType.values[map['type'] as int],
      date: DateTime.fromMillisecondsSinceEpoch(map['date'] as int),
      note: map['note'] as String?,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'amount': amount,
      'type': type.index,
      'date': date.millisecondsSinceEpoch,
      'note': note,
    };
  }
}
