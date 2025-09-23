// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'challenge_model.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
  'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models',
);

ChallengeModel _$ChallengeModelFromJson(Map<String, dynamic> json) {
  return _ChallengeModel.fromJson(json);
}

/// @nodoc
mixin _$ChallengeModel {
  String get id => throw _privateConstructorUsedError;
  String get challengerTeamId => throw _privateConstructorUsedError;
  String get challengedTeamId => throw _privateConstructorUsedError;
  String? get message => throw _privateConstructorUsedError;
  DateTime? get proposedDate => throw _privateConstructorUsedError;
  String? get canchaId => throw _privateConstructorUsedError;
  String? get sectorId => throw _privateConstructorUsedError;
  String get status =>
      throw _privateConstructorUsedError; // pending, accepted, rejected, expired
  String? get createdBy => throw _privateConstructorUsedError;
  DateTime? get createdAt => throw _privateConstructorUsedError;
  DateTime? get respondedAt => throw _privateConstructorUsedError;
  String? get respondedBy => throw _privateConstructorUsedError;
  String? get matchId => throw _privateConstructorUsedError;

  /// Serializes this ChallengeModel to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of ChallengeModel
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $ChallengeModelCopyWith<ChallengeModel> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $ChallengeModelCopyWith<$Res> {
  factory $ChallengeModelCopyWith(
    ChallengeModel value,
    $Res Function(ChallengeModel) then,
  ) = _$ChallengeModelCopyWithImpl<$Res, ChallengeModel>;
  @useResult
  $Res call({
    String id,
    String challengerTeamId,
    String challengedTeamId,
    String? message,
    DateTime? proposedDate,
    String? canchaId,
    String? sectorId,
    String status,
    String? createdBy,
    DateTime? createdAt,
    DateTime? respondedAt,
    String? respondedBy,
    String? matchId,
  });
}

/// @nodoc
class _$ChallengeModelCopyWithImpl<$Res, $Val extends ChallengeModel>
    implements $ChallengeModelCopyWith<$Res> {
  _$ChallengeModelCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of ChallengeModel
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? challengerTeamId = null,
    Object? challengedTeamId = null,
    Object? message = freezed,
    Object? proposedDate = freezed,
    Object? canchaId = freezed,
    Object? sectorId = freezed,
    Object? status = null,
    Object? createdBy = freezed,
    Object? createdAt = freezed,
    Object? respondedAt = freezed,
    Object? respondedBy = freezed,
    Object? matchId = freezed,
  }) {
    return _then(
      _value.copyWith(
            id:
                null == id
                    ? _value.id
                    : id // ignore: cast_nullable_to_non_nullable
                        as String,
            challengerTeamId:
                null == challengerTeamId
                    ? _value.challengerTeamId
                    : challengerTeamId // ignore: cast_nullable_to_non_nullable
                        as String,
            challengedTeamId:
                null == challengedTeamId
                    ? _value.challengedTeamId
                    : challengedTeamId // ignore: cast_nullable_to_non_nullable
                        as String,
            message:
                freezed == message
                    ? _value.message
                    : message // ignore: cast_nullable_to_non_nullable
                        as String?,
            proposedDate:
                freezed == proposedDate
                    ? _value.proposedDate
                    : proposedDate // ignore: cast_nullable_to_non_nullable
                        as DateTime?,
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
            status:
                null == status
                    ? _value.status
                    : status // ignore: cast_nullable_to_non_nullable
                        as String,
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
            respondedAt:
                freezed == respondedAt
                    ? _value.respondedAt
                    : respondedAt // ignore: cast_nullable_to_non_nullable
                        as DateTime?,
            respondedBy:
                freezed == respondedBy
                    ? _value.respondedBy
                    : respondedBy // ignore: cast_nullable_to_non_nullable
                        as String?,
            matchId:
                freezed == matchId
                    ? _value.matchId
                    : matchId // ignore: cast_nullable_to_non_nullable
                        as String?,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$ChallengeModelImplCopyWith<$Res>
    implements $ChallengeModelCopyWith<$Res> {
  factory _$$ChallengeModelImplCopyWith(
    _$ChallengeModelImpl value,
    $Res Function(_$ChallengeModelImpl) then,
  ) = __$$ChallengeModelImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    String id,
    String challengerTeamId,
    String challengedTeamId,
    String? message,
    DateTime? proposedDate,
    String? canchaId,
    String? sectorId,
    String status,
    String? createdBy,
    DateTime? createdAt,
    DateTime? respondedAt,
    String? respondedBy,
    String? matchId,
  });
}

/// @nodoc
class __$$ChallengeModelImplCopyWithImpl<$Res>
    extends _$ChallengeModelCopyWithImpl<$Res, _$ChallengeModelImpl>
    implements _$$ChallengeModelImplCopyWith<$Res> {
  __$$ChallengeModelImplCopyWithImpl(
    _$ChallengeModelImpl _value,
    $Res Function(_$ChallengeModelImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of ChallengeModel
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? challengerTeamId = null,
    Object? challengedTeamId = null,
    Object? message = freezed,
    Object? proposedDate = freezed,
    Object? canchaId = freezed,
    Object? sectorId = freezed,
    Object? status = null,
    Object? createdBy = freezed,
    Object? createdAt = freezed,
    Object? respondedAt = freezed,
    Object? respondedBy = freezed,
    Object? matchId = freezed,
  }) {
    return _then(
      _$ChallengeModelImpl(
        id:
            null == id
                ? _value.id
                : id // ignore: cast_nullable_to_non_nullable
                    as String,
        challengerTeamId:
            null == challengerTeamId
                ? _value.challengerTeamId
                : challengerTeamId // ignore: cast_nullable_to_non_nullable
                    as String,
        challengedTeamId:
            null == challengedTeamId
                ? _value.challengedTeamId
                : challengedTeamId // ignore: cast_nullable_to_non_nullable
                    as String,
        message:
            freezed == message
                ? _value.message
                : message // ignore: cast_nullable_to_non_nullable
                    as String?,
        proposedDate:
            freezed == proposedDate
                ? _value.proposedDate
                : proposedDate // ignore: cast_nullable_to_non_nullable
                    as DateTime?,
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
        status:
            null == status
                ? _value.status
                : status // ignore: cast_nullable_to_non_nullable
                    as String,
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
        respondedAt:
            freezed == respondedAt
                ? _value.respondedAt
                : respondedAt // ignore: cast_nullable_to_non_nullable
                    as DateTime?,
        respondedBy:
            freezed == respondedBy
                ? _value.respondedBy
                : respondedBy // ignore: cast_nullable_to_non_nullable
                    as String?,
        matchId:
            freezed == matchId
                ? _value.matchId
                : matchId // ignore: cast_nullable_to_non_nullable
                    as String?,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$ChallengeModelImpl implements _ChallengeModel {
  const _$ChallengeModelImpl({
    required this.id,
    required this.challengerTeamId,
    required this.challengedTeamId,
    this.message,
    this.proposedDate,
    this.canchaId,
    this.sectorId,
    this.status = 'pending',
    this.createdBy,
    this.createdAt,
    this.respondedAt,
    this.respondedBy,
    this.matchId,
  });

  factory _$ChallengeModelImpl.fromJson(Map<String, dynamic> json) =>
      _$$ChallengeModelImplFromJson(json);

  @override
  final String id;
  @override
  final String challengerTeamId;
  @override
  final String challengedTeamId;
  @override
  final String? message;
  @override
  final DateTime? proposedDate;
  @override
  final String? canchaId;
  @override
  final String? sectorId;
  @override
  @JsonKey()
  final String status;
  // pending, accepted, rejected, expired
  @override
  final String? createdBy;
  @override
  final DateTime? createdAt;
  @override
  final DateTime? respondedAt;
  @override
  final String? respondedBy;
  @override
  final String? matchId;

  @override
  String toString() {
    return 'ChallengeModel(id: $id, challengerTeamId: $challengerTeamId, challengedTeamId: $challengedTeamId, message: $message, proposedDate: $proposedDate, canchaId: $canchaId, sectorId: $sectorId, status: $status, createdBy: $createdBy, createdAt: $createdAt, respondedAt: $respondedAt, respondedBy: $respondedBy, matchId: $matchId)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$ChallengeModelImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.challengerTeamId, challengerTeamId) ||
                other.challengerTeamId == challengerTeamId) &&
            (identical(other.challengedTeamId, challengedTeamId) ||
                other.challengedTeamId == challengedTeamId) &&
            (identical(other.message, message) || other.message == message) &&
            (identical(other.proposedDate, proposedDate) ||
                other.proposedDate == proposedDate) &&
            (identical(other.canchaId, canchaId) ||
                other.canchaId == canchaId) &&
            (identical(other.sectorId, sectorId) ||
                other.sectorId == sectorId) &&
            (identical(other.status, status) || other.status == status) &&
            (identical(other.createdBy, createdBy) ||
                other.createdBy == createdBy) &&
            (identical(other.createdAt, createdAt) ||
                other.createdAt == createdAt) &&
            (identical(other.respondedAt, respondedAt) ||
                other.respondedAt == respondedAt) &&
            (identical(other.respondedBy, respondedBy) ||
                other.respondedBy == respondedBy) &&
            (identical(other.matchId, matchId) || other.matchId == matchId));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
    runtimeType,
    id,
    challengerTeamId,
    challengedTeamId,
    message,
    proposedDate,
    canchaId,
    sectorId,
    status,
    createdBy,
    createdAt,
    respondedAt,
    respondedBy,
    matchId,
  );

  /// Create a copy of ChallengeModel
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$ChallengeModelImplCopyWith<_$ChallengeModelImpl> get copyWith =>
      __$$ChallengeModelImplCopyWithImpl<_$ChallengeModelImpl>(
        this,
        _$identity,
      );

  @override
  Map<String, dynamic> toJson() {
    return _$$ChallengeModelImplToJson(this);
  }
}

abstract class _ChallengeModel implements ChallengeModel {
  const factory _ChallengeModel({
    required final String id,
    required final String challengerTeamId,
    required final String challengedTeamId,
    final String? message,
    final DateTime? proposedDate,
    final String? canchaId,
    final String? sectorId,
    final String status,
    final String? createdBy,
    final DateTime? createdAt,
    final DateTime? respondedAt,
    final String? respondedBy,
    final String? matchId,
  }) = _$ChallengeModelImpl;

  factory _ChallengeModel.fromJson(Map<String, dynamic> json) =
      _$ChallengeModelImpl.fromJson;

  @override
  String get id;
  @override
  String get challengerTeamId;
  @override
  String get challengedTeamId;
  @override
  String? get message;
  @override
  DateTime? get proposedDate;
  @override
  String? get canchaId;
  @override
  String? get sectorId;
  @override
  String get status; // pending, accepted, rejected, expired
  @override
  String? get createdBy;
  @override
  DateTime? get createdAt;
  @override
  DateTime? get respondedAt;
  @override
  String? get respondedBy;
  @override
  String? get matchId;

  /// Create a copy of ChallengeModel
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$ChallengeModelImplCopyWith<_$ChallengeModelImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
