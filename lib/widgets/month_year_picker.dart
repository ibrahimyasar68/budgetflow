import 'package:flutter/material.dart';
import 'package:personal_finance_tracker/utils/month_names.dart';

/// Ay + yıl seçtiren basit diyalog. Seçilen ay `DateTime(yıl, ay)` döner,
/// iptalde null döner.
Future<DateTime?> showMonthYearPicker(
  BuildContext context, {
  required DateTime initial,
  int? firstYear,
  int? lastYear,
}) {
  return showDialog<DateTime>(
    context: context,
    builder: (_) => _MonthYearDialog(
      initial: initial,
      firstYear: firstYear ?? DateTime.now().year - 5,
      lastYear: lastYear ?? DateTime.now().year + 5,
    ),
  );
}

class _MonthYearDialog extends StatefulWidget {
  final DateTime initial;
  final int firstYear;
  final int lastYear;
  const _MonthYearDialog({
    required this.initial,
    required this.firstYear,
    required this.lastYear,
  });

  @override
  State<_MonthYearDialog> createState() => _MonthYearDialogState();
}

class _MonthYearDialogState extends State<_MonthYearDialog> {
  late int _year = widget.initial.year;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return AlertDialog(
      contentPadding: const EdgeInsets.fromLTRB(20, 20, 20, 12),
      content: SizedBox(
        width: 320,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Yıl seçici
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                IconButton(
                  onPressed: _year > widget.firstYear
                      ? () => setState(() => _year--)
                      : null,
                  icon: const Icon(Icons.chevron_left_rounded),
                ),
                Text('$_year',
                    style: Theme.of(context)
                        .textTheme
                        .titleLarge
                        ?.copyWith(fontWeight: FontWeight.w800)),
                IconButton(
                  onPressed: _year < widget.lastYear
                      ? () => setState(() => _year++)
                      : null,
                  icon: const Icon(Icons.chevron_right_rounded),
                ),
              ],
            ),
            const SizedBox(height: 8),
            // 12 ay ızgarası
            GridView.count(
              crossAxisCount: 3,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              mainAxisSpacing: 8,
              crossAxisSpacing: 8,
              childAspectRatio: 2.1,
              children: [
                for (int mo = 1; mo <= 12; mo++)
                  _monthCell(mo, scheme),
              ],
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('İptal'),
        ),
      ],
    );
  }

  Widget _monthCell(int mo, ColorScheme scheme) {
    final selected =
        _year == widget.initial.year && mo == widget.initial.month;
    return Material(
      color: selected ? scheme.primary : scheme.surfaceContainerHighest,
      borderRadius: BorderRadius.circular(12),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: () => Navigator.pop(context, DateTime(_year, mo)),
        child: Center(
          child: Text(
            kShortMonthNames[mo - 1],
            style: TextStyle(
              fontWeight: FontWeight.w700,
              color: selected ? Colors.white : null,
            ),
          ),
        ),
      ),
    );
  }
}
