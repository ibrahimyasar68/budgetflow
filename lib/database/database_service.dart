import 'package:path/path.dart';
import 'package:personal_finance_tracker/models/recurring_rule.dart';
import 'package:personal_finance_tracker/models/transaction.dart';
import 'package:sqflite/sqflite.dart' hide Transaction;

class DatabaseService {
  DatabaseService._internal();
  static final DatabaseService _instance = DatabaseService._internal();
  factory DatabaseService() => _instance;

  Database? _db;

  Future<Database> get db async {
    if (_db != null) return _db!;
    _db = await _initializeDb();
    return _db!;
  }

  Future<Database> _initializeDb() async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, 'financeDb.db');
    return await openDatabase(
      path,
      version: 10,
      onCreate: _createDb,
      onUpgrade: _upgradeDb,
    );
  }

  Future<void> _createDb(Database db, int version) async {
    await db.execute('''
      CREATE TABLE transactions (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        amount INTEGER NOT NULL,
        type INTEGER NOT NULL,
        date INTEGER NOT NULL,
        note TEXT
      )
    ''');
    await _ensureSettings(db);
    await _ensureRecurring(db);
  }

  Future<void> _ensureSettings(Database db) async {
    await db.execute('''
      CREATE TABLE IF NOT EXISTS settings (
        key TEXT PRIMARY KEY,
        value TEXT
      )
    ''');
  }

  Future<void> _ensureRecurring(Database db) async {
    await db.execute('''
      CREATE TABLE IF NOT EXISTS recurring (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        amount INTEGER NOT NULL,
        type INTEGER NOT NULL,
        note TEXT,
        dayOfMonth INTEGER NOT NULL,
        startYear INTEGER NOT NULL,
        startMonth INTEGER NOT NULL,
        lastYear INTEGER NOT NULL,
        lastMonth INTEGER NOT NULL,
        endYear INTEGER,
        endMonth INTEGER
      )
    ''');
  }

  /// v9'da oluşmuş `recurring` tablosuna bitiş ayı sütunlarını ekler
  /// (yoksa). ALTER var olan sütunda hata verdiği için önce kontrol edilir.
  Future<void> _ensureRecurringEndColumns(Database db) async {
    final cols = await db.rawQuery('PRAGMA table_info(recurring)');
    final names = cols.map((c) => c['name'] as String).toSet();
    if (!names.contains('endYear')) {
      await db.execute('ALTER TABLE recurring ADD COLUMN endYear INTEGER');
    }
    if (!names.contains('endMonth')) {
      await db.execute('ALTER TABLE recurring ADD COLUMN endMonth INTEGER');
    }
  }

  Future<void> _upgradeDb(Database db, int oldVersion, int newVersion) async {
    // Eski sürümlerde oluşmuş olabilecek categories tablosunu temizle.
    await db.execute('DROP TABLE IF EXISTS categories');

    // v5: tutarları TL (REAL) → kuruş (INTEGER) biçimine çevir.
    if (oldVersion < 5) {
      await db.execute(
          'UPDATE transactions SET amount = CAST(ROUND(amount * 100) AS INTEGER)');
    }

    // v6: category sütununu kaldır. (Eski SQLite'larda DROP COLUMN olmayabilir,
    // bu yüzden tablo güvenli biçimde yeniden oluşturulur.)
    if (oldVersion < 6) {
      await db.execute('''
        CREATE TABLE transactions_new (
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          amount INTEGER NOT NULL,
          type INTEGER NOT NULL,
          date INTEGER NOT NULL,
          note TEXT
        )
      ''');
      await db.execute('''
        INSERT INTO transactions_new (id, amount, type, date, note)
        SELECT id, amount, type, date, note FROM transactions
      ''');
      await db.execute('DROP TABLE transactions');
      await db.execute('ALTER TABLE transactions_new RENAME TO transactions');
    }

    // v7: kategori sütunu eklendi.
    if (oldVersion < 7) {
      await db.execute('ALTER TABLE transactions ADD COLUMN category TEXT');
    }

    // v8: kategori özelliği kaldırıldı. Tablo category sütunu olmadan yeniden
    // oluşturulur ve notu boş olan kayıtlara 'Diğer' atanır (not artık
    // sınıflandırma başlığı olarak kullanılıyor).
    if (oldVersion < 8) {
      await db.execute('''
        CREATE TABLE transactions_v8 (
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          amount INTEGER NOT NULL,
          type INTEGER NOT NULL,
          date INTEGER NOT NULL,
          note TEXT
        )
      ''');
      await db.execute('''
        INSERT INTO transactions_v8 (id, amount, type, date, note)
        SELECT id, amount, type, date,
               CASE WHEN note IS NULL OR TRIM(note) = '' THEN 'Diğer'
                    ELSE note END
        FROM transactions
      ''');
      await db.execute('DROP TABLE transactions');
      await db.execute('ALTER TABLE transactions_v8 RENAME TO transactions');
    }

    // v9: tekrarlayan işlem kuralları tablosu eklendi.
    if (oldVersion < 9) {
      await _ensureRecurring(db);
    }

    // v10: tekrarlama kurallarına bitiş ayı (aralık) eklendi.
    if (oldVersion < 10) {
      await _ensureRecurring(db);
      await _ensureRecurringEndColumns(db);
    }

    await _ensureSettings(db);
    await _ensureRecurring(db);
  }

  Future<int> insertTransaction(Transaction model) async {
    final database = await db;
    final map = model.toMap()..remove('id');
    return await database.insert('transactions', map);
  }

  Future<List<Transaction>> getAllTransactions() async {
    final database = await db;
    final result = await database.query('transactions', orderBy: 'date DESC');
    return result.map((e) => Transaction.fromMap(e)).toList();
  }

  /// Geçmişte kullanılmış benzersiz notlar (en sık kullanılan önce).
  /// İşlem eklerken otomatik tamamlama için kullanılır.
  ///
  /// Büyük/küçük harf ve baştaki/sondaki boşluklar yok sayılarak gruplanır —
  /// "Market" ve "market" tek öneri olur (gider dağılımıyla aynı davranış).
  /// Her grup için en sık kullanılan yazım gösterilir.
  Future<List<String>> getDistinctNotes() async {
    final database = await db;
    final rows = await database.rawQuery('''
      SELECT note
      FROM transactions
      WHERE note IS NOT NULL AND TRIM(note) <> ''
    ''');

    final counts = <String, int>{}; // normalize anahtar → toplam kullanım
    final variants = <String, Map<String, int>>{}; // anahtar → yazım → sayı
    for (final r in rows) {
      final raw = (r['note'] as String).trim();
      if (raw.isEmpty) continue;
      final key = raw.toLowerCase();
      counts[key] = (counts[key] ?? 0) + 1;
      final v = variants[key] ??= {};
      v[raw] = (v[raw] ?? 0) + 1;
    }

    final keys = counts.keys.toList()
      ..sort((a, b) {
        final byCount = counts[b]!.compareTo(counts[a]!);
        return byCount != 0 ? byCount : a.compareTo(b);
      });

    return keys.map((k) {
      // Grup içinde en sık yazılmış biçim.
      return variants[k]!
          .entries
          .reduce((a, b) => b.value > a.value ? b : a)
          .key;
    }).toList();
  }

  Future<int> deleteOneItem(int id) async {
    final database = await db;
    return await database
        .delete('transactions', where: 'id = ?', whereArgs: [id]);
  }

  Future<int> updateTransaction(Transaction model) async {
    final database = await db;
    return await database.update(
      'transactions',
      model.toMap(),
      where: 'id = ?',
      whereArgs: [model.id],
    );
  }

  /// Tüm işlemleri verilen listeyle değiştirir (yedekten geri yükleme).
  /// Tek bir SQLite işleminde çalışır; yarıda kalırsa hiçbiri uygulanmaz.
  Future<void> replaceAllTransactions(List<Transaction> items) async {
    final database = await db;
    await database.transaction((txn) async {
      await txn.delete('transactions');
      for (final t in items) {
        final map = t.toMap()..remove('id');
        await txn.insert('transactions', map);
      }
    });
  }

  // ── Tekrarlayan işlem kuralları ─────────────────────────────────────────────

  Future<List<RecurringRule>> getRecurringRules() async {
    final database = await db;
    await _ensureRecurring(database);
    final rows = await database.query('recurring', orderBy: 'id DESC');
    return rows.map((e) => RecurringRule.fromMap(e)).toList();
  }

  Future<int> insertRecurringRule(RecurringRule rule) async {
    final database = await db;
    await _ensureRecurring(database);
    final map = rule.toMap()..remove('id');
    return await database.insert('recurring', map);
  }

  Future<void> updateRecurringLast(int id, int year, int month) async {
    final database = await db;
    await database.update(
      'recurring',
      {'lastYear': year, 'lastMonth': month},
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future<int> deleteRecurringRule(int id) async {
    final database = await db;
    return await database.delete('recurring', where: 'id = ?', whereArgs: [id]);
  }

  /// Tüm tekrarlama kurallarını verilenlerle değiştirir (yedekten geri yükleme).
  /// Tek işlem içinde yapılır; yarım kalmış bir geri yükleme oluşmaz.
  Future<void> replaceAllRecurringRules(List<RecurringRule> rules) async {
    final database = await db;
    await _ensureRecurring(database);
    await database.transaction((txn) async {
      await txn.delete('recurring');
      for (final r in rules) {
        final map = r.toMap()..remove('id');
        await txn.insert('recurring', map);
      }
    });
  }

  // ── Ayarlar (key/value) ────────────────────────────────────────────────────

  Future<String?> getSetting(String key) async {
    final database = await db;
    await _ensureSettings(database);
    final result = await database.query(
      'settings',
      where: 'key = ?',
      whereArgs: [key],
      limit: 1,
    );
    if (result.isEmpty) return null;
    return result.first['value'] as String?;
  }

  Future<void> setSetting(String key, String value) async {
    final database = await db;
    await _ensureSettings(database);
    await database.insert(
      'settings',
      {'key': key, 'value': value},
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<void> deleteSetting(String key) async {
    final database = await db;
    await _ensureSettings(database);
    await database.delete('settings', where: 'key = ?', whereArgs: [key]);
  }

  /// Tüm ayarları tek seferde okur (yedeğe dahil etmek için).
  Future<Map<String, String>> getAllSettings() async {
    final database = await db;
    await _ensureSettings(database);
    final rows = await database.query('settings');
    return {
      for (final r in rows)
        if (r['value'] != null) r['key'] as String: r['value'] as String,
    };
  }
}
