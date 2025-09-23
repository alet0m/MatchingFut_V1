import 'package:freezed_annotation/freezed_annotation.dart';

part 'comuna_model.freezed.dart';
part 'comuna_model.g.dart';

@freezed
class ComunaModel with _$ComunaModel {
  const factory ComunaModel({
    required String id,
    required String name,
    required String regionId,
    @Default(false) bool isActive,
    required DateTime createdAt,
  }) = _ComunaModel;

  factory ComunaModel.fromJson(Map<String, dynamic> json) =>
      _$ComunaModelFromJson(json);
}
