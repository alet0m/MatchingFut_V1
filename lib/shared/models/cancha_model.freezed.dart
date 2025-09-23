// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'cancha_model.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
  'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models',
);

CanchaModel _$CanchaModelFromJson(Map<String, dynamic> json) {
  return _CanchaModel.fromJson(json);
}

/// @nodoc
mixin _$CanchaModel {
  String get id => throw _privateConstructorUsedError;
  String get name => throw _privateConstructorUsedError;
  String? get comunaId => throw _privateConstructorUsedError;
  String? get address => throw _privateConstructorUsedError;
  String? get fieldType =>
      throw _privateConstructorUsedError; // futsal, football7, football11
  String? get surfaceType =>
      throw _privateConstructorUsedError; // cesped_natural, cesped_sintetico, cemento
  bool get hasLighting => throw _privateConstructorUsedError;
  int? get capacity => throw _privateConstructorUsedError;
  double? get hourlyRate => throw _privateConstructorUsedError;
  String? get contactPhone => throw _privateConstructorUsedError;
  bool get isActive => throw _privateConstructorUsedError;
  DateTime get createdAt => throw _privateConstructorUsedError;

  /// Serializes this CanchaModel to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of CanchaModel
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $CanchaModelCopyWith<CanchaModel> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $CanchaModelCopyWith<$Res> {
  factory $CanchaModelCopyWith(
    CanchaModel value,
    $Res Function(CanchaModel) then,
  ) = _$CanchaModelCopyWithImpl<$Res, CanchaModel>;
  @useResult
  $Res call({
    String id,
    String name,
    String? comunaId,
    String? address,
    String? fieldType,
    String? surfaceType,
    bool hasLighting,
    int? capacity,
    double? hourlyRate,
    String? contactPhone,
    bool isActive,
    DateTime createdAt,
  });
}

/// @nodoc
class _$CanchaModelCopyWithImpl<$Res, $Val extends CanchaModel>
    implements $CanchaModelCopyWith<$Res> {
  _$CanchaModelCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of CanchaModel
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? name = null,
    Object? comunaId = freezed,
    Object? address = freezed,
    Object? fieldType = freezed,
    Object? surfaceType = freezed,
    Object? hasLighting = null,
    Object? capacity = freezed,
    Object? hourlyRate = freezed,
    Object? contactPhone = freezed,
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
            comunaId:
                freezed == comunaId
                    ? _value.comunaId
                    : comunaId // ignore: cast_nullable_to_non_nullable
                        as String?,
            address:
                freezed == address
                    ? _value.address
                    : address // ignore: cast_nullable_to_non_nullable
                        as String?,
            fieldType:
                freezed == fieldType
                    ? _value.fieldType
                    : fieldType // ignore: cast_nullable_to_non_nullable
                        as String?,
            surfaceType:
                freezed == surfaceType
                    ? _value.surfaceType
                    : surfaceType // ignore: cast_nullable_to_non_nullable
                        as String?,
            hasLighting:
                null == hasLighting
                    ? _value.hasLighting
                    : hasLighting // ignore: cast_nullable_to_non_nullable
                        as bool,
            capacity:
                freezed == capacity
                    ? _value.capacity
                    : capacity // ignore: cast_nullable_to_non_nullable
                        as int?,
            hourlyRate:
                freezed == hourlyRate
                    ? _value.hourlyRate
                    : hourlyRate // ignore: cast_nullable_to_non_nullable
                        as double?,
            contactPhone:
                freezed == contactPhone
                    ? _value.contactPhone
                    : contactPhone // ignore: cast_nullable_to_non_nullable
                        as String?,
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
abstract class _$$CanchaModelImplCopyWith<$Res>
    implements $CanchaModelCopyWith<$Res> {
  factory _$$CanchaModelImplCopyWith(
    _$CanchaModelImpl value,
    $Res Function(_$CanchaModelImpl) then,
  ) = __$$CanchaModelImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    String id,
    String name,
    String? comunaId,
    String? address,
    String? fieldType,
    String? surfaceType,
    bool hasLighting,
    int? capacity,
    double? hourlyRate,
    String? contactPhone,
    bool isActive,
    DateTime createdAt,
  });
}

/// @nodoc
class __$$CanchaModelImplCopyWithImpl<$Res>
    extends _$CanchaModelCopyWithImpl<$Res, _$CanchaModelImpl>
    implements _$$CanchaModelImplCopyWith<$Res> {
  __$$CanchaModelImplCopyWithImpl(
    _$CanchaModelImpl _value,
    $Res Function(_$CanchaModelImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of CanchaModel
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? name = null,
    Object? comunaId = freezed,
    Object? address = freezed,
    Object? fieldType = freezed,
    Object? surfaceType = freezed,
    Object? hasLighting = null,
    Object? capacity = freezed,
    Object? hourlyRate = freezed,
    Object? contactPhone = freezed,
    Object? isActive = null,
    Object? createdAt = null,
  }) {
    return _then(
      _$CanchaModelImpl(
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
            freezed == comunaId
                ? _value.comunaId
                : comunaId // ignore: cast_nullable_to_non_nullable
                    as String?,
        address:
            freezed == address
                ? _value.address
                : address // ignore: cast_nullable_to_non_nullable
                    as String?,
        fieldType:
            freezed == fieldType
                ? _value.fieldType
                : fieldType // ignore: cast_nullable_to_non_nullable
                    as String?,
        surfaceType:
            freezed == surfaceType
                ? _value.surfaceType
                : surfaceType // ignore: cast_nullable_to_non_nullable
                    as String?,
        hasLighting:
            null == hasLighting
                ? _value.hasLighting
                : hasLighting // ignore: cast_nullable_to_non_nullable
                    as bool,
        capacity:
            freezed == capacity
                ? _value.capacity
                : capacity // ignore: cast_nullable_to_non_nullable
                    as int?,
        hourlyRate:
            freezed == hourlyRate
                ? _value.hourlyRate
                : hourlyRate // ignore: cast_nullable_to_non_nullable
                    as double?,
        contactPhone:
            freezed == contactPhone
                ? _value.contactPhone
                : contactPhone // ignore: cast_nullable_to_non_nullable
                    as String?,
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
class _$CanchaModelImpl implements _CanchaModel {
  const _$CanchaModelImpl({
    required this.id,
    required this.name,
    this.comunaId,
    this.address,
    this.fieldType,
    this.surfaceType,
    this.hasLighting = false,
    this.capacity,
    this.hourlyRate,
    this.contactPhone,
    this.isActive = true,
    required this.createdAt,
  });

  factory _$CanchaModelImpl.fromJson(Map<String, dynamic> json) =>
      _$$CanchaModelImplFromJson(json);

  @override
  final String id;
  @override
  final String name;
  @override
  final String? comunaId;
  @override
  final String? address;
  @override
  final String? fieldType;
  // futsal, football7, football11
  @override
  final String? surfaceType;
  // cesped_natural, cesped_sintetico, cemento
  @override
  @JsonKey()
  final bool hasLighting;
  @override
  final int? capacity;
  @override
  final double? hourlyRate;
  @override
  final String? contactPhone;
  @override
  @JsonKey()
  final bool isActive;
  @override
  final DateTime createdAt;

  @override
  String toString() {
    return 'CanchaModel(id: $id, name: $name, comunaId: $comunaId, address: $address, fieldType: $fieldType, surfaceType: $surfaceType, hasLighting: $hasLighting, capacity: $capacity, hourlyRate: $hourlyRate, contactPhone: $contactPhone, isActive: $isActive, createdAt: $createdAt)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$CanchaModelImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.name, name) || other.name == name) &&
            (identical(other.comunaId, comunaId) ||
                other.comunaId == comunaId) &&
            (identical(other.address, address) || other.address == address) &&
            (identical(other.fieldType, fieldType) ||
                other.fieldType == fieldType) &&
            (identical(other.surfaceType, surfaceType) ||
                other.surfaceType == surfaceType) &&
            (identical(other.hasLighting, hasLighting) ||
                other.hasLighting == hasLighting) &&
            (identical(other.capacity, capacity) ||
                other.capacity == capacity) &&
            (identical(other.hourlyRate, hourlyRate) ||
                other.hourlyRate == hourlyRate) &&
            (identical(other.contactPhone, contactPhone) ||
                other.contactPhone == contactPhone) &&
            (identical(other.isActive, isActive) ||
                other.isActive == isActive) &&
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
    address,
    fieldType,
    surfaceType,
    hasLighting,
    capacity,
    hourlyRate,
    contactPhone,
    isActive,
    createdAt,
  );

  /// Create a copy of CanchaModel
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$CanchaModelImplCopyWith<_$CanchaModelImpl> get copyWith =>
      __$$CanchaModelImplCopyWithImpl<_$CanchaModelImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$CanchaModelImplToJson(this);
  }
}

abstract class _CanchaModel implements CanchaModel {
  const factory _CanchaModel({
    required final String id,
    required final String name,
    final String? comunaId,
    final String? address,
    final String? fieldType,
    final String? surfaceType,
    final bool hasLighting,
    final int? capacity,
    final double? hourlyRate,
    final String? contactPhone,
    final bool isActive,
    required final DateTime createdAt,
  }) = _$CanchaModelImpl;

  factory _CanchaModel.fromJson(Map<String, dynamic> json) =
      _$CanchaModelImpl.fromJson;

  @override
  String get id;
  @override
  String get name;
  @override
  String? get comunaId;
  @override
  String? get address;
  @override
  String? get fieldType; // futsal, football7, football11
  @override
  String? get surfaceType; // cesped_natural, cesped_sintetico, cemento
  @override
  bool get hasLighting;
  @override
  int? get capacity;
  @override
  double? get hourlyRate;
  @override
  String? get contactPhone;
  @override
  bool get isActive;
  @override
  DateTime get createdAt;

  /// Create a copy of CanchaModel
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$CanchaModelImplCopyWith<_$CanchaModelImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
