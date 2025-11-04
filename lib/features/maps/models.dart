/// Modelos null-safe para el panel de mapas
class Cancha {
  final String id;
  final String nombre;
  final String? fotoUrl; // puede venir null
  final String comuna;

  const Cancha({
    required this.id,
    required this.nombre,
    this.fotoUrl,
    required this.comuna,
  });

  /// Factory para crear desde JSON con null-safety
  factory Cancha.fromJson(Map<String, dynamic> json) {
    return Cancha(
      id: _safeString(json['id']),
      nombre: _safeString(json['nombre']),
      fotoUrl: json['fotoUrl'] as String?,
      comuna: _safeString(json['comuna']),
    );
  }

  Map<String, dynamic> toJson() {
    return {'id': id, 'nombre': nombre, 'fotoUrl': fotoUrl, 'comuna': comuna};
  }
}

class EquipoRank {
  final String id;
  final String nombre;
  final int puntos;
  final String comuna;

  const EquipoRank({
    required this.id,
    required this.nombre,
    required this.puntos,
    required this.comuna,
  });

  /// Factory para crear desde JSON con null-safety
  factory EquipoRank.fromJson(Map<String, dynamic> json) {
    return EquipoRank(
      id: _safeString(json['id']),
      nombre: _safeString(json['nombre']),
      puntos: (json['puntos'] as num?)?.toInt() ?? 0,
      comuna: _safeString(json['comuna']),
    );
  }

  Map<String, dynamic> toJson() {
    return {'id': id, 'nombre': nombre, 'puntos': puntos, 'comuna': comuna};
  }
}

/// Helper para garantizar String no-null desde JSON
String _safeString(Object? value) => (value as String?) ?? '';
