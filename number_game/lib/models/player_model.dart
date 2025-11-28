/// Player model class for managing player data
/// Contains player information and score management
class PlayerModel {
  final int? id;
  final String name;
  final int totalScore;

  const PlayerModel({
    this.id,
    required this.name,
    this.totalScore = 0,
  });

  /// Create PlayerModel from database map
  factory PlayerModel.fromMap(Map<String, dynamic> map) {
    return PlayerModel(
      id: map['id']?.toInt(),
      name: map['name'] ?? '',
      totalScore: map['total_score']?.toInt() ?? 0,
    );
  }

  /// Convert PlayerModel to database map
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'total_score': totalScore,
    };
  }

  /// Create a copy of PlayerModel with updated fields
  PlayerModel copyWith({
    int? id,
    String? name,
    int? totalScore,
  }) {
    return PlayerModel(
      id: id ?? this.id,
      name: name ?? this.name,
      totalScore: totalScore ?? this.totalScore,
    );
  }

  @override
  String toString() {
    return 'PlayerModel(id: $id, name: $name, totalScore: $totalScore)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is PlayerModel &&
        other.id == id &&
        other.name == name &&
        other.totalScore == totalScore;
  }

  @override
  int get hashCode {
    return id.hashCode ^ name.hashCode ^ totalScore.hashCode;
  }
}
