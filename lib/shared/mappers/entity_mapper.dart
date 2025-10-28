
/// Clase que contiene métodos estáticos para mapear entidades de la base de datos a modelos de Flutter
class EntityMapper {
  // Mapper para Region
  static Map<String, dynamic> mapRegionFromDatabase(
    Map<String, dynamic> dbRegion,
  ) {
    return {
      'id': dbRegion['id'],
      'name': dbRegion['name'] ?? '',
      'code': dbRegion['code'] ?? '',
      'ordinal': dbRegion['ordinal'] ?? 0,
      'isActive': dbRegion['is_active'] ?? false,
    };
  }

  // Mapper para Comuna
  static Map<String, dynamic> mapComunaFromDatabase(
    Map<String, dynamic> dbComuna,
  ) {
    return {
      'id': dbComuna['id'] ?? '',
      'name': dbComuna['name'] ?? '',
      'regionId': dbComuna['region_id'] ?? 0,
      'code': dbComuna['code'] ?? '',
      'isActive': dbComuna['is_active'] ?? false,
      'description': dbComuna['description'],
      'featuredImageUrl': dbComuna['featured_image_url'],
      'totalPlayers': dbComuna['total_players'] ?? 0,
      'totalTeams': dbComuna['total_teams'] ?? 0,
      'totalMatches': dbComuna['total_matches'] ?? 0,
    };
  }

  // Mapper para Sector
  static Map<String, dynamic> mapSectorFromDatabase(
    Map<String, dynamic> dbSector,
  ) {
    return {
      'id': dbSector['id'] ?? '',
      'name': dbSector['name'] ?? '',
      'comunaId': dbSector['comuna_id'] ?? '',
      'description': dbSector['description'],
      'controllingTeamId': dbSector['controlling_team_id'],
      'eloRequired': dbSector['elo_required'] ?? 1200,
      'currentEloThreshold': dbSector['current_elo_threshold'] ?? 1200,
      'totalMatches': dbSector['total_matches'] ?? 0,
      'lastMatchDate':
          dbSector['last_match_date'] != null
              ? DateTime.parse(dbSector['last_match_date'])
              : null,
      'controlStartDate':
          dbSector['control_start_date'] != null
              ? DateTime.parse(dbSector['control_start_date'])
              : null,
      'featuredImageUrl': dbSector['featured_image_url'],
      'isActive': dbSector['is_active'] ?? true,
      'createdAt':
          dbSector['created_at'] != null
              ? DateTime.parse(dbSector['created_at'])
              : null,
      'updatedAt':
          dbSector['updated_at'] != null
              ? DateTime.parse(dbSector['updated_at'])
              : null,
    };
  }

  // Mapper para Team
  static Map<String, dynamic> mapTeamFromDatabase(Map<String, dynamic> dbTeam) {
    return {
      'id': dbTeam['id'] ?? '',
      'name': dbTeam['name'] ?? '',
      'tag': dbTeam['tag'],
      'captainId': dbTeam['captain_id'],
      'comunaId': dbTeam['comuna_id'],
      'modalityId': dbTeam['modality_id'],
      'isActive': dbTeam['is_active'] ?? true,
      'maxMembers': dbTeam['max_members'] ?? 15,
      'homeColor': dbTeam['home_color'] ?? '#2E7D32',
      'awayColor': dbTeam['away_color'] ?? '#FFFFFF',
      'eloRating': dbTeam['elo_rating'] ?? 1200,
      'totalMatches': dbTeam['total_matches'] ?? 0,
      'wins': dbTeam['wins'] ?? 0,
      'losses': dbTeam['losses'] ?? 0,
      'draws': dbTeam['draws'] ?? 0,
      'logoUrl': dbTeam['logo_url'],
      'description': dbTeam['description'],
      'createdAt':
          dbTeam['created_at'] != null
              ? DateTime.parse(dbTeam['created_at'])
              : null,
      'updatedAt':
          dbTeam['updated_at'] != null
              ? DateTime.parse(dbTeam['updated_at'])
              : null,
    };
  }

  // Mapper para SectorControlHistory
  static Map<String, dynamic> mapControlHistoryFromDatabase(
    Map<String, dynamic> dbControl,
  ) {
    return {
      'id': dbControl['id'] ?? '',
      'sectorId': dbControl['sector_id'] ?? '',
      'teamId': dbControl['team_id'] ?? '',
      'controlStart':
          dbControl['control_start'] != null
              ? DateTime.parse(dbControl['control_start'])
              : DateTime.now(),
      'controlEnd':
          dbControl['control_end'] != null
              ? DateTime.parse(dbControl['control_end'])
              : null,
      'eloAtStart': dbControl['elo_at_start'],
      'eloAtEnd': dbControl['elo_at_end'],
      'totalDays': dbControl['total_days'],
      'matchId': dbControl['match_id'],
      'lossMatchId': dbControl['loss_match_id'],
      'createdAt':
          dbControl['created_at'] != null
              ? DateTime.parse(dbControl['created_at'])
              : DateTime.now(),
    };
  }

  // Mapper para FootballModality
  static Map<String, dynamic> mapModalityFromDatabase(
    Map<String, dynamic> dbModality,
  ) {
    return {
      'id': dbModality['id'] ?? 0,
      'name': dbModality['name'] ?? '',
      'code': dbModality['code'] ?? '',
      'playersPerTeam': dbModality['players_per_team'] ?? 0,
      'minPlayers': dbModality['min_players'] ?? 0,
      'maxPlayers': dbModality['max_players'] ?? 0,
      'fieldPlayers': dbModality['field_players'] ?? 0,
      'description': dbModality['description'],
      'colorHex': dbModality['color_hex'],
    };
  }
}
