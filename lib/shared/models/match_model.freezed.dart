// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'match_model.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
  'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models',
);

MatchModel _$MatchModelFromJson(Map<String, dynamic> json) {
  return _MatchModel.fromJson(json);
}

/// @nodoc
mixin _$MatchModel {
  String get id => throw _privateConstructorUsedError;
  String get hostTeamId => throw _privateConstructorUsedError;
  String? get guestTeamId => throw _privateConstructorUsedError;
  String? get hostTeamName => throw _privateConstructorUsedError;
  String? get guestTeamName => throw _privateConstructorUsedError;
  DateTime get scheduledDate => throw _privateConstructorUsedError;
  String get location => throw _privateConstructorUsedError;
  String get matchType =>
      throw _privateConstructorUsedError; // futbolito, futbol
  String get status =>
      throw _privateConstructorUsedError; // scheduled, live, finished, cancelled
  bool get isPublic => throw _privateConstructorUsedError;
  String? get description => throw _privateConstructorUsedError;
  int? get hostTeamScore => throw _privateConstructorUsedError;
  int? get guestTeamScore => throw _privateConstructorUsedError;
  DateTime? get startedAt => throw _privateConstructorUsedError;
  DateTime? get finishedAt => throw _privateConstructorUsedError;
  String? get createdBy => throw _privateConstructorUsedError;
  DateTime? get createdAt => throw _privateConstructorUsedError;
  DateTime? get updatedAt =>
      throw _privateConstructorUsedError; // Campos legacy para compatibilidad
  String? get homeTeamId => throw _privateConstructorUsedError;
  String? get awayTeamId => throw _privateConstructorUsedError;
  String? get canchaId => throw _privateConstructorUsedError;
  String? get sectorId => throw _privateConstructorUsedError;
  DateTime? get matchDate => throw _privateConstructorUsedError;
  int get homeScore => throw _privateConstructorUsedError;
  int get awayScore => throw _privateConstructorUsedError;
  int get eloChange => throw _privateConstructorUsedError;

  /// Serializes this MatchModel to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of MatchModel
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $MatchModelCopyWith<MatchModel> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $MatchModelCopyWith<$Res> {
  factory $MatchModelCopyWith(
    MatchModel value,
    $Res Function(MatchModel) then,
  ) = _$MatchModelCopyWithImpl<$Res, MatchModel>;
  @useResult
  $Res call({
    String id,
    String hostTeamId,
    String? guestTeamId,
    String? hostTeamName,
    String? guestTeamName,
    DateTime scheduledDate,
    String location,
    String matchType,
    String status,
    bool isPublic,
    String? description,
    int? hostTeamScore,
    int? guestTeamScore,
    DateTime? startedAt,
    DateTime? finishedAt,
    String? createdBy,
    DateTime? createdAt,
    DateTime? updatedAt,
    String? homeTeamId,
    String? awayTeamId,
    String? canchaId,
    String? sectorId,
    DateTime? matchDate,
    int homeScore,
    int awayScore,
    int eloChange,
  });
}

/// @nodoc
class _$MatchModelCopyWithImpl<$Res, $Val extends MatchModel>
    implements $MatchModelCopyWith<$Res> {
  _$MatchModelCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of MatchModel
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? hostTeamId = null,
    Object? guestTeamId = freezed,
    Object? hostTeamName = freezed,
    Object? guestTeamName = freezed,
    Object? scheduledDate = null,
    Object? location = null,
    Object? matchType = null,
    Object? status = null,
    Object? isPublic = null,
    Object? description = freezed,
    Object? hostTeamScore = freezed,
    Object? guestTeamScore = freezed,
    Object? startedAt = freezed,
    Object? finishedAt = freezed,
    Object? createdBy = freezed,
    Object? createdAt = freezed,
    Object? updatedAt = freezed,
    Object? homeTeamId = freezed,
    Object? awayTeamId = freezed,
    Object? canchaId = freezed,
    Object? sectorId = freezed,
    Object? matchDate = freezed,
    Object? homeScore = null,
    Object? awayScore = null,
    Object? eloChange = null,
  }) {
    return _then(
      _value.copyWith(
            id:
                null == id
                    ? _value.id
                    : id // ignore: cast_nullable_to_non_nullable
                        as String,
            hostTeamId:
                null == hostTeamId
                    ? _value.hostTeamId
                    : hostTeamId // ignore: cast_nullable_to_non_nullable
                        as String,
            guestTeamId:
                freezed == guestTeamId
                    ? _value.guestTeamId
                    : guestTeamId // ignore: cast_nullable_to_non_nullable
                        as String?,
            hostTeamName:
                freezed == hostTeamName
                    ? _value.hostTeamName
                    : hostTeamName // ignore: cast_nullable_to_non_nullable
                        as String?,
            guestTeamName:
                freezed == guestTeamName
                    ? _value.guestTeamName
                    : guestTeamName // ignore: cast_nullable_to_non_nullable
                        as String?,
            scheduledDate:
                null == scheduledDate
                    ? _value.scheduledDate
                    : scheduledDate // ignore: cast_nullable_to_non_nullable
                        as DateTime,
            location:
                null == location
                    ? _value.location
                    : location // ignore: cast_nullable_to_non_nullable
                        as String,
            matchType:
                null == matchType
                    ? _value.matchType
                    : matchType // ignore: cast_nullable_to_non_nullable
                        as String,
            status:
                null == status
                    ? _value.status
                    : status // ignore: cast_nullable_to_non_nullable
                        as String,
            isPublic:
                null == isPublic
                    ? _value.isPublic
                    : isPublic // ignore: cast_nullable_to_non_nullable
                        as bool,
            description:
                freezed == description
                    ? _value.description
                    : description // ignore: cast_nullable_to_non_nullable
                        as String?,
            hostTeamScore:
                freezed == hostTeamScore
                    ? _value.hostTeamScore
                    : hostTeamScore // ignore: cast_nullable_to_non_nullable
                        as int?,
            guestTeamScore:
                freezed == guestTeamScore
                    ? _value.guestTeamScore
                    : guestTeamScore // ignore: cast_nullable_to_non_nullable
                        as int?,
            startedAt:
                freezed == startedAt
                    ? _value.startedAt
                    : startedAt // ignore: cast_nullable_to_non_nullable
                        as DateTime?,
            finishedAt:
                freezed == finishedAt
                    ? _value.finishedAt
                    : finishedAt // ignore: cast_nullable_to_non_nullable
                        as DateTime?,
            createdBy:
                freezed == createdBy
                    ? _value.createdBy
                    : createdBy // ignore: cast_nullable_to_non_nullable
                        as String?,
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
            homeTeamId:
                freezed == homeTeamId
                    ? _value.homeTeamId
                    : homeTeamId // ignore: cast_nullable_to_non_nullable
                        as String?,
            awayTeamId:
                freezed == awayTeamId
                    ? _value.awayTeamId
                    : awayTeamId // ignore: cast_nullable_to_non_nullable
                        as String?,
            canchaId:
                freezed == canchaId
                    ? _value.canchaId
                    : canchaId // ignore: cast_nullable_to_non_nullable
                        as String?,
            sectorId:
                freezed == sectorId
                    ? _value.sectorId
                    : sectorId // ignore: cast_nullable_to_non_nullable
                        as String?,
            matchDate:
                freezed == matchDate
                    ? _value.matchDate
                    : matchDate // ignore: cast_nullable_to_non_nullable
                        as DateTime?,
            homeScore:
                null == homeScore
                    ? _value.homeScore
                    : homeScore // ignore: cast_nullable_to_non_nullable
                        as int,
            awayScore:
                null == awayScore
                    ? _value.awayScore
                    : awayScore // ignore: cast_nullable_to_non_nullable
                        as int,
            eloChange:
                null == eloChange
                    ? _value.eloChange
                    : eloChange // ignore: cast_nullable_to_non_nullable
                        as int,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$MatchModelImplCopyWith<$Res>
    implements $MatchModelCopyWith<$Res> {
  factory _$$MatchModelImplCopyWith(
    _$MatchModelImpl value,
    $Res Function(_$MatchModelImpl) then,
  ) = __$$MatchModelImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    String id,
    String hostTeamId,
    String? guestTeamId,
    String? hostTeamName,
    String? guestTeamName,
    DateTime scheduledDate,
    String location,
    String matchType,
    String status,
    bool isPublic,
    String? description,
    int? hostTeamScore,
    int? guestTeamScore,
    DateTime? startedAt,
    DateTime? finishedAt,
    String? createdBy,
    DateTime? createdAt,
    DateTime? updatedAt,
    String? homeTeamId,
    String? awayTeamId,
    String? canchaId,
    String? sectorId,
    DateTime? matchDate,
    int homeScore,
    int awayScore,
    int eloChange,
  });
}

/// @nodoc
class __$$MatchModelImplCopyWithImpl<$Res>
    extends _$MatchModelCopyWithImpl<$Res, _$MatchModelImpl>
    implements _$$MatchModelImplCopyWith<$Res> {
  __$$MatchModelImplCopyWithImpl(
    _$MatchModelImpl _value,
    $Res Function(_$MatchModelImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of MatchModel
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? hostTeamId = null,
    Object? guestTeamId = freezed,
    Object? hostTeamName = freezed,
    Object? guestTeamName = freezed,
    Object? scheduledDate = null,
    Object? location = null,
    Object? matchType = null,
    Object? status = null,
    Object? isPublic = null,
    Object? description = freezed,
    Object? hostTeamScore = freezed,
    Object? guestTeamScore = freezed,
    Object? startedAt = freezed,
    Object? finishedAt = freezed,
    Object? createdBy = freezed,
    Object? createdAt = freezed,
    Object? updatedAt = freezed,
    Object? homeTeamId = freezed,
    Object? awayTeamId = freezed,
    Object? canchaId = freezed,
    Object? sectorId = freezed,
    Object? matchDate = freezed,
    Object? homeScore = null,
    Object? awayScore = null,
    Object? eloChange = null,
  }) {
    return _then(
      _$MatchModelImpl(
        id:
            null == id
                ? _value.id
                : id // ignore: cast_nullable_to_non_nullable
                    as String,
        hostTeamId:
            null == hostTeamId
                ? _value.hostTeamId
                : hostTeamId // ignore: cast_nullable_to_non_nullable
                    as String,
        guestTeamId:
            freezed == guestTeamId
                ? _value.guestTeamId
                : guestTeamId // ignore: cast_nullable_to_non_nullable
                    as String?,
        hostTeamName:
            freezed == hostTeamName
                ? _value.hostTeamName
                : hostTeamName // ignore: cast_nullable_to_non_nullable
                    as String?,
        guestTeamName:
            freezed == guestTeamName
                ? _value.guestTeamName
                : guestTeamName // ignore: cast_nullable_to_non_nullable
                    as String?,
        scheduledDate:
            null == scheduledDate
                ? _value.scheduledDate
                : scheduledDate // ignore: cast_nullable_to_non_nullable
                    as DateTime,
        location:
            null == location
                ? _value.location
                : location // ignore: cast_nullable_to_non_nullable
                    as String,
        matchType:
            null == matchType
                ? _value.matchType
                : matchType // ignore: cast_nullable_to_non_nullable
                    as String,
        status:
            null == status
                ? _value.status
                : status // ignore: cast_nullable_to_non_nullable
                    as String,
        isPublic:
            null == isPublic
                ? _value.isPublic
                : isPublic // ignore: cast_nullable_to_non_nullable
                    as bool,
        description:
            freezed == description
                ? _value.description
                : description // ignore: cast_nullable_to_non_nullable
                    as String?,
        hostTeamScore:
            freezed == hostTeamScore
                ? _value.hostTeamScore
                : hostTeamScore // ignore: cast_nullable_to_non_nullable
                    as int?,
        guestTeamScore:
            freezed == guestTeamScore
                ? _value.guestTeamScore
                : guestTeamScore // ignore: cast_nullable_to_non_nullable
                    as int?,
        startedAt:
            freezed == startedAt
                ? _value.startedAt
                : startedAt // ignore: cast_nullable_to_non_nullable
                    as DateTime?,
        finishedAt:
            freezed == finishedAt
                ? _value.finishedAt
                : finishedAt // ignore: cast_nullable_to_non_nullable
                    as DateTime?,
        createdBy:
            freezed == createdBy
                ? _value.createdBy
                : createdBy // ignore: cast_nullable_to_non_nullable
                    as String?,
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
        homeTeamId:
            freezed == homeTeamId
                ? _value.homeTeamId
                : homeTeamId // ignore: cast_nullable_to_non_nullable
                    as String?,
        awayTeamId:
            freezed == awayTeamId
                ? _value.awayTeamId
                : awayTeamId // ignore: cast_nullable_to_non_nullable
                    as String?,
        canchaId:
            freezed == canchaId
                ? _value.canchaId
                : canchaId // ignore: cast_nullable_to_non_nullable
                    as String?,
        sectorId:
            freezed == sectorId
                ? _value.sectorId
                : sectorId // ignore: cast_nullable_to_non_nullable
                    as String?,
        matchDate:
            freezed == matchDate
                ? _value.matchDate
                : matchDate // ignore: cast_nullable_to_non_nullable
                    as DateTime?,
        homeScore:
            null == homeScore
                ? _value.homeScore
                : homeScore // ignore: cast_nullable_to_non_nullable
                    as int,
        awayScore:
            null == awayScore
                ? _value.awayScore
                : awayScore // ignore: cast_nullable_to_non_nullable
                    as int,
        eloChange:
            null == eloChange
                ? _value.eloChange
                : eloChange // ignore: cast_nullable_to_non_nullable
                    as int,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$MatchModelImpl implements _MatchModel {
  const _$MatchModelImpl({
    required this.id,
    required this.hostTeamId,
    this.guestTeamId,
    this.hostTeamName,
    this.guestTeamName,
    required this.scheduledDate,
    required this.location,
    this.matchType = 'futbolito',
    this.status = 'scheduled',
    this.isPublic = false,
    this.description,
    this.hostTeamScore,
    this.guestTeamScore,
    this.startedAt,
    this.finishedAt,
    this.createdBy,
    this.createdAt,
    this.updatedAt,
    this.homeTeamId,
    this.awayTeamId,
    this.canchaId,
    this.sectorId,
    this.matchDate,
    this.homeScore = 0,
    this.awayScore = 0,
    this.eloChange = 0,
  });

  factory _$MatchModelImpl.fromJson(Map<String, dynamic> json) =>
      _$$MatchModelImplFromJson(json);

  @override
  final String id;
  @override
  final String hostTeamId;
  @override
  final String? guestTeamId;
  @override
  final String? hostTeamName;
  @override
  final String? guestTeamName;
  @override
  final DateTime scheduledDate;
  @override
  final String location;
  @override
  @JsonKey()
  final String matchType;
  // futbolito, futbol
  @override
  @JsonKey()
  final String status;
  // scheduled, live, finished, cancelled
  @override
  @JsonKey()
  final bool isPublic;
  @override
  final String? description;
  @override
  final int? hostTeamScore;
  @override
  final int? guestTeamScore;
  @override
  final DateTime? startedAt;
  @override
  final DateTime? finishedAt;
  @override
  final String? createdBy;
  @override
  final DateTime? createdAt;
  @override
  final DateTime? updatedAt;
  // Campos legacy para compatibilidad
  @override
  final String? homeTeamId;
  @override
  final String? awayTeamId;
  @override
  final String? canchaId;
  @override
  final String? sectorId;
  @override
  final DateTime? matchDate;
  @override
  @JsonKey()
  final int homeScore;
  @override
  @JsonKey()
  final int awayScore;
  @override
  @JsonKey()
  final int eloChange;

  @override
  String toString() {
    return 'MatchModel(id: $id, hostTeamId: $hostTeamId, guestTeamId: $guestTeamId, hostTeamName: $hostTeamName, guestTeamName: $guestTeamName, scheduledDate: $scheduledDate, location: $location, matchType: $matchType, status: $status, isPublic: $isPublic, description: $description, hostTeamScore: $hostTeamScore, guestTeamScore: $guestTeamScore, startedAt: $startedAt, finishedAt: $finishedAt, createdBy: $createdBy, createdAt: $createdAt, updatedAt: $updatedAt, homeTeamId: $homeTeamId, awayTeamId: $awayTeamId, canchaId: $canchaId, sectorId: $sectorId, matchDate: $matchDate, homeScore: $homeScore, awayScore: $awayScore, eloChange: $eloChange)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$MatchModelImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.hostTeamId, hostTeamId) ||
                other.hostTeamId == hostTeamId) &&
            (identical(other.guestTeamId, guestTeamId) ||
                other.guestTeamId == guestTeamId) &&
            (identical(other.hostTeamName, hostTeamName) ||
                other.hostTeamName == hostTeamName) &&
            (identical(other.guestTeamName, guestTeamName) ||
                other.guestTeamName == guestTeamName) &&
            (identical(other.scheduledDate, scheduledDate) ||
                other.scheduledDate == scheduledDate) &&
            (identical(other.location, location) ||
                other.location == location) &&
            (identical(other.matchType, matchType) ||
                other.matchType == matchType) &&
            (identical(other.status, status) || other.status == status) &&
            (identical(other.isPublic, isPublic) ||
                other.isPublic == isPublic) &&
            (identical(other.description, description) ||
                other.description == description) &&
            (identical(other.hostTeamScore, hostTeamScore) ||
                other.hostTeamScore == hostTeamScore) &&
            (identical(other.guestTeamScore, guestTeamScore) ||
                other.guestTeamScore == guestTeamScore) &&
            (identical(other.startedAt, startedAt) ||
                other.startedAt == startedAt) &&
            (identical(other.finishedAt, finishedAt) ||
                other.finishedAt == finishedAt) &&
            (identical(other.createdBy, createdBy) ||
                other.createdBy == createdBy) &&
            (identical(other.createdAt, createdAt) ||
                other.createdAt == createdAt) &&
            (identical(other.updatedAt, updatedAt) ||
                other.updatedAt == updatedAt) &&
            (identical(other.homeTeamId, homeTeamId) ||
                other.homeTeamId == homeTeamId) &&
            (identical(other.awayTeamId, awayTeamId) ||
                other.awayTeamId == awayTeamId) &&
            (identical(other.canchaId, canchaId) ||
                other.canchaId == canchaId) &&
            (identical(other.sectorId, sectorId) ||
                other.sectorId == sectorId) &&
            (identical(other.matchDate, matchDate) ||
                other.matchDate == matchDate) &&
            (identical(other.homeScore, homeScore) ||
                other.homeScore == homeScore) &&
            (identical(other.awayScore, awayScore) ||
                other.awayScore == awayScore) &&
            (identical(other.eloChange, eloChange) ||
                other.eloChange == eloChange));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hashAll([
    runtimeType,
    id,
    hostTeamId,
    guestTeamId,
    hostTeamName,
    guestTeamName,
    scheduledDate,
    location,
    matchType,
    status,
    isPublic,
    description,
    hostTeamScore,
    guestTeamScore,
    startedAt,
    finishedAt,
    createdBy,
    createdAt,
    updatedAt,
    homeTeamId,
    awayTeamId,
    canchaId,
    sectorId,
    matchDate,
    homeScore,
    awayScore,
    eloChange,
  ]);

  /// Create a copy of MatchModel
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$MatchModelImplCopyWith<_$MatchModelImpl> get copyWith =>
      __$$MatchModelImplCopyWithImpl<_$MatchModelImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$MatchModelImplToJson(this);
  }
}

abstract class _MatchModel implements MatchModel {
  const factory _MatchModel({
    required final String id,
    required final String hostTeamId,
    final String? guestTeamId,
    final String? hostTeamName,
    final String? guestTeamName,
    required final DateTime scheduledDate,
    required final String location,
    final String matchType,
    final String status,
    final bool isPublic,
    final String? description,
    final int? hostTeamScore,
    final int? guestTeamScore,
    final DateTime? startedAt,
    final DateTime? finishedAt,
    final String? createdBy,
    final DateTime? createdAt,
    final DateTime? updatedAt,
    final String? homeTeamId,
    final String? awayTeamId,
    final String? canchaId,
    final String? sectorId,
    final DateTime? matchDate,
    final int homeScore,
    final int awayScore,
    final int eloChange,
  }) = _$MatchModelImpl;

  factory _MatchModel.fromJson(Map<String, dynamic> json) =
      _$MatchModelImpl.fromJson;

  @override
  String get id;
  @override
  String get hostTeamId;
  @override
  String? get guestTeamId;
  @override
  String? get hostTeamName;
  @override
  String? get guestTeamName;
  @override
  DateTime get scheduledDate;
  @override
  String get location;
  @override
  String get matchType; // futbolito, futbol
  @override
  String get status; // scheduled, live, finished, cancelled
  @override
  bool get isPublic;
  @override
  String? get description;
  @override
  int? get hostTeamScore;
  @override
  int? get guestTeamScore;
  @override
  DateTime? get startedAt;
  @override
  DateTime? get finishedAt;
  @override
  String? get createdBy;
  @override
  DateTime? get createdAt;
  @override
  DateTime? get updatedAt; // Campos legacy para compatibilidad
  @override
  String? get homeTeamId;
  @override
  String? get awayTeamId;
  @override
  String? get canchaId;
  @override
  String? get sectorId;
  @override
  DateTime? get matchDate;
  @override
  int get homeScore;
  @override
  int get awayScore;
  @override
  int get eloChange;

  /// Create a copy of MatchModel
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$MatchModelImplCopyWith<_$MatchModelImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
