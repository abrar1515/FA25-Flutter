import 'dart:math';
import 'database/db_helper.dart';
import 'models/player_model.dart';
import 'controllers/toss_controller.dart';
import 'controllers/game_controller.dart';
import 'controllers/score_controller.dart';

/// Test script to demonstrate the complete game flow
/// Creates dummy data and runs a test game for 2 rounds
class TestGameFlow {
  static final DatabaseHelper _dbHelper = DatabaseHelper();
  // Using static methods from controllers

  /// Run complete test game flow
  static Future<void> runTestGame() async {
    print('🎮 Starting Number Guessing Game Test Flow');
    print('=' * 50);

    try {
      // Step 1: Clear existing data
      await _dbHelper.clearAllData();
      print('✅ Cleared existing game data');

      // Step 2: Add test players
      await _addTestPlayers();
      print('✅ Added test players: Ali, Sara, Hamza');

      // Step 3: Run test game for 2 rounds
      await _runTestRounds();

      // Step 4: Display final results
      await _displayFinalResults();

      print('🎉 Test game completed successfully!');
    } catch (e) {
      print('❌ Error during test: $e');
    }
  }

  /// Add test players to database
  static Future<void> _addTestPlayers() async {
    final players = ['Ali', 'Sara', 'Hamza'];
    for (final name in players) {
      await _dbHelper.insertPlayer(name);
    }
  }

  /// Run test rounds
  static Future<void> _runTestRounds() async {
    const totalRounds = 2;
    const rangeLimit = 50;
    const marksPerWin = 5;

    for (int round = 1; round <= totalRounds; round++) {
      print('\n🎯 Round $round');
      print('-' * 30);

      // Get all players
      final playersData = await _dbHelper.getAllPlayers();
      final players = playersData
          .map((data) => PlayerModel.fromMap(data))
          .toList();

      // Select random player for this round
      final selectedPlayer = await TossController.selectRandomPlayer(players);
      if (selectedPlayer == null) {
        print('❌ No player selected for round $round');
        continue;
      }

      print('🎲 Selected player: ${selectedPlayer.name}');

      // Start new round
      await GameController.startNewRound(round, selectedPlayer.id!, rangeLimit);
      print('🎯 Number to guess: ${GameController.getCurrentNumber()}');

      // Simulate guessing
      await _simulateGuessing(selectedPlayer, rangeLimit);

      // Check if someone won
      final isComplete = await GameController.isRoundComplete();
      if (isComplete) {
        final winner = await GameController.getRoundWinner();
        if (winner != null) {
          print(
            '🏆 Winner: Player ${winner['player_id']} with guess ${winner['guessed_number']}',
          );

          // Update score
          await ScoreController.updatePlayerScore(
            winner['player_id'],
            marksPerWin,
          );
          print('📊 Updated score: +$marksPerWin points');
        }
      }

      // End round
      await GameController.endCurrentRound(selectedPlayer.id!);
    }
  }

  /// Simulate guessing process
  static Future<void> _simulateGuessing(
    PlayerModel player,
    int rangeLimit,
  ) async {
    final random = Random();
    int attempts = 0;
    const maxAttempts = 5;

    print('🎮 ${player.name} is guessing...');

    while (attempts < maxAttempts) {
      attempts++;

      // Generate random guess
      final guess = random.nextInt(rangeLimit) + 1;

      // Process guess
      final result = await GameController.processGuess(player.id!, guess);

      print('  Attempt $attempts: Guessed $guess - ${result['result']}');

      if (result['isCorrect']) {
        print('🎉 Correct guess! ${player.name} wins this round!');
        break;
      }

      // Small delay for realistic simulation
      await Future.delayed(const Duration(milliseconds: 500));
    }
  }

  /// Display final game results
  static Future<void> _displayFinalResults() async {
    print('\n🏆 FINAL RESULTS');
    print('=' * 50);

    // Get leaderboard
    final leaderboard = await ScoreController.getLeaderboard();

    if (leaderboard.isEmpty) {
      print('❌ No results found');
      return;
    }

    // Sort by score (descending)
    leaderboard.sort(
      (a, b) => (b['total_score'] ?? 0).compareTo(a['total_score'] ?? 0),
    );

    print('📊 Leaderboard:');
    for (int i = 0; i < leaderboard.length; i++) {
      final player = leaderboard[i];
      final rank = i + 1;
      final name = player['name'] ?? 'Unknown';
      final score = player['total_score'] ?? 0;

      if (rank == 1) {
        print('🥇 $rank. $name - $score points (WINNER!)');
      } else {
        print('   $rank. $name - $score points');
      }
    }

    // Get game statistics
    final stats = await ScoreController.getGameStats();
    print('\n📈 Game Statistics:');
    print('   Total Players: ${stats['player_count']}');
    print('   Total Rounds: ${stats['round_count']}');
    print('   Total Guesses: ${stats['guess_count']}');
  }
}

// Using Dart's built-in Random from `dart:math` above
