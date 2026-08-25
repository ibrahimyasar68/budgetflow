import 'dart:convert';
import 'dart:typed_data';

import 'package:share_plus/share_plus.dart';
import 'package:personal_finance_tracker/models/recurring_rule.dart';
import 'package:personal_finance_tracker/models/transaction.dart';

/// Bir yedek dosyasından okunan veriler.
class BackupData {
  final List<Transaction> transactions;

  /// Tekrarlayan işlem kuralları.
  ///
  /// `null` ise yedekte bu bölüm hiç yok (schema 1) — geri yüklerken mevcut
  /// kurallara dokunulmamalı. Boş liste ise yedek alındığında kural yoktu ve
  /// geri yükleme mevcut kuralları temizlemelidir.
  final List<RecurringRule>? recurring;

  /// Ayar anahtar/değer çiftleri (ör. budgetLimit, noteBudgets).
  final Map<String, String> settings;

  BackupData({
    required this.transactions,
    required this.settings,
    this.recurring,
  });
}

/// Tüm verinin JSON olarak yedeklenmesi ve geri yüklenmesi.
///
/// Yedek biçimi cihazdan bağımsızdır; başka bir kuruluma da aktarılabilir.
/// `id` alanları yazılmaz — geri yüklemede yeni id'ler atanır.
class BackupService {
  /// 1: işlemler + ayarlar. 2: tekrarlayan kurallar da eklendi.
  /// Eski yedekler okunmaya devam eder ('recurring' alanı yoksa boş liste).
  static const int schemaVersion = 2;
  static const String _appTag = 'BudgetFlow';

  /// İşlemleri, tekrarlama kurallarını ve ayarları JSON metnine dönüştürür.
  static String buildJson(
    List<Transaction> transactions, {
    Map<String, String> settings = const {},
    List<RecurringRule> recurring = const [],
  }) {
    final map = {
      'app': _appTag,
      'schema': schemaVersion,
      'exportedAt': DateTime.now().toIso8601String(),
      'settings': settings,
      'transactions': [
        for (final t in transactions)
          {
            'amount': t.amount,
            'type': t.type.index,
            'date': t.date.millisecondsSinceEpoch,
            'note': t.note,
          },
      ],
      // id yazılmaz; geri yüklemede yeni id atanır.
      'recurring': [
        for (final r in recurring) r.toMap()..remove('id'),
      ],
    };
    return const JsonEncoder.withIndent('  ').convert(map);
  }

  /// JSON metnini ayrıştırır. Geçersizse [FormatException] fırlatır.
  static BackupData parseJson(String source) {
    // Bazı editörler/dosya sağlayıcıları başa UTF-8 BOM ekleyebilir; ayıkla.
    var text = source.trim();
    if (text.isNotEmpty && text.codeUnitAt(0) == 0xFEFF) {
      text = text.substring(1).trim();
    }
    if (text.isEmpty) {
      throw const FormatException('Dosya boş.');
    }
    final dynamic decoded;
    try {
      decoded = jsonDecode(text);
    } catch (_) {
      throw const FormatException('Dosya geçerli bir JSON değil.');
    }
    if (decoded is! Map || decoded['app'] != _appTag) {
      throw const FormatException('Bu bir BudgetFlow yedeği değil.');
    }
    final rawList = decoded['transactions'];
    if (rawList is! List) {
      throw const FormatException('Yedek içinde işlem listesi bulunamadı.');
    }

    final transactions = <Transaction>[];
    for (final item in rawList) {
      if (item is! Map) continue;
      final amount = (item['amount'] as num?)?.round();
      final typeIndex = (item['type'] as num?)?.toInt();
      final dateMs = (item['date'] as num?)?.toInt();
      if (amount == null || typeIndex == null || dateMs == null) continue;
      if (typeIndex < 0 || typeIndex >= TransactionType.values.length) continue;
      transactions.add(Transaction(
        amount: amount,
        type: TransactionType.values[typeIndex],
        date: DateTime.fromMillisecondsSinceEpoch(dateMs),
        note: item['note'] as String?,
      ));
    }

    final settings = <String, String>{};
    final rawSettings = decoded['settings'];
    if (rawSettings is Map) {
      rawSettings.forEach((k, v) {
        if (v != null) settings[k.toString()] = v.toString();
      });
    }

    return BackupData(
      transactions: transactions,
      settings: settings,
      recurring: _parseRecurring(decoded['recurring']),
    );
  }

  /// Tekrarlama kurallarını ayıklar. Alan eksikse veya değer geçersizse o kural
  /// atlanır — bozuk tek bir kayıt yüzünden geri yükleme başarısız olmaz.
  /// Bölüm hiç yoksa `null` döner (schema 1 yedeği).
  static List<RecurringRule>? _parseRecurring(dynamic rawList) {
    if (rawList is! List) return null;
    final rules = <RecurringRule>[];
    for (final item in rawList) {
      if (item is! Map) continue;
      final amount = (item['amount'] as num?)?.round();
      final typeIndex = (item['type'] as num?)?.toInt();
      final day = (item['dayOfMonth'] as num?)?.toInt();
      final startYear = (item['startYear'] as num?)?.toInt();
      final startMonth = (item['startMonth'] as num?)?.toInt();
      final lastYear = (item['lastYear'] as num?)?.toInt();
      final lastMonth = (item['lastMonth'] as num?)?.toInt();
      if (amount == null ||
          typeIndex == null ||
          day == null ||
          startYear == null ||
          startMonth == null ||
          lastYear == null ||
          lastMonth == null) {
        continue;
      }
      if (typeIndex < 0 || typeIndex >= TransactionType.values.length) continue;
      if (day < 1 || day > 31) continue;
      if (startMonth < 1 || startMonth > 12) continue;
      if (lastMonth < 1 || lastMonth > 12) continue;
      final endYear = (item['endYear'] as num?)?.toInt();
      final endMonth = (item['endMonth'] as num?)?.toInt();
      // Bitiş ayı ancak iki alan da geçerliyse anlamlıdır; yarım veri süresiz sayılır.
      final validEnd =
          endYear != null && endMonth != null && endMonth >= 1 && endMonth <= 12;
      rules.add(RecurringRule(
        amount: amount,
        type: TransactionType.values[typeIndex],
        note: item['note'] as String?,
        dayOfMonth: day,
        startYear: startYear,
        startMonth: startMonth,
        lastYear: lastYear,
        lastMonth: lastMonth,
        endYear: validEnd ? endYear : null,
        endMonth: validEnd ? endMonth : null,
      ));
    }
    return rules;
  }

  /// Yedeği .json dosyası olarak sistem paylaşım sayfası üzerinden dışa aktarır.
  static Future<void> shareBackup(
    List<Transaction> transactions, {
    Map<String, String> settings = const {},
    List<RecurringRule> recurring = const [],
  }) async {
    final json =
        buildJson(transactions, settings: settings, recurring: recurring);
    final bytes = Uint8List.fromList(utf8.encode(json));
    final fileName =
        'budgetflow_yedek_${DateTime.now().toIso8601String().split('T').first}.json';
    await Share.shareXFiles(
      [XFile.fromData(bytes, mimeType: 'application/json', name: fileName)],
      fileNameOverrides: [fileName],
      subject: 'BudgetFlow yedeği',
      text: 'BudgetFlow tam yedeği (JSON)',
    );
  }
}
