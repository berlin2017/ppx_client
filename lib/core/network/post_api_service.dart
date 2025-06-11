// lib/services/network/post_api_service.dart
import 'package:dio/dio.dart';
import 'package:ppx_client/data/models/post_item_model.dart';

import 'dio_client.dart';

class PostApiService {
  final DioClient _dioClient;

  PostApiService(this._dioClient);

  Future<List<PostItem>> fetchPosts({int page = 0, int limit = 20}) async {
    try {
      // 这里可以添加分页参数，例如 page 和 limit
      final response = await _dioClient.dio.get(
        '/posts',
        queryParameters: {'page': page, 'limit': limit},
      );
      return (response.data as List)
          .map((json) => PostItem.fromJson(json))
          .toList();
    } on DioException catch (e) {
      throw Exception('获取内容列表失败: ${e.message}');
    }
  }

  // 你可以在这里添加其他与帖子相关的API调用，例如创建帖子、点赞等
}
