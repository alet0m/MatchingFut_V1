import 'package:freezed_annotation/freezed_annotation.dart';

part 'match_event_model.freezed.dart';
part 'match_event_model.g.dart';

@freezed
class MatchEvent with _$MatchEvent {
  const factory MatchEvent({
    required String id,
    required String matchId,
    required String
    eventType, // 'goal', 'yellow_card', 'red_card', 'substitution', etc.
    String? playerId,
    required String teamId,
    required int minute,
    String? description,
    Map<String, dynamic>? extraData,
    required DateTime createdAt,
  }) = _MatchEvent;

  factory MatchEvent.fromJson(Map<String, dynamic> json) =>
      _$MatchEventFromJson(json);
}
