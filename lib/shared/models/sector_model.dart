import 'package:freezed_annotation/freezed_annotation.dart';

part 'sector_model.freezed.dart';
part 'sector_model.g.dart';

@freezed
class SectorModel with _$SectorModel {
  const factory SectorModel({
    required String id,
    required String name,
    required String comunaId,
    String? description,
    String? currentChampionId,
    @Default(0) int totalMatches,
    required DateTime createdAt,
  }) = _SectorModel;

  factory SectorModel.fromJson(Map<String, dynamic> json) =>
      _$SectorModelFromJson(json);
}
