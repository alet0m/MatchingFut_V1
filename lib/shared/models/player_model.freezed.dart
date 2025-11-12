// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'player_model.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
  'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models',
);

PlayerModel _$PlayerModelFromJson(Map<String, dynamic> json) {
  return _PlayerModel.fromJson(json);
}

/// @nodoc
mixin _$PlayerModel {
  String get id => throw _privateConstructorUsedError;
  String get userId => throw _privateConstructorUsedError;
  String get teamId => throw _privateConstructorUsedError;
  String get name => throw _privateConstructorUsedError;
  String? get email => throw _privateConstructorUsedError;
  String? get position =>
      throw _privateConstructorUsedError; // Portero, Defensa, Mediocampo, Delantero
  int get elo =>
      throw _privateConstructorUsedError; // Liga basada en puntos (nuevo ranking principal)
  int get leaguePoints => throw _privateConstructorUsedError;
  String? get leagueTier => throw _privateConstructorUsedError;
  int get goalsScored => throw _privateConstructorUsedError;
  int get assists => throw _privateConstructorUsedError;
  int get yellowCards => throw _privateConstructorUsedError;
  int get redCards => throw _privateConstructorUsedError;
  bool get isActive => throw _privateConstructorUsedError;
  bool get isCaptain => throw _privateConstructorUsedError;
  DateTime? get joinedAt => throw _privateConstructorUsedError;
  DateTime? get createdAt => throw _privateConstructorUsedError;

  /// Serializes this PlayerModel to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of PlayerModel
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $PlayerModelCopyWith<PlayerModel> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $PlayerModelCopyWith<$Res> {
  factory $PlayerModelCopyWith(
    PlayerModel value,
    $Res Function(PlayerModel) then,
  ) = _$PlayerModelCopyWithImpl<$Res, PlayerModel>;
  @useResult
  $Res call({
    String id,
    String userId,
    String teamId,
    String name,
    String? email,
    String? position,
    int elo,
    int leaguePoints,
    String? leagueTier,
    int goalsScored,
    int assists,
    int yellowCards,
    int redCards,
    bool isActive,
    bool isCaptain,
    DateTime? joinedAt,
    DateTime? createdAt,
  });
}

/// @nodoc
class _$PlayerModelCopyWithImpl<$Res, $Val extends PlayerModel>
    implements $PlayerModelCopyWith<$Res> {
  _$PlayerModelCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of PlayerModel
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? userId = null,
    Object? teamId = null,
    Object? name = null,
    Object? email = freezed,
    Object? position = freezed,
    Object? elo = null,
    Object? leaguePoints = null,
    Object? leagueTier = freezed,
    Object? goalsScored = null,
    Object? assists = null,
    Object? yellowCards = null,
    Object? redCards = null,
    Object? isActive = null,
    Object? isCaptain = null,
    Object? joinedAt = freezed,
    Object? createdAt = freezed,
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
            teamId:
                null == teamId
                    ? _value.teamId
                    : teamId // ignore: cast_nullable_to_non_nullable
                        as String,
            name:
                null == name
                    ? _value.name
                    : name // ignore: cast_nullable_to_non_nullable
                        as String,
            email:
                freezed == email
                    ? _value.email
                    : email // ignore: cast_nullable_to_non_nullable
                        as String?,
            position:
                freezed == position
                    ? _value.position
                    : position // ignore: cast_nullable_to_non_nullable
                        as String?,
            elo:
                null == elo
                    ? _value.elo
                    : elo // ignore: cast_nullable_to_non_nullable
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
            goalsScored:
                null == goalsScored
                    ? _value.goalsScored
                    : goalsScored // ignore: cast_nullable_to_non_nullable
                        as int,
            assists:
                null == assists
                    ? _value.assists
                    : assists // ignore: cast_nullable_to_non_nullable
                        as int,
            yellowCards:
                null == yellowCards
                    ? _value.yellowCards
                    : yellowCards // ignore: cast_nullable_to_non_nullable
                        as int,
            redCards:
                null == redCards
                    ? _value.redCards
                    : redCards // ignore: cast_nullable_to_non_nullable
                        as int,
            isActive:
                null == isActive
                    ? _value.isActive
                    : isActive // ignore: cast_nullable_to_non_nullable
                        as bool,
            isCaptain:
                null == isCaptain
                    ? _value.isCaptain
                    : isCaptain // ignore: cast_nullable_to_non_nullable
                        as bool,
            joinedAt:
                freezed == joinedAt
                    ? _value.joinedAt
                    : joinedAt // ignore: cast_nullable_to_non_nullable
                        as DateTime?,
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
abstract class _$$PlayerModelImplCopyWith<$Res>
    implements $PlayerModelCopyWith<$Res> {
  factory _$$PlayerModelImplCopyWith(
    _$PlayerModelImpl value,
    $Res Function(_$PlayerModelImpl) then,
  ) = __$$PlayerModelImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    String id,
    String userId,
    String teamId,
    String name,
    String? email,
    String? position,
    int elo,
    int leaguePoints,
    String? leagueTier,
    int goalsScored,
    int assists,
    int yellowCards,
    int redCards,
    bool isActive,
    bool isCaptain,
    DateTime? joinedAt,
    DateTime? createdAt,
  });
}

/// @nodoc
class __$$PlayerModelImplCopyWithImpl<$Res>
    extends _$PlayerModelCopyWithImpl<$Res, _$PlayerModelImpl>
    implements _$$PlayerModelImplCopyWith<$Res> {
  __$$PlayerModelImplCopyWithImpl(
    _$PlayerModelImpl _value,
    $Res Function(_$PlayerModelImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of PlayerModel
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? userId = null,
    Object? teamId = null,
    Object? name = null,
    Object? email = freezed,
    Object? position = freezed,
    Object? elo = null,
    Object? leaguePoints = null,
    Object? leagueTier = freezed,
    Object? goalsScored = null,
    Object? assists = null,
    Object? yellowCards = null,
    Object? redCards = null,
    Object? isActive = null,
    Object? isCaptain = null,
    Object? joinedAt = freezed,
    Object? createdAt = freezed,
  }) {
    return _then(
      _$PlayerModelImpl(
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
        teamId:
            null == teamId
                ? _value.teamId
                : teamId // ignore: cast_nullable_to_non_nullable
                    as String,
        name:
            null == name
                ? _value.name
                : name // ignore: cast_nullable_to_non_nullable
                    as String,
        email:
            freezed == email
                ? _value.email
                : email // ignore: cast_nullable_to_non_nullable
                    as String?,
        position:
            freezed == position
                ? _value.position
                : position // ignore: cast_nullable_to_non_nullable
                    as String?,
        elo:
            null == elo
                ? _value.elo
                : elo // ignore: cast_nullable_to_non_nullable
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
        goalsScored:
            null == goalsScored
                ? _value.goalsScored
                : goalsScored // ignore: cast_nullable_to_non_nullable
                    as int,
        assists:
            null == assists
                ? _value.assists
                : assists // ignore: cast_nullable_to_non_nullable
                    as int,
        yellowCards:
            null == yellowCards
                ? _value.yellowCards
                : yellowCards // ignore: cast_nullable_to_non_nullable
                    as int,
        redCards:
            null == redCards
                ? _value.redCards
                : redCards // ignore: cast_nullable_to_non_nullable
                    as int,
        isActive:
            null == isActive
                ? _value.isActive
                : isActive // ignore: cast_nullable_to_non_nullable
                    as bool,
        isCaptain:
            null == isCaptain
                ? _value.isCaptain
                : isCaptain // ignore: cast_nullable_to_non_nullable
                    as bool,
        joinedAt:
            freezed == joinedAt
                ? _value.joinedAt
                : joinedAt // ignore: cast_nullable_to_non_nullable
                    as DateTime?,
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
class _$PlayerModelImpl implements _PlayerModel {
  const _$PlayerModelImpl({
    required this.id,
    required this.userId,
    required this.teamId,
    required this.name,
    this.email,
    this.position,
    this.elo = 1200,
    this.leaguePoints = 100,
    this.leagueTier,
    this.goalsScored = 0,
    this.assists = 0,
    this.yellowCards = 0,
    this.redCards = 0,
    this.isActive = true,
    this.isCaptain = false,
    this.joinedAt,
    this.createdAt,
  });

  factory _$PlayerModelImpl.fromJson(Map<String, dynamic> json) =>
      _$$PlayerModelImplFromJson(json);

  @override
  final String id;
  @override
  final String userId;
  @override
  final String teamId;
  @override
  final String name;
  @override
  final String? email;
  @override
  final String? position;
  // Portero, Defensa, Mediocampo, Delantero
  @override
  @JsonKey()
  final int elo;
  // Liga basada en puntos (nuevo ranking principal)
  @override
  @JsonKey()
  final int leaguePoints;
  @override
  final String? leagueTier;
  @override
  @JsonKey()
  final int goalsScored;
  @override
  @JsonKey()
  final int assists;
  @override
  @JsonKey()
  final int yellowCards;
  @override
  @JsonKey()
  final int redCards;
  @override
  @JsonKey()
  final bool isActive;
  @override
  @JsonKey()
  final bool isCaptain;
  @override
  final DateTime? joinedAt;
  @override
  final DateTime? createdAt;

  @override
  String toString() {
    return 'PlayerModel(id: $id, userId: $userId, teamId: $teamId, name: $name, email: $email, position: $position, elo: $elo, leaguePoints: $leaguePoints, leagueTier: $leagueTier, goalsScored: $goalsScored, assists: $assists, yellowCards: $yellowCards, redCards: $redCards, isActive: $isActive, isCaptain: $isCaptain, joinedAt: $joinedAt, createdAt: $createdAt)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$PlayerModelImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.userId, userId) || other.userId == userId) &&
            (identical(other.teamId, teamId) || other.teamId == teamId) &&
            (identical(other.name, name) || other.name == name) &&
            (identical(other.email, email) || other.email == email) &&
            (identical(other.position, position) ||
                other.position == position) &&
            (identical(other.elo, elo) || other.elo == elo) &&
            (identical(other.leaguePoints, leaguePoints) ||
                other.leaguePoints == leaguePoints) &&
            (identical(other.leagueTier, leagueTier) ||
                other.leagueTier == leagueTier) &&
            (identical(other.goalsScored, goalsScored) ||
                other.goalsScored == goalsScored) &&
            (identical(other.assists, assists) || other.assists == assists) &&
            (identical(other.yellowCards, yellowCards) ||
                other.yellowCards == yellowCards) &&
            (identical(other.redCards, redCards) ||
                other.redCards == redCards) &&
            (identical(other.isActive, isActive) ||
                other.isActive == isActive) &&
            (identical(other.isCaptain, isCaptain) ||
                other.isCaptain == isCaptain) &&
            (identical(other.joinedAt, joinedAt) ||
                other.joinedAt == joinedAt) &&
            (identical(other.createdAt, createdAt) ||
                other.createdAt == createdAt));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
    runtimeType,
    id,
    userId,
    teamId,
    name,
    email,
    position,
    elo,
    leaguePoints,
    leagueTier,
    goalsScored,
    assists,
    yellowCards,
    redCards,
    isActive,
    isCaptain,
    joinedAt,
    createdAt,
  );

  /// Create a copy of PlayerModel
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$PlayerModelImplCopyWith<_$PlayerModelImpl> get copyWith =>
      __$$PlayerModelImplCopyWithImpl<_$PlayerModelImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$PlayerModelImplToJson(this);
  }
}

abstract class _PlayerModel implements PlayerModel {
  const factory _PlayerModel({
    required final String id,
    required final String userId,
    required final String teamId,
    required final String name,
    final String? email,
    final String? position,
    final int elo,
    final int leaguePoints,
    final String? leagueTier,
    final int goalsScored,
    final int assists,
    final int yellowCards,
    final int redCards,
    final bool isActive,
    final bool isCaptain,
    final DateTime? joinedAt,
    final DateTime? createdAt,
  }) = _$PlayerModelImpl;

  factory _PlayerModel.fromJson(Map<String, dynamic> json) =
      _$PlayerModelImpl.fromJson;

  @override
  String get id;
  @override
  String get userId;
  @override
  String get teamId;
  @override
  String get name;
  @override
  String? get email;
  @override
  String? get position; // Portero, Defensa, Mediocampo, Delantero
  @override
  int get elo; // Liga basada en puntos (nuevo ranking principal)
  @override
  int get leaguePoints;
  @override
  String? get leagueTier;
  @override
  int get goalsScored;
  @override
  int get assists;
  @override
  int get yellowCards;
  @override
  int get redCards;
  @override
  bool get isActive;
  @override
  bool get isCaptain;
  @override
  DateTime? get joinedAt;
  @override
  DateTime? get createdAt;

  /// Create a copy of PlayerModel
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$PlayerModelImplCopyWith<_$PlayerModelImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
