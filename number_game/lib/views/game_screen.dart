import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/player_model.dart';
import '../controllers/game_controller.dart';
import '../controllers/score_controller.dart';
// Removed unused import
import 'result_screen.dart';

/// Game screen for number guessing gameplay
/// Matches the UI design shown in the fourth image
class GameScreen extends StatefulWidget {
  final PlayerModel selectedPlayer;

  const GameScreen({super.key, required this.selectedPlayer});

  @override
  State<GameScreen> createState() => _GameScreenState();
}

class _GameScreenState extends State<GameScreen> {
  final TextEditingController _guessController = TextEditingController();
  // Using static methods from controllers

  List<Map<String, dynamic>> _previousGuesses = [];
  String _feedback = '';
  int _rangeLimit = 100;
  int _marksPerWin = 5;
  int _currentRound = 1;
  int _totalRounds = 3;

  @override
  void initState() {
    super.initState();
    _loadSettings();
    _startNewRound();
  }

  /// Load game settings from SharedPreferences
  Future<void> _loadSettings() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      setState(() {
        _rangeLimit = prefs.getInt('range_limit') ?? 100;
        _marksPerWin = prefs.getInt('marks_per_win') ?? 5;
        _totalRounds = prefs.getInt('total_rounds') ?? 3;
      });
    } catch (e) {
      print('Error loading settings: $e');
    }
  }

  /// Start a new round
  Future<void> _startNewRound() async {
    try {
      await GameController.startNewRound(
        _currentRound,
        widget.selectedPlayer.id!,
        _rangeLimit,
      );
      await _loadPreviousGuesses();
    } catch (e) {
      _showSnackBar('Error starting round: $e');
    }
  }

  /// Load previous guesses for current round
  Future<void> _loadPreviousGuesses() async {
    try {
      final guesses = await GameController.getCurrentRoundGuesses();
      setState(() {
        _previousGuesses = guesses;
      });
    } catch (e) {
      print('Error loading previous guesses: $e');
    }
  }

  /// Process player's guess
  Future<void> _processGuess() async {
    final guessText = _guessController.text.trim();
    if (guessText.isEmpty) {
      _showSnackBar('Please enter a guess');
      return;
    }

    if (!GameController.isValidGuess(guessText, _rangeLimit)) {
      _showSnackBar('Please enter a number between 1 and $_rangeLimit');
      return;
    }

    try {
      final guess = int.parse(guessText);
      final result = await GameController.processGuess(
        widget.selectedPlayer.id!,
        guess,
      );

      setState(() {
        _feedback = result['result'];
      });

      _guessController.clear();
      await _loadPreviousGuesses();

      // Check if guess is correct
      if (result['isCorrect']) {
        await _handleCorrectGuess();
      }
    } catch (e) {
      _showSnackBar('Error processing guess: $e');
    }
  }

  /// Handle correct guess
  Future<void> _handleCorrectGuess() async {
    try {
      // Update player score
      await ScoreController.updatePlayerScore(
        widget.selectedPlayer.id!,
        _marksPerWin,
      );

      // End current round
      await GameController.endCurrentRound(widget.selectedPlayer.id!);

      // Check if game is complete
      if (_currentRound >= _totalRounds) {
        _showGameCompleteDialog();
      } else {
        _showRoundCompleteDialog();
      }
    } catch (e) {
      _showSnackBar('Error handling correct guess: $e');
    }
  }

  /// Show round complete dialog
  void _showRoundCompleteDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: Text(
          'Round Complete!',
          style: GoogleFonts.poppins(fontWeight: FontWeight.bold),
        ),
        content: Text(
          '${widget.selectedPlayer.name} won this round!\n+$_marksPerWin points',
          style: GoogleFonts.poppins(),
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              _nextRound();
            },
            child: Text(
              'Next Round',
              style: GoogleFonts.poppins(fontWeight: FontWeight.w600),
            ),
          ),
        ],
      ),
    );
  }

  /// Show game complete dialog
  void _showGameCompleteDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: Text(
          'Game Complete!',
          style: GoogleFonts.poppins(fontWeight: FontWeight.bold),
        ),
        content: Text(
          'All rounds finished!\n${widget.selectedPlayer.name} won the final round!',
          style: GoogleFonts.poppins(),
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              _goToResults();
            },
            child: Text(
              'View Results',
              style: GoogleFonts.poppins(fontWeight: FontWeight.w600),
            ),
          ),
        ],
      ),
    );
  }

  /// Move to next round
  Future<void> _nextRound() async {
    setState(() {
      _currentRound++;
      // Replace the list with a fresh empty list so any external
      // references aren't retained by the UI or builders.
      _previousGuesses = [];
      _feedback = '';
    });
    await _startNewRound();
  }

  /// Go to results screen
  void _goToResults() {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => const ResultScreen()),
    );
  }

  /// Show snackbar message
  void _showSnackBar(String message) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message)));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // Blue gradient background
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFF64B5F6), Color(0xFF1976D2)],
          ),
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Player info section
                Row(
                  children: [
                    // Player avatar
                    Container(
                      width: 50,
                      height: 50,
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [Color(0xFFFF6B9D), Color(0xFF4ECDC4)],
                        ),
                        borderRadius: BorderRadius.circular(25),
                      ),
                      child: const Icon(
                        Icons.person,
                        color: Colors.white,
                        size: 24,
                      ),
                    ),
                    const SizedBox(width: 16),
                    // Player name and turn info
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "${widget.selectedPlayer.name}'s Turn",
                          style: GoogleFonts.poppins(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                        Text(
                          "I'm thinking of a number between 1 and $_rangeLimit",
                          style: GoogleFonts.poppins(
                            fontSize: 14,
                            color: Colors.white.withOpacity(0.8),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 40),

                // Guess input section
                Text(
                  'Your guess',
                  style: GoogleFonts.poppins(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 16),
                Container(
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.9),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: TextField(
                    controller: _guessController,
                    keyboardType: TextInputType.number,
                    decoration: InputDecoration(
                      hintText: 'Enter your guess',
                      hintStyle: GoogleFonts.poppins(
                        color: Colors.grey[600],
                        fontSize: 16,
                      ),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide.none,
                      ),
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 16,
                      ),
                    ),
                    style: GoogleFonts.poppins(fontSize: 16),
                  ),
                ),
                const SizedBox(height: 16),

                // Feedback section
                if (_feedback.isNotEmpty)
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: _feedback == 'Correct'
                          ? Colors.green.withOpacity(0.2)
                          : _feedback == 'Too high'
                          ? Colors.orange.withOpacity(0.2)
                          : Colors.blue.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: _feedback == 'Correct'
                            ? Colors.green
                            : _feedback == 'Too high'
                            ? Colors.orange
                            : Colors.blue,
                        width: 1,
                      ),
                    ),
                    child: Text(
                      'Your guess is $_feedback.toLowerCase()',
                      style: GoogleFonts.poppins(
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                        color: Colors.white,
                      ),
                    ),
                  ),
                const SizedBox(height: 24),

                // Guess button
                Container(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: _processGuess,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF4ECDC4),
                      foregroundColor: Colors.white,
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      padding: const EdgeInsets.symmetric(vertical: 16),
                    ),
                    child: Text(
                      'Guess',
                      style: GoogleFonts.poppins(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 40),

                // Previous guesses section
                if (_previousGuesses.isNotEmpty) ...[
                  Text(
                    'Previous Guesses',
                    style: GoogleFonts.poppins(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Expanded(
                    child: ListView.builder(
                      itemCount: _previousGuesses.length,
                      itemBuilder: (context, index) {
                        final guess = _previousGuesses[index];
                        return Container(
                          margin: const EdgeInsets.only(bottom: 8),
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 12,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                '${guess['guessed_number']}',
                                style: GoogleFonts.poppins(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w500,
                                  color: Colors.white,
                                ),
                              ),
                              Text(
                                '- ${guess['result']}',
                                style: GoogleFonts.poppins(
                                  fontSize: 14,
                                  color: Colors.white.withOpacity(0.8),
                                ),
                              ),
                            ],
                          ),
                        );
                      },
                    ),
                  ),
                ] else
                  Expanded(
                    child: Center(
                      child: Text(
                        'No guesses yet',
                        style: GoogleFonts.poppins(
                          fontSize: 16,
                          color: Colors.white.withOpacity(0.6),
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _guessController.dispose();
    super.dispose();
  }
}
