import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'package:paypulse/core/errors/exceptions.dart';

abstract class AppDatabase {
  Future<Database> get database;
  Future<void> close();
  Future<void> clearAllData();
}

class AppDatabaseImpl implements AppDatabase {
  static const String _databaseName = 'paypulse.db';
  static const int _databaseVersion = 1;
  
  static AppDatabaseImpl? _instance;
  Database? _database;
  
  AppDatabaseImpl._private();
  
  factory AppDatabaseImpl() {
    _instance ??= AppDatabaseImpl._private();
    return _instance!;
  }
  
  @override
  Future<Database> get database async {
    if (_database != null) return _database!;
    
    _database = await _initDatabase();
    return _database!;
  }
  
  Future<Database> _initDatabase() async {
    try {
      final databasesPath = await getDatabasesPath();
      final path = join(databasesPath, _databaseName);
      
      return await openDatabase(
        path,
        version: _databaseVersion,
        onCreate: _onCreate,
        onUpgrade: _onUpgrade,
        onConfigure: _onConfigure,
      );
    } catch (e) {
      throw DatabaseException(
        message: 'Failed to initialize database: $e',
        data: {'error': e.toString()},
      );
    }
  }
  
  Future<void> _onCreate(Database db, int version) async {
    try {
      // Create all tables
      await _createUserTable(db);
      await _createWalletTable(db);
      await _createTransactionTable(db);
      await _createCategoryTable(db);
      await _createInvestmentTable(db);
      await _createGoalTable(db);
      await _createBudgetTable(db);
      
      // Create indexes
      await _createIndexes(db);
      
      // Insert default data
      await _insertDefaultData(db);
    } catch (e) {
      throw DatabaseException(
        message: 'Failed to create database: $e',
        data: {'error': e.toString()},
      );
    }
  }
  
  Future<void> _onUpgrade(Database db, int oldVersion, int newVersion) async {
    try {
      // Handle database migrations
      for (int version = oldVersion + 1; version <= newVersion; version++) {
        await _runMigration(db, version);
      }
    } catch (e) {
      throw DatabaseException(
        message: 'Failed to upgrade database: $e',
        data: {'oldVersion': oldVersion, 'newVersion': newVersion, 'error': e.toString()},
      );
    }
  }
  
  Future<void> _onConfigure(Database db) async {
    await db.execute('PRAGMA foreign_keys = ON');
  }
  
  // Table creation methods
  
  Future<void> _createUserTable(Database db) async {
    await db.execute('''
      CREATE TABLE users (
        id TEXT PRIMARY KEY,
        email TEXT NOT NULL UNIQUE,
        first_name TEXT NOT NULL,
        last_name TEXT NOT NULL,
        phone_number TEXT,
        profile_image_url TEXT,
        is_email_verified INTEGER DEFAULT 0,
        is_phone_verified INTEGER DEFAULT 0,
        preferences TEXT,
        security_settings TEXT,
        created_at INTEGER NOT NULL,
        updated_at INTEGER NOT NULL
      )
    ''');
  }
  
  Future<void> _createWalletTable(Database db) async {
    await db.execute('''
      CREATE TABLE wallets (
        id TEXT PRIMARY KEY,
        user_id TEXT NOT NULL,
        name TEXT NOT NULL,
        balance REAL NOT NULL DEFAULT 0,
        currency TEXT NOT NULL,
        is_default INTEGER DEFAULT 0,
        metadata TEXT,
        created_at INTEGER NOT NULL,
        updated_at INTEGER NOT NULL,
        FOREIGN KEY (user_id) REFERENCES users (id) ON DELETE CASCADE
      )
    ''');
  }
  
  Future<void> _createTransactionTable(Database db) async {
    await db.execute('''
      CREATE TABLE transactions (
        id TEXT PRIMARY KEY,
        wallet_id TEXT NOT NULL,
        user_id TEXT NOT NULL,
        amount REAL NOT NULL,
        currency TEXT NOT NULL,
        type TEXT NOT NULL,
        category_id TEXT,
        description TEXT,
        date INTEGER NOT NULL,
        location TEXT,
        attachments TEXT,
        metadata TEXT,
        is_recurring INTEGER DEFAULT 0,
        recurrence_pattern TEXT,
        created_at INTEGER NOT NULL,
        updated_at INTEGER NOT NULL,
        FOREIGN KEY (wallet_id) REFERENCES wallets (id) ON DELETE CASCADE,
        FOREIGN KEY (user_id) REFERENCES users (id) ON DELETE CASCADE,
        FOREIGN KEY (category_id) REFERENCES categories (id) ON DELETE SET NULL
      )
    ''');
  }
  
  Future<void> _createCategoryTable(Database db) async {
    await db.execute('''
      CREATE TABLE categories (
        id TEXT PRIMARY KEY,
        name TEXT NOT NULL,
        type TEXT NOT NULL,
        icon TEXT,
        color TEXT,
        parent_id TEXT,
        is_system INTEGER DEFAULT 0,
        metadata TEXT,
        created_at INTEGER NOT NULL,
        FOREIGN KEY (parent_id) REFERENCES categories (id) ON DELETE CASCADE
      )
    ''');
  }
  
  Future<void> _createInvestmentTable(Database db) async {
    await db.execute('''
      CREATE TABLE investments (
        id TEXT PRIMARY KEY,
        user_id TEXT NOT NULL,
        name TEXT NOT NULL,
        type TEXT NOT NULL,
        amount REAL NOT NULL,
        currency TEXT NOT NULL,
        purchase_price REAL,
        current_price REAL,
        quantity REAL NOT NULL,
        purchase_date INTEGER NOT NULL,
        maturity_date INTEGER,
        risk_level TEXT,
        returns REAL DEFAULT 0,
        metadata TEXT,
        created_at INTEGER NOT NULL,
        updated_at INTEGER NOT NULL,
        FOREIGN KEY (user_id) REFERENCES users (id) ON DELETE CASCADE
      )
    ''');
  }
  
  Future<void> _createGoalTable(Database db) async {
    await db.execute('''
      CREATE TABLE goals (
        id TEXT PRIMARY KEY,
        user_id TEXT NOT NULL,
        name TEXT NOT NULL,
        target_amount REAL NOT NULL,
        current_amount REAL NOT NULL DEFAULT 0,
        currency TEXT NOT NULL,
        target_date INTEGER NOT NULL,
        icon TEXT,
        color TEXT,
        is_completed INTEGER DEFAULT 0,
        metadata TEXT,
        created_at INTEGER NOT NULL,
        updated_at INTEGER NOT NULL,
        FOREIGN KEY (user_id) REFERENCES users (id) ON DELETE CASCADE
      )
    ''');
  }
  
  Future<void> _createBudgetTable(Database db) async {
    await db.execute('''
      CREATE TABLE budgets (
        id TEXT PRIMARY KEY,
        user_id TEXT NOT NULL,
        category_id TEXT,
        amount REAL NOT NULL,
        currency TEXT NOT NULL,
        period TEXT NOT NULL,
        start_date INTEGER NOT NULL,
        end_date INTEGER NOT NULL,
        spent REAL DEFAULT 0,
        metadata TEXT,
        created_at INTEGER NOT NULL,
        updated_at INTEGER NOT NULL,
        FOREIGN KEY (user_id) REFERENCES users (id) ON DELETE CASCADE,
        FOREIGN KEY (category_id) REFERENCES categories (id) ON DELETE CASCADE
      )
    ''');
  }
  
  // Index creation
  
  Future<void> _createIndexes(Database db) async {
    // User indexes
    await db.execute('CREATE INDEX idx_users_email ON users(email)');
    
    // Wallet indexes
    await db.execute('CREATE INDEX idx_wallets_user_id ON wallets(user_id)');
    await db.execute('CREATE INDEX idx_wallets_is_default ON wallets(is_default)');
    
    // Transaction indexes
    await db.execute('CREATE INDEX idx_transactions_user_id ON transactions(user_id)');
    await db.execute('CREATE INDEX idx_transactions_wallet_id ON transactions(wallet_id)');
    await db.execute('CREATE INDEX idx_transactions_date ON transactions(date)');
    await db.execute('CREATE INDEX idx_transactions_category_id ON transactions(category_id)');
    await db.execute('CREATE INDEX idx_transactions_type ON transactions(type)');
    
    // Investment indexes
    await db.execute('CREATE INDEX idx_investments_user_id ON investments(user_id)');
    await db.execute('CREATE INDEX idx_investments_type ON investments(type)');
    
    // Goal indexes
    await db.execute('CREATE INDEX idx_goals_user_id ON goals(user_id)');
    await db.execute('CREATE INDEX idx_goals_is_completed ON goals(is_completed)');
    
    // Budget indexes
    await db.execute('CREATE INDEX idx_budgets_user_id ON budgets(user_id)');
    await db.execute('CREATE INDEX idx_budgets_period ON budgets(period)');
  }
  
  // Default data insertion
  
  Future<void> _insertDefaultData(Database db) async {
    // Insert default categories
    await _insertDefaultCategories(db);
  }
  
  Future<void> _insertDefaultCategories(Database db) async {
    const defaultCategories = [
      {
        'id': 'cat_income_salary',
        'name': 'Salary',
        'type': 'income',
        'icon': '💰',
        'color': '#4CAF50',
        'is_system': 1,
      },
      {
        'id': 'cat_income_freelance',
        'name': 'Freelance',
        'type': 'income',
        'icon': '💼',
        'color': '#2196F3',
        'is_system': 1,
      },
      {
        'id': 'cat_expense_food',
        'name': 'Food & Dining',
        'type': 'expense',
        'icon': '🍔',
        'color': '#FF9800',
        'is_system': 1,
      },
      {
        'id': 'cat_expense_transport',
        'name': 'Transportation',
        'type': 'expense',
        'icon': '🚗',
        'color': '#3F51B5',
        'is_system': 1,
      },
      {
        'id': 'cat_expense_entertainment',
        'name': 'Entertainment',
        'type': 'expense',
        'icon': '🎬',
        'color': '#9C27B0',
        'is_system': 1,
      },
    ];
    
    for (final category in defaultCategories) {
      await db.insert(
        'categories',
        {
          ...category,
          'created_at': DateTime.now().millisecondsSinceEpoch,
          'metadata': '{}',
        },
        conflictAlgorithm: ConflictAlgorithm.ignore,
      );
    }
  }
  
  // Migration methods
  
  Future<void> _runMigration(Database db, int version) async {
    switch (version) {
      case 2:
        await _migrationV2(db);
        break;
      case 3:
        await _migrationV3(db);
        break;
      // Add more migrations as needed
    }
  }
  
  Future<void> _migrationV2(Database db) async {
    // Example migration for version 2
    await db.execute('''
      ALTER TABLE transactions ADD COLUMN is_verified INTEGER DEFAULT 0
    ''');
  }
  
  Future<void> _migrationV3(Database db) async {
    // Example migration for version 3
    await db.execute('''
      ALTER TABLE users ADD COLUMN two_factor_enabled INTEGER DEFAULT 0
    ''');
  }
  
  @override
  Future<void> close() async {
    try {
      await _database?.close();
      _database = null;
    } catch (e) {
      throw DatabaseException(
        message: 'Failed to close database: $e',
        data: {'error': e.toString()},
      );
    }
  }
  
  @override
  Future<void> clearAllData() async {
    try {
      final db = await database;
      
      // Delete all data from all tables (in correct order due to foreign keys)
      await db.delete('transactions');
      await db.delete('budgets');
      await db.delete('goals');
      await db.delete('investments');
      await db.delete('wallets');
      await db.delete('categories');
      await db.delete('users');
      
      // Re-insert default categories
      await _insertDefaultCategories(db);
    } catch (e) {
      throw DatabaseException(
        message: 'Failed to clear all data: $e',
        data: {'error': e.toString()},
      );
    }
  }
  
  // Utility methods
  
  Future<int> getRowCount(String tableName) async {
    try {
      final db = await database;
      final result = await db.rawQuery('SELECT COUNT(*) as count FROM $tableName');
      return Sqflite.firstIntValue(result) ?? 0;
    } catch (e) {
      throw DatabaseException(
        message: 'Failed to get row count: $e',
        data: {'table': tableName, 'error': e.toString()},
      );
    }
  }
  
  Future<Map<String, int>> getAllTableCounts() async {
    try {
      final tables = ['users', 'wallets', 'transactions', 'categories', 'investments', 'goals', 'budgets'];
      final counts = <String, int>{};
      
      for (final table in tables) {
        counts[table] = await getRowCount(table);
      }
      
      return counts;
    } catch (e) {
      throw DatabaseException(
        message: 'Failed to get all table counts: $e',
        data: {'error': e.toString()},
      );
    }
  }
  
  Future<void> vacuum() async {
    try {
      final db = await database;
      await db.execute('VACUUM');
    } catch (e) {
      throw DatabaseException(
        message: 'Failed to vacuum database: $e',
        data: {'error': e.toString()},
      );
    }
  }
  
  Future<void> backup(String backupPath) async {
    try {
      final db = await database;
      final databasesPath = await getDatabasesPath();
      final originalPath = join(databasesPath, _databaseName);
      
      // Copy database file
      // Note: This is a simplified version
      // In production, you might want to use proper backup strategy
    } catch (e) {
      throw DatabaseException(
        message: 'Failed to backup database: $e',
        data: {'backupPath': backupPath, 'error': e.toString()},
      );
    }
  }
}

class DatabaseException extends AppException {
  DatabaseException({
    required super.message,
    super.statusCode,
    super.data,
  });
}