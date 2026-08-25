import 'package:intl/intl.dart';

class AppFormatters {
  static final NumberFormat currency = NumberFormat.currency(
    locale: "tr_TR",
    symbol: "₺",
    decimalDigits: 2,
  );

  static final NumberFormat compactCurrency = NumberFormat.compactCurrency(
    locale: "tr_TR",
    symbol: "₺",
    decimalDigits: 1,
  );

  /// Kuruş (int) → "₺10,50"
  static String formatCurrency(int cents) => currency.format(cents / 100);

  /// Kuruş (int) → "₺1,2B" (kısa biçim)
  static String formatCompact(int cents) => compactCurrency.format(cents / 100);

  /// tr_TR girişini güvenle kuruşa çevirir: "1.250,75" / "1250,75" / "1250.75".
  /// Geçersizse null döner.
  static int? parseAmountCents(String input) {
    var s = input.trim().replaceAll(' ', '').replaceAll('₺', '');
    if (s.isEmpty) return null;
    if (s.contains(',') && s.contains('.')) {
      // nokta binlik, virgül ondalık
      s = s.replaceAll('.', '').replaceAll(',', '.');
    } else if (s.contains(',')) {
      s = s.replaceAll(',', '.');
    }
    final value = double.tryParse(s);
    if (value == null) return null;
    return (value * 100).round();
  }

  /// Kuruş (int) → düzenleme alanı için "10,50" metni.
  static String centsToInput(int cents) =>
      (cents / 100).toStringAsFixed(2).replaceAll('.', ',');
}
