// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'package:json_annotation/json_annotation.dart';

part 'poster_photo_model.g.dart';

@JsonSerializable()
class PosterPhotoModel {
  String id;
  String imageUrl;
  String thumbnailUrl;
  DateTime createdAt;

  PosterPhotoModel({
    required this.id,
    required this.imageUrl,
    required this.thumbnailUrl,
    required this.createdAt,
  });

  factory PosterPhotoModel.fromJson(Map<String, dynamic> json) => _$PosterPhotoModelFromJson(json);

  Map<String, dynamic> toJson() => _$PosterPhotoModelToJson(this);

  PosterPhotoModel copyWith({
    String? id,
    String? imageUrl,
    String? thumbnailUrl,
    DateTime? createdAt,
  }) {
    return PosterPhotoModel(
      id: id ?? this.id,
      imageUrl: imageUrl ?? this.imageUrl,
      thumbnailUrl: thumbnailUrl ?? this.thumbnailUrl,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}
