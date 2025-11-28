import 'dart:math';
import '../database/db_helper.dart';
// Removed unused model imports to fix analyzer warnings

/// Game controller for managing game logic and guess validation
/// Handles number generation, guess comparison, and round management
class GameController {
  static final DatabaseHelper _dbHelper = DatabaseHelper();
  static int? _currentRoundId;
  static int? _currentNumberToGuess;
  static int? _currentHiddenBy;

  /// Start a new round with random number generation
  static Future<int> startNewRound(
    int roundNumber,
    int hiddenBy,
    int rangeLimit,
  ) async {
    final random = Random();
    _currentNumberToGuess = random.nextInt(rangeLimit) + 1;
    _currentHiddenBy = hiddenBy;

    print('GameController: Starting round $roundNumber');
    print('GameController: Hidden by player ID: $hiddenBy');
    print('GameController: Number to guess: $_currentNumberToGuess');

    _currentRoundId = await _dbHelper.insertRound(
      roundNumber,
      hiddenBy,
      _currentNumberToGuess!,
    );

    return _currentRoundId!;
  }

  /// Process a player's guess and return result
  static Future<Map<String, dynamic>> processGuess(
    int playerId,
    int guessedNumber,
  ) async {
    if (_currentNumberToGuess == null || _currentRoundId == null) {
      throw Exception('No active round. Please start a new round first.');
    }

    String result;
    bool isCorrect = false;

    if (guessedNumber == _currentNumberToGuess) {
      result = 'Correct';
      isCorrect = true;
      print('GameController: Player $playerId guessed correctly!');
    } else if (guessedNumber > _currentNumberToGuess!) {
      result = 'Too high';
      print('GameController: Player $playerId guess too high: $guessedNumber');
    } else {
      result = 'Too low';
      print('GameController: Player $playerId guess too low: $guessedNumber');
    }

    // Save guess to database
    await _dbHelper.insertGuess(
      _currentRoundId!,
      playerId,
      guessedNumber,
      result,
    );

    return {
      'result': result,
      'isCorrect': isCorrect,
      'guessedNumber': guessedNumber,
      'actualNumber': _currentNumberToGuess,
    };
  }

  /// Get all guesses for current round
  static Future<List<Map<String, dynamic>>> getCurrentRoundGuesses() async {
    if (_currentRoundId == null) return [];
    return await _dbHelper.getGuessesForRound(_currentRoundId!);
  }

  /// Get all guesses for a specific player in current round
  static Future<List<Map<String, dynamic>>> getPlayerGuesses(
    int playerId,
  ) async {
    if (_currentRoundId == null) return [];
    return await _dbHelper
        .getGuessesForRound(_currentRoundId!)
        .then(
          (guesses) =>
              guesses.where((g) => g['player_id'] == playerId).toList(),
        );
  }

  /// Check if current round is complete (someone guessed correctly)
  static Future<bool> isRoundComplete() async {
    if (_currentRoundId == null) return false;

    final guesses = await _dbHelper.getGuessesForRound(_currentRoundId!);
    return guesses.any((guess) => guess['result'] == 'Correct');
  }

  /// Get the winner of current round
  static Future<Map<String, dynamic>?> getRoundWinner() async {
    if (_currentRoundId == null) return null;

    final guesses = await _dbHelper.getGuessesForRound(_currentRoundId!);
    final winningGuess = guesses.firstWhere(
      (guess) => guess['result'] == 'Correct',
      orElse: () => <String, dynamic>{},
    );

    if (winningGuess.isEmpty) return null;

    return {
      'player_id': winningGuess['player_id'],
      'guessed_number': winningGuess['guessed_number'],
    };
  }

  /// End current round and update winner
  static Future<void> endCurrentRound(int winnerId) async {
    if (_currentRoundId == null) return;

    await _dbHelper.updateRoundWinner(_currentRoundId!, winnerId);
    print('GameController: Round $_currentRoundId ended. Winner: $winnerId');

    // Reset current round data
    _currentRoundId = null;
    _currentNumberToGuess = null;
    _currentHiddenBy = null;
  }

  /// Get current round information
  static Map<String, dynamic> getCurrentRoundInfo() {
    return {
      'round_id': _currentRoundId,
      'number_to_guess': _currentNumberToGuess,
      'hidden_by': _currentHiddenBy,
    };
  }

  /// Reset game state
  static void resetGameState() {
    _currentRoundId = null;
    _currentNumberToGuess = null;
    _currentHiddenBy = null;
    print('GameController: Game state reset');
  }

  /// Validate guess input
  static bool isValidGuess(String input, int rangeLimit) {
    try {
      final number = int.parse(input);
      return number >= 1 && number <= rangeLimit;
    } catch (e) {
      return false;
    }
  }

  /// Get hint for current number (for debugging)
  static int? getCurrentNumber() {
    return _currentNumberToGuess;
  }
}
