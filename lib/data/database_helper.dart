import 'dart:async';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:sqflite_common_ffi_web/sqflite_ffi_web.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
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
    if (kIsWeb) {
      databaseFactory = databaseFactoryFfiWeb;
    } else {
      sqfliteFfiInit();
      databaseFactory = databaseFactoryFfi;
    }

    final db = await databaseFactory.openDatabase(
      'tulish.db',
      options: OpenDatabaseOptions(
        version: 1,
        onCreate: _createDB,
      ),
    );

    return db;
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

    // Populate with sample data
    await _populateSampleData(db);
  }

  Future<void> _populateSampleData(Database db) async {
    final sampleWords = [
      {
        'word': 'ephemeral',
        'part_of_speech': 'Adjective',
        'definition': 'Lasting for a very short time.',
        'example': 'Fashions are ephemeral.\nThe mayfly has an ephemeral existence.\nEphemeral pleasures often leave a longing.',
        'synonyms': 'Fleeting, Transient, Momentary',
        'antonyms': 'Permanent, Enduring, Eternal',
        'etymology': 'Ephemeral comes from the Greek word ephēmeros, literally meaning "lasting for a day." Its meaning has since expanded to describe anything that is fleeting or transient.'
      },
      {
        'word': 'serendipity',
        'part_of_speech': 'Noun',
        'definition': 'The occurrence of events by chance in a happy or beneficial way.',
        'example': 'A fortunate stroke of serendipity brought the two old friends together.',
        'synonyms': 'Luck, Fortune, Chance',
        'antonyms': 'Misfortune, Bad luck',
        'etymology': 'Coined by Horace Walpole in 1754, inspired by the Persian fairy tale "The Three Princes of Serendip."'
      },
      {
        'word': 'mellifluous',
        'part_of_speech': 'Adjective',
        'definition': 'Sweet or musical; pleasant to hear.',
        'example': 'The voice was mellifluous and smooth.\nHer mellifluous tones captivated the audience.',
        'synonyms': 'Sweet, Musical, Honeyed',
        'antonyms': 'Harsh, Grating, Discordant',
        'etymology': 'From Latin mellifluus, from mel (honey) + fluere (to flow).'
      },
      {
        'word': 'luminous',
        'part_of_speech': 'Adjective',
        'definition': 'Emitting or reflecting light; bright or shining, especially in the dark.',
        'example': 'The moon was luminous in the night sky.\nHer luminous smile lit up the room.',
        'synonyms': 'Bright, Shining, Glowing',
        'antonyms': 'Dark, Dim, Dull',
        'etymology': 'From Latin luminosus, from lumen (light).'
      },
      {
        'word': 'ubiquitous',
        'part_of_speech': 'Adjective',
        'definition': 'Present, appearing, or found everywhere.',
        'example': 'Smartphones have become ubiquitous in modern society.\nCoffee shops are ubiquitous in this city.',
        'synonyms': 'Omnipresent, Universal, Pervasive',
        'antonyms': 'Rare, Scarce, Limited',
        'etymology': 'From Latin ubique, meaning "everywhere."'
      },
      {
        'word': 'nefarious',
        'part_of_speech': 'Adjective',
        'definition': 'Wicked or criminal; extremely bad.',
        'example': 'He was a nefarious criminal mastermind.\nTheir nefarious plot was eventually discovered.',
        'synonyms': 'Wicked, Evil, Sinful',
        'antonyms': 'Good, Virtuous, Moral',
        'etymology': 'From Latin nefarius, from nefas (crime, sin), from ne- (not) + fas (divine law).'
      },
      {
        'word': 'quixotic',
        'part_of_speech': 'Adjective',
        'definition': 'Extremely idealistic; unrealistic and impractical.',
        'example': 'His quixotic attempt to change the world single-handedly failed.\nShe had quixotic dreams of becoming a famous artist.',
        'synonyms': 'Idealistic, Impractical, Unrealistic',
        'antonyms': 'Realistic, Practical, Pragmatic',
        'etymology': 'Named after Don Quixote, the hero of Cervantes novel who was known for his impractical idealism.'
      },
      {
        'word': 'halcyon',
        'part_of_speech': 'Adjective',
        'definition': 'Denoting a period of time in the past that was idyllically happy and peaceful.',
        'example': 'The halcyon days of youth.\nThose were halcyon times, before the war.',
        'synonyms': 'Peaceful, Happy, Golden',
        'antonyms': 'Turbulent, Troubled, Chaotic',
        'etymology': 'From Greek halkyon, a mythical bird said to calm the sea during winter solstice.'
      },
      {
        'word': 'verdant',
        'part_of_speech': 'Adjective',
        'definition': 'Green with grass or other rich vegetation.',
        'example': 'The verdant hills of Ireland.\nA verdant landscape stretched before them.',
        'synonyms': 'Green, Lush, Grassy',
        'antonyms': 'Barren, Arid, Dry',
        'etymology': 'From Old French verdoyant, from Latin viridis (green).'
      },
      {
        'word': 'cacophony',
        'part_of_speech': 'Noun',
        'definition': 'A harsh discordant mixture of sounds.',
        'example': 'A cacophony of car horns filled the street.\nThe cacophony of the construction site was deafening.',
        'synonyms': 'Discord, Dissonance, Noise',
        'antonyms': 'Harmony, Melody, Euphony',
        'etymology': 'From Greek kakophonia, from kakos (bad) + phone (sound).'
      },
      {
        'word': 'resilient',
        'part_of_speech': 'Adjective',
        'definition': 'Able to withstand or recover quickly from difficult conditions.',
        'example': 'Children are generally very resilient.\nThe company proved resilient during the recession.',
        'synonyms': 'Strong, Tough, Hardy',
        'antonyms': 'Fragile, Weak, Vulnerable',
        'etymology': 'From Latin resilire (to spring back), from re- (back) + salire (to jump).'
      },
      {
        'word': 'zenith',
        'part_of_speech': 'Noun',
        'definition': 'The highest point reached by a celestial or other object; the peak.',
        'example': 'The sun reached its zenith at noon.\nHe was at the zenith of his career.',
        'synonyms': 'Peak, Summit, Apex',
        'antonyms': 'Nadir, Bottom, Lowest point',
        'etymology': 'From Arabic samt (ar-ras), meaning "path (over the head)."'
      }
    ];

    for (var word in sampleWords) {
      await db.insert('words', word, conflictAlgorithm: ConflictAlgorithm.ignore);
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
