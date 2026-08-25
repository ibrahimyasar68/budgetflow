/// Türkçe ay adları için ortak kaynak (birden çok ekran kullanır).
const List<String> kMonthNames = [
  'Ocak', 'Şubat', 'Mart', 'Nisan', 'Mayıs', 'Haziran',
  'Temmuz', 'Ağustos', 'Eylül', 'Ekim', 'Kasım', 'Aralık',
];

const List<String> kShortMonthNames = [
  'Oca', 'Şub', 'Mar', 'Nis', 'May', 'Haz',
  'Tem', 'Ağu', 'Eyl', 'Eki', 'Kas', 'Ara',
];

/// "Ocak 2026" biçimi.
String monthLabel(DateTime m) => '${kMonthNames[m.month - 1]} ${m.year}';
