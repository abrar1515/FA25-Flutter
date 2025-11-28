/// Round model class for managing round data
/// Contains round information and game state
class RoundModel {
  final int? id;
  final int roundNumber;
  final int hiddenBy;
  final int? winnerId;
  final int numberToGuess;

  const RoundModel({
    this.id,
    required this.roundNumber,
    required this.hiddenBy,
    this.winnerId,
    required this.numberToGuess,
  });

  /// Create RoundModel from database map
  factory RoundModel.fromMap(Map<String, dynamic> map) {
    return RoundModel(
      id: map['id']?.toInt(),
      roundNumber: map['round_number']?.toInt() ?? 0,
      hiddenBy: map['hidden_by']?.toInt() ?? 0,
      winnerId: map['winner_id']?.toInt(),
      numberToGuess: map['number_to_guess']?.toInt() ?? 0,
    );
  }

  /// Convert RoundModel to database map
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'round_number': roundNumber,
      'hidden_by': hiddenBy,
      'winner_id': winnerId,
      'number_to_guess': numberToGuess,
    };
  }

  /// Create a copy of RoundModel with updated fields
  RoundModel copyWith({
    int? id,
    int? roundNumber,
    int? hiddenBy,
    int? winnerId,
    int? numberToGuess,
  }) {
    return RoundModel(
      id: id ?? this.id,
      roundNumber: roundNumber ?? this.roundNumber,
      hiddenBy: hiddenBy ?? this.hiddenBy,
      winnerId: winnerId ?? this.winnerId,
      numberToGuess: numberToGuess ?? this.numberToGuess,
    );
  }

  @override
  String toString() {
    return 'RoundModel(id: $id, roundNumber: $roundNumber, hiddenBy: $hiddenBy, winnerId: $winnerId, numberToGuess: $numberToGuess)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is RoundModel &&
        other.id == id &&
        other.roundNumber == roundNumber &&
        other.hiddenBy == hiddenBy &&
        other.winnerId == winnerId &&
        other.numberToGuess == numberToGuess;
  }

  @override
  int get hashCode {
    return id.hashCode ^
        roundNumber.hashCode ^
        hiddenBy.hashCode ^
        winnerId.hashCode ^
        numberToGuess.hashCode;
  }
}
