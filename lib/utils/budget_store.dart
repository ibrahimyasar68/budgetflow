import 'dart:convert';

/// Etiket (not) bazlı aylık bütçe limiti.
class NoteBudget {
  /// Normalize edilmiş eşleştirme anahtarı (küçük harf + kırpılmış).
  final String key;

  /// Kullanıcıya gösterilen ad.
  final String label;

  /// Kuruş cinsinden aylık limit.
  final int limit;

  const NoteBudget({
    required this.key,
    required this.label,
    required this.limit,
  });
}

/// `noteBudgets` ayarının JSON kodlaması ve çözümü.
///
/// Biçim: `{"market": {"c": 50000, "l": "Market"}}`
/// (c = kuruş limit, l = görünen ad). Bozuk/eksik girdiler yok sayılır.
class BudgetStore {
  static String normalize(String label) => label.trim().toLowerCase();

  static Map<String, NoteBudget> decode(String? raw) {
    if (raw == null || raw.trim().isEmpty) return {};
    try {
      final decoded = jsonDecode(raw);
      if (decoded is! Map) return {};
      final result = <String, NoteBudget>{};
      decoded.forEach((k, v) {
        if (v is Map && v['c'] is num) {
          final cents = (v['c'] as num).round();
          if (cents <= 0) return;
          final key = k.toString();
          result[key] = NoteBudget(
            key: key,
            label: (v['l'] ?? key).toString(),
            limit: cents,
          );
        }
      });
      return result;
    } catch (_) {
      return {};
    }
  }

  static String encode(Map<String, NoteBudget> budgets) {
    final map = {
      for (final b in budgets.values)
        b.key: {'c': b.limit, 'l': b.label},
    };
    return jsonEncode(map);
  }
}
