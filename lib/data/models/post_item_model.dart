// lib/data/models/post_item_model.dart
import 'package:hive/hive.dart';
// If you use json_serializable for other parts or for UserModel:
// import 'package:json_annotation/json_annotation.dart';
import 'package:ppx_client/data/models/user_model.dart'; // Ensure UserModel is Hive compatible

part 'post_item_model.g.dart'; // For Hive generator

// Helper functions for PostType serialization
int postTypeToInt(PostType type) {
  switch (type) {
    case PostType.text: return 0;
    case PostType.image: return 1;
    case PostType.video: return 2;
    case PostType.advertisement: return 3;
  }
}

PostType intToPostType(int type) {
  switch (type) {
    case 0: return PostType.text;
    case 1: return PostType.image;
    case 2: return PostType.video;
    case 3: return PostType.advertisement;
    default: throw ArgumentError('Unknown post type integer: $type');
  }
}

enum PostType {
  text,
  image,
  video,
  advertisement,
}

@HiveType(typeId: 1)
class PostItem extends HiveObject {
  @HiveField(0) // Now stores an integer ID
  final int id;

  @HiveField(1)
  final UserModel userInfo;

  @HiveField(2)
  final String? content;

  @HiveField(3)
  final List<String>? images;

  @HiveField(4)
  final String? videoUrl;

  @HiveField(5)
  final int likesCount;

  @HiveField(6)
  final int unLikesCount;

  @HiveField(7)
  final int commentsCount;

  @HiveField(8) // Stores PostType as an integer
  final int _postTypeAsInt;

  @HiveField(9)
  final bool isLiked;

  @HiveField(10)
  final bool isUnliked;

  @HiveField(11) // Stores timestamp as integer (millisecondsSinceEpoch)
  final int _timestampMillisecondsSinceEpoch;

  @HiveField(12)
  final int? categoryId;

  // Public getters for convenient access
  PostType get postType => intToPostType(_postTypeAsInt);
  DateTime get timestamp => DateTime.fromMillisecondsSinceEpoch(_timestampMillisecondsSinceEpoch);

  // Primary constructor: Used by Hive and can be used internally.
  PostItem({
    required this.id, // Changed to int
    required this.userInfo,
    this.content,
    this.images,
    this.videoUrl,
    required this.likesCount,
    required this.unLikesCount,
    required this.commentsCount,
    required int postTypeAsIntInput,
    this.isLiked = false,
    this.isUnliked = false,
    required int timestampMillisecondsSinceEpochInput,
    this.categoryId,
  })  : _postTypeAsInt = postTypeAsIntInput,
        _timestampMillisecondsSinceEpoch = timestampMillisecondsSinceEpochInput;

  // Factory constructor for creating PostItem with DateTime and PostType objects
  factory PostItem.create({
    required int id, // Changed to int
    required UserModel userInfo,
    String? content,
    List<String>? images,
    String? videoUrl,
    required int likesCount,
    required int unLikesCount,
    required int commentsCount,
    required PostType postType,
    bool isLiked = false,
    bool isUnliked = false,
    required DateTime timestamp,
    int? categoryId,
  }) {
    return PostItem(
      id: id,
      userInfo: userInfo,
      content: content,
      images: images,
      videoUrl: videoUrl,
      likesCount: likesCount,
      unLikesCount: unLikesCount,
      commentsCount: commentsCount,
      postTypeAsIntInput: postTypeToInt(postType),
      isLiked: isLiked,
      isUnliked: isUnliked,
      timestampMillisecondsSinceEpochInput: timestamp.millisecondsSinceEpoch,
      categoryId: categoryId,
    );
  }

  PostItem copyWith({
    int? id, // Changed to int?
    UserModel? userInfo,
    String? content,
    List<String>? images,
    String? videoUrl,
    int? likesCount,
    int? unLikesCount,
    int? commentsCount,
    PostType? postType,
    bool? isLiked,
    bool? isUnliked,
    DateTime? timestamp,
    int? categoryId,
  }) {
    return PostItem.create(
      id: id ?? this.id,
      userInfo: userInfo ?? this.userInfo,
      content: content ?? this.content,
      images: images ?? this.images,
      videoUrl: videoUrl ?? this.videoUrl,
      likesCount: likesCount ?? this.likesCount,
      unLikesCount: unLikesCount ?? this.unLikesCount,
      commentsCount: commentsCount ?? this.commentsCount,
      postType: postType ?? this.postType,
      isLiked: isLiked ?? this.isLiked,
      isUnliked: isUnliked ?? this.isUnliked,
      timestamp: timestamp ?? this.timestamp,
      categoryId: categoryId ?? this.categoryId,
    );
  }

  // Factory constructor for JSON deserialization
  factory PostItem.fromJson(Map<String, dynamic> json) {
    return PostItem.create(
      id: json['id'] as int, // Changed to parse as int
      userInfo: UserModel.fromJson(json['userInfo'] as Map<String, dynamic>),
      content: json['content'] as String?,
      images: (json['images'] as List<dynamic>?)?.map((e) => e as String).toList(),
      videoUrl: json['videoUrl'] as String?,
      likesCount: json['likesCount'] as int,
      unLikesCount: json['unLikesCount'] as int,
      commentsCount: json['commentsCount'] as int,
      postType: intToPostType(json['postType'] as int),
      isLiked: json['isLiked'] as bool? ?? false,
      isUnliked: json['isUnliked'] as bool? ?? false,
      timestamp: DateTime.fromMillisecondsSinceEpoch(json['timestamp'] as int),
      categoryId: json['categoryId'] as int?,
    );
  }

  // Method for JSON serialization
  Map<String, dynamic> toJson() {
    return {
      'id': id, // Will be serialized as int
      'userInfo': userInfo.toJson(),
      'content': content,
      'images': images,
      'videoUrl': videoUrl,
      'likesCount': likesCount,
      'unLikesCount': unLikesCount,
      'commentsCount': commentsCount,
      'postType': postTypeToInt(postType),
      'isLiked': isLiked,
      'isUnliked': isUnliked,
      'timestamp': timestamp.millisecondsSinceEpoch,
      'categoryId': categoryId,
    };
  }
}