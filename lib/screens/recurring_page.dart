import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:personal_finance_tracker/database/database_service.dart';
import 'package:personal_finance_tracker/models/recurring_rule.dart';
import 'package:personal_finance_tracker/models/transaction.dart';
import 'package:personal_finance_tracker/utils/app_theme.dart';
import 'package:personal_finance_tracker/utils/check_message.dart';
import 'package:personal_finance_tracker/utils/formatters.dart';
import 'package:personal_finance_tracker/utils/month_names.dart';

/// Tekrarlayan işlem kurallarının listelendiği ve kaldırıldığı ekran.
/// Kural silmek, o kuraldan geçmişte üretilmiş işlemleri etkilemez.
class RecurringPage extends StatefulWidget {
  const RecurringPage({super.key});

  @override
  State<RecurringPage> createState() => _RecurringPageState();
}

class _RecurringPageState extends State<RecurringPage> {
  final _db = DatabaseService();
  List<RecurringRule> _rules = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final rules = await _db.getRecurringRules();
    if (!mounted) return;
    setState(() {
      _rules = rules;
      _loading = false;
    });
  }

  Future<void> _delete(RecurringRule rule) async {
    if (rule.id == null) return;
    final ok = await checkMessage(
      context,
      'Tekrarlamayı Durdur',
      'Bu tekrarlama kuralı silinsin mi? Geçmişte eklenen işlemler kalır.',
    );
    if (!ok) return;
    await _db.deleteRecurringRule(rule.id!);
    HapticFeedback.mediumImpact();
    await _load();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(title: const Text('Tekrarlayan İşlemler')),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : _rules.isEmpty
              ? _empty()
              : ListView(
                  padding: EdgeInsets.fromLTRB(
                      16, 12, 16, 24 + MediaQuery.paddingOf(context).bottom),
                  children: [
                    Text(
                      'Bu kurallar her ay otomatik işlem ekler. '
                      'Yeni bir tekrarlayan işlem oluşturmak için işlem '
                      'eklerken "Her ay tekrarla"yı aç.',
                      style: TextStyle(
                        fontSize: 12.5,
                        color: Theme.of(context).colorScheme.onSurfaceVariant,
                      ),
                    ),
                    const SizedBox(height: 12),
                    for (final r in _rules) ...[
                      _ruleCard(r),
                      const SizedBox(height: 10),
                    ],
                  ],
                ),
    );
  }

  Widget _ruleCard(RecurringRule r) {
    final isIncome = r.type == TransactionType.gelir;
    final color = isIncome ? AppTheme.incomeColor : AppTheme.expenseColor;
    final title = (r.note != null && r.note!.trim().isNotEmpty)
        ? r.note!.trim()
        : 'Diğer';

    return Card(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        child: Row(
          children: [
            Container(
              width: 42,
              height: 42,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.14),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(Icons.repeat_rounded, color: color, size: 20),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                          fontWeight: FontWeight.w600, fontSize: 15)),
                  const SizedBox(height: 2),
                  Text(
                    '${isIncome ? 'Gelir' : 'Gider'} · her ayın ${r.dayOfMonth}. günü',
                    style: TextStyle(
                        fontSize: 12,
                        color: Theme.of(context).colorScheme.onSurfaceVariant),
                  ),
                  const SizedBox(height: 1),
                  Text(
                    _rangeLabel(r),
                    style: TextStyle(
                        fontSize: 11.5,
                        fontWeight: FontWeight.w600,
                        color: Theme.of(context).colorScheme.primary),
                  ),
                ],
              ),
            ),
            Text(
              '${isIncome ? '+' : '-'}${AppFormatters.formatCurrency(r.amount)}',
              style: TextStyle(
                color: color,
                fontWeight: FontWeight.bold,
                fontSize: 14,
                fontFeatures: AppTheme.tabularFigures,
              ),
            ),
            IconButton(
              icon: const Icon(Icons.delete_outline),
              tooltip: 'Tekrarlamayı durdur',
              onPressed: () => _delete(r),
            ),
          ],
        ),
      ),
    );
  }

  String _rangeLabel(RecurringRule r) {
    final start = monthLabel(DateTime(r.startYear, r.startMonth));
    if (r.hasEnd) {
      final end = monthLabel(DateTime(r.endYear!, r.endMonth!));
      return '$start – $end';
    }
    return '$start’dan itibaren · süresiz';
  }

  Widget _empty() {
    final muted = Theme.of(context).colorScheme.onSurfaceVariant;
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.repeat_rounded, size: 52, color: muted),
            const SizedBox(height: 16),
            const Text('Tekrarlayan İşlem Yok',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            Text(
              'İşlem eklerken "Her ay tekrarla"yı açtığında, o işlem her ay '
              'otomatik olarak eklenir ve burada listelenir.',
              textAlign: TextAlign.center,
              style: TextStyle(color: muted),
            ),
          ],
        ),
      ),
    );
  }
}
