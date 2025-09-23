import 'package:freezed_annotation/freezed_annotation.dart';

part 'cancha_model.freezed.dart';
part 'cancha_model.g.dart';

@freezed
class CanchaModel with _$CanchaModel {
  const factory CanchaModel({
    required String id,
    required String name,
    String? comunaId,
    String? address,
    String? fieldType, // futsal, football7, football11
    String? surfaceType, // cesped_natural, cesped_sintetico, cemento
    @Default(false) bool hasLighting,
    int? capacity,
    double? hourlyRate,
    String? contactPhone,
    @Default(true) bool isActive,
    required DateTime createdAt,
  }) = _CanchaModel;

  factory CanchaModel.fromJson(Map<String, dynamic> json) =>
      _$CanchaModelFromJson(json);
}
