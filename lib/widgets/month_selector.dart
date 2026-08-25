import 'package:flutter/material.dart';
import 'package:personal_finance_tracker/utils/month_names.dart';

/// İşlem ve Grafik sekmelerinin paylaştığı ay/kapsam seçici.
/// [selectedMonth] null ise "Tüm Zamanlar" gösterilir.
class MonthSelector extends StatelessWidget {
  final DateTime? selectedMonth;
  final VoidCallback onPrev;
  final VoidCallback onNext;
  final VoidCallback onToggleAll;

  const MonthSelector({
    super.key,
    required this.selectedMonth,
    required this.onPrev,
    required this.onNext,
    required this.onToggleAll,
  });

  @override
  Widget build(BuildContext context) {
    final isAll = selectedMonth == null;
    final now = DateTime.now();
    // Gelecek ay seçilemesin (içinde bulunulan aydan ileri gitme).
    final canGoNext = !isAll &&
        (selectedMonth!.year < now.year ||
            (selectedMonth!.year == now.year &&
                selectedMonth!.month < now.month));
    final scheme = Theme.of(context).colorScheme;

    return Row(
      children: [
        IconButton(
          onPressed: isAll ? null : onPrev,
          icon: const Icon(Icons.chevron_left_rounded),
          visualDensity: VisualDensity.compact,
        ),
        Expanded(
          child: GestureDetector(
            onTap: onToggleAll,
            child: Container(
              padding: const EdgeInsets.symmetric(vertical: 8),
              alignment: Alignment.center,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    isAll ? Icons.all_inclusive_rounded : Icons.event_rounded,
                    size: 16,
                    color: scheme.primary,
                  ),
                  const SizedBox(width: 6),
                  Text(
                    isAll ? 'Tüm Zamanlar' : monthLabel(selectedMonth!),
                    style: const TextStyle(
                        fontWeight: FontWeight.w700, fontSize: 15),
                  ),
                ],
              ),
            ),
          ),
        ),
        IconButton(
          onPressed: canGoNext ? onNext : null,
          icon: const Icon(Icons.chevron_right_rounded),
          visualDensity: VisualDensity.compact,
        ),
      ],
    );
  }
}
