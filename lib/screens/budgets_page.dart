import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:personal_finance_tracker/database/database_service.dart';
import 'package:personal_finance_tracker/models/transaction.dart';
import 'package:personal_finance_tracker/screens/budget_dialog.dart';
import 'package:personal_finance_tracker/utils/app_theme.dart';
import 'package:personal_finance_tracker/utils/budget_store.dart';
import 'package:personal_finance_tracker/utils/formatters.dart';

/// Bütçe yönetimi: aylık toplam limit + etiket (not) bazlı limitler.
/// İlerleme her zaman içinde bulunulan ayın giderleri üzerinden hesaplanır.
class BudgetsPage extends StatefulWidget {
  const BudgetsPage({super.key});

  @override
  State<BudgetsPage> createState() => _BudgetsPageState();
}

class _BudgetsPageState extends State<BudgetsPage> {
  final _db = DatabaseService();
  List<Transaction> _transactions = [];
  int? _monthlyBudget;
  Map<String, NoteBudget> _noteBudgets = {};
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final tx = await _db.getAllTransactions();
    final budgetRaw = await _db.getSetting('budgetLimit');
    final noteRaw = await _db.getSetting('noteBudgets');
    if (!mounted) return;
    setState(() {
      _transactions = tx;
      final b = budgetRaw == null ? null : int.tryParse(budgetRaw);
      _monthlyBudget = (b != null && b > 0) ? b : null;
      _noteBudgets = BudgetStore.decode(noteRaw);
      _loading = false;
    });
  }

  DateTime get _thisMonth {
    final n = DateTime.now();
    return DateTime(n.year, n.month);
  }

  bool _inThisMonth(Transaction t) =>
      t.date.year == _thisMonth.year && t.date.month == _thisMonth.month;

  int get _monthExpense {
    var s = 0;
    for (final t in _transactions) {
      if (t.type == TransactionType.gider && _inThisMonth(t)) s += t.amount;
    }
    return s;
  }

  /// İçinde bulunulan ay için etiket bazlı gider toplamları (normalize anahtar).
  Map<String, int> _expenseByNote() {
    final map = <String, int>{};
    for (final t in _transactions) {
      if (t.type != TransactionType.gider || !_inThisMonth(t)) continue;
      final raw = (t.note != null && t.note!.trim().isNotEmpty)
          ? t.note!.trim()
          : 'Diğer';
      map[BudgetStore.normalize(raw)] =
          (map[BudgetStore.normalize(raw)] ?? 0) + t.amount;
    }
    return map;
  }

  /// Normalize anahtar → görünen ad (tüm işlemlerden, en son yazım).
  Map<String, String> _labelsByNote() {
    final map = <String, String>{};
    for (final t in _transactions) {
      if (t.type != TransactionType.gider) continue;
      final raw = (t.note != null && t.note!.trim().isNotEmpty)
          ? t.note!.trim()
          : 'Diğer';
      map[BudgetStore.normalize(raw)] = raw;
    }
    return map;
  }

  Color _statusColor(double ratio) {
    if (ratio >= 1.0) return AppTheme.expenseColor;
    if (ratio >= 0.85) return const Color(0xFFFFA726);
    return AppTheme.incomeColor;
  }

  Future<void> _editMonthly() async {
    final result = await showBudgetDialog(context, current: _monthlyBudget);
    if (result == null) return;
    HapticFeedback.selectionClick();
    if (result == 0) {
      await _db.deleteSetting('budgetLimit');
    } else {
      await _db.setSetting('budgetLimit', result.toString());
    }
    await _load();
  }

  Future<void> _editNote(String key, String label) async {
    final existing = _noteBudgets[key];
    final result = await showBudgetDialog(
      context,
      current: existing?.limit,
      title: '$label · Aylık Limit',
      description:
          '"$label" etiketli aylık giderler için bir üst sınır belirle.',
    );
    if (result == null) return;
    HapticFeedback.selectionClick();
    final map = Map<String, NoteBudget>.from(_noteBudgets);
    if (result == 0) {
      map.remove(key);
    } else {
      map[key] = NoteBudget(key: key, label: label, limit: result);
    }
    await _db.setSetting('noteBudgets', BudgetStore.encode(map));
    await _load();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(title: const Text('Bütçeler')),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : _buildBody(),
    );
  }

  Widget _buildBody() {
    final expenseByNote = _expenseByNote();
    final labels = _labelsByNote();

    // Aday etiketler: bütçesi olanlar + bu ay gideri olanlar.
    final keys = <String>{..._noteBudgets.keys, ...expenseByNote.keys}.toList()
      ..sort((a, b) {
        final ea = expenseByNote[a] ?? 0;
        final eb = expenseByNote[b] ?? 0;
        return eb.compareTo(ea);
      });

    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
      children: [
        Text(
          '${AppFormatters.formatCurrency(_monthExpense)} · bu ayki toplam gider',
          style: TextStyle(
            fontSize: 13,
            color: Theme.of(context).colorScheme.onSurfaceVariant,
          ),
        ),
        const SizedBox(height: 12),
        _monthlyCard(),
        const SizedBox(height: 22),
        Row(
          children: [
            Text('Etiket Bazlı Limitler',
                style: Theme.of(context)
                    .textTheme
                    .titleMedium
                    ?.copyWith(fontWeight: FontWeight.w700)),
          ],
        ),
        const SizedBox(height: 4),
        Text(
          'Bir etikete dokunarak o başlık için aylık limit belirle.',
          style: TextStyle(
            fontSize: 12.5,
            color: Theme.of(context).colorScheme.onSurfaceVariant,
          ),
        ),
        const SizedBox(height: 12),
        if (keys.isEmpty)
          _emptyNotes()
        else
          for (final k in keys) ...[
            _noteCard(k, labels[k] ?? _noteBudgets[k]?.label ?? k,
                expenseByNote[k] ?? 0),
            const SizedBox(height: 10),
          ],
      ],
    );
  }

  Widget _monthlyCard() {
    final limit = _monthlyBudget;
    final spent = _monthExpense;
    final hasLimit = limit != null && limit > 0;
    final ratio = hasLimit ? spent / limit : 0.0;
    final color = hasLimit ? _statusColor(ratio) : Theme.of(context).colorScheme.primary;

    return Card(
      child: InkWell(
        onTap: _editMonthly,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(Icons.savings_outlined, size: 18, color: color),
                  const SizedBox(width: 8),
                  const Text('Aylık Toplam',
                      style: TextStyle(fontWeight: FontWeight.w700)),
                  const Spacer(),
                  if (hasLimit)
                    Text(
                      '${AppFormatters.formatCurrency(spent)} / ${AppFormatters.formatCurrency(limit)}',
                      style: TextStyle(
                        fontSize: 13,
                        color: Theme.of(context).colorScheme.onSurfaceVariant,
                        fontFeatures: AppTheme.tabularFigures,
                      ),
                    )
                  else
                    const Text('Belirle',
                        style: TextStyle(fontWeight: FontWeight.w600)),
                ],
              ),
              if (hasLimit) ...[
                const SizedBox(height: 12),
                _progressBar(ratio, color),
                const SizedBox(height: 10),
                _statusLine(spent, limit, ratio, color),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _noteCard(String key, String label, int spent) {
    final budget = _noteBudgets[key];
    final hasLimit = budget != null;
    final ratio = hasLimit ? spent / budget.limit : 0.0;
    final color =
        hasLimit ? _statusColor(ratio) : Theme.of(context).colorScheme.primary;

    return Card(
      child: InkWell(
        onTap: () => _editNote(key, label),
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(label,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(fontWeight: FontWeight.w700)),
                  ),
                  const SizedBox(width: 8),
                  if (hasLimit)
                    Text(
                      '${AppFormatters.formatCurrency(spent)} / ${AppFormatters.formatCurrency(budget.limit)}',
                      style: TextStyle(
                        fontSize: 12.5,
                        color: Theme.of(context).colorScheme.onSurfaceVariant,
                        fontFeatures: AppTheme.tabularFigures,
                      ),
                    )
                  else
                    Row(
                      children: [
                        Text(AppFormatters.formatCurrency(spent),
                            style: TextStyle(
                              fontSize: 12.5,
                              color: Theme.of(context)
                                  .colorScheme
                                  .onSurfaceVariant,
                              fontFeatures: AppTheme.tabularFigures,
                            )),
                        const SizedBox(width: 6),
                        Icon(Icons.add_circle_outline,
                            size: 16,
                            color: Theme.of(context).colorScheme.primary),
                      ],
                    ),
                ],
              ),
              if (hasLimit) ...[
                const SizedBox(height: 10),
                _progressBar(ratio, color),
                const SizedBox(height: 8),
                _statusLine(spent, budget.limit, ratio, color),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _progressBar(double ratio, Color color) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(8),
      child: LinearProgressIndicator(
        value: ratio.clamp(0.0, 1.0),
        minHeight: 9,
        backgroundColor: color.withValues(alpha: 0.14),
        valueColor: AlwaysStoppedAnimation(color),
      ),
    );
  }

  Widget _statusLine(int spent, int limit, double ratio, Color color) {
    final over = spent > limit;
    return Row(
      children: [
        Icon(over ? Icons.warning_amber_rounded : Icons.check_circle_outline,
            size: 14, color: color),
        const SizedBox(width: 5),
        Text(
          over
              ? '${AppFormatters.formatCurrency(spent - limit)} aşıldı'
              : '${AppFormatters.formatCurrency(limit - spent)} kaldı',
          style: TextStyle(
            color: color,
            fontWeight: FontWeight.w600,
            fontSize: 12.5,
            fontFeatures: AppTheme.tabularFigures,
          ),
        ),
        const Spacer(),
        Text('%${(ratio * 100).round()}',
            style: TextStyle(
              color: color,
              fontWeight: FontWeight.w700,
              fontSize: 12.5,
              fontFeatures: AppTheme.tabularFigures,
            )),
      ],
    );
  }

  Widget _emptyNotes() {
    final muted = Theme.of(context).colorScheme.onSurfaceVariant;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 24),
      child: Column(
        children: [
          Icon(Icons.label_outline_rounded, size: 40, color: muted),
          const SizedBox(height: 10),
          Text(
            'Bu ay henüz gider yok.\nGider ekledikçe etiketler burada belirir.',
            textAlign: TextAlign.center,
            style: TextStyle(color: muted, fontSize: 13),
          ),
        ],
      ),
    );
  }
}
