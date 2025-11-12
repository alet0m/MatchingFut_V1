// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'team_model.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
  'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models',
);

TeamModel _$TeamModelFromJson(Map<String, dynamic> json) {
  return _TeamModel.fromJson(json);
}

/// @nodoc
mixin _$TeamModel {
  String get id => throw _privateConstructorUsedError;
  String get name => throw _privateConstructorUsedError;
  String? get tag => throw _privateConstructorUsedError;
  String? get captainId => throw _privateConstructorUsedError;
  String? get sectorId => throw _privateConstructorUsedError;
  String? get comunaId =>
      throw _privateConstructorUsedError; // ✅ Coincidir con base de datos
  FootballModality get modality => throw _privateConstructorUsedError;
  int get eloRating =>
      throw _privateConstructorUsedError; // ✅ Coincidir con base de datos (no averageElo)
  // Puntos de liga acumulados (ranking principal)
  int get leaguePoints =>
      throw _privateConstructorUsedError; // Tier/slug de la liga (pichanga, barrio, etc.)
  String? get leagueTier => throw _privateConstructorUsedError;
  int get totalMatches => throw _privateConstructorUsedError;
  int get wins => throw _privateConstructorUsedError;
  int get losses => throw _privateConstructorUsedError;
  int get draws => throw _privateConstructorUsedError;
  DateTime? get createdAt => throw _privateConstructorUsedError;

  /// Serializes this TeamModel to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of TeamModel
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $TeamModelCopyWith<TeamModel> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $TeamModelCopyWith<$Res> {
  factory $TeamModelCopyWith(TeamModel value, $Res Function(TeamModel) then) =
      _$TeamModelCopyWithImpl<$Res, TeamModel>;
  @useResult
  $Res call({
    String id,
    String name,
    String? tag,
    String? captainId,
    String? sectorId,
    String? comunaId,
    FootballModality modality,
    int eloRating,
    int leaguePoints,
    String? leagueTier,
    int totalMatches,
    int wins,
    int losses,
    int draws,
    DateTime? createdAt,
  });
}

/// @nodoc
class _$TeamModelCopyWithImpl<$Res, $Val extends TeamModel>
    implements $TeamModelCopyWith<$Res> {
  _$TeamModelCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of TeamModel
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? name = null,
    Object? tag = freezed,
    Object? captainId = freezed,
    Object? sectorId = freezed,
    Object? comunaId = freezed,
    Object? modality = null,
    Object? eloRating = null,
    Object? leaguePoints = null,
    Object? leagueTier = freezed,
    Object? totalMatches = null,
    Object? wins = null,
    Object? losses = null,
    Object? draws = null,
    Object? createdAt = freezed,
  }) {
    return _then(
      _value.copyWith(
            id:
                null == id
                    ? _value.id
                    : id // ignore: cast_nullable_to_non_nullable
                        as String,
            name:
                null == name
                    ? _value.name
                    : name // ignore: cast_nullable_to_non_nullable
                        as String,
            tag:
                freezed == tag
                    ? _value.tag
                    : tag // ignore: cast_nullable_to_non_nullable
                        as String?,
            captainId:
                freezed == captainId
                    ? _value.captainId
                    : captainId // ignore: cast_nullable_to_non_nullable
                        as String?,
            sectorId:
                freezed == sectorId
                    ? _value.sectorId
                    : sectorId // ignore: cast_nullable_to_non_nullable
                        as String?,
            comunaId:
                freezed == comunaId
                    ? _value.comunaId
                    : comunaId // ignore: cast_nullable_to_non_nullable
                        as String?,
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
            leaguePoints:
                null == leaguePoints
                    ? _value.leaguePoints
                    : leaguePoints // ignore: cast_nullable_to_non_nullable
                        as int,
            leagueTier:
                freezed == leagueTier
                    ? _value.leagueTier
                    : leagueTier // ignore: cast_nullable_to_non_nullable
                        as String?,
            totalMatches:
                null == totalMatches
                    ? _value.totalMatches
                    : totalMatches // ignore: cast_nullable_to_non_nullable
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
            createdAt:
                freezed == createdAt
                    ? _value.createdAt
                    : createdAt // ignore: cast_nullable_to_non_nullable
                        as DateTime?,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$TeamModelImplCopyWith<$Res>
    implements $TeamModelCopyWith<$Res> {
  factory _$$TeamModelImplCopyWith(
    _$TeamModelImpl value,
    $Res Function(_$TeamModelImpl) then,
  ) = __$$TeamModelImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    String id,
    String name,
    String? tag,
    String? captainId,
    String? sectorId,
    String? comunaId,
    FootballModality modality,
    int eloRating,
    int leaguePoints,
    String? leagueTier,
    int totalMatches,
    int wins,
    int losses,
    int draws,
    DateTime? createdAt,
  });
}

/// @nodoc
class __$$TeamModelImplCopyWithImpl<$Res>
    extends _$TeamModelCopyWithImpl<$Res, _$TeamModelImpl>
    implements _$$TeamModelImplCopyWith<$Res> {
  __$$TeamModelImplCopyWithImpl(
    _$TeamModelImpl _value,
    $Res Function(_$TeamModelImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of TeamModel
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? name = null,
    Object? tag = freezed,
    Object? captainId = freezed,
    Object? sectorId = freezed,
    Object? comunaId = freezed,
    Object? modality = null,
    Object? eloRating = null,
    Object? leaguePoints = null,
    Object? leagueTier = freezed,
    Object? totalMatches = null,
    Object? wins = null,
    Object? losses = null,
    Object? draws = null,
    Object? createdAt = freezed,
  }) {
    return _then(
      _$TeamModelImpl(
        id:
            null == id
                ? _value.id
                : id // ignore: cast_nullable_to_non_nullable
                    as String,
        name:
            null == name
                ? _value.name
                : name // ignore: cast_nullable_to_non_nullable
                    as String,
        tag:
            freezed == tag
                ? _value.tag
                : tag // ignore: cast_nullable_to_non_nullable
                    as String?,
        captainId:
            freezed == captainId
                ? _value.captainId
                : captainId // ignore: cast_nullable_to_non_nullable
                    as String?,
        sectorId:
            freezed == sectorId
                ? _value.sectorId
                : sectorId // ignore: cast_nullable_to_non_nullable
                    as String?,
        comunaId:
            freezed == comunaId
                ? _value.comunaId
                : comunaId // ignore: cast_nullable_to_non_nullable
                    as String?,
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
        leaguePoints:
            null == leaguePoints
                ? _value.leaguePoints
                : leaguePoints // ignore: cast_nullable_to_non_nullable
                    as int,
        leagueTier:
            freezed == leagueTier
                ? _value.leagueTier
                : leagueTier // ignore: cast_nullable_to_non_nullable
                    as String?,
        totalMatches:
            null == totalMatches
                ? _value.totalMatches
                : totalMatches // ignore: cast_nullable_to_non_nullable
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
        createdAt:
            freezed == createdAt
                ? _value.createdAt
                : createdAt // ignore: cast_nullable_to_non_nullable
                    as DateTime?,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$TeamModelImpl extends _TeamModel {
  const _$TeamModelImpl({
    required this.id,
    required this.name,
    this.tag,
    this.captainId,
    this.sectorId,
    this.comunaId,
    this.modality = FootballModality.futbolito,
    this.eloRating = 1200,
    this.leaguePoints = 100,
    this.leagueTier,
    this.totalMatches = 0,
    this.wins = 0,
    this.losses = 0,
    this.draws = 0,
    this.createdAt,
  }) : super._();

  factory _$TeamModelImpl.fromJson(Map<String, dynamic> json) =>
      _$$TeamModelImplFromJson(json);

  @override
  final String id;
  @override
  final String name;
  @override
  final String? tag;
  @override
  final String? captainId;
  @override
  final String? sectorId;
  @override
  final String? comunaId;
  // ✅ Coincidir con base de datos
  @override
  @JsonKey()
  final FootballModality modality;
  @override
  @JsonKey()
  final int eloRating;
  // ✅ Coincidir con base de datos (no averageElo)
  // Puntos de liga acumulados (ranking principal)
  @override
  @JsonKey()
  final int leaguePoints;
  // Tier/slug de la liga (pichanga, barrio, etc.)
  @override
  final String? leagueTier;
  @override
  @JsonKey()
  final int totalMatches;
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
  final DateTime? createdAt;

  @override
  String toString() {
    return 'TeamModel(id: $id, name: $name, tag: $tag, captainId: $captainId, sectorId: $sectorId, comunaId: $comunaId, modality: $modality, eloRating: $eloRating, leaguePoints: $leaguePoints, leagueTier: $leagueTier, totalMatches: $totalMatches, wins: $wins, losses: $losses, draws: $draws, createdAt: $createdAt)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$TeamModelImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.name, name) || other.name == name) &&
            (identical(other.tag, tag) || other.tag == tag) &&
            (identical(other.captainId, captainId) ||
                other.captainId == captainId) &&
            (identical(other.sectorId, sectorId) ||
                other.sectorId == sectorId) &&
            (identical(other.comunaId, comunaId) ||
                other.comunaId == comunaId) &&
            (identical(other.modality, modality) ||
                other.modality == modality) &&
            (identical(other.eloRating, eloRating) ||
                other.eloRating == eloRating) &&
            (identical(other.leaguePoints, leaguePoints) ||
                other.leaguePoints == leaguePoints) &&
            (identical(other.leagueTier, leagueTier) ||
                other.leagueTier == leagueTier) &&
            (identical(other.totalMatches, totalMatches) ||
                other.totalMatches == totalMatches) &&
            (identical(other.wins, wins) || other.wins == wins) &&
            (identical(other.losses, losses) || other.losses == losses) &&
            (identical(other.draws, draws) || other.draws == draws) &&
            (identical(other.createdAt, createdAt) ||
                other.createdAt == createdAt));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
    runtimeType,
    id,
    name,
    tag,
    captainId,
    sectorId,
    comunaId,
    modality,
    eloRating,
    leaguePoints,
    leagueTier,
    totalMatches,
    wins,
    losses,
    draws,
    createdAt,
  );

  /// Create a copy of TeamModel
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$TeamModelImplCopyWith<_$TeamModelImpl> get copyWith =>
      __$$TeamModelImplCopyWithImpl<_$TeamModelImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$TeamModelImplToJson(this);
  }
}

abstract class _TeamModel extends TeamModel {
  const factory _TeamModel({
    required final String id,
    required final String name,
    final String? tag,
    final String? captainId,
    final String? sectorId,
    final String? comunaId,
    final FootballModality modality,
    final int eloRating,
    final int leaguePoints,
    final String? leagueTier,
    final int totalMatches,
    final int wins,
    final int losses,
    final int draws,
    final DateTime? createdAt,
  }) = _$TeamModelImpl;
  const _TeamModel._() : super._();

  factory _TeamModel.fromJson(Map<String, dynamic> json) =
      _$TeamModelImpl.fromJson;

  @override
  String get id;
  @override
  String get name;
  @override
  String? get tag;
  @override
  String? get captainId;
  @override
  String? get sectorId;
  @override
  String? get comunaId; // ✅ Coincidir con base de datos
  @override
  FootballModality get modality;
  @override
  int get eloRating; // ✅ Coincidir con base de datos (no averageElo)
  // Puntos de liga acumulados (ranking principal)
  @override
  int get leaguePoints; // Tier/slug de la liga (pichanga, barrio, etc.)
  @override
  String? get leagueTier;
  @override
  int get totalMatches;
  @override
  int get wins;
  @override
  int get losses;
  @override
  int get draws;
  @override
  DateTime? get createdAt;

  /// Create a copy of TeamModel
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$TeamModelImplCopyWith<_$TeamModelImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
