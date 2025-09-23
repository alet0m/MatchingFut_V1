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
  String? get homeTeamId => throw _privateConstructorUsedError;
  String? get awayTeamId => throw _privateConstructorUsedError;
  String? get canchaId => throw _privateConstructorUsedError;
  String? get sectorId => throw _privateConstructorUsedError;
  DateTime? get matchDate => throw _privateConstructorUsedError;
  String get status =>
      throw _privateConstructorUsedError; // scheduled, in_progress, finished, cancelled
  int get homeScore => throw _privateConstructorUsedError;
  int get awayScore => throw _privateConstructorUsedError;
  int get eloChange => throw _privateConstructorUsedError;
  String? get createdBy => throw _privateConstructorUsedError;
  DateTime? get createdAt => throw _privateConstructorUsedError;

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
    String? homeTeamId,
    String? awayTeamId,
    String? canchaId,
    String? sectorId,
    DateTime? matchDate,
    String status,
    int homeScore,
    int awayScore,
    int eloChange,
    String? createdBy,
    DateTime? createdAt,
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
    Object? homeTeamId = freezed,
    Object? awayTeamId = freezed,
    Object? canchaId = freezed,
    Object? sectorId = freezed,
    Object? matchDate = freezed,
    Object? status = null,
    Object? homeScore = null,
    Object? awayScore = null,
    Object? eloChange = null,
    Object? createdBy = freezed,
    Object? createdAt = freezed,
  }) {
    return _then(
      _value.copyWith(
            id:
                null == id
                    ? _value.id
                    : id // ignore: cast_nullable_to_non_nullable
                        as String,
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
            status:
                null == status
                    ? _value.status
                    : status // ignore: cast_nullable_to_non_nullable
                        as String,
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
    String? homeTeamId,
    String? awayTeamId,
    String? canchaId,
    String? sectorId,
    DateTime? matchDate,
    String status,
    int homeScore,
    int awayScore,
    int eloChange,
    String? createdBy,
    DateTime? createdAt,
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
    Object? homeTeamId = freezed,
    Object? awayTeamId = freezed,
    Object? canchaId = freezed,
    Object? sectorId = freezed,
    Object? matchDate = freezed,
    Object? status = null,
    Object? homeScore = null,
    Object? awayScore = null,
    Object? eloChange = null,
    Object? createdBy = freezed,
    Object? createdAt = freezed,
  }) {
    return _then(
      _$MatchModelImpl(
        id:
            null == id
                ? _value.id
                : id // ignore: cast_nullable_to_non_nullable
                    as String,
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
        status:
            null == status
                ? _value.status
                : status // ignore: cast_nullable_to_non_nullable
                    as String,
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
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$MatchModelImpl implements _MatchModel {
  const _$MatchModelImpl({
    required this.id,
    this.homeTeamId,
    this.awayTeamId,
    this.canchaId,
    this.sectorId,
    this.matchDate,
    this.status = 'scheduled',
    this.homeScore = 0,
    this.awayScore = 0,
    this.eloChange = 0,
    this.createdBy,
    this.createdAt,
  });

  factory _$MatchModelImpl.fromJson(Map<String, dynamic> json) =>
      _$$MatchModelImplFromJson(json);

  @override
  final String id;
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
  final String status;
  // scheduled, in_progress, finished, cancelled
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
  final String? createdBy;
  @override
  final DateTime? createdAt;

  @override
  String toString() {
    return 'MatchModel(id: $id, homeTeamId: $homeTeamId, awayTeamId: $awayTeamId, canchaId: $canchaId, sectorId: $sectorId, matchDate: $matchDate, status: $status, homeScore: $homeScore, awayScore: $awayScore, eloChange: $eloChange, createdBy: $createdBy, createdAt: $createdAt)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$MatchModelImpl &&
            (identical(other.id, id) || other.id == id) &&
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
            (identical(other.status, status) || other.status == status) &&
            (identical(other.homeScore, homeScore) ||
                other.homeScore == homeScore) &&
            (identical(other.awayScore, awayScore) ||
                other.awayScore == awayScore) &&
            (identical(other.eloChange, eloChange) ||
                other.eloChange == eloChange) &&
            (identical(other.createdBy, createdBy) ||
                other.createdBy == createdBy) &&
            (identical(other.createdAt, createdAt) ||
                other.createdAt == createdAt));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
    runtimeType,
    id,
    homeTeamId,
    awayTeamId,
    canchaId,
    sectorId,
    matchDate,
    status,
    homeScore,
    awayScore,
    eloChange,
    createdBy,
    createdAt,
  );

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
    final String? homeTeamId,
    final String? awayTeamId,
    final String? canchaId,
    final String? sectorId,
    final DateTime? matchDate,
    final String status,
    final int homeScore,
    final int awayScore,
    final int eloChange,
    final String? createdBy,
    final DateTime? createdAt,
  }) = _$MatchModelImpl;

  factory _MatchModel.fromJson(Map<String, dynamic> json) =
      _$MatchModelImpl.fromJson;

  @override
  String get id;
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
  String get status; // scheduled, in_progress, finished, cancelled
  @override
  int get homeScore;
  @override
  int get awayScore;
  @override
  int get eloChange;
  @override
  String? get createdBy;
  @override
  DateTime? get createdAt;

  /// Create a copy of MatchModel
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$MatchModelImplCopyWith<_$MatchModelImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
