// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'database.dart';

// **************************************************************************
// FloorGenerator
// **************************************************************************

// ignore: avoid_classes_with_only_static_members
class $FloorAppDatabase {
  /// Creates a database builder for a persistent database.
  /// Once a database is built, you should keep a reference to it and re-use it.
  static _$AppDatabaseBuilder databaseBuilder(String name) =>
      _$AppDatabaseBuilder(name);

  /// Creates a database builder for an in memory database.
  /// Information stored in an in memory database disappears when the process is killed.
  /// Once a database is built, you should keep a reference to it and re-use it.
  static _$AppDatabaseBuilder inMemoryDatabaseBuilder() =>
      _$AppDatabaseBuilder(null);
}

class _$AppDatabaseBuilder {
  _$AppDatabaseBuilder(this.name);

  final String? name;

  final List<Migration> _migrations = [];

  Callback? _callback;

  /// Adds migrations to the builder.
  _$AppDatabaseBuilder addMigrations(List<Migration> migrations) {
    _migrations.addAll(migrations);
    return this;
  }

  /// Adds a database [Callback] to the builder.
  _$AppDatabaseBuilder addCallback(Callback callback) {
    _callback = callback;
    return this;
  }

  /// Creates the database and initializes it.
  Future<AppDatabase> build() async {
    final path = name != null
        ? await sqfliteDatabaseFactory.getDatabasePath(name!)
        : ':memory:';
    final database = _$AppDatabase();
    database.database = await database.open(
      path,
      _migrations,
      _callback,
    );
    return database;
  }
}

class _$AppDatabase extends AppDatabase {
  _$AppDatabase([StreamController<String>? listener]) {
    changeListener = listener ?? StreamController<String>.broadcast();
  }

  BookDAO? _bookDaoInstance;

  UserDAO? _userDaoInstance;

  Future<sqflite.Database> open(
    String path,
    List<Migration> migrations, [
    Callback? callback,
  ]) async {
    final databaseOptions = sqflite.OpenDatabaseOptions(
      version: 1,
      onConfigure: (database) async {
        await database.execute('PRAGMA foreign_keys = ON');
        await callback?.onConfigure?.call(database);
      },
      onOpen: (database) async {
        await callback?.onOpen?.call(database);
      },
      onUpgrade: (database, startVersion, endVersion) async {
        await MigrationAdapter.runMigrations(
            database, startVersion, endVersion, migrations);

        await callback?.onUpgrade?.call(database, startVersion, endVersion);
      },
      onCreate: (database, version) async {
        await database.execute(
            'CREATE TABLE IF NOT EXISTS `Book` (`id` INTEGER PRIMARY KEY AUTOINCREMENT, `title` TEXT NOT NULL, `authorName` TEXT NOT NULL, `bookDirPath` TEXT NOT NULL, `coverPath` TEXT NOT NULL, `description` TEXT NOT NULL, `dateAdded` TEXT NOT NULL, `sizeInKb` INTEGER NOT NULL)');
        await database.execute(
            'CREATE TABLE IF NOT EXISTS `User` (`username` TEXT NOT NULL, `password` TEXT NOT NULL, PRIMARY KEY (`username`))');

        await callback?.onCreate?.call(database, version);
      },
    );
    return sqfliteDatabaseFactory.openDatabase(path, options: databaseOptions);
  }

  @override
  BookDAO get bookDao {
    return _bookDaoInstance ??= _$BookDAO(database, changeListener);
  }

  @override
  UserDAO get userDao {
    return _userDaoInstance ??= _$UserDAO(database, changeListener);
  }
}

class _$BookDAO extends BookDAO {
  _$BookDAO(
    this.database,
    this.changeListener,
  )   : _queryAdapter = QueryAdapter(database),
        _bookInsertionAdapter = InsertionAdapter(
            database,
            'Book',
            (Book item) => <String, Object?>{
                  'id': item.id,
                  'title': item.title,
                  'authorName': item.authorName,
                  'bookDirPath': item.bookDirPath,
                  'coverPath': item.coverPath,
                  'description': item.description,
                  'dateAdded': item.dateAdded,
                  'sizeInKb': item.sizeInKb
                });

  final sqflite.DatabaseExecutor database;

  final StreamController<String> changeListener;

  final QueryAdapter _queryAdapter;

  final InsertionAdapter<Book> _bookInsertionAdapter;

  @override
  Future<List<Book>> getAllBooks() async {
    return _queryAdapter.queryList('SELECT * FROM Book',
        mapper: (Map<String, Object?> row) => Book(
            id: row['id'] as int?,
            title: row['title'] as String,
            authorName: row['authorName'] as String,
            bookDirPath: row['bookDirPath'] as String,
            coverPath: row['coverPath'] as String,
            description: row['description'] as String,
            dateAdded: row['dateAdded'] as String,
            sizeInKb: row['sizeInKb'] as int));
  }

  @override
  Future<Book?> findBookById(int id) async {
    return _queryAdapter.query('SELECT * FROM Book WHERE id = ?1',
        mapper: (Map<String, Object?> row) => Book(
            id: row['id'] as int?,
            title: row['title'] as String,
            authorName: row['authorName'] as String,
            bookDirPath: row['bookDirPath'] as String,
            coverPath: row['coverPath'] as String,
            description: row['description'] as String,
            dateAdded: row['dateAdded'] as String,
            sizeInKb: row['sizeInKb'] as int),
        arguments: [id]);
  }

  @override
  Future<List<Book>> findBooksByTitle(String searchText) async {
    return _queryAdapter.queryList('SELECT * FROM Book WERE title LIKE ?1',
        mapper: (Map<String, Object?> row) => Book(
            id: row['id'] as int?,
            title: row['title'] as String,
            authorName: row['authorName'] as String,
            bookDirPath: row['bookDirPath'] as String,
            coverPath: row['coverPath'] as String,
            description: row['description'] as String,
            dateAdded: row['dateAdded'] as String,
            sizeInKb: row['sizeInKb'] as int),
        arguments: [searchText]);
  }

  @override
  Future<void> deleteBookById(int id) async {
    await _queryAdapter
        .queryNoReturn('DELETE FROM Book WHERE id = ?1', arguments: [id]);
  }

  @override
  Future<void> insertBook(Book book) async {
    await _bookInsertionAdapter.insert(book, OnConflictStrategy.abort);
  }
}

class _$UserDAO extends UserDAO {
  _$UserDAO(
    this.database,
    this.changeListener,
  )   : _queryAdapter = QueryAdapter(database),
        _userInsertionAdapter = InsertionAdapter(
            database,
            'User',
            (User item) => <String, Object?>{
                  'username': item.username,
                  'password': item.password
                });

  final sqflite.DatabaseExecutor database;

  final StreamController<String> changeListener;

  final QueryAdapter _queryAdapter;

  final InsertionAdapter<User> _userInsertionAdapter;

  @override
  Future<User?> findUserByUsername(String username) async {
    return _queryAdapter.query('SELECT * FROM User WHERE username = ?1',
        mapper: (Map<String, Object?> row) => User(
            username: row['username'] as String,
            password: row['password'] as String),
        arguments: [username]);
  }

  @override
  Future<void> deleteUserByUsername(String username) async {
    await _queryAdapter.queryNoReturn('DELETE FROM User WHERE username = ?1',
        arguments: [username]);
  }

  @override
  Future<void> insertUser(User user) async {
    await _userInsertionAdapter.insert(user, OnConflictStrategy.abort);
  }
}
