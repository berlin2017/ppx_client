import 'package:ppx_client/data/models/user_model.dart';

class Comment {
  final int id;
  final String content;
  final int postId;
  final int userId;
  final int? parentId;
  final int timestamp;
  final UserModel? userInfo;
  final List<Comment> replies;

  Comment({
    required this.id,
    required this.content,
    required this.postId,
    required this.userId,
    this.parentId,
    required this.timestamp,
    this.userInfo,
    this.replies = const [],
  });

  factory Comment.fromJson(Map<String, dynamic> json) {
    var repliesFromJson = json['replies'] as List<dynamic>?;
    List<Comment> repliesList = repliesFromJson != null
        ? repliesFromJson.map((i) => Comment.fromJson(i)).toList()
        : [];

    return Comment(
      id: json['id'],
      content: json['content'],
      postId: json['postId'],
      userId: json['userId'],
      parentId: json['parentId'],
      timestamp: json['timestamp'],
      userInfo: json['userInfo'] != null
          ? UserModel.fromJson(json['userInfo'])
          : null,
      replies: repliesList,
    );
  }
}