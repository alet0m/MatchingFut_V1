enum FootballModality {
  futbolito('futbolito', 'Futbolito', '7v7'),
  futbol11('futbol11', 'Fútbol 11', '11v11'),
  babyFutbol('baby_futbol', 'Baby Fútbol', '5v5');

  const FootballModality(this.value, this.displayName, this.format);

  final String value;
  final String displayName;
  final String format;

  /// Configuración de reglas por modalidad
  ModalityRules get rules {
    switch (this) {
      case FootballModality.futbolito:
        return ModalityRules(
          minPlayers: 7,
          maxPlayers: 10,
          fieldPlayers: 7,
          description:
              'Fútbol reducido 7v7. Mínimo 7 jugadores por equipo, máximo 10 (solo 7 en cancha)',
        );
      case FootballModality.futbol11:
        return ModalityRules(
          minPlayers: 11,
          maxPlayers: 22,
          fieldPlayers: 11,
          description: 'Fútbol tradicional 11v11 con reglas oficiales FIFA',
        );
      case FootballModality.babyFutbol:
        return ModalityRules(
          minPlayers: 5,
          maxPlayers: 8,
          fieldPlayers: 5,
          description: 'Fútbol street 5v5 estilo FIFA Street. Rápido y técnico',
        );
    }
  }

  /// Posiciones disponibles por modalidad
  List<PlayerPosition> get availablePositions {
    switch (this) {
      case FootballModality.futbolito:
        return [
          PlayerPosition('POR', 'Portero'),
          PlayerPosition('DEF', 'Defensor'),
          PlayerPosition('MED', 'Mediocampista'),
          PlayerPosition('DEL', 'Delantero'),
          PlayerPosition('LIB', 'Líbero'),
        ];
      case FootballModality.futbol11:
        return [
          PlayerPosition('POR', 'Portero'),
          PlayerPosition('DFC', 'Defensor Central'),
          PlayerPosition('LAT', 'Lateral'),
          PlayerPosition('MCD', 'Mediocampista Defensivo'),
          PlayerPosition('MC', 'Mediocampista'),
          PlayerPosition('MCO', 'Mediocampista Ofensivo'),
          PlayerPosition('EXT', 'Extremo'),
          PlayerPosition('DC', 'Delantero Centro'),
        ];
      case FootballModality.babyFutbol:
        return [
          PlayerPosition('POR', 'Portero'),
          PlayerPosition('DEF', 'Defensor'),
          PlayerPosition('MED', 'Todo Terreno'),
          PlayerPosition('DEL', 'Delantero'),
        ];
    }
  }

  /// Color temático por modalidad
  String get colorHex {
    switch (this) {
      case FootballModality.futbolito:
        return '#2E7D32'; // Verde tradicional
      case FootballModality.futbol11:
        return '#1565C0'; // Azul profesional
      case FootballModality.babyFutbol:
        return '#FF6F00'; // Naranja street
    }
  }

  /// Ícono por modalidad
  String get iconPath {
    switch (this) {
      case FootballModality.futbolito:
        return 'assets/icons/futbolito.png';
      case FootballModality.futbol11:
        return 'assets/icons/futbol11.png';
      case FootballModality.babyFutbol:
        return 'assets/icons/baby_futbol.png';
    }
  }
}

class ModalityRules {
  final int minPlayers;
  final int maxPlayers;
  final int fieldPlayers;
  final String description;

  const ModalityRules({
    required this.minPlayers,
    required this.maxPlayers,
    required this.fieldPlayers,
    required this.description,
  });
}

class PlayerPosition {
  final String code;
  final String name;

  const PlayerPosition(this.code, this.name);
}

enum SkillLevel {
  principiante('principiante', 'Principiante', '⭐'),
  intermedio('intermedio', 'Intermedio', '⭐⭐'),
  avanzado('avanzado', 'Avanzado', '⭐⭐⭐'),
  profesional('profesional', 'Profesional', '⭐⭐⭐⭐');

  const SkillLevel(this.value, this.displayName, this.stars);

  final String value;
  final String displayName;
  final String stars;
}
