// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'comuna_model.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
  'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models',
);

ComunaModel _$ComunaModelFromJson(Map<String, dynamic> json) {
  return _ComunaModel.fromJson(json);
}

/// @nodoc
mixin _$ComunaModel {
  String get id => throw _privateConstructorUsedError;
  String get name => throw _privateConstructorUsedError;
  String get regionId => throw _privateConstructorUsedError;
  bool get isActive => throw _privateConstructorUsedError;
  DateTime get createdAt => throw _privateConstructorUsedError;

  /// Serializes this ComunaModel to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of ComunaModel
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $ComunaModelCopyWith<ComunaModel> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $ComunaModelCopyWith<$Res> {
  factory $ComunaModelCopyWith(
    ComunaModel value,
    $Res Function(ComunaModel) then,
  ) = _$ComunaModelCopyWithImpl<$Res, ComunaModel>;
  @useResult
  $Res call({
    String id,
    String name,
    String regionId,
    bool isActive,
    DateTime createdAt,
  });
}

/// @nodoc
class _$ComunaModelCopyWithImpl<$Res, $Val extends ComunaModel>
    implements $ComunaModelCopyWith<$Res> {
  _$ComunaModelCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of ComunaModel
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? name = null,
    Object? regionId = null,
    Object? isActive = null,
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
            regionId:
                null == regionId
                    ? _value.regionId
                    : regionId // ignore: cast_nullable_to_non_nullable
                        as String,
            isActive:
                null == isActive
                    ? _value.isActive
                    : isActive // ignore: cast_nullable_to_non_nullable
                        as bool,
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
abstract class _$$ComunaModelImplCopyWith<$Res>
    implements $ComunaModelCopyWith<$Res> {
  factory _$$ComunaModelImplCopyWith(
    _$ComunaModelImpl value,
    $Res Function(_$ComunaModelImpl) then,
  ) = __$$ComunaModelImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    String id,
    String name,
    String regionId,
    bool isActive,
    DateTime createdAt,
  });
}

/// @nodoc
class __$$ComunaModelImplCopyWithImpl<$Res>
    extends _$ComunaModelCopyWithImpl<$Res, _$ComunaModelImpl>
    implements _$$ComunaModelImplCopyWith<$Res> {
  __$$ComunaModelImplCopyWithImpl(
    _$ComunaModelImpl _value,
    $Res Function(_$ComunaModelImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of ComunaModel
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? name = null,
    Object? regionId = null,
    Object? isActive = null,
    Object? createdAt = null,
  }) {
    return _then(
      _$ComunaModelImpl(
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
        regionId:
            null == regionId
                ? _value.regionId
                : regionId // ignore: cast_nullable_to_non_nullable
                    as String,
        isActive:
            null == isActive
                ? _value.isActive
                : isActive // ignore: cast_nullable_to_non_nullable
                    as bool,
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
class _$ComunaModelImpl implements _ComunaModel {
  const _$ComunaModelImpl({
    required this.id,
    required this.name,
    required this.regionId,
    this.isActive = false,
    required this.createdAt,
  });

  factory _$ComunaModelImpl.fromJson(Map<String, dynamic> json) =>
      _$$ComunaModelImplFromJson(json);

  @override
  final String id;
  @override
  final String name;
  @override
  final String regionId;
  @override
  @JsonKey()
  final bool isActive;
  @override
  final DateTime createdAt;

  @override
  String toString() {
    return 'ComunaModel(id: $id, name: $name, regionId: $regionId, isActive: $isActive, createdAt: $createdAt)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$ComunaModelImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.name, name) || other.name == name) &&
            (identical(other.regionId, regionId) ||
                other.regionId == regionId) &&
            (identical(other.isActive, isActive) ||
                other.isActive == isActive) &&
            (identical(other.createdAt, createdAt) ||
                other.createdAt == createdAt));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode =>
      Object.hash(runtimeType, id, name, regionId, isActive, createdAt);

  /// Create a copy of ComunaModel
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$ComunaModelImplCopyWith<_$ComunaModelImpl> get copyWith =>
      __$$ComunaModelImplCopyWithImpl<_$ComunaModelImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$ComunaModelImplToJson(this);
  }
}

abstract class _ComunaModel implements ComunaModel {
  const factory _ComunaModel({
    required final String id,
    required final String name,
    required final String regionId,
    final bool isActive,
    required final DateTime createdAt,
  }) = _$ComunaModelImpl;

  factory _ComunaModel.fromJson(Map<String, dynamic> json) =
      _$ComunaModelImpl.fromJson;

  @override
  String get id;
  @override
  String get name;
  @override
  String get regionId;
  @override
  bool get isActive;
  @override
  DateTime get createdAt;

  /// Create a copy of ComunaModel
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$ComunaModelImplCopyWith<_$ComunaModelImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
