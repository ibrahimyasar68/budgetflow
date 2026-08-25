import 'dart:convert';
import 'dart:typed_data';

import 'package:share_plus/share_plus.dart';
import 'package:personal_finance_tracker/models/transaction.dart';

/// İşlemleri CSV olarak dışa aktarır ve sistem paylaşım sayfasını açar.
class ExportService {
  /// İşlem listesinden CSV metni üretir.
  /// Tutar, hesap tablolarında ayrıştırılabilmesi için nokta ondalıklı
  /// (₺ sembolü olmadan) yazılır; ör. 1250.75.
  static String buildCsv(List<Transaction> transactions) {
    final rows = <String>[
      ['Tarih', 'Tür', 'Not', 'Tutar'].map(_escape).join(','),
    ];
    for (final t in transactions) {
      final date =
          '${t.date.year}-${_pad(t.date.month)}-${_pad(t.date.day)}';
      final type = t.type == TransactionType.gelir ? 'Gelir' : 'Gider';
      final note = (t.note != null && t.note!.trim().isNotEmpty)
          ? t.note!.trim()
          : 'Diğer';
      final amount = (t.amount / 100).toStringAsFixed(2);
      rows.add(
        [date, type, note, amount].map(_escape).join(','),
      );
    }
    return rows.join('\r\n');
  }

  static String _pad(int n) => n.toString().padLeft(2, '0');

  static String _escape(String value) {
    if (value.contains(',') ||
        value.contains('"') ||
        value.contains('\n') ||
        value.contains('\r')) {
      return '"${value.replaceAll('"', '""')}"';
    }
    return value;
  }

  /// CSV'yi paylaşım sayfası üzerinden dışa aktarır.
  static Future<void> shareCsv(List<Transaction> transactions) async {
    final csv = buildCsv(transactions);
    // UTF-8 BOM, Excel'in Türkçe karakterleri doğru göstermesini sağlar.
    final bytes = Uint8List.fromList(utf8.encode('﻿$csv'));
    final fileName =
        'budgetflow_${DateTime.now().toIso8601String().split('T').first}.csv';

    await Share.shareXFiles(
      [XFile.fromData(bytes, mimeType: 'text/csv', name: fileName)],
      fileNameOverrides: [fileName],
      subject: 'BudgetFlow işlem dışa aktarımı',
      text: 'BudgetFlow işlemleri (CSV)',
    );
  }
}
