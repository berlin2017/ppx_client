// lib/core/network/api_service.dart
import 'package:dio/dio.dart';

import '../../data/models/comment_model.dart';
import '../../data/models/user_model.dart';
import 'dio_client.dart';

class ApiService {
  final DioClient _dioClient;

  ApiService(this._dioClient);

  Future<List<Comment>> getComments(int postId) async {
    try {
      final response = await _dioClient.dio.get('/posts/$postId/comments');
      return (response.data as List)
          .map((json) => Comment.fromJson(json))
          .toList();
    } on DioException catch (e) {
      throw Exception('获取评论列表失败: ${e.message}');
    }
  }

  Future<void> addComment(int postId, String content, {int? parentId}) async {
    try {
      await _dioClient.dio.post(
        '/posts/$postId/comments',
        data: {
          'content': content,
          'parentId': parentId,
        },
      );
    } on DioException catch (e) {
      throw Exception('添加评论失败: ${e.message}');
    }
  }

  Future<List<UserModel>> getUsers() async {
    try {
      final response = await _dioClient.dio.get('/users'); // 假设你的用户列表接口是 /users
      return (response.data as List)
          .map((json) => UserModel.fromJson(json))
          .toList();
    } on DioException catch (e) {
      throw Exception('获取用户列表失败: ${e.message}');
    }
  }

// 更多API请求方法...
// Future<UserModel> getUserById(String id) async { ... }
// Future<UserModel> createUser(UserModel user) async { ... }
}