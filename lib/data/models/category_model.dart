import 'package:hive/hive.dart';
import 'package:json_annotation/json_annotation.dart';

part 'category_model.g.dart';

@HiveType(typeId: 3) // Ensure unique typeId
@JsonSerializable()
class Category {
  @HiveField(0)
  final int id;
  @HiveField(1)
  final String name;

  Category({
    required this.id,
    required this.name,
  });

  factory Category.fromJson(Map<String, dynamic> json) => _$CategoryFromJson(json);
  Map<String, dynamic> toJson() => _$CategoryToJson(this);
}
