// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'team_elo_model.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
  'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models',
);

TeamEloModel _$TeamEloModelFromJson(Map<String, dynamic> json) {
  return _TeamEloModel.fromJson(json);
}

/// @nodoc
mixin _$TeamEloModel {
  String get id => throw _privateConstructorUsedError;
  String get teamId => throw _privateConstructorUsedError;
  FootballModality get modality => throw _privateConstructorUsedError;
  int get eloRating => throw _privateConstructorUsedError;
  int get matchesPlayed => throw _privateConstructorUsedError;
  int get wins => throw _privateConstructorUsedError;
  int get losses => throw _privateConstructorUsedError;
  int get draws => throw _privateConstructorUsedError;
  int get goalsFor => throw _privateConstructorUsedError;
  int get goalsAgainst => throw _privateConstructorUsedError;
  DateTime? get lastMatchDate => throw _privateConstructorUsedError;
  DateTime? get createdAt => throw _privateConstructorUsedError;
  DateTime? get updatedAt => throw _privateConstructorUsedError;

  /// Serializes this TeamEloModel to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of TeamEloModel
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $TeamEloModelCopyWith<TeamEloModel> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $TeamEloModelCopyWith<$Res> {
  factory $TeamEloModelCopyWith(
    TeamEloModel value,
    $Res Function(TeamEloModel) then,
  ) = _$TeamEloModelCopyWithImpl<$Res, TeamEloModel>;
  @useResult
  $Res call({
    String id,
    String teamId,
    FootballModality modality,
    int eloRating,
    int matchesPlayed,
    int wins,
    int losses,
    int draws,
    int goalsFor,
    int goalsAgainst,
    DateTime? lastMatchDate,
    DateTime? createdAt,
    DateTime? updatedAt,
  });
}

/// @nodoc
class _$TeamEloModelCopyWithImpl<$Res, $Val extends TeamEloModel>
    implements $TeamEloModelCopyWith<$Res> {
  _$TeamEloModelCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of TeamEloModel
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? teamId = null,
    Object? modality = null,
    Object? eloRating = null,
    Object? matchesPlayed = null,
    Object? wins = null,
    Object? losses = null,
    Object? draws = null,
    Object? goalsFor = null,
    Object? goalsAgainst = null,
    Object? lastMatchDate = freezed,
    Object? createdAt = freezed,
    Object? updatedAt = freezed,
  }) {
    return _then(
      _value.copyWith(
            id:
                null == id
                    ? _value.id
                    : id // ignore: cast_nullable_to_non_nullable
                        as String,
            teamId:
                null == teamId
                    ? _value.teamId
                    : teamId // ignore: cast_nullable_to_non_nullable
                        as String,
            modality:
                null == modality
                    ? _value.modality
                    : modality // ignore: cast_nullable_to_non_nullable
                        as FootballModality,
            eloRating:
                null == eloRating
                    ? _value.eloRating
                    : eloRating // ignore: cast_nullable_to_non_nullable
                        as int,
            matchesPlayed:
                null == matchesPlayed
                    ? _value.matchesPlayed
                    : matchesPlayed // ignore: cast_nullable_to_non_nullable
                        as int,
            wins:
                null == wins
                    ? _value.wins
                    : wins // ignore: cast_nullable_to_non_nullable
                        as int,
            losses:
                null == losses
                    ? _value.losses
                    : losses // ignore: cast_nullable_to_non_nullable
                        as int,
            draws:
                null == draws
                    ? _value.draws
                    : draws // ignore: cast_nullable_to_non_nullable
                        as int,
            goalsFor:
                null == goalsFor
                    ? _value.goalsFor
                    : goalsFor // ignore: cast_nullable_to_non_nullable
                        as int,
            goalsAgainst:
                null == goalsAgainst
                    ? _value.goalsAgainst
                    : goalsAgainst // ignore: cast_nullable_to_non_nullable
                        as int,
            lastMatchDate:
                freezed == lastMatchDate
                    ? _value.lastMatchDate
                    : lastMatchDate // ignore: cast_nullable_to_non_nullable
                        as DateTime?,
            createdAt:
                freezed == createdAt
                    ? _value.createdAt
                    : createdAt // ignore: cast_nullable_to_non_nullable
                        as DateTime?,
            updatedAt:
                freezed == updatedAt
                    ? _value.updatedAt
                    : updatedAt // ignore: cast_nullable_to_non_nullable
                        as DateTime?,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$TeamEloModelImplCopyWith<$Res>
    implements $TeamEloModelCopyWith<$Res> {
  factory _$$TeamEloModelImplCopyWith(
    _$TeamEloModelImpl value,
    $Res Function(_$TeamEloModelImpl) then,
  ) = __$$TeamEloModelImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    String id,
    String teamId,
    FootballModality modality,
    int eloRating,
    int matchesPlayed,
    int wins,
    int losses,
    int draws,
    int goalsFor,
    int goalsAgainst,
    DateTime? lastMatchDate,
    DateTime? createdAt,
    DateTime? updatedAt,
  });
}

/// @nodoc
class __$$TeamEloModelImplCopyWithImpl<$Res>
    extends _$TeamEloModelCopyWithImpl<$Res, _$TeamEloModelImpl>
    implements _$$TeamEloModelImplCopyWith<$Res> {
  __$$TeamEloModelImplCopyWithImpl(
    _$TeamEloModelImpl _value,
    $Res Function(_$TeamEloModelImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of TeamEloModel
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? teamId = null,
    Object? modality = null,
    Object? eloRating = null,
    Object? matchesPlayed = null,
    Object? wins = null,
    Object? losses = null,
    Object? draws = null,
    Object? goalsFor = null,
    Object? goalsAgainst = null,
    Object? lastMatchDate = freezed,
    Object? createdAt = freezed,
    Object? updatedAt = freezed,
  }) {
    return _then(
      _$TeamEloModelImpl(
        id:
            null == id
                ? _value.id
                : id // ignore: cast_nullable_to_non_nullable
                    as String,
        teamId:
            null == teamId
                ? _value.teamId
                : teamId // ignore: cast_nullable_to_non_nullable
                    as String,
        modality:
            null == modality
                ? _value.modality
                : modality // ignore: cast_nullable_to_non_nullable
                    as FootballModality,
        eloRating:
            null == eloRating
                ? _value.eloRating
                : eloRating // ignore: cast_nullable_to_non_nullable
                    as int,
        matchesPlayed:
            null == matchesPlayed
                ? _value.matchesPlayed
                : matchesPlayed // ignore: cast_nullable_to_non_nullable
                    as int,
        wins:
            null == wins
                ? _value.wins
                : wins // ignore: cast_nullable_to_non_nullable
                    as int,
        losses:
            null == losses
                ? _value.losses
                : losses // ignore: cast_nullable_to_non_nullable
                    as int,
        draws:
            null == draws
                ? _value.draws
                : draws // ignore: cast_nullable_to_non_nullable
                    as int,
        goalsFor:
            null == goalsFor
                ? _value.goalsFor
                : goalsFor // ignore: cast_nullable_to_non_nullable
                    as int,
        goalsAgainst:
            null == goalsAgainst
                ? _value.goalsAgainst
                : goalsAgainst // ignore: cast_nullable_to_non_nullable
                    as int,
        lastMatchDate:
            freezed == lastMatchDate
                ? _value.lastMatchDate
                : lastMatchDate // ignore: cast_nullable_to_non_nullable
                    as DateTime?,
        createdAt:
            freezed == createdAt
                ? _value.createdAt
                : createdAt // ignore: cast_nullable_to_non_nullable
                    as DateTime?,
        updatedAt:
            freezed == updatedAt
                ? _value.updatedAt
                : updatedAt // ignore: cast_nullable_to_non_nullable
                    as DateTime?,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$TeamEloModelImpl implements _TeamEloModel {
  const _$TeamEloModelImpl({
    required this.id,
    required this.teamId,
    required this.modality,
    this.eloRating = 1200,
    this.matchesPlayed = 0,
    this.wins = 0,
    this.losses = 0,
    this.draws = 0,
    this.goalsFor = 0,
    this.goalsAgainst = 0,
    this.lastMatchDate,
    this.createdAt,
    this.updatedAt,
  });

  factory _$TeamEloModelImpl.fromJson(Map<String, dynamic> json) =>
      _$$TeamEloModelImplFromJson(json);

  @override
  final String id;
  @override
  final String teamId;
  @override
  final FootballModality modality;
  @override
  @JsonKey()
  final int eloRating;
  @override
  @JsonKey()
  final int matchesPlayed;
  @override
  @JsonKey()
  final int wins;
  @override
  @JsonKey()
  final int losses;
  @override
  @JsonKey()
  final int draws;
  @override
  @JsonKey()
  final int goalsFor;
  @override
  @JsonKey()
  final int goalsAgainst;
  @override
  final DateTime? lastMatchDate;
  @override
  final DateTime? createdAt;
  @override
  final DateTime? updatedAt;

  @override
  String toString() {
    return 'TeamEloModel(id: $id, teamId: $teamId, modality: $modality, eloRating: $eloRating, matchesPlayed: $matchesPlayed, wins: $wins, losses: $losses, draws: $draws, goalsFor: $goalsFor, goalsAgainst: $goalsAgainst, lastMatchDate: $lastMatchDate, createdAt: $createdAt, updatedAt: $updatedAt)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$TeamEloModelImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.teamId, teamId) || other.teamId == teamId) &&
            (identical(other.modality, modality) ||
                other.modality == modality) &&
            (identical(other.eloRating, eloRating) ||
                other.eloRating == eloRating) &&
            (identical(other.matchesPlayed, matchesPlayed) ||
                other.matchesPlayed == matchesPlayed) &&
            (identical(other.wins, wins) || other.wins == wins) &&
            (identical(other.losses, losses) || other.losses == losses) &&
            (identical(other.draws, draws) || other.draws == draws) &&
            (identical(other.goalsFor, goalsFor) ||
                other.goalsFor == goalsFor) &&
            (identical(other.goalsAgainst, goalsAgainst) ||
                other.goalsAgainst == goalsAgainst) &&
            (identical(other.lastMatchDate, lastMatchDate) ||
                other.lastMatchDate == lastMatchDate) &&
            (identical(other.createdAt, createdAt) ||
                other.createdAt == createdAt) &&
            (identical(other.updatedAt, updatedAt) ||
                other.updatedAt == updatedAt));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
    runtimeType,
    id,
    teamId,
    modality,
    eloRating,
    matchesPlayed,
    wins,
    losses,
    draws,
    goalsFor,
    goalsAgainst,
    lastMatchDate,
    createdAt,
    updatedAt,
  );

  /// Create a copy of TeamEloModel
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$TeamEloModelImplCopyWith<_$TeamEloModelImpl> get copyWith =>
      __$$TeamEloModelImplCopyWithImpl<_$TeamEloModelImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$TeamEloModelImplToJson(this);
  }
}

abstract class _TeamEloModel implements TeamEloModel {
  const factory _TeamEloModel({
    required final String id,
    required final String teamId,
    required final FootballModality modality,
    final int eloRating,
    final int matchesPlayed,
    final int wins,
    final int losses,
    final int draws,
    final int goalsFor,
    final int goalsAgainst,
    final DateTime? lastMatchDate,
    final DateTime? createdAt,
    final DateTime? updatedAt,
  }) = _$TeamEloModelImpl;

  factory _TeamEloModel.fromJson(Map<String, dynamic> json) =
      _$TeamEloModelImpl.fromJson;

  @override
  String get id;
  @override
  String get teamId;
  @override
  FootballModality get modality;
  @override
  int get eloRating;
  @override
  int get matchesPlayed;
  @override
  int get wins;
  @override
  int get losses;
  @override
  int get draws;
  @override
  int get goalsFor;
  @override
  int get goalsAgainst;
  @override
  DateTime? get lastMatchDate;
  @override
  DateTime? get createdAt;
  @override
  DateTime? get updatedAt;

  /// Create a copy of TeamEloModel
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$TeamEloModelImplCopyWith<_$TeamEloModelImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

PlayerModalityStats _$PlayerModalityStatsFromJson(Map<String, dynamic> json) {
  return _PlayerModalityStats.fromJson(json);
}

/// @nodoc
mixin _$PlayerModalityStats {
  String get id => throw _privateConstructorUsedError;
  String get userId => throw _privateConstructorUsedError;
  FootballModality get modality => throw _privateConstructorUsedError;
  SkillLevel get skillLevel => throw _privateConstructorUsedError;
  String? get preferredPosition => throw _privateConstructorUsedError;
  int get matchesPlayed => throw _privateConstructorUsedError;
  int get goals => throw _privateConstructorUsedError;
  int get assists => throw _privateConstructorUsedError;
  double get ratingAvg => throw _privateConstructorUsedError;
  bool get isActive => throw _privateConstructorUsedError;
  DateTime? get createdAt => throw _privateConstructorUsedError;
  DateTime? get updatedAt => throw _privateConstructorUsedError;

  /// Serializes this PlayerModalityStats to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of PlayerModalityStats
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $PlayerModalityStatsCopyWith<PlayerModalityStats> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $PlayerModalityStatsCopyWith<$Res> {
  factory $PlayerModalityStatsCopyWith(
    PlayerModalityStats value,
    $Res Function(PlayerModalityStats) then,
  ) = _$PlayerModalityStatsCopyWithImpl<$Res, PlayerModalityStats>;
  @useResult
  $Res call({
    String id,
    String userId,
    FootballModality modality,
    SkillLevel skillLevel,
    String? preferredPosition,
    int matchesPlayed,
    int goals,
    int assists,
    double ratingAvg,
    bool isActive,
    DateTime? createdAt,
    DateTime? updatedAt,
  });
}

/// @nodoc
class _$PlayerModalityStatsCopyWithImpl<$Res, $Val extends PlayerModalityStats>
    implements $PlayerModalityStatsCopyWith<$Res> {
  _$PlayerModalityStatsCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of PlayerModalityStats
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? userId = null,
    Object? modality = null,
    Object? skillLevel = null,
    Object? preferredPosition = freezed,
    Object? matchesPlayed = null,
    Object? goals = null,
    Object? assists = null,
    Object? ratingAvg = null,
    Object? isActive = null,
    Object? createdAt = freezed,
    Object? updatedAt = freezed,
  }) {
    return _then(
      _value.copyWith(
            id:
                null == id
                    ? _value.id
                    : id // ignore: cast_nullable_to_non_nullable
                        as String,
            userId:
                null == userId
                    ? _value.userId
                    : userId // ignore: cast_nullable_to_non_nullable
                        as String,
            modality:
                null == modality
                    ? _value.modality
                    : modality // ignore: cast_nullable_to_non_nullable
                        as FootballModality,
            skillLevel:
                null == skillLevel
                    ? _value.skillLevel
                    : skillLevel // ignore: cast_nullable_to_non_nullable
                        as SkillLevel,
            preferredPosition:
                freezed == preferredPosition
                    ? _value.preferredPosition
                    : preferredPosition // ignore: cast_nullable_to_non_nullable
                        as String?,
            matchesPlayed:
                null == matchesPlayed
                    ? _value.matchesPlayed
                    : matchesPlayed // ignore: cast_nullable_to_non_nullable
                        as int,
            goals:
                null == goals
                    ? _value.goals
                    : goals // ignore: cast_nullable_to_non_nullable
                        as int,
            assists:
                null == assists
                    ? _value.assists
                    : assists // ignore: cast_nullable_to_non_nullable
                        as int,
            ratingAvg:
                null == ratingAvg
                    ? _value.ratingAvg
                    : ratingAvg // ignore: cast_nullable_to_non_nullable
                        as double,
            isActive:
                null == isActive
                    ? _value.isActive
                    : isActive // ignore: cast_nullable_to_non_nullable
                        as bool,
            createdAt:
                freezed == createdAt
                    ? _value.createdAt
                    : createdAt // ignore: cast_nullable_to_non_nullable
                        as DateTime?,
            updatedAt:
                freezed == updatedAt
                    ? _value.updatedAt
                    : updatedAt // ignore: cast_nullable_to_non_nullable
                        as DateTime?,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$PlayerModalityStatsImplCopyWith<$Res>
    implements $PlayerModalityStatsCopyWith<$Res> {
  factory _$$PlayerModalityStatsImplCopyWith(
    _$PlayerModalityStatsImpl value,
    $Res Function(_$PlayerModalityStatsImpl) then,
  ) = __$$PlayerModalityStatsImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    String id,
    String userId,
    FootballModality modality,
    SkillLevel skillLevel,
    String? preferredPosition,
    int matchesPlayed,
    int goals,
    int assists,
    double ratingAvg,
    bool isActive,
    DateTime? createdAt,
    DateTime? updatedAt,
  });
}

/// @nodoc
class __$$PlayerModalityStatsImplCopyWithImpl<$Res>
    extends _$PlayerModalityStatsCopyWithImpl<$Res, _$PlayerModalityStatsImpl>
    implements _$$PlayerModalityStatsImplCopyWith<$Res> {
  __$$PlayerModalityStatsImplCopyWithImpl(
    _$PlayerModalityStatsImpl _value,
    $Res Function(_$PlayerModalityStatsImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of PlayerModalityStats
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? userId = null,
    Object? modality = null,
    Object? skillLevel = null,
    Object? preferredPosition = freezed,
    Object? matchesPlayed = null,
    Object? goals = null,
    Object? assists = null,
    Object? ratingAvg = null,
    Object? isActive = null,
    Object? createdAt = freezed,
    Object? updatedAt = freezed,
  }) {
    return _then(
      _$PlayerModalityStatsImpl(
        id:
            null == id
                ? _value.id
                : id // ignore: cast_nullable_to_non_nullable
                    as String,
        userId:
            null == userId
                ? _value.userId
                : userId // ignore: cast_nullable_to_non_nullable
                    as String,
        modality:
            null == modality
                ? _value.modality
                : modality // ignore: cast_nullable_to_non_nullable
                    as FootballModality,
        skillLevel:
            null == skillLevel
                ? _value.skillLevel
                : skillLevel // ignore: cast_nullable_to_non_nullable
                    as SkillLevel,
        preferredPosition:
            freezed == preferredPosition
                ? _value.preferredPosition
                : preferredPosition // ignore: cast_nullable_to_non_nullable
                    as String?,
        matchesPlayed:
            null == matchesPlayed
                ? _value.matchesPlayed
                : matchesPlayed // ignore: cast_nullable_to_non_nullable
                    as int,
        goals:
            null == goals
                ? _value.goals
                : goals // ignore: cast_nullable_to_non_nullable
                    as int,
        assists:
            null == assists
                ? _value.assists
                : assists // ignore: cast_nullable_to_non_nullable
                    as int,
        ratingAvg:
            null == ratingAvg
                ? _value.ratingAvg
                : ratingAvg // ignore: cast_nullable_to_non_nullable
                    as double,
        isActive:
            null == isActive
                ? _value.isActive
                : isActive // ignore: cast_nullable_to_non_nullable
                    as bool,
        createdAt:
            freezed == createdAt
                ? _value.createdAt
                : createdAt // ignore: cast_nullable_to_non_nullable
                    as DateTime?,
        updatedAt:
            freezed == updatedAt
                ? _value.updatedAt
                : updatedAt // ignore: cast_nullable_to_non_nullable
                    as DateTime?,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$PlayerModalityStatsImpl implements _PlayerModalityStats {
  const _$PlayerModalityStatsImpl({
    required this.id,
    required this.userId,
    required this.modality,
    this.skillLevel = SkillLevel.principiante,
    this.preferredPosition,
    this.matchesPlayed = 0,
    this.goals = 0,
    this.assists = 0,
    this.ratingAvg = 0.0,
    this.isActive = true,
    this.createdAt,
    this.updatedAt,
  });

  factory _$PlayerModalityStatsImpl.fromJson(Map<String, dynamic> json) =>
      _$$PlayerModalityStatsImplFromJson(json);

  @override
  final String id;
  @override
  final String userId;
  @override
  final FootballModality modality;
  @override
  @JsonKey()
  final SkillLevel skillLevel;
  @override
  final String? preferredPosition;
  @override
  @JsonKey()
  final int matchesPlayed;
  @override
  @JsonKey()
  final int goals;
  @override
  @JsonKey()
  final int assists;
  @override
  @JsonKey()
  final double ratingAvg;
  @override
  @JsonKey()
  final bool isActive;
  @override
  final DateTime? createdAt;
  @override
  final DateTime? updatedAt;

  @override
  String toString() {
    return 'PlayerModalityStats(id: $id, userId: $userId, modality: $modality, skillLevel: $skillLevel, preferredPosition: $preferredPosition, matchesPlayed: $matchesPlayed, goals: $goals, assists: $assists, ratingAvg: $ratingAvg, isActive: $isActive, createdAt: $createdAt, updatedAt: $updatedAt)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$PlayerModalityStatsImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.userId, userId) || other.userId == userId) &&
            (identical(other.modality, modality) ||
                other.modality == modality) &&
            (identical(other.skillLevel, skillLevel) ||
                other.skillLevel == skillLevel) &&
            (identical(other.preferredPosition, preferredPosition) ||
                other.preferredPosition == preferredPosition) &&
            (identical(other.matchesPlayed, matchesPlayed) ||
                other.matchesPlayed == matchesPlayed) &&
            (identical(other.goals, goals) || other.goals == goals) &&
            (identical(other.assists, assists) || other.assists == assists) &&
            (identical(other.ratingAvg, ratingAvg) ||
                other.ratingAvg == ratingAvg) &&
            (identical(other.isActive, isActive) ||
                other.isActive == isActive) &&
            (identical(other.createdAt, createdAt) ||
                other.createdAt == createdAt) &&
            (identical(other.updatedAt, updatedAt) ||
                other.updatedAt == updatedAt));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
    runtimeType,
    id,
    userId,
    modality,
    skillLevel,
    preferredPosition,
    matchesPlayed,
    goals,
    assists,
    ratingAvg,
    isActive,
    createdAt,
    updatedAt,
  );

  /// Create a copy of PlayerModalityStats
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$PlayerModalityStatsImplCopyWith<_$PlayerModalityStatsImpl> get copyWith =>
      __$$PlayerModalityStatsImplCopyWithImpl<_$PlayerModalityStatsImpl>(
        this,
        _$identity,
      );

  @override
  Map<String, dynamic> toJson() {
    return _$$PlayerModalityStatsImplToJson(this);
  }
}

abstract class _PlayerModalityStats implements PlayerModalityStats {
  const factory _PlayerModalityStats({
    required final String id,
    required final String userId,
    required final FootballModality modality,
    final SkillLevel skillLevel,
    final String? preferredPosition,
    final int matchesPlayed,
    final int goals,
    final int assists,
    final double ratingAvg,
    final bool isActive,
    final DateTime? createdAt,
    final DateTime? updatedAt,
  }) = _$PlayerModalityStatsImpl;

  factory _PlayerModalityStats.fromJson(Map<String, dynamic> json) =
      _$PlayerModalityStatsImpl.fromJson;

  @override
  String get id;
  @override
  String get userId;
  @override
  FootballModality get modality;
  @override
  SkillLevel get skillLevel;
  @override
  String? get preferredPosition;
  @override
  int get matchesPlayed;
  @override
  int get goals;
  @override
  int get assists;
  @override
  double get ratingAvg;
  @override
  bool get isActive;
  @override
  DateTime? get createdAt;
  @override
  DateTime? get updatedAt;

  /// Create a copy of PlayerModalityStats
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$PlayerModalityStatsImplCopyWith<_$PlayerModalityStatsImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
