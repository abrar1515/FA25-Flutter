import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

/// Database helper class for managing SQLite database operations
/// Handles players, rounds, and guesses tables with full CRUD functionality
class DatabaseHelper {
  static final DatabaseHelper _instance = DatabaseHelper._internal();
  factory DatabaseHelper() => _instance;
  DatabaseHelper._internal();

  static Database? _database;

  /// Get database instance, create if not exists
  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  /// Initialize database with all required tables
  Future<Database> _initDatabase() async {
    String path = join(await getDatabasesPath(), 'number_guessing_game.db');
    return await openDatabase(
      path,
      version: 1,
      onCreate: _onCreate,
    );
  }

  /// Create all tables on database creation
  Future<void> _onCreate(Database db, int version) async {
    // Players table - stores player information and scores
    await db.execute('''
      CREATE TABLE players(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT NOT NULL,
        total_score INTEGER DEFAULT 0
      )
    ''');

    // Rounds table - stores round information
    await db.execute('''
      CREATE TABLE rounds(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        round_number INTEGER NOT NULL,
        hidden_by INTEGER NOT NULL,
        winner_id INTEGER,
        number_to_guess INTEGER NOT NULL,
        FOREIGN KEY (hidden_by) REFERENCES players (id),
        FOREIGN KEY (winner_id) REFERENCES players (id)
      )
    ''');

    // Guesses table - stores all player guesses
    await db.execute('''
      CREATE TABLE guesses(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        round_id INTEGER NOT NULL,
        player_id INTEGER NOT NULL,
        guessed_number INTEGER NOT NULL,
        result TEXT NOT NULL,
        FOREIGN KEY (round_id) REFERENCES rounds (id),
        FOREIGN KEY (player_id) REFERENCES players (id)
      )
    ''');
  }

  // ========== PLAYERS CRUD OPERATIONS ==========

  /// Insert a new player
  Future<int> insertPlayer(String name) async {
    final db = await database;
    return await db.insert('players', {'name': name, 'total_score': 0});
  }

  /// Get all players
  Future<List<Map<String, dynamic>>> getAllPlayers() async {
    final db = await database;
    return await db.query('players', orderBy: 'total_score DESC');
  }

  /// Get player by ID
  Future<Map<String, dynamic>?> getPlayer(int id) async {
    final db = await database;
    final result = await db.query('players', where: 'id = ?', whereArgs: [id]);
    return result.isNotEmpty ? result.first : null;
  }

  /// Update player score
  Future<int> updatePlayerScore(int playerId, int newScore) async {
    final db = await database;
    return await db.update(
      'players',
      {'total_score': newScore},
      where: 'id = ?',
      whereArgs: [playerId],
    );
  }

  /// Delete a player
  Future<int> deletePlayer(int id) async {
    final db = await database;
    return await db.delete('players', where: 'id = ?', whereArgs: [id]);
  }

  // ========== ROUNDS CRUD OPERATIONS ==========

  /// Insert a new round
  Future<int> insertRound(int roundNumber, int hiddenBy, int numberToGuess) async {
    final db = await database;
    return await db.insert('rounds', {
      'round_number': roundNumber,
      'hidden_by': hiddenBy,
      'number_to_guess': numberToGuess,
    });
  }

  /// Get all rounds
  Future<List<Map<String, dynamic>>> getAllRounds() async {
    final db = await database;
    return await db.query('rounds', orderBy: 'round_number ASC');
  }

  /// Get round by ID
  Future<Map<String, dynamic>?> getRound(int id) async {
    final db = await database;
    final result = await db.query('rounds', where: 'id = ?', whereArgs: [id]);
    return result.isNotEmpty ? result.first : null;
  }

  /// Update round winner
  Future<int> updateRoundWinner(int roundId, int winnerId) async {
    final db = await database;
    return await db.update(
      'rounds',
      {'winner_id': winnerId},
      where: 'id = ?',
      whereArgs: [roundId],
    );
  }

  /// Delete a round
  Future<int> deleteRound(int id) async {
    final db = await database;
    return await db.delete('rounds', where: 'id = ?', whereArgs: [id]);
  }

  // ========== GUESSES CRUD OPERATIONS ==========

  /// Insert a new guess
  Future<int> insertGuess(int roundId, int playerId, int guessedNumber, String result) async {
    final db = await database;
    return await db.insert('guesses', {
      'round_id': roundId,
      'player_id': playerId,
      'guessed_number': guessedNumber,
      'result': result,
    });
  }

  /// Get all guesses for a round
  Future<List<Map<String, dynamic>>> getGuessesForRound(int roundId) async {
    final db = await database;
    return await db.query(
      'guesses',
      where: 'round_id = ?',
      whereArgs: [roundId],
      orderBy: 'id ASC',
    );
  }

  /// Get all guesses for a player
  Future<List<Map<String, dynamic>>> getGuessesForPlayer(int playerId) async {
    final db = await database;
    return await db.query(
      'guesses',
      where: 'player_id = ?',
      whereArgs: [playerId],
      orderBy: 'id ASC',
    );
  }

  /// Delete all guesses for a round
  Future<int> deleteGuessesForRound(int roundId) async {
    final db = await database;
    return await db.delete('guesses', where: 'round_id = ?', whereArgs: [roundId]);
  }

  // ========== UTILITY METHODS ==========

  /// Clear all data (for testing or reset)
  Future<void> clearAllData() async {
    final db = await database;
    await db.delete('guesses');
    await db.delete('rounds');
    await db.delete('players');
  }

  /// Get game statistics
  Future<Map<String, dynamic>> getGameStats() async {
    final db = await database;
    
    final playerCount = Sqflite.firstIntValue(
      await db.rawQuery('SELECT COUNT(*) FROM players')
    ) ?? 0;
    
    final roundCount = Sqflite.firstIntValue(
      await db.rawQuery('SELECT COUNT(*) FROM rounds')
    ) ?? 0;
    
    final guessCount = Sqflite.firstIntValue(
      await db.rawQuery('SELECT COUNT(*) FROM guesses')
    ) ?? 0;

    return {
      'player_count': playerCount,
      'round_count': roundCount,
      'guess_count': guessCount,
    };
  }

  /// Close database connection
  Future<void> close() async {
    final db = await database;
    await db.close();
  }
}
