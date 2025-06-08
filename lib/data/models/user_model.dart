// lib/data/models/user_model.dart
import 'package:hive/hive.dart';
import 'package:json_annotation/json_annotation.dart';

part 'user_model.g.dart'; // Hive 和 Json Serializable 的代码生成文件

@HiveType(typeId: 0) // HiveType 必须是唯一的
@JsonSerializable()
class UserModel extends HiveObject {
  @HiveField(0)
  final int id;
  @HiveField(1)
  final String name;
  @HiveField(2)
  final String email;
  @HiveField(3)
  final String avatar;
  @HiveField(4)
  final int age;
  @HiveField(5)
  final String? token; // 登录后获取的令牌

  UserModel({
    required this.id,
    required this.name,
    required this.email,
    this.avatar = "",
    this.age = 0,
    this.token,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) =>
      _$UserModelFromJson(json);

  Map<String, dynamic> toJson() => _$UserModelToJson(this);

  UserModel copyWith({
    int? id,
    String? name,
    String? email,
    String? avatar,
    int age = 0,
    String? token,
  }) {
    return UserModel(
      id: id ?? this.id,
      name: name ?? this.name,
      email: email ?? this.email,
      avatar: avatar ?? this.avatar,
      token: token ?? this.token,
    );
  }
}
