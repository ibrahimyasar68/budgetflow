import 'package:flutter/material.dart';
import 'package:personal_finance_tracker/utils/app_theme.dart';
import 'package:personal_finance_tracker/utils/formatters.dart';

/// Bütçe limiti belirleme / düzenleme diyaloğu (aylık toplam veya etiket bazlı).
///
/// Döner:
///   • pozitif kuruş değeri → yeni limit,
///   • 0 → limiti kaldır,
///   • null → iptal (değişiklik yok).
Future<int?> showBudgetDialog(
  BuildContext context, {
  int? current,
  String title = 'Aylık Bütçe Limiti',
  String description = 'Aylık toplam gider için bir üst sınır belirle. '
      'Ana ekranda ne kadar harcadığını ve kalanı görürsün.',
}) {
  final controller = TextEditingController(
    text: (current != null && current > 0)
        ? AppFormatters.centsToInput(current)
        : '',
  );
  final hasExisting = current != null && current > 0;

  return showDialog<int>(
    context: context,
    builder: (ctx) {
      String? error;
      return StatefulBuilder(
        builder: (ctx, setLocal) {
          void submit() {
            final cents = AppFormatters.parseAmountCents(controller.text);
            if (cents == null || cents <= 0) {
              setLocal(() => error = 'Geçerli bir tutar gir');
              return;
            }
            Navigator.pop(ctx, cents);
          }

          return AlertDialog(
            title: Text(title),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  description,
                  style: TextStyle(
                    fontSize: 13,
                    color: Theme.of(ctx).colorScheme.onSurfaceVariant,
                  ),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: controller,
                  autofocus: true,
                  keyboardType:
                      const TextInputType.numberWithOptions(decimal: true),
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    fontFeatures: AppTheme.tabularFigures,
                  ),
                  decoration: InputDecoration(
                    labelText: 'Limit',
                    prefixIcon: const Icon(Icons.savings_outlined),
                    suffixText: '₺',
                    errorText: error,
                  ),
                  onChanged: (_) {
                    if (error != null) setLocal(() => error = null);
                  },
                  onSubmitted: (_) => submit(),
                ),
              ],
            ),
            actions: [
              if (hasExisting)
                TextButton(
                  onPressed: () => Navigator.pop(ctx, 0),
                  style: TextButton.styleFrom(
                      foregroundColor: AppTheme.expenseColor),
                  child: const Text('Kaldır'),
                ),
              TextButton(
                onPressed: () => Navigator.pop(ctx),
                child: const Text('İptal'),
              ),
              FilledButton(
                onPressed: submit,
                child: const Text('Kaydet'),
              ),
            ],
          );
        },
      );
    },
  );
}
