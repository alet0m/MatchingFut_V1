// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'sector_model.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
  'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models',
);

SectorModel _$SectorModelFromJson(Map<String, dynamic> json) {
  return _SectorModel.fromJson(json);
}

/// @nodoc
mixin _$SectorModel {
  String get id => throw _privateConstructorUsedError;
  String get name => throw _privateConstructorUsedError;
  String get comunaId => throw _privateConstructorUsedError;
  String? get description => throw _privateConstructorUsedError;
  String? get currentChampionId => throw _privateConstructorUsedError;
  int get totalMatches => throw _privateConstructorUsedError;
  DateTime get createdAt => throw _privateConstructorUsedError;

  /// Serializes this SectorModel to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of SectorModel
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $SectorModelCopyWith<SectorModel> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $SectorModelCopyWith<$Res> {
  factory $SectorModelCopyWith(
    SectorModel value,
    $Res Function(SectorModel) then,
  ) = _$SectorModelCopyWithImpl<$Res, SectorModel>;
  @useResult
  $Res call({
    String id,
    String name,
    String comunaId,
    String? description,
    String? currentChampionId,
    int totalMatches,
    DateTime createdAt,
  });
}

/// @nodoc
class _$SectorModelCopyWithImpl<$Res, $Val extends SectorModel>
    implements $SectorModelCopyWith<$Res> {
  _$SectorModelCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of SectorModel
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? name = null,
    Object? comunaId = null,
    Object? description = freezed,
    Object? currentChampionId = freezed,
    Object? totalMatches = null,
    Object? createdAt = null,
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
            comunaId:
                null == comunaId
                    ? _value.comunaId
                    : comunaId // ignore: cast_nullable_to_non_nullable
                        as String,
            description:
                freezed == description
                    ? _value.description
                    : description // ignore: cast_nullable_to_non_nullable
                        as String?,
            currentChampionId:
                freezed == currentChampionId
                    ? _value.currentChampionId
                    : currentChampionId // ignore: cast_nullable_to_non_nullable
                        as String?,
            totalMatches:
                null == totalMatches
                    ? _value.totalMatches
                    : totalMatches // ignore: cast_nullable_to_non_nullable
                        as int,
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
abstract class _$$SectorModelImplCopyWith<$Res>
    implements $SectorModelCopyWith<$Res> {
  factory _$$SectorModelImplCopyWith(
    _$SectorModelImpl value,
    $Res Function(_$SectorModelImpl) then,
  ) = __$$SectorModelImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    String id,
    String name,
    String comunaId,
    String? description,
    String? currentChampionId,
    int totalMatches,
    DateTime createdAt,
  });
}

/// @nodoc
class __$$SectorModelImplCopyWithImpl<$Res>
    extends _$SectorModelCopyWithImpl<$Res, _$SectorModelImpl>
    implements _$$SectorModelImplCopyWith<$Res> {
  __$$SectorModelImplCopyWithImpl(
    _$SectorModelImpl _value,
    $Res Function(_$SectorModelImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of SectorModel
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? name = null,
    Object? comunaId = null,
    Object? description = freezed,
    Object? currentChampionId = freezed,
    Object? totalMatches = null,
    Object? createdAt = null,
  }) {
    return _then(
      _$SectorModelImpl(
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
        comunaId:
            null == comunaId
                ? _value.comunaId
                : comunaId // ignore: cast_nullable_to_non_nullable
                    as String,
        description:
            freezed == description
                ? _value.description
                : description // ignore: cast_nullable_to_non_nullable
                    as String?,
        currentChampionId:
            freezed == currentChampionId
                ? _value.currentChampionId
                : currentChampionId // ignore: cast_nullable_to_non_nullable
                    as String?,
        totalMatches:
            null == totalMatches
                ? _value.totalMatches
                : totalMatches // ignore: cast_nullable_to_non_nullable
                    as int,
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
class _$SectorModelImpl implements _SectorModel {
  const _$SectorModelImpl({
    required this.id,
    required this.name,
    required this.comunaId,
    this.description,
    this.currentChampionId,
    this.totalMatches = 0,
    required this.createdAt,
  });

  factory _$SectorModelImpl.fromJson(Map<String, dynamic> json) =>
      _$$SectorModelImplFromJson(json);

  @override
  final String id;
  @override
  final String name;
  @override
  final String comunaId;
  @override
  final String? description;
  @override
  final String? currentChampionId;
  @override
  @JsonKey()
  final int totalMatches;
  @override
  final DateTime createdAt;

  @override
  String toString() {
    return 'SectorModel(id: $id, name: $name, comunaId: $comunaId, description: $description, currentChampionId: $currentChampionId, totalMatches: $totalMatches, createdAt: $createdAt)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$SectorModelImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.name, name) || other.name == name) &&
            (identical(other.comunaId, comunaId) ||
                other.comunaId == comunaId) &&
            (identical(other.description, description) ||
                other.description == description) &&
            (identical(other.currentChampionId, currentChampionId) ||
                other.currentChampionId == currentChampionId) &&
            (identical(other.totalMatches, totalMatches) ||
                other.totalMatches == totalMatches) &&
            (identical(other.createdAt, createdAt) ||
                other.createdAt == createdAt));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
    runtimeType,
    id,
    name,
    comunaId,
    description,
    currentChampionId,
    totalMatches,
    createdAt,
  );

  /// Create a copy of SectorModel
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$SectorModelImplCopyWith<_$SectorModelImpl> get copyWith =>
      __$$SectorModelImplCopyWithImpl<_$SectorModelImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$SectorModelImplToJson(this);
  }
}

abstract class _SectorModel implements SectorModel {
  const factory _SectorModel({
    required final String id,
    required final String name,
    required final String comunaId,
    final String? description,
    final String? currentChampionId,
    final int totalMatches,
    required final DateTime createdAt,
  }) = _$SectorModelImpl;

  factory _SectorModel.fromJson(Map<String, dynamic> json) =
      _$SectorModelImpl.fromJson;

  @override
  String get id;
  @override
  String get name;
  @override
  String get comunaId;
  @override
  String? get description;
  @override
  String? get currentChampionId;
  @override
  int get totalMatches;
  @override
  DateTime get createdAt;

  /// Create a copy of SectorModel
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$SectorModelImplCopyWith<_$SectorModelImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
