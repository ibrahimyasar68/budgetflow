import 'dart:convert';
import 'dart:math';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:personal_finance_tracker/database/database_service.dart';
import 'package:personal_finance_tracker/models/transaction.dart';
import 'package:personal_finance_tracker/screens/about.dart';
import 'package:personal_finance_tracker/screens/budget_dialog.dart';
import 'package:personal_finance_tracker/screens/budgets_page.dart';
import 'package:personal_finance_tracker/screens/recurring_page.dart';
import 'package:personal_finance_tracker/screens/tabs/chart_tab.dart';
import 'package:personal_finance_tracker/screens/tabs/settings_tab.dart';
import 'package:personal_finance_tracker/screens/transaction_sheet.dart';
import 'package:personal_finance_tracker/utils/ad_service.dart';
import 'package:personal_finance_tracker/utils/app_theme.dart';
import 'package:personal_finance_tracker/utils/backup_service.dart';
import 'package:personal_finance_tracker/utils/check_message.dart';
import 'package:personal_finance_tracker/utils/export_service.dart';
import 'package:personal_finance_tracker/utils/fade_route.dart';
import 'package:personal_finance_tracker/utils/file_bytes.dart';
import 'package:personal_finance_tracker/utils/formatters.dart';
import 'package:personal_finance_tracker/utils/month_names.dart';
import 'package:personal_finance_tracker/utils/recurring_service.dart';
import 'package:personal_finance_tracker/widgets/empty_state.dart';
import 'package:personal_finance_tracker/widgets/month_selector.dart';

/// Ana kabuk: alt gezinme + üç sekme (İşlem / Grafik / Ayarlar).
/// İşlem verisi ve seçili ay/kapsam burada tutulur; Grafik ve Ayarlar
/// sekmeleri ayrı widget'lardır ve gerekli veriyi/geri çağrıları alır.
class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> with TickerProviderStateMixin {
  final DatabaseService _db = DatabaseService();
  final TextEditingController _searchController = TextEditingController();
  List<Transaction> _transactions = [];
  int _selectedIndex = 0;

  // Filtre durumu
  String _searchQuery = '';
  TransactionType? _typeFilter; // null = Tümü
  DateTime? _selectedMonth; // null = Tümü (tüm zamanlar); aksi halde o ay

  // Aylık gider limiti (kuruş). null = limit belirlenmedi.
  int? _monthlyBudget;

  late final AnimationController _listAnim;
  late final AnimationController _fabAnim;

  // Alt bardaki banner reklam. Yüklenene kadar yer kaplamaz.
  BannerAd? _bannerAd;
  bool _isBannerLoaded = false;

  @override
  void initState() {
    super.initState();
    final now = DateTime.now();
    _selectedMonth = DateTime(now.year, now.month);
    _listAnim = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 700),
    );
    _fabAnim = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 320),
    );
    _loadTransactions();
    _loadBudget();
    // Adaptive banner ekran genişliğine göre boyutlandığı için MediaQuery
    // gerekiyor; initState'te henüz erişilemez, ilk kareden sonra yüklenir.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) _loadBannerAd();
    });
  }

  Future<void> _loadBannerAd() async {
    final width = MediaQuery.sizeOf(context).width.truncate();
    final ad = await AdService.instance.createBannerAd(
      width: width,
      onLoaded: () {
        if (mounted) setState(() => _isBannerLoaded = true);
      },
    );
    if (!mounted) {
      ad?.dispose();
      return;
    }
    setState(() => _bannerAd = ad);
  }

  Future<void> _loadBudget() async {
    final raw = await _db.getSetting('budgetLimit');
    final v = raw == null ? null : int.tryParse(raw);
    if (!mounted) return;
    setState(() => _monthlyBudget = (v != null && v > 0) ? v : null);
  }

  @override
  void dispose() {
    _listAnim.dispose();
    _fabAnim.dispose();
    _searchController.dispose();
    _bannerAd?.dispose();
    super.dispose();
  }

  // Seçili aydaki işlemler (özet kartı ve liste bunun üzerinden hesaplanır).
  List<Transaction> get _monthTransactions {
    final m = _selectedMonth;
    if (m == null) return _transactions;
    return _transactions
        .where((t) => t.date.year == m.year && t.date.month == m.month)
        .toList();
  }

  // Aya ek olarak arama ve tür filtresinden de geçen işlemler (liste için).
  List<Transaction> get _visibleTransactions {
    final q = _searchQuery.trim().toLowerCase();
    return _monthTransactions.where((t) {
      if (_typeFilter != null && t.type != _typeFilter) return false;
      if (q.isEmpty) return true;
      final note = t.note?.toLowerCase() ?? '';
      return note.contains(q);
    }).toList();
  }

  // Belirli bir ayın net bakiyesi (trend göstergesi için).
  int _netForMonth(DateTime m) {
    var net = 0;
    for (final t in _transactions) {
      if (t.date.year == m.year && t.date.month == m.month) {
        net += t.type == TransactionType.gelir ? t.amount : -t.amount;
      }
    }
    return net;
  }

  // Belirli bir ayın toplam gideri (bütçe limiti kontrolü için).
  int _expenseForMonth(DateTime m) {
    var sum = 0;
    for (final t in _transactions) {
      if (t.type == TransactionType.gider &&
          t.date.year == m.year &&
          t.date.month == m.month) {
        sum += t.amount;
      }
    }
    return sum;
  }

  void _changeMonth(int delta) {
    HapticFeedback.selectionClick();
    final now = DateTime.now();
    final base = _selectedMonth ?? DateTime(now.year, now.month);
    setState(() => _selectedMonth = DateTime(base.year, base.month + delta));
  }

  void _toggleAllMonths() {
    HapticFeedback.selectionClick();
    final now = DateTime.now();
    setState(() => _selectedMonth =
        _selectedMonth == null ? DateTime(now.year, now.month) : null);
  }

  Future<void> _loadTransactions() async {
    final data = await _db.getAllTransactions();
    if (!mounted) return;
    setState(() => _transactions = data);
    _listAnim.forward(from: 0);
  }

  Future<void> _openSheet({Transaction? existing}) async {
    HapticFeedback.mediumImpact();
    final wasEmpty = _transactions.isEmpty;
    // Bütçe uyarısı: bu ayın gideri, işlemden önce limitin altında mıydı?
    final budget = _monthlyBudget;
    final thisMonth = DateTime.now();
    final expenseBefore = budget != null ? _expenseForMonth(thisMonth) : 0;
    _fabAnim.forward();
    final result = await showTransactionSheet(context, existing: existing);
    _fabAnim.reverse();
    if (result == true) {
      // Yeni bir tekrarlama kuralı eklendiyse, geçmiş ayların işlemlerini
      // hemen üret (aksi halde yalnızca bir sonraki açılışta oluşurdu).
      await RecurringService(_db).generateDue();
      await _loadTransactions();
      if (!mounted) return;
      // Ekranda okunması gereken bir bildirim gösterildi mi? Gösterildiyse
      // geçiş reklamı bu turu atlar (aksi halde snackbar'ın üstünü kapatır).
      var showedNotice = false;
      // İlk işlem eklendiğinde küçük bir kutlama.
      if (existing == null && wasEmpty && _transactions.isNotEmpty) {
        showedNotice = true;
        HapticFeedback.lightImpact();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('🎉 İlk işlemini ekledin! Böyle devam.'),
            behavior: SnackBarBehavior.floating,
          ),
        );
      } else if (budget != null && budget > 0) {
        // Yalnızca sınırı bu işlem ilk kez aştıysa uyar (tekrar spam yok).
        final expenseAfter = _expenseForMonth(thisMonth);
        if (expenseBefore <= budget && expenseAfter > budget) {
          showedNotice = true;
          HapticFeedback.heavyImpact();
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Bu ay bütçe limitini aştın · '
                  '${AppFormatters.formatCurrency(expenseAfter - budget)} üzerinde'),
              behavior: SnackBarBehavior.floating,
            ),
          );
        }
      }
      // Geçiş reklamı yalnızca yeni kayıtta; düzenlemede gösterilmez.
      // Bütçe aşım uyarısı gibi bir bildirim varsa reklam bir sonraki kayda
      // ertelenir — uyarı reklamın altında kaybolmasın.
      if (existing == null) {
        await AdService.instance.maybeShowInterstitialAfterSave(
          _db,
          skipThisRound: showedNotice,
        );
      }
    }
  }

  Future<void> _deleteWithUndo(Transaction tx) async {
    await _db.deleteOneItem(tx.id!);
    await _loadTransactions();
    if (!mounted) return;
    final messenger = ScaffoldMessenger.of(context)..hideCurrentSnackBar();
    messenger.showSnackBar(
      SnackBar(
        content: const Text('İşlem silindi'),
        behavior: SnackBarBehavior.floating,
        action: SnackBarAction(
          label: 'Geri Al',
          onPressed: () async {
            // Aynı verilerle yeniden ekle (yeni id alır).
            await _db.insertTransaction(tx);
            await _loadTransactions();
          },
        ),
      ),
    );
  }

  Future<void> _confirmExit() async {
    final ok = await checkMessage(
        context, 'Çıkış', 'Uygulamadan çıkmak istiyor musunuz?');
    if (!ok) return;
    if (!kIsWeb) {
      SystemNavigator.pop();
    }
  }

  // ── Hesaplamalar ──────────────────────────────────────────────────────────

  // Tüm tutarlar kuruş (int) cinsinden — tam sayı aritmetiği, yuvarlama hatası yok.
  // Özet, seçili ay kapsamı (`_monthTransactions`) üzerinden hesaplanır.
  int get _totalIncome => _monthTransactions
      .where((t) => t.type == TransactionType.gelir)
      .fold(0, (s, t) => s + t.amount);

  int get _totalExpense => _monthTransactions
      .where((t) => t.type == TransactionType.gider)
      .fold(0, (s, t) => s + t.amount);

  int get _balance => _totalIncome - _totalExpense;

  // ── Build ────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: _buildAppBar(),
      body: IndexedStack(
        index: _selectedIndex,
        children: [
          _buildTransactionTab(),
          ChartTab(
            transactions: _transactions,
            selectedMonth: _selectedMonth,
            monthSelector: _monthSelector(),
          ),
          SettingsTab(
            monthlyBudget: _monthlyBudget,
            onOpenBudgets: _openBudgets,
            onOpenRecurring: _openRecurring,
            onBackup: _backupJson,
            onSaveLocal: _saveBackupLocal,
            onRestore: _restoreBackup,
            onExportCsv: _exportCsv,
            onExit: _confirmExit,
          ),
        ],
      ),
      floatingActionButton: _selectedIndex == 0 ? _buildFab() : null,
      bottomNavigationBar: _buildBottomBar(),
    );
  }

  AppBar _buildAppBar() {
    const titles = ['BudgetFlow', 'Grafik', 'Ayarlar'];
    return AppBar(
      title: Text(titles[_selectedIndex]),
      actions: [
        if (_selectedIndex == 0)
          IconButton(
            icon: const Icon(Icons.info_outline),
            onPressed: () =>
                Navigator.push(context, fadeRoute(const AboutPage())),
          ),
      ],
    );
  }

  /// Banner reklam + mevcut alt gezinme çubuğu. Reklam yüklenmediyse yalnızca
  /// gezinme çubuğu görünür (yer tutucu boşluk bırakılmaz).
  Widget _buildBottomBar() {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        if (_isBannerLoaded && _bannerAd != null)
          Container(
            color: Theme.of(context).colorScheme.surface,
            width: _bannerAd!.size.width.toDouble(),
            height: _bannerAd!.size.height.toDouble(),
            alignment: Alignment.center,
            child: AdWidget(ad: _bannerAd!),
          ),
        _buildBottomNav(),
      ],
    );
  }

  Widget _buildBottomNav() {
    return NavigationBar(
      selectedIndex: _selectedIndex,
      onDestinationSelected: (i) {
        HapticFeedback.selectionClick();
        setState(() => _selectedIndex = i);
      },
      labelBehavior: NavigationDestinationLabelBehavior.onlyShowSelected,
      destinations: const [
        NavigationDestination(
          icon: Icon(Icons.home_outlined),
          selectedIcon: Icon(Icons.home),
          label: 'Ana Sayfa',
        ),
        NavigationDestination(
          icon: Icon(Icons.pie_chart_outline),
          selectedIcon: Icon(Icons.pie_chart),
          label: 'Grafik',
        ),
        NavigationDestination(
          icon: Icon(Icons.settings_outlined),
          selectedIcon: Icon(Icons.settings),
          label: 'Ayarlar',
        ),
      ],
    );
  }

  Widget _buildFab() {
    return AnimatedBuilder(
      animation: _fabAnim,
      builder: (_, child) => Transform.rotate(
        angle: _fabAnim.value * pi / 2,
        child: child,
      ),
      child: FloatingActionButton(
        onPressed: () => _openSheet(),
        child: const Icon(Icons.add),
      ),
    );
  }

  // ── Ayarlardan açılan alt ekranlar ─────────────────────────────────────────

  Future<void> _openBudgets() async {
    await Navigator.push(context, fadeRoute(const BudgetsPage()));
    await _loadBudget();
    if (mounted) setState(() {});
  }

  Future<void> _openRecurring() async {
    await Navigator.push(context, fadeRoute(const RecurringPage()));
    await _loadTransactions();
  }

  // ── İşlem Sekmesi ────────────────────────────────────────────────────────

  Widget _monthSelector() => MonthSelector(
        selectedMonth: _selectedMonth,
        onPrev: () => _changeMonth(-1),
        onNext: () => _changeMonth(1),
        onToggleAll: _toggleAllMonths,
      );

  Widget _buildTransactionTab() {
    // Hiç işlem yokken kaydırılacak bir liste yok; sade düzen yeterli.
    if (_transactions.isEmpty) {
      return Padding(
        padding: const EdgeInsets.fromLTRB(16, 4, 16, 0),
        child: Column(
          children: [
            _buildSummaryCard(),
            const SizedBox(height: 16),
            const Expanded(
              child: EmptyState(
                icon: Icons.receipt_long_rounded,
                title: 'Henüz Bir İşlem Yok',
                subtitle: 'Aşağıdaki + butonuyla ilk işlemini ekle',
              ),
            ),
          ],
        ),
      );
    }

    // Özet/bütçe kartları ve filtre çubuğu artık listeyle birlikte kayıyor.
    // Sabit başlıkken listeye yalnızca birkaç satır kalıyordu; bu haliyle
    // kullanıcı kaydırdığı anda işlem listesi ekranın tamamını kullanıyor.
    return RefreshIndicator(
      onRefresh: _loadTransactions,
      child: CustomScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        slivers: [
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(16, 4, 16, 0),
            sliver: SliverList(
              delegate: SliverChildListDelegate([
                _monthSelector(),
                const SizedBox(height: 12),
                _buildSummaryCard(),
                // Bütçe kartı: yalnızca belirli bir ay seçiliyken ve limit varken.
                if (_selectedMonth != null && _monthlyBudget != null) ...[
                  const SizedBox(height: 12),
                  _buildBudgetCard(),
                ],
                const SizedBox(height: 16),
                _buildFilterBar(),
                const SizedBox(height: 8),
              ]),
            ),
          ),
          SliverPadding(
            // Alt boşluk FAB'ın son satırı kapatmaması için.
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 90),
            sliver: _buildTransactionSliver(),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterBar() {
    return Column(
      children: [
        TextField(
          controller: _searchController,
          onChanged: (v) => setState(() => _searchQuery = v),
          decoration: InputDecoration(
            isDense: true,
            hintText: 'İşlem ara (nota göre)…',
            prefixIcon: const Icon(Icons.search_rounded, size: 20),
            suffixIcon: _searchQuery.isEmpty
                ? null
                : IconButton(
                    icon: const Icon(Icons.close_rounded, size: 18),
                    onPressed: () {
                      _searchController.clear();
                      setState(() => _searchQuery = '');
                    },
                  ),
          ),
        ),
        const SizedBox(height: 10),
        Row(
          children: [
            _filterChip('Tümü', null),
            const SizedBox(width: 8),
            _filterChip('Gelir', TransactionType.gelir),
            const SizedBox(width: 8),
            _filterChip('Gider', TransactionType.gider),
          ],
        ),
      ],
    );
  }

  Widget _filterChip(String label, TransactionType? type) {
    final selected = _typeFilter == type;
    return ChoiceChip(
      label: Text(label),
      selected: selected,
      onSelected: (_) {
        HapticFeedback.selectionClick();
        setState(() => _typeFilter = type);
      },
    );
  }

  Widget _buildSummaryCard() {
    final m = _selectedMonth;
    final cardLabel = m == null ? 'Toplam Bakiye' : '${monthLabel(m)} · Net';
    // Trend: seçili ayın neti, bir önceki aya göre nasıl değişti?
    int? trendDelta;
    if (m != null) {
      final prev = DateTime(m.year, m.month - 1);
      final prevNet = _netForMonth(prev);
      if (prevNet != 0) trendDelta = _netForMonth(m) - prevNet;
    }

    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0, end: _balance.toDouble()),
      duration: const Duration(milliseconds: 900),
      curve: Curves.easeOutCubic,
      builder: (_, animBalance, __) {
        return Container(
          width: double.infinity,
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(24),
            gradient: const LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: AppTheme.balanceGradient,
            ),
            boxShadow: [
              BoxShadow(
                color: AppTheme.seed.withValues(alpha: 0.35),
                blurRadius: 24,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Text(cardLabel,
                      style: const TextStyle(
                          color: Colors.white70, fontSize: 13)),
                  const Spacer(),
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(Icons.account_balance_wallet_rounded,
                        color: Colors.white, size: 18),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                AppFormatters.formatCurrency(animBalance.round()),
                style: const TextStyle(
                  fontSize: 34,
                  fontWeight: FontWeight.w800,
                  color: Colors.white,
                  letterSpacing: -0.8,
                  fontFeatures: AppTheme.tabularFigures,
                ),
              ),
              if (trendDelta != null) ...[
                const SizedBox(height: 6),
                Row(
                  children: [
                    Icon(
                      trendDelta >= 0
                          ? Icons.arrow_upward_rounded
                          : Icons.arrow_downward_rounded,
                      size: 14,
                      color: trendDelta >= 0
                          ? const Color(0xFF7CFFC4)
                          : const Color(0xFFFF9AA8),
                    ),
                    const SizedBox(width: 4),
                    Text(
                      '${AppFormatters.formatCurrency(trendDelta.abs())} geçen aya göre',
                      style: const TextStyle(
                          color: Colors.white70,
                          fontSize: 12,
                          fontFeatures: AppTheme.tabularFigures),
                    ),
                  ],
                ),
              ],
              const SizedBox(height: 20),
              Row(
                children: [
                  Expanded(
                    child: _summaryCol('Gelir', _totalIncome,
                        const Color(0xFF7CFFC4), Icons.south_west_rounded),
                  ),
                  Container(width: 1, height: 38, color: Colors.white24),
                  Expanded(
                    child: _summaryCol('Gider', _totalExpense,
                        const Color(0xFFFF9AA8), Icons.north_east_rounded,
                        right: true),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _summaryCol(String label, int amount, Color color, IconData icon,
      {bool right = false}) {
    return Padding(
      padding: EdgeInsets.only(left: right ? 16 : 0, right: right ? 0 : 16),
      child: Column(
        crossAxisAlignment:
            right ? CrossAxisAlignment.end : CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment:
                right ? MainAxisAlignment.end : MainAxisAlignment.start,
            children: [
              Icon(icon, size: 14, color: color),
              const SizedBox(width: 4),
              Text(label,
                  style:
                      const TextStyle(color: Colors.white70, fontSize: 12)),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            AppFormatters.formatCurrency(amount),
            style: TextStyle(
                color: color,
                fontWeight: FontWeight.bold,
                fontSize: 16,
                fontFeatures: AppTheme.tabularFigures),
          ),
        ],
      ),
    );
  }

  // Bütçe ilerleme rengi: limit altında yeşil, yaklaşınca turuncu, aşınca kırmızı.
  Color _budgetColor(double ratio) {
    if (ratio >= 1.0) return AppTheme.expenseColor;
    if (ratio >= 0.85) return const Color(0xFFFFA726);
    return AppTheme.incomeColor;
  }

  Widget _buildBudgetCard() {
    final limit = _monthlyBudget!;
    final spent = _totalExpense; // seçili ayın gideri
    final ratio = limit == 0 ? 0.0 : spent / limit;
    final over = spent > limit;
    final color = _budgetColor(ratio);
    final scheme = Theme.of(context).colorScheme;

    return Card(
      child: InkWell(
        onTap: _editBudget,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(Icons.savings_outlined, size: 18, color: color),
                  const SizedBox(width: 8),
                  const Text('Aylık Bütçe',
                      style: TextStyle(fontWeight: FontWeight.w700)),
                  const Spacer(),
                  Text(
                    '${AppFormatters.formatCurrency(spent)} / ${AppFormatters.formatCurrency(limit)}',
                    style: TextStyle(
                      fontSize: 13,
                      color: scheme.onSurfaceVariant,
                      fontFeatures: AppTheme.tabularFigures,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: TweenAnimationBuilder<double>(
                  tween: Tween(begin: 0, end: ratio.clamp(0.0, 1.0)),
                  duration: const Duration(milliseconds: 600),
                  curve: Curves.easeOutCubic,
                  builder: (_, v, __) => LinearProgressIndicator(
                    value: v,
                    minHeight: 10,
                    backgroundColor: color.withValues(alpha: 0.14),
                    valueColor: AlwaysStoppedAnimation(color),
                  ),
                ),
              ),
              const SizedBox(height: 10),
              Row(
                children: [
                  Icon(
                    over
                        ? Icons.warning_amber_rounded
                        : Icons.check_circle_outline,
                    size: 15,
                    color: color,
                  ),
                  const SizedBox(width: 5),
                  Text(
                    over
                        ? '${AppFormatters.formatCurrency(spent - limit)} aşıldı'
                        : '${AppFormatters.formatCurrency(limit - spent)} kaldı',
                    style: TextStyle(
                      color: color,
                      fontWeight: FontWeight.w600,
                      fontSize: 13,
                      fontFeatures: AppTheme.tabularFigures,
                    ),
                  ),
                  const Spacer(),
                  Text(
                    '%${(ratio * 100).round()}',
                    style: TextStyle(
                      color: color,
                      fontWeight: FontWeight.w700,
                      fontSize: 13,
                      fontFeatures: AppTheme.tabularFigures,
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

  Future<void> _editBudget() async {
    final result = await showBudgetDialog(context, current: _monthlyBudget);
    if (result == null || !mounted) return; // iptal
    HapticFeedback.selectionClick();
    if (result == 0) {
      await _db.deleteSetting('budgetLimit');
      if (!mounted) return;
      setState(() => _monthlyBudget = null);
    } else {
      await _db.setSetting('budgetLimit', result.toString());
      if (!mounted) return;
      setState(() => _monthlyBudget = result);
    }
  }

  /// İşlem listesi — sliver olarak döner, böylece üstündeki kartlarla aynı
  /// kaydırma alanını paylaşır.
  Widget _buildTransactionSliver() {
    final items = _visibleTransactions;
    if (items.isEmpty) {
      return const SliverFillRemaining(
        hasScrollBody: false,
        child: EmptyState(
          icon: Icons.search_off_rounded,
          title: 'Sonuç Yok',
          subtitle: 'Arama, filtre veya ayı değiştirmeyi dene',
        ),
      );
    }

    // İşlemleri tarih gruplarına ayır (başlık + işlem satırları).
    final rows = <Object>[];
    String? lastBucket;
    for (final t in items) {
      final b = _dateBucket(t.date);
      if (b != lastBucket) {
        rows.add(b);
        lastBucket = b;
      }
      rows.add(t);
    }

    return SliverList(
      delegate: SliverChildBuilderDelegate(
        (context, index) {
          final start = (index * 0.05).clamp(0.0, 0.8);
          final end = (start + 0.4).clamp(0.0, 1.0);
          final row = rows[index];
          final rowChild = row is String
              ? _dateHeader(row)
              : _buildTransactionCard(row as Transaction);

          return AnimatedBuilder(
            animation: _listAnim,
            builder: (_, child) {
              final curved = CurvedAnimation(
                parent: _listAnim,
                curve: Interval(start, end, curve: Curves.easeOutCubic),
              );
              return FadeTransition(
                opacity: curved,
                child: SlideTransition(
                  position: Tween<Offset>(
                    begin: const Offset(0, 0.25),
                    end: Offset.zero,
                  ).animate(curved),
                  child: child,
                ),
              );
            },
            child: rowChild,
          );
        },
        childCount: rows.length,
      ),
    );
  }

  String _dateBucket(DateTime d) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final that = DateTime(d.year, d.month, d.day);
    final diff = today.difference(that).inDays;
    if (diff == 0) return 'Bugün';
    if (diff == 1) return 'Dün';
    if (diff > 1 && diff < 7) return 'Son 7 Gün';
    return monthLabel(DateTime(d.year, d.month));
  }

  Widget _dateHeader(String label) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(4, 14, 4, 6),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 12.5,
          fontWeight: FontWeight.w700,
          letterSpacing: 0.2,
          color: Theme.of(context).colorScheme.onSurfaceVariant,
        ),
      ),
    );
  }

  Widget _buildTransactionCard(Transaction tx) {
    final isIncome = tx.type == TransactionType.gelir;
    final amountColor =
        isIncome ? AppTheme.incomeColor : AppTheme.expenseColor;
    final title = (tx.note != null && tx.note!.isNotEmpty) ? tx.note! : 'Diğer';
    // Rozet (baş harf) rengi de tutarla aynı: gelir yeşil, gider kırmızı.
    final badgeColor = amountColor;

    return Dismissible(
      key: ValueKey(tx.id),
      direction: DismissDirection.horizontal,
      background:
          _swipeBg(Colors.blue.shade400, Icons.edit, Alignment.centerLeft),
      secondaryBackground: _swipeBg(
          AppTheme.expenseColor, Icons.delete, Alignment.centerRight),
      confirmDismiss: (direction) async {
        if (direction == DismissDirection.endToStart) {
          if (tx.id != null) {
            // Onay diyaloğu yerine "Geri Al"lı silme (daha modern kalıp).
            HapticFeedback.mediumImpact();
            await _deleteWithUndo(tx);
            return true;
          }
          return false;
        } else {
          await _openSheet(existing: tx);
          return false;
        }
      },
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 5),
        child: Card(
          child: InkWell(
            onTap: () => _openSheet(existing: tx),
            child: Padding(
              padding:
                  const EdgeInsets.symmetric(horizontal: 12, vertical: 11),
              child: Row(
                children: [
                  Container(
                    width: 48,
                    height: 48,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: badgeColor.withValues(alpha: 0.16),
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: Text(
                      title.characters.first.toUpperCase(),
                      style: TextStyle(
                        color: badgeColor,
                        fontWeight: FontWeight.w800,
                        fontSize: 19,
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          title,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                              fontWeight: FontWeight.w600, fontSize: 15),
                        ),
                        const SizedBox(height: 3),
                        Text(
                          '${isIncome ? 'Gelir' : 'Gider'} · ${_fmtDate(tx.date)}',
                          style: TextStyle(
                              fontSize: 12,
                              color: Theme.of(context)
                                  .colorScheme
                                  .onSurfaceVariant),
                        ),
                      ],
                    ),
                  ),
                  Text(
                    '${isIncome ? '+' : '-'}${AppFormatters.formatCurrency(tx.amount)}',
                    style: TextStyle(
                      color: amountColor,
                      fontWeight: FontWeight.bold,
                      fontSize: 15,
                      fontFeatures: AppTheme.tabularFigures,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _swipeBg(Color color, IconData icon, Alignment align) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 5),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(18),
      ),
      alignment: align,
      padding: const EdgeInsets.symmetric(horizontal: 22),
      child: Icon(icon, color: Colors.white),
    );
  }

  String _fmtDate(DateTime date) {
    final now = DateTime.now();
    if (date.year == now.year &&
        date.month == now.month &&
        date.day == now.day) {
      return 'Bugün';
    }
    return '${date.day}.${date.month.toString().padLeft(2, '0')}.${date.year}';
  }

  // ── Veri işlemleri (Ayarlar sekmesinden çağrılır) ──────────────────────────

  Future<void> _exportCsv() async {
    if (_transactions.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Dışa aktarılacak işlem yok')),
      );
      return;
    }
    try {
      HapticFeedback.mediumImpact();
      await ExportService.shareCsv(_transactions);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Dışa aktarma başarısız: $e')),
      );
    }
  }

  Future<void> _backupJson() async {
    try {
      HapticFeedback.mediumImpact();
      final settings = await _db.getAllSettings();
      final recurring = await _db.getRecurringRules();
      // Yedek kuralları da taşır: yalnızca kuralı olan kullanıcı da yedek alabilmeli.
      if (_transactions.isEmpty && recurring.isEmpty) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Yedeklenecek veri yok')),
        );
        return;
      }
      await BackupService.shareBackup(
        _transactions,
        settings: settings,
        recurring: recurring,
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Yedekleme başarısız: $e')),
      );
    }
  }

  /// Yedeği paylaşım yerine doğrudan cihazda seçilen bir konuma kaydeder.
  Future<void> _saveBackupLocal() async {
    try {
      HapticFeedback.mediumImpact();
      final settings = await _db.getAllSettings();
      final recurring = await _db.getRecurringRules();
      if (_transactions.isEmpty && recurring.isEmpty) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Yedeklenecek veri yok')),
        );
        return;
      }
      final json = BackupService.buildJson(
        _transactions,
        settings: settings,
        recurring: recurring,
      );
      final bytes = Uint8List.fromList(utf8.encode(json));
      final fileName =
          'budgetflow_yedek_${DateTime.now().toIso8601String().split('T').first}.json';
      final path = await FilePicker.platform.saveFile(
        dialogTitle: 'Yedeği cihaza kaydet',
        fileName: fileName,
        type: FileType.custom,
        allowedExtensions: ['json'],
        bytes: bytes,
      );
      if (path == null || !mounted) return; // iptal
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Yedek cihaza kaydedildi'),
          behavior: SnackBarBehavior.floating,
        ),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Kaydetme başarısız: $e')),
      );
    }
  }

  Future<void> _restoreBackup() async {
    try {
      // Tür filtresi (custom + json) bazı Android dosya sağlayıcılarında
      // seçimi engelliyor veya byte döndürmüyor; herhangi bir dosyaya izin
      // verip içeriği doğruluyoruz.
      final result = await FilePicker.platform.pickFiles(withData: true);
      if (result == null || result.files.isEmpty) return; // iptal
      final picked = result.files.first;
      // Önce bellekteki byte'lar; yoksa dosya yolundan oku (Android yedek yolu).
      List<int>? raw = picked.bytes;
      raw ??= await readFileBytes(picked.path);
      if (raw == null) {
        throw const FormatException(
            'Dosya okunamadı. Yedeği cihaza indirip tekrar deneyin.');
      }
      final data = BackupService.parseJson(utf8.decode(raw, allowMalformed: true));
      if (!mounted) return;

      final rules = data.recurring;
      final ozet = rules == null || rules.isEmpty
          ? '${data.transactions.length} işlem'
          : '${data.transactions.length} işlem ve ${rules.length} tekrarlama '
              'kuralı';
      final ok = await checkMessage(
        context,
        'Yedekten Geri Yükle',
        '$ozet içe aktarılacak ve mevcut veriler bununla değiştirilecek. '
            'Devam edilsin mi?',
      );
      if (!ok) return;

      await _db.replaceAllTransactions(data.transactions);
      // Eski (schema 1) yedeklerde bu bölüm yok; o durumda mevcut kurallar korunur.
      if (rules != null) await _db.replaceAllRecurringRules(rules);
      // Bütçe ayarlarını da geri yükle (varsa).
      for (final key in const ['budgetLimit', 'noteBudgets']) {
        final v = data.settings[key];
        if (v != null) await _db.setSetting(key, v);
      }
      await _loadTransactions();
      await _loadBudget();
      if (!mounted) return;
      HapticFeedback.mediumImpact();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('${data.transactions.length} işlem geri yüklendi'),
          behavior: SnackBarBehavior.floating,
        ),
      );
    } catch (e) {
      if (!mounted) return;
      final msg = e is FormatException ? e.message : e.toString();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Geri yükleme başarısız: $msg')),
      );
    }
  }
}
