// lib/services/network/post_api_service.dart
import 'package:camera/camera.dart';
import 'package:dio/dio.dart';
import 'package:hive/hive.dart';
import 'package:http_parser/http_parser.dart'; // Ensure this is imported
import 'package:ppx_client/data/models/post_item_model.dart';

import '../../data/models/user_model.dart';
import 'dio_client.dart';

class PostApiService {
  final DioClient _dioClient;

  PostApiService(this._dioClient);

  static const String _userBoxName = 'userBox'; // 与 AppDatabase 中一致
  Future<Box<UserModel>> _getUserBox() async {
    if (!Hive.isBoxOpen(_userBoxName)) {
      return await Hive.openBox<UserModel>(_userBoxName);
    }
    return Hive.box<UserModel>(_userBoxName);
  }

  Future<List<PostItem>> fetchPosts({
    int page = 0,
    int limit = 20,
  }) async {
    try {
      final userId = (await getCurrentUser())?.id ?? -1; // 获取当前用户ID，如果未登录则使用 -1
      // 这里可以添加分页参数，例如 page 和 limit
      final response = await _dioClient.dio.get(
        '/posts',
        queryParameters: {'userId': userId, 'page': page, 'limit': limit},
      );
      return (response.data as List)
          .map((json) => PostItem.fromJson(json))
          .toList();
    } on DioException catch (e) {
      throw Exception('获取内容列表失败: ${e.message}');
    }
  }

  Future<bool> publishPost({
    required String textContent,
    required List<XFile> imageFiles,
    XFile? videoFile,
  }) async {
    final formData = FormData.fromMap({
      'textContent': textContent,
      'image_files': await Future.wait(
        imageFiles.map(
          (file) => MultipartFile.fromFile(
            file.path,
            contentType: MediaType('image', 'jpeg'),
          ),
        ),
      ),
      if (videoFile != null)
        'video_file': await MultipartFile.fromFile(
          videoFile.path,
          contentType: MediaType('video', 'mp4'),
        ),
    });

    UserModel? userModel = await getCurrentUser(); // 假设你有方法获取当前用户ID
    if (userModel == null) {
      throw Exception('用户未登录或不存在');
    }
    try {
      final response = await _dioClient.dio.post(
        '/posts',
        data: formData,
        queryParameters: {'userId': userModel.id},
      );
      return response.statusCode == 200;
    } on DioException catch (e) {
      throw Exception('发布帖子失败: ${e.message}');
    }
  }

  // 获取当前登录的用户信息
  Future<UserModel?> getCurrentUser() async {
    final box = await _getUserBox();
    return box.get('currentUser');
  }

  // 你可以在这里添加其他与帖子相关的API调用，例如创建帖子、点赞等

  Future<bool> likePost(int postId) async {
    UserModel? userModel = await getCurrentUser(); // 假设你有方法获取当前用户ID
    if (userModel == null) {
      throw Exception('用户未登录或不存在');
    }

    final data = {'postId': postId, 'userId': userModel.id};
    try {
      final response = await _dioClient.dio.post(
        '/posts_like',
        queryParameters: data,
      );
      return response.statusCode == 200;
    } on DioException catch (e) {
      throw Exception('帖子点赞失败: ${e.message}');
    }
  }

  Future<bool> unlikePost(int postId) async {
    UserModel? userModel = await getCurrentUser(); // 假设你有方法获取当前用户ID
    if (userModel == null) {
      throw Exception('用户未登录或不存在');
    }

    final data = {'postId': postId, 'userId': userModel.id};
    try {
      final response = await _dioClient.dio.post(
        '/posts_unlike',
        queryParameters: data,
      );
      return response.statusCode == 200;
    } on DioException catch (e) {
      throw Exception('帖子取消点赞失败: ${e.message}');
    }
  }

  Future<bool> dislikePost(int postId) async {
    UserModel? userModel = await getCurrentUser(); // 假设你有方法获取当前用户ID
    if (userModel == null) {
      throw Exception('用户未登录或不存在');
    }

    final data = {'postId': postId, 'userId': userModel.id};
    try {
      final response = await _dioClient.dio.post(
        '/posts_dislike',
        queryParameters: data,
      );
      return response.statusCode == 200;
    } on DioException catch (e) {
      throw Exception('帖子踩失败: ${e.message}');
    }
  }

  Future<bool> undislikePost(int postId) async {
    UserModel? userModel = await getCurrentUser(); // 假设你有方法获取当前用户ID
    if (userModel == null) {
      throw Exception('用户未登录或不存在');
    }

    final data = {'postId': postId, 'userId': userModel.id};
    try {
      final response = await _dioClient.dio.post(
        '/posts_undislike',
        queryParameters: data,
      );
      return response.statusCode == 200;
    } on DioException catch (e) {
      throw Exception('帖子取消踩失败: ${e.message}');
    }
  }
}
