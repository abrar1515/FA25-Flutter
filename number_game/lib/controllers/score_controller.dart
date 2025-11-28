import '../database/db_helper.dart';
// Removed unused model import

/// Score controller for managing player scores and game results
/// Handles score updates, leaderboard management, and final winner logic
class ScoreController {
  static final DatabaseHelper _dbHelper = DatabaseHelper();

  /// Update player score when they win a round
  static Future<void> updatePlayerScore(int playerId, int marksPerWin) async {
    try {
      // Get current player data
      final playerData = await _dbHelper.getPlayer(playerId);
      if (playerData == null) {
        print('ScoreController: Player with ID $playerId not found');
        return;
      }

      final currentScore = playerData['total_score'] ?? 0;
      final newScore = currentScore + marksPerWin;

      // Update player score in database
      await _dbHelper.updatePlayerScore(playerId, newScore);

      print(
        'ScoreController: Updated score for player $playerId: $currentScore -> $newScore (+$marksPerWin)',
      );
    } catch (e) {
      print('ScoreController: Error updating score for player $playerId: $e');
    }
  }

  /// Get all players with their scores (leaderboard)
  static Future<List<Map<String, dynamic>>> getLeaderboard() async {
    try {
      final players = await _dbHelper.getAllPlayers();
      print(
        'ScoreController: Retrieved leaderboard with ${players.length} players',
      );
      return players;
    } catch (e) {
      print('ScoreController: Error getting leaderboard: $e');
      return [];
    }
  }

  /// Get the winner (player with highest score)
  static Future<Map<String, dynamic>?> getWinner() async {
    try {
      final leaderboard = await getLeaderboard();
      if (leaderboard.isEmpty) return null;

      // Sort by score (descending) and get the first player
      leaderboard.sort(
        (a, b) => (b['total_score'] ?? 0).compareTo(a['total_score'] ?? 0),
      );
      final winner = leaderboard.first;

      print(
        'ScoreController: Winner: ${winner['name']} with score ${winner['total_score']}',
      );
      return winner;
    } catch (e) {
      print('ScoreController: Error getting winner: $e');
      return null;
    }
  }

  /// Get player rank in leaderboard
  static Future<int> getPlayerRank(int playerId) async {
    try {
      final leaderboard = await getLeaderboard();
      for (int i = 0; i < leaderboard.length; i++) {
        if (leaderboard[i]['id'] == playerId) {
          return i + 1; // Rank starts from 1
        }
      }
      return -1; // Player not found
    } catch (e) {
      print('ScoreController: Error getting player rank: $e');
      return -1;
    }
  }

  /// Get game statistics
  static Future<Map<String, dynamic>> getGameStats() async {
    try {
      final stats = await _dbHelper.getGameStats();
      final leaderboard = await getLeaderboard();
      final winner = await getWinner();

      return {
        ...stats,
        'leaderboard': leaderboard,
        'winner': winner,
        'total_players': leaderboard.length,
      };
    } catch (e) {
      print('ScoreController: Error getting game stats: $e');
      return {};
    }
  }

  /// Reset all scores (for new game)
  static Future<void> resetAllScores() async {
    try {
      // Get all players and reset their scores to 0
      final players = await _dbHelper.getAllPlayers();
      for (final player in players) {
        await _dbHelper.updatePlayerScore(player['id'], 0);
      }

      // Clear rounds and guesses data
      await _dbHelper.clearAllData();

      print('ScoreController: All scores and game data reset');
    } catch (e) {
      print('ScoreController: Error resetting scores: $e');
    }
  }

  /// Get player's total score
  static Future<int> getPlayerScore(int playerId) async {
    try {
      final playerData = await _dbHelper.getPlayer(playerId);
      return playerData?['total_score'] ?? 0;
    } catch (e) {
      print('ScoreController: Error getting player score: $e');
      return 0;
    }
  }

  /// Check if game is complete (all rounds finished)
  static Future<bool> isGameComplete(int totalRounds) async {
    try {
      final rounds = await _dbHelper.getAllRounds();
      return rounds.length >= totalRounds;
    } catch (e) {
      print('ScoreController: Error checking game completion: $e');
      return false;
    }
  }

  /// Get round history for a specific player
  static Future<List<Map<String, dynamic>>> getPlayerHistory(
    int playerId,
  ) async {
    try {
      final guesses = await _dbHelper.getGuessesForPlayer(playerId);
      print(
        'ScoreController: Retrieved ${guesses.length} guesses for player $playerId',
      );
      return guesses;
    } catch (e) {
      print('ScoreController: Error getting player history: $e');
      return [];
    }
  }
}
