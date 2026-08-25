import 'dart:math';

import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:personal_finance_tracker/models/transaction.dart';
import 'package:personal_finance_tracker/utils/app_theme.dart';
import 'package:personal_finance_tracker/utils/formatters.dart';
import 'package:personal_finance_tracker/utils/label_color.dart';
import 'package:personal_finance_tracker/utils/month_names.dart';
import 'package:personal_finance_tracker/widgets/empty_state.dart';

/// Grafik sekmesi. Pasta ve gider dağılımı [selectedMonth] kapsamıyla,
/// "Son 6 Ay" çubukları her zaman güncel 6 aylık trendle çalışır.
class ChartTab extends StatefulWidget {
  final List<Transaction> transactions;
  final DateTime? selectedMonth;
  final Widget monthSelector;

  const ChartTab({
    super.key,
    required this.transactions,
    required this.selectedMonth,
    required this.monthSelector,
  });

  @override
  State<ChartTab> createState() => _ChartTabState();
}

class _ChartTabState extends State<ChartTab> {
  int _touchedPie = -1;

  List<Transaction> get _monthTransactions {
    final m = widget.selectedMonth;
    if (m == null) return widget.transactions;
    return widget.transactions
        .where((t) => t.date.year == m.year && t.date.month == m.month)
        .toList();
  }

  int get _totalIncome => _monthTransactions
      .where((t) => t.type == TransactionType.gelir)
      .fold(0, (s, t) => s + t.amount);

  int get _totalExpense => _monthTransactions
      .where((t) => t.type == TransactionType.gider)
      .fold(0, (s, t) => s + t.amount);

  int get _balance => _totalIncome - _totalExpense;

  @override
  Widget build(BuildContext context) {
    if (widget.transactions.isEmpty) {
      return const EmptyState(
        icon: Icons.bar_chart_rounded,
        title: 'Henüz Veri Yok',
        subtitle: 'İşlem ekledikçe grafikler burada belirir',
      );
    }

    final hasScopeData = _totalIncome + _totalExpense > 0;

    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 4, 16, 24),
      children: [
        widget.monthSelector,
        const SizedBox(height: 12),
        if (!hasScopeData) ...[
          const SizedBox(height: 40),
          const EmptyState(
            icon: Icons.event_busy_rounded,
            title: 'Bu Dönemde Veri Yok',
            subtitle: 'Başka bir ay seç veya "Tüm Zamanlar"a geç',
          ),
        ] else ...[
          _sectionTitle('Gelir / Gider'),
          const SizedBox(height: 12),
          _buildPieCard(),
          const SizedBox(height: 20),
          _sectionTitle('Son 6 Ay'),
          const SizedBox(height: 12),
          _buildMonthlyBarCard(),
          const SizedBox(height: 20),
          if (_totalExpense > 0) ...[
            _sectionTitle('Gider Dağılımı'),
            const SizedBox(height: 12),
            _buildExpenseBreakdown(),
          ],
        ],
      ],
    );
  }

  Widget _sectionTitle(String t) => Text(
        t,
        style: Theme.of(context)
            .textTheme
            .titleMedium
            ?.copyWith(fontWeight: FontWeight.w700),
      );

  Widget _buildPieCard() {
    final sections = [
      _pieSection(0, _totalIncome, AppTheme.incomeColor),
      _pieSection(1, _totalExpense, AppTheme.expenseColor),
    ];
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            SizedBox(
              height: 200,
              child: Stack(
                alignment: Alignment.center,
                children: [
                  PieChart(
                    PieChartData(
                      sectionsSpace: 3,
                      centerSpaceRadius: 58,
                      sections: sections,
                      pieTouchData: PieTouchData(
                        touchCallback: (event, response) {
                          setState(() {
                            if (!event.isInterestedForInteractions ||
                                response?.touchedSection == null) {
                              _touchedPie = -1;
                              return;
                            }
                            _touchedPie = response!
                                .touchedSection!.touchedSectionIndex;
                          });
                        },
                      ),
                    ),
                  ),
                  Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text('Bakiye',
                          style: TextStyle(
                              fontSize: 12,
                              color: Theme.of(context)
                                  .colorScheme
                                  .onSurfaceVariant)),
                      const SizedBox(height: 2),
                      Text(
                        AppFormatters.formatCompact(_balance),
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w800,
                          fontFeatures: AppTheme.tabularFigures,
                          color: _balance >= 0
                              ? AppTheme.incomeColor
                              : AppTheme.expenseColor,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _legend('Gelir', AppTheme.incomeColor),
                _legend('Gider', AppTheme.expenseColor),
              ],
            ),
          ],
        ),
      ),
    );
  }

  PieChartSectionData _pieSection(int index, int valueCents, Color color) {
    final total = _totalIncome + _totalExpense;
    final pct = total == 0 ? 0.0 : valueCents / total * 100;
    final touched = index == _touchedPie;
    return PieChartSectionData(
      value: valueCents.toDouble(),
      color: color,
      radius: touched ? 62 : 52,
      title: '${pct.toStringAsFixed(0)}%',
      titleStyle: TextStyle(
        color: Colors.white,
        fontWeight: FontWeight.bold,
        fontSize: touched ? 16 : 13,
      ),
    );
  }

  Widget _legend(String label, Color color) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 12,
          height: 12,
          decoration: BoxDecoration(
              color: color, borderRadius: BorderRadius.circular(4)),
        ),
        const SizedBox(width: 6),
        Text(label, style: const TextStyle(fontWeight: FontWeight.w600)),
      ],
    );
  }

  // Son 6 ayın gelir/gider bar grafiği
  Widget _buildMonthlyBarCard() {
    final buckets = _monthlyBuckets();
    final maxCents = buckets
        .map((b) => max(b.income, b.expense))
        .fold(0, (a, b) => max(a, b));
    final maxY = maxCents == 0 ? 1.0 : maxCents * 1.25;

    return Card(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(12, 20, 12, 12),
        child: SizedBox(
          height: 200,
          child: BarChart(
            BarChartData(
              maxY: maxY,
              alignment: BarChartAlignment.spaceAround,
              barTouchData: BarTouchData(
                touchTooltipData: BarTouchTooltipData(
                  getTooltipItem: (group, _, rod, __) => BarTooltipItem(
                    AppFormatters.formatCompact(rod.toY.round()),
                    const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 12),
                  ),
                ),
              ),
              gridData: const FlGridData(show: false),
              borderData: FlBorderData(show: false),
              titlesData: FlTitlesData(
                leftTitles: const AxisTitles(
                    sideTitles: SideTitles(showTitles: false)),
                rightTitles: const AxisTitles(
                    sideTitles: SideTitles(showTitles: false)),
                topTitles: const AxisTitles(
                    sideTitles: SideTitles(showTitles: false)),
                bottomTitles: AxisTitles(
                  sideTitles: SideTitles(
                    showTitles: true,
                    getTitlesWidget: (value, meta) {
                      final i = value.toInt();
                      if (i < 0 || i >= buckets.length) {
                        return const SizedBox.shrink();
                      }
                      return Padding(
                        padding: const EdgeInsets.only(top: 6),
                        child: Text(buckets[i].label,
                            style: const TextStyle(fontSize: 11)),
                      );
                    },
                  ),
                ),
              ),
              barGroups: [
                for (int i = 0; i < buckets.length; i++)
                  BarChartGroupData(
                    x: i,
                    barRods: [
                      BarChartRodData(
                        toY: buckets[i].income.toDouble(),
                        color: AppTheme.incomeColor,
                        width: 9,
                        borderRadius: BorderRadius.circular(4),
                      ),
                      BarChartRodData(
                        toY: buckets[i].expense.toDouble(),
                        color: AppTheme.expenseColor,
                        width: 9,
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ],
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  List<_MonthBucket> _monthlyBuckets() {
    final now = DateTime.now();
    final months = List.generate(6, (i) {
      final d = DateTime(now.year, now.month - (5 - i));
      return _MonthBucket(d);
    });
    for (final t in widget.transactions) {
      for (final b in months) {
        if (t.date.year == b.date.year && t.date.month == b.date.month) {
          if (t.type == TransactionType.gelir) {
            b.income += t.amount;
          } else {
            b.expense += t.amount;
          }
          break;
        }
      }
    }
    return months;
  }

  Widget _buildExpenseBreakdown() {
    final Map<String, int> totals = {};
    final Map<String, String> labels = {}; // normalize anahtar → görünen ad
    // Seçili ay/kapsamla tutarlı olsun diye pastayla aynı veri kümesi.
    for (final t in _monthTransactions) {
      if (t.type != TransactionType.gider) continue;
      final raw = (t.note != null && t.note!.trim().isNotEmpty)
          ? t.note!.trim()
          : 'Diğer';
      final key = raw.toLowerCase();
      totals[key] = (totals[key] ?? 0) + t.amount;
      labels.putIfAbsent(key, () => raw);
    }
    final entries = totals.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            for (int i = 0; i < entries.length; i++) ...[
              // Renk, listedeki harf rozetiyle aynı (etiket kimliği tutarlı).
              _breakdownRow(labels[entries[i].key]!, entries[i].value,
                  labelColor(labels[entries[i].key]!)),
              if (i != entries.length - 1) const SizedBox(height: 14),
            ],
          ],
        ),
      ),
    );
  }

  Widget _breakdownRow(String label, int amount, Color color) {
    final pct = _totalExpense == 0 ? 0.0 : amount / _totalExpense;
    return Row(
      children: [
        Container(
          width: 38,
          height: 38,
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.14),
            borderRadius: BorderRadius.circular(11),
          ),
          child: Icon(Icons.label_rounded, color: color, size: 19),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(label,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(fontWeight: FontWeight.w600)),
                  ),
                  const SizedBox(width: 8),
                  Text(AppFormatters.formatCurrency(amount),
                      style: const TextStyle(
                          fontWeight: FontWeight.w700,
                          fontFeatures: AppTheme.tabularFigures)),
                ],
              ),
              const SizedBox(height: 6),
              ClipRRect(
                borderRadius: BorderRadius.circular(6),
                child: LinearProgressIndicator(
                  value: pct,
                  minHeight: 6,
                  backgroundColor: color.withValues(alpha: 0.12),
                  valueColor: AlwaysStoppedAnimation(color),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _MonthBucket {
  final DateTime date;
  int income = 0; // kuruş
  int expense = 0; // kuruş
  _MonthBucket(this.date);

  String get label => kShortMonthNames[date.month - 1];
}
