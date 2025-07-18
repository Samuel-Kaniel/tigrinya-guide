import 'dart:async';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import '../models/letter.dart';

class DatabaseService {
  static final DatabaseService _instance = DatabaseService._internal();
  static DatabaseService get instance => _instance;
  DatabaseService._internal();

  Database? _database;

  Future<Database> get database async {
    _database ??= await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, 'tigrinya_guide.db');

    return await openDatabase(
      path,
      version: 1,
      onCreate: _onCreate,
    );
  }

  Future<void> _onCreate(Database db, int version) async {
    await db.execute('''
      CREATE TABLE letters (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        character TEXT NOT NULL,
        pronunciation TEXT NOT NULL,
        example TEXT NOT NULL,
        translation TEXT NOT NULL,
        audio_url TEXT
      )
    ''');

    await db.execute('''
      CREATE TABLE user_progress (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        letter_id INTEGER,
        practice_count INTEGER DEFAULT 0,
        quiz_correct INTEGER DEFAULT 0,
        quiz_attempts INTEGER DEFAULT 0,
        last_practiced TEXT,
        FOREIGN KEY (letter_id) REFERENCES letters (id)
      )
    ''');

    // Insert sample Tigrinya letters
    await _insertSampleData(db);
  }

  Future<void> _insertSampleData(Database db) async {
    final sampleLetters = [
      {
        'character': 'ሀ',
        'pronunciation': 'ha',
        'example': 'ሀገር',
        'translation': 'country'
      },
      {
        'character': 'ለ',
        'pronunciation': 'le',
        'example': 'ለባስ',
        'translation': 'clothes'
      },
      {
        'character': 'ሐ',
        'pronunciation': 'Ha',
        'example': 'ሐሳብ',
        'translation': 'thought'
      },
      {
        'character': 'መ',
        'pronunciation': 'me',
        'example': 'መጽሓፍ',
        'translation': 'book'
      },
      {
        'character': 'ሠ',
        'pronunciation': 'se',
        'example': 'ሠላም',
        'translation': 'peace'
      },
      {
        'character': 'ረ',
        'pronunciation': 're',
        'example': 'ረድኤት',
        'translation': 'help'
      },
      {
        'character': 'ሰ',
        'pronunciation': 'se',
        'example': 'ሰላም',
        'translation': 'peace'
      },
      {
        'character': 'ሸ',
        'pronunciation': 'she',
        'example': 'ሸሚዝ',
        'translation': 'shirt'
      },
      {
        'character': 'ቀ',
        'pronunciation': 'qe',
        'example': 'ቀን',
        'translation': 'day'
      },
      {
        'character': 'በ',
        'pronunciation': 'be',
        'example': 'በዓል',
        'translation': 'festival'
      },
      {
        'character': 'ተ',
        'pronunciation': 'te',
        'example': 'ተስፋ',
        'translation': 'hope'
      },
      {
        'character': 'ቸ',
        'pronunciation': 'che',
        'example': 'ቸርቃ',
        'translation': 'mud'
      },
      {
        'character': 'ኀ',
        'pronunciation': 'khe',
        'example': 'ኀይሊ',
        'translation': 'strong'
      },
      {
        'character': 'ነ',
        'pronunciation': 'ne',
        'example': 'ነፋስ',
        'translation': 'wind'
      },
      {
        'character': 'ኘ',
        'pronunciation': 'nye',
        'example': 'ኘሮ',
        'translation': 'black'
      },
      {
        'character': 'አ',
        'pronunciation': 'a',
        'example': 'አንበሳ',
        'translation': 'lion'
      },
      {
        'character': 'ከ',
        'pronunciation': 'ke',
        'example': 'ከተማ',
        'translation': 'city'
      },
      {
        'character': 'ኸ',
        'pronunciation': 'khe',
        'example': 'ኸሪ',
        'translation': 'dog'
      },
      {
        'character': 'ወ',
        'pronunciation': 'we',
        'example': 'ወርሒ',
        'translation': 'month'
      },
      {
        'character': 'ዐ',
        'pronunciation': 'a',
        'example': 'ዐይኒ',
        'translation': 'eye'
      },
      {
        'character': 'ዘ',
        'pronunciation': 'ze',
        'example': 'ዘመን',
        'translation': 'time'
      },
      {
        'character': 'ዠ',
        'pronunciation': 'zhe',
        'example': 'ዠንጎ',
        'translation': 'brain'
      },
      {
        'character': 'የ',
        'pronunciation': 'ye',
        'example': 'የማነ',
        'translation': 'right'
      },
      {
        'character': 'ደ',
        'pronunciation': 'de',
        'example': 'ደቂ',
        'translation': 'children'
      },
      {
        'character': 'ጀ',
        'pronunciation': 'je',
        'example': 'ጀሚሩ',
        'translation': 'started'
      },
      {
        'character': 'ገ',
        'pronunciation': 'ge',
        'example': 'ገዛ',
        'translation': 'house'
      },
      {
        'character': 'ጠ',
        'pronunciation': 'Te',
        'example': 'ጠቢብ',
        'translation': 'wise'
      },
      {
        'character': 'ጨ',
        'pronunciation': 'Che',
        'example': 'ጨረቃ',
        'translation': 'moon'
      },
      {
        'character': 'ጰ',
        'pronunciation': 'Pe',
        'example': 'ጰጣሮስ',
        'translation': 'Peter'
      },
      {
        'character': 'ጸ',
        'pronunciation': 'Tse',
        'example': 'ጸሓይ',
        'translation': 'sun'
      },
      {
        'character': 'ፀ',
        'pronunciation': 'tse',
        'example': 'ፀሓይ',
        'translation': 'sun'
      },
      {
        'character': 'ፈ',
        'pronunciation': 'fe',
        'example': 'ፈረስ',
        'translation': 'horse'
      },
      {
        'character': 'ፐ',
        'pronunciation': 'pe',
        'example': 'ፐንስል',
        'translation': 'pencil'
      },
    ];

    for (final letter in sampleLetters) {
      await db.insert('letters', letter);
    }
  }

  Future<void> initDatabase() async {
    await database;
  }

  Future<List<Letter>> getLetters() async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query('letters');
    return List.generate(maps.length, (i) => Letter.fromMap(maps[i]));
  }

  Future<Letter?> getLetter(int id) async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'letters',
      where: 'id = ?',
      whereArgs: [id],
    );
    if (maps.isNotEmpty) {
      return Letter.fromMap(maps.first);
    }
    return null;
  }

  Future<int> insertLetter(Letter letter) async {
    final db = await database;
    return await db.insert('letters', letter.toMap());
  }

  Future<void> updateLetter(Letter letter) async {
    final db = await database;
    await db.update(
      'letters',
      letter.toMap(),
      where: 'id = ?',
      whereArgs: [letter.id],
    );
  }

  Future<void> deleteLetter(int id) async {
    final db = await database;
    await db.delete(
      'letters',
      where: 'id = ?',
      whereArgs: [id],
    );
  }
}
