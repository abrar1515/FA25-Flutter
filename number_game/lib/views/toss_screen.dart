import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../models/player_model.dart';
import '../database/db_helper.dart';
import '../controllers/toss_controller.dart';
import 'game_screen.dart';

/// Toss screen for player selection
/// Matches the UI design shown in the third image
class TossScreen extends StatefulWidget {
  const TossScreen({super.key});

  @override
  State<TossScreen> createState() => _TossScreenState();
}

class _TossScreenState extends State<TossScreen> with TickerProviderStateMixin {
  final DatabaseHelper _dbHelper = DatabaseHelper();
  List<PlayerModel> _players = [];
  PlayerModel? _selectedPlayer;
  bool _isAnimating = false;
  late AnimationController _animationController;
  late Animation<double> _rotationAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    );
    _rotationAnimation =
        Tween<double>(
          begin: 0,
          end: 4 * 2 * 3.14159, // 4 full rotations
        ).animate(
          CurvedAnimation(
            parent: _animationController,
            curve: Curves.easeInOut,
          ),
        );
    _loadPlayers();
  }

  /// Load all players from database
  Future<void> _loadPlayers() async {
    try {
      final playersData = await _dbHelper.getAllPlayers();
      setState(() {
        _players = playersData
            .map((data) => PlayerModel.fromMap(data))
            .toList();
      });
    } catch (e) {
      print('Error loading players: $e');
    }
  }

  /// Select a random player with animation
  Future<void> _selectPlayer() async {
    if (_players.isEmpty) return;

    setState(() {
      _isAnimating = true;
    });

    // Start animation
    _animationController.forward();

    // Wait for animation to complete
    await Future.delayed(const Duration(seconds: 2));

    // Select random player
    final selectedPlayer = await TossController.selectRandomPlayer(_players);

    setState(() {
      _selectedPlayer = selectedPlayer;
      _isAnimating = false;
    });

    _animationController.reset();
  }

  /// Continue to game screen
  void _continueToGame() {
    if (_selectedPlayer == null) return;

    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (context) => GameScreen(selectedPlayer: _selectedPlayer!),
      ),
    );
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
              children: [
                const SizedBox(height: 40),

                // Animated circular graphic
                AnimatedBuilder(
                  animation: _rotationAnimation,
                  builder: (context, child) {
                    return Transform.rotate(
                      angle: _rotationAnimation.value,
                      child: Container(
                        width: 200,
                        height: 200,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: Colors.white.withOpacity(0.3),
                            width: 2,
                          ),
                        ),
                        child: Stack(
                          children: [
                            // Outer ring
                            Container(
                              width: 200,
                              height: 200,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                border: Border.all(
                                  color: Colors.white.withOpacity(0.2),
                                  width: 1,
                                ),
                              ),
                            ),
                            // Middle ring
                            Container(
                              width: 150,
                              height: 150,
                              margin: const EdgeInsets.all(25),
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                border: Border.all(
                                  color: Colors.white.withOpacity(0.2),
                                  width: 1,
                                ),
                              ),
                            ),
                            // Inner ring
                            Container(
                              width: 100,
                              height: 100,
                              margin: const EdgeInsets.all(50),
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                border: Border.all(
                                  color: Colors.white.withOpacity(0.2),
                                  width: 1,
                                ),
                              ),
                            ),
                            // Center question mark
                            Center(
                              child: Text(
                                '?',
                                style: GoogleFonts.poppins(
                                  fontSize: 48,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),

                const SizedBox(height: 40),

                // Player turn display
                if (_selectedPlayer != null)
                  Text(
                    "${_selectedPlayer!.name}'s turn",
                    style: GoogleFonts.poppins(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  )
                else
                  Text(
                    "Selecting player...",
                    style: GoogleFonts.poppins(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),

                const SizedBox(height: 40),

                // Player list
                if (_players.isNotEmpty)
                  Column(
                    children: _players.map((player) {
                      final isSelected = _selectedPlayer?.id == player.id;

                      return Container(
                        margin: const EdgeInsets.only(bottom: 8),
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 12,
                          ),
                          decoration: BoxDecoration(
                            color: isSelected
                                ? Colors.white.withOpacity(0.2)
                                : Colors.transparent,
                            borderRadius: BorderRadius.circular(8),
                            border: isSelected
                                ? Border.all(color: Colors.white, width: 2)
                                : null,
                          ),
                          child: Text(
                            player.name,
                            style: GoogleFonts.poppins(
                              fontSize: 16,
                              fontWeight: FontWeight.w500,
                              color: isSelected
                                  ? Colors.white
                                  : Colors.white.withOpacity(0.7),
                            ),
                          ),
                        ),
                      );
                    }).toList(),
                  ),

                const Spacer(),

                // Continue button
                if (_selectedPlayer != null)
                  Container(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: _continueToGame,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFFFC107),
                        foregroundColor: Colors.white,
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        padding: const EdgeInsets.symmetric(vertical: 16),
                      ),
                      child: Text(
                        'Continue',
                        style: GoogleFonts.poppins(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  )
                else
                  Container(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: _isAnimating ? null : _selectPlayer,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.white.withOpacity(0.2),
                        foregroundColor: Colors.white,
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        padding: const EdgeInsets.symmetric(vertical: 16),
                      ),
                      child: Text(
                        _isAnimating ? 'Selecting...' : 'Select Player',
                        style: GoogleFonts.poppins(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
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
    _animationController.dispose();
    super.dispose();
  }
}
