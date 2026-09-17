import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:personal_finance_tracker/database/database_service.dart';
import 'package:personal_finance_tracker/models/recurring_rule.dart';
import 'package:personal_finance_tracker/models/transaction.dart';
import 'package:personal_finance_tracker/utils/app_theme.dart';
import 'package:personal_finance_tracker/utils/check_message.dart';
import 'package:personal_finance_tracker/utils/formatters.dart';
import 'package:personal_finance_tracker/utils/month_names.dart';
import 'package:personal_finance_tracker/widgets/month_year_picker.dart';

/// Modern modal bottom sheet — hem yeni işlem ekleme hem düzenleme için.
Future<bool?> showTransactionSheet(BuildContext context,
    {Transaction? existing}) {
  return showModalBottomSheet<bool>(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (_) => TransactionSheet(existing: existing),
  );
}

class TransactionSheet extends StatefulWidget {
  final Transaction? existing;
  const TransactionSheet({super.key, this.existing});

  @override
  State<TransactionSheet> createState() => _TransactionSheetState();
}

class _TransactionSheetState extends State<TransactionSheet> {
  final _db = DatabaseService();
  final _amountController = TextEditingController();
  final _noteController = TextEditingController();
  final _noteFocus = FocusNode();

  late TransactionType _type;
  late DateTime _date;
  List<String> _noteSuggestions = [];
  bool _recurring = false; // yalnızca yeni işlemde geçerli

  // Tekrarlama ay aralığı (yalnızca _recurring iken kullanılır).
  late DateTime _recurStart; // DateTime(yıl, ay)
  late DateTime _recurEnd; // DateTime(yıl, ay)
  bool _recurIndefinite = false; // true → bitiş yok (süresiz)

  static const _months = [
    'Ocak', 'Şubat', 'Mart', 'Nisan', 'Mayıs', 'Haziran',
    'Temmuz', 'Ağustos', 'Eylül', 'Ekim', 'Kasım', 'Aralık'
  ];

  bool get _isEdit => widget.existing != null;
  bool get _isIncome => _type == TransactionType.gelir;

  @override
  void initState() {
    super.initState();
    final e = widget.existing;
    // Yeni işlemde gider varsayılan: kayıtların çoğu harcama.
    _type = e?.type ?? TransactionType.gider;
    _date = e?.date ?? DateTime.now();
    _recurStart = DateTime(_date.year, _date.month);
    _recurEnd = DateTime(_date.year, 12); // varsayılan: yıl sonu (ör. Aralık)
    if (e != null) {
      _amountController.text = AppFormatters.centsToInput(e.amount);
      _noteController.text = e.note ?? '';
    }
    _loadNoteSuggestions();
  }

  Future<void> _loadNoteSuggestions() async {
    final notes = await _db.getDistinctNotes();
    if (!mounted) return;
    setState(() => _noteSuggestions = notes);
  }

  // Hızlı tutar çipi: mevcut tutara ekler.
  void _addAmount(int lira) {
    final current = AppFormatters.parseAmountCents(_amountController.text) ?? 0;
    final updated = current + lira * 100;
    _amountController.text = AppFormatters.centsToInput(updated);
    HapticFeedback.selectionClick();
    setState(() {});
  }

  @override
  void dispose() {
    _amountController.dispose();
    _noteController.dispose();
    _noteFocus.dispose();
    super.dispose();
  }

  void _setType(TransactionType t) {
    HapticFeedback.selectionClick();
    setState(() => _type = t);
  }

  @override
  Widget build(BuildContext context) {
    final color =
        _isIncome ? AppTheme.incomeColor : AppTheme.expenseColor;
    final bottomInset = MediaQuery.of(context).viewInsets.bottom;
    final surface = Theme.of(context).colorScheme.surface;

    return AnimatedPadding(
      duration: const Duration(milliseconds: 150),
      padding: EdgeInsets.only(bottom: bottomInset),
      child: Container(
        decoration: BoxDecoration(
          color: surface,
          borderRadius:
              const BorderRadius.vertical(top: Radius.circular(28)),
        ),
        child: SingleChildScrollView(
          // Android 15+ uygulamayı gezinme çubuğunun altına çizer; Kaydet
          // düğmesi çubuğun arkasında kalmasın. Klavye açıkken bu değer 0.
          padding: EdgeInsets.fromLTRB(
              20, 12, 20, 24 + MediaQuery.paddingOf(context).bottom),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Sürükleme tutamacı
              Center(
                child: Container(
                  width: 44,
                  height: 5,
                  decoration: BoxDecoration(
                    color: Theme.of(context)
                        .colorScheme
                        .onSurfaceVariant
                        .withValues(alpha: 0.4),
                    borderRadius: BorderRadius.circular(3),
                  ),
                ),
              ),
              const SizedBox(height: 18),
              Text(
                _isEdit ? 'İşlemi Düzenle' : 'Yeni İşlem',
                style: Theme.of(context).textTheme.titleLarge,
              ),
              const SizedBox(height: 18),

              // Gelir / Gider seçici
              _TypeToggle(type: _type, onChanged: _setType),
              const SizedBox(height: 20),

              TextField(
                controller: _amountController,
                keyboardType:
                    const TextInputType.numberWithOptions(decimal: true),
                style: const TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    fontFeatures: AppTheme.tabularFigures),
                decoration: const InputDecoration(
                  labelText: 'Tutar',
                  prefixIcon: Icon(Icons.payments_outlined),
                  suffixText: '₺',
                ),
              ),
              const SizedBox(height: 10),

              // Hızlı tutar çipleri
              Wrap(
                spacing: 8,
                children: [
                  for (final v in const [50, 100, 500, 1000])
                    ActionChip(
                      label: Text('+$v'),
                      onPressed: () => _addAmount(v),
                      visualDensity: VisualDensity.compact,
                    ),
                ],
              ),
              const SizedBox(height: 14),

              // Not — geçmiş notlardan otomatik tamamlamalı
              Autocomplete<String>(
                textEditingController: _noteController,
                focusNode: _noteFocus,
                optionsBuilder: (value) {
                  final q = value.text.trim().toLowerCase();
                  if (q.isEmpty) return const Iterable<String>.empty();
                  return _noteSuggestions
                      .where((n) =>
                          n.toLowerCase().contains(q) &&
                          n.toLowerCase() != q)
                      .take(5);
                },
                fieldViewBuilder:
                    (context, controller, focusNode, onFieldSubmitted) {
                  return TextField(
                    controller: controller,
                    focusNode: focusNode,
                    textCapitalization: TextCapitalization.sentences,
                    decoration: const InputDecoration(
                      labelText: 'Not',
                      helperText:
                          'Sınıflandırma için kullanılır · boşsa "Diğer"',
                      prefixIcon: Icon(Icons.notes_rounded),
                    ),
                    onSubmitted: (_) => onFieldSubmitted(),
                  );
                },
                optionsViewBuilder: (context, onSelected, options) {
                  return Align(
                    alignment: Alignment.topLeft,
                    child: Material(
                      elevation: 4,
                      borderRadius: BorderRadius.circular(12),
                      child: ConstrainedBox(
                        constraints: const BoxConstraints(
                            maxHeight: 200, maxWidth: 400),
                        child: ListView(
                          padding: EdgeInsets.zero,
                          shrinkWrap: true,
                          children: [
                            for (final o in options)
                              ListTile(
                                dense: true,
                                leading: const Icon(Icons.history_rounded,
                                    size: 18),
                                title: Text(o),
                                onTap: () => onSelected(o),
                              ),
                          ],
                        ),
                      ),
                    ),
                  );
                },
              ),
              const SizedBox(height: 14),

              // Tarih seçici
              Material(
                color: Theme.of(context)
                    .colorScheme
                    .surfaceContainerHighest
                    .withValues(alpha: 0.5),
                borderRadius: BorderRadius.circular(16),
                child: InkWell(
                  borderRadius: BorderRadius.circular(16),
                  onTap: _pickDate,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 16, vertical: 16),
                    child: Row(
                      children: [
                        const Icon(Icons.calendar_today_rounded, size: 20),
                        const SizedBox(width: 12),
                        const Text('Tarih'),
                        const Spacer(),
                        Text(
                          _fmtDate(_date),
                          style:
                              const TextStyle(fontWeight: FontWeight.w600),
                        ),
                        const SizedBox(width: 4),
                        const Icon(Icons.expand_more_rounded, size: 20),
                      ],
                    ),
                  ),
                ),
              ),

              // Tekrarlama — yalnızca yeni işlem eklerken sunulur.
              if (!_isEdit) ...[
                const SizedBox(height: 12),
                Material(
                  color: Theme.of(context)
                      .colorScheme
                      .surfaceContainerHighest
                      .withValues(alpha: 0.5),
                  borderRadius: BorderRadius.circular(16),
                  child: SwitchListTile(
                    contentPadding:
                        const EdgeInsets.symmetric(horizontal: 12),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16)),
                    secondary: const Icon(Icons.repeat_rounded),
                    title: const Text('Her ay tekrarla'),
                    subtitle: Text(
                      'Ayın ${_date.day}. günü otomatik eklenir',
                      style: const TextStyle(fontSize: 12),
                    ),
                    value: _recurring,
                    onChanged: (v) {
                      HapticFeedback.selectionClick();
                      setState(() {
                        _recurring = v;
                        if (v) {
                          // Aralığı, seçili işlem tarihine göre tazele.
                          _recurStart = DateTime(_date.year, _date.month);
                          _recurEnd = DateTime(_date.year, 12);
                          _recurIndefinite = false;
                        }
                      });
                    },
                  ),
                ),
                if (_recurring) ...[
                  const SizedBox(height: 8),
                  _monthField(
                    label: 'Başlangıç ayı',
                    value: _recurStart,
                    onPick: (d) => setState(() {
                      _recurStart = d;
                      // Bitiş, başlangıçtan önce kalmasın.
                      if (!_recurIndefinite &&
                          _recurEnd.isBefore(_recurStart)) {
                        _recurEnd = _recurStart;
                      }
                    }),
                  ),
                  const SizedBox(height: 8),
                  Material(
                    color: Theme.of(context)
                        .colorScheme
                        .surfaceContainerHighest
                        .withValues(alpha: 0.5),
                    borderRadius: BorderRadius.circular(16),
                    child: SwitchListTile(
                      contentPadding:
                          const EdgeInsets.symmetric(horizontal: 12),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16)),
                      secondary: const Icon(Icons.all_inclusive_rounded),
                      title: const Text('Süresiz'),
                      subtitle: const Text('Bitiş ayı olmadan devam et',
                          style: TextStyle(fontSize: 12)),
                      value: _recurIndefinite,
                      onChanged: (v) {
                        HapticFeedback.selectionClick();
                        setState(() => _recurIndefinite = v);
                      },
                    ),
                  ),
                  if (!_recurIndefinite) ...[
                    const SizedBox(height: 8),
                    _monthField(
                      label: 'Bitiş ayı',
                      value: _recurEnd,
                      onPick: (d) => setState(() => _recurEnd = d),
                    ),
                  ],
                ],
              ],
              const SizedBox(height: 26),

              Row(
                children: [
                  if (_isEdit) ...[
                    SizedBox(
                      height: 54,
                      child: OutlinedButton(
                        onPressed: _delete,
                        style: OutlinedButton.styleFrom(
                          foregroundColor: AppTheme.expenseColor,
                          side: const BorderSide(color: AppTheme.expenseColor),
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16)),
                          padding:
                              const EdgeInsets.symmetric(horizontal: 18),
                        ),
                        child: const Icon(Icons.delete_outline),
                      ),
                    ),
                    const SizedBox(width: 12),
                  ],
                  Expanded(
                    child: SizedBox(
                      height: 54,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: color,
                          foregroundColor: Colors.white,
                        ),
                        onPressed: _save,
                        child: Text(
                          _isEdit ? 'Güncelle' : 'Kaydet',
                          style: const TextStyle(
                              fontSize: 16, fontWeight: FontWeight.bold),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _fmtDate(DateTime d) => '${d.day} ${_months[d.month - 1]} ${d.year}';

  Widget _monthField({
    required String label,
    required DateTime value,
    required ValueChanged<DateTime> onPick,
  }) {
    return Material(
      color: Theme.of(context)
          .colorScheme
          .surfaceContainerHighest
          .withValues(alpha: 0.5),
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: () async {
          HapticFeedback.selectionClick();
          final picked = await showMonthYearPicker(context, initial: value);
          if (picked != null) onPick(picked);
        },
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
          child: Row(
            children: [
              const Icon(Icons.event_rounded, size: 20),
              const SizedBox(width: 12),
              Text(label),
              const Spacer(),
              Text(monthLabel(value),
                  style: const TextStyle(fontWeight: FontWeight.w600)),
              const SizedBox(width: 4),
              const Icon(Icons.expand_more_rounded, size: 20),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _pickDate() async {
    HapticFeedback.selectionClick();
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: _date,
      firstDate: DateTime(now.year - 5),
      lastDate: DateTime(now.year + 1, 12, 31),
    );
    if (picked != null) {
      // Saat bilgisini koru (aynı gün eklenenlerin sırası bozulmasın).
      setState(() => _date = DateTime(
            picked.year,
            picked.month,
            picked.day,
            _date.hour,
            _date.minute,
            _date.second,
          ));
    }
  }

  Future<void> _save() async {
    final amount = AppFormatters.parseAmountCents(_amountController.text);
    if (amount == null || amount <= 0) {
      HapticFeedback.heavyImpact();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Geçerli bir tutar giriniz')),
      );
      return;
    }

    final note = _noteController.text.trim();
    final model = (widget.existing ??
            Transaction(amount: amount, type: _type, date: _date))
        .copyWith(
      amount: amount,
      type: _type,
      date: _date,
      // Not boşsa sınıflandırmada 'Diğer' başlığı altında toplanır.
      note: note.isEmpty ? 'Diğer' : note,
    );

    if (_isEdit) {
      await _db.updateTransaction(model);
    } else if (_recurring) {
      // Tekrarlayan seri: aralıktaki her ay için işlem, üst ekranda
      // generateDue() ile üretilir. Ayrı bir tek seferlik kayıt eklenmez.
      final end = _recurIndefinite ? null : _recurEnd;
      if (end != null && end.isBefore(_recurStart)) {
        HapticFeedback.heavyImpact();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
              content: Text('Bitiş ayı, başlangıçtan önce olamaz')),
        );
        return;
      }
      // last = başlangıçtan bir önceki ay → üretim başlangıç ayını da kapsar.
      final beforeStart = DateTime(_recurStart.year, _recurStart.month - 1);
      await _db.insertRecurringRule(RecurringRule(
        amount: amount,
        type: _type,
        note: model.note,
        dayOfMonth: _date.day,
        startYear: _recurStart.year,
        startMonth: _recurStart.month,
        lastYear: beforeStart.year,
        lastMonth: beforeStart.month,
        endYear: end?.year,
        endMonth: end?.month,
      ));
    } else {
      await _db.insertTransaction(model);
    }
    HapticFeedback.mediumImpact();
    if (!mounted) return;
    Navigator.pop(context, true);
  }

  Future<void> _delete() async {
    final id = widget.existing?.id;
    if (id == null) return;
    final ok = await checkMessage(context, 'Silme', 'Bu işlem silinsin mi?');
    if (!ok) return;
    await _db.deleteOneItem(id);
    HapticFeedback.mediumImpact();
    if (!mounted) return;
    Navigator.pop(context, true);
  }
}

class _TypeToggle extends StatelessWidget {
  final TransactionType type;
  final ValueChanged<TransactionType> onChanged;
  const _TypeToggle({required this.type, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    final bg = Theme.of(context).colorScheme.surfaceContainerHighest
        .withValues(alpha: 0.5);
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          _seg('Gider', Icons.north_east_rounded, TransactionType.gider,
              AppTheme.expenseColor),
          _seg('Gelir', Icons.south_west_rounded, TransactionType.gelir,
              AppTheme.incomeColor),
        ],
      ),
    );
  }

  Widget _seg(String label, IconData icon, TransactionType t, Color color) {
    final selected = type == t;
    return Expanded(
      child: GestureDetector(
        onTap: () => onChanged(t),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          curve: Curves.easeOut,
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            color: selected ? color : Colors.transparent,
            borderRadius: BorderRadius.circular(13),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon,
                  size: 18, color: selected ? Colors.white : color),
              const SizedBox(width: 6),
              Text(
                label,
                style: TextStyle(
                  color: selected ? Colors.white : null,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
