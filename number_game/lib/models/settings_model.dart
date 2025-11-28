/// Settings model class for managing game settings
/// Contains game configuration and preferences
class SettingsModel {
  final int totalRounds;
  final int marksPerWin;
  final int rangeLimit;
  final int totalPlayers;

  const SettingsModel({
    this.totalRounds = 3,
    this.marksPerWin = 5,
    this.rangeLimit = 100,
    this.totalPlayers = 2,
  });

  /// Create SettingsModel from SharedPreferences map
  factory SettingsModel.fromMap(Map<String, dynamic> map) {
    return SettingsModel(
      totalRounds: map['total_rounds']?.toInt() ?? 3,
      marksPerWin: map['marks_per_win']?.toInt() ?? 5,
      rangeLimit: map['range_limit']?.toInt() ?? 100,
      totalPlayers: map['total_players']?.toInt() ?? 2,
    );
  }

  /// Convert SettingsModel to SharedPreferences map
  Map<String, dynamic> toMap() {
    return {
      'total_rounds': totalRounds,
      'marks_per_win': marksPerWin,
      'range_limit': rangeLimit,
      'total_players': totalPlayers,
    };
  }

  /// Create a copy of SettingsModel with updated fields
  SettingsModel copyWith({
    int? totalRounds,
    int? marksPerWin,
    int? rangeLimit,
    int? totalPlayers,
  }) {
    return SettingsModel(
      totalRounds: totalRounds ?? this.totalRounds,
      marksPerWin: marksPerWin ?? this.marksPerWin,
      rangeLimit: rangeLimit ?? this.rangeLimit,
      totalPlayers: totalPlayers ?? this.totalPlayers,
    );
  }

  @override
  String toString() {
    return 'SettingsModel(totalRounds: $totalRounds, marksPerWin: $marksPerWin, rangeLimit: $rangeLimit, totalPlayers: $totalPlayers)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is SettingsModel &&
        other.totalRounds == totalRounds &&
        other.marksPerWin == marksPerWin &&
        other.rangeLimit == rangeLimit &&
        other.totalPlayers == totalPlayers;
  }

  @override
  int get hashCode {
    return totalRounds.hashCode ^
        marksPerWin.hashCode ^
        rangeLimit.hashCode ^
        totalPlayers.hashCode;
  }
}
