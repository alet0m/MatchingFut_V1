// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'match_event_model.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
  'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models',
);

MatchEvent _$MatchEventFromJson(Map<String, dynamic> json) {
  return _MatchEvent.fromJson(json);
}

/// @nodoc
mixin _$MatchEvent {
  String get id => throw _privateConstructorUsedError;
  String get matchId => throw _privateConstructorUsedError;
  String get eventType =>
      throw _privateConstructorUsedError; // 'goal', 'yellow_card', 'red_card', 'substitution', etc.
  String? get playerId => throw _privateConstructorUsedError;
  String get teamId => throw _privateConstructorUsedError;
  int get minute => throw _privateConstructorUsedError;
  String? get description => throw _privateConstructorUsedError;
  Map<String, dynamic>? get extraData => throw _privateConstructorUsedError;
  DateTime get createdAt => throw _privateConstructorUsedError;

  /// Serializes this MatchEvent to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of MatchEvent
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $MatchEventCopyWith<MatchEvent> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $MatchEventCopyWith<$Res> {
  factory $MatchEventCopyWith(
    MatchEvent value,
    $Res Function(MatchEvent) then,
  ) = _$MatchEventCopyWithImpl<$Res, MatchEvent>;
  @useResult
  $Res call({
    String id,
    String matchId,
    String eventType,
    String? playerId,
    String teamId,
    int minute,
    String? description,
    Map<String, dynamic>? extraData,
    DateTime createdAt,
  });
}

/// @nodoc
class _$MatchEventCopyWithImpl<$Res, $Val extends MatchEvent>
    implements $MatchEventCopyWith<$Res> {
  _$MatchEventCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of MatchEvent
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? matchId = null,
    Object? eventType = null,
    Object? playerId = freezed,
    Object? teamId = null,
    Object? minute = null,
    Object? description = freezed,
    Object? extraData = freezed,
    Object? createdAt = null,
  }) {
    return _then(
      _value.copyWith(
            id:
                null == id
                    ? _value.id
                    : id // ignore: cast_nullable_to_non_nullable
                        as String,
            matchId:
                null == matchId
                    ? _value.matchId
                    : matchId // ignore: cast_nullable_to_non_nullable
                        as String,
            eventType:
                null == eventType
                    ? _value.eventType
                    : eventType // ignore: cast_nullable_to_non_nullable
                        as String,
            playerId:
                freezed == playerId
                    ? _value.playerId
                    : playerId // ignore: cast_nullable_to_non_nullable
                        as String?,
            teamId:
                null == teamId
                    ? _value.teamId
                    : teamId // ignore: cast_nullable_to_non_nullable
                        as String,
            minute:
                null == minute
                    ? _value.minute
                    : minute // ignore: cast_nullable_to_non_nullable
                        as int,
            description:
                freezed == description
                    ? _value.description
                    : description // ignore: cast_nullable_to_non_nullable
                        as String?,
            extraData:
                freezed == extraData
                    ? _value.extraData
                    : extraData // ignore: cast_nullable_to_non_nullable
                        as Map<String, dynamic>?,
            createdAt:
                null == createdAt
                    ? _value.createdAt
                    : createdAt // ignore: cast_nullable_to_non_nullable
                        as DateTime,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$MatchEventImplCopyWith<$Res>
    implements $MatchEventCopyWith<$Res> {
  factory _$$MatchEventImplCopyWith(
    _$MatchEventImpl value,
    $Res Function(_$MatchEventImpl) then,
  ) = __$$MatchEventImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    String id,
    String matchId,
    String eventType,
    String? playerId,
    String teamId,
    int minute,
    String? description,
    Map<String, dynamic>? extraData,
    DateTime createdAt,
  });
}

/// @nodoc
class __$$MatchEventImplCopyWithImpl<$Res>
    extends _$MatchEventCopyWithImpl<$Res, _$MatchEventImpl>
    implements _$$MatchEventImplCopyWith<$Res> {
  __$$MatchEventImplCopyWithImpl(
    _$MatchEventImpl _value,
    $Res Function(_$MatchEventImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of MatchEvent
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? matchId = null,
    Object? eventType = null,
    Object? playerId = freezed,
    Object? teamId = null,
    Object? minute = null,
    Object? description = freezed,
    Object? extraData = freezed,
    Object? createdAt = null,
  }) {
    return _then(
      _$MatchEventImpl(
        id:
            null == id
                ? _value.id
                : id // ignore: cast_nullable_to_non_nullable
                    as String,
        matchId:
            null == matchId
                ? _value.matchId
                : matchId // ignore: cast_nullable_to_non_nullable
                    as String,
        eventType:
            null == eventType
                ? _value.eventType
                : eventType // ignore: cast_nullable_to_non_nullable
                    as String,
        playerId:
            freezed == playerId
                ? _value.playerId
                : playerId // ignore: cast_nullable_to_non_nullable
                    as String?,
        teamId:
            null == teamId
                ? _value.teamId
                : teamId // ignore: cast_nullable_to_non_nullable
                    as String,
        minute:
            null == minute
                ? _value.minute
                : minute // ignore: cast_nullable_to_non_nullable
                    as int,
        description:
            freezed == description
                ? _value.description
                : description // ignore: cast_nullable_to_non_nullable
                    as String?,
        extraData:
            freezed == extraData
                ? _value._extraData
                : extraData // ignore: cast_nullable_to_non_nullable
                    as Map<String, dynamic>?,
        createdAt:
            null == createdAt
                ? _value.createdAt
                : createdAt // ignore: cast_nullable_to_non_nullable
                    as DateTime,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$MatchEventImpl implements _MatchEvent {
  const _$MatchEventImpl({
    required this.id,
    required this.matchId,
    required this.eventType,
    this.playerId,
    required this.teamId,
    required this.minute,
    this.description,
    final Map<String, dynamic>? extraData,
    required this.createdAt,
  }) : _extraData = extraData;

  factory _$MatchEventImpl.fromJson(Map<String, dynamic> json) =>
      _$$MatchEventImplFromJson(json);

  @override
  final String id;
  @override
  final String matchId;
  @override
  final String eventType;
  // 'goal', 'yellow_card', 'red_card', 'substitution', etc.
  @override
  final String? playerId;
  @override
  final String teamId;
  @override
  final int minute;
  @override
  final String? description;
  final Map<String, dynamic>? _extraData;
  @override
  Map<String, dynamic>? get extraData {
    final value = _extraData;
    if (value == null) return null;
    if (_extraData is EqualUnmodifiableMapView) return _extraData;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableMapView(value);
  }

  @override
  final DateTime createdAt;

  @override
  String toString() {
    return 'MatchEvent(id: $id, matchId: $matchId, eventType: $eventType, playerId: $playerId, teamId: $teamId, minute: $minute, description: $description, extraData: $extraData, createdAt: $createdAt)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$MatchEventImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.matchId, matchId) || other.matchId == matchId) &&
            (identical(other.eventType, eventType) ||
                other.eventType == eventType) &&
            (identical(other.playerId, playerId) ||
                other.playerId == playerId) &&
            (identical(other.teamId, teamId) || other.teamId == teamId) &&
            (identical(other.minute, minute) || other.minute == minute) &&
            (identical(other.description, description) ||
                other.description == description) &&
            const DeepCollectionEquality().equals(
              other._extraData,
              _extraData,
            ) &&
            (identical(other.createdAt, createdAt) ||
                other.createdAt == createdAt));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
    runtimeType,
    id,
    matchId,
    eventType,
    playerId,
    teamId,
    minute,
    description,
    const DeepCollectionEquality().hash(_extraData),
    createdAt,
  );

  /// Create a copy of MatchEvent
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$MatchEventImplCopyWith<_$MatchEventImpl> get copyWith =>
      __$$MatchEventImplCopyWithImpl<_$MatchEventImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$MatchEventImplToJson(this);
  }
}

abstract class _MatchEvent implements MatchEvent {
  const factory _MatchEvent({
    required final String id,
    required final String matchId,
    required final String eventType,
    final String? playerId,
    required final String teamId,
    required final int minute,
    final String? description,
    final Map<String, dynamic>? extraData,
    required final DateTime createdAt,
  }) = _$MatchEventImpl;

  factory _MatchEvent.fromJson(Map<String, dynamic> json) =
      _$MatchEventImpl.fromJson;

  @override
  String get id;
  @override
  String get matchId;
  @override
  String get eventType; // 'goal', 'yellow_card', 'red_card', 'substitution', etc.
  @override
  String? get playerId;
  @override
  String get teamId;
  @override
  int get minute;
  @override
  String? get description;
  @override
  Map<String, dynamic>? get extraData;
  @override
  DateTime get createdAt;

  /// Create a copy of MatchEvent
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$MatchEventImplCopyWith<_$MatchEventImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
