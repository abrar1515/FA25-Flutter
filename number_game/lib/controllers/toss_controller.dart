import 'dart:math';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/player_model.dart';

/// Toss controller for managing player selection
/// Ensures fair rotation of players for each round
class TossController {
  static const String _usedPlayersKey = 'used_players_for_toss';
  static const String _currentRoundKey = 'current_round';

  /// Get a random player for the current round
  /// Ensures no player is selected twice until all have had their turn
  static Future<PlayerModel?> selectRandomPlayer(List<PlayerModel> players) async {
    if (players.isEmpty) {
      print('TossController: No players available for selection');
      return null;
    }

    final prefs = await SharedPreferences.getInstance();
    final usedPlayerIds = prefs.getStringList(_usedPlayersKey) ?? [];
    final currentRound = prefs.getInt(_currentRoundKey) ?? 1;

    print('TossController: Current round: $currentRound');
    print('TossController: Used players: $usedPlayerIds');

    // If all players have been used in this round, reset for next round
    if (usedPlayerIds.length >= players.length) {
      print('TossController: All players used, resetting for new round');
      await prefs.remove(_usedPlayersKey);
      await prefs.setInt(_currentRoundKey, currentRound + 1);
      usedPlayerIds.clear();
    }

    // Get available players (not used in current round)
    final availablePlayers = players.where((player) {
      return !usedPlayerIds.contains(player.id.toString());
    }).toList();

    if (availablePlayers.isEmpty) {
      print('TossController: No available players, resetting');
      await prefs.remove(_usedPlayersKey);
      availablePlayers.addAll(players);
    }

    // Select random player from available players
    final random = Random();
    final selectedPlayer = availablePlayers[random.nextInt(availablePlayers.length)];
    
    // Mark this player as used for current round
    usedPlayerIds.add(selectedPlayer.id.toString());
    await prefs.setStringList(_usedPlayersKey, usedPlayerIds);

    print('TossController: Selected player: ${selectedPlayer.name} (ID: ${selectedPlayer.id})');
    return selectedPlayer;
  }

  /// Reset toss state (call when starting new game)
  static Future<void> resetTossState() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_usedPlayersKey);
    await prefs.setInt(_currentRoundKey, 1);
    print('TossController: Toss state reset for new game');
  }

  /// Get current round number
  static Future<int> getCurrentRound() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getInt(_currentRoundKey) ?? 1;
  }

  /// Check if all players have been used in current round
  static Future<bool> areAllPlayersUsed(List<PlayerModel> players) async {
    final prefs = await SharedPreferences.getInstance();
    final usedPlayerIds = prefs.getStringList(_usedPlayersKey) ?? [];
    return usedPlayerIds.length >= players.length;
  }

  /// Get list of players who haven't been selected in current round
  static Future<List<PlayerModel>> getAvailablePlayers(List<PlayerModel> players) async {
    final prefs = await SharedPreferences.getInstance();
    final usedPlayerIds = prefs.getStringList(_usedPlayersKey) ?? [];
    
    return players.where((player) {
      return !usedPlayerIds.contains(player.id.toString());
    }).toList();
  }
}
