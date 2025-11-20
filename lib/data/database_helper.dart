import 'dart:async';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'package:flutter/services.dart';
import 'package:csv/csv.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/word.dart';
import '../models/history.dart';
import '../models/bookmark.dart';

class DatabaseHelper {
  static final DatabaseHelper instance = DatabaseHelper._init();
  static Database? _database;

  DatabaseHelper._init();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB();
    return _database!;
  }

  Future<Database> _initDB() async {
    final documentsDirectory = await getApplicationDocumentsDirectory();
    final path = join(documentsDirectory.path, 'tulish.db');

    return await openDatabase(
      path,
      version: 1,
      onCreate: _createDB,
    );
  }

  Future<void> _createDB(Database db, int version) async {
    // Create words table
    await db.execute('''
      CREATE TABLE IF NOT EXISTS words (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        word TEXT NOT NULL UNIQUE,
        part_of_speech TEXT,
        definition TEXT NOT NULL,
        example TEXT,
        synonyms TEXT,
        antonyms TEXT,
        etymology TEXT
      )
    ''');

    // Create history table
    await db.execute('''
      CREATE TABLE IF NOT EXISTS history (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        word_id INTEGER,
        word_text TEXT NOT NULL,
        searched_at TEXT DEFAULT CURRENT_TIMESTAMP,
        FOREIGN KEY (word_id) REFERENCES words(id) ON DELETE SET NULL
      )
    ''');

    // Create bookmarks table
    await db.execute('''
      CREATE TABLE IF NOT EXISTS bookmarks (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        word_id INTEGER,
        word_text TEXT NOT NULL,
        definition TEXT,
        part_of_speech TEXT,
        added_at TEXT DEFAULT CURRENT_TIMESTAMP,
        FOREIGN KEY (word_id) REFERENCES words(id) ON DELETE CASCADE,
        UNIQUE(word_id)
      )
    ''');

    // Create indexes
    await db.execute('CREATE INDEX IF NOT EXISTS idx_word ON words(word)');
    await db.execute('CREATE INDEX IF NOT EXISTS idx_history_date ON history(searched_at DESC)');
    await db.execute('CREATE INDEX IF NOT EXISTS idx_bookmark_date ON bookmarks(added_at DESC)');

    // Load data from CSV
    await _loadDataFromCSV(db);
  }

  Future<void> _loadDataFromCSV(Database db) async {
    try {
      // Check if data already loaded using SharedPreferences
      final prefs = await SharedPreferences.getInstance();
      final isDataLoaded = prefs.getBool('words_loaded') ?? false;

      if (isDataLoaded) {
        print('Database already populated, skipping CSV import');
        return;
      }

      // Read CSV file from assets
      final csvData = await rootBundle.loadString('assets/database/words.csv');
      
      // Parse CSV
      List<List<dynamic>> rows = const CsvToListConverter().convert(csvData);

      // Skip header row
      for (int i = 1; i < rows.length; i++) {
        final row = rows[i];
        
        if (row.length < 7) continue; // Skip incomplete rows

        final wordMap = {
          'word': (row[0] ?? '').toString().trim(),
          'part_of_speech': (row[1] ?? '').toString().trim(),
          'definition': (row[2] ?? '').toString().trim(),
          'example': (row[3] ?? '').toString().trim(),
          'synonyms': (row[4] ?? '').toString().trim(),
          'antonyms': (row[5] ?? '').toString().trim(),
          'etymology': (row[6] ?? '').toString().trim(),
        };

        // Skip if word is empty
        if (wordMap['word']!.isEmpty) continue;

        try {
          await db.insert(
            'words',
            wordMap,
            conflictAlgorithm: ConflictAlgorithm.ignore,
          );
        } catch (e) {
          print('Error inserting word: ${wordMap['word']} - $e');
        }
      }

      // Mark data as loaded
      await prefs.setBool('words_loaded', true);
      print('CSV data successfully imported to database');
    } catch (e) {
      print('Error loading CSV data: $e');
      rethrow;
    }
  }

  // Word operations
  Future<List<Word>> searchWords(String query) async {
    final db = await database;
    final results = await db.query(
      'words',
      where: 'word LIKE ?',
      whereArgs: ['%$query%'],
      orderBy: 'word ASC',
      limit: 50,
    );
    return results.map((map) => Word.fromMap(map)).toList();
  }

  Future<Word?> getWordById(int id) async {
    final db = await database;
    final results = await db.query(
      'words',
      where: 'id = ?',
      whereArgs: [id],
      limit: 1,
    );
    if (results.isEmpty) return null;
    return Word.fromMap(results.first);
  }

  Future<Word?> getWordByText(String word) async {
    final db = await database;
    final results = await db.query(
      'words',
      where: 'word = ?',
      whereArgs: [word],
      limit: 1,
    );
    if (results.isEmpty) return null;
    return Word.fromMap(results.first);
  }

  Future<List<Word>> getRandomWords(int limit) async {
    final db = await database;
    final results = await db.rawQuery(
      'SELECT * FROM words ORDER BY RANDOM() LIMIT ?',
      [limit],
    );
    return results.map((map) => Word.fromMap(map)).toList();
  }

  Future<int> getTotalWordCount() async {
    final db = await database;
    final result = await db.rawQuery('SELECT COUNT(*) as count FROM words');
    return Sqflite.firstIntValue(result) ?? 0;
  }

  // History operations
  Future<int> addHistory(History history) async {
    final db = await database;
    return await db.insert('history', history.toMap());
  }

  Future<List<History>> getHistory({int limit = 100}) async {
    final db = await database;
    final results = await db.query(
      'history',
      orderBy: 'searched_at DESC',
      limit: limit,
    );
    return results.map((map) => History.fromMap(map)).toList();
  }

  Future<void> clearHistory() async {
    final db = await database;
    await db.delete('history');
  }

  // Bookmark operations
  Future<int> addBookmark(Bookmark bookmark) async {
    final db = await database;
    return await db.insert(
      'bookmarks',
      bookmark.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<void> removeBookmark(int wordId) async {
    final db = await database;
    await db.delete(
      'bookmarks',
      where: 'word_id = ?',
      whereArgs: [wordId],
    );
  }

  Future<bool> isBookmarked(int wordId) async {
    final db = await database;
    final results = await db.query(
      'bookmarks',
      where: 'word_id = ?',
      whereArgs: [wordId],
      limit: 1,
    );
    return results.isNotEmpty;
  }

  Future<List<Bookmark>> getBookmarks() async {
    final db = await database;
    final results = await db.query(
      'bookmarks',
      orderBy: 'added_at DESC',
    );
    return results.map((map) => Bookmark.fromMap(map)).toList();
  }

  Future<List<Bookmark>> searchBookmarks(String query) async {
    final db = await database;
    final results = await db.query(
      'bookmarks',
      where: 'word_text LIKE ?',
      whereArgs: ['%$query%'],
      orderBy: 'word_text ASC',
    );
    return results.map((map) => Bookmark.fromMap(map)).toList();
  }

  Future<void> close() async {
    final db = await database;
    await db.close();
  }
}