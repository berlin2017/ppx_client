// lib/repositories/post_repository.dart
import 'package:ppx_client/core/utils/app_logger.dart';
import 'package:ppx_client/data/models/post_item_model.dart';

import '../../core/database/post_dao.dart';
import '../../core/network/post_api_service.dart';

class PostRepository {
  final PostApiService _apiService;
  final PostDao _postDao; // 具体的 DAO 实现将通过依赖注入传入

  PostRepository({required PostApiService apiService, required PostDao postDao})
    : _apiService = apiService,
      _postDao = postDao;

  // 从本地数据库获取帖子
  Future<List<PostItem>> getCachedPosts() async {
    try {
      return await _postDao.getAllPosts();
    } catch (e) {
      AppLogger.error("Error fetching cached posts: $e");
      return []; // 或者抛出自定义错误
    }
  }

  // 从网络获取最新帖子，并缓存到本地
  // forceRefresh 参数可以用于下拉刷新等场景，总是从网络获取
  Future<List<PostItem>> fetchAndCacheRemotePosts({
    bool clearCacheFirst = false,
    int? userId,
    int? categoryId,
    int page = 0,
  }) async {
    try {
      final remotePosts = await _apiService.fetchPosts(userId: userId, categoryId: categoryId, page: page);
      if (remotePosts.isNotEmpty) {
        if (clearCacheFirst) {
          await _postDao.clearAllPosts();
        }
        await _postDao.insertPosts(remotePosts);
      }
      return remotePosts;
    } catch (e) {
      AppLogger.error("Error fetching remote posts: $e");
      throw e;
    }
  }

  Future<List<PostItem>> fetchMyPosts({int page = 0}) async {
    try {
      final remotePosts = await _apiService.fetchMyPosts(page: page);
      if (remotePosts.isNotEmpty) {
        await _postDao.insertPosts(remotePosts);
      }
      return remotePosts;
    } catch (e) {
      AppLogger.error("Error fetching my remote posts: $e");
      throw e;
    }
  }

  // 未来可以添加：
  // Future<void> likePost(String postId) async { ... }
  // Future<void> createPost(PostItem newPost) async { ... }
}
