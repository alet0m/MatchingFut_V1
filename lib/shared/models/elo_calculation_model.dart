class EloCalculationModel {
  final double baseElo;
  final MatchTypeMultiplier matchType;
  final double firstTimeBonus;
  final double diversityBonus;
  final double finalElo;
  final List<EloBonus> appliedBonuses;

  const EloCalculationModel({
    required this.baseElo,
    required this.matchType,
    this.firstTimeBonus = 0,
    this.diversityBonus = 0,
    required this.finalElo,
    required this.appliedBonuses,
  });

  factory EloCalculationModel.fromJson(Map<String, dynamic> json) {
    return EloCalculationModel(
      baseElo: (json['baseElo'] as num).toDouble(),
      matchType: MatchTypeMultiplier.values.firstWhere(
        (e) => e.toString().split('.').last == json['matchType'],
      ),
      firstTimeBonus: (json['firstTimeBonus'] as num?)?.toDouble() ?? 0,
      diversityBonus: (json['diversityBonus'] as num?)?.toDouble() ?? 0,
      finalElo: (json['finalElo'] as num).toDouble(),
      appliedBonuses:
          (json['appliedBonuses'] as List)
              .map((bonus) => EloBonus.fromJson(bonus))
              .toList(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'baseElo': baseElo,
      'matchType': matchType.toString().split('.').last,
      'firstTimeBonus': firstTimeBonus,
      'diversityBonus': diversityBonus,
      'finalElo': finalElo,
      'appliedBonuses': appliedBonuses.map((bonus) => bonus.toJson()).toList(),
    };
  }
}

class EloBonus {
  final String type;
  final String description;
  final double multiplier;
  final double additionalPoints;

  const EloBonus({
    required this.type,
    required this.description,
    required this.multiplier,
    required this.additionalPoints,
  });

  factory EloBonus.fromJson(Map<String, dynamic> json) {
    return EloBonus(
      type: json['type'] as String,
      description: json['description'] as String,
      multiplier: (json['multiplier'] as num).toDouble(),
      additionalPoints: (json['additionalPoints'] as num).toDouble(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'type': type,
      'description': description,
      'multiplier': multiplier,
      'additionalPoints': additionalPoints,
    };
  }
}

enum MatchTypeMultiplier {
  directChallenge(0.8, 'Desafío Directo'),
  publicMatch(1.0, 'Partido Público'),
  tournament(1.2, 'Torneo');

  const MatchTypeMultiplier(this.multiplier, this.displayName);

  final double multiplier;
  final String displayName;
}

/// Clase utilitaria para calcular ELO con bonuses
class EloCalculator {
  static const double FIRST_TIME_BONUS = 0.2; // +20%
  static const double DIVERSITY_BONUS_PER_TEAM =
      0.02; // +2% por cada equipo único
  static const double MAX_DIVERSITY_BONUS = 0.1; // Máximo 10% bonus

  /// Calcula el ELO final considerando todos los bonuses
  static EloCalculationModel calculateElo({
    required double baseEloGain,
    required MatchTypeMultiplier matchType,
    required bool isFirstTimeOpponent,
    required int uniqueOpponentsCount,
    Map<String, dynamic>? additionalBonuses,
  }) {
    double finalElo = baseEloGain;
    List<EloBonus> appliedBonuses = [];

    // 1. Aplicar multiplicador de tipo de partido
    finalElo *= matchType.multiplier;
    appliedBonuses.add(
      EloBonus(
        type: 'match_type',
        description: '${matchType.displayName} (x${matchType.multiplier})',
        multiplier: matchType.multiplier,
        additionalPoints: 0,
      ),
    );

    // 2. Bonus por primera vez enfrentando al equipo
    double firstTimeBonus = 0;
    if (isFirstTimeOpponent) {
      firstTimeBonus = baseEloGain * FIRST_TIME_BONUS;
      finalElo += firstTimeBonus;
      appliedBonuses.add(
        EloBonus(
          type: 'first_time',
          description:
              'Primera vez vs este equipo (+${(FIRST_TIME_BONUS * 100).toInt()}%)',
          multiplier: 1.0,
          additionalPoints: firstTimeBonus,
        ),
      );
    }

    // 3. Bonus por diversidad de equipos enfrentados
    double diversityBonus = 0;
    if (uniqueOpponentsCount > 5) {
      double calculatedBonus =
          (uniqueOpponentsCount - 5) * DIVERSITY_BONUS_PER_TEAM;
      diversityBonus =
          baseEloGain * calculatedBonus.clamp(0, MAX_DIVERSITY_BONUS);
      finalElo += diversityBonus;
      appliedBonuses.add(
        EloBonus(
          type: 'diversity',
          description:
              'Diversidad de rivales (+${(calculatedBonus * 100).clamp(0, MAX_DIVERSITY_BONUS * 100).toInt()}%)',
          multiplier: 1.0,
          additionalPoints: diversityBonus,
        ),
      );
    }

    // 4. Bonuses adicionales personalizados
    if (additionalBonuses != null) {
      additionalBonuses.forEach((key, bonus) {
        if (bonus is Map<String, dynamic> &&
            bonus.containsKey('points') &&
            bonus.containsKey('description')) {
          double bonusPoints = (bonus['points'] as num).toDouble();
          finalElo += bonusPoints;
          appliedBonuses.add(
            EloBonus(
              type: key,
              description: bonus['description'] as String,
              multiplier: 1.0,
              additionalPoints: bonusPoints,
            ),
          );
        }
      });
    }

    return EloCalculationModel(
      baseElo: baseEloGain,
      matchType: matchType,
      firstTimeBonus: firstTimeBonus,
      diversityBonus: diversityBonus,
      finalElo: finalElo,
      appliedBonuses: appliedBonuses,
    );
  }

  /// Obtiene una explicación textual de cómo se calculó el ELO
  static String getCalculationExplanation(EloCalculationModel calculation) {
    StringBuffer explanation = StringBuffer();
    explanation.writeln('📊 Cálculo de ELO:');
    explanation.writeln(
      '• Base: ${calculation.baseElo.toStringAsFixed(1)} pts',
    );

    for (EloBonus bonus in calculation.appliedBonuses) {
      if (bonus.multiplier != 1.0) {
        explanation.writeln('• ${bonus.description}');
      } else if (bonus.additionalPoints > 0) {
        explanation.writeln(
          '• ${bonus.description}: +${bonus.additionalPoints.toStringAsFixed(1)} pts',
        );
      }
    }

    explanation.writeln(
      '🏆 Total: ${calculation.finalElo.toStringAsFixed(1)} pts',
    );
    return explanation.toString();
  }

  /// Determina qué bonuses están disponibles para un partido
  static List<String> getAvailableBonuses({
    required MatchTypeMultiplier matchType,
    required bool isFirstTimeOpponent,
    required int uniqueOpponentsCount,
  }) {
    List<String> bonuses = [];

    if (matchType == MatchTypeMultiplier.publicMatch) {
      bonuses.add('ELO completo (x1.0)');
    } else if (matchType == MatchTypeMultiplier.directChallenge) {
      bonuses.add('ELO reducido (x0.8)');
    }

    if (isFirstTimeOpponent) {
      bonuses.add('+20% bonus primera vez');
    }

    if (uniqueOpponentsCount > 5) {
      int bonusPercent = ((uniqueOpponentsCount - 5) * 2).clamp(0, 10);
      bonuses.add('+$bonusPercent% bonus diversidad');
    }

    return bonuses;
  }
}
